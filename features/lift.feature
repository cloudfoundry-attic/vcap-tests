Feature: Use Scala / Lift on AppCloud
  As a user of AppCloud
  I want to launch Scala / Lift apps that expect automatic binding of the services that they use

  Background: MySQL autostaging
    Given I have registered and logged in

  @creates_simple_lift_app @jvm
  Scenario: deploy simple Scala / Lift Application
    Given I have deployed a simple Lift application
    Then the Lift app should be available for use
    Then I delete my application

  @creates_lift_db_app @creates_lift_db_adapter @jvm @services
  Scenario: start Scala / Lift application and add some records
    Given I deploy a Lift application using the MySQL DB service
    When I add 3 records to the Lift application
    Then I should have the same 3 records on retrieving all records from the Lift application

    When I delete my application
    And I deploy a Lift application using the created MySQL service
    Then I should have the same 3 records on retrieving all records from the Lift application
    Then I delete my service
    Then I delete my application


