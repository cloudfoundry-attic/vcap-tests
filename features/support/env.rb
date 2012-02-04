
require 'rubygems'
require 'bundler'
require 'httpclient'

Bundler.setup

$:.unshift(File.join(File.dirname(__FILE__), '../../lib/client/lib'))
require 'json/pure'
require 'singleton'
require 'spec'
require 'zip/zipfilesystem'
require 'vmc'
require 'cli'
require 'curb'
require 'pp'
require 'fileutils'
require 'tempfile'
require 'tmpdir'
require 'digest/sha1'

# The integration test automation based on Cucumber uses the AppCloudHelper as a driver that takes care of
# of all interactions with AppCloud through the VCAP::BaseClient intermediary.
#
# Author:: A.B.Srinivasan
# Copyright:: Copyright (c) 2010 VMware Inc.

TEST_AUTOMATION_USER_ID = "vcap_tester@vmware.com"
TEST_AUTOMATION_PASSWORD = "tester"
SIMPLE_APP = "simple_app"
SIMPLE_APP2 = "simple_app2"
SIMPLE_APP3 = "simple_app3"
REDIS_LB_APP = "redis_lb_app"
ENV_TEST_APP = "env_test_app"
TINY_JAVA_APP = "tiny_java_app"
SIMPLE_DB_APP = "simple_db_app"
SIMPLE_PHP_APP = "simple_php_app"
BROKEN_APP = "broken_app"
RAILS3_APP = "rails3_app"
JPA_APP = "jpa_app"
HIBERNATE_APP = "hibernate_app"
DBRAILS_APP = "dbrails_app"
DBRAILS_BROKEN_APP = "dbrails_broken_app"
GRAILS_APP = "grails_app"
ROO_APP = "roo_app"
SIMPLE_ERLANG_APP = "mochiweb_test"
SIMPLE_LIFT_APP = "simple-lift-app"
LIFT_DB_APP = "lift-db-app"
TOMCAT_VERSION_CHECK_APP="tomcat-version-check-app"
NEO4J_APP = "neo4j_app"
ATMOS_APP = "atmos_app"
SIMPLE_PYTHON_APP = "simple_wsgi_app"
PYTHON_APP_WITH_DEPENDENCIES = "wsgi_app_with_requirements"
SIMPLE_DJANGO_APP = "simple_django_app"
SPRING_ENV_APP = "spring-env-app"
AUTO_RECONFIG_TEST_APP="auto-reconfig-test-app"
AUTO_RECONFIG_MISSING_DEPS_TEST_APP="auto-reconfig-missing-deps-test-app"
SIMPLE_KV_APP = "simple_kv_app"
BROKERED_SERVICE_APP = "brokered_service_app"
JAVA_APP_WITH_STARTUP_DELAY = "java_app_with_startup_delay"

class Fixnum
  def to_json(options = nil)
    to_s
  end
end

After do
  AppCloudHelper.instance.cleanup
end

After("@creates_simple_app") do
  AppCloudHelper.instance.delete_app_internal SIMPLE_APP
end

After("@creates_simple_app2") do
  AppCloudHelper.instance.delete_app_internal SIMPLE_APP2
end

After("@creates_simple_app3") do
  AppCloudHelper.instance.delete_app_internal SIMPLE_APP3
end

After("@creates_tiny_java_app") do
  AppCloudHelper.instance.delete_app_internal TINY_JAVA_APP
end

After("@creates_simple_db_app") do
  AppCloudHelper.instance.delete_app_internal SIMPLE_DB_APP
end

After("@creates_redis_lb_app") do
  AppCloudHelper.instance.delete_app_internal REDIS_LB_APP
end

After("@creates_env_test_app") do
  AppCloudHelper.instance.delete_app_internal ENV_TEST_APP
end

After("@creates_broken_app") do
  AppCloudHelper.instance.delete_app_internal BROKEN_APP
end

After("@creates_rails3_app") do
  AppCloudHelper.instance.delete_app_internal RAILS3_APP
end

After("@creates_jpa_app") do
  AppCloudHelper.instance.delete_app_internal JPA_APP
end

After("@creates_hibernate_app") do
  AppCloudHelper.instance.delete_app_internal HIBERNATE_APP
end

