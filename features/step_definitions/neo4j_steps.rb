# Simple Neo4j Application that uses the Neo4j graph database service

Given /^I have deployed a Neo4j application that is backed by a Neo4j Service$/ do
  @neo4j_app = create_app NEO4J_APP, @token
  @neo4j_service = provision_neo4j_service @token
  attach_provisioned_service @neo4j_app, @neo4j_service, @token
  upload_app @neo4j_app, @token
  start_app @neo4j_app, @token
  expected_health = 1.0
  health = poll_until_done @neo4j_app, expected_health, @token
  health.should == expected_health
end

When /^I add an answer to my application$/ do
  uri = get_uri @app, "add"
  post_record uri, { :question => 'Q1', :answer => 'A1'}
end

Then /^I should be able see it on the start page$/ do
  uri = get_uri @app, ""
  contents = get_uri_contents uri
  contents.should_not == nil
  contents.include?("Q1").should_be true
  contents.include?("A1").should_be true
  contents.close
end
