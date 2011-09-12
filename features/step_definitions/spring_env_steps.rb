require 'rest_client'

Given /^I have deployed a Spring 3.1 application$/ do
  @app = create_app SPRING_ENV_APP, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

When /^I bind a Redis service named (\S+) to the Spring 3.1 application$/ do |name|
  service = provision_redis_service_named @token, name
  stop_app @app, @token
  attach_provisioned_service @app, service, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

Then /^the (\S+) profile should be active$/ do |profile|
  response = http_get_body "profiles/active/#{profile}"
  response.should == 'true'
end

Then /^the (\S+) profile should not be active$/ do |profile|
  response = http_get_body "profiles/active/#{profile}"
  response.should == 'false'
end

Then /^the (\S+) property source should exist$/ do |source|
  response = http_get_body "properties/sources/source/#{source}"
  response.length.should_not == 0
end

Then /^the (\S+) property should be (\S+)$/ do |name, value|
  response = http_get_body "properties/sources/property/#{name}"
  response.should == value
end

Then /^the (\S+) property should be the app name$/ do |name|
  response = http_get_body "properties/sources/property/#{name}"
  response.should == get_app_name(@app)
end

Then /^the (\S+) property should be the cloud provider url$/ do |name|
  response = http_get_body "properties/sources/property/#{name}"
  response.should == @target
end

Then /^the (\S+) and (\S+) properties should have the same value$/ do |prop1, prop2|
  response1 = http_get_body "properties/sources/property/#{prop1}"
  response2 = http_get_body "properties/sources/property/#{prop2}"
  response1.should == response2
end

def http_get_body path
  uri = get_uri @app, path
  response = RestClient.get uri, :accept => 'application/json'
  response.should_not == nil
  response.code.should == 200
  response.body
end

After("@creates_spring_env_app") do |scenario|
  delete_app_services
end
