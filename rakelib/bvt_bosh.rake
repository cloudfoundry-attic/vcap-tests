require 'yaml'
require 'fileutils'
require 'tempfile'
require 'open3'
require 'nokogiri'
require 'net/smtp'

# Keep our state in a seperate class so that we don't pollute the
# global environment
class BoshBvtEnv
   
  DEFAULT_BOSH_TARGET     = "PLEASE_SET_director_url_IN_bvt_bosh.yml"
  DEFAULT_MANIFEST   = "PLEASE SET bosh_manifest in bvt_bosh.yml"
  DEFAULT_BOSH_USER       = "admin"
  DEFAULT_BOSH_PASSWORD   = "admin"
  DEFAULT_BOSH_DEV_NAME   = "bvt_bosh"
  DEFAULT_EMAIL_RECIPIENTS = "cftest@vmware.com"

  # The following are all relative to the test dir root.
  # FIXME: move these to config files too and figure out where
  # they should be on the bamboo system.  Bamboo will have
  # already checked out core,
  VCAP_DIR        = "../../vcap"
  SERVICES_DIR    = "../../vcap-services" 
  RELEASE_DIR     = "../../release"
  DEPLOYMENTS_DIR = "../../deployments"
  RESULTS_DIR     = "./ci-artifacts-dir"

  attr_reader :root_dir, :release_dir, :config_dir, :director_url,
              :manifest_src, :manifest_file, :vcap_dir, :services_dir,
              :release_cfg, :bosh_user, :bosh_password, :bosh_dev_name,
              :results_dir, :email_recipients

  def initialize
    # Root dir will be the tests dir (parent of rakelib)
    @root_dir        = File.expand_path("..", File.dirname(__FILE__))
    @config_dir      = File.expand_path("config", @root_dir)

    # Pull in all property values from yml file, defaulting values when missing
    bosh_bvt_config_file = ENV['BOSH_BVT_CONFIG_FILE'] || File.join(@config_dir, 'bvt_bosh.yml')
    @config = YAML::load(File.open(bosh_bvt_config_file))
    
    @release_dir     = File.expand_path(RELEASE_DIR, @root_dir)
    @director_url    =  @config['director_url'] || DEFAULT_DIRECTOR_URL
    @bosh_user       = @config['bosh_user'] || DEFAULT_BOSH_USER
    @bosh_password   = @config['bosh_password'] || DEFAULT_BOSH_PASSWORD
    @bosh_dev_name   = @config['bosh_dev_name'] || DEFAULT_BOSH_DEV_NAME
    @vcap_dir        = @config['vcap_dir'] || File.expand_path(VCAP_DIR, @root_dir)
    @services_dir    = @config['services_dir'] || File.expand_path(SERVICES_DIR, @root_dir)
    @results_dir     = @config['results_dir'] || File.expand_path(RESULTS_DIR, @root_dir)
    @deployments_dir = @config['deployments_dir'] || File.expand_path(DEPLOYMENTS_DIR, @root_dir)
    @bosh_manifest   = @config['bosh_manifest']
    @email_recipients = @config['email_recipients'] || DEFAULT_EMAIL_RECIPIENTS
    puts "bosh_manifest is: #{@bosh_manifest}"
    puts "director_url is: #{@director_url}"
    @manifest_src    = File.expand_path("#{DEPLOYMENTS_DIR}/#{@bosh_manifest}", @root_dir)
    @manifest_file   = Tempfile.new('manifest')
    ##@manifest_file   = File.open(#{@results_dir}+"/bvt_bosh_manifest.yml","w")
  end
end

