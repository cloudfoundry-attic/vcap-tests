require "fileutils"
require 'nokogiri'
require 'tempfile'

namespace :bvt_caldecott do

  @results_dir = File.expand_path("../ci-artifacts-dir", File.dirname(__FILE__))
  @tests_dir = File.join(CoreComponents.root, "tests")
  FileUtils.mkdir_p(@results_dir)

  def get_feature_name (framework)
    name = "canonical_apps_#{framework}.feature"
  end

  desc "Delete/recreate results dir"
  task :clean_results_dir do
    FileUtils.rm Dir.glob("#{@results_dir}/TEST*.xml")
  end

# Deploy one canonical app, provision all services, and post data
  def deploy_one_canonical_app (framework)
    feature_name = get_feature_name (framework)
    puts "#{feature_name}"
    cucumber_options = ENV['CUCUMBER_OPTIONS'] || "--no-color --tags @canonical --tags @#{framework} --tags ~@delete --tags ~@bvt_upgrade"
    command = "bundle exec cucumber features/#{feature_name} --require features #{cucumber_options} --format junit -o #{@results_dir}"
    puts "#{command}"
    sh("cd #{@tests_dir}; #{command}")
  end

  desc "Delete all canonical apps"
  task :delete_all_canonical_apps do
    cucumber_options = ENV['CUCUMBER_OPTIONS'] || "--tags @bvt_upgrade --tags @delete"
    feature_name = "upgrade_canonical_apps.feature"
    command = "bundle exec cucumber features/#{feature_name} --require features #{cucumber_options} --format junit -o #{@results_dir}"
    sh("cd #{@tests_dir}; #{command}")
  end

# Verify posted data for one canonical app, and service
  def verify_one_app_one_service (framework, service)
    feature_name = "caldecott_verify.feature"
    service.match("all") ?  cucumber_options = ENV['CUCUMBER_OPTIONS'] || "--no-color --tags @caldecott --tags @verify --tags @#{framework} --tags ~@postgresql" :  cucumber_options = ENV['CUCUMBER_OPTIONS'] || "--no-color --tags @caldecott --tags @verify --tags @#{framework} --tags @#{service}"
    command = "bundle exec cucumber features/#{feature_name} --require features #{cucumber_options} --format junit -o #{@results_dir}"
    sh("cd #{@tests_dir}; #{command}")
  end

  desc "Verify uploaded data for all canonical apps"
  task :verify_node_all_services do
    verify_one_app_one_service("node", "all") 
  end

  desc "Deploy and keep sinatra canonical app running"
  task :deploy_sinatra_canonical do
    deploy_one_canonical_app("sinatra")
  end

  desc "Deploy and keep node canonical app running"
  task :deploy_node_canonical do
    deploy_one_canonical_app("node")
  end

  desc "Deploy and keep spring canonical app running"
  task :deploy_spring_canonical do
    deploy_one_canonical_app("spring")
  end

  desc "Deploy and keep rails canonical app running"
  task :deploy_rails_canonical do
    deploy_one_canonical_app("rails")
  end

  desc "Verify mysql data on the node app"
  task :verify_node_mysql do
    verify_one_app_one_service("node", "mysql")
  end

  desc "Verify postgresql data on the node app"
  task :verify_node_postgresql do
    verify_one_app_one_service("node", "postgresql")
  end

  desc "Verify mongodb data on the node app"
  task :verify_node_mongodb do
    verify_one_app_one_service("node", "mongodb")
  end

  desc "Verify redis data on the node app"
  task :verify_node_redis do
    verify_one_app_one_service("node", "redis")
  end

end

