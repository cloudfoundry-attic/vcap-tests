#
# The test automation based on Cucumber uses the steps defined and implemented here to
# facilitate the handling of the various scenarios that make up the feature set of
# AppCloud.
#
# Author:: A.B.Srinivasan
# Copyright:: Copyright (c) 2010 VMware Inc.

#World(AppCloudHelper)

require 'nokogiri'

World do
  AppCloudHelper.instance
end

## User management

# Register
Given /^I am a new user to AppCloud$/ do
  pending "new user registration is temporarily disabled in the bvts"
  AppCloudHelper.instance.create_user
end

When /^I register$/ do
  @user = AppCloudHelper.instance.register
end

Then /^I should be able to login to AppCloud\.$/ do
  @user.should_not == nil
  AppCloudHelper.instance.login
end

# Login
Given /^I am registered$/ do
  user = AppCloudHelper.instance.get_registered_user
  if (user == nil)
    user = AppCloudHelper.instance.create_user
    AppCloudHelper.instance.register
  end
  user.should_not == nil
end

When /^I login$/ do
  @token = AppCloudHelper.instance.login
end

Then /^I should get an authentication token that I need to use with all subsequent AppCloud requests$/ do
  @token.should_not == nil
end

# Re-login
Given /^I have logged in$/ do

  user = AppCloudHelper.instance.get_registered_user
  if (user == nil)
    user = AppCloudHelper.instance.create_user
    AppCloudHelper.instance.register
  end
  user.should_not == nil

  @first_login_token = AppCloudHelper.instance.get_login_token
  @first_login_token.should_not == nil
end

Then /^I should get a new authentication token that I need to use for all subsequent AppCloud requests$/ do
  @token.should_not == nil
  @token.should_not == @first_login_token
end

## Application CRUD operations

Given /^I have registered and logged in$/ do
  user = AppCloudHelper.instance.get_registered_user
  if user == nil
    user = AppCloudHelper.instance.create_user
    AppCloudHelper.instance.register
  end
  user.should_not == nil

  @token = AppCloudHelper.instance.get_login_token
  if @token == nil
    @token = AppCloudHelper.instance.login
  end
  @token.should_not == nil
end

# Create
When /^I create a simple application$/ do
  @app = create_app SIMPLE_APP3, @token
end

Then /^I should have my application on AppCloud$/ do
  @app.should_not == nil
end

Then /^it should not be started$/ do
  status = get_app_status @app, @token
  status.should_not == nil
  status['state'].should_not == 'STARTED'
end

# Read (Query status)
Given /^I have my simple application on AppCloud$/ do
  @app = create_app SIMPLE_APP3, @token
end

When /^I query status of my application$/ do
  @status = get_app_status @app, @token
end

Then /^I should get the state of my application$/ do
  @status.should_not == nil
end

# Delete
When /^I delete my application$/ do
  delete_app @app, @token
end

Then /^it should not be on AppCloud$/ do
  status = get_app_status @app, @token
  status.should == nil
end

# Upload
When /^I upload my application$/ do
  upload_app @app, @token
end

## Application availability control
# Start
When /^I start my application$/ do
  start_app @app, @token
end

Then /^it should be started$/ do
  status = get_app_status @app, @token
  status.should_not == nil
  status[:state].should == 'STARTED'
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

Then /^it should be available for use$/ do
  contents = get_app_contents @app
  contents.should_not == nil
  contents.body_str.should_not == nil
  contents.body_str.should =~ /Hello from VCAP/
  contents.close
end

# Stop
When /^I stop my application$/ do
  stop_app @app, @token
end

Then /^it should be stopped$/ do
  status = get_app_status @app, @token
  status.should_not == nil
  status[:state].should == 'STOPPED'
  expected_health = 0.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

Then /^it should not be available for use$/ do
  contents = get_app_contents @app
  contents.should_not == nil
  contents.response_code.should == 404
  contents.close
end

Given /^I have deleted all deployed applications$/ do
  AppCloudHelper.instance.cleanup
end

Given /^I have deployed my application named (\w+)$/ do |app_name|
  @app = create_app app_name, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

# List apps
Given /^I have deployed a simple application$/ do
  @app = create_app SIMPLE_APP, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

# List apps
Given /^I have deployed another simple application$/ do
  @app = create_app SIMPLE_APP3, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

