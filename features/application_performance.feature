Feature: Measure various performance features of an application

	 As a user of AppCloud
	 I want to measure certain performance related aspects of an application

	 Background: Application creation
	   Given I have registered and logged in

      @creates_redis_lb_app @lb_check @smoke @sanity
      Scenario: start application
        Given I have my redis lb app on AppCloud
        When I upload my application
        And I start my application
        Then it should be started
        And it's health_check entrypoint should return OK
        And after resetting all counters it should return OK and no data

        # ensure basic operation works fine with a single instance
        When I execute /incr 10 times
        Then the sum of all instance counts should be 10
        And after resetting all counters it should return OK and no data

        # ensure basic operation works fine with multiple instances
        When I increase the instance count of my application by 4
        Then I should have 5 instances of my application
        When I execute /incr 150 times
        Then the sum of all instance counts should be 150
        And all 5 instances should participate
        And all 5 instances should do within 55 percent of their fair share of the 150 operations
        And after resetting all counters it should return OK and no data
        Then I delete all my service
        Then I delete my application

      @creates_env_test_app @env_test_check @smoke
      Scenario: start application
        Given I have my env_test app on AppCloud
        When I upload my application
        And I start my application
        Then it should be started
        Then it should be bound to the right services
        And env_test's health_check entrypoint should return OK
        Then I delete all my service
        Then I delete my application

      @creates_env_test_app @env_test_check
      Scenario: start application
        Given The appcloud instance has a set of available services
        Given I have my mozyatmos app on AppCloud
        When I upload my application
        And I start my application
        Then it should be started
        Then it should be bound to an atmos service
        And env_test's health_check entrypoint should return OK
        Then I delete all my service
        Then I delete my application

      @smoke
      Scenario: start application
        Given The appcloud instance has a set of available frameworks
        Given The foo framework is not supported on appcloud
        Given The rails3 framework is supported on appcloud
        Given The node framework is supported on appcloud
        Given The spring framework is supported on appcloud
        Given The grails framework is supported on appcloud
        Given The sinatra framework is supported on appcloud
        Given The java_web framework is supported on appcloud
        Given The lift framework is supported on appcloud
        When I upload my foo-based ruby18 application it should fail
        When I upload my sinatra ruby2010 application it should fail
        Then I delete all my service
        Then I delete my application
