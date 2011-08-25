Feature: Use PHP on AppCloud
  As a PHP user of AppCloud
  I want to be able to deploy and manage PHP applications

  Background: Authentication
    Given I have registered and logged in

  @creates_simple_php_app
  Scenario: Deploy Simple PHP Application
    Given I have deployed a simple PHP application
    Then it should be available for use
