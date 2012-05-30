Feature: Range request support

  As a user of Cloud Foundry
  I want to be able to retrieve portions of my files

  Background: Range request support
    Given I have registered and logged in
    Given I have deployed my application named simple_app

  Scenario: Request with a partially specified range
    When I request a file named foo.rb with the range '-10'
    Then I should get back the final 10 bytes of the file.

  Scenario: Request with a fully specified range
    When I request a file named foo.rb with the range '10-20'
    Then I should get back bytes 10-20 of the file.