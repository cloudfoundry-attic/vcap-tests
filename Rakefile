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
  puts "  tests\t\trun all bvts"
  puts "  smoke_tests\trun a smaller subset of bvts"
  puts "  sanity\trun only the most fundamental bvts"
  puts "  ruby\t\trun ruby-based bvts (rails3, sinatra)"
  puts "  jvm\t\trun jvm-based bvts (spring, java_web, grails, lift)"
  puts "  java\t\trun java-based bvts (spring, java_web)"
  puts "  services\trun services-based bvts"
  puts "  ci-tests\tset up a test cloud, run the bvts, and then tear it down"
  puts "  help\t\tlist help commands"
end

desc "Run the Basic Viability Tests"
task :tests => ['build','bvt:run']

desc "Run the Basic Viability Tests but spit junit format results"
task :junit_tests => ['build','bvt:run_junit_format']

desc "Run a faster subset of Basic Viability Tests"
task :smoke_tests => ['build','bvt:run_smoke']

desc "Run a fast essential basic set of tests"
task :sanity => ['build','bvt:run_sanity']

desc "Run ruby-based tests"
task :ruby => ['bvt:run_ruby']

desc "Run jvm-based tests"
task :jvm => ['build','bvt:run_jvm']

desc "Run java-based tests"
task :java => ['build','bvt:run_java']

desc "Run services-based tests"
task :services => ['build','bvt:run_services']

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
             "#{TESTS_PATH}/java_web/app_with_startup_delay",
             "#{TESTS_PATH}/java_web/tomcat-version-check-app",
             "#{TESTS_PATH}/spring/roo-guestbook",
             "#{TESTS_PATH}/spring/jpa-guestbook",
             "#{TESTS_PATH}/spring/hibernate-guestbook",
             "#{TESTS_PATH}/spring/spring-env",
             "#{TESTS_PATH}/grails/guestbook",
             "#{TESTS_PATH}/java_web/java_tiny_app",
             "#{TESTS_PATH}/lift/hello_lift",
             "#{TESTS_PATH}/lift/lift-db-app"
]

desc "Build the tests. If the git hash associated with the test assets has not changed, nothing is built. To force a build, invoke 'rake build[--force]'"
task :build, [:force] do |t, args|
  puts "\nBuilding tests"
  sh('git submodule update --init')
  if build_required? args.force
    ENV['MAVEN_OPTS']="-XX:MaxPermSize=256M"
    is_grailsdep_installed = false
    TESTS_TO_BUILD.each do |test|
      puts "\tBuilding '#{test}'"
      Dir.chdir test do
        unless is_grailsdep_installed
          is_grailsdep_installed = install_grailsdep test
        end
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

def install_grails
  puts "\tOne-time install of grails modules to enable build/run of grails apps"
  sh('sudo apt-get install python-software-properties') do |success, exit_code|
    unless success
      puts "\tUnable to install python-software-properties"
    end
  end
  sh('sudo add-apt-repository ppa:groovy-dev/grails') do |success, exit_code|
    unless success
      puts "\tUnable to add grails repository"
    end
  end
  sh('sudo apt-get update') do |success, exit_code|
    unless success
      puts "\tUnable to execute apt-get update"
    end
  end
  sh('sudo apt-get install grails') do |success, exit_code|
    unless success
      puts "\tUnable to install grails. BVT may fail to build."
    end
  end
end

def install_grails_mac
  puts "\tOne-time install of grails on mac"
  sh('brew install grails') do |success, exit_code|
    unless success
      puts "\tUnable to install grails using 'brew install grails'. You need to manually install grails on your mac"
    end
  end
end

def install_grailsdep test
  is_grailsdep_installed = false
  is_grails_installed = false
  if (test =~ /\/grails\//)
    sh('grails create-app tmp') do |success, exit_code|
      if success
        is_grailsdep_installed = true
        is_grails_installed = true
        puts "\tInstall grails dependencies in ivy cache successfully"
        sh('rm -rf tmp') do |success, exit_code|
        end
      else
        puts "platform: #{RUBY_PLATFORM}"
        if (RUBY_PLATFORM =~ /darwin/)
          puts "Assuming brew is installed on Mac OSX, executing 'brew install grails' to install grails on your system"
          install_grails_mac
        elsif (RUBY_PLATFORM =~ /win32/)
          puts "Please install grails manually in your windows environment before running BVT"
        else
          puts "Assuming a debian-based OS. Automatically installing grails..."
          install_grails
        end
      end
    end
    unless is_grailsdep_installed
      sh('grails create-app tmp') do |success, exit_code|
        if success
          is_grailsdep_installed = true
          puts "\tInstall grails dependencies in ivy cache successfully"
        else
          is_grailsdep_installed = false
          puts "\tUnable to populate require dependencies in ivy cache using 'grails create-app'"
          puts "\tUnable to auto-install grails components. You may have to install grails in your environment manually"
          puts "\tIn your BVT shell> grails --version"
          puts "\t\t command not found -> You have to manually install grails"
          puts "\t\t Security Exception etc -> You have to remove the setting of CLASSPATH variable"
          fail "***** Please make sure grails is installed and configured properly before building BVT"
        end
        sh('rm -rf tmp') do |success, exit_code|
        end
      end 
    end
  end
  is_grailsdep_installed
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

