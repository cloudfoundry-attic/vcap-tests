require 'yaml'
require 'fileutils'
require 'tempfile'
require 'open3'
require 'nokogiri'
require 'net/smtp'

# Keep our state in a seperate class so that we don't pollute the
# global environment
class BvtEnv

  DEFAULT_EMAIL_RECIPIENTS = "cftest@vmware.com"

  # The following are all relative to the test dir root.
  DEFAULT_ARTIFACTS_DIR   = "./ci-artifacts-dir"

  attr_reader :root_dir, :config_dir,
              :vcap_dir, :git_root_dir,
              :artifacts_dir, :email_recipients

  def initialize
    # Root dir will be the tests dir (parent of rakelib)
    @root_dir        = File.expand_path("..", File.dirname(__FILE__))
    @vcap_dir        = ENV['VCAP'] || File.dirname(@root_dir)
    @config_dir      = File.expand_path("config", @root_dir)
    # git_root_dir is applicable to full reporting with git repo version info
    @git_root_dir    = ENV['GIT_ROOT_DIR'] || @vcap_dir

    # Pull in all property values from yml file, defaulting values when missing
    config_file = ENV['BVT_BOSH_CONFIG_FILE'] || File.join(@config_dir, "bvt_bosh.yml")
    if File.exists?(config_file)
      @config = YAML::load(File.open(config_file)) || Hash.new
    else
      @config = Hash.new
    end
    @artifacts_dir    = ENV['ARTIFACTS_DIR'] || File.expand_path(@config['artifacts_dir'] || DEFAULT_ARTIFACTS_DIR, @root_dir)
    @email_recipients = ENV['EMAIL_RECIPIENTS'] || @config['email_recipients'] || DEFAULT_EMAIL_RECIPIENTS

    unless File.directory?(@artifacts_dir)
      Dir.mkdir(@artifacts_dir)
    end
  end
end

