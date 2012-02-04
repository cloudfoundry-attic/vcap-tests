Feature: Deploy the rails canonical app and check the console

  As a user of Rails apps
  I want to deploy the canonical Rails app and use its console

  Background: Rails Console
    Given I have registered and logged in

   Scenario: rails test deploy app
    Given I have deployed my application named app_rails_service
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application root and see hello from rails
    
   Scenario: rails test console
    Given I have my running application named app_rails_service
    When I first access console of my application
    Then I should get responses irb():001:0>  from console of my application
    When I send command app.class to console of my application
    Then I should get responses app.class,=> ActionDispatch::Integration::Session,irb():002:0>  from console of my application

   Scenario: rails test console tab completion
    Given I have my application console running
    When I send tab completion puts to console of my application
    Then I should get completion results puts from console of my application
    
   Scenario: close console connection
    Given I have my application console running
    Then I close my console connection

   Scenario: delete caldecott
    Given I have caldecott running
    Then I delete caldecott

   @delete @delete_app
   Scenario: rails test delete app
    Given I have my running application named app_rails_service
    When I delete my application
    Then it should not be on AppCloud
