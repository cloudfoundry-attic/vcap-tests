Feature: Sqlfire service binding and app deployment

  In order to use Sqlfire in AppCloud
  As the VMC user
  I want to deploy my app against a Sqlfire instance

  @sqlfire
  Scenario: Deploy Sqlfire
    Given I have registered and logged in
    Given Sqlfire is available as a service
    Given I have provisioned a Sqlfire service with a bronze plan
    Given I have deployed a Sqlfire application that is bound to this service
    When I access my application I should see a sqlfire jdbc string
