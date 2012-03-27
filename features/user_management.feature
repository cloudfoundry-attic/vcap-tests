@smoke
Feature: User registration with and establishment of an authentication token with AppCloud

   In order to track service and resource usage
   As the AppCloud service provider
   I want users to register and login to use AppCloud.

   Scenario: Register user
     Given I am a new user to AppCloud
     When I register
     Then I should be able to login to AppCloud.

   Scenario: User account access
     Given I am registered
     When I login
     Then I should get an authentication token that I need to use with all subsequent AppCloud requests
     Then I should be able to change my password

   Scenario: Reset user authentication token
     Given I have registered and logged in
     When I login
     Then I should get a new authentication token that I need to use for all subsequent AppCloud requests
