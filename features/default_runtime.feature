@default_runtime_info @sanity @smoke
Feature: Expose default runtime info.

  I want to get information of a default runtime per supported frameworks.

  Background: Authentication
    Given I have registered and logged in

  Scenario: sinatra framework test
    When I query sinatra framework information
    Then I should get ruby18 as a default runtime of sinatra framework

  Scenario: rails3 framework test
    When I query rails3 framework information
    Then I should get ruby18 as a default runtime of rails3 framework

  Scenario: rack framework test
    When I query rack framework information
    Then I should get ruby18 as a default runtime of rack framework

  Scenario: node framework test
    When I query node framework information
    Then I should get node as a default runtime of node framework

  Scenario: java_web framework test
    When I query java_web framework information
    Then I should get java as a default runtime of java_web framework

  Scenario: spring framework test
    When I query spring framework information
    Then I should get java as a default runtime of spring framework

  Scenario: grails framework test
    When I query grails framework information
    Then I should get java as a default runtime of grails framework

  Scenario: lift framework test
    When I query lift framework information
    Then I should get java as a default runtime of lift framework

  Scenario: play famework test
    When I query play framework information
    Then I should get java as a default runtime of play framework

  Scenario: otp_rebar framework test
    When I query otp_rebar framework information
    Then I should get erlangR14B02 as a default runtime of otp_rebar framework

  Scenario: wsgi framework test
    When I query wsgi framework information
    Then I should get python2 as a default runtime of wsgi framework

  Scenario: django framework test
    When I query django framework information
    Then I should get python2 as a default runtime of django framework

  Scenario: php framework test
    When I query php framework information
    Then I should get php as a default runtime of php framework

  Scenario: standalone framework test
    When I query standalone framework information
    Then I should not get any default runtime of standalone framework

