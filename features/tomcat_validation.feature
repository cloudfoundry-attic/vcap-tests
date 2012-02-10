Feature: Use Tomcat on Cloud Foundry
  As a JVM based app deployer on Cloud Foundry
  I want to use a validated version of Tomcat

  Background: Authentication
    Given I have registered and logged in

    @creates_tomcat_version_check_app @smoke @java
    Scenario: Deploy a Java servlet
      Given I have deployed a Java servlet to get the web container version
      When I get the version of the web container from the Java servlet
      Then the version should be that of a Tomcat runtime
      And the version should match the version of the Tomcat runtime that is packaged for Cloud Foundry
      Then I delete my application
