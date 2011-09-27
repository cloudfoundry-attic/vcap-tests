namespace :bvt do
  task :run do
    sh "bundle exec cucumber"
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

