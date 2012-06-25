@imagemagick
Feature: ImageMagick support

  As a user of Cloud Foundry
  I want to deploy applications that use ImageMagick

  Background: ImageMagick and RMagick apps
    Given I have registered and logged in

  Scenario: Deploy application that uses ImageMagick tools
    Given I have deployed my application named node_imagemagick
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application root and see hello from imagemagick
    Then I delete my application

  Scenario: Deploy application that uses RMagick
    Given I have deployed my application named sinatra_rmagick
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application root and see hello from rmagick
    Then I delete my application
