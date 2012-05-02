@canonical @sinatra @smoke @ruby @rubygems
Feature: Deploy the sinatra canonical app with bad gem

  As a user with all canonical apps
  I want to deploy a sinatra app with a gem containing an invalid date

  Background: deploying canonical service
    Given I have registered and logged in

  Scenario: sinatra test deploy app with gem containing invalid date
    Given I have deployed my application named broken_gem_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application root and see hello from sinatra
    When I delete my application
    Then it should not be on Cloud Foundry
