require "fileutils"
require 'nokogiri'
require 'tempfile'

namespace :bvt_caldecott do

  results_dir = File.expand_path("../ci-artifacts-dir", File.dirname(__FILE__))
  tests_dir = File.join(CoreComponents.root, "tests")
  FileUtils.mkdir_p(results_dir)
  output = "#{results_dir}"

  def get_feature_name (framework)
    name = "canonical_apps_#{framework}.feature"
  end

  desc "Delete/recreate results dir"
  task :clean_results_dir do
    FileUtils.rm Dir.glob("#{output}/TEST*.xml")
  end

# Internal task:  desc "Deploy one canonical app, provision all services, and post data"
  task :deploy_one_canonical_app, :framework do |t, args|
    feature_name = get_feature_name (args.framework)
    puts "#{feature_name}"
    cucumber_options = ENV['CUCUMBER_OPTIONS'] || "--no-color --tags @canonical --tags @#{args.framework} --tags ~@delete --tags ~@bvt_upgrade"
    command = "bundle exec cucumber features/#{feature_name} --require features #{cucumber_options} --format junit -o #{output}"
    puts "#{command}"
    sh("cd #{tests_dir}; #{command}")
  end

  desc "Delete all canonical apps"
  task :delete_all_canonical_apps do |t, args|
    cucumber_options = ENV['CUCUMBER_OPTIONS'] || "--tags @bvt_upgrade --tags @delete"
    feature_name = "upgrade_canonical_apps.feature"
    command = "bundle exec cucumber features/#{feature_name} --require features #{cucumber_options} --format junit -o #{output}"
    sh("cd #{tests_dir}; #{command}")
  end

# Internal task:  desc "Verify posted data for one canonical app, and service"
  task :verify_one_app_one_service, :framework, :service do |t, args|
    feature_name = "caldecott_verify.feature"
    cucumber_options = ENV['CUCUMBER_OPTIONS'] || "--no-color --tags @caldecott --tags @verify --tags @#{args.framework} --tags @#{args.service}"
    command = "bundle exec cucumber features/#{feature_name} --require features #{cucumber_options} --format junit -o #{output}"
    sh("cd #{tests_dir}; #{command}")
  end

  desc "Deploy and keep sinatra canonical app running"
  task :deploy_sinatra_canonical do
    Rake::Task['bvt_caldecott:deploy_one_canonical_app'].invoke("sinatra")
  end

  desc "Deploy and keep node canonical app running"
  task :deploy_node_canonical do
    Rake::Task['bvt_caldecott:deploy_one_canonical_app'].invoke("node")
  end

  desc "Deploy and keep spring canonical app running"
  task :deploy_spring_canonical do
    Rake::Task['bvt_caldecott:deploy_one_canonical_app'].invoke("spring")
  end

  desc "Deploy and keep rails canonical app running"
  task :deploy_rails_canonical do
    Rake::Task['bvt_caldecott:deploy_one_canonical_app'].invoke("rails")
  end

  desc "Verify mysql data on the node app"
  task :verify_node_mysql do
    Rake::Task['bvt_caldecott:verify_one_app_one_service'].invoke("node", "mysql")
  end

  desc "Verify postgresql data on the node app"
  task :verify_node_postgresql do
    Rake::Task['bvt_caldecott:verify_one_app_one_service'].invoke("node", "postgresql")
  end

  desc "Verify mongodb data on the node app"
  task :verify_node_mongodb do
    Rake::Task['bvt_caldecott:verify_one_app_one_service'].invoke("node", "mongodb")
  end

  desc "Verify redis data on the node app"
  task :verify_node_redis do
    Rake::Task['bvt_caldecott:verify_one_app_one_service'].invoke("node", "redis")
  end
end

