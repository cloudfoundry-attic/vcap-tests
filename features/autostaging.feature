Feature: Deploy applications that make use of autostaging

  As a user of AppCloud
  I want to launch apps that expect automatic binding of the services that they use

  Background: MySQL and PostgreSQL autostaging
    Given I have registered and logged in

      @creates_jpa_app @creates_jpa_db_adapter
      Scenario: start Spring Web application using JPA and add some records
        Given I deploy a Spring JPA application using the MySQL DB service
        When I add 3 records to the application
        Then I should have the same 3 records on retrieving all records from the application

        When I delete my application
        And I deploy a Spring JPA application using the created MySQL service
        Then I should have the same 3 records on retrieving all records from the application

      @creates_hibernate_app @creates_hibernate_db_adapter
      Scenario: start Spring Web application using Hibernate and add some records
        Given I deploy a Spring Hibernate application using the MySQL DB service
        When I add 3 records to the application
        Then I should have the same 3 records on retrieving all records from the application

        When I delete my application
        And I deploy a Spring Hibernate application using the created MySQL service
        Then I should have the same 3 records on retrieving all records from the application

      @creates_grails_app @creates_grails_db_adapter
      Scenario: start Spring Grails application and add some records
        Given I deploy a Spring Grails application using the MySQL DB service
        When I add 3 records to the Grails application
        Then I should have the same 3 records on retrieving all records from the Grails application

        When I delete my application
        And I deploy a Spring Grails application using the created MySQL service
        Then I should have the same 3 records on retrieving all records from the Grails application

      @creates_roo_app @creates_roo_db_adapter
      Scenario: start Spring Roo application and add some records
        Given I deploy a Spring Roo application using the MySQL DB service
        When I add 3 records to the Roo application
        Then I should have the same 3 records on retrieving all records from the Roo application

        When I delete my application
        And I deploy a Spring Roo application using the created MySQL service
        Then I should have the same 3 records on retrieving all records from the Roo application

      @creates_rails3_app, @creates_rails3_db_adapter
      Scenario: start application and write data
        Given I have deployed a Rails 3 application
        Then I can add a Widget to the database

      @creates_dbrails_app, @creates_dbrails_db_adapter
      Scenario: start and test a rails db app with Gemfile that includes mysql2 gem
        Given I deploy a dbrails application using the MySQL DB service
        Then The dbrails app should work

      @creates_dbrails_broken_app, @creates_dbrails_broken_db_adapter
      Scenario: start and test a rails db app with Gemfile that DOES NOT include mysql2 or sqllite gems
        Given I deploy a broken dbrails application  using the MySQL DB service
        Then The broken dbrails application should fail

      @creates_hibernate_app @creates_hibernate_postgresql_adapter
      Scenario: start Spring Web application using Hibernate and add some records
        Given I deploy a hibernate application that is backed by the PostgreSQL database service on AppCloud
        When I add 3 records to the application
        Then I should have the same 3 records on retrieving all records from the application

        When I delete my application
        And I deploy a Spring Hibernate application using the created PostgreSQL service
        Then I should have the same 3 records on retrieving all records from the application

      @creates_auto_reconfig_test_app @creates_services
      Scenario: start Spring Web Application specifying a Cloud Service and Data Source
        Given I deploy a Spring application using a Cloud Service and Data Source
        Then the Data Source should not be auto-configured

      @creates_auto_reconfig_test_app @creates_services
      Scenario: start Spring Web Application using Service Scan and a Data Source
        Given I deploy a Spring application using Service Scan and a Data Source
        Then the Data Source should not be auto-configured
      
      @creates_auto_reconfig_test_app @creates_services
      Scenario: start Spring Web Application using a local MongoDBFactory
        Given I deploy a Spring application using a local MongoDBFactory
        Then the MongoDBFactory should be auto-configured

      @creates_auto_reconfig_test_app @creates_services
      Scenario: start Spring Web Application using a local RedisConnectionFactory
        Given I deploy a Spring application using a local RedisConnectionFactory
        Then the RedisConnectionFactory should be auto-configured

      @creates_auto_reconfig_test_app @creates_services
      Scenario: start Spring Web Application using a local RabbitConnectionFactory
        Given I deploy a Spring application using a local RabbitConnectionFactory
        Then the RabbitConnectionFactory should be auto-configured

      @creates_auto_reconfig_test_app @creates_services
      Scenario: start Spring 3.1 Hibernate application using a local DataSource
        Given I deploy a Spring 3.1 Hibernate application using a local DataSource
        Then the Hibernate SessionFactory should be auto-configured

      @creates_auto_reconfig_missing_deps_test_app
      Scenario: Start Spring Web Application with no service dependencies
        Given I deploy a Spring Web Application that has no packaged mongo, redis, rabbit, or datasource dependencies
        Then the application should start with no errors

