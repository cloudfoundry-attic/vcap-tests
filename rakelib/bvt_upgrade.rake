require "fileutils"
require 'nokogiri'
require 'tempfile'

namespace :bvt_upgrade do

  results_dir = File.expand_path("../../../ci-artifacts-dir", File.dirname(__FILE__))
  tests_dir = File.join(CoreComponents.root, "tests")
  FileUtils.mkdir_p(results_dir)

  desc "Execute specific feature  tests"
  task :exec_feature_tests, :feature_name, :format do |t, args|
    puts "Feature is #{args.feature_name}"
    puts "Format is #{args.format}"
    puts "Starting #{args.feature_name} tests against #{ENV['VCAP_BVT_TARGET']}"
    if "#{args.format}".match("junit")
      output = "#{results_dir}"
    else
      output = "#{results_dir}/TEST-#{args.feature_name}.log"
    end
    if "#{args.feature_name}".match("upgrade_canonical_apps")
      cucumber_options = ENV['CUCUMBER_OPTIONS'] || "--no-color --tags @bvt_upgrade --tags ~@rails"
    else
      cucumber_options = ENV['CUCUMBER_OPTIONS'] || "--no-color --tags @canonical --tags ~@delete --tags ~@rails --tags ~@bvt_upgrade"
    end
    cmd = BuildConfig.bundle_cmd(" bundle exec cucumber features/#{args.feature_name}* --require features #{cucumber_options} --format #{args.format} -o #{output}")
    sh "\tcd #{tests_dir}; #{cmd}" do |success, exit_code|
      if success
        puts " #{args.feature_name} completed successfully"
      else
        fail " #{args.feature_name} exited with code: #{exit_code.exitstatus}"
      end
    end
  end

  desc "Run BVT: deploy and keep canonical apps running"
  task :run_bvt_canonical_keep_apps do
    Rake::Task['bvt_upgrade:exec_feature_tests'].invoke("canonical_apps", "pretty")
  end

  desc "Run BVT expecting canonical apps running"
  task :resume_bvt_canonical do
    Rake::Task['bvt_upgrade:exec_feature_tests'].invoke("upgrade_canonical_apps", "pretty")
  end

  desc "Run BVT: deploy and keep canonical apps running"
  task :junit_bvt_canonical_keep_apps do
    Rake::Task['bvt_upgrade:exec_feature_tests'].invoke("canonical_apps", "junit")
  end

  desc "Run BVT expecting canonical apps running"
  task :junit_resume_bvt_canonical do
    Rake::Task['bvt_upgrade:exec_feature_tests'].invoke("upgrade_canonical_apps", "junit")
  end
end
