@smoke
Feature: Control the life-cycle of an application on AppCloud

  As a user of AppCloud
  I want to create, query status of, start, stop, and delete an application

  Background: Application creation
    Given I have registered and logged in

      @creates_simple_app
      Scenario: create application
        When I create a simple application
        Then I should have my application on AppCloud
        But it should not be started

      @creates_simple_app
      Scenario: start application
        Given I have my simple application on AppCloud
        When I upload my application
        And I start my application
        Then it should be started
        And it should be available for use

      @creates_simple_app
      Scenario: stop application
        Given I have deployed a simple application
        When I stop my application
        Then it should be stopped
        And it should not be available for use

      @creates_simple_app
      Scenario: delete application
        Given I have my simple application on AppCloud
        When I delete my application
        Then it should not be on AppCloud

      @creates_java_app_with_delay @java
      Scenario: start java application and be able to access its contents immediately thereafter
        Given I have deployed my application named java_app_with_startup_delay
        Then it should be started
        And I should be able to immediately access the Java application through its url
