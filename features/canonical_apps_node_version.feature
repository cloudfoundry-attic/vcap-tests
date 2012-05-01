# The canonical_apps_* tests can be explicitly run via "bundle exec cucumber"
# using "--tags @canonical" on the command line or setting CUCUMBER_OPTIONS
# environment variable when invoking rake tasks.
# Combinations of app(s)/service(s) can now be chosen by combining tags.
# If not passing "--tags ~@delete" the services and apps are
# deleted during the run, and if passed the apps and provisioned services
# are left running at the end of the run.
# To select only one app to run, or a combination app and services use:
# --tags @canonical --tags @node
# --tags @canonical --tags @spring --tags @mysql,postgresql
# --tags @canonical --tags @spring --tags @postgresql --tags ~@delete

@canonical @node
Feature: Deploy the node app with different versions and dependencies

  As a user with all canonical apps
  I want to deploy node apps with different version

  Background: deploying canonical service
    Given I have registered and logged in

  @versions
  Scenario: node test deploy app version04
    Given I have deployed my application named app_node_version04
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application root and see it's running version v0.4.12
    When I delete my application
    Then it should not be on AppCloud

  @versions
  Scenario: node test deploy app version06
    Given I have deployed my application named app_node_version06
    When I query status of my application
    Then I should get the state of my application
    Then I should be able to access my application root and see it's running version v0.6.8
    When I delete my application
    Then it should not be on AppCloud
