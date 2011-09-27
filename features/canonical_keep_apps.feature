# These tests unlike other BVTs are not cleaning up after themselves
# The purpose is to keep the apps and services running for verifying the 
# survival of the services after actions like stopping service nodes or upgrading
# These tests are expected to be run prior to tests in upgrade_canonical_apps.feature 
# This feature should be excluded via cucumber --tags ~@bvt_upgrade from the
# regular BVT run
# To run only the tests for one particular app use cucumber tags:
## --tags @bvt_upgrade --tags @sinatra

@bvt_upgrade
Feature: Deploy canonical apps and check their service

	As a user with all canonical apps.
	I want to deploy all canonical apps and use all their service

	Background: deploying canonical service
	  Given I have registered and logged in

    @sinatra
    Scenario: sinatra_keep_app test services
      Given I have deployed my application named app_sinatra_service
      When I query status of my application
      Then I should get the state of my application
      Then I should be able to access my application root and see hello from sinatra
      When I provision mysql service
      Then I post mysqlabc to mysql service with key abc
      Then I should be able to get from mysql service with key abc, and I should see mysqlabc
      When I provision redis service
      Then I post redisabc to redis service with key abc
      Then I should be able to get from redis service with key abc, and I should see redisabc
      When I provision mongodb service
      Then I post mongoabc to mongo service with key abc
      Then I should be able to get from mongo service with key abc, and I should see mongoabc
      When I provision rabbitmq service
      Then I post rabbitabc to rabbitmq service with key abc
      Then I should be able to get from rabbitmq service with key abc, and I should see rabbitabc
      When I provision postgresql service
      Then I post postgresqlabc to postgresql service with key abc
      Then I should be able to get from postgresql service with key abc, and I should see postgresqlabc

    @node
    Scenario: node_keep_app test services
      Given I have deployed my application named app_node_service
      When I query status of my application
      Then I should get the state of my application
      Then I should be able to access my application root and see hello from node
      When I provision mysql service
      Then I post mysqlabc to mysql service with key abc
      Then I should be able to get from mysql service with key abc, and I should see mysqlabc
      When I provision redis service
      Then I post redisabc to redis service with key abc
      Then I should be able to get from redis service with key abc, and I should see redisabc
      When I provision mongodb service
      Then I post mongoabc to mongo service with key abc
      Then I should be able to get from mongo service with key abc, and I should see mongoabc
      When I provision rabbitmq service
      Then I post rabbitabc to rabbitmq service with key abc
      Then I should be able to get from rabbitmq service with key abc, and I should see rabbitabc
      When I provision postgresql service
      Then I post postgresqlabc to postgresql service with key abc
      Then I should be able to get from postgresql service with key abc, and I should see postgresqlabc

    @spring
    Scenario: spring_keep_app test services
      Given I have deployed my application named app_spring_service
      When I query status of my application
      Then I should get the state of my application
      Then I should be able to access my application root and see hello from spring
      When I provision mysql service
      Then I post mysqlabc to mysql service with key abc
      Then I should be able to get from mysql service with key abc, and I should see mysqlabc
      When I provision redis service
      Then I post redisabc to redis service with key abc
      Then I should be able to get from redis service with key abc, and I should see redisabc
      When I provision mongodb service
      Then I post mongoabc to mongo service with key abc
      Then I should be able to get from mongo service with key abc, and I should see mongoabc
      When I provision rabbitmq service
      Then I post rabbitabc to rabbitmq service with key abc
      Then I should be able to get from rabbitmq service with key abc, and I should see rabbitabc
      When I provision postgresql service
      Then I post postgresqlabc to postgresql service with key abc
      Then I should be able to get from postgresql service with key abc, and I should see postgresqlabc

    @rails
    Scenario: rails_keep_app test services
      Given I have deployed my application named app_rails_service
      When I query status of my application
      Then I should get the state of my application
      Then I should be able to access my application root and see hello from rails
      When I provision mysql service
      Then I post mysqlabc to mysql service with key abc
      Then I should be able to get from mysql service with key abc, and I should see mysqlabc
      When I provision redis service
      Then I post redisabc to redis service with key abc
      Then I should be able to get from redis service with key abc, and I should see redisabc
      When I provision mongodb service
      Then I post mongoabc to mongo service with key abc
      Then I should be able to get from mongo service with key abc, and I should see mongoabc
      When I provision rabbitmq service
      Then I post rabbitabc to rabbitmq service with key abc
      Then I should be able to get from rabbitmq service with key abc, and I should see rabbitabc
# Limitation of the rails app to not allow provisioning of both postgresql and mysql
#      When I provision postgresql service
#      Then I post postgresqlabc to postgresql service with key abc
#      Then I should be able to get from postgresql service with key abc, and I should see postgresqlabc