# List apps
Given /^I have deployed a new simple application$/ do
  @app = create_app SIMPLE_APP2, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

Given /^I have built a simple Erlang application$/ do
  # Try to find an appropriate Erlang
  erlang_ready = true

  # figure out if cloud has erlang runtime
  runtimes = @client.info().to_a().join()
  if (runtimes =~ /erlang/)
    puts "target cloud has Erlang runtime"
  else
    puts "target cloud does not support Erlang"
    erlang_ready = false
  end

  # figure out if BVT environment has Erlang installed
  begin
    installed_erlang = `erl -version`
  rescue
  end
  if $? != 0
    puts "BVT environment does not have Erlang installed. Please install manually."
    erlang_ready = false
  else
    puts "BVT environment has Erlang runtime installed"
  end

  if !erlang_ready
    pending "Not running Erlang test because the Erlang runtime is not installed"
  else
    Dir.chdir("#{@testapps_dir}/mochiweb/#{SIMPLE_ERLANG_APP}")
    rel_build_result = `make relclean rel`
    raise "Erlang application build failed: #{rel_build_result}" if $? != 0
  end
end

Given /^I have deployed a simple Erlang application$/ do
  @app = create_app SIMPLE_ERLANG_APP, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

Given /^I have deployed a simple PHP application$/ do
  pending_unless_framework_exists(@token, "php")
  @app = create_app SIMPLE_PHP_APP, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

Given /^I have deployed a simple Python application$/ do
  pending_unless_framework_exists(@token, "wsgi")
  @app = create_app SIMPLE_PYTHON_APP, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

Given /^I have deployed a Django application$/ do
  pending_unless_framework_exists(@token, "django")
  @app = create_app SIMPLE_DJANGO_APP, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

Given /^I have deployed a Python application with a dependency$/ do
  pending_unless_framework_exists(@token, "wsgi")
  @app = create_app PYTHON_APP_WITH_DEPENDENCIES, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

Given /^I have deployed a tiny Java application$/ do
  @java_app = create_app TINY_JAVA_APP, @token
  upload_app @java_app, @token
  start_app @java_app, @token
  expected_health = 1.0
  health = poll_until_done @java_app, expected_health, @token
  health.should == expected_health
end

When /^I list my applications$/ do
  @app_list = list_apps @token
  @app_list.should_not == nil
end

Then /^I should get status on the simple app as well as the tiny Java application$/ do
  simple_app = get_app_info @app_list, @app
  tiny_java_app = get_app_info @app_list, @java_app
  simple_app.should_not == nil
  tiny_java_app.should_not == nil
end

# Get app files
When /^I list files associated with my application$/ do
  @instance = '0'
  path = '/'
  @response = get_app_files @app, @instance, path, @token
end

Then /^I should get a list of directories and files associated with my application on AppCloud$/ do
# new vmc client no longer returns the response status it just returns the body
#   @response.status.should == 200
  @response.should_not == nil
end

Then /^I should be able to retrieve any of the listed files$/ do
  @instance = '0'
  path = '/app'
  response = get_app_files @app, @instance, path, @token
# new vmc client no longer returns the response status it just returns the body
#   @response.status.should == 200
  response.should_not == nil
end

# Get instances info
Given /^I have (\d+) instances of a simple application$/ do |arg1|
  @instances = set_app_instances @app, arg1.to_i, @token
end

When /^I get instance information for my application$/ do
  @instances_info = get_instances_info @app, @token
end

Then /^I should get status on all instances of my application$/ do
  @instances_info.should_not == nil
  @instances_info[:instances].length.should == @instances
end

# Get crash info
Given /^I that my application has a crash$/ do
  @instance = '0'
  path = '/run.pid'
  response = get_app_files @app, @instance, path, @token
# new vmc client no longer returns the response status it just returns the body
#   @response.status.should == 200
  response.should_not == nil
  pid = response.chomp
  # This call causes the app to crash
  begin
    contents = get_app_contents @app, "crash/#{pid}"
    contents.close
  rescue
  end
end

When /^I get crash information for my application$/ do
  @crash_info = get_app_crashes @app, @token
end

Then /^I should be able to get the time of the crash from that information$/ do
  @crash_info.should_not == nil
  Time.at(@crash_info[:crashes][0][:since]).should_not == nil
end

Then /^I should be able to get a list of files associated with my application on AppCloud$/ do
  @instance = '0'
  path = '/'
  @response = get_app_files @app, @instance, path, @token
