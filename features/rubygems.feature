@sinatra @smoke @ruby @rubygems
Feature: Deploy the sinatra app with specified gem dependencies

  As a user of Cloud Foundry
  I want to deploy Ruby apps and have gems properly installed

  Background: Logging in to Cloud Foundry
    Given I have registered and logged in

  Scenario: sinatra test deploy app with gem containing invalid date
    Given I have deployed my application named broken_gem_app
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application root and see hello from sinatra
    When I delete my application
    Then it should not be on Cloud Foundry

  Scenario: sinatra test deploy app without specifying BUNDLE_WITHOUT
    Given I have deployed my application named sinatra_gem_groups
    # Verify test gems are not installed by default
    Then I should be able to access my application file logs/staging.log and not get text including Adding rspec-2.11.0.gem to app
    Then I should be able to access my application file app/.bundle/config and get text including BUNDLE_WITHOUT: test
    Then I should be able to access my application root and see hello from sinatra
    When I delete my application
    Then it should not be on Cloud Foundry

  Scenario: sinatra test deploy app specifying BUNDLE_WITHOUT
    Given I have deployed my application named sinatra_gem_groups without starting
    Then I set sinatra_gem_groups environment variable BUNDLE_WITHOUT to development
    Then I start my application named sinatra_gem_groups
    # Verify gem belonging to test and development group is installed and gem belonging only to development group is not
    Then I should be able to access my application file logs/staging.log and get text including Adding thor-0.15.4.gem to app
    Then I should be able to access my application file logs/staging.log and not get text including Adding rubyzip-0.9.9.gem to app
    Then I should be able to access my application file app/.bundle/config and get text including BUNDLE_WITHOUT: development
    Then I should be able to access my application root and see hello from sinatra
    When I delete my application
    Then it should not be on Cloud Foundry

  Scenario: sinatra test deploy app setting BUNDLE_WITHOUT to multiple groups
    Given I have deployed my application named sinatra_gem_groups without starting
    Then I set sinatra_gem_groups environment variable BUNDLE_WITHOUT to development:test
    Then I start my application named sinatra_gem_groups
    # Verify gems belonging to test and/or development groups are not installed
    Then I should be able to access my application file logs/staging.log and not get text including Adding thor-0.15.4.gem to app
    Then I should be able to access my application file logs/staging.log and not get text including Adding rubyzip-0.9.9.gem to app
    Then I should be able to access my application file logs/staging.log and not get text including Adding rspec-2.11.0.gem to app
    Then I should be able to access my application file app/.bundle/config and get text including BUNDLE_WITHOUT: development:test
    Then I should be able to access my application root and see hello from sinatra
    When I delete my application
    Then it should not be on Cloud Foundry

  Scenario: sinatra test deploy app setting BUNDLE_WITHOUT blank to override default
    Given I have deployed my application named sinatra_gem_groups without starting
    Then I set sinatra_gem_groups environment variable BUNDLE_WITHOUT to
    Then I start my application named sinatra_gem_groups
    # Verify gems belonging to all groups are installed
    Then I should be able to access my application file logs/staging.log and get text including Adding thor-0.15.4.gem to app
    Then I should be able to access my application file logs/staging.log and get text including Adding rubyzip-0.9.9.gem to app
    Then I should be able to access my application file logs/staging.log and get text including Adding rspec-2.11.0.gem to app
    Then I should be able to access my application file app/.bundle/config and not get text including BUNDLE_WITHOUT
    Then I should be able to access my application root and see hello from sinatra
    When I delete my application
    Then it should not be on Cloud Foundry

  Scenario: sinatra test deploy app with Gemfile.lock containing Windows versions
    Given I have deployed my application named sinatra_windows_gemfile
    # Verify gem for mswin platform is not installed
    Then I should be able to access my application file logs/staging.log and not get text including Adding yajl-ruby-0.8.3.gem to app
    # Verify non-Windows versions of gems are installed
    Then I should be able to access my application file logs/staging.log and get text including Adding mysql2-0.3.11.gem to app
    Then I should be able to access my application file logs/staging.log and get text including Adding pg-0.14.0.gem to app
    # mysql2 and pg gems had Windows-specific versions in Gemfile.lock.  Make sure we can use them.
    When I provision mysql service
    Then I post mysqlabc to mysql service with key abc
    Then I should be able to get from mysql service with key abc, and I should see mysqlabc
    Then I delete my service
    When I provision postgresql service
    Then I post postgresqlabc to postgresql service with key abc
    Then I should be able to get from postgresql service with key abc, and I should see postgresqlabc
    Then I delete my service
    When I delete my application
    Then it should not be on Cloud Foundry

  Scenario: sinatra test deploy app containing gems specifying a ruby platform
    Given I have deployed my application named sinatra_gem_groups
    # Verify gem for ruby_18 platform is installed, ruby_19 gem is not
    Then I should be able to access my application file logs/staging.log and get text including Adding uglifier-1.2.6.gem to app
    Then I should be able to access my application file logs/staging.log and not get text including Adding yajl-ruby-0.8.3.gem to app
    Then I should be able to access my application root and see hello from sinatra
    When I delete my application
    Then it should not be on Cloud Foundry

  Scenario: sinatra test deploy app with git gems using ruby19
    Given I have deployed my application named git_gems_app_ruby19
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application root and see hello from git
    When I delete my application
    Then it should not be on Cloud Foundry

  Scenario: sinatra test deploy app with git gems using ruby18
    Given I have deployed my application named git_gems_app_ruby18
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application root and see hello from git
    When I delete my application
    Then it should not be on Cloud Foundry
