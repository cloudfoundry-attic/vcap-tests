Feature: Use Clojure on AppCloud
  As a Clojure user of AppCloud
  I want to be able to deploy and manage Clojure applications

  Background: Authentication
    Given I have registered and logged in

  @creates_simple_clojure_app
  Scenario: Deploy Simple Clojure Application
    Given I have deployed a simple Clojure application
    Then it should be available for use
