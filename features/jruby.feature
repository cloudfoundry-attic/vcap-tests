Feature: Use JRuby on AppCloud
  As a JRuby user of AppCloud
  I want to be able to deploy and manage JRuby applications

  Background: Authentication
    Given I have registered and logged in

  @creates_jruby18_sinatra_simple_app
  Scenario: Deploy Simple JRuby 1.8 Sinatra Application
    Given I have deployed a simple JRuby 1.8 Sinatra application
    Then it should be available for use
    And I should get JRuby version 1.8 information
    And I should get Java Runtime Environment information

  @creates_jruby19_sinatra_simple_app
  Scenario: Deploy Simple JRuby 1.9 Sinatra Application
    Given I have deployed a simple JRuby 1.9 Sinatra application
    Then it should be available for use
    And I should get JRuby version 1.9 information
    And I should get Java Runtime Environment information

  @creates_jruby19_sinatra_mysql_app
  Scenario: Deploy Simple JRuby 1.9 Sinatra MySQL Application
    Given I have deployed a simple JRuby 1.9 Sinatra application using the MySQL service
    Then it should be available for use
    And I should get JRuby version 1.9 information
    And I should get Java Runtime Environment information

  @creates_jruby18_rails3_simple_app
  Scenario: Deploy Simple JRuby 1.8 Rails3 Simple Application
    Given I have deployed a simple JRuby 1.8 Rails3 application
      Then I should get Ruby On Rails Top Page

  @creates_jruby18_rails3_mysql_app
  Scenario: Deploy Simple JRuby 1.8 Rails3 MySQL Application
    Given I have deployed a simple JRuby 1.8 Rails3 application using the MySQL service
#    Then I should get scaffolding generated index page of Message model
    Then The Message model scaffolding generated page should work
