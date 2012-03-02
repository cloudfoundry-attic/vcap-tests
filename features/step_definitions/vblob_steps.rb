Given /^I have provisioned a vblob service$/ do
  pending unless find_service 'vblob'
  @service = provision_vblob_service @token
  @service.should_not == nil
end

Given /^I have deployed a vblob application that is bound to this service$/ do
  @app = create_app VBLOB_APP, @token
  attach_provisioned_service @app, @service, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

Given /^I create a container in my vblob service through my application$/ do
  uri = get_uri(@app, 'container1')
  r = post_uri(uri,'dummy') # here post_uri requires payload, but our service safely ignores the payload, thus really some dummy data to make post_uri happy
  r.response_code.should == 200
  r.close
end

When /^I create an file in my vblob service through my application$/ do
  uri = get_uri(@app, 'container1/file1')
  r = post_uri(uri, 'abc')
  r.response_code.should == 200
  r.close
end

Then /^I should be able to get the file$/ do
  uri = get_uri @app, "container1/file1"
  r = get_uri_contents uri
  r.should_not == nil
  r.response_code.should == 200
  r.body_str.should == 'abc'
  r.close
end
