#!/usr/bin/env ruby
# -*- mode: ruby -*-
# Copyright (c) 2009-2011 VMware, Inc.

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __FILE__)
require "rubygems"
require "bundler/setup"
require 'sinatra'
require 'thin'
require 'logger'
require 'yajl'

atmos = {}
obj_id = nil
client = nil
test = nil

$:.unshift File.join(File.dirname(__FILE__),'lib','atmos')
require 'atmos_client'

svcs = ENV['VMC_SERVICES']
if svcs
  svcs = Yajl::Parser.parse(svcs)
  svcs.each do |svc|
    if svc["name"] =~ /atmos/
      opts = svc["options"]
      atmos[:host] = opts["host"]
      atmos[:uid] = opts["token"]
      atmos[:sid] = opts["subtenant_id"]
      atmos[:key] = opts["shared_secret"]
      atmos[:port] = opts["port"]
      client = AtmosClient.new(atmos)
    end
  end
end

get '/service' do
  ENV['VCAP_SERVICES']
end

get '/env' do
  res = ''
  ENV.each do |k, v|
    res << "#{k}: #{v}<br/>"
  end
  res
end

get '/config' do
  res = ''
  config = atmos
  if config
    config.each do |k, v|
      res << "#{k}: #{v}<br/>"
    end
  end
  res
end

post '/object' do
  content = request.body.read
  res = client.create_obj(content)
  obj_id = res['location']
  obj_id.to_s
end

get '/object' do
  res = client.get_obj(obj_id)
  res.body
end

post '/test' do
  test = request.body.read
end


get '/test' do
  test
end
