Feature: memcached service binding and app deployment

  In order to use memcached service in cloud foundry
  As the VMC user
  I want to deploy my app against memcached service

  @creates_memcached_service @creates_memcached_app
  Scenario: deploy simple memcached application
    Given I am registered
    Given I have provisioned a memcached service
    Given I have deployed a memcached application that is bound to this service
    Given I put a key value pair in my memcached service through my application
    When I put a key value pair in my memcached service through my application
    Then I should be able to get the value for the key
