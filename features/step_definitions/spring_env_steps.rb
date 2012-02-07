require 'rest_client'

Given /^I have deployed a Spring 3.1 application$/ do
  @app = create_app SPRING_ENV_APP, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

When /^I bind a (\S+) service named (\S+) to the Spring 3.1 application$/ do |type, name|
  service = eval("provision_#{type}_service_named @token, name")
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

Then /^the cloud application properties should be correct$/ do
  app_name = http_get_body "properties/sources/property/cloud.application.name"
  app_name.should == get_app_name(@app)
  provider_url = http_get_body "properties/sources/property/cloud.provider.url"
  provider_url.should == @target
end

Then /^the cloud service properties should be correct for a (\S+) service named (\S+)$/ do |service_type, service_name|
  # adjust service name to add test prefix
  service_name =  eval("#{service_type}_name service_name")
  type = http_get_body "properties/sources/property/cloud.services.#{service_name}.type"
  type.should satisfy {|arg| arg.start_with? service_type}
  plan = http_get_body "properties/sources/property/cloud.services.#{service_name}.plan"
  plan.should == 'free'
  password = http_get_body "properties/sources/property/cloud.services.#{service_name}.connection.password"
  aliased_password = http_get_body "properties/sources/property/cloud.services.#{service_type}.connection.password"
  aliased_password.should == password
end

def http_get_body path
  uri = get_uri @app, path
  response = RestClient.get uri, :accept => 'application/json'
  response.should_not == nil
  response.code.should == 200
  response.body
end
