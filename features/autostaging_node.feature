Feature: Deploy Node.js applications that make use of autostaging

  As a user of AppCloud
  I want to launch apps that expect automatic binding of the services that they use

  Background: Node.js autostaging
  Given I have registered and logged in

  @node @sanity @services
  Scenario: Node.js autostaging
    Given I have deployed my application named node_autoconfig
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
    Then I delete all my service
    Then I delete my application

  @node @sanity @services
  Scenario: Node.js version 0.4 autostaging
    Given I have deployed my application named node_autoconfig04
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
    Then I delete all my service
    Then I delete my application

  @node
  Scenario: Node.js opt-out of autostaging via config file
    Given I have deployed my application named node_autoconfig_disabled_by_file
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application root and see hello from node
    When I provision redis service
    Then I should be able to get from redis service with key connection, and I should see Redisconnectionto127.0.0.1:6379failed
    Then I delete all my service
    Then I delete my application

  @node
  Scenario: Node.js opt-out of autostaging via cf-runtime module
    Given I have deployed my application named node_autoconfig_disabled_by_module
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application root and see hello from node
    When I provision redis service
    Then I should be able to get from redis service with key connection, and I should see Redisconnectionto127.0.0.1:6379failed
    Then I delete all my service
    Then I delete my application
