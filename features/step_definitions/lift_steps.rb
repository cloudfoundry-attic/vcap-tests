require 'rest_client'

Given /^I have deployed a simple Lift application$/ do
  @app = create_app SIMPLE_LIFT_APP, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

Given /^I deploy a Lift application using the MySQL DB service$/ do
  expected_health = 1.0
  health = create_and_start_app LIFT_DB_APP, expected_health
  health.should == expected_health
end

When /^I add (\d+) records to the Lift application$/ do |arg1|
  @records = {}
  uri = get_uri @app, "api/guests"
  1.upto arg1.to_i do |i|
    key = "key-#{i}"
    content = "<guest><name>#{key}</name></guest>"
    @records[key] = content
    response = post_xml_content uri, content
    response.should == 200
  end
end

Then /^I should have the same (\d+) records on retrieving all records from the Lift application$/ do |arg1|
  url = get_uri @app, "api/guests"
  response = RestClient.get url, :accept => 'text/xml'
  response.should_not == nil
  response.code.should == 200
  verify_contents arg1.to_i, response.body, "//guest"
end

When /^I deploy a Lift application using the created MySQL service$/ do
  expected_health = 1.0
  health = create_and_start_app LIFT_DB_APP, expected_health, @service
  health.should == expected_health
end

Then /^the Lift app should be available for use$/ do
  url = get_uri @app
  response = RestClient.get url
  response.should_not == nil
  response.code.should == 200
  response.body.should_not == nil
  response.body.should =~ /hello_lift/
#  contents = get_app_contents @app
#  contents.should_not == nil
#  contents.body_str.should_not == nil
#  contents.body_str.should =~ /hello_lift/
#  contents.close
end

def post_xml_content url, content
  response = RestClient.post url, content, :content_type => 'text/xml', :accept => 'text/xml'
  response.code
end

After("@creates_lift_db_adapter") do |scenario|
  delete_app_services
end
