Then /^it should not be on Cloud Foundry$/ do
  status = get_app_status @app, @token
  status.should == nil
end
