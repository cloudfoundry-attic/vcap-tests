require File.expand_path('../lib/build_config.rb', __FILE__)
ENV['BUNDLE_PATH'] = BuildConfig.bundle_path

import "../rakelib/core_components.rake"
import "../rakelib/bundler.rake"


desc "Run the Basic Viability Tests"
task :tests => ['build','bvt:run']

ci_steps = ['ci:version_check',
            'build',
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

def tests_path
  if @tests_path == nil
    @tests_path = File.join(Dir.pwd, "assets")
  end
  @tests_path
end
TESTS_PATH = tests_path

BUILD_ARTIFACT = File.join(Dir.pwd, ".build")

TESTS_TO_BUILD = ["#{TESTS_PATH}/spring/auto-reconfig-test-app",
             "#{TESTS_PATH}/spring/auto-reconfig-missing-deps-test-app", 
             "#{TESTS_PATH}/spring/app_spring_service",
             "#{TESTS_PATH}/spring/roo-guestbook",
             "#{TESTS_PATH}/spring/jpa-guestbook",
             "#{TESTS_PATH}/spring/hibernate-guestbook", 
             "#{TESTS_PATH}/java_web/java_tiny_app",
             "#{TESTS_PATH}/lift/hello_lift",
             "#{TESTS_PATH}/lift/lift-db-app",
             "#{TESTS_PATH}/java_web/tomcat-version-check-app"
             ]

desc "Build the tests. If the git hash associated with the test assets has not changed, nothing is built. To force a build, invoke 'rake build[--force]'"
task :build, [:force] do |t, args|
  sh('git submodule update --init')
  if build_required? args.force
    ENV['MAVEN_OPTS']="-XX:MaxPermSize=256M"
    TESTS_TO_BUILD.each do |test|
      puts "\nBuilding '#{test}'"
      Dir.chdir test do
        sh('mvn package -DskipTests')
      end
      puts "Completed building '#{test}'"
    end
    save_git_hash
  else
    puts "Built artifacts in sync with test assets - no build required"
  end
end

desc "Clean the build artifacts"
task :clean do
  TESTS_TO_BUILD.each do |test|
    puts "\nCleaning '#{test}'"
    Dir.chdir test do
      sh("mvn clean")
    end
    puts "Completed cleaning '#{test}'"
  end
  File.unlink BUILD_ARTIFACT if File.exists? BUILD_ARTIFACT
end

def build_required? (force_build=nil)
  if File.exists?(BUILD_ARTIFACT) == false or (force_build and force_build == "--force")
    return true
  end
  Dir.chdir(tests_path) do
    saved_git_hash = IO.readlines(BUILD_ARTIFACT)[0].split[0]
    git_hash = `git rev-parse --short=8 --verify HEAD`
    saved_git_hash == git_hash
  end
end

def save_git_hash
  Dir.chdir(tests_path) do
    git_hash = `git rev-parse --short=8 --verify HEAD`
    File.open(BUILD_ARTIFACT, 'w') {|f| f.puts("#{git_hash}")}
  end
end



