Feature: elasticsearch service binding and app deployment

  In order to use elasticsearch service in cloud foundry
  As the VMC user
  I want to deploy my app against elasticsearch service

  @creates_elasticsearch_service @create_elasticsearch_app
  Scenario: deploy simple elasticsearch application
    Given I am registered
    Given I have provisioned an elasticsearch service
    Given I have deployed an elasticsearch application that is bound to this service
    When I add a document in my elasticsearch service through my application
    Then I should be able to get it
