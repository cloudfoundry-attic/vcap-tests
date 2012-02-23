Feature: Deploy applications that make use of autostaging

  As a user of AppCloud
  I want to launch apps that expect automatic binding of the services that they use

  Background: MySQL and PostgreSQL autostaging
    Given I have registered and logged in

      @creates_auto_reconfig_test_app @creates_services @java @services
      Scenario: start Spring Web Application specifying a Cloud Service and Data Source
        Given I deploy a Spring application using a Cloud Service and Data Source
        Then the Data Source should not be auto-configured
        Then I delete all my service
        Then I delete my application

      @creates_auto_reconfig_test_app @creates_services @java @services
      Scenario: start Spring Web Application using Service Scan and a Data Source
        Given I deploy a Spring application using Service Scan and a Data Source
        Then the Data Source should not be auto-configured
        Then I delete all my service
        Then I delete my application

      @creates_auto_reconfig_test_app @creates_services @java @services
      Scenario: start Spring Web Application using a local MongoDBFactory
        Given I deploy a Spring application using a local MongoDBFactory
        Then the MongoDBFactory should be auto-configured
        Then I delete all my service
        Then I delete my application

      @creates_auto_reconfig_test_app @creates_services @java @services
      Scenario: start Spring Web Application using a local RedisConnectionFactory
        Given I deploy a Spring application using a local RedisConnectionFactory
        Then the RedisConnectionFactory should be auto-configured
        Then I delete all my service
        Then I delete my application

      @creates_auto_reconfig_test_app @creates_services @java @services
      Scenario: start Spring Web Application using a local RabbitConnectionFactory
        Given I deploy a Spring application using a local RabbitConnectionFactory
        Then the RabbitConnectionFactory should be auto-configured
        Then I delete all my service
        Then I delete my application

      @creates_auto_reconfig_test_app @creates_services @java @services
      Scenario: start Spring 3.1 Hibernate application using a local DataSource
        Given I deploy a Spring 3.1 Hibernate application using a local DataSource
        Then the Hibernate SessionFactory should be auto-configured
        Then I delete all my service
        Then I delete my application

      @creates_auto_reconfig_missing_deps_test_app @java
      Scenario: Start Spring Web Application with no service dependencies
        Given I deploy a Spring Web Application that has no packaged mongo, redis, rabbit, or datasource dependencies
        Then the application should start with no errors
        Then I delete all my service
        Then I delete my application

