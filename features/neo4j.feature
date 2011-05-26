Feature: Neo4j service binding and app deployment

	 In order to use Neo4j in AppCloud
	 As the VMC user
	 I want to deploy my app against a Neo4j service

	 Scenario: Deploy Neo4j 
		Given I have deployed a Neo4j application that is backed by a Neo4j Service
		When I add an answer to my application
		Then I should be able see it on the start page

