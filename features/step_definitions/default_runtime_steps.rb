
When /^I query (\w+) framework information$/ do |framework|
 pending_unless_framework_exists(@token, framework)
 pending_unless_default_runtime_info_exists
end

Given /^I should get (\w+) as a default runtime of (\w+) framework$/ do |runtime, framework|
  pending_unless_runtime_exists(runtime)
  default_runtime = get_default_runtime(framework)
  default_runtime.should == runtime
end

Given /^I should not get any default runtime of (\w+) framework$/ do |framework|
  default_runtime = get_default_runtime(framework)
  default_runtime.should == nil
end
