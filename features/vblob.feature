Feature: vblob service binding and app deployment

  In order to use vblob service in cloud foundry
  As the VMC user
  I want to deploy my app against vblob service

  @creates_vblob_service @creates_vblob_app
  Scenario: deploy simple vblob application
    Given I have registered and logged in
    Given I have provisioned a vblob service
    Given I have deployed a vblob application that is bound to this service
    Given I create a container in my vblob service through my application
    When I create an file in my vblob service through my application
    Then I should be able to get the file
    Then I delete my service
    Then I delete my application