namespace :ci_bosh do
  bosh_env = BoshBvtEnv.new

  desc "Set BOSH target"
  task :target do
    url = bosh_env.director_url
    puts "Setting BOSH target to #{url}"
    rslt = `bosh target #{url}`
    if not /Target set to '.* \(#{url}\)'/.match(rslt)
      fail "Cloud not set bosh target. Result: #{rslt}"
    end
  end

  desc "Login to BOSH"
  task :login => [:target] do
    puts "Logging into BOSH as '#{bosh_env.bosh_user}'"
    rslt = `bosh login #{bosh_env.bosh_user} #{bosh_env.bosh_password}`
    if not /Logged in as '#{bosh_env.bosh_user}'/.match(rslt)
      fail "Could not login to bosh. Result: #{rslt}"
    end
  end

  desc "Set BOSH deployment"
  task :deployment do
    man = bosh_env.manifest_file.path
    puts "Setting BOSH deployment"
    rslt = `bosh deployment #{man}`
    if not /Deployment set to .*/.match(rslt)
      fail "Could not set bosh deployment. Result: #{rslt}"
    end
  end

  desc "Checkout release"
  task :checkout_release do
    puts "Checking out release"
    Dir.chdir(bosh_env.release_dir) do
      system "git pull"
    end
  end

  desc "Update core"
  task :update_core do
    puts "Updating core"
    Dir.chdir(bosh_env.release_dir) do
      # TODO: add ability to do selectively do official submodule
      # update or release right from HEAD of real core
      FileUtils::rm_rf("src/core")
      FileUtils::ln_s(bosh_env.vcap_dir, "src/core")
    end
  end

  desc "Update services"
  task :update_services do
    puts "Updating services"
    Dir.chdir(bosh_env.release_dir) do
      # TODO: add ability to do selectively do official submodule
      # update or release right from HEAD of real core
      FileUtils::rm_rf("src/services")
      FileUtils::ln_s(bosh_env.services_dir, "src/services")
    end
  end

  desc "Clean releases"
  task "clean_releases" do
    puts "Cleaning local versions of old releases"
    Dir.chdir(bosh_env.release_dir) do
      FileUtils.rm Dir.glob('dev_releases/*.tgz')
      # Probably should delete entire directory, including .yml files?  And config/dev.yml at same time?
    end
  end

  # Removed these tasks as dependencies of create_release, in case we know
  # we've already got the release directory hierarchy in the desired state. 
  desc "prepare the release directory tree"
  task :prep_release_dir => [:checkout_release, :clean_releases, :update_core, :update_services] do; end

  desc "Create release <fail_if_unchanged default=true>"
  task :create_release, :fail_if_unchanged do | t, args |
    puts "performing create release"
    fail_if_unchanged = args[:fail_if_unchanged] || 'true'
    puts "Creating release under #{bosh_env.release_dir}"
    rslt = ''
    Dir.chdir(bosh_env.release_dir) do
      if File.exists?("config/dev.yml") && File.exists?("dev_releases")
        initial_cfg = YAML.load_file("config/dev.yml")
        rslt = `bosh create release --force`
      else
        puts "no config/dev.yml found, so setting dev_name=#{bosh_env.bosh_dev_name} in stdin..."
        Open3.popen2("bosh create release --force") do |i,o|
          i.print "#{bosh_env.bosh_dev_name}"
          i.close
          rslt = o.read
        end
      end
    end
    if rslt.include?("Looks like this version is no different from") && fail_if_unchanged[0].downcase == "t" 
      fail "bosh create release did not generate a new release; no different from predecessor"
    end
    if !rslt.include?("Release manifest saved in")
       fail "bosh create release failed: #{rslt}"
    end
  end

  desc "Upload latest release, <fail_if_exists default=true>"
  task :upload_latest_release, :fail_if_exists, :needs => :login do | t, args |
    fail_if_exists = args[:fail_if_exists] || 'true'
    puts "Uploading latest release"
    Dir.chdir(bosh_env.release_dir) do
      cfg = YAML.load_file("config/dev.yml")
      release_yml = "#{cfg['latest_release_filename']}"
      puts "  using filename #{release_yml}"
      rslt = `bosh upload release #{release_yml}`
      if rslt.include?("has already been uploaded")
         if fail_if_exists[0].downcase == "t"
          fail "bosh upload release failed. Result:\n#{rslt}"
         else
           puts "warning: this release has already been uploaded."
         end
      else
        if not /Task [\d]+: state is 'done'/.match(rslt)
          fail "bosh upload release failed. Result:\n#{rslt}"
        end
      end
    end
  end

  desc "Generate manifest"
  task :generate_manifest do
    puts "Generating manifest"
    cfg = YAML.load_file("#{bosh_env.release_dir}/config/dev.yml")
    # Parse the release number out of the 'latest_release_filename'
    manifest = YAML.load_file(bosh_env.manifest_src)
    cfg['latest_release_filename'] =~ /([0-9]*).yml/ 
    matchData = Regexp.last_match
    manifest['release'] = {'name' => cfg['name'], 'version' => matchData[1].to_i }
    bosh_env.manifest_file.rewind
    bosh_env.manifest_file << manifest.to_yaml
    bosh_env.manifest_file.flush
  end

  # This is not actually used as it will cause the deployment
  # to be really slow.  But it is here in case we ever want to
  # do it all the time, or maybe if a bvt tests fails we could
  # do a delete and redploy to see if it was due to stale test
  # state or something.
  desc "Delete deployment"
  task :delete_deployment do
    puts "Deleting deployment"
    cfg = YAML.load_file(bosh_env.manifest_src)
    rslt = `bosh delete deployment #{cfg['name']}`
    if not /Task [\d]+: state is 'done'/.match(rslt)
      fail "bosh delete deployment failed. Result:\n#{rslt}"
    end
  end

  desc "Deploy AppCloud via BOSH"
  task :deploy => [:login, :generate_manifest, :deployment] do
    puts "Deploying release via BOSH"
    rslt = `bosh --non-interactive deploy`
    if not /Task [\d]+: state is 'done'/.match(rslt)
      fail "bosh deploy failed. Result:\n#{rslt}"
    end
  end

  desc "Set BVT environment"
  task :bvt_env do
    cfg = YAML.load_file(bosh_env.manifest_src)
    ENV['VCAP_BVT_TARGET'] = cfg['properties']['domain']
    ENV.delete('BUNDLE_PATH')  # was causing issues.. TODO: ask AB why he sets this
                               # Was to allow different projects to share a CI system,
                               # and not be affected by system gems.
  end

  desc "Run BVT"
  task :bvt => [:bvt_env] do
    puts "Starting BVT against #{ENV['VCAP_BVT_TARGET']}"
    root = File.join(CoreComponents.root, 'tests')
    cmd = BuildConfig.bundle_cmd("bundle exec cucumber --format junit -o #{bosh_env.results_dir}")
    sh "\tcd #{root}; #{cmd}" do |success, exit_code|
      if success
        puts "BVT completed successfully"
      else
        fail "BVT did not complete successfully - exited with code: #{exit_code.exitstatus}"
      end
    end
  end

  def bvt_summary(results_dir_path)
    summary = ""
    errFail_count = 0
    total_count = 0
    results_dir = Dir.new(results_dir_path)
    results_dir.each do | f |
      if f.match('TEST.*\.xml')
        doc = Nokogiri::XML(File.open(File.join(results_dir_path, f)))
        suite_node = doc.root()
        suite_failures = suite_node.attribute("failures")
        suite_tests = suite_node.attribute("tests")
        suite_errors = suite_node.attribute("errors")
        suite_description = suite_node.attribute("name")
        suite_time = suite_node.attribute("time")
        errFail_count += suite_failures.value().to_i()
        errFail_count += suite_errors.value().to_i()
        total_count += suite_tests.value().to_i()
        summary += "#{f}: tests=#{suite_tests}, errors=#{suite_errors}, failures=#{suite_failures}\n"
      end
    end
    return summary, errFail_count, total_count
  end

  desc "Summarize BVT results, without failure details"
  task :brief_bvt_summary do
    puts "Summarizing BVT results in #{bosh_env.results_dir}"
    summary, errFailCount = bvt_summary(bosh_env.results_dir)
    puts "SUMMARY OF BVT EXECTION\n #{summary}"
    puts "errFailCount is: #{errFailCount}"
  end
  
  def send_email(from, to, subject, message)
   to_lines=""
   to.split(',').each do | recipient|
     to_lines+="To: #{recipient}\n"
   end
   msg = <<END_OF_MESSAGE
