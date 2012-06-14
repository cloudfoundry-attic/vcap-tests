Feature: couchdb service binding and app deployment

  In order to use couchdb service in cloud foundry
  As the VMC user
  I want to deploy my app against couchdb service

  @creates_couchdb_service @creates_couchdb_app
  Scenario: deploy simple couchdb application
    Given I am registered
    Given I have provisioned a couchdb service
    Given I have deployed a couchdb application that is bound to this service
    Given I put a document in my couchdb service through my application
    When I put a document in my couchdb service through my application
    Then I should be able to get the document for the key
