require 'rest_client'
require 'base64'
require 'json'
require 'yajl'

Given /^I know the ACM service base URL$/ do
  @acmbase = ENV['ACM_URL']
  pending "no acm url found in ACM_URL" unless @acmbase
end

Given /^I have the ACM credentials$/ do
  @acmuser = ENV['ACM_USER']
  @acmpassword = ENV['ACM_PASSWORD']
  pending "no acm credentials found in either ACM_USER or ACM_PASSWORD" unless @acmuser && @acmpassword
  @auth_header = {"Authorization" => "Basic " + Base64.encode64("#{@acmuser}:#{@acmpassword}").chomp}
end

Then /^a simple GET to the ACM should return a 404$/ do
  f = lambda {
    begin
      RestClient.get @acmbase, @auth_header
    rescue => e
      if e.kind_of? (RestClient::ResourceNotFound)
        return 404
      end
    end
    200
  }

  f.call.should eql 404
end

Given /^that test data has been cleaned up$/ do

  url = @acmbase + "/objects?name=bvt_test_object"
  body = nil
  begin
    response = RestClient.get url, @auth_header
    body = Yajl::Parser.parse(response.body, :symbolize_keys => true)
  rescue => e
  end

  unless body.nil?
    body.each {|obj_id|
      url = @acmbase + "/objects/#{obj_id}"
      acm_resource = RestClient::Resource.new url, :user => @acmuser, :password => @acmpassword, :timeout => 20, :open_timeout => 5
      f = lambda {
        response = 0
        begin
          response = acm_resource.delete
        rescue => e
          if e.kind_of? (RestClient::ResourceNotFound)
            return 404
          else
            return 500
          end
        end
        response.code
      }

      [200, 404].should include f.call
    }
  end

  url = @acmbase + "/permission_sets/bvt_app_space"
  acm_resource = RestClient::Resource.new url, :user => @acmuser, :password => @acmpassword, :timeout => 20, :open_timeout => 5
  f = lambda {
    response = 0
    begin
      response = acm_resource.delete
    rescue => e
      if e.kind_of? (RestClient::ResourceNotFound)
        return 404
      else
        return 500
      end
    end
    response.code
  }

  [200, 404].should include f.call

  (1..10).each { |i|
    url = @acmbase + "/users"
    acm_resource = RestClient::Resource.new url + "/bvt_test#{i}", :user => @acmuser, :password => @acmpassword, :timeout => 20, :open_timeout => 5
    f = lambda {
      response = 0
      begin
        response = acm_resource.delete
      rescue => e
        if e.kind_of? (RestClient::ResourceNotFound)
          return 404
        end
      end
      response.code
    }

    [200, 404].should include f.call
  }

  (1..2).each { |i|
    url = @acmbase + "/groups"
    acm_resource = RestClient::Resource.new url + "/g-bvt-group#{i}", :user => @acmuser, :password => @acmpassword, :timeout => 20, :open_timeout => 5
    f = lambda {
      response = 0
      begin
        response = acm_resource.delete
      rescue => e
        if e.kind_of? (RestClient::ResourceNotFound)
          return 404
        end
      end
      response.code
    }

    [200, 404].should include f.call
  }

end

Given /^I have been able to create a permission set$/ do
  url = @acmbase + "/permission_sets"

  permission_set_data = {
    :name => "bvt_app_space",
    :additional_info => "{component => cloud_controller}",
    :permissions => [:bvt_read_appspace.to_s, :bvt_write_appspace.to_s, :bvt_delete_appspace.to_s]
  }.to_json

  acm_resource = RestClient::Resource.new url, :user => @acmuser, :password => @acmpassword, :timeout => 20, :open_timeout => 5
  response = acm_resource.post permission_set_data
  response.code.should == 200
  response.body.should_not == nil
end

Given /^I have created some users$/ do
  url = @acmbase + "/users"

  (1..10).each { |i|
    acm_resource = RestClient::Resource.new url + "/bvt_test#{i}", :user => @acmuser, :password => @acmpassword, :timeout => 20, :open_timeout => 5
    response = acm_resource.post nil
    response.code.should == 200
    response.body.should_not == nil
  }

end

Given /^I have those users to some groups$/ do
  url = @acmbase + "/groups"

  group_data1 = {
    :id => "g-bvt-group1",
    :additional_info => "Developer group",
    :members => ["bvt_test1", "bvt_test3"]
  }.to_json

  acm_resource = RestClient::Resource.new url + "/g-bvt-group1", :user => @acmuser, :password => @acmpassword, :timeout => 20, :open_timeout => 5
  response = acm_resource.post group_data1
  response.code.should == 200
  response.body.should_not == nil

  group_data2= {
    :id => "g-bvt-group2",
    :additional_info => "Developer group",
    :members => ["bvt_test1", "bvt_test3", "bvt_test5", "bvt_test7", "bvt_test9"]
  }.to_json

  acm_resource = RestClient::Resource.new url + "/g-bvt-group2", :user => @acmuser, :password => @acmpassword, :timeout => 20, :open_timeout => 5
  response = acm_resource.post group_data2
  response.code.should == 200
  response.body.should_not == nil

end


When /^I try to create an object$/ do
  url = @acmbase + "/objects"

  object_data = {
    :name => "bvt_test_object",
    :additional_info => {:description => :bvt_test_object}.to_json(),
    :permission_sets => [:bvt_app_space.to_s],
    :acl => {
        :bvt_read_appspace => ["bvt_test2", "bvt_test5", "g-bvt-group2"],
        :bvt_write_appspace => ["bvt_test5"],
        :bvt_delete_appspace => ["g-bvt-group2"]
      }
  }.to_json


  acm_resource = RestClient::Resource.new url, :user => @acmuser, :password => @acmpassword, :timeout => 20, :open_timeout => 5
  response = acm_resource.post object_data
  response.code.should == 200
  response.body.should_not == nil
  body = Yajl::Parser.parse(response.body, :symbolize_keys => true)
  @object_id = body[:id]

end

Then /^I should be able to check the user's access rights$/ do
  response = RestClient.get @acmbase + "/objects/#{@object_id}/access?id=bvt_test2&p=bvt_read_appspace", @auth_header
  response.code.should == 200
end

Then /^I should be able to check the group's access rights$/ do
  response = RestClient.get @acmbase + "/objects/#{@object_id}/access?id=bvt-group2&p=bvt_delete_appspace", @auth_header
  response.code.should == 200
end

