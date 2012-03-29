@smoke
Feature: Standalone application support

  As a user of Cloud Foundry
  I want to launch standalone apps

  Background: Standalone app support
    Given I have registered and logged in

  @ruby
  Scenario: Bundled app with ruby 1.8 runtime
    Given I have deployed my application named standalone_ruby18_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application root and see it's running version 1.8
    When I delete my application
    Then it should not be on Cloud Foundry

  @ruby
  Scenario: Bundled app with ruby 1.9 runtime
    Given I have deployed my application named standalone_ruby19_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application root and see it's running version 1.9
    When I delete my application
    Then it should not be on Cloud Foundry

  @ruby
  Scenario: Simple app with ruby 1.8 runtime and no URL
    Given I have deployed my application named standalone_simple_ruby18_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application file logs/stdout.log and see running version 1.8
    When I delete my application
    Then it should not be on Cloud Foundry

  @ruby
  Scenario: Simple app with ruby 1.9 runtime and no URL
    Given I have deployed my application named standalone_simple_ruby19_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application file logs/stdout.log and see running version 1.9
    When I delete my application
    Then it should not be on Cloud Foundry

  @ruby
  Scenario: With Java runtime
    Given I have deployed my application named standalone_java_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application file logs/stdout.log and see Hello from the cloud.  Java opts:  -Xms256m -Xmx256m -Djava.io.tmpdir=appdir/temp
    When I delete my application
    Then it should not be on Cloud Foundry

  @node
  Scenario: With node runtime
    Given I have deployed my application named standalone_node_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application root and see it's running version v0.4.12
    When I delete my application
    Then it should not be on Cloud Foundry

  @node
  Scenario: With node06 runtime
    Given I have deployed my application named standalone_node06_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application root and see it's running version v0.6.8
    When I delete my application
    Then it should not be on Cloud Foundry

  @ruby
  Scenario: With quotes in command
    Given I have deployed my application named standalone_simple_ruby18_quotes_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application file logs/stdout.log and see running version 1.8
    When I delete my application
    Then it should not be on Cloud Foundry

 Scenario: With PHP runtime
    Given I have deployed my application with runtime php named standalone_php_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application file logs/stdout.log and see Hello from VCAP
    When I delete my application
    Then it should not be on Cloud Foundry

Scenario: With Python runtime
    Given I have deployed my application with runtime python named standalone_python_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application file logs/stdout.log and see Hello, World!
    When I delete my application
    Then it should not be on Cloud Foundry

Scenario: With Erlang runtime
    Given I have deployed my application with runtime erlang named standalone_erlang_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application file logs/stdout.log and see Hello, world!
    When I delete my application
    Then it should not be on Cloud Foundry
