require 'curb'
require 'nokogiri'
require 'pp'

Given /^I deploy a Spring application using a Cloud Service and Data Source$/ do
  expected_health = 1.0
  create_and_upload_app AUTO_RECONFIG_TEST_APP
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
  create_and_upload_app AUTO_RECONFIG_TEST_APP
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
  response.body_str.should == 'jdbc:mysql://localhost:3306/vcap-java-test-app'
end

Given /^I deploy a Spring application using a local MongoDBFactory$/ do
  expected_health = 1.0
  create_and_upload_app AUTO_RECONFIG_TEST_APP
  mongosvc = provision_mongodb_service @token
  attach_provisioned_service @app, mongosvc, @token
  environment_add @app,'TEST_PROFILE','mongo-auto-staging'
  health = start_app_check_health expected_health
  health.should == expected_health
end

Then /^the MongoDBFactory should be auto-configured$/ do
  response = get_app_contents @app, "mongo"
  response.should_not == nil
  response.response_code.should == 200
  response.body_str.should_not == 'localhost:1234'
end

Given /^I deploy a Spring application using a local RedisConnectionFactory$/ do
  expected_health = 1.0
  create_and_upload_app AUTO_RECONFIG_TEST_APP
  redissvc = provision_redis_service @token
  attach_provisioned_service @app, redissvc, @token
  environment_add @app,'TEST_PROFILE','redis-auto-staging'
  health = start_app_check_health expected_health
  health.should == expected_health
end

Then /^the RedisConnectionFactory should be auto-configured$/ do
  response = get_app_contents @app, "redis/host"
  response.should_not == nil
  response.response_code.should == 200
  response.body_str.should_not == 'localhost:1345'
end

Given /^I deploy a Spring application using a local RabbitConnectionFactory$/ do
  expected_health = 1.0
  create_and_upload_app AUTO_RECONFIG_TEST_APP
  pending unless find_service 'rabbitmq'
  rabbitsvc = provision_rabbitmq_service @token
  attach_provisioned_service @app, rabbitsvc, @token
  environment_add @app,'TEST_PROFILE','rabbit-auto-staging'
  health = start_app_check_health expected_health
  health.should == expected_health
end

Then /^the RabbitConnectionFactory should be auto-configured$/ do
  response = get_app_contents @app, "rabbit"
  response.should_not == nil
  response.response_code.should == 200
  response.body_str.should_not == 'localhost:1238'
end

Given /^I deploy a Spring Web Application that has no packaged mongo, redis, rabbit, or datasource dependencies$/ do
  expected_health = 1.0
  create_and_upload_app AUTO_RECONFIG_MISSING_DEPS_TEST_APP
  health = start_app_check_health expected_health
  health.should == expected_health
end

Then /^the application should start with no errors$/ do
  response = get_app_contents @app
  response.should_not == nil
  response.response_code.should == 200
end

Given /^I deploy a Spring 3.1 Hibernate application using a local DataSource$/ do
  expected_health = 1.0
  create_and_upload_app AUTO_RECONFIG_TEST_APP
  mysqlsvc = provision_db_service @token
  attach_provisioned_service @app, mysqlsvc, @token
  environment_add @app,'TEST_PROFILE','hibernate-auto-staging'
  health = start_app_check_health expected_health
  health.should == expected_health
end

Then /^the Hibernate SessionFactory should be auto-configured$/ do
  response = get_app_contents @app, "hibernate"
  response.should_not == nil
  response.response_code.should == 200
  response.body_str.should == 'org.hibernate.dialect.MySQLDialect'
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

Given /^I have deployed my application named (\w+) without starting$/ do |app_name|
  @app = create_app app_name, @token
  upload_app @app, @token
end

Then /^I start my application named (\w+)$/ do |app_name|
 @app = app_name
 expected_health = 1.0
 health = start_app_check_health expected_health
 health.should == expected_health
end

Then /^I provision ([\w\-]+) service without restarting$/ do |requested_service|
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
  end
end

Then /^I delete my service of type ([\w\-]+)$/ do |requested_service|
  all_services.each do |s|
    if s[:vendor].to_s == requested_service
      delete_service(s[:name])
    end
  end
end

def post_content url, field, value
  easy = Curl::Easy.new
  easy.url =  url
  easy.resolve_mode =:ipv4
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
