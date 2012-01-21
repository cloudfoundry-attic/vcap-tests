@canonical @sinatra @ruby @services
Feature: Deploy the sinatra canonical app and check that services can be rebound

  As a user with all canonical apps.
  I want to deploy all canonical apps and ensure all services can be rebound

  Background: Deploy canonical service for rebinding test
    Given I have registered and logged in
    Given I have deployed my application named app_sinatra_service

  @mysql
  Scenario: Verify rebinding for mysql
    Given I have my running application named app_sinatra_service
    When I provision mysql service
    Then I post mysqlabc to mysql service with key abc
    Then I should be able to get from mysql service with key abc, and I should see mysqlabc
    Then I should be able to create a table named foobar_table in the mysql service
    Then I should be able to create a function named foobar_function in the mysql service
    Then I should be able to create a procedure named foobar_procedure in the mysql service
    Then I unbind the service from my app
    Then I bind the service to my app
    Then I should be able to get from mysql service with key abc, and I should see mysqlabc
    Then I post mysqldef to mysql service with key def
    Then I should be able to get from mysql service with key def, and I should see mysqldef
    Then I should be able to drop the table named foobar_table from the mysql service
    Then I should be able to drop the function named foobar_function from the mysql service
    Then I should be able to drop the procedure named foobar_procedure from the mysql service

  @mysql
  Scenario: Cleanup after verifying rebinding for mysql
    Then I delete my service

  @postgresql
  Scenario: Verify rebinding for postgresql
    Given I have my running application named app_sinatra_service
    When I provision postgresql service
    Then I post postgresqlabc to postgresql service with key abc
    Then I should be able to get from postgresql service with key abc, and I should see postgresqlabc
    Then I should be able to create a table named foobar_table in the postgresql service
    Then I should be able to create a function named foobar_function in the postgresql service
    Then I should be able to create a sequence named foobar_sequence in the postgresql service
    ## Uncomment the following lines to break the BVT :-(
    ## Then I unbind the service from my app
    ## Then I bind the service to my app
    Then I should be able to get from postgresql service with key abc, and I should see postgresqlabc
    Then I post postgresqldef to postgresql service with key def
    Then I should be able to get from postgresql service with key def, and I should see postgresqldef
    Then I should be able to drop the table named foobar_table from the postgresql service
    Then I should be able to drop the function named foobar_function from the postgresql service
    Then I should be able to drop the sequence named foobar_sequence from the postgresql service

  @postgresql @delete
  Scenario: Cleanup after verifying rebinding for postgresql
    Then I delete my service

  @delete @delete_app
  Scenario: Clean up app after testing service rebinding
    Given I have my running application named app_sinatra_service
    When I delete my application
    Then it should not be on AppCloud
