Feature: blob service binding and app deployment

  In order to use blob in cloud foundry
  As the VMC user
  I want to deploy my app against blob service

  @creates_blob_service @creates_blob_app
  Scenario: deploy simple blob application
    Given I have registered and logged in
    Given I have provisioned an blob service
    Given I have deployed an blob application that is bound to this service
    Given I create a bucket in backend blob through my application
    When I create an object in backend blob through my application
    Then I should be able to get the object
