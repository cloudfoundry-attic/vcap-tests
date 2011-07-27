#
# The test automation based on Cucumber uses the steps defined and implemented here to
# facilitate the handling of the various scenarios that make up the feature set of
# AppCloud.
#
# Author:: Mark Lucovsky (markl)
# Copyright:: Copyright (c) 2010 VMware Inc.

#World(AppCloudHelper)

Given /^I have my redis lb app on AppCloud$/ do
  @counters = nil
  @app = create_app REDIS_LB_APP, @token
  @service = provision_redis_service @token
  attach_provisioned_service @app, @service, @token
end

Then /^it's health_check entrypoint should return OK$/ do
  response = get_app_contents @app, 'healthcheck'
  response.should_not == nil
  response.body_str.should =~ /^OK/
  response.response_code.should == 200
  response.close
end

Then /^after resetting all counters it should return OK and no data$/ do
  response = get_app_contents @app, 'reset'
  response.should_not == nil
  response.body_str.should =~ /^OK/
  response.response_code.should == 200
  response.close

  response = get_app_contents @app, 'getstats'
  response.should_not == nil
  response.body_str.should =~ /^\{\}/
  response.response_code.should == 200
  response.close
end

When /^I execute \/incr (\d+) times$/ do |arg1|
  arg1.to_i.times do
    response = get_app_contents @app, 'incr'
    response.should_not == nil
    response.body_str.should =~ /^OK:/
    response.response_code.should == 200
    response.close
  end
end

Then /^the sum of all instance counts should be (\d+)$/ do |arg1|
  response = get_app_contents @app, 'getstats'
  response.should_not == nil
  response.response_code.should == 200
  counters = JSON.parse(response.body_str)
  response.close

  total_count = 0
  counters.each do |k,v|
    total_count += v.to_i
  end
  total_count.should == arg1.to_i
end

Then /^all (\d+) instances should participate$/ do |arg1|
  response = get_app_contents @app, 'getstats'
  response.should_not == nil
  response.response_code.should == 200
  counters = JSON.parse(response.body_str)
  response.close

  total_keys = 0
  counters.each do |k,v|
    total_keys += 1
  end
  total_keys.should == arg1.to_i
end

Then /^all (\d+) instances should do within (\d+) percent of their fair share of the (\d+) operations$/ do |arg1, arg2, arg3|
  @target = arg3.to_i / arg1.to_i
  @slop = @target * (arg2.to_i/100.0)

  response = get_app_contents @app, 'getstats'
  response.should_not == nil
  response.response_code.should == 200
  @counters = JSON.parse(response.body_str)
  response.close

  @counters.each do |k,v|
    v.to_i.should be_close(@target, @slop)
  end
end

Given /^I have my env_test app on AppCloud$/ do
  @counters = nil
  @app = create_app ENV_TEST_APP, @token

  # enumerate system services. IFF aurora is present,
  # bind to aurora. If not, bind to other services

  services = get_services @token

  # flatten
  services_list = []

  services.each do |service_type, value|
    value.each do |k,v|
      # k is really the vendor
      v.each do |version, s|
        services_list << s
      end
    end
  end

  # look through the services list. for each available service
  # bind to the service, adapt if service isn't running
  @should_be_there = []
  ["aurora", "redis"].each do |v|
    s = services_list.find {|service| service[:vendor].downcase == v}
    if s

      # create named service
      myname = "my-#{s[:vendor]}"
      if v == 'aurora'
        name = aurora_name(myname)
        service = provision_aurora_service_named @token, myname
      end
      if v == 'redis'
        name = redis_name(myname)
        service = provision_redis_service_named @token, myname
      end

      # attach to the app
      attach_provisioned_service @app, service, @token

      # then record for testing against the environment variables
      entry = {}
      entry['name'] = name
      entry['type'] = s['type']
      entry['vendor'] = s['vendor']
      entry['version'] = s['version']
      @should_be_there << entry
    end
  end

end

Given /^I have my mozyatmos app on AppCloud$/ do

  @counters = nil
  @should_be_there = []
  @app = create_app ENV_TEST_APP, @token

  # the mozy service needs to be available
  vendor = 'mozyatmos'
  s = @services_list.find {|service| service[:vendor].downcase == vendor}

  if s
    # create named service
    myname = "my-#{'vendor'}"
    name = mozyatmos_name(myname)
    service = provision_mozyatmos_service_named @token, myname

    # attach to the app
    attach_provisioned_service @app, service, @token

    # then record for testing against the environment variables
    entry = {}
    entry['name'] = name
    entry['type'] = s['type']
    entry['vendor'] = s['vendor']
    entry['version'] = s['version']
    @should_be_there << entry
  end
end

Given /^The appcloud instance has a set of available services$/ do
  calculate_service_list
  @services_list.length.should > 1
end

Then /^env_test's health_check entrypoint should return OK$/ do
  response = get_app_contents @app, 'healthcheck'
  response.should_not == nil
  response.body_str.should =~ /^OK/
  response.response_code.should == 200
  response.close
