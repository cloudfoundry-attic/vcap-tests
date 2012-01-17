Feature: Deploy applications that make use of autostaging

  As a user of AppCloud
  I want to launch apps that expect automatic binding of the services that they use

  Background: MySQL and PostgreSQL autostaging
    Given I have registered and logged in

      @creates_rails3_app, @creates_rails3_db_adapter @ruby @services
      Scenario: start application and write data
        Given I have deployed a Rails 3 application
        Then I can add a Widget to the database

      @creates_dbrails_app, @creates_dbrails_db_adapter @ruby @sanity @services
      Scenario: start and test a rails db app with Gemfile that includes mysql2 gem
        Given I deploy a dbrails application using the MySQL DB service
        Then The dbrails app should work

      @creates_dbrails_broken_app, @creates_dbrails_broken_db_adapter @ruby
      Scenario: start and test a rails db app with Gemfile that DOES NOT include mysql2 or sqllite gems
        Given I deploy a broken dbrails application  using the MySQL DB service
        Then The broken dbrails application should fail