# new vmc client no longer returns the response status it just returns the body
#   @response.status.should == 200
  @response.should_not == nil
end

# Crash info for a broken (persistently broken) app
Given /^I have deployed a broken application$/ do
  @app = create_app BROKEN_APP, @token
  upload_app @app, @token
  start_app @app, @token
  sleep 3
end

# Resource use
When /^I get resource usage for my application$/ do
  @app_stats = get_app_stats @app, @token
end

Then /^I should get information representing my application\'s resource use\.$/ do
  @app_stats.should_not == nil
  stats = @app_stats[:stats]
  stats.should_not == nil
  appname = get_app_name @app
  stats[:name].should == appname

  timeout = 6 # Because monitor sweeps are 5 secs..
  sleep_time = 0.5

  while stats[:usage] == nil && timeout > 0
    sleep sleep_time
    timeout -= sleep_time
    @app_stats = get_app_stats @app, @token
    stats = @app_stats[:stats]
  end

  stats[:usage].should_not == nil
end

# Update app instance count
When /^I increase the instance count of my application by (\d+)$/ do |arg1|
  instances_info = get_instances_info @app, @token
  instances_info.should_not == nil
  set_app_instances @app, instances_info[:instances].length + arg1.to_i, @token
end

Then /^I should have (\d+) instances of my application$/ do |arg1|
  instances_info = get_instances_info @app, @token
  instances_info.should_not == nil
  instances_info[:instances].length.should == arg1.to_i
end

When /^I decrease the instance count of my application by (\d+)$/ do |arg1|
  instances_info = get_instances_info @app, @token
  instances_info.should_not == nil
  set_app_instances @app, instances_info[:instances].length - arg1.to_i, @token
end

# Map & unmap application URIs
When /^I add a url to my application$/ do
  app_info = get_app_status @app, @token
  app_info.should_not == nil
  uris = app_info[:uris]
  @original_uri = uris[0]
  appname = get_app_name @app
  @new_uri = create_uri "#{appname}-1"
  add_app_uri @app, @new_uri, @token
end

# Map & unmap application URIs
When /^I add a url that differs only by case$/ do
  # While odd, this is allowed for a single user.  It should fail
  # for similar urls, both in terms of the same case and mixed
  # case across users.  These tests aren't setup for
  # cross user testing at the moment.  For a single user we might
  # merge these urls on the backend, but we don't for the moment,
  # hence the 'pending' status below.
  pending "the expected behavior of this test is under discussion"
  app_info = get_app_status @app, @token
  app_info.should_not == nil
  uris = app_info[:uris]
  uris.length.should == 1
  @original_uri = uris[0]
  appname = get_app_name @app
  @new_uri = create_uri "#{appname.swapcase}"
  @new_uri.should_not == @original_uri
  add_app_uri @app, @new_uri, @token
end

Then /^I should have (\d+) urls associated with my application$/ do |arg1|
  app_info = get_app_status @app, @token
  app_info.should_not == nil
  uris = app_info[:uris]
  uris.length.should == arg1.to_i
end

Then /^I should be able to access the application through the original url\.$/ do
  contents = get_uri_contents @original_uri
  contents.should_not == nil
  contents.body_str.should_not == nil
  contents.body_str.should =~ /Hello from VCAP/
  contents.close
end

Then /^I should be able to access the application through the new url\.$/ do
  # Time dependent, so sleep for a small amount.
  sleep 0.25

  contents = get_uri_contents @new_uri
  contents.should_not == nil
  contents.body_str.should_not == nil
  contents.body_str.should =~ /Hello from VCAP/
  contents.close
end

Given /^I have my application associated with '(\d+)' urls$/ do |arg1|
  app_info = get_app_status @app, @token
  app_info.should_not == nil
  uris = app_info[:uris]
  @remaining_uri = uris[0]
  appname = get_app_name @app
  @uri_to_be_removed = appname << "-1"
  @uri_to_be_removed = create_uri @uri_to_be_removed
  add_app_uri @app, @uri_to_be_removed, @token
end

When /^I remove one of the urls associated with my application$/ do
  remove_app_uri @app, @uri_to_be_removed, @token
end

Then /^I should be able to access the application through the remaining url\.$/ do
  contents = get_uri_contents @remaining_uri
  contents.should_not == nil
  contents.body_str.should_not == nil
  contents.body_str.should =~ /Hello from VCAP/
  contents.close
