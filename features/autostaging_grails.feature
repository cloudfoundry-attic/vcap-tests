Feature: Deploy applications that make use of autostaging

  As a user of AppCloud
  I want to launch apps that expect automatic binding of the services that they use

  Background: MySQL and PostgreSQL autostaging
    Given I have registered and logged in
      @creates_grails_app @creates_grails_db_adapter @jvm @services
      Scenario: start Spring Grails application and add some records
        Given I deploy a Spring Grails application using the MySQL DB service
        When I add 3 records to the Grails application
        Then I should have the same 3 records on retrieving all records from the Grails application

        When I delete my application
        And I deploy a Spring Grails application using the created MySQL service
        Then I should have the same 3 records on retrieving all records from the Grails application