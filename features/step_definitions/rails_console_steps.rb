require 'vmc'

When /^I first access console of my application$/ do
  prompt = run_console get_app_name @app
  @console_response = [prompt]
end

When /^I send command (.+) to console of my application$/ do |cmd|
  @console_response = @console_cmd.send_console_command(cmd)
end

When /^I send tab completion (.+) to console of my application$/ do |cmd|
  #IRB wants tab twice before it gives up the data
  @console_cmd.console_tab_completion_data(cmd)
  @console_tab_response = @console_cmd.console_tab_completion_data(cmd)
end

Then /^I should get responses (.+) from console of my application$/ do |expected|
  expected_results = expected.split(",")
  expected_results.should == @console_response
end

Then /^I should get completion results (.+) from console of my application$/ do |expected|
  expected_results = expected.split(",")
  expected_results.should == @console_tab_response
end

Given /^I have my application console running$/ do
  @console_cmd.should_not == nil
end

Then /^I close my console connection$/ do
  @console_cmd.close_console
end

Then /^I delete caldecott$/ do
  response = @client.delete_app('caldecott')
  response[0].should == 200
  status = get_app_status 'caldecott', @token
  status.should == nil
end

Given /^I have caldecott running$/ do
  begin
    status = @client.app_info('caldecott')
  rescue
    status = nil
  end
  status.should_not == nil
end

def run_console(appname)
  @console_cmd = VMC::Cli::Command::Apps.new
  @console_cmd.client(@client)
  local_console_port = @console_cmd.console appname, false
  creds = @console_cmd.console_credentials appname
  @console_cmd.console_login(creds, local_console_port)
end

