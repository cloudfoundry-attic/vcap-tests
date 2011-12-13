require File.expand_path('../lib/build_config.rb', __FILE__)
ENV['BUNDLE_PATH'] = BuildConfig.bundle_path

#import "../rakelib/core_components.rake"
#import "../rakelib/bundler.rake"

desc "Run the Basic Viability Tests"
task :tests => 'bvt:run'

ci_steps = ['ci:version_check',
            'bundler:install:production',
            'bundler:check',
            'ci:hacky_startup_delay',
            'ci:configure',
            'ci:reset',
            'ci:starting_build',
            'ci:start',
            'bvt:run_for_ci',
            'ci:stop']
desc "Set up a test cloud, run the BVT tests, and then tear it down"
task 'ci-tests' => ci_steps

task 'ci-java-tests' => 'java_client:ci_tests'
