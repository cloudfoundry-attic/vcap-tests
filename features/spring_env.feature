Feature: Use Spring 3.1 Environment on AppCloud
  As a user of AppCloud
  I want to launch Spring 3.1 Environment apps that expose the cloud profile and cloud properties to the app

  Background: Validate account
    Given I have registered and logged in

  @creates_spring_env_app @smoke
  Scenario: deploy Spring 3.1 Environment Application
    Given I have deployed a Spring 3.1 application
    Then the cloud profile should be active
    And the default profile should not be active
    And the cloud property source should exist
    And the cloud application properties should be correct

    When I bind a redis service named cache-provider to the Spring 3.1 application
    Then the cloud service properties should be correct for a redis service named cache-provider
