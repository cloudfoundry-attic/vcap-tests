@sinatra @smoke @ruby @rubygems
Feature: Deploy the sinatra app with specified gem dependencies

  As a user of Cloud Foundry
  I want to deploy ruby applications with specified gem dependencies

  Background: Logging in to Cloud Foundry
    Given I have registered and logged in

  Scenario: sinatra test deploy app with gem containing invalid date
    Given I have deployed my application named broken_gem_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application root and see hello from sinatra
    When I delete my application
    Then it should not be on Cloud Foundry

  Scenario: sinatra test deploy app with git gems using ruby19
    Given I have deployed my application named git_gems_app_ruby19
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application root and see hello from git
    When I delete my application
    Then it should not be on Cloud Foundry

  Scenario: sinatra test deploy app with git gems using ruby18
    Given I have deployed my application named git_gems_app_ruby19
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application root and see hello from git
    When I delete my application
    Then it should not be on Cloud Foundry

