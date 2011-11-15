

Given /^Sqlfire is available as a service$/ do
  pending unless find_service("sqlfire")
end

Given /^I have provisioned a Sqlfire service with a (\w+) plan$/ do |plan|
  @sqlfire_service = provision_sqlfire_service(@token, plan)
  @sqlfire_service.should_not == nil
end

Given /^I have deployed a Sqlfire application that is bound to this service$/ do
  @app = create_app(SQLFIRE_APP, @token)
  attach_provisioned_service(@app, @sqlfire_service, @token)
  upload_app(@app, @token)
  start_app(@app, @token)
  expected_health = 1.0
  health = poll_until_done(@app, expected_health, @token)
  health.should == expected_health
end

When /^I access my application I should see a sqlfire jdbc string$/ do
  uri = get_uri(@app, "")
  response = get_uri_contents(uri)
  response.should_not == nil
  response.response_code.should == 200
  response.body_str.include?("DataSource: jdbc:sqlfire").should_not == nil
  response.close
end

#After("@sqlfire") do |scenario|
#  delete_app_services if @sqlfire_service
#end
