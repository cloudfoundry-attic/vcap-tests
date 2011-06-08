Feature: Deploy all canonical apps and check their services

	As a user with all canonical apps.
	I want to deploy all canonical apps and use all their service

	Background: deploying canonical service
	  Given I have registered and logged in

    Scenario: sinatra test services
      Given I have deployed my application named app_sinatra_service
      When I query status of my application
      Then I should get the state of my application
      Then I should be able to access my application root and see hello from sinatra
      Then I should be able to access crash and it should crash
      When I provision mysql service
      Then I post mysqlabc to mysql service with key abc
      Then I should be able to get from mysql service with key abc, and I should see mysqlabc
      Then I delete my service
      When I provision redis service
      Then I post redisabc to redis service with key abc
      Then I should be able to get from redis service with key abc, and I should see redisabc
      Then I delete my service
      When I provision mongodb service
      Then I post mongoabc to mongo service with key abc
      Then I should be able to get from mongo service with key abc, and I should see mongoabc
      Then I delete my service
      When I provision rabbitmq service
      Then I post rabbitabc to rabbit service with key abc
      Then I should be able to get from rabbit service with key abc, and I should see rabbitabc
      Then I delete my service
      When I delete my application
      Then it should not be on AppCloud

    Scenario: node test services
      Given I have deployed my application named app_node_service
      When I query status of my application
      Then I should get the state of my application
      Then I should be able to access my application root and see hello from node
      Then I should be able to access crash and it should crash
      When I provision mysql service
      Then I post mysqlabc to mysql service with key abc
      Then I should be able to get from mysql service with key abc, and I should see mysqlabc
      Then I delete my service
      When I provision redis service
      Then I post redisabc to redis service with key abc
      Then I should be able to get from redis service with key abc, and I should see redisabc
      Then I delete my service
      When I provision mongodb service
      Then I post mongoabc to mongo service with key abc
      Then I should be able to get from mongo service with key abc, and I should see mongoabc
      Then I delete my service
      When I provision rabbitmq service
      Then I post rabbitabc to rabbit service with key abc
      Then I should be able to get from rabbit service with key abc, and I should see rabbitabc
      Then I delete my service
      When I delete my application
      Then it should not be on AppCloud

    Scenario: spring test services
      Given I have deployed my application named app_spring_service
      #with spring we must have a datasource define
      When I provision mysql service
      Then I post mysqlabc to mysql service with key abc
      Then I should be able to get from mysql service with key abc, and I should see mysqlabc
      When I query status of my application
      Then I should get the state of my application
      Then I should be able to access my application root and see hello from spring
      Then I should be able to access crash and it should crash
      When I provision redis service
      Then I post redisabc to redis service with key abc
      Then I should be able to get from redis service with key abc, and I should see redisabc
      Then I delete my service
      When I provision mongodb service
      Then I post mongoabc to mongo service with key abc
      Then I should be able to get from mongo service with key abc, and I should see mongoabc
      Then I delete my service
      When I provision rabbitmq service
      Then I post rabbitabc to rabbit service with key abc
      Then I should be able to get from rabbit service with key abc, and I should see rabbitabc
      Then I delete my service
      Then I delete all my service
      When I delete my application
      Then it should not be on AppCloud

	  Scenario: rails test services
      Given I have deployed my application named app_rails_service
	    When I query status of my application
	    Then I should get the state of my application
      Then I should be able to access my application root and see hello from rails
      Then I should be able to access crash and it should crash
      When I provision mysql service
      Then I post mysqlabc to mysql service with key abc
      Then I should be able to get from mysql service with key abc, and I should see mysqlabc
      Then I delete my service
      When I provision redis service
      Then I post redisabc to redis service with key abc
      Then I should be able to get from redis service with key abc, and I should see redisabc
      Then I delete my service
      When I provision mongodb service
      Then I post mongoabc to mongo service with key abc
      Then I should be able to get from mongo service with key abc, and I should see mongoabc
      Then I delete my service
      When I provision rabbitmq service
      Then I post rabbitabc to rabbit service with key abc
      Then I should be able to get from rabbit service with key abc, and I should see rabbitabc
      Then I delete my service
      When I delete my application
      Then it should not be on AppCloud
