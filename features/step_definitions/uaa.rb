require 'singleton'
require 'rest_client'

class UaaHelper
  include Singleton

  attr_writer :uaabase

  def initialize
    @admin_client = ENV['VCAP_BVT_ADMIN_CLIENT'] || "admin"
    @admin_secret = ENV['VCAP_BVT_ADMIN_SECRET'] || "adminsecret"
    puts "** Using admin client: '#{@admin_client}' (set environment variables VCAP_BVT_ADMIN_CLIENT / VCAP_BVT_ADMIN_SECRET to override) **"
  end

  def webclient

    return @webclient if @webclient

    begin
      token = client_token(@admin_client, @admin_secret)
    rescue RestClient::Unauthorized
      puts "Unauthorized admin client (check your config or env vars)"
    end
    return nil unless token

    client_id = "testapp"
    begin
      response = JSON.parse(get_url "/oauth/clients/#{client_id}", "Authorization"=>"Bearer #{token}")
      @webclient = {:client_id=>response["client_id"]}
    rescue RestClient::ResourceNotFound
      @webclient = register_client({:client_id=>client_id, :client_secret=>"appsecret", :authorized_grant_types=>["authorization_code"]}, token)
    rescue RestClient::Unauthorized
      puts "Unauthorized admin client not able to create new client"
    end

    @webclient

  end

  def client_token(client_id, client_secret)
    url = @uaabase + "/oauth/token"
    response = RestClient.post url, {:client_id=>client_id, :grant_type=>"client_credentials", :scope=>"read write password"}, {"Accept"=>"application/json", "Authorization"=>basic_auth(client_id, client_secret)}
    response.should_not == nil
    response.code.should == 200
    JSON.parse(response.body)["access_token"]
  end

  def login(username, password)
    url = @uaabase + "/login.do"
    response = RestClient.post url, {:username=>username, :password=>password}, {"Accept"=>"application/json"} { |response, request, result| response }
    response.should_not == nil
    response.code.should == 302
    response.headers
  end

  def register_client(client, token)
    url = @uaabase + "/oauth/clients"
    response = RestClient.post url, client.to_json, {"Authorization"=>"Bearer #{token}", "Content-Type"=>"application/json"}
    response.should_not == nil
    response.code.should == 201
    client
  end

  def basic_auth(id, secret)
    "Basic " + Base64::strict_encode64("#{id}:#{secret}")
  end

  def get_url(path,headers={})
    url = @uaabase + path
    headers[:accept] = "application/json"
    response = RestClient.get url, headers
    response.should_not == nil
    response.code.should == 200
    response.body.should_not == nil
    response.body
  end

  def get_status(path)
    url = @uaabase + path
    begin
      response = RestClient.get url, {"Accept"=>"application/json"}
      response.code
    rescue RestClient::Exception => e
      e.http_code
    end
  end

end

Given /^I know the UAA service base URL$/ do
  @uaabase = @client.info[:authorization_endpoint]
  @uaahelper = UaaHelper.instance
  @uaahelper.uaabase = @uaabase
end

Given /^I have an authenticated user session$/ do
  headers = @uaahelper.login(test_user,test_passwd)
  @cookie = headers[:set_cookie][0]
  headers[:location].should == "#{@uaabase}/"
end

Given /^there is a registered webapp client$/ do
  @webclient = @uaahelper.webclient
  pending "Client registration unsuccessful" unless @webclient
end

When /^I get the approval prompts$/ do
  @uaahelper.get_url "/oauth/authorize?response_type=code&client_id=#{@webclient[:client_id]}&redirect_uri=http://anywhere.com", "Cookie" => @cookie
  response = @uaahelper.get_url "/oauth/confirm_access", "Cookie" => @cookie
  @approval = JSON.parse(response)
end

Then /^the content should contain the correct paths$/ do
  @approval["options"].should_not == nil
end

When /^I get the login prompts$/ do
  @prompts = @uaahelper.get_url "/login"
end

Then /^the content should contain prompts$/ do
  @prompts.should =~ /prompts/
end

When /^I try and get the user data$/ do
  @code = @uaahelper.get_status "/Users"
end

Then /^the response should be UNAUTHORIZED$/ do
  @code.should == 401
end
