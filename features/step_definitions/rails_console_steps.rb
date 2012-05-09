require 'vmc'

When /^I first access console of my application$/ do
  #Console may not be available immediately after app start
  #if system is under heavy load.  Try a few times.
  3.times do
    begin
      console_output = run_console get_app_name @app
      #Due to small bug in vmc console_login method, the prompt may or may
      #not be pre-pended with "Switch to inspect mode \n".  Pull out the last line
      #just in case
      prompt = console_output.split("\n")[-1]
      @console_response = [prompt]
      break
    rescue VMC::Cli::CliExit
      sleep 1
    end
  end
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

Then /^I should get response including (.+) from console of my application$/ do |expected|
  @console_response.should_not == nil
  matched = false
  @console_response.each do |response|
    matched = true if response=~ /#{Regexp.escape(expected)}/
  end
  matched.should == true
end

Then /^I should get completion results (.+) from console of my application$/ do |expected|
  expected_results = expected.split(",")
  expected_results.should == @console_tab_response
end

Then /^I close console$/ do
  close_console
  delete_caldecott
end

def run_console(appname)
  @console_cmd = VMC::Cli::Command::Apps.new
  @console_cmd.client(@client)
  local_console_port = @console_cmd.console appname, false
  creds = @console_cmd.console_credentials appname
  @console_cmd.console_login(creds, local_console_port)
end

def delete_caldecott
  begin
    @client.delete_app('caldecott')
  rescue
  end
end

def close_console
  @console_cmd.close_console if @console_cmd
end
