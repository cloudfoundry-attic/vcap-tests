Feature: Use Python on AppCloud
  As a Python user of AppCloud
  I want to be able to deploy and manage Python applications

  Background: Authentication
    Given I have registered and logged in

  @creates_wsgi_app
  Scenario: Deploy Simple Python Application
    Given I have deployed a simple Python application
    Then it should be available for use
