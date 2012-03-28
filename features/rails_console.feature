Feature: Deploy the rails canonical app and check the console

  As a user of Rails apps
  I want to deploy the canonical Rails app and use its console

  Background: Rails Console
    Given I have registered and logged in

   @runs_rails_console
   Scenario: rails test console
    Given I have deployed my application named rails_console_test_app
    When I first access console of my application
    Then I should get responses irb():001:0>  from console of my application
    When I send command app.class to console of my application
    Then I should get responses app.class,=> ActionDispatch::Integration::Session,irb():002:0>  from console of my application
    Then I close console
    Then I delete my application

   @runs_rails_console
   Scenario: rails test console tab completion
    Given I have deployed my application named rails_console_test_app
    When I first access console of my application
    Then I should get responses irb():001:0>  from console of my application
    When I send tab completion puts to console of my application
    Then I should get completion results puts from console of my application
    Then I close console
    Then I delete my application

   @runs_rails_console
   Scenario: rails test console stdout redirect
    Given I have deployed my application named rails_console_test_app
    When I first access console of my application
    Then I should get responses irb():001:0>  from console of my application
    When I send command puts 'hi' to console of my application
    Then I should get responses puts 'hi',hi,=> nil,irb():002:0>  from console of my application
    Then I close console
    Then I delete my application

   @runs_rails_console
   Scenario: rails test console rake tasks
    Given I have deployed my application named rails_console_test_app
    When I first access console of my application
    Then I should get responses irb():001:0>  from console of my application
    When I send command `rake routes` to console of my application
    Then I should get response including :action=>\"hello\" from console of my application
    Then I close console
    Then I delete my application

   @runs_rails_console
   Scenario: rails test console rake tasks with ruby 1.9
    Given I have deployed my application named rails_console_19_test_app
    When I first access console of my application
    Then I should get responses irb():001:0>  from console of my application
    When I send command `rake routes` to console of my application
    Then I should get response including :action=>\"index\" from console of my application
    Then I close console
    Then I delete my application

   @runs_rails_console
   Scenario: Rails Console runs tasks with correct ruby 1.8 version in path
    Given I have deployed my application named rails_console_test_app
    When I first access console of my application
    Then I should get responses irb():001:0>  from console of my application
    When I send command `ruby --version` to console of my application
    Then I should get response including ruby 1.8 from console of my application
    Then I close console
    Then I delete my application

   @runs_rails_console
   Scenario: Rails Console runs tasks with correct ruby 1.9 version in path
    Given I have deployed my application named rails_console_19_test_app
    When I first access console of my application
    Then I should get responses irb():001:0>  from console of my application
    When I send command `ruby --version` to console of my application
    Then I should get response including ruby 1.9 from console of my application
    Then I close console
    Then I delete my application


