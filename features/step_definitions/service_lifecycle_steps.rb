# Copyright:: Copyright (c) 2011 VMware Inc.

require 'json'
require 'curb'
require 'tempfile'
require 'base64'

Then /^I check (\w+) extension is enabled$/ do |extension|
  parse_service_id unless  @service_id

  case extension
  when "snapshot" then get_snapshots
  when "serialized" then get_serialized_url
  end
end

When /^I create a snapshot of (\w+) service$/ do |service|
  parse_service_id unless  @service_id
  create_snapshot
end

Then /^I should be able to query snapshots for (\w+) service$/ do |service|
  parse_service_id unless  @service_id
  snapshots = get_snapshots
  id = snapshots["snapshots"].find {|s| s["snapshot_id"] == @snapshot_id}
  id.should_not == nil
end

When /^I rollback to previous snapshot for (\w+) service$/ do |service|
  parse_service_id unless  @service_id
  rollback_snapshot @snapshot_id
end

When /^I create a serialized URL of (\w+) service$/ do |service|
  parse_service_id unless  @service_id
  @serialized_url = get_serialized_url
end

Then /^I should be able to download data from serialized URL$/ do
  temp_file = Tempfile.new('serialized_data')
  File.open(temp_file.path, "wb+") do |f|
    c = Curl::Easy.new(@serialized_url)
    c.on_body{|data| f.write(data)}
    c.perform
    c.response_code.should == 200
  end
  File.open(temp_file.path) do |f|
    f.size.should > 0
  end
  @serialized_data_file = temp_file
end

When /^I import serialized data from URL of (\w+) service$/ do |service|
  parse_service_id unless  @service_id
  import_service_from_url @serialized_url
end

When /^I import serialized data from request of (\w+) service$/ do |service|
  parse_service_id unless  @service_id
  import_service_from_data @serialized_data_file
end

def create_snapshot
  easy = Curl::Easy.new
  easy.url = "#{@base_uri}/services/v1/configurations/#{@service_id}/snapshots"
  easy.headers = auth_headers
  easy.resolve_mode =:ipv4
  easy.http_post

  easy.response_code.should == 200
  resp = easy.body_str
  resp.should_not == nil
  job = JSON.parse(resp)
  job = wait_job(job["job_id"])
  job.should_not == nil
  job["result"]["snapshot_id"].should_not == nil
  @snapshot_id = job["result"]["snapshot_id"]
end

def lifecycle_cleanup
  # delete app and service manually
  delete_service @service[:name] if @service
  @service = nil
  delete_app @app, @token if @app
  @app = nil
end

def get_snapshots
  easy = Curl::Easy.new("#{@base_uri}/services/v1/configurations/#{@service_id}/snapshots")
  easy.headers = auth_headers
  easy.resolve_mode =:ipv4
  easy.http_get

  unless easy.response_code == 200
    lifecycle_cleanup
    pending "Snapshot extension is disabled, return code=#{easy.response_code}"
  end

  resp = easy.body_str
  resp.should_not == nil
  JSON.parse(resp)
end

def rollback_snapshot(snapshot_id)
  easy = Curl::Easy.new("#{@base_uri}/services/v1/configurations/#{@service_id}/snapshots/#{snapshot_id}")
  easy.headers = auth_headers
  easy.resolve_mode =:ipv4
  easy.http_put ''

  easy.response_code.should == 200
  resp = easy.body_str
  resp.should_not == nil
  job = JSON.parse(resp)
  job = wait_job(job["job_id"])
  job.should_not == nil
  job["result"]["result"].should == "ok"
end

def get_serialized_url
  easy = Curl::Easy.new("#{@base_uri}/services/v1/configurations/#{@service_id}/serialized/url")
  easy.headers = auth_headers
  easy.resolve_mode =:ipv4
  easy.http_get

  unless easy.response_code == 200
    lifecycle_cleanup
    pending "Serialzed API is disabled, return code=#{easy.response_code}"
  end
  resp = easy.body_str
  resp.should_not == nil
  job = JSON.parse(resp)
  job = wait_job(job["job_id"])
  job["result"]["url"].should_not == nil
  job["result"]["url"]
end


def import_service_from_url(url)
  easy = Curl::Easy.new("#{@base_uri}/services/v1/configurations/#{@service_id}/serialized/url")
  easy.headers = auth_headers
  payload = {"url" => url}
  easy.resolve_mode =:ipv4
  easy.http_put(JSON payload)

  resp = easy.body_str
  resp.should_not == nil
  job = JSON.parse(resp)
  job = wait_job(job["job_id"])
  job.should_not == nil
  job["result"]["result"].should == "ok"
end

def import_service_from_data(temp_file)
  content = nil
  File.open(temp_file.path, "rb") do |f|
    content = f.read
  end

  payload = {"data" => Base64.encode64(content)}
  easy = Curl::Easy.new("#{@base_uri}/services/v1/configurations/#{@service_id}/serialized/data")
  easy.headers = auth_headers
  easy.resolve_mode =:ipv4
  easy.http_put(JSON payload)

  resp = easy.body_str
  resp.should_not == nil
  job = JSON.parse(resp)
  job = wait_job(job["job_id"])
  job.should_not == nil
  job["result"]["result"].should == "ok"
end

def auth_headers
  {"content-type"=>"application/json", "AUTHORIZATION" => get_login_token}
end

def parse_service_id
  uri = get_uri @app, "env"
  resp = get_uri_contents uri
  resp.should_not == nil
  services = JSON.parse resp.body_str
  services.each do |srv|
    if srv["name"] == @service[:name]
      srv_id = srv["options"]["name"]
      @service_id = srv_id
      break
    end
  end
  @service_id
end

def wait_job(job_id)
  timeout = @config["job_timeout_secs"]
  sleep_time = @config["sleep_secs"]
  while timeout > 0
    sleep sleep_time
    timeout -= sleep_time

    job = get_job(job_id)
    return job if job_completed?(job)
  end
  # failed
  nil
end

def get_job(job_id)
  easy = Curl::Easy.new("#{@base_uri}/services/v1/configurations/#{@service_id}/jobs/#{job_id}")
  easy.headers = auth_headers
  easy.resolve_mode =:ipv4
  easy.http_get

  resp = easy.body_str
  resp.should_not == nil
  JSON.parse(resp)
end

def job_completed?(job)
  return true if job["status"] == "completed" || job["status"] == "failed"
end
