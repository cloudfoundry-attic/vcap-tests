Given /^I have provisioned an blob service$/ do
  pending unless find_service 'blob'
  @blob_service = provision_blob_service @token
  @blob_service.should_not == nil
end

Given /^I have deployed an blob application that is bound to this service$/ do
  @app = create_app BLOB_APP, @token
  attach_provisioned_service @app, @blob_service, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

Given /^I create a bucket in backend blob through my application$/ do
  uri = get_uri(@app, 'bucket1')
  r = post_uri(uri,'dummy')
  r.response_code.should == 200
  r.close
end

When /^I create an object in backend blob through my application$/ do
  uri = get_uri(@app, 'bucket1/object1')
  r = post_uri(uri, 'abc')
  r.response_code.should == 200
  r.close
end

Then /^I should be able to get the object$/ do
  uri = get_uri @app, "bucket1/object1"
  r = get_uri_contents uri
  r.should_not == nil
  r.response_code.should == 200
  r.body_str.should == 'abc'
  r.close
end

After("@creates_blob_app") do |scenario|
  delete_app @app, @token if @app
end

After("@creates_blob_service") do |scenario|
  delete_service @blob_service[:name] if @blob_service
end

