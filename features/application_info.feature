@smoke
Feature: Retrieve information on an application on AppCloud

	 As a user with an application deployed on AppCloud
	 I want to be able to retrieve information on various aspects of the application

	 Background: Application information retrieval
	   Given I have registered and logged in

	   @creates_simple_app
	   Scenario: query application status
         Given I have deployed a simple application
	     When I query status of my application
	     Then I should get the state of my application

	   @creates_simple_app
       @creates_tiny_java_app @jvm
	   Scenario: list applications
         Given I have deployed a simple application
	     And I have deployed a tiny Java application
	     When I list my applications
	     Then I should get status on the simple app as well as the tiny Java application

       @creates_simple_app
       Scenario: get application files
         Given I have deployed a simple application
         When I list files associated with my application
         Then I should get a list of directories and files associated with my application on AppCloud
         And I should be able to retrieve any of the listed files

       @creates_simple_app
       Scenario: get instances information
         Given I have deployed a simple application
         And I have 2 instances of a simple application
         When I get instance information for my application
         Then I should get status on all instances of my application

       @creates_simple_app
       Scenario: get resource usage information for an application
         Given I have deployed a simple application
         When I get resource usage for my application
         Then I should get information representing my application's resource use.

       @creates_simple_app
       Scenario: get crash information for an application
         Given I have deployed a simple application
         And I that my application has a crash
         When I get crash information for my application
         Then I should be able to get the time of the crash from that information
         And I should be able to get a list of files associated with my application on AppCloud
         And I should be able to retrieve any of the listed files

       @creates_broken_app @ruby
       Scenario: get crash information for a broken application
         Given I have registered and logged in
         And I have deployed a broken application
         When I get crash information for my application
         Then I should be able to get a list of files associated with my application on AppCloud
         And I should be able to retrieve any of the listed files


