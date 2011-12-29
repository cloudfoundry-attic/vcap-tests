# These tests are meant to be executed as part of the bvt_upgrade run and should
# be excluded from a regular BVT run.
# They expect the canonical apps to be running and the services provisioned.
# The tests cleanup after themselves, so no apps and services
# should be left at the end of the run.
# If BVTs are run via rake tasks like "rake tests" or "rake bvt:run", the tasks
# have already been modified to exclude them.
# If BVTs are run as "bundle exec cucumber" please add "--tags ~@bvt_upgrade"
# to exclude them.

@bvt_upgrade
Feature: Check canonical app services

  As a user with all canonical apps.
  I want to check all canonical apps and use all their service

  Background: logging in
    Given I have registered and logged in

  @sinatra
  Scenario: check persistent data
     Given I have my running application named app_sinatra_service
     Then I should get on application app_sinatra_service the persisted data from redis service with key abc, and I should see redisabc
     Then I should get on application app_sinatra_service the persisted data from postgresql service with key abc, and I should see postgresqlabc
     Then I should get on application app_sinatra_service the persisted data from mongo service with key abc, and I should see mongoabc
     Then I should get on application app_sinatra_service the persisted data from mysql service with key abc, and I should see mysqlabc
     Then I should get on application app_sinatra_service the persisted data from rabbitmq service with key abc, and I should see rabbitabc

  @node
  Scenario: check persistent data
     Given I have my running application named app_node_service
     Then I should get on application app_node_service the persisted data from redis service with key abc, and I should see redisabc
     Then I should get on application app_node_service the persisted data from postgresql service with key abc, and I should see postgresqlabc
     Then I should get on application app_node_service the persisted data from mongo service with key abc, and I should see mongoabc
     Then I should get on application app_node_service the persisted data from mysql service with key abc, and I should see mysqlabc
     Then I should get on application app_node_service the persisted data from rabbitmq service with key abc, and I should see rabbitabc

  @spring
  Scenario: check persistent data
     Given I have my running application named app_spring_service
     Then I should get on application app_spring_service the persisted data from redis service with key abc, and I should see redisabc
     Then I should get on application app_spring_service the persisted data from postgresql service with key abc, and I should see postgresqlabc
     Then I should get on application app_spring_service the persisted data from mongo service with key abc, and I should see mongoabc
     Then I should get on application app_spring_service the persisted data from mysql service with key abc, and I should see mysqlabc
     Then I should get on application app_spring_service the persisted data from rabbitmq service with key abc, and I should see rabbitabc

  @rails
  Scenario: check persistent data
     Given I have my running application named app_rails_service

     Then I should get on application app_rails_service the persisted data from redis service with key abc, and I should see redisabc
     #Then I should get on application app_rails_service the persisted data from postgresql service with key abc, and I should see postgresqlabc
     Then I should get on application app_rails_service the persisted data from mongo service with key abc, and I should see mongoabc
     Then I should get on application app_rails_service the persisted data from mysql service with key abc, and I should see mysqlabc
     Then I should get on application app_rails_service the persisted data from rabbitmq service with key abc, and I should see rabbitabc

  @delete
  Scenario: delete services and canonical apps
     When I list my applications
     Then I delete all services and apps
