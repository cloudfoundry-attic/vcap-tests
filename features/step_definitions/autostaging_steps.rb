require 'curb'
require 'nokogiri'
require 'pp'

Given /^I deploy a Spring application using a Cloud Service and Data Source$/ do
  expected_health = 1.0
  create_and_upload_app VCAP_JAVA_TEST_APP
  mongosvc = provision_mongodb_service @token
  attach_provisioned_service @app, mongosvc, @token
  mysqlsvc = provision_db_service @token
  attach_provisioned_service @app, mysqlsvc, @token
  environment_add @app,'TEST_PROFILE','auto-staging-off-using-cloud-service'
  health = start_app_check_health expected_health
  health.should == expected_health
end

Given /^I deploy a Spring application using Service Scan and a Data Source$/ do
  expected_health = 1.0
  create_and_upload_app VCAP_JAVA_TEST_APP
  mysqlsvc = provision_db_service @token
  attach_provisioned_service @app, mysqlsvc, @token
  environment_add @app,'TEST_PROFILE','auto-staging-off-using-service-scan'
  health = start_app_check_health expected_health
  health.should == expected_health
end

Then /^the Data Source should not be auto-configured$/ do
  response = get_app_contents @app, "mysql"
  response.should_not == nil
  response.response_code.should == 200
  response.body_str.should =~ /jdbc:mysql:\/\/localhost:3306\/vcap-java-test-app/m
end

Given /^I deploy a Spring JPA application using the MySQL DB service$/ do
  expected_health = 1.0
  health = create_and_start_app JPA_APP, expected_health
  health.should == expected_health
end


When /^I add (\d+) records to the application$/ do |arg1|
  @records = {}
  uri = get_uri @app
  1.upto arg1.to_i do |i|
    key = "key-#{i}"
    value = "FooBar-#{i}"
    @records[key] = value
    response = post_content uri, "name", value
    response.should == 302
  end
end

Then /^I should have the same (\d+) records on retrieving all records from the application$/ do |arg1|
  response = get_app_contents @app
  response.should_not == nil
  response.response_code.should == 200
  verify_contents arg1.to_i, response.body_str, "//li/p"
end

When /^I deploy a Spring JPA application using the created MySQL service$/ do
  expected_health = 1.0
  health = create_and_start_app JPA_APP, expected_health, @service
  health.should == expected_health
end

Given /^I deploy a Spring Hibernate application using the MySQL DB service$/ do
  expected_health = 1.0
  health = create_and_start_app HIBERNATE_APP, expected_health
  health.should == expected_health
end

When /^I deploy a Spring Hibernate application using the created MySQL service$/ do
  expected_health = 1.0
  health = create_and_start_app HIBERNATE_APP, expected_health, @service
  health.should == expected_health
end

When /^I deploy a Spring Hibernate application using the created PostgreSQL service$/ do
  expected_health = 1.0
  health = create_and_start_app HIBERNATE_APP, expected_health, @service
  health.should == expected_health
end

Given /^I deploy a dbrails application using the MySQL DB service$/ do
  expected_health = 1.0
  health = create_and_start_app DBRAILS_APP, expected_health
  health.should == expected_health
end

When /^The dbrails app should work$/ do
  # init the database
  response = get_app_contents @app, '/db/init'
  response.should_not == nil
  response.response_code.should == 200
  p = JSON.parse(response.body_str)
  p['operation'].should == 'success'

  # execute a query
  response = get_app_contents @app, '/db/query'
  response.should_not == nil
  response.response_code.should == 200
  p = JSON.parse(response.body_str)
  p['operation'].should == 'success'

  # execute an update
  response = get_app_contents @app, '/db/update'
  response.should_not == nil
  response.response_code.should == 200
  p = JSON.parse(response.body_str)
  p['operation'].should == 'success'

  # execute a create
  response = get_app_contents @app, '/db/create'
  response.should_not == nil
  response.response_code.should == 200
  p['operation'].should == 'success'
end

Given /^I deploy a broken dbrails application  using the MySQL DB service$/ do
  expected_health = 0.0
  @health = create_and_start_app DBRAILS_BROKEN_APP, expected_health
end

Then /^The broken dbrails application should fail$/ do
  expected_health = 0.0
  @health.should == expected_health
end

Given /^I have deployed a Rails 3 application$/ do
  expected_health = 1.0
  @service = provision_db_service @token
  health = create_and_start_app RAILS3_APP, expected_health
  health.should == expected_health
end

