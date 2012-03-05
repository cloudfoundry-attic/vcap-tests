Feature: Deploy standalone applications that make use of autostaging

  As a user of Cloud Foundry
  I want to launch apps that expect automatic binding of the services that they use

  Background: standalone autostaging
    Given I have registered and logged in

      @ruby @sanity @services
      Scenario: standalone ruby18 autostaging
        Given I have deployed a standalone application with runtime ruby18 named standalone_ruby18_autoconfig
        When I query status of my application
        Then I should get the state of my application
        Then I should be able to access my application root and see hello from sinatra
        Then I should be able to access crash and it should crash
        When I provision mysql service
        Then I post mysqlabc to mysql service with key abc
        Then I should be able to get from mysql service with key abc, and I should see mysqlabc
        Then I delete my service
        When I provision redis service
        Then I post redisabc to redis service with key abc
        Then I should be able to get from redis service with key abc, and I should see redisabc
        When I provision mongodb service
        Then I post mongoabc to mongo service with key abc
        Then I should be able to get from mongo service with key abc, and I should see mongoabc
        When I provision rabbitmq service
        Then I post rabbitabc to rabbitmq service with key abc
        Then I should be able to get from rabbitmq service with key abc, and I should see rabbitabc
        When I provision postgresql service
        Then I post postgresqlabc to postgresql service with key abc
        Then I should be able to get from postgresql service with key abc, and I should see postgresqlabc
        Then I delete all my service
        Then I delete my application

      @ruby
      Scenario: standalone ruby 19 autostaging
        Given I have deployed a standalone application with runtime ruby19 named standalone_ruby19_autoconfig
       When I query status of my application
        Then I should get the state of my application
        Then I should be able to access my application root and see hello from sinatra
        Then I should be able to access crash and it should crash
        When I provision mysql service
        Then I post mysqlabc to mysql service with key abc
        Then I should be able to get from mysql service with key abc, and I should see mysqlabc
        Then I delete my service
        When I provision redis service
        Then I post redisabc to redis service with key abc
        Then I should be able to get from redis service with key abc, and I should see redisabc
        When I provision mongodb service
        Then I post mongoabc to mongo service with key abc
        Then I should be able to get from mongo service with key abc, and I should see mongoabc
        When I provision rabbitmq service
        Then I post rabbitabc to rabbitmq service with key abc
        Then I should be able to get from rabbitmq service with key abc, and I should see rabbitabc
        When I provision postgresql service
        Then I post postgresqlabc to postgresql service with key abc
        Then I should be able to get from postgresql service with key abc, and I should see postgresqlabc
        Then I delete all my service
        Then I delete my application

      @ruby
      Scenario: standalone ruby opt-out of autostaging via config file
        Given I have deployed a standalone application with runtime ruby18 named standalone_ruby_autoconfig_disabled_by_file
        When I query status of my application
        Then I should get the state of my application
        Then I should be able to access my application root and see hello from sinatra
        When I provision redis service
        Then I should be able to get from redis service with key connection, and I should see Connectionrefused-UnabletoconnecttoRedison127.0.0.1:6379
        Then I delete all my service
        Then I delete my application

      @ruby
      Scenario: standalone ruby opt-out of autostaging via cf-runtime gem
        Given I have deployed a standalone application with runtime ruby18 named standalone_ruby_autoconfig_disabled_by_gem
        When I query status of my application
        Then I should get the state of my application
        Then I should be able to access my application root and see hello from sinatra
        When I provision redis service
        Then I should be able to get from redis service with key connection, and I should see Connectionrefused-UnabletoconnecttoRedison127.0.0.1:6379
        Then I delete all my service
        Then I delete my application
