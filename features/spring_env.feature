Feature: Use Spring 3.1 Environment on AppCloud
  As a user of AppCloud
  I want to launch Spring 3.1 Environment apps that expose the cloud profile and cloud properties to the app

  Background: Validate account
    Given I have registered and logged in

  @creates_spring_env_app
  Scenario: deploy Spring 3.1 Environment Application
    Given I have deployed a Spring 3.1 application
    Then the cloud profile should be active
    And the default profile should not be active
    And the cloud property source should exist
    And the cloud.application.name property should be the app name
    And the cloud.provider.url property should be the cloud provider url

    # Note: 'redis_' is prefixed to the service name provided
    When I bind a Redis service named cache-provider to the Spring 3.1 application
    Then the cloud.services.redis.type property should be redis-2.2
    And the cloud.services.redis.plan property should be free
    And the cloud.services.redis.connection.password and cloud.services.redis_cache-provider.connection.password properties should have the same value
