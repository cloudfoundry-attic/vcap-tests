Feature: Ensure that Rack Applications are fully supported on AppCloud

  As a user of AppCloud
  I want to create applications using bare rack framework bare

  Background: Rack Application creation
    Given I have registered and logged in

      @creates_rack_app
      Scenario: start and test a rack app with Gemfile
        Given I have deployed a rack application
        Then The rack app should work
