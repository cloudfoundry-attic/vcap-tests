Feature: UAA Service
  As a deployer of Cloud Foundry
  I want to be sure that the UAA Service is available

  Background: Setup base URL
    Given I know the UAA service base URL

    @uaa @smoke
    Scenario: Get login prompts
      When I get the login prompts
      Then the content should contain prompts

    @uaa @smoke
    Scenario: Get Users data
      When I try and get the user data
      Then the response should be 403