end

Then /^I should be not be able to access the application through the removed url\.$/ do
  # Time dependent, so sleep for a small amount.
  sleep 0.25

  contents = get_uri_contents @uri_to_be_removed
  contents.should_not == nil
  contents.response_code.should == 404
  contents.close
end

When /^I remove the original url associated with my application$/ do
  remove_app_uri @app, @original_uri, @token
end

Then /^I should be not be able to access the application through the original url\.$/ do
  contents = get_uri_contents @original_uri
  contents.should_not == nil
  contents.response_code.should == 404
  contents.close
end

# Modify application contents
When /^I upload a modified simple application to AppCloud$/ do
  modify_and_upload_app @app, @token
end

When /^I update my application on AppCloud$/ do
  @response = poll_until_update_app_done @app, @token
end

Then /^my update should succeed$/ do
  @response.should == 'SUCCEEDED'
end


Then /^I post (\w+) to (\w+) service with key (\w+)$/ do |body, service, key|
  if @service
    contents = post_to_app @app, "service/#{service}/#{key}", body
    contents.response_code.should == 200
    contents.close

    # Time dependency
    # Some app's post is async. Sleep to ensure the operation is done.
    sleep 0.1
  end
end

Then /^I should be able to get from (\w+) service with key (\w+), and I should see (\w+)$/ do |service, key, value|
  if @service
    contents = get_app_contents @app, "service/#{service}/#{key}"
    contents.should_not == nil
    contents.body_str.should_not == nil
    contents.response_code.should == 200
    contents.body_str.should == value
    contents.close
  end
end

Then /^I put (\w+) to (\w+) service with key (\w+)$/ do |body, service, key|
  if @service
    contents = put_to_app @app, "service/#{service}/#{key}", body
    contents.response_code.should == 200
    contents.close
  end
end

Then /^I delete from (\w+) service with key (\w+)$/ do |service, key|
  if @service
    delete_from_app @app, "service/#{service}/#{key}"
  end
end

Then /^I should not be able to get from (\w+) service with key (\w+)$/ do |service, key|
  if @service
    contents = get_app_contents @app, "service/#{service}/#{key}"
    contents.response_code.should_not == 200
    contents.close
  end
end

Then /^I should be able to access the updated version of my application$/ do
  contents = get_app_contents @app
  contents.should_not == nil
  contents.body_str.should_not == nil
  contents.body_str.should =~ /Hello from modified VCAP/
  contents.close
end

Then /^I delete all my service$/ do
  delete_services(all_my_services)
end

Then /^I should be able to access crash and it should crash$/ do
  contents = get_app_contents @app, 'crash'
  contents.should_not == nil
  contents.response_code.should >= 500
  contents.response_code.should < 600
  contents.close
end

Then /^I should be able to access my application root and see hello from (\w+)$/ do |framework|
  contents = get_app_contents @app
  contents.should_not == nil
  contents.body_str.should_not == nil
  contents.body_str.should == "hello from #{framework}"
  contents.close
end

Then /^I should be able to access my application root and see it's running version (.+)$/ do |version|
  contents = get_app_contents @app
  contents.should_not == nil
  contents.body_str.should_not == nil
  contents.body_str.should == "running version #{version}"
  contents.close
end

Then /^I should be able to access the original version of my application$/ do
  pending
  contents = get_app_contents @app
  contents.should_not == nil
  contents.body_str.should_not == nil
  contents.body_str.should =~ /Hello from VCAP/
  contents.close
end

Then /^I delete my service$/ do
  if @service
    s = delete_service @service[:name]
  end
  @service_id = nil
end

When /^I provision ([\w\-]+) service$/ do |requested_service|
  @service = nil
  if find_service requested_service
    @service = case requested_service
               when "mysql" then provision_db_service @token
               when "redis" then provision_redis_service @token
               when "mongodb" then provision_mongodb_service @token
               when "rabbitmq" then provision_rabbitmq_service @token
               when "postgresql" then provision_postgresql_service
               when "rabbitmq-srs" then provision_rabbitmq_srs_service @token
               end

    attach_provisioned_service @app, @service, @token
    upload_app @app, @token
    stop_app @app, @token
    start_app @app, @token
    expected_health = 1.0
    health = poll_until_done @app, expected_health, @token
    health.should == expected_health
  end
