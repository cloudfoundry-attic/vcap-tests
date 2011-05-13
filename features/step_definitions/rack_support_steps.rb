When /^I create a rack application$/ do
  @app = create_app RACK_APP, @token
end

Given /^I have deployed a rack application$/ do
  @app = create_app RACK_APP, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

Then /^The rack app should work$/ do
  response = get_app_contents @app, '/'
  response.should_not == nil
  response.response_code.should == 200
  response.body_str.should == 'hello'
end

# Crash info for a broken (persistently broken) rack app with no Gemfile
Given /^I have deployed a broken rack application missing a Gemfile$/ do
  @app = create_app RACK_BROKEN_NO_GEMFILE_APP, @token
  upload_app @app, @token
  start_app @app, @token
  sleep 3
end