Feature: Update an application on AppCloud

   As a user with an application deployed on AppCloud
   I want to be able to update various aspects of the application

   Background: Application update set up
     Given I have registered and logged in
     And I have deployed a simple application

     @creates_simple_app @smoke
     Scenario: increase instance count
         When I increase the instance count of my application by 2
         Then I should have 3 instances of my application

     @creates_simple_app @smoke
     Scenario: decrease instance count
         When I increase the instance count of my application by 2
         And I decrease the instance count of my application by 1
         Then I should have 2 instances of my application

     @creates_simple_app @smoke
     Scenario: add a url for the application to respond to
         When I add a url to my application
         Then I should have 2 urls associated with my application
         And I should be able to access the application through the original url.
         And I should be able to access the application through the new url.

     @creates_simple_app
     Scenario: add a second url that differs by case
         When I add a url that differs only by case
         Then I should have 1 urls associated with my application
         And I should be able to access the application through the original url.
         And I should be able to access the application through the new url.

     @creates_simple_app @smoke
     Scenario: remove a url that the application responds to
         Given I have my application associated with '2' urls
         When I remove one of the urls associated with my application
         Then I should have 1 urls associated with my application
         And I should be able to access the application through the remaining url.
         And I should be not be able to access the application through the removed url.

     @creates_simple_app @smoke
     Scenario: change url that the application responds to
         When I add a url to my application
         And I remove the original url associated with my application
         Then I should have 1 urls associated with my application
         And I should be able to access the application through the new url.
         And I should be not be able to access the application through the original url.

       @creates_simple_app @smoke
       Scenario: redeploy application
         When I upload a modified simple application to AppCloud
         And I update my application on AppCloud
         Then my update should succeed
         And I should be able to access the updated version of my application

