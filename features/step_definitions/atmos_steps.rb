Given /^I have provisioned an atmos service$/ do
  pending unless find_service 'atmos'
  @atmos_service = provision_atmos_service @token
  @atmos_service.should_not == nil
end

Given /^I have deployed an atmos application that is bound to this service$/ do
  @app = create_app ATMOS_APP, @token
  attach_provisioned_service @app, @atmos_service, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

When /^I create an object in backend atmos through my application$/ do
  uri = get_uri(@app, 'object')
  r = post_uri(uri, 'abc')
  r.response_code.should == 200
  r.close
end

Then /^I should be able to get the object$/ do
  uri = get_uri @app, "object"
  r = get_uri_contents uri
  r.should_not == nil
  r.response_code.should == 200
  r.body_str.should == 'abc'
  r.close
end

After("@creates_atmos_app") do |scenario|
  delete_app @app, @token if @app
end

After("@creates_atmos_service") do |scenario|
  delete_service @atmos_service[:name] if @atmos_service
end
