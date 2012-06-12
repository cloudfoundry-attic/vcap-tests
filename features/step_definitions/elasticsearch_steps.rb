# Simple elasticsearch Application that uses the elasticsearch text search service

Given /^I have provisioned an elasticsearch service$/ do
  pending unless find_service 'elasticsearch'
  @elasticsearch_service = provision_elasticsearch_service @token
  @elasticsearch_service.should_not == nil
end

Given /^I have deployed an elasticsearch application that is bound to this service$/ do
  @app = create_app ELASTICSEARCH_APP, @token
  attach_provisioned_service @app, @elasticsearch_service, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

When /^I add a document in my elasticsearch service through my application$/ do
  uri = get_uri(@app, "es/save")
  @elasticsearch_doc_id = "foo"
  response = post_uri(uri, "id=#{@elasticsearch_doc_id}&message=bar")
  response.response_code.should == 200
  response.body_str.include?('"ok":true').should == true
  response.close
end

Then /^I should be able to get it$/ do
  uri = get_uri(@app, "es/get/#{@elasticsearch_doc_id}")
  response = get_uri_contents uri
  response.should_not == nil
  response.response_code.should == 200
  response.body_str.include?('"exists":true').should == true
  response.close
end
