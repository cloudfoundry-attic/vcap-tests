Feature: Use JRuby on AppCloud
  As a JRuby user of AppCloud
  I want to be able to deploy and manage JRuby applications

  Background: Authentication
    Given I have registered and logged in

  @creates_jruby18_sinatra_simple_app
  Scenario: Deploy Simple JRuby 1.8 Sinatra Application
    Given I have deployed a simple JRuby 1.8 Sinatra application
    Then it should be available for use

