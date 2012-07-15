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

@canonical @sinatra @ruby @services
Feature: Deploy the sinatra canonical app and check its services

  As a user with all canonical apps.
  I want to deploy all canonical apps and use all their service

  Background: deploying canonical service
    Given I have registered and logged in
    Given I have deployed my application named app_sinatra_service

  Scenario: sinatra test deploy app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application root and see hello from sinatra
    Then I should be able to access my application URL rack/env and see production
    Then I should be able to access my application file logs/stdout.log and get text including for production with backup
    Then I should be able to access crash and it should crash
    When I delete my application
    Then it should not be on AppCloud

  Scenario: sinatra test setting RACK_ENV
    Given I have my running application named app_sinatra_service
    Then I set app_sinatra_service environment variable RACK_ENV to development
    Then I stop my application
    Then I start my application named app_sinatra_service
    Then I should be able to access my application URL rack/env and see development
    Then I should be able to access my application file logs/stdout.log and get text including for development with backup
    When I delete my application
    Then it should not be on Cloud Foundry

  @mysql
  Scenario: sinatra test mysql service
    Given I have my running application named app_sinatra_service
    When I provision mysql service
    Then I post mysqlabc to mysql service with key abc
    Then I should be able to get from mysql service with key abc, and I should see mysqlabc
    Then I post mysql123 to mysql service with key 123
    Then I post mysqldef to mysql service with key def
    Then I delete my service
    When I delete my application
    Then it should not be on AppCloud

  @redis
  Scenario: sinatra test redis service
    Given I have my running application named app_sinatra_service
    When I provision redis service
    Then I post redisabc to redis service with key abc
    Then I should be able to get from redis service with key abc, and I should see redisabc
    Then I post redis123 to redis service with key 123
    Then I post redisdef to redis service with key def
    Then I delete my service
    When I delete my application
    Then it should not be on AppCloud

  @mongodb
  Scenario: sinatra test mongodb service
    Given I have my running application named app_sinatra_service
    When I provision mongodb service
    Then I post mongoabc to mongo service with key abc
    Then I should be able to get from mongo service with key abc, and I should see mongoabc
    Then I post mongo123 to mongo service with key 123
    Then I post mongodef to mongo service with key def
    Then I delete my service
    When I delete my application
    Then it should not be on AppCloud

  @rabbitmq
  Scenario: sinatra test rabbitmq service
    Given I have my running application named app_sinatra_service
    When I provision rabbitmq service
    Then I post rabbitabc to rabbitmq service with key abc
    Then I should be able to get from rabbitmq service with key abc, and I should see rabbitabc
    Then I post rabbitabc to rabbitmq service with key abc
    Then I post rabbit123 to rabbitmq service with key 123
    Then I post rabbitdef to rabbitmq service with key def
    Then I delete my service
    When I delete my application
    Then it should not be on AppCloud

  @postgresql
  Scenario: sinatra test postgresql service
    Given I have my running application named app_sinatra_service
    When I provision postgresql service
    Then I post postgresqlabc to postgresql service with key abc
    Then I should be able to get from postgresql service with key abc, and I should see postgresqlabc
    Then I post postgresql123 to postgresql service with key 123
    Then I post postgresqldef to postgresql service with key def
    Then I delete my service
    When I delete my application
    Then it should not be on AppCloud
