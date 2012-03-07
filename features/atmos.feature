Feature: atmos service binding and app deployment

  In order to use atmos in cloud foundry
  As the VMC user
  I want to deploy my app against atmos service

  @creates_atmos_service @creates_atmos_app
  Scenario: deploy simple atmos application
    Given I have registered and logged in
    Given I have provisioned an atmos service
    Given I have deployed an atmos application that is bound to this service
    When I create an object in backend atmos through my application
    Then I should be able to get the object
    Then I delete my application
