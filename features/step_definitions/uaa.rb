require 'rest_client'

Given /^I know the UAA service base URL$/ do
  @base = 'uaa.' + @target
end

When /^I get the login prompts$/ do
  @prompts = get_prompts
end

Then /^the content should contain prompts$/ do
  @prompts.should =~ /prompts/
end

When /^I get the user data$/ do
  pending "getting user data is temporarily disabled in the bvts"
  @content = get_url "/Users"
end

Then /^the content should be an empty list$/ do
  @content.should =~ /"resources":\[\]/
end

def get_prompts
  get_url "/login"
end

def get_url(path)
  url = @base + path
  response = RestClient.get url, {"Accept"=>"application/json"}
  response.should_not == nil
  response.code.should == 200
  response.body.should_not == nil
  response.body
end
