@smoke
Feature: Play! application support

  As a user of Cloud Foundry
  I want to launch Play! apps

  Background: Play! app support
    Given I have registered and logged in

  Scenario: Deploy Play Application with postgres auto-reconfiguration
    Given that the postgresql service is available
    Given I have deployed my application named play_computer_database_scala_app without starting
    Then I provision postgresql service without restarting
    Then I start my application named play_computer_database_scala_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application URL computers
    Then I should be able to access my application file logs/stdout.log and get text including Auto-reconfiguring default
    Then I should be able to access my application file logs/stdout.log and get text including database [default] connected at jdbc:postgresql
    Then I delete all my service
    Then I delete my application

  Scenario: Deploy Play Application with mysql auto-reconfiguration
    Given I have deployed my application named play_todolist_app without starting
    Then I provision mysql service without restarting
    Then I start my application named play_todolist_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application URL tasks
    Then I should be able to access my application file logs/stdout.log and get text including Auto-reconfiguring default
    Then I should be able to access my application file logs/stdout.log and get text including database [default] connected at jdbc:mysql
    Then I delete all my service
    Then I delete my application

  Scenario: Deploy Play Application using cloud properties for mysql configuration by service type
    Given I have deployed my application named play_zentasks_cf_by_type_app without starting
    Then I provision mysql service without restarting
    Then I start my application named play_zentasks_cf_by_type_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application URL login
    Then I should be able to access my application file logs/stdout.log and get text including Found cloud properties in configuration.  Auto-reconfiguration disabled.
    Then I should be able to access my application file logs/stdout.log and get text including database [default] connected at jdbc:mysql
    Then I should be able to list application files and not find file app/lib/mysql-connector-java-5.1.12-bin.jar
    Then I delete all my service
    Then I delete my application

  Scenario: Deploy Play Application using cloud properties for postgresql configuration by service type
    Given that the postgresql service is available
    Given I have deployed my application named play_computer_database_cf_by_type_app without starting
    Then I provision postgresql service without restarting
    Then I start my application named play_computer_database_cf_by_type_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application URL computers
    Then I should be able to access my application file logs/stdout.log and get text including Found cloud properties in configuration.  Auto-reconfiguration disabled.
    Then I should be able to access my application file logs/stdout.log and get text including database [default] connected at jdbc:postgresql
    Then I should be able to list application files and not find file app/lib/postgresql-9.0-801.jdbc4.jar
    Then I delete all my service
    Then I delete my application

  Scenario: Deploy Play Application using cloud properties for mysql configuration by service name
    Given I have deployed my application named play_zentasks_cf_by_name_app without starting
    Then I provision mysql service without restarting
    Then I start my application named play_zentasks_cf_by_name_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application URL login
    Then I should be able to access my application file logs/stdout.log and get text including Found cloud properties in configuration.  Auto-reconfiguration disabled.
    Then I should be able to access my application file logs/stdout.log and get text including database [default] connected at jdbc:mysql
    Then I should be able to list application files and not find file app/lib/mysql-connector-java-5.1.12-bin.jar
    Then I delete all my service
    Then I delete my application

  Scenario: Deploy Play Application using cloud properties for postgresql configuration by service name
    Given that the postgresql service is available
    Given I have deployed my application named play_computer_database_cf_by_name_app without starting
    Then I provision postgresql service without restarting
    Then I start my application named play_computer_database_cf_by_name_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application URL computers
    Then I should be able to access my application file logs/stdout.log and get text including Found cloud properties in configuration.  Auto-reconfiguration disabled.
    Then I should be able to access my application file logs/stdout.log and get text including database [default] connected at jdbc:postgresql
    Then I should be able to list application files and not find file app/lib/postgresql-9.0-801.jdbc4.jar
    Then I delete all my service
    Then I delete my application

  Scenario: Deploy Play Application with auto-reconfiguration disabled
    Given that the postgresql service is available
    Given I have deployed my application named play_computer_database_autoconfig_disabled_app without starting
    Then I provision postgresql service without restarting
    Then I start my application named play_computer_database_autoconfig_disabled_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application URL computers
    Then I should be able to access my application file logs/stdout.log and get text including User disabled auto-reconfiguration
    Then I should be able to access my application file logs/stdout.log and get text including database [default] connected at jdbc:h2
    Then I delete all my service
    Then I delete my application

  Scenario: Deploy Play Application using cloudfoundry-runtime lib
    Given I have deployed my application named play_todolist_with_cfruntime_app without starting
    Then I provision mysql service without restarting
    Then I start my application named play_todolist_with_cfruntime_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application URL tasks
    Then I should be able to access my application file logs/stdout.log and get text including Found cloudfoundry-runtime lib.  Auto-reconfiguration disabled
    Then I should be able to access my application file logs/stdout.log and get text including database [default] connected at jdbc:h2
    Then I delete all my service
    Then I delete my application

  Scenario: Deploy Play Application with multiple database services, one named production
    Given that the postgresql service is available
    Given I have deployed my application named play_computer_database_scala_app without starting
    Then I provision postgresql service without restarting
    Then I provision a postgresql service named play-comp-db-app-production without restarting
    Then I start my application named play_computer_database_scala_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application URL computers
    Then I should be able to access my application file logs/stdout.log and get text including Auto-reconfiguring default
    Then I should be able to access my application file logs/stdout.log and get text including database [default] connected at jdbc:postgresql
    Then I delete all my service
    Then I delete my application

  Scenario: Deploy Play Application with multiple database services
    Given that the postgresql service is available
    Given I have deployed my application named play_computer_database_scala_app without starting
    Then I provision postgresql service without restarting
    Then I provision mysql service without restarting
    Then I start my application named play_computer_database_scala_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application URL computers
    Then I should be able to access my application file logs/stdout.log and get text including Found 0 or multiple database services bound to app.  Skipping auto-reconfiguration
    Then I should be able to access my application file logs/stdout.log and get text including database [default] connected at jdbc:h2
    Then I delete all my service
    Then I delete my application

  Scenario: Deploy Play Application with multiple Play databases
    Given that the postgresql service is available
    Given I have deployed my application named play_computer_database_multi_dbs_app without starting
    Then I provision postgresql service without restarting
    Then I start my application named play_computer_database_multi_dbs_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application URL computers
    Then I should be able to access my application file logs/stdout.log and get text including Found multiple databases in Play configuration.  Skipping auto-reconfiguration
    Then I should be able to access my application file logs/stdout.log and get text including database [default] connected at jdbc:h2
    Then I delete all my service
    Then I delete my application

  Scenario: Deploy Play Application with mysql JPA auto-reconfiguration
    Given I have deployed my application named play_computer_database_jpa_mysql_app without starting
    Then I provision mysql service without restarting
    Then I start my application named play_computer_database_jpa_mysql_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application URL computers
    Then I should be able to access my application file logs/stdout.log and get text including Auto-reconfiguring default
    Then I should be able to access my application file logs/stdout.log and get text including database [default] connected at jdbc:mysql
    Then I delete all my service
    Then I delete my application

  Scenario: Deploy Play Application with postgresql JPA auto-reconfiguration
    Given that the postgresql service is available
    Given I have deployed my application named play_computer_database_jpa_app without starting
    Then I provision postgresql service without restarting
    Then I start my application named play_computer_database_jpa_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application URL computers
    Then I should be able to access my application file logs/stdout.log and get text including Auto-reconfiguring default
    Then I should be able to access my application file logs/stdout.log and get text including database [default] connected at jdbc:postgresql
    Then I delete all my service
    Then I delete my application



