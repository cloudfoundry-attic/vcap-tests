@java @versions
Feature: Deploy jvm apps with different versions

  As a user with all canonical apps
  I want to deploy java apps with different versions

  Background: deploying canonical service
    Given I have registered and logged in

  @spring @mysql
  Scenario: java test deploy app using java 6
    Given I have deployed my application named app_spring_service
    Then I should be able to get java version, and I should see 1.6
    When I provision mysql service
    Then I post mysqlabc to mysql service with key abc
    Then I should be able to get from mysql service with key abc, and I should see mysqlabc
    Then I delete my service
    When I delete my application
    Then it should not be on AppCloud

  @spring @mysql
  Scenario: java test deploy app using java 7
    Given I have Java 7 runtime available
      And I have deployed my application named app_spring_service_7
    Then I should be able to get java version, and I should see 1.7
    When I provision mysql service
    Then I post mysqlabc to mysql service with key abc
    Then I should be able to get from mysql service with key abc, and I should see mysqlabc
    Then I delete my service
    When I delete my application
    Then it should not be on AppCloud

  @grails @mysql
  Scenario: start Spring Grails application and add some records using Java 6
    Given I deploy a Spring Grails application using the MySQL DB service
    Then I should be able to get app status, and I should see 1.6 jvm version
    When I add 3 records to the Grails application
    Then I should have the same 3 records on retrieving all records from the Grails application
    Then I delete all my service
    Then I delete my application

  @grails @mysql
  Scenario: start Spring Grails application and add some records using Java 7
    Given I have Java 7 runtime available
      And I deploy a Spring Grails application using Java 7 and the MySQL DB service
    Then I should be able to get app status, and I should see 1.7 jvm version
    When I add 3 records to the Grails application
    Then I should have the same 3 records on retrieving all records from the Grails application
    Then I delete all my service
    Then I delete my application

  @play @mysql
  Scenario: Deploy Play Application using Java 6 with mysql auto-reconfiguration
    Given I have deployed my application named play_todolist_app without starting
    Then I provision mysql service without restarting
    Then I start my application named play_todolist_app
    When I query status of my application
    Then I should be able to get java version, and I should see 1.6
    Then I should get the state of my application
    Then I should be able to access my application URL tasks
    Then I should be able to access my application file logs/stdout.log and get text including Auto-reconfiguring default
    Then I should be able to access my application file logs/stdout.log and get text including database [default] connected at jdbc:mysql
    Then I delete all my service
    Then I delete my application

  @play @mysql
  Scenario: Deploy Play Application using Java 7 with mysql auto-reconfiguration
    Given I have Java 7 runtime available
      And I have deployed my application named play_todolist_app_7 without starting
    Then I provision mysql service without restarting
    Then I start my application named play_todolist_app_7
    When I query status of my application
    Then I should be able to get java version, and I should see 1.7
    Then I should get the state of my application
    Then I should be able to access my application URL tasks
    Then I should be able to access my application file logs/stdout.log and get text including Auto-reconfiguring default
    Then I should be able to access my application file logs/stdout.log and get text including database [default] connected at jdbc:mysql
    Then I delete all my service
    Then I delete my application

  @standalone
  Scenario: Deploy Standalone App with Java 6 runtime
    Given I have deployed my application named standalone_java_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application file logs/stdout.log and get text including Java version: 1.6
    Then I should be able to access my application file logs/stdout.log and get text including Hello from the cloud.  Java opts:  -Xms256m -Xmx256m -Djava.io.tmpdir=appdir/temp
    When I delete my application
    Then it should not be on Cloud Foundry

  @standalone
  Scenario: Deploy Standalone App with Java 7 runtime
    Given I have Java 7 runtime available
      And I have deployed my application named standalone_java_app_7
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application file logs/stdout.log and get text including Java version: 1.7
    Then I should be able to access my application file logs/stdout.log and get text including Hello from the cloud.  Java opts:  -Xms256m -Xmx256m -Djava.io.tmpdir=appdir/temp
    When I delete my application
    Then it should not be on Cloud Foundry