After("@creates_dbrails_app") do
  AppCloudHelper.instance.delete_app_internal DBRAILS_APP
end

After("@creates_dbrails_broken_app") do
  AppCloudHelper.instance.delete_app_internal DBRAILS_BROKEN_APP
end

After("@creates_grails_app") do
  AppCloudHelper.instance.delete_app_internal GRAILS_APP
end

After("@creates_roo_app") do
  AppCloudHelper.instance.delete_app_internal ROO_APP
end

After("@creates_mochiweb_app") do
    AppCloudHelper.instance.delete_app_internal SIMPLE_ERLANG_APP
end

After("@creates_simple_lift_app") do
  AppCloudHelper.instance.delete_app_internal SIMPLE_LIFT_APP
end

After("@creates_lift_db_app") do
  AppCloudHelper.instance.delete_app_internal LIFT_DB_APP
end

After("@creates_tomcat_version_check_app") do
  AppCloudHelper.instance.delete_app_internal TOMCAT_VERSION_CHECK_APP
end

After("@creates_neo4j_app") do
  AppCloudHelper.instance.delete_app_internal NEO4J_APP
end

After("@creates_wsgi_app") do
  AppCloudHelper.instance.delete_app_internal SIMPLE_PYTHON_APP
end

After("@creates_wsgi_app") do
  AppCloudHelper.instance.delete_app_internal SIMPLE_PYTHON_APP
end

After("@creates_django_app") do
  AppCloudHelper.instance.delete_app_internal SIMPLE_DJANGO_APP
end

After("@creates_simple_php_app") do
  AppCloudHelper.instance.delete_app_internal SIMPLE_PHP_APP
end

After("@creates_spring_env_app") do
  AppCloudHelper.instance.delete_app_internal SPRING_ENV_APP
end

After("@creates_auto_reconfig_test_app") do
  AppCloudHelper.instance.delete_app_internal AUTO_RECONFIG_TEST_APP
end

After("@creates_auto_reconfig_missing_deps_test_app") do
  AppCloudHelper.instance.delete_app_internal AUTO_RECONFIG_MISSING_DEPS_TEST_APP
end

After("@creates_java_app_with_delay") do
  AppCloudHelper.instance.delete_app_internal JAVA_APP_WITH_STARTUP_DELAY
end

at_exit do
  AppCloudHelper.instance.cleanup
end

['TERM', 'INT'].each do |s|
  trap(s) do
    ENV['parallel_tests'] = 'false'
    AppCloudHelper.instance.cleanup
    Process.exit!
  end
end

