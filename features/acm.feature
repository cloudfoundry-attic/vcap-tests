Feature: ACM Service
  As a deployer of Cloud Foundry
  I want to be sure that the ACM Service is available

  Background: Setup base URL
    Given I know the ACM service base URL
    And I have the ACM credentials

    @acm @smoke
    Scenario: Test ACM login credentials
      Then a simple GET to the ACM should return a 404

    @acm @smoke
    Scenario: Exercise the API
      Given that test data has been cleaned up
      When I have been able to create a permission set
      And I have created some users
      And I have those users to some groups
      Then I try to create an object
      Then I should be able to check the user's access rights
      And I should be able to check the group's access rights
