require 'rest-client'

When /^I request a file named ([^ ]+) with the range '([^']+)'$/ do |fn, range|
  file_path = File.join(@root_dir, @config[@app]["path"], fn)
  @file_contents = File.read(file_path)

  path = VMC::Client.path(VMC::APPS_PATH, get_app_name(@app),
                          "instances", "0", "files", "app", fn)
  url = "#{@client.target}/#{path}"

  hdrs = {
    "AUTHORIZATION" => @client.auth_token,
    "Range" => "bytes=#{range}",
  }

  resp = RestClient.get(url, hdrs)

  resp.should_not == nil
  resp.code.should == 206
  resp.body.should_not == nil

  @body = resp.body
end

Then /^I should get back the final (\d+) bytes of the file\.$/ do |num_bytes|
  num_bytes = num_bytes.to_i

  @body.should == @file_contents.slice(@file_contents.size - num_bytes,
                                       num_bytes)
end

Then /^I should get back bytes (\d+)-(\d+) of the file\.$/ do |start, fin|
  start = start.to_i
  fin = fin.to_i

  num_bytes = fin - start + 1

  @body.should == @file_contents.slice(start, num_bytes)
end


