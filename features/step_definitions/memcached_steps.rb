# Simple memcached Application that uses the memcached high performance key-value service

Given /^I have provisioned a memcached service$/ do
  pending unless find_service 'memcached'
  @memcached_service = provision_memcached_service @token
  @memcached_service.should_not == nil
end

Given /^I have deployed a memcached application that is bound to this service$/ do
  @app = create_app MEMCACHED_APP, @token
  attach_provisioned_service @app, @memcached_service, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

When /^I put a key value pair in my memcached service through my application$/ do
  uri = get_uri(@app, "storeincache")
  r = post_record_no_close(uri, { :key => 'foo', :value => 'bar'})
  r.response_code.should == 200
  r.close
end

Then /^I should be able to get the value for the key$/ do
  uri = get_uri @app, "getfromcache/foo"
  response = get_uri_contents uri
  response.should_not == nil
  response.response_code.should == 200
  contents = JSON.parse response.body_str
  contents["requested_key"].should == "foo"
  contents["value"].should == "bar"
  response.close
end

After("@creates_memcached_app") do |scenario|
  delete_app @app, @token if @app
end

After("@creates_memcached_service") do |scenario|
  delete_service @memcached_service[:name] if @memcached_service
end

