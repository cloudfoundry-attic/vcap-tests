Feature: Create a simple key-value brokered service and test it using application

  As the cloudfoundry admin
  I create a simple key-value application as brokered service.

  Background: create brokered service

  @creates_simple_kv_app  @creates_brokered_service @creates_brokered_service_app @smoke @ruby @services
  Scenario: Create a brokered service
    When I have the service broker url and token
    Given I have registered and logged in
    Given I have deployed my application named simple_kv_app
    Then I create a brokered service using simple_kv_app as backend
    Then I should able to find the brokered service
    Given I have deployed my application named brokered_service_app
    Then I create a brokered service and bind it to brokered_service_app
    Then I post a key-value to app_brokered_service
    Then I should able to access the same key-value from simple_kv_app
