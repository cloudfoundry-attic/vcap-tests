Feature: mvstore service binding and app deployment

  In order to use mvstore in AppCloud
  As the VMC user
  I want to deploy my app against a mvstore service

  @creates_mvstore_app @creates_mvstore_service
  Scenario: Deploy mvstore
    Given I have registered and logged in
    Given I have provisioned a mvstore service
    Given I have deployed a mvstore application that is bound to this service
    When I add an answer to my mvstore application
    Then I should be able to retrieve my mvstore answer
