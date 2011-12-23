Feature: blob service binding and app deployment

  In order to use blob service in cloud foundry
  As the VMC user
  I want to deploy my app against blob service

  @creates_blob_service @creates_blob_app
  Scenario: deploy simple blob application
    Given I have registered and logged in
    Given I have provisioned a blob service
    Given I have deployed a blob application that is bound to this service
    Given I create a container in my blob service through my application
    When I create an file in my blob service through my application
    Then I should be able to get the file
