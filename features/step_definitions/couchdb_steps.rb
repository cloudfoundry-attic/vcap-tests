# Simple couchdb Application that uses the couchdb high performance key-value service

Given /^I have provisioned a couchdb service$/ do
  pending unless find_service 'couchdb'
  @couchdb_service = provision_couchdb_service @token
  @couchdb_service.should_not == nil
end

Given /^I have deployed a couchdb application that is bound to this service$/ do
  @app = create_app COUCHDB_APP, @token
  attach_provisioned_service @app, @couchdb_service, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

When /^I put a document in my couchdb service through my application$/ do
  uri = get_uri(@app, "storeincouchdb")
  r = post_record_no_close(uri, { :key => 'foo', :value => 'bar'})
  r.response_code.should == 200
  r.close
end

Then /^I should be able to get the document for the key$/ do
  uri = get_uri @app, "getfromcouchdb/foo"
  response = get_uri_contents uri
  response.should_not == nil
  response.response_code.should == 200
  contents = JSON.parse response.body_str
  contents["requested_key"].should == "foo"
  contents["value"].should == "bar"
  response.close
end
