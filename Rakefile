require File.expand_path('../lib/build_config.rb', __FILE__)
ENV['BUNDLE_PATH'] = BuildConfig.bundle_path

# Relies on having the ENV['VCAP'] environment variable set to the root of
# of the VCAP source. If the environemnt variable is not set, the default
# value of "..", enables this script when 'vcap-tests' is a submodule reference
# under 'vcap'.
vcap = ENV['VCAP'] || ".."
import "#{vcap}/rakelib/core_components.rake"
import "#{vcap}/rakelib/bundler.rake"


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
             "#{TESTS_PATH}/java_web/app_with_startup_delay"
]

desc "Build the tests. If the git hash associated with the test assets has not changed, nothing is built. To force a build, invoke 'rake build[--force]'"
task :build, [:force] do |t, args|
  puts "\nBuilding tests"
  sh('git submodule update --init')
  if build_required? args.force
    ENV['MAVEN_OPTS']="-XX:MaxPermSize=256M"
    TESTS_TO_BUILD.each do |test|
      puts "\tBuilding '#{test}'"
      Dir.chdir test do
        sh('mvn package -DskipTests') do |success, exit_code|
          unless success
            clear_build_artifact
            do_mvn_clean('-q')
            fail "\tFailed to build #{test} - aborting build"
          end
        end
      end
      puts "\tCompleted building '#{test}'"
    end
    save_git_hash
  else
    puts "Built artifacts in sync with test assets - no build required"
  end
end

desc "Clean the build artifacts"
task :clean do
  puts "\nCleaning tests"
  clear_build_artifact
  TESTS_TO_BUILD.each do |test|
    puts "\tCleaning '#{test}'"
    Dir.chdir test do
      do_mvn_clean
    end
    puts "\tCompleted cleaning '#{test}'"
  end
end

def build_required? (force_build=nil)
  if File.exists?(BUILD_ARTIFACT) == false or (force_build and force_build == "--force")
    return true
  end
  Dir.chdir(tests_path) do
    saved_git_hash = IO.readlines(BUILD_ARTIFACT)[0].split[0]
    git_hash = `git rev-parse --short=8 --verify HEAD`
    saved_git_hash.to_s.strip != git_hash.to_s.strip
  end
end

def save_git_hash
  Dir.chdir(tests_path) do
    git_hash = `git rev-parse --short=8 --verify HEAD`
    File.open(BUILD_ARTIFACT, 'w') {|f| f.puts("#{git_hash}")}
  end
end

def clear_build_artifact
  puts "\tClearing build artifact #{BUILD_ARTIFACT}"
  File.unlink BUILD_ARTIFACT if File.exists? BUILD_ARTIFACT
end

def do_mvn_clean options=nil
  sh("mvn clean #{options}")
end