From: #{from}
#{to_lines}Subject: #{subject}

#{message}
END_OF_MESSAGE
    
    Net::SMTP.start('localhost',25) do |smtp|
      smtp.send_message msg, from, to.split(',')
    end
  end

  desc "Email BVT summary"
  task :email_bvt_summary do
    puts "Emailing BVT results in #{bosh_env.results_dir}"
    summary, errFail_count, total_count = bvt_summary(bosh_env.results_dir)
    email_body = "Number of errs/fails: #{errFail_count}\nTotal Tests: #{total_count}\n#{summary}"
    # FIX_ME: pull default email recipient from property file
    recipients = ENV['EMAIL_RECIPIENTS'] || bosh_env.email_recipients
    from = ENV['USER']+"@vmware.com"
    send_email(from, recipients, "bosh_bvt summary", email_body)
  end
  
  
  task :java_client_tests => [:bvt_env] do
    puts "Starting Java client driven tests against #{ENV['VCAP_BVT_TARGET']}"
    puts "NOT IMPLEMENTED."

    # TODO: Code below copied from bvt.rake, but the tools directory is
    # not in the repo.  Where does the ci system get it from?
    #
    # NOTE(wlb): Check out the 'clone_repo' task in rakelib/java_client.rake
    #RakeDefs.set_root "tools/sts/AppCloudClient"
    #sh "\tmvn -Dvcap.target.domain=vcap.me -e -ff clean test" do |success, exit_code|
    #  if success
    #    puts "Java client tests completed successfully"
    #  else
    #    fail "Java client tests did not complete successfully - exited with code: #{exit_code.exitstatus}"
    #  end
    #end
  end

  # The dependencies for all actions are on this task rather than
  # putting a dependency of :create_release on :upload_latest,
  # for example, so that the individual tasks can be run in isolation
  # for debugging.
  desc "Update release dir, and deploy via BOSH"
  task :prep_create_and_deploy => [:prep_release_dir, :create_release, :upload_latest_release, :deploy] do; end
  desc "Deploy existing release dir via BOSH"
  task :create_and_deploy => [:create_release, :upload_latest_release, :deploy] do; end
  desc "Create and deploy a release, continue if already deployed"
  task :create_and_deploy_keep_going do
    Rake.application.invoke_task("ci_bosh:create_release[false]")
    Rake.application.invoke_task("ci_bosh:upload_latest_release[false]")
    Rake.application.invoke_task("ci_bosh:deploy")
  end

  desc "Create and deploy a release, then run bvt tests"
  task :ci_tests      => [:create_and_deploy, :bvt] do; end
  desc "Create and deploy a release, continuing if already exists, then run bvts"
  task :ci_tests_keep_going => [:create_and_deploy_keep_going, :bvt] do; end

  task :ci_java_tests => [:create_and_deploy, :java_client_tests] do; end
end

