# The canonical_apps_* tests can be explicitly run via "bundle exec cucumber"
# using "--tags @canonical" on the command line or setting CUCUMBER_OPTIONS
# environment variable when invoking rake tasks.
# Combinations of app(s)/service(s) can now be chosen by combining tags.
# If not passing "--tags ~@delete" the services and apps are
# deleted during the run, and if passed the apps and provisioned services
# are left running at the end of the run.
# To select only one app to run, or a combination app and services use:
# --tags @canonical --tags @node
# --tags @canonical --tags @spring --tags @mysql,postgresql
# --tags @canonical --tags @spring --tags @postgresql --tags ~@delete

@canonical @node @services @debug-node
Feature: Deploy the node canonical app and check its services

  As a user with all canonical apps
  I want to deploy all canonical apps and use all their service

  Background: deploying canonical service
    Given I have registered and logged in
    Given I have deployed my application named app_node_service

  Scenario: node test deploy app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application root and see hello from node
    Then I should be able to access crash and it should crash
    When I delete my application
    Then it should not be on AppCloud

  @mysql
  Scenario: node test mysql service
    Given I have my running application named app_node_service
    When I provision mysql service
    Then I post mysqlabc_updated to mysql service with key abc
    Then I should be able to get from mysql service with key abc, and I should see mysqlabc_updated
    Then I put mysqlabc to mysql service with key abc
    Then I should be able to get from mysql service with key abc, and I should see mysqlabc
    Then I delete my service
    When I delete my application
    Then it should not be on AppCloud

  @redis
  Scenario: node test redis service
    Given I have my running application named app_node_service
    When I provision redis service
    Then I post redisabc_updated to redis service with key abc
    Then I should be able to get from redis service with key abc, and I should see redisabc_updated
    Then I put redisabc to redis service with key abc
    Then I should be able to get from redis service with key abc, and I should see redisabc
    Then I delete my service
    When I delete my application
    Then it should not be on AppCloud

  @mongodb
  Scenario: node test mongodb service
    Given I have my running application named app_node_service
    When I provision mongodb service
    Then I post mongoabc_updated to mongo service with key abc
    Then I should be able to get from mongo service with key abc, and I should see mongoabc_updated
    Then I put mongoabc to mongo service with key abc
    Then I should be able to get from mongo service with key abc, and I should see mongoabc
    Then I delete my service
    When I delete my application
    Then it should not be on AppCloud

  @rabbitmq
  Scenario: node test rabbitmq service
    Given I have my running application named app_node_service
    When I provision rabbitmq service
    Then I post rabbitabc_updated to rabbitmq service with key abc
    Then I should be able to get from rabbitmq service with key abc, and I should see rabbitabc_updated
    Then I put rabbitabc to rabbitmq service with key abc
    Then I should be able to get from rabbitmq service with key abc, and I should see rabbitabc
    Then I post rabbitabc to rabbitmq service with key abc
    Then I delete my service
    When I delete my application
    Then it should not be on AppCloud

  @postgresql
  Scenario: node test postgresql service
    Given I have my running application named app_node_service
    When I provision postgresql service
    Then I post pgresqlabc_updated to postgresql service with key abc
    Then I should be able to get from postgresql service with key abc, and I should see pgresqlabc_updated
    Then I put postgresqlabc to postgresql service with key abc
    Then I should be able to get from postgresql service with key abc, and I should see postgresqlabc
    Then I delete my service
    When I delete my application
    Then it should not be on AppCloud