end

Then /^it should be bound to an atmos service$/ do

  # execute this block, but only if mozy service is present
  # in the system
  vendor = 'mozyatmos'
  s = @services_list.find {|service| service[:vendor].downcase == vendor}
  if s

    app_info = get_app_status @app, @token
    app_info.should_not == nil
    services = app_info[:services]
    services.should_not == nil

    # grab the services bound to the app from its env
    response = get_app_contents @app, 'services'
    response.should_not == nil
    response.response_code.should == 200
    service_list = JSON.parse(response.body_str)
    response.close

    # assert that there should only be a single service bound to this app
    service_list[:services].length.should == 1
    service_list[:services][0][:vendor].should == 'mozyatmos'


    # assert that the services list that we get from the app environment
    # matches what we expect from provisioning
    found = 0
    service_list[:services].each do |s|
      @should_be_there.each do |v|
        if v[:name] == s[:name] && v[:type] == s[:type] && v[:vendor] == s[:vendor]
          found += 1
          break
        end
      end
    end
    found.should == @should_be_there.length
    end
  end

Then /^it should be bound to the right services$/ do
  app_info = get_app_status @app, @token
  app_info.should_not == nil
  services = app_info[:services]
  services.should_not == nil

  response = get_app_contents @app, 'services'
  response.should_not == nil
  response.response_code.should == 200
  service_list = JSON.parse(response.body_str)
  response.close

  # assert that the services list that we get from the app environment
  # matches what we expect from provisioning
  found = 0
  service_list['services'].each do |s|
    @should_be_there.each do |v|
      if v[:name] == s[:name] && v[:type] == s[:type] && v[:vendor] == s[:vendor]
        found += 1
        break
      end
    end
  end
  found.should == @should_be_there.length
end


After("@lb_check") do |scenario|
  app_info = get_app_status @app, @token
  app_info.should_not == nil
  services = app_info[:services]
  delete_services services if services.length.to_i > 0

  if(scenario.failed?)
    if @counters != nil
      puts "The scenario failed due to unexpected load balance distribution from the router"
      puts "The following hash shows the per-instance counts along with the target and allowable deviation"
      pp @counters
      puts "target: #{@target}, allowable deviation: #{@slop}"
    end
  end
end

# look at for env_test cleanup
After("@env_test_check") do |scenario|
  app_info = get_app_status @app, @token
  app_info.should_not == nil
  services = app_info[:services]
  delete_services services if services.length.to_i > 0

  if(scenario.failed?)
     puts "The scenario failed #{scenario}"
  end
end

def calculate_service_list
  services = get_services @token

  # flatten
  services_list = []

  services.each do |service_type, value|
    value.each do |k,v|
      # k is really the vendor
      v.each do |version, s|
        services_list << s
      end
    end
  end
  @services_list = services_list
end

Given /^The appcloud instance has a set of available frameworks$/ do
  calculate_frameworks_list
  @frameworks_list.length.should > 1
end

Given /^The appcloud instance has a set of available runtimes$/ do
  calculate_runtimes_list
  pp @runtimes_list

  @runtimes_list.length.should > 1
end


Given /^The foo framework is not supported on appcloud$/ do
  @frameworks_list.include?('foo').should == false
end

Given /^The rails3 framework is supported on appcloud$/ do
  @frameworks_list.include?('rails3').should == true
end

Given /^The node framework is supported on appcloud$/ do
  @frameworks_list.include?('node').should == true
end

Given /^The spring framework is supported on appcloud$/ do
  @frameworks_list.include?('spring').should == true
end

Given /^The grails framework is supported on appcloud$/ do
  @frameworks_list.include?('grails').should == true
end

Given /^The sinatra framework is supported on appcloud$/ do
  @frameworks_list.include?('sinatra').should == true
end

When /^I upload my foo-based ruby18 application it should fail$/ do
  response = create_failed_app_with_runtime_and_framework ENV_TEST_APP, @token, 'ruby18', 'foo'
  response.message.should =="Error 300: Invalid application description"
end

When /^I upload my sinatra ruby2010 application it should fail$/ do
  response = create_failed_app_with_runtime_and_framework ENV_TEST_APP, @token, 'ruby2010', 'sinatra'

  response.message.should =="Error 300: Invalid application description"
end

def create_failed_app_with_runtime_and_framework app, token, runtime, framework
  appname = get_app_name app
  delete_app app, token
  url = create_uri appname
  manifest = {
    :name => "#{appname}",
    :staging => {
      :runtime => runtime,
      :framework => framework
    },
    :resources=> {
        :memory => @config[app]['memory'] || 64
    },
    :uris => [url],
    :instances => "1",
  }
  begin
    response = @client.create_app appname, manifest
  rescue Exception => e
    return e
  end
  return response
end

def calculate_frameworks_list
  frameworks = get_frameworks @token

  # flatten
  frameworks_list = []
  frameworks.each do |k, v|
    frameworks_list << k
  end
  @frameworks_list = frameworks_list
end
