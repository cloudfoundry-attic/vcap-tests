# function test of service broker
require "uri"
require "json"
require 'curb'

When /^I have the service broker url and token$/ do
  unless @service_broker_url and @service_broker_token
    pending "service broker url or token is not provided."
  end
end

Then /^I create a brokered service using (\w+) as backend$/ do |app|
  @brokered_service_app = @app
  name = "simple_kv"
  version = "1.0"
  label = "#{name}-#{version}"
  option_name = "default"
  # the real name in vmc
  @brokered_service_name = "#{name}_#{option_name}"
  @brokered_service_label = "#{name}_#{option_name}-#{version}"
  app_uri = get_uri(@brokered_service_app)
  @brokered_service = {
    :label => label,
    :options => [ {
        :name => option_name,
        :acls => {
          :users => [test_user],
          :wildcards => []
        },
        :credentials =>{:url => "http://#{app_uri}"}
      }
    ]
  }
  resp = create_brokered_service
  resp.code.should == "200"
end

Then /^I should able to find the brokered service$/ do
  find_service(@brokered_service_name).should_not be_nil
end

Then /^I create a brokered service and bind it to (\w+)$/ do |app|
  @brokered_service_instance = provision_brokered_service @token
  @brokered_service_instance.should_not == nil

  attach_provisioned_service @app, @brokered_service_instance, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

Then /^I post a key-value to (\w+)$/ do |app|
  uri = get_uri(@app, "brokered-service/#{@brokered_service_label}")
  @simple_key = "key1"
  @simple_value = "value1"
  data = "#{@simple_key}:#{@simple_value}"
  easy = Curl::Easy.new
  easy.url = uri
  easy.http_post(data)
  easy.response_code.should == 200
  easy.close
end

Then /^I should able to access the same key-value from (\w+)$/ do |app|
  uri = get_uri(@brokered_service_app, "service/#{@simple_key}")
  res = get_uri_contents uri
  res.response_code.should == 200
  res.body_str.should == @simple_value
end

BROKER_API_VERSION = "poc"

def broker_hdrs
  {
    'Content-Type' => 'application/json',
    'X-VCAP-Service-Token' => @service_broker_token,
  }
end

def create_brokered_service
  klass = Net::HTTP::Post
  url = "/service-broker/#{BROKER_API_VERSION}/offerings"
  body = @brokered_service.to_json
  resp = perform_http_request(klass, url, body)
  resp
end

def delete_brokered_services
  klass = Net::HTTP::Delete
  label = @brokered_service[:label]
  url = "/service-broker/#{BROKER_API_VERSION}/offerings/#{label}"
  resp = perform_http_request(klass, url)
  resp
end

def perform_http_request(klass, url, body=nil)
  uri = URI.parse(@service_broker_url)
  req = klass.new(url, initheader=broker_hdrs)
  req.body = body if body
  resp = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(req)}
end

After("@creates_simple_kv_app") do |scenario|
  AppCloudHelper.instance.delete_app_internal SIMPLE_KV_APP
end


After("@creates_brokered_service_app") do |scenario|
  AppCloudHelper.instance.delete_app_internal BROKERED_SERVICE_APP
end

After("@creates_brokered_service") do |scenario|
  delete_brokered_services if @brokered_service
end