namespace :bvt_rpt do
  bvt_env = BvtEnv.new
  bvt_failed = false

  desc "Set BVT environment"
  task :bvt_setenv do
    # Could default to vcap.me, but forcing user to specify
    unless ENV['VCAP_BVT_TARGET']
      fail "Please set the VCAP_BVT_TARGET environment variable"
    end
  end

  desc "Delete/recreate artifacts dir"
  task :clean_artifacts_dir do
    FileUtils.rm Dir.glob("#{bvt_env.artifacts_dir}/TEST*.xml")
  end

  desc "Run BVT tests, and continue if error"
  task :bvt_keep_going do
    begin
      Rake::Task['bvt_rpt:bvt'].invoke
    rescue
      bvt_failed = true
      puts "Continuing after BVT failure..."
    end
  end

  desc "Run BVT tests <keep_going:true>"
  task :bvt => [:bvt_setenv, :clean_artifacts_dir] do | t, args |
    puts "Starting BVT against #{ENV['VCAP_BVT_TARGET']}"
    puts "  with output to #{bvt_env.artifacts_dir}"
    root = File.join(CoreComponents.root, "tests")
    # Allow user to specify cucumber switches, e.g. --tagname some-tag-name
    cucumber_options = ENV['CUCUMBER_OPTIONS'] || "--tags ~@bvt_upgrade"
    cmd = BuildConfig.bundle_cmd("bundle exec cucumber --format junit -o #{bvt_env.artifacts_dir} #{cucumber_options}")
    sh "\tcd #{root}; #{cmd}" do |success, exit_code|
      if success
        puts "BVT completed successfully"
      else
        fail "BVT did not complete successfully - exited with code: #{exit_code.exitstatus}"
      end
    end
  end

  # Reports ALL git sub-repos, in case some are soft-links
  # to head.
  def repo_info(root_dir)
    return_log = " ==== REPOSITORY INFORMATION ====\n"
    base = File.basename(root_dir)
    gitfiles=`find -L #{root_dir} -name .git 2>/dev/null`
    gitfiles.sort.each do | gitfile |
      gitdir = File.dirname(gitfile).chomp
      this_repo_log = `cd #{gitdir}; git log -1 --oneline`
      return_log += "#{gitdir.gsub(root_dir, base)} : #{this_repo_log}"
    end
    return_log
  end

  def bvt_summary(results_dir_path, git_root_path, verbose = true)
    summary = "Target " + ENV['VCAP_BVT_TARGET'] + "\n"
    total_errs = 0
    total_count = 0
    total_time = 0
    results_dir = Dir.new(results_dir_path)
    # if verbose output requested, then append each output file
    # to the summary, and some git repo state info
    if verbose
      results_dir.entries.sort.each do | f |
        if f.match("TEST.*\.xml")
          summary += "\n\n === #{f} === \n"
          summary += IO.read(File.join(results_dir_path, f))
        end
      end
      # append some basic information on the git repo state
      summary += "\n\n" + repo_info(git_root_path) + "\n"
    end

    # Start building a summary, with just the pass/fail/time values
    # at first.
    results_dir.entries.sort.each do | f |
      if f.match("TEST.*\.xml")
        doc = Nokogiri::XML(File.open(File.join(results_dir_path, f)))
        suite_node = doc.root
        suite_failures = suite_node.attribute("failures")
        suite_tests = suite_node.attribute("tests")
        suite_errors = suite_node.attribute("errors")
        suite_description = suite_node.attribute("name")
        suite_time = suite_node.attribute("time")
        total_errs += suite_failures.value.to_i
        total_errs += suite_errors.value.to_i
        total_count += suite_tests.value.to_i
        total_time += suite_time.value.to_f
        summary += "#{f}: tests=#{suite_tests}, errors=#{suite_errors}, failures=#{suite_failures}, time=#{suite_time}\n"
      end
    end
    minutes = (total_time/60).to_i.to_s
    seconds = "%02d" % (total_time%60).to_i.to_s
    total_time_string = "" + minutes + ":" + seconds
    return_summary = summary
    return_summary += "\nSUMMARY OF BVT EXECUTION\n"
    return_summary += "total tests = #{total_count}\n"
    return_summary += "total errors+failures = #{total_errs}\n"
    return_summary += "total time = #{total_time} (#{total_time_string})\n"
    return return_summary, total_errs, total_count
  end

  desc "Summarize BVT results"
  task :brief_bvt_summary do
    puts "Summarizing BVT results in #{bvt_env.artifacts_dir}"
    summary, total_errs, total_count = bvt_summary(bvt_env.artifacts_dir, bvt_env.git_root_dir, false)
    puts summary
  end

  desc "Summarize BVT results with test output"
  task :full_bvt_summary do
    puts "Summarizing BVT results in #{bvt_env.artifacts_dir}"
    summary, total_errs, total_count = bvt_summary(bvt_env.artifacts_dir, bvt_env.git_root_dir, true)
    puts summary
  end


  def send_email(from, to, subject, message)
   to_lines = ""
   to.split(",").each do | recipient |
     to_lines += "To: #{recipient}\n"
   end
   msg = <<END_OF_MESSAGE
From: #{from}
#{to_lines}Subject: #{subject}

#{message}
END_OF_MESSAGE

    Net::SMTP.start("localhost",25) do | smtp |
      smtp.send_message msg, from, to.split(",")
    end
  end

  desc "Email BVT summary"
  task :email_bvt_summary  do
    puts "Emailing BVT results in #{bvt_env.artifacts_dir}"
    # Get pass/fail status, and full text of results files
    summary, total_errs, total_tests  = bvt_summary(bvt_env.artifacts_dir, File.dirname(bvt_env.vcap_dir))
    recipients = ENV['EMAIL_RECIPIENTS'] || bvt_env.email_recipients
    from = ENV['USER'] + "@vmware.com"
    subject = "bvt summary #{ENV['VCAP_BVT_TARGET']} #{total_tests} run, #{total_errs} errors"
    send_email(from, recipients, subject, summary)
  end

  desc "Run BVTs, brief stdout report"
  task :bvt_rpt => [:bvt_keep_going, :full_bvt_summary] do
    if bvt_failed
      fail "BVTs failed."
    end
  end


  desc "Run BVTs, report and email results"
  task :bvt_rpt_email => [:bvt_keep_going, :full_bvt_summary, :email_bvt_summary] do
    if bvt_failed
      fail "BVTs failed."
    end
  end

end
