require 'rest_client'

Given /^I have deployed a Java servlet to get the web container version$/ do
  @app = create_app TOMCAT_VERSION_CHECK_APP, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

When /^I get the version of the web container from the Java servlet$/ do
  @version = get_version
end

Then /^the version should be that of a Tomcat runtime$/ do
  @version.should_not == nil
  @version.should =~ /Apache Tomcat/
end

Then /^the version should match the version of the Tomcat runtime that is packaged for Cloud Foundry$/ do
  packaged_version = get_expected_tomcat_version
  packaged_version.should_not == nil
  # The Tomcat version reported by the servlet is of the form
  # 'Apache Tomcat/6.0.xx' for Tomcat 6 based releases.
  @version.split('/')[1].should == packaged_version
end

def get_version
  url = get_uri @app
  response = RestClient.get url
  response.should_not == nil
  response.code.should == 200
  response.body.should_not == nil
  doc = Nokogiri::XML(response.body)
  version = doc.xpath("//version").first.content
end