class AppCloudHelper
  include Singleton

  def initialize
    @last_registered_user, @last_login_token = nil
    # Go through router endpoint for CloudController
    @target = ENV['VCAP_BVT_TARGET'] || 'vcap.me'
    @registered_user = ENV['VCAP_BVT_USER']
    @registered_user_passwd = ENV['VCAP_BVT_USER_PASSWD']
    @service_broker_url = ENV['SERVICE_BROKER_URL']
    @service_broker_token = ENV['SERVICE_BROKER_TOKEN']
    @base_uri = "http://api.#{@target}"
    @droplets_uri = "#{@base_uri}/assets"
    @resources_uri = "#{@base_uri}/resources"
    @services_uri = "#{@base_uri}/services"
    @suggest_url = @target

    puts "\n** VCAP_BVT_TARGET = '#{@target}' (set environment variable to override) **"
    puts "** Running as user: '#{test_user}' (set environment variables VCAP_BVT_USER / VCAP_BVT_USER_PASSWD to override) **"
    puts "** VCAP CloudController = '#{@base_uri}' **\n\n"

    # Namespacing allows multiple tests to run in parallel.
    # Deprecated, along with the load-test tasks.
    # puts "** To run multiple tests in parallel, set environment variable VCAP_BVT_NS **"
    @namespace = ENV['VCAP_BVT_NS'] || ''
    puts "** Using namespace: '#{@namespace}' **\n\n" unless @namespace.empty?

    config_file = File.join(File.dirname(__FILE__), 'testconfig.yml')
    begin
      @config = File.open(config_file) do |f|
        YAML.load(f)
      end
    rescue => e
      puts "Could not read configuration file:  #{e}"
      exit
    end
    @testapps_dir = File.join(File.dirname(__FILE__), '../../assets')
    @root_dir = File.join(File.dirname(__FILE__), '../..')
    @client = VMC::Client.new(@base_uri)

    # Make sure we cleanup if we had a failed run..
    # Fake out the login and registration piece..
    begin
      login
      @last_registered_user = test_user
    rescue
    end
    check_admin_user
    cleanup
  end

  def check_admin_user
    # Run test only as non-admin user
    # Check if the test_user is admin and exit the BVT if the user is admin
    begin
      @client.users
      puts "Admin user can not run BVTs. Please try running as non-admin user"
      Cucumber.wants_to_quit = true
      # Make sure that RuntimeError 'Operation not permitted' is caught for the non-admin user
      # when running the vmc 'users' command
    rescue RuntimeError => e
    end
  end

  def cleanup
    unless ENV['parallel_tests'] == 'true'
      delete_app_internal(SIMPLE_APP)
      delete_app_internal(SIMPLE_APP2)
      delete_app_internal(SIMPLE_APP3)
      delete_app_internal(TINY_JAVA_APP)
      delete_app_internal(REDIS_LB_APP)
      delete_app_internal(ENV_TEST_APP)
      delete_app_internal(SIMPLE_DB_APP)
      delete_app_internal(BROKEN_APP)
      delete_app_internal(RAILS3_APP)
      delete_app_internal(JPA_APP)
      delete_app_internal(HIBERNATE_APP)
      delete_app_internal(DBRAILS_APP)
      delete_app_internal(DBRAILS_BROKEN_APP)
      delete_app_internal(GRAILS_APP)
      delete_app_internal(ROO_APP)
      delete_app_internal(SIMPLE_LIFT_APP)
      delete_app_internal(LIFT_DB_APP)
      delete_app_internal(TOMCAT_VERSION_CHECK_APP)
      delete_app_internal(NEO4J_APP)
      delete_app_internal(ATMOS_APP)
      delete_app_internal(SIMPLE_PYTHON_APP)
      delete_app_internal(PYTHON_APP_WITH_DEPENDENCIES)
      delete_app_internal(SIMPLE_DJANGO_APP)
      delete_app_internal(SIMPLE_PHP_APP)
      delete_app_internal(SPRING_ENV_APP)
      delete_app_internal(AUTO_RECONFIG_TEST_APP)
      delete_app_internal(AUTO_RECONFIG_MISSING_DEPS_TEST_APP)
      delete_app_internal(SIMPLE_KV_APP)
      delete_app_internal(BROKERED_SERVICE_APP)
      delete_app_internal(JAVA_APP_WITH_STARTUP_DELAY)
      delete_services(all_my_services) unless @registered_user or !get_login_token
      # This used to delete the entire user, but that now requires admin
      # privs so it was removed, as was the delete_user method.  See the
      # git history if it needs to be revived.
    end
  end

  def create_uri name
    "#{name}.#{@suggest_url}"
  end

  def create_user
    @registered_user || "#{@namespace}#{TEST_AUTOMATION_USER_ID}"
  end

  def create_passwd
    @registered_user_passwd || TEST_AUTOMATION_PASSWORD
  end

  alias :test_user :create_user
  alias :test_passwd :create_passwd

  def get_registered_user
    @last_registered_user
  end

  def register
    unless @registered_user
      @client.add_user(test_user, test_passwd)
    end
    @last_registered_user = test_user
  end

  def login
    token = @client.login(test_user, test_passwd)
    # TBD - ABS: This is a hack around the 1 sec granularity of our token time stamp
    sleep(1)
    @last_login_token = token
  end

  def get_login_token
    @last_login_token
  end

  def list_apps token
    @client.apps
  end

  def get_app_info app_list, app
    if app_list.empty?
      return
    end
    appname = get_app_name app
    app_list.each { |d|
      if d['name'] == appname
        return d
      end
    }
  end

  def create_app app, token, instances=1
    appname = get_app_name app
    delete_app app, token
    url = create_uri appname
    manifest = {
      :name => "#{appname}",
      :staging => {
        :model => @config[app]['framework'],
        :stack => @config[app]['startup']
      },
      :resources=> {
          :memory => @config[app]['memory'] || 64
      },
      :uris => [url],
      :instances => "#{instances}",
    }
    response = @client.create_app(appname, manifest)
    if response.first == 400
      puts "Creation of app #{appname} failed"
      return
    end
    app
  end

  def get_app_name app
    # URLs synthesized from app names containing '_' are not handled well by the Lift framework.
    # So we used '-' instead of '_'
    # '_' is not a valid character for hostname according to RFC 822,
    # use '-' to replace it.
    "#{@namespace}my-test-app-#{app}".gsub("_", "-")
  end

  def strip_app_name long_app
    # Strip compund CF app name of namespace and "my-test-app-"
    app_name = long_app.split("#{@namespace}my-test-app-")[1]
  end

  def upload_app app, token, rel_path=nil
    raise "Application #{appname} does not have a 'path' configuration" unless @config[app]['path']
    upload_app_help("#{@root_dir}/#{@config[app]['path']}", app)
  end

  def upload_app_help(app_dir, app)
    appname = get_app_name app

    upload_file, file = "#{Dir.tmpdir}/#{appname}.zip", nil
    FileUtils.rm_f(upload_file)

    explode_dir = "#{Dir.tmpdir}/.vmc_#{appname}_files"
    FileUtils.rm_rf(explode_dir) # Make sure we didn't have anything left over..
    Dir.chdir(app_dir) do
      if war_file = Dir.glob('*.war').first
        VMC::Cli::ZipUtil.unpack(war_file, explode_dir)
      else
        FileUtils.mkdir(explode_dir)
        files = Dir.glob('{*,.[^\.]*}')
        # Do not process .git files
        files.delete('.git') if files
        FileUtils.cp_r(files, explode_dir)
      end

      fingerprints = []
      total_size = 0
      resource_files = Dir.glob("#{explode_dir}/**/*", File::FNM_DOTMATCH)
      resource_files.each do |filename|
        next if (File.directory?(filename) || !File.exists?(filename))
        fingerprints << {
          :size => File.size(filename),
          :sha1 => Digest::SHA1.file(filename).hexdigest,
          :fn => filename
        }
        total_size += File.size(filename)
      end

      unless VMC::Cli::ZipUtil.get_files_to_pack(explode_dir).empty?
        VMC::Cli::ZipUtil.pack(explode_dir, upload_file)
        file = File.open(upload_file, 'rb')
      end
      @client.upload_app(appname , file)
    end
    ensure
      # Cleanup if we created an exploded directory.
      FileUtils.rm_f(upload_file) if upload_file
      FileUtils.rm_rf(explode_dir) if explode_dir
  end

  def update_app_help(app_dir, app)
    appname = get_app_name app
    manifest = {
      :name => "#{appname}",
      :staging => {
        :model => @config[app]['framework'],
        :stack => @config[app]['startup']
      }
    }
    @client.update_app(appname , manifest)
  end

  def get_app_status app, token
    appname = get_app_name app
    begin
      response = @client.app_info(appname)
    rescue
      nil
    end
  end

  def delete_app_internal app
    token = get_login_token
    if app != nil && token != nil
      delete_app app, token
    end
  end

  def delete_app app, token
    appname = get_app_name app
    begin
      response = @client.delete_app(appname)
    rescue
    end
    @app = nil
    response
  end

  def start_app app, token
    appname = get_app_name app
    app_manifest = get_app_status app, token
    if app_manifest == nil
     raise "Application #{appname} does not exist, app needs to be created."
    end

    if (app_manifest[:state] == 'STARTED')
      return
    end

    app_manifest[:state] = 'STARTED'
    #Enable console for Rails applications, as done in vmc
    if app_manifest[:staging][:model] == 'rails3'
      app_manifest[:console] = true
    end
    response = @client.update_app(appname, app_manifest)
    raise "Problem starting application #{appname}." if response.first != 200
  end

  def poll_until_done app, expected_health, token
    secs_til_timeout = @config['timeout_secs']
    health = nil
    sleep_time = @config['sleep_secs']
    while secs_til_timeout > 0 && health != expected_health
      sleep sleep_time
      secs_til_timeout = secs_til_timeout - sleep_time
      status = get_app_status app, token
      if (status)
        runningInstances = status[:runningInstances] || 0
        health = runningInstances/status[:instances].to_f
        # to mark? Not sure why this change, but breaks simple stop tests
        #health = runningInstances == 0 ? status['instances'].to_f : runningInstances.to_f
      end
    end
    health
  end

  def stop_app app, token
    appname = get_app_name app
    app_manifest = get_app_status app, token
    if app_manifest == nil
     raise "Application #{appname} does not exist."
    end

    if (app_manifest[:state] == 'STOPPED')
      return
    end

    app_manifest[:state] = 'STOPPED'
    @client.update_app(appname, app_manifest)
  end

  def restart_app app, token
    stop_app app, token
    start_app app, token
  end

  def get_app_files app, instance, path, token
    appname = get_app_name app
    @client.app_files(appname, path, instance)
  end

  def get_instances_info app, token
    appname = get_app_name app
    instances_info = @client.app_instances(appname)
    instances_info
  end

  def set_app_instances app, new_instance_count, token
    appname = get_app_name app
    app_manifest = get_app_status app, token
    if app_manifest == nil
      raise "App #{appname} needs to be deployed on AppCloud before being able to increment its instance count"
    end

    instances = app_manifest[:instances]
    health = app_manifest[:health]
    if (instances == new_instance_count)
      return
    end
    app_manifest[:instances] = new_instance_count


    response = @client.update_app(appname, app_manifest)
    raise "Problem setting instance count for application #{appname}." if response.first != 200
    expected_health = 1.0
    poll_until_done app, expected_health, token
    new_instance_count
  end

  def get_app_crashes app, token
    # FIXME: this is a temporary hack.  What really should happen here
    # is that we should poll to make sure the crash logs have been
    # generated, and limit the polling to 2s.
    #
    # Wait for the DEA to save the crash logs.  On a dev/prod instance
    # this happens very quickly, but on a loaded dev laptop, the test
    # is able to proceed faster than the DEA can save the logs
    sleep 0.5
    appname = get_app_name app
    response = @client.app_crashes(appname)

    crash_info = response if response
  end

  def get_app_stats app, token
    appname = get_app_name app
    response = @client.app_stats(appname)
    response.first if response
  end

  def add_app_uri app, uri, token
    appname = get_app_name app
    app_manifest = get_app_status app, token
    if app_manifest == nil
     raise "Application #{appname} does not exist, app needs to be created."
    end

    app_manifest[:uris] << uri
    response = @client.update_app(appname, app_manifest)
    raise "Problem adding uri #{uri} to application #{appname}." if response.first!= 200
    expected_health = 1.0
    poll_until_done app, expected_health, token
  end

  def remove_app_uri app, uri, token
    appname = get_app_name app
    app_manifest = get_app_status app, token
    if app_manifest == nil
     raise "Application #{appname} does not exist, app needs to be created."
    end

    if app_manifest[:uris].delete(uri) == nil
      raise "Application #{appname} is not associated with #{uri} to be removed"
    end
    response = @client.update_app(appname, app_manifest)
    raise "Problem removing uri #{uri} from application #{appname}." if response.first != 200
    expected_health = 1.0
    poll_until_done app, expected_health, token
  end

  def modify_and_upload_app app,token
    upload_app_help("#{@testapps_dir}/sinatra/modified_#{app}", app)
    restart_app app, token
  end

  def modify_and_upload_bad_app app,token
    upload_app_help("#{@testapps_dir}/sinatra/#{BROKEN_APP}", app)
  end

  def poll_until_update_app_done app, token
    appname = get_app_name app
    @client.app_update_info(appname)
    update_state = nil
    secs_til_timeout = @config['timeout_secs']
    while secs_til_timeout > 0 && update_state != 'SUCCEEDED' && update_state != 'CANARY_FAILED'
      sleep 1
      secs_til_timeout = secs_til_timeout - 1
      response = @client.app_update_info(appname)
      update_state = response[:state]
    end
    update_state
  end

  def all_my_services
    @client.services.map{ |service| service[:name] }
  end

  def get_services token
    @client.services_info
  end

  def services_list(opts={})
    refresh = opts[:refresh]
    return @services_list if !refresh and @services_list

    # flatten
    @services_list = []

    services = get_services @token
    services.each do |service_type, value|
      value.each do |k,v|
        # k is really the vendor
        v.each do |version, s|
          @services_list << s
        end
      end
    end

    return @services_list
  end

  def find_service vendor
    services_list.find { |s| s[:vendor].downcase == vendor }
  end

  def get_frameworks token
    response = HTTPClient.get "#{@base_uri}/info", nil, auth_hdr(token)
    frameworks = JSON.parse(response.content)
    frameworks['frameworks']
  end

  def pending_unless_framework_exists(token, framework)
    unless get_frameworks(token).include?(framework)
      pending "Not running #{framework} based test because #{framework} is not available in this Cloud Foundry instance."
    end
  end

   def provision_rabbitmq_srs_service token
     name = "#{@namespace}#{@app || 'simple_rabbitmq_srs_app'}rabbitmq_srs"
     @client.create_service('rabbitmq-srs', name)
     service_manifest = {
       :type=>"generic",
       :vendor=>"rabbitmq-srs",
       :tier=>"free",
       :version=>"2.4.1",
       :name=>name,
       :options=>{"size"=>"256MiB"}}
     #puts "Provisioned service #{service_manifest}"
     service_manifest
   end

   def provision_rabbitmq_service token
     name = "#{@namespace}#{@app || 'simple_rabbitmq_app'}rabbitmq"
     @client.create_service(:rabbitmq, name)
     service_manifest = {
       :type=>"generic",
       :vendor=>"rabbitmq",
       :tier=>"free",
       :version=>"2.4",
       :name=>name,
       :options=>{"size"=>"256MiB"}}
     #puts "Provisioned service #{service_manifest}"
     service_manifest
   end

   def provision_mongodb_service token
     name = "#{@namespace}#{@app || 'simple_mongodb_app'}mongodb"
     @client.create_service(:mongodb, name)
     service_manifest = {
       :type=>"key-value",
       :vendor=>"mongodb",
       :tier=>"free",
       :version=>"1.8",
       :name=>name,
       :options=>{"size"=>"256MiB"}}
       #puts "Provisioned service #{service_manifest}"
       service_manifest
     end

  def provision_neo4j_service token
    name = "#{@namespace}#{@app || 'simple_neo4j_app'}neo4j"
    @client.create_service(:neo4j, name)
    service_manifest = {
     :vendor=>"neo4j",
     :tier=>"free",
     :version=>"1.4",
     :name=>name
    }
  end

  def provision_atmos_service token
    name = "#{@namespace}#{@app || 'simple_atmos_app'}atmos"
    @client.create_service(:atmos, name)
    service_manifest = {
     :vendor=>"atmos",
     :tier=>"free",
     :version=>"1.4.1",
     :name=>name
    }
  end

  def provision_brokered_service token
    name = "#{@namespace}#{@app || 'brokered_service_app'}_#{@brokered_service_name}"
    @client.create_service(@brokered_service_name.to_sym, name)
    service_manifest = {
     :vendor=>"brokered_service",
     :tier=>"free",
     :version=>"1.0",
     :name=>name
    }
  end

  def provision_postgresql_service
    name = "#{@namespace}#{@app || 'simple_db_app'}postgresql"
    @client.create_service(:postgresql, name)
    service_manifest = {
      :type=>"database",
      :vendor=>"postgresql",
      :tier=>"free",
      :version=>"9.0",
      :name=>name,
      :options=>{"size"=>"256MiB"},
    }
  end

  def provision_db_service token
    name = "#{@namespace}#{@app || 'simple_db_app'}mysql"
    @client.create_service(:mysql, name)
    service_manifest = {
      :type=>"database",
      :vendor=>"mysql",
      :tier=>"free",
      :version=>"5.1.45",
      :name=>name,
      :options=>{"size"=>"256MiB"},
    }
  end

  def provision_redis_service token
    name = "#{@namespace}#{@app}redis"
    @client.create_service(:redis, name)
    {
        :type=>"key-value",
        :vendor=>"redis",
        :tier=>"free",
        :version=>"5.1.45",
        :name=>name,
    }
  end

  def postgresql_name name
    "#{@namespace}postgresql_#{name}"
  end

  def provision_postgresql_service_named token, name
    service_manifest = {
     :type=>"database",
     :vendor=>"postgresql",
     :tier=>"free",
     :version=>"8.4",
     :name=>postgresql_name(name),
    }
    @client.create_service(:postgresql, service_manifest[:name])
    #puts "Provisioned service #{service_manifest}"
    service_manifest
  end

  def provision_redis_service_named token, name
    r_name = redis_name(name)
    @client.create_service(:redis, r_name)
    { :type=>"key-value", :vendor=>"redis", :tier=>"free", :version=>"5.1.45", :name=> r_name }
  end

  def redis_name name
    "#{@namespace}redis_#{name}"
  end

  def aurora_name name
    "#{@namespace}aurora_#{name}"
  end


  def mozyatmos_name name
    "#{@namespace}mozyatmos_#{name}"
  end

  def provision_aurora_service_named token, name
    service_manifest = {
     :type=>"database",
     :vendor=>"aurora",
     :tier=>"std",
     :name=>aurora_name(name),
    }
    @client.create_service(:aurora, aurora_name(name))
    #puts "Provisioned service #{service_manifest}"
    service_manifest
  end

  def provision_mozyatmos_service_named token, name
    service_manifest = {
     :type=>"blob",
     :vendor=>"mozyatmos",
     :tier=>"std",
     :name=>mozyatmos_name(name),
    }
    @client.create_service(:mozyatoms, mozyatmos_name(name))
    #puts "Provisioned service #{service_manifest}"
    service_manifest
  end


  def attach_provisioned_service app, service_manifest, token
    appname = get_app_name app
    app_manifest = get_app_status app, token
    provisioned_service = app_manifest[:services]
    provisioned_service = [] unless provisioned_service
    svc_name = service_manifest[:name]
    provisioned_service << svc_name
    app_manifest[:services] = provisioned_service
    @client.update_app(appname, app_manifest)
  end

  def delete_services services
    services.each do |service|
      delete_service service
    end
  end

  def delete_service service
    begin
      @client.delete_service(service)
    rescue
      nil
    end
  end

  def get_uri app, relative_path=nil
    appname = get_app_name app
    uri = "#{appname}.#{@suggest_url}"
    if relative_path != nil
      uri << "/#{relative_path}"
    end
    uri
  end

  def environment_add app, k, v=nil
    appname = get_app_name app
    app = @client.app_info(appname)
    env = app[:env] || []
    k,v = k.split('=', 2) unless v
    env << "#{k}=#{v}"
    app[:env] = env
    @client.update_app(appname, app)
  end

  def get_app_contents app, relative_path=nil
    uri = get_uri app, relative_path
    get_uri_contents uri
  end

  def get_uri_contents uri, timeout=0
    easy = Curl::Easy.new
    easy.url = uri
    if timeout != 0
      easy.timeout = timeout
    end
    easy.resolve_mode =:ipv4
    easy.http_get
    easy
  end

  def post_to_app app, relative_path, data
    uri = get_uri app, relative_path
    post_uri uri, data
  end

  def post_uri uri, data
    easy = Curl::Easy.new
    easy.url = uri
    easy.resolve_mode =:ipv4
    easy.http_post(data)
    easy
  end

  def post_record_no_close uri, data_hash
    easy = Curl::Easy.new
    easy.url = uri
    easy.resolve_mode =:ipv4
    easy.http_post(data_hash.to_json)
    easy
  end

  def post_record uri, data_hash
    easy = post_record_no_close(uri,data_hash)
    easy.close
  end

  def put_to_app app, relative_path, data
    uri = get_uri app, relative_path
    put_uri uri, data
  end

  def put_uri uri, data
    easy = Curl::Easy.new
    easy.url = uri
    easy.resolve_mode =:ipv4
    easy.http_put(data)
    easy
  end

  def put_record uri, data_hash
    easy = Curl::Easy.new
    easy.url = uri
    easy.resolve_mode =:ipv4
    easy.http_put(data_hash.to_json)
    easy.close
  end

  def delete_from_app app, relative_path
    uri = get_uri app, relative_path
    delete_record uri
  end

  def delete_record uri
    easy = Curl::Easy.new
    easy.resolve_mode =:ipv4
    easy.url = uri
    easy.http_delete
    easy.close
  end

  def parse_json payload
    JSON.parse(payload)
  end

  def auth_hdr token
    {'AUTHORIZATION' => "#{token}"}
  end

  def get_expected_tomcat_version
    @config[@app]['tomcat_version']
  end

end
