Feature: Deploy the rails canonical app and check the console

  As a user of Rails apps
  I want to deploy the canonical Rails app and use its console

  Background: Rails Console
    Given I have registered and logged in
    Given I have deployed my application named rails_console_test_app

   @runs_rails_console
   Scenario: rails test console
    Given I have my running application named rails_console_test_app
    When I first access console of my application
    Then I should get responses irb():001:0>  from console of my application
    When I send command app.class to console of my application
    Then I should get responses app.class,=> ActionDispatch::Integration::Session,irb():002:0>  from console of my application
    Then I close console

   @runs_rails_console
   Scenario: rails test console tab completion
    Given I have my running application named rails_console_test_app
    When I first access console of my application
    Then I should get responses irb():001:0>  from console of my application
    When I send tab completion puts to console of my application
    Then I should get completion results puts from console of my application
    Then I close console

   @runs_rails_console
   Scenario: rails test console stdout redirect
    Given I have my running application named rails_console_test_app
    When I first access console of my application
    Then I should get responses irb():001:0>  from console of my application
    When I send command puts 'hi' to console of my application
    Then I should get responses puts 'hi',hi,=> nil,irb():002:0>  from console of my application
    Then I close console

