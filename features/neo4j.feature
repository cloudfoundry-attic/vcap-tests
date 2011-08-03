Feature: Neo4j service binding and app deployment

  In order to use Neo4j in AppCloud
  As the VMC user
  I want to deploy my app against a Neo4j service

  @creates_neo4j_app @creates_neo4j_service
  Scenario: Deploy Neo4j
    Given I have registered and logged in
    Given I have provisioned a Neo4j service
    Given I have deployed a Neo4j application that is bound to this service
    When I add an answer to my application
    Then I should be able to retrieve it