end

# Simple Sinatra CRUD application that uses MySQL
Given /^I deploy my simple application that is backed by the MySql database service on AppCloud$/ do
  @app = create_app SIMPLE_DB_APP, @token
  @service = provision_db_service @token
  attach_provisioned_service @app, @service, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

When /^I add a record to my application$/ do
  @desc = "Description"
  @id = "tester1"
  data_hash = { :id => @id, :desc => @desc}
  uri = get_uri @app, "users"
  post_record uri, data_hash
end

Then /^I should be able to retrieve the record that was added$/ do
  user_id = @id
  uri = get_uri @app, "users/#{user_id}"
  contents = get_uri_contents uri
  contents.should_not == nil
  user_hash = parse_json contents.body_str
  user_hash['id'].should == user_id
  user_hash['desc'].should == @desc
  contents.close
end

Then /^be able to update the record$/ do
  updated_desc = "Updated description"
  data_hash = { :id => @id, :desc => updated_desc}
  uri = get_uri @app, "users/#{@id}"
  put_record uri, data_hash

  uri = get_uri @app, "users/#{@id}"
  contents = get_uri_contents uri
  contents.should_not == nil
  user_hash = parse_json contents.body_str
  user_hash['id'].should == @id
  user_hash['desc'].should == updated_desc
  contents.close
end

Then /^be able to delete the record$/ do
  uri = get_uri @app, "users/#{@id}"
  contents = get_uri_contents uri
  contents.should_not == nil
  contents.close
  delete_record uri
  contents = get_uri_contents uri
  contents.should_not == nil
  contents.response_code.should == 404
  contents.close
end

# Hiberate application that uses PostgreSQL
Given /^I deploy a hibernate application that is backed by the PostgreSQL database service on AppCloud$/ do
  # find postgresql service in the list
  postgresql_service = find_service "postgresql"

  if postgresql_service
    @app = create_app HIBERNATE_APP, @token
    @service = provision_postgresql_service_named @token, "mydb"
    attach_provisioned_service @app, @service, @token
    upload_app @app, @token
    start_app @app, @token
    expected_health = 1.0
    health = poll_until_done @app, expected_health, @token
    health.should == expected_health
  else
    pending "Not running Postgresql test because Postgresql service is not available"
  end
end

When /^I add one entry in the Guestbook$/ do
  uri = get_uri @app, "guest.html"

  easy = Curl::Easy.new
  easy.url = uri
  easy.resolve_mode =:ipv4
  easy.http_post("name=guest")
  easy.close
end

Then /^I should be able to retrieve entries from Guestbook$/ do
  uri = get_uri @app

  easy = Curl::Easy.new
  easy.url = uri
  easy.resolve_mode =:ipv4
  easy.http_get
  doc = Nokogiri::HTML(easy.body_str)
  number = doc.xpath('//p').count
  easy.close

  number.should >= 1
end

Given /^I have my running application named (\w+)$/ do |app_name|
  status = get_app_status app_name, @token
  status.should_not == nil
  if status
    @app = app_name
  end
end

Then /^I should get on application (\w+) the persisted data from (\w+) service with key (\w+), and I should see (\w+)$/ do |app_name, service, key, value|
  app_manifest = get_app_status app_name, @token
  app_manifest.should_not == nil
  @app.should == app_name
  provisioned_services = app_manifest[:services]
  provisioned_services.should_not == nil
  long_app_name = get_app_name app_name
  long_service_name = "#{@namespace}#{@app}#{service}"
  if provisioned_services.include?("#{long_service_name}")
    contents = get_app_contents @app, "service/#{service}/#{key}"
    contents.should_not == nil
    contents.body_str.should_not == nil
    contents.response_code.should == 200
    contents.body_str.should == value
    contents.close
  end
end

Then /^I delete all services and apps$/ do
  @app_list.each do |item|
    app = strip_app_name item[:name]
    services = item[:services]
    if services.length.to_i > 0
      services.each do |s|
        delete_service(s)
      end
    end
    delete_app_internal app
  end
end

Then /^I should be able to immediately access the Java application through its url$/ do
  uri = get_uri @app
  contents = get_uri_contents uri, 20
  contents.should_not == nil
  contents.body_str.should_not == nil
  contents.body_str.should =~ /I am up and running/
  contents.close
end
