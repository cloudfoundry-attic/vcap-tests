require "fileutils"
require 'nokogiri'
require 'tempfile'

namespace :bvt_upgrade do

  results_dir = File.expand_path("../../../ci-artifacts-dir", File.dirname(__FILE__))
  tests_dir = File.join(CoreComponents.root, "tests")
  FileUtils.mkdir_p(results_dir)
  cucumber_options = ENV['CUCUMBER_OPTIONS'] || "--tags @bvt_upgrade --tags ~@rails"
    
  desc "Run BVT: deploy and keep canonical apps running"
  task :run_bvt_canonical_keep_apps do
#    root = File.join(CoreComponents.root, "tests")
    puts "Starting canonical_keep_apps test against #{ENV['VCAP_BVT_TARGET']}"
    cmd = BuildConfig.bundle_cmd(" bundle exec cucumber features/canonical_keep_apps.feature --require features #{cucumber_options} --format pretty -o #{results_dir}/TEST-canonical_keep_apps.log")
    sh "\tcd #{tests_dir}; #{cmd}" do |success, exit_code|    
      if success
        puts "canonical_keep_apps completed successfully"
      else
        fail "canonical_keep_apps exited with code: #{exit_code.exitstatus}"
      end
    end
  end
  
  desc "Run BVT expecting canonical apps running"
  task :resume_bvt_canonical do
#    root = File.join(CoreComponents.root, "tests")
    puts "Starting upgrade_canonical_apps test against #{ENV['VCAP_BVT_TARGET']}"
    cmd = BuildConfig.bundle_cmd(" bundle exec cucumber features/upgrade_canonical_apps.feature --require features #{cucumber_options} --format pretty -o #{results_dir}/TEST-upgrade_canonical_apps.log")
    sh "\tcd #{tests_dir}; #{cmd}" do |success, exit_code|    
      if success
        puts "resume_bvt_canonical completed successfully"
      else
        fail "resume_bvt_canonical exited with code: #{exit_code.exitstatus}"
      end
    end
  end
  
  desc "Run BVT: deploy and keep canonical apps running - junit format"
  task :junit_bvt_canonical_keep_apps do
    root = File.join(CoreComponents.root, "tests")
    puts "Starting canonical_keep_apps test against #{ENV['VCAP_BVT_TARGET']}"
    cmd = BuildConfig.bundle_cmd("bundle exec cucumber features/canonical_keep_apps.feature --require features #{cucumber_options} --format junit -o #{results_dir}")
    sh "\tcd #{root}; #{cmd}" do |success, exit_code|    
      if success
        puts "canonical_keep_apps completed successfully"
      else
        fail "canonical_keep_apps exited with code: #{exit_code.exitstatus}"
      end
    end
  end
 
  desc "Run BVT expecting canonical apps running - junit format"
  task :junit_resume_bvt_canonical do
    root = File.join(CoreComponents.root, "tests")
    puts "Starting resume_bvt_canonical test against #{ENV['VCAP_BVT_TARGET']}"
    cmd = BuildConfig.bundle_cmd("bundle exec cucumber features/upgrade_canonical_apps.feature --require features #{cucumber_options} --format junit -o #{results_dir}")
    sh "\tcd #{root}; #{cmd}" do |success, exit_code|    
      if success
        puts "resume_bvt_canonical completed successfully"
      else
        fail "resume_bvt_canonical exited with code: #{exit_code.exitstatus}"
      end
    end
  end
  
end 
  


