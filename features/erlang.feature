Feature: Use Erlang on AppCloud
  As an Erlang user of AppCloud
  I want to be able to deploy and manage Erlang applications
   
  Background: Authentication
    Given I have registered and logged in
   
  @creates_mochiweb_app
  Scenario: Deploy Simple Erlang Application
    Given I have built a simple Erlang application
      And I have deployed a simple Erlang application
    Then it should be available for use