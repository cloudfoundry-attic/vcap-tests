Feature: Deploy applications that make use of autostaging

  As a user of AppCloud
  I want to launch apps that expect automatic binding of the services that they use

  Background: MySQL and PostgreSQL autostaging
    Given I have registered and logged in

      @creates_jpa_app @creates_jpa_db_adapter @java @services
      Scenario: start Spring Web application using JPA and add some records
        Given I deploy a Spring JPA application using the MySQL DB service
        When I add 3 records to the application
        Then I should have the same 3 records on retrieving all records from the application

        When I delete my application
        And I deploy a Spring JPA application using the created MySQL service
        Then I should have the same 3 records on retrieving all records from the application
        Then I delete all my service
        Then I delete my application

      @creates_hibernate_app @creates_hibernate_db_adapter @java @sanity @services
      Scenario: start Spring Web application using Hibernate and add some records
        Given I deploy a Spring Hibernate application using the MySQL DB service
        When I add 3 records to the application
        Then I should have the same 3 records on retrieving all records from the application

        When I delete my application
        And I deploy a Spring Hibernate application using the created MySQL service
        Then I should have the same 3 records on retrieving all records from the application
        Then I delete all my service
        Then I delete my application

      @creates_roo_app @creates_roo_db_adapter @java @services
      Scenario: start Spring Roo application and add some records
        Given I deploy a Spring Roo application using the MySQL DB service
        When I add 3 records to the Roo application
        Then I should have the same 3 records on retrieving all records from the Roo application

        When I delete my application
        And I deploy a Spring Roo application using the created MySQL service
        Then I should have the same 3 records on retrieving all records from the Roo application
        Then I delete all my service
        Then I delete my application

      @creates_hibernate_app @creates_hibernate_postgresql_adapter @java @sanity @services
      Scenario: start Spring Web application using Hibernate and add some records
        Given I deploy a hibernate application that is backed by the PostgreSQL database service on AppCloud
        When I add 3 records to the application
        Then I should have the same 3 records on retrieving all records from the application

        When I delete my application
        And I deploy a Spring Hibernate application using the created PostgreSQL service
        Then I should have the same 3 records on retrieving all records from the application
        Then I delete all my service
        Then I delete my application

