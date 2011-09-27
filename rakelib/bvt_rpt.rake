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
  DEFAULT_VCAP_DIR        = "../../vcap"
  DEFAULT_SERVICES_DIR    = "../../vcap/services"
  DEFAULT_ARTIFACTS_DIR   = "./ci-artifacts-dir"

  attr_reader :root_dir, :config_dir,
              :vcap_dir, :services_dir,
              :artifacts_dir, :email_recipients

  def initialize
    # Root dir will be the tests dir (parent of rakelib)
    @root_dir        = File.expand_path("..", File.dirname(__FILE__))
    @config_dir      = File.expand_path("config", @root_dir)

    # Pull in all property values from yml file, defaulting values when missing
    config_file = ENV['BVT_BOSH_CONFIG_FILE'] || File.join(@config_dir, "bvt_bosh.yml")
    if File.exists?(config_file)
      @config = YAML::load(File.open(config_file)) || Hash.new
    else
      @config = Hash.new
    end
    @vcap_dir         = File.expand_path(@config['vcap_dir'] || DEFAULT_VCAP_DIR, @root_dir)
    @services_dir     = File.expand_path(@config['services_dir'] || DEFAULT_SERVICES_DIR, @root_dir)
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
    FileUtils.rm_rf(bvt_env.artifacts_dir)
    Dir.mkdir(bvt_env.artifacts_dir)
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

  # Returns output on git version strings
  def repo_info(root_dir)
    return_log=" ==== REPOSITORY INFORMATION ===="
    root_dir.entries.sort.each do | fname  |
      fpath = File.join(root_dir.path, fname)
      if File.directory?(fpath) && File.exists?(fpath+"/.git/config")
        begin
          this_repo_log=`cd #{fpath};git log -1 --pretty=short`
          return_log+="\n\nREPO: "+fname+"\n"+this_repo_log
        rescue
          puts "WARNING: failed collecting git repository version info"
        end
      end
    end
    return return_log
  end

  def bvt_summary(results_dir_path, git_root_path, verbose=true)
    summary = "Target " + ENV['VCAP_BVT_TARGET']+ "\n"
    errfail_count = 0
    total_count = 0
    total_time = 0
    results_dir = Dir.new(results_dir_path)
    # Start building a summary, with just the pass/fail/time values
    # at first.
    results_dir.entries.sort.each do | f |
      if f.match("TEST.*\.xml")
        doc = Nokogiri::XML(File.open(File.join(results_dir_path, f)))
        suite_node = doc.root()
        suite_failures = suite_node.attribute("failures")
        suite_tests = suite_node.attribute("tests")
        suite_errors = suite_node.attribute("errors")
        suite_description = suite_node.attribute("name")
        suite_time = suite_node.attribute("time")
        errfail_count += suite_failures.value().to_i()
        errfail_count += suite_errors.value().to_i()
        total_count += suite_tests.value().to_i()
        total_time += suite_time.value().to_f()
        summary += "#{f}: tests=#{suite_tests}, errors=#{suite_errors}, failures=#{suite_failures}, time=#{suite_time}\n"
      end
    end
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
      vcap_parent = Dir.new(git_root_path)
      summary += "\n\n"+repo_info(vcap_parent)
    end
    minutes = (total_time/60).to_i().to_s()
    seconds = "%02d" % (total_time%60).to_i().to_s()
    total_time_string = ""+minutes+":"+seconds
    return_summary = "SUMMARY OF BVT EXECTION\n"
    return_summary += "total tests = #{total_count}\n"
    return_summary += "errors+failures = #{errfail_count}\n"
    return_summary += "total time = #{total_time}\n"
    return_summary += summary
    return return_summary, errfail_count, total_count, total_time_string
  end

  desc "Summarize BVT results"
  task :brief_bvt_summary do
    puts "Summarizing BVT results in #{bvt_env.artifacts_dir}"
    summary = bvt_summary(bvt_env.artifacts_dir, File.dirname(bvt_env.vcap_dir), false)
    puts "#{summary}"
  end

  desc "Summarize BVT results with test output"
  task :full_bvt_summary do
    puts "Summarizing BVT results in #{bvt_env.artifacts_dir}"
    summary = bvt_summary(bvt_env.artifacts_dir, File.dirname(bvt_env.vcap_dir), true)
    puts "#{summary}"
  end


  def send_email(from, to, subject, message)
   to_lines = ""
   to.split(",").each do | recipient|
     to_lines+="To: #{recipient}\n"
   end
   msg = <<END_OF_MESSAGE
From: #{from}
#{to_lines}Subject: #{subject}

#{message}
END_OF_MESSAGE

    Net::SMTP.start("localhost",25) do |smtp|
      smtp.send_message msg, from, to.split(",")
    end
  end

  desc "Email BVT summary"
  task :email_bvt_summary  do
    puts "Emailing BVT results in #{bvt_env.artifacts_dir}"
    # Get pass/fail status, and full text of results files
    summary, errfail_count, total_count, total_time = bvt_summary(bvt_env.artifacts_dir, File.dirname(bvt_env.vcap_dir))
    email_body = "Number of errs/fails: #{errfail_count}\nTotal Tests: #{total_count}\nTotal Time: #{total_time}\n#{summary}"
    recipients = ENV['EMAIL_RECIPIENTS'] || bvt_env.email_recipients
    from = ENV['USER']+"@vmware.com"
    send_email(from, recipients, "bvt summary", email_body)
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
