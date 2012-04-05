When /^I have postgresql max db size setting$/ do
  unless @service_quota_pg_maxdbsize
    pending "service quota: postgresql max db size is not provided."
  end
end

Given /^I have provisioned a postgresql service$/ do
  pending unless find_service 'postgresql'
  @postgresql_quota_service = provision_postgresql_quota_service
  @postgresql_quota_service.should_not == nil
end

Given /^I have deployed a service quota application that is bound to this service$/ do
  @app = create_app SERVICE_QUOTA_APP, @token
  attach_provisioned_service @app, @postgresql_quota_service, @token
  upload_app @app, @token
  start_app @app, @token
  expected_health = 1.0
  health = poll_until_done @app, expected_health, @token
  health.should == expected_health
end

Then /^I should be able to create a table$/ do
  uri = get_uri(@app, '/service/postgresql/tables/quota_table')
  r = post_uri(uri, '')
  r.response_code.should == 200
  r.body_str.should == 'quota_table'
  r.close
end

Then /^I should be able to insert data under quota$/ do
  mega = @service_quota_pg_maxdbsize.to_i - 1
  uri = get_uri(@app, "/service/postgresql/tables/quota_table/#{mega}")
  r = post_uri(uri, '')
  r.response_code.should == 200
  r.body_str.should == 'ok'
  r.close
end

When /^I insert more data to be over quota$/ do
  uri = get_uri(@app, '/service/postgresql/tables/quota_table/2')
  r = post_uri(uri, '')
  r.response_code.should == 200
  r.close
  sleep 2
end

Then /^I should not be able to insert data any more$/ do
  uri = get_uri(@app, '/service/postgresql/tables/quota_table/2')
  r = post_uri(uri, '')
  r.response_code.should == 200
  r.body_str.should == "ERROR:  permission denied for relation quota_table\n"
  r.close
end

Then /^I should not be able to create objects any more$/ do
  uri = get_uri(@app, '/service/postgresql/tables/test_table')
  r = post_uri(uri, '')
  r.response_code.should == 200
  r.body_str.should == "ERROR:  permission denied for schema public\n"
  #
  uri = get_uri(@app, '/service/postgresql/functions/test_func')
  r = post_uri(uri, '')
  r.response_code.should == 200
  r.body_str.should == "ERROR:  permission denied for schema public\n"
  #
  uri = get_uri(@app, '/service/postgresql/sequences/test_seq')
  r = post_uri(uri, '')
  r.response_code.should == 200
  r.body_str.should == "ERROR:  permission denied for schema public\n"
  r.close
end

When /^I delete data from the table$/ do
  uri = get_uri(@app, '/service/postgresql/tables/quota_table/data')
  r = delete_uri(uri)
  r.response_code.should == 200
  r.close
  sleep 2
end

Then /^I should be able to insert data again$/ do
  uri = get_uri(@app, '/service/postgresql/tables/quota_table/2')
  r = post_uri(uri, '')
  r.response_code.should == 200
  r.body_str.should == 'ok'
  r.close
end

Then /^I should be able to create objects$/ do
  uri = get_uri(@app, '/service/postgresql/tables/test_table')
  r = post_uri(uri, '')
  r.response_code.should == 200
  r.body_str.should == 'test_table'
  #
  uri = get_uri(@app, '/service/postgresql/functions/test_func')
  r = post_uri(uri, '')
  r.response_code.should == 200
  r.body_str.should == 'test_func'
  #
  uri = get_uri(@app, '/service/postgresql/sequences/test_seq')
  r = post_uri(uri, '')
  r.response_code.should == 200
  r.body_str.should == 'test_seq'
  r.close
end
