Feature: services quota/limitation verification

  @creates_postgresql_quota_service @creates_service_quota_app
  Scenario: deploy service quota application with postgresql service
    When I have postgresql max db size setting
    Given I have registered and logged in
    Given I have provisioned a postgresql service
    Given I have deployed a service quota application that is bound to this service
    Then I should be able to create a table
    Then I should be able to insert data under quota
    When I insert more data to be over quota
    Then I should not be able to insert data any more
    Then I should not be able to create objects any more
    When I delete data from the table
    Then I should be able to insert data again
    Then I should be able to create objects
