namespace :bvt do
  task :run do
    sh "bundle exec cucumber --tags ~@bvt_upgrade"
  end

  task :run_junit_format do
    sh "bundle exec cucumber --tags ~@bvt_upgrade --format junit -o #{BuildConfig.test_result_dir}"
  end

  task :run_smoke do
    sh "bundle exec cucumber --tags @smoke"
  end

  task :run_sanity do
    sh "bundle exec cucumber --tags @sanity"
  end

  task :run_ruby do
    sh "bundle exec cucumber --tags @ruby"
  end

  task :run_jvm do
    sh "bundle exec cucumber --tags @jvm,@java"
  end

  task :run_java do
    sh "bundle exec cucumber --tags @java"
  end

  task :run_services do
    sh "bundle exec cucumber --tags @services"
  end

  task :init do
    ENV['parallel_tests' ] = "false"
  end

  task :run_parallel => ['parallel_tests', 'cleanup']

  task :parallel_tests do
    tests_specified = ENV['tests']
    tests = tests_specified.dup if tests_specified
    if (tests)
      tests.gsub!(/,/, ' ')
    end
    test_proc = ENV['TEST_PROC']
    unless test_proc
      test_proc = 5
    end
    puts "set environment variable TEST_PROC to change number of processes used"
    ENV['parallel_tests'] = "true"
    if (tests && tests[0, 'features'.length] == 'features')
      puts "Process Started:#{test_proc}"
      sh "bundle exec parallel_cucumber -n #{test_proc} " + tests do |success, exit_code|
        ENV['parallel_tests'] = "false"
      end
    else
      puts "Start application performance bvts separate from the rest to get around the 2GB per user memory limitations"
      sh "bundle exec parallel_cucumber -n 2 " +
        "features/application_performance.feature " +
        "features/application_update.feature" do |success, exit_code|
      end
      puts "Process Started:#{test_proc}"
      sh "bundle exec parallel_cucumber -n #{test_proc} " +
        "features/autostaging.feature "+
        "features/autostaging_rails.feature "+
        "features/autostaging_grails.feature "+
        "features/autoreconfig.feature "+
        "features/erlang.feature " +
        "features/lift.feature " +
        "features/neo4j.feature " +
        "features/php.feature " +
        "features/python.feature " +
        "features/service_broker.feature " +
        "features/tomcat_validation.feature " +
        "features/user_management.feature " +
        "features/spring_env.feature " +
        "features/application_info.feature " +
        "features/application_lifecycle_control.feature" do |success, exit_code|
        ENV['parallel_tests'] = "false"
      end
    end
    puts "\n::::BVT TESTS RUN COMPLETE::::"
    puts "\nrunning cleanup now..."
  end

  task :cleanup do
    ENV['parallel_tests'] = "false"
    sh "bundle exec cucumber features/cleanup.feature"
  end

  desc "Run the Basic Viability Tests with jUnit output"
  task :run_for_ci do
    # Don't fail the Rake run if a test fails.
    # We still want to run our 'stop' task whenever possible.
    # ci:succeed_or_fail will run after everything has stopped.
    $ci_exit_code = nil
    cucumber = "cucumber --tags ~@bvt_upgrade --format junit -o #{BuildConfig.test_result_dir}"
    cmd = BuildConfig.bundle_cmd("bundle exec #{cucumber}")
    system(cmd) # Cucumber's output is all on STDOUT, happily.
    $ci_exit_code = $?.dup
  end
end
