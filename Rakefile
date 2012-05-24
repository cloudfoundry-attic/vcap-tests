require File.expand_path('../lib/build_config.rb', __FILE__)
ENV['BUNDLE_PATH'] = BuildConfig.bundle_path

# Relies on having the ENV['VCAP'] environment variable set to the root of
# of the VCAP source. If the environemnt variable is not set, the default
# value of "..", enables this script when 'vcap-tests' is a submodule reference
# under 'vcap'.
vcap = ENV['VCAP'] || ".."
import "#{vcap}/rakelib/core_components.rake"
import "#{vcap}/rakelib/bundler.rake"

task :default => [:help]

desc "List help commands"
task :help do
  puts "Usage: rake [command]"
  puts "  tests\t\t\t\trun all bvts"
  puts "  parallel\t\t\trun all scenarios in parallel threads"
  puts "  p_tests\t\t\trun bvts in parallel (default to 5 processes. set env variable TEST_PROC to modify)"
  puts "  p_tests tests=canonical\trun canonical bvts in parallel"
  puts "  p_tests tests=[tests]\t\trun specified comma-delimited bvts in parallel (features/a.feature,features/b.feature)"
  puts "  smoke_tests\t\t\trun a smaller subset of bvts"
  puts "  sanity\t\t\trun only the most fundamental bvts"
  puts "  ruby\t\t\t\trun ruby-based bvts (rails3, sinatra)"
  puts "  jvm\t\t\t\trun jvm-based bvts (spring, java_web, grails, lift)"
  puts "  java\t\t\t\trun java-based bvts (spring, java_web)"
  puts "  services\t\t\trun services-based bvts"
  puts "  ci-tests\t\t\tset up a test cloud, run the bvts, and then tear it down"
  puts "  help\t\t\t\tlist help commands"
end

desc "Run the Basic Viability Tests"
task :tests => ['build','bvt:run']

desc "Run BVTs in parallel"
task :p_tests => ['build', 'bvt:init', 'bvt:run_parallel']

desc "Run the Basic Viability Tests but spit junit format results"
task :junit_tests => ['build', 'bvt:init', 'bvt:run_junit_format']

desc "Run a faster subset of Basic Viability Tests"
task :smoke_tests => ['build', 'bvt:init', 'bvt:run_smoke']

desc "Run a fast essential basic set of tests"
task :sanity => ['build', 'bvt:init', 'bvt:run_sanity']

desc "Run ruby-based tests"
task :ruby => ['bvt:init', 'bvt:run_ruby']

desc "Run jvm-based tests"
task :jvm => ['build', 'bvt:init', 'bvt:run_jvm']

desc "Run java-based tests"
task :java => ['build', 'bvt:init', 'bvt:run_java']

desc "Run services-based tests"
task :services => ['build', 'bvt:init', 'bvt:run_services']

desc "Run tests in parallel using thread pool"
task :parallel => ['build','bvt:in_threads']

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

desc "Run really simple tests for UAA service"
task 'uaa-tests' => ['uaa:run']

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
             "#{TESTS_PATH}/java_web/app_with_startup_delay",
             "#{TESTS_PATH}/java_web/tomcat-version-check-app",
             "#{TESTS_PATH}/spring/roo-guestbook",
             "#{TESTS_PATH}/spring/jpa-guestbook",
             "#{TESTS_PATH}/spring/hibernate-guestbook",
             "#{TESTS_PATH}/spring/spring-env",
             "#{TESTS_PATH}/spring/javaee-namespace-app",
             "#{TESTS_PATH}/spring/auto-reconfig-annotation-app",
             "#{TESTS_PATH}/grails/guestbook",
             "#{TESTS_PATH}/java_web/java_tiny_app",
             "#{TESTS_PATH}/lift/hello_lift",
             "#{TESTS_PATH}/lift/lift-db-app",
             "#{TESTS_PATH}/play/computer_database_scala",
             "#{TESTS_PATH}/play/computer_database_autoconfig_disabled",
             "#{TESTS_PATH}/play/computer_database_cf_by_name",
             "#{TESTS_PATH}/play/computer_database_cf_by_type",
             "#{TESTS_PATH}/play/computer_database_jpa",
             "#{TESTS_PATH}/play/computer_database_jpa_mysql",
             "#{TESTS_PATH}/play/computer_database_multi_dbs",
             "#{TESTS_PATH}/play/todolist",
             "#{TESTS_PATH}/play/todolist_with_cfruntime",
             "#{TESTS_PATH}/play/zentasks_cf_by_name",
             "#{TESTS_PATH}/play/zentasks_cf_by_type",
             "#{TESTS_PATH}/standalone/java_app"
]

PLAY_VERSION="2.0.1"

desc "Build the tests. If the git hash associated with the test assets has not changed, nothing is built. To force a build, invoke 'rake build[--force]'"
task :build, [:force] do |t, args|
  download_play if not File.exists? File.join(Dir.pwd, "play-#{PLAY_VERSION}","play")
  puts "\nBuilding tests"
  sh('git submodule update --init')
  if build_required? args.force
    prompt_message = "\nBVT need java development environment to build java-based test apps before pushing them to appcloud.\n
Please run 'sudo aptitude install maven2 default-jdk' on your Linux box"
    `mvn -v 2>&1`
    raise prompt_message if $?.exitstatus != 0
    ENV['MAVEN_OPTS']="-Xmx1024m -XX:MaxPermSize=256M"
    ENV['PLAY2_HOME']=File.join(Dir.pwd, "play-#{PLAY_VERSION}")
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

def download_play
  puts "Downloading and unpacking Play Framework"
  prompt_message = "\nBVTs require the unzip utility to install Play Framework.
    Please run 'sudo apt-get install unzip' on your Linux box"
  `unzip -v 2>&1`
  raise prompt_message if $?.exitstatus != 0
  sh("wget http://download.playframework.org/releases/play-#{PLAY_VERSION}.zip")
  sh("unzip -q play-#{PLAY_VERSION}.zip")
  FileUtils.rm_f("play-#{PLAY_VERSION}.zip")
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
