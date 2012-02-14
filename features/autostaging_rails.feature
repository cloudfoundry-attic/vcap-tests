Feature: Deploy Rails applications that make use of autostaging

  As a user of AppCloud
  I want to launch apps that expect automatic binding of the services that they use

  Background: Rails autostaging
    Given I have registered and logged in

      @ruby @services
      Scenario: start application and write data
        Given I have deployed a Rails 3 application
        Then I can add a Widget to the database
        Then I delete all my service
        Then I delete my application

      @ruby @sanity @services
      Scenario: start and test a rails db app with Gemfile that includes mysql2 gem
        Given I deploy a dbrails application using the MySQL DB service
        Then The dbrails app should work
        Then I delete all my service
        Then I delete my application

      @ruby
      Scenario: start and test a rails db app with Gemfile that DOES NOT include mysql2 or sqllite gems
        Given I deploy a broken dbrails application  using the MySQL DB service
        Then The broken dbrails application should fail
        Then I delete all my service
        Then I delete my application

      @ruby @sanity @services
      Scenario: Rails autostaging
        Given I have deployed my application named app_rails_service_autoconfig without starting
        Then I provision redis service without restarting
        Then I provision mongodb service without restarting
        Then I provision mysql service without restarting
        Then I start my application named app_rails_service_autoconfig
        When I query status of my application
        Then I should get the state of my application
        Then I should be able to access my application root and see hello from rails
	
        Then I post mysqlabc to mysql service with key abc
        Then I should be able to get from mysql service with key abc, and I should see mysqlabc
	
        Then I post redisabc to redis service with key abc
        Then I should be able to get from redis service with key abc, and I should see redisabc

        Then I post mongoabc to mongo service with key abc
        Then I should be able to get from mongo service with key abc, and I should see mongoabc
	
        When I provision rabbitmq service
        Then I post rabbitabc to rabbitmq service with key abc
        Then I should be able to get from rabbitmq service with key abc, and I should see rabbitabc
        Then I delete my service of type mysql
	
	When I provision postgresql service
        Then I post postgresqlabc to postgresql service with key abc
        Then I should be able to get from postgresql service with key abc, and I should see postgresqlabc
        Then I delete all my service
        Then I delete my application

      @ruby
      Scenario: Rails opt-out of autostaging via config file
        Given I have deployed my application named rails_autoconfig_disabled_by_file without starting
        Then I provision redis service without restarting
        Then I provision mysql service without restarting
        Then I start my application named rails_autoconfig_disabled_by_file
        When I query status of my application
        Then I should get the state of my application
        Then I should be able to access my application root and see hello from rails
        Then I should be able to get from redis service with key connection, and I should see Connectionrefused-UnabletoconnecttoRedison127.0.0.1:6379
        Then I delete all my service
        Then I delete my application

      @ruby
      Scenario: Rails opt-out of autostaging via cf-runtime gem
        Given I have deployed my application named rails_autoconfig_disabled_by_gem without starting
        Then I provision redis service without restarting
        Then I provision mysql service without restarting
        Then I start my application named rails_autoconfig_disabled_by_gem
        When I query status of my application
        Then I should get the state of my application
        Then I should be able to access my application root and see hello from rails
        Then I should be able to get from redis service with key connection, and I should see Connectionrefused-UnabletoconnecttoRedison127.0.0.1:6379
        Then I delete all my service
        Then I delete my application
