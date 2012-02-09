$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "parallel_runner"

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

  task :run_uaa do
    config_path=ENV['CLOUD_FOUNDRY_CONFIG_PATH']?"-DCLOUD_FOUNDRY_CONFIG_PATH=#{ENV['CLOUD_FOUNDRY_CONFIG_PATH']} ":''
    sh "cd #{CoreComponents.root}/uaa/uaa; MAVEN_OPTS=\"#{ENV['MAVEN_OPTS']}\" mvn -P vcap #{config_path}-Duaa.integration.test=true -Dtest=*IntegrationTests test | tee /tmp/uaa.bvt.log | grep 'BUILD SUCCESSFUL'" do |ok,status|
      logmsg = `tail -20 /tmp/uaa.bvt.log`
      ok or fail "UAA integration tests failed...truncated logs:\n#{logmsg}\nUAA integration tests failed"
    end
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
      unless (tests && tests == 'canonical')
        puts "Start application performance bvts separate from the rest to get around the 2GB per user memory limitations\n"
        sh "bundle exec parallel_cucumber -n 2 " +
          "features/application_performance.feature " +
          "features/application_update.feature" do |success, exit_code|
        end
      end
      puts "Start canonical apps bvts separate from the rest to get around the 2GB per user memory limitations\n"
      sh "bundle exec parallel_cucumber -n 4 " +
        "features/canonical_apps_node.feature " +
        "features/canonical_apps_rails.feature " +
        "features/canonical_apps_sinatra.feature " +
        "features/canonical_apps_spring.feature" do |success, exit_code|
      end
      unless (tests && tests == 'canonical')
        puts "Process Started:#{test_proc}"
        sh "bundle exec parallel_cucumber --no-sort -n #{test_proc} " +
          "features/autostaging.feature " +
          "features/autostaging_rails.feature " +
          "features/autostaging_grails.feature " +
          "features/autoreconfig.feature " +
          "features/erlang.feature " +
          "features/lift.feature " +
          "features/neo4j.feature " +
          "features/php.feature " +
          "features/python.feature " +
          "features/atmos.feature " +
          "features/service_broker.feature " +
          "features/service_lifecycle.feature " +
          "features/tomcat_validation.feature " +
          "features/user_management.feature " +
          "features/spring_env.feature " +
          "features/application_info.feature " +
          "features/application_lifecycle_control.feature" do |success, exit_code|
          ENV['parallel_tests'] = "false"
        end
      end
    end
    puts "\n::::BVT TESTS RUN COMPLETE::::"
    puts "\nrunning cleanup now..."
  end

  task :cleanup do
    ENV['parallel_tests'] = "false"
    sh "bundle exec cucumber features/cleanup.feature"
  end

  task :in_threads do
    include ColorHelpers

    puts yellow("Starting parallel BVT run")

    runner = Bvt::ParallelRunner.new($stdout)

    start_time = Time.now

    list_tests_cmd = "bundle exec cucumber -e hooks.rb " +
      "-d -f BVT::ListScenarios --tags ~@bvt_upgrade " +
      "--tags ~@canonical --tags ~@cleanup"

    list_tests_out = `#{list_tests_cmd}`
    if $?.exitstatus != 0
      raise "Cannot get tests list: exit code #{$?.exitstatus}"
    end

    tests = list_tests_out.lines.map{ |t| t.strip }.select{ |t| t =~ /^features/}

    runner.cleanup

    # Adding canonical tests
    canonical_apps = ["node", "sinatra", "rails", "spring"]

    canonical_apps.each do |app|
      task_env = {
        "VCAP_BVT_NS" => "t" + rand(2**32).to_s(36),
        "CANONICAL" => "yes"
      }
      runner.add_task("features/canonical_apps_#{app}.feature", task_env)
    end

    runner.run_tasks
    runner.cleanup

    # Run rest of the tests
    tests.sort_by { rand }.each do |test|
      task_env = {
        "VCAP_BVT_NS" => "t" + rand(2**32).to_s(36)
      }
      runner.add_task(test, task_env)
    end

    runner.run_tasks
    runner.cleanup

    if runner.failed_tasks.size > 0
      puts red("\nFailed scenarios output:")
      runner.failed_tasks.each do |scenario, output|
        puts red(scenario)
        puts output
      end
      puts red("\nTotal number of failing scenarios: #{runner.failed_tasks.size} (see output above)")
      runner.failed_tasks.map { |scenario, output| puts red(scenario) }
      puts "You can run them explicitly with: bundle exec cucumber FEATURE_PATH:LINE"
    else
      puts green("\nNo failed scenarios!")
    end

    puts yellow("\nTotal number of scenarios: #{tests.size} + #{canonical_apps.size} canonical tests")
    puts "Total execution time: %sm:%.3fs" % (Time.now - start_time).divmod(60)
  end

end