Then /^I can add a Widget to the database$/ do
  @widget_name = "somewidget"
  uri = get_uri @app, "make_widget/#{@widget_name}"
  response = get_uri_contents uri
  @widget_response = response.body_str.dup
  @widget_response.should == "Saved somewidget"
  response.close
end


def post_content url, field, value
  easy = Curl::Easy.new
  easy.url =  url
  easy.http_post(Curl::PostField.content(field, value))
  response = easy.response_code
  easy.close
  response
end

def verify_contents count, contents, path
  doc = Nokogiri::XML(contents)
  list = doc.xpath(path)
  list.length.should == count
  @records.values.each do |record_val|
    record_present(record_val, list)
  end
end

def record_present record, list
  list.each do |item|
    if item.content.include? record
      return true
    end
  end
  nil
end

def create_and_upload_app app
  @app = create_app app, @token
  upload_app @app, @token
end

def start_app_check_health expected_health
  start_app @app, @token
  health = poll_until_done @app, expected_health, @token
  health
end

def create_and_start_app app, expected_health, service=nil
  @app = create_app app, @token
  if service == nil
    @service = provision_db_service @token unless service
  end
  attach_provisioned_service @app, @service, @token
  upload_app @app, @token
  start_app @app, @token
  health = poll_until_done @app, expected_health, @token
  health
end

def delete_app_services
  app_info = get_app_status @app, @token
  app_info.should_not == nil
  services = app_info[:services]
  delete_services services if services.length.to_i > 0
  @services = nil
end

# check application exist before deleting its services.
def delete_app_services_check
  if @app.nil?
    @services = nil
    return
  else
    delete_app_services
  end
end

Given /^I deploy a Spring Grails application using the MySQL DB service$/ do
  expected_health = 1.0
  health = create_and_start_app GRAILS_APP, expected_health
  health.should == expected_health
end

When /^I add (\d+) records to the Grails application$/ do |arg1|
  @records = {}
  uri = get_uri @app, "guest/save"
  1.upto arg1.to_i do |i|
    key = "key-#{i}"
    value = "FooBar-#{i}"
    @records[key] = value
    response = post_content uri, "name", value
    response.should == 302
  end
end

When /^I deploy a Spring Grails application using the created MySQL service$/ do
  expected_health = 1.0
  health = create_and_start_app GRAILS_APP, expected_health, @service
  health.should == expected_health
end


Then /^I should have the same (\d+) records on retrieving all records from the Grails application$/ do |arg1|
  response = get_app_contents @app, "guest/list"
  response.should_not == nil
  response.response_code.should == 200
  verify_contents arg1.to_i, response.body_str, "//tbody/tr"
end

Given /^I deploy a Spring Roo application using the MySQL DB service$/ do
  expected_health = 1.0
  health = create_and_start_app ROO_APP, expected_health
  health.should == expected_health
end

When /^I add (\d+) records to the Roo application$/ do |arg1|
  @records = {}
  uri = get_uri @app, "guests"
  1.upto arg1.to_i do |i|
    key = "key-#{i}"
    value = "FooBar-#{i}"
    @records[key] = value
    response = post_content uri, "name", value
    response.should == 302
  end
end

When /^I deploy a Spring Roo application using the created MySQL service$/ do
  expected_health = 1.0
  health = create_and_start_app ROO_APP, expected_health, @service
  health.should == expected_health
end


Then /^I should have the same (\d+) records on retrieving all records from the Roo application$/ do |arg1|
  response = get_app_contents @app, "guests"
  response.should_not == nil
  response.response_code.should == 200
  # The Roo page returns an extra row for the footer in the table .. hence the "+ 1"
  verify_contents arg1.to_i + 1, response.body_str, "//table/tr"
end

After("@creates_services") do |scenario|
  delete_app_services
end

After("@creates_jpa_db_adapter") do |scenario|
  delete_app_services
end

After("@creates_hibernate_db_adapter") do |scenario|
  delete_app_services
end


After("@creates_hibernate_postgresql_adapter") do |scenario|
  delete_app_services_check
end

After("@creates_grails_db_adapter") do |scenario|
  delete_app_services
end

After("@creates_roo_db_adapter") do |scenario|
  delete_app_services
end

After("@creates_rails3_db_adapter") do |scenario|
  delete_app_services
end


After("@creates_dbrails_db_adapter") do |scenario|
  delete_app_services
end

After("@creates_dbrails_broken_db_adapter") do |scenario|
  delete_app_services
end

