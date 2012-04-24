# Copyright:: Copyright (c) 2011 VMware Inc.
#
@lifecycle @sinatra @ruby @services
Feature: Deploy the sinatra canonical app and test lifecycle APIs

  As a user with all canonical apps.
  I want to deploy all canonical apps and test lifecycle functions.

  Background: deploying canonical service
    Given I have registered and logged in
    Given I have deployed my application named app_sinatra_service2

  @mysql @snapshot
  Scenario: Take mysql snapshot and rollback to a certain snapshot
    Given I have my running application named app_sinatra_service2
    When I provision mysql service
    Then I check snapshot extension is enabled
    Then I post mysqlabc to mysql service with key abc
    Then I should be able to get from mysql service with key abc, and I should see mysqlabc
    When I create a snapshot of mysql service
    Then I should be able to query detail information of snapshot
    Then I should be able to find the snapshot in snapshots list for mysql service
    Then I post mysqlabc2 to mysql service with key abc
    Then I should be able to get from mysql service with key abc, and I should see mysqlabc2
    When I rollback to previous snapshot for mysql service
    Then I should be able to get from mysql service with key abc, and I should see mysqlabc
    When I delete snapshot of mysql service
    Then I should not be able to query detail information of snapshot
    Then I should not be able to find the snapshot in snapshots list for mysql service
    Then I delete my service
    Then I delete my application

  @mysql @serialized
  Scenario: Import and export serialized data for mysql service
    Given I have my running application named app_sinatra_service2
    When I provision mysql service
    Then I post mysqlabc to mysql service with key abc
    Then I should be able to get from mysql service with key abc, and I should see mysqlabc
    Then I check snapshot extension is enabled
    When I create a snapshot of mysql service
    Then I check serialized extension is enabled
    When I create a serialized URL for the snapshot of mysql service
    Then I should be able to get the URL of the snapshot for mysql service
    Then I should be able to download data from serialized URL
    Then I post mysqlabc2 to mysql service with key abc
    Then I should be able to get from mysql service with key abc, and I should see mysqlabc2
    When I import serialized data from URL of mysql service
    When I rollback to import_from_url snapshot for mysql service
    Then I should be able to get from mysql service with key abc, and I should see mysqlabc
    Then I post mysqlabc2 to mysql service with key abc
    Then I should be able to get from mysql service with key abc, and I should see mysqlabc2
    When I import serialized data from request of mysql service
    When I rollback to import_from_data snapshot for mysql service
    Then I should be able to get from mysql service with key abc, and I should see mysqlabc
    When I delete snapshot of mysql service
    Then I should not be able to get the URL of the snapshot for mysql service
    Then I should not be able to download data from serialized URL
    Then I delete my service
    Then I delete my application

  @redis @snapshot
  Scenario: Take redis snapshot and rollback to a certain snapshot
    Given I have my running application named app_sinatra_service2
    When I provision redis service
    Then I check snapshot extension is enabled
    Then I post redisabc to redis service with key abc
    Then I should be able to get from redis service with key abc, and I should see redisabc
    When I create a snapshot of redis service
    Then I should be able to query detail information of snapshot
    Then I should be able to find the snapshot in snapshots list for redis service
    Then I post redisabc2 to redis service with key abc
    Then I should be able to get from redis service with key abc, and I should see redisabc2
    When I rollback to previous snapshot for redis service
    Then I should be able to get from redis service with key abc, and I should see redisabc
    When I delete snapshot of redis service
    Then I should not be able to query detail information of snapshot
    Then I should not be able to find the snapshot in snapshots list for redis service
    Then I delete my service
    Then I delete my application

  @redis @serialized
  Scenario: Import and export serialized data for redis service
    Given I have my running application named app_sinatra_service2
    When I provision redis service
    Then I post redisabc to redis service with key abc
    Then I should be able to get from redis service with key abc, and I should see redisabc
    Then I check snapshot extension is enabled
    When I create a snapshot of redis service
    Then I check serialized extension is enabled
    When I create a serialized URL for the snapshot of redis service
    Then I should be able to get the URL of the snapshot for redis service
    Then I should be able to download data from serialized URL
    Then I post redisabc2 to redis service with key abc
    Then I should be able to get from redis service with key abc, and I should see redisabc2
    When I import serialized data from URL of redis service
    When I rollback to import_from_url snapshot for redis service
    Then I should be able to get from redis service with key abc, and I should see redisabc
    Then I post redisabc2 to redis service with key abc
    Then I should be able to get from redis service with key abc, and I should see redisabc2
    When I import serialized data from request of redis service
    When I rollback to import_from_data snapshot for redis service
    Then I should be able to get from redis service with key abc, and I should see redisabc
    When I delete snapshot of redis service
    Then I should not be able to get the URL of the snapshot for redis service
    Then I should not be able to download data from serialized URL
    Then I delete my service
    Then I delete my application

  @mongodb @snapshot
  Scenario: Take mongodb snapshot and rollback to a certain snapshot
    Given I have my running application named app_sinatra_service2
    When I provision mongodb service
    Then I check snapshot extension is enabled
    Then I post mongodbabc to mongo service with key abc
    Then I should be able to get from mongo service with key abc, and I should see mongodbabc
    When I create a snapshot of mongodb service
    Then I should be able to query detail information of snapshot
    Then I should be able to find the snapshot in snapshots list for mongodb service
    Then I post mongodbabc2 to mongo service with key abc
    Then I should be able to get from mongo service with key abc, and I should see mongodbabc2
    When I rollback to previous snapshot for mongodb service
    Then I should be able to get from mongo service with key abc, and I should see mongodbabc
    When I delete snapshot of mongodb service
    Then I should not be able to query detail information of snapshot
    Then I should not be able to find the snapshot in snapshots list for mongodb service
    Then I delete my service
    Then I delete my application

  @mongodb @serialized
  Scenario: Import and export serialized data for mongodb service
    Given I have my running application named app_sinatra_service2
    When I provision mongodb service
    Then I post mongodbabc to mongo service with key abc
    Then I should be able to get from mongo service with key abc, and I should see mongodbabc
    Then I check snapshot extension is enabled
    When I create a snapshot of mongodb service
    Then I check serialized extension is enabled
    When I create a serialized URL for the snapshot of mongodb service
    Then I should be able to get the URL of the snapshot for mongodb service
    Then I should be able to download data from serialized URL
    Then I post mongodbabc2 to mongo service with key abc
    Then I should be able to get from mongo service with key abc, and I should see mongodbabc2
    When I import serialized data from URL of mongodb service
    When I rollback to import_from_url snapshot for mongodb service
    Then I should be able to get from mongo service with key abc, and I should see mongodbabc
    Then I post mongodbabc2 to mongo service with key abc
    Then I should be able to get from mongo service with key abc, and I should see mongodbabc2
    When I import serialized data from request of mongodb service
    When I rollback to import_from_data snapshot for mongodb service
    Then I should be able to get from mongo service with key abc, and I should see mongodbabc
    When I delete snapshot of mongodb service
    Then I should not be able to get the URL of the snapshot for mongodb service
    Then I should not be able to download data from serialized URL
    Then I delete my service
    Then I delete my application

  @postgresql @snapshot
  Scenario: Take postgresql snapshot and rollback to a certain snapshot
    Given I have my running application named app_sinatra_service2
    When I provision postgresql service
    Then I check snapshot extension is enabled
    Then I post postgresqlabc to postgresql service with key abc
    Then I should be able to get from postgresql service with key abc, and I should see postgresqlabc
    When I create a snapshot of postgresql service
    Then I should be able to query detail information of snapshot
    Then I should be able to find the snapshot in snapshots list for postgresql service
    Then I post postgresqlabc2 to postgresql service with key abc
    Then I should be able to get from postgresql service with key abc, and I should see postgresqlabc2
    When I rollback to previous snapshot for postgresql service
    Then I should be able to get from postgresql service with key abc, and I should see postgresqlabc
    When I delete snapshot of postgresql service
    Then I should not be able to query detail information of snapshot
    Then I should not be able to find the snapshot in snapshots list for postgresql service
    Then I delete my service
    Then I delete my application

  @postgresql @serialized
  Scenario: Import and export serialized data for postgresql service
    Given I have my running application named app_sinatra_service2
    When I provision postgresql service
    Then I post postgresqlabc to postgresql service with key abc
    Then I should be able to get from postgresql service with key abc, and I should see postgresqlabc
    Then I check snapshot extension is enabled
    When I create a snapshot of postgresql service
    Then I check serialized extension is enabled
    When I create a serialized URL for the snapshot of postgresql service
    Then I should be able to get the URL of the snapshot for postgresql service
    Then I should be able to download data from serialized URL
    Then I post postgresqlabc2 to postgresql service with key abc
    Then I should be able to get from postgresql service with key abc, and I should see postgresqlabc2
    When I import serialized data from URL of postgresql service
    When I rollback to import_from_url snapshot for postgresql service
    Then I should be able to get from postgresql service with key abc, and I should see postgresqlabc
    Then I post postgresqlabc2 to postgresql service with key abc
    Then I should be able to get from postgresql service with key abc, and I should see postgresqlabc2
    When I import serialized data from request of postgresql service
    When I rollback to import_from_data snapshot for postgresql service
    Then I should be able to get from postgresql service with key abc, and I should see postgresqlabc
    When I delete snapshot of postgresql service
    Then I should not be able to get the URL of the snapshot for postgresql service
    Then I should not be able to download data from serialized URL
    Then I delete my service
    Then I delete my application
