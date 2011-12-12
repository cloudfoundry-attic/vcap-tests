# Simple mvstore Application that uses the mvstore database service

Given /^I have provisioned a mvstore service$/ do
  pending unless find_service 'mvstore'
  @mvstore_service = provision_mvstore_service @token
  @mvstore_service.should_not == nil
end

Given /^I have deployed a mvstore application that is bound to this service$/ do
  @app = create_app MVSTORE_APP, @token
  attach_provisioned_service @app, @mvstore_service, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

When /^I add an answer to my mvstore application$/ do
  uri = get_uri(@app, "service/mvstore/question")
  r = post_uri(uri, "A1")
  r.response_code.should == 200
  r.close
end

Then /^I should be able to retrieve my mvstore answer$/ do
  uri = get_uri @app, "service/mvstore/question"
  response = get_uri_contents uri
  response.should_not == nil
  response.response_code.should == 200
  contents = JSON.parse response.body_str
  contents[0]["mvstore_bvt1_value"].should == "A1"
  response.close
end

After("@creates_mvstore_service") do |scenario|
  delete_app_services if @mvstore_service
end
