# The canonical_apps_* tests can be explicitly run via "bundle exec cucumber"
# using "--tags @canonical" on the command line or setting CUCUMBER_OPTIONS
# environment variable when invoking rake tasks.
# Combinations of app(s)/service(s) can now be chosen by combining tags.
# If not passing "--tags ~@delete" the services and apps are
# deleted during the run, and if passed the apps and provisioned services
# are left running at the end of the run.
# To select only one app to run, or a combination app and services use:
# --tags @canonical --tags @rails
# --tags @canonical --tags @spring --tags @mysql,postgresql
# --tags @canonical --tags @spring --tags @postgresql --tags ~@delete

@canonical @rails
Feature: Deploy the rails canonical app with different version

  As a user with all canonical apps
  I want to deploy rails apps with different version

  Background: deploying canonical service
    Given I have registered and logged in

  @versions
  Scenario: rails test deploy app version18
    Given I have deployed my application named app_rails_version18
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application root and see it's running version 1.8.7
    When I delete my application
    Then it should not be on AppCloud

  @versions
  Scenario: rails test deploy app version19
    Given I have deployed my application named app_rails_version19
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application root and see it's running version 1.9.2
    When I delete my application
    Then it should not be on AppCloud
