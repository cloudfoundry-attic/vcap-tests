require 'curb'

Given /^I have deployed a simple JRuby (\d+).(\d+) (\w+) application$/ do |major, minor, framework|
  pending_unless_runtime_exists(@token, "jruby#{major}#{minor}")
  app_name = "jruby#{major}#{minor}_#{framework.downcase}_simple_app"
  @app = create_app app_name, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

Given /^I have deployed a simple JRuby (\d+).(\d+) (\w+) application using the (\w+) service$/ do |major, minor, framework, service|
  pending_unless_runtime_exists(@token, "jruby#{major}#{minor}")
  app_name = "jruby#{major}#{minor}_#{framework.downcase}_#{service.downcase}_app"
  expected_health = 1.0
  health = create_and_start_app app_name, expected_health
  health.should == expected_health
end

Then /^I should get JRuby version (\d+).(\d+) information$/ do |major, minor|
  contents = get_app_contents @app
  contents.should_not == nil
  contents.body_str.should_not == nil
  contents.body_str.should =~ /RUBY_ENGINE : jruby/
  contents.body_str.should =~ /RUBY_VERSION : #{major}.#{minor}/
  contents.close
end

Then /^I should get Java Runtime Environment information$/ do
  contents = get_app_contents @app, "env_java"
  contents.should_not == nil
  contents.body_str.should_not == nil
  contents.body_str.should =~ /java\.runtime\.name: Java\(TM\) SE Runtime Environment/
  contents.body_str.should =~ /java\.runtime\.version/
  contents.body_str.should =~ /jruby\.script: jruby/
  contents.close
end

Then /^I should get Ruby On Rails Top Page$/ do
  contents = get_app_contents @app
  contents.should_not == nil
  contents.body_str.should_not == nil
  contents.body_str.should =~ /You&rsquo;re riding Ruby on Rails!/
  contents.close
end

Then /^I should get scaffolding generated index page of (\w+) model$/ do |model|
  models = "#{model.downcase}s"
  contents = get_app_contents @app, models
  contents.should_not == nil
  contents.body_str.should_not == nil
  contents.body_str.should =~ /Listing #{models}/
  contents.body_str.should =~ /#{model}/
  contents.body_str.should =~ /New #{model}/
  contents.close
end

Then /^The (\w+) model scaffolding generated page should work$/ do |model|
  models = "#{model.downcase}s"
  index_uri = models

  # get index page
  contents = get_app_contents @app, index_uri
  contents.should_not == nil
  contents.body_str.should_not == nil
  contents.body_str.should =~ /Listing #{models}/
  contents.body_str.should =~ /#{model}/
  contents.body_str.should =~ /New #{model}/
  contents.close

  # get new message page
  new_uri = "#{models}/new"
  contents = get_app_contents @app, new_uri
  contents.should_not == nil
  contents.body_str.should_not == nil
  contents.body_str.should =~ /New #{model.downcase}/
  contents.body_str.should =~ /Create #{model}/
  contents.close

  # post new message
  new_message = "Hello from VCAP"
  model_uri = "#{models}/1"
  data = [ Curl::PostField.content('message[message]', new_message) ]
  contents = post_to_app @app, models, data
  contents.should_not == nil
  contents.body_str.should_not == nil
  contents.body_str.should =~ /#{model_uri}/
  #contents.body_str.should =~ /#{model} was successfully created./
  #contents.body_str.should =~ /#{model}: #{new_message}/
  contents.close

  # get edit message page
  edit_uri = "#{model_uri}/edit"
  contents = get_app_contents @app, edit_uri
  contents.should_not == nil
  contents.body_str.should_not == nil
  contents.body_str.should =~ /Editing #{model.downcase}/
  contents.body_str.should =~ /#{new_message}/
  contents.body_str.should =~ /Update #{model}/
  contents.close

  # update message
  update_message = "Hello from the Cloud!"
  data = [ Curl::PostField.content('_method', 'put'),
           Curl::PostField.content('message[message]', update_message) ]
  contents = post_to_app @app, model_uri, data
  contents.should_not == nil
  contents.body_str.should_not == nil
  contents.body_str.should =~ /#{model_uri}/
  #contents.body_str.should =~ /#{model} was successfully updated./
  #contents.body_str.should =~ /#{model}: #{new_message}/
  contents.close

  # get index page, and check updated message
  contents = get_app_contents @app, edit_uri
  contents.should_not == nil
  contents.body_str.should_not == nil
  contents.body_str.should =~ /Editing #{model.downcase}/
  contents.body_str.should =~ /#{update_message}/
  contents.body_str.should =~ /Update #{model}/
  contents.close

  # delete message
  data = [ Curl::PostField.content('_method', 'delete') ]
  contents = post_to_app @app, model_uri, data
  contents.should_not == nil
  contents.body_str.should_not == nil
  contents.body_str.should =~ /#{index_uri}/
  #contents.body_str.should =~ /Listing #{models}/
  #contents.body_str.should =~ /#{model}/
  #contents.body_str.should =~ /New #{model}/
  #contents.body_str.should !=~ /#{update_message}/
  contents.close

end
