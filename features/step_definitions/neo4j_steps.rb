# Simple Neo4j Application that uses the Neo4j graph database service

Given /^I have provisioned a Neo4j service$/ do
  pending unless find_service 'neo4j'
  @neo4j_service = provision_neo4j_service @token
  @neo4j_service.should_not == nil
end

Given /^I have deployed a Neo4j application that is bound to this service$/ do
  @app = create_app NEO4J_APP, @token
  attach_provisioned_service @app, @neo4j_service, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

When /^I add an answer to my application$/ do
  uri = get_uri(@app, "question")
  r = post_record_no_close(uri, { :question => 'Q1', :answer => 'A1'})
  r.response_code.should == 200
  @question_id = r.body_str.split(/\//).last
  r.close
end

Then /^I should be able to retrieve it$/ do
  uri = get_uri @app, "question/#{@question_id}"
  response = get_uri_contents uri
  response.should_not == nil
  response.response_code.should == 200
  contents = JSON.parse response.body_str
  contents["question"].should == "Q1"
  contents["answer"].should == "A1"
  response.close
end
