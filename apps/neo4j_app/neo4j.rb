require 'rubygems'
require 'sinatra'
require 'neography'

include Neography

before do
  if ENV['VCAP_SERVICES']
    services = ENV['VCAP_SERVICES']
    neo4j = services['neo4j-1.4'][0]['credentials']
  else
    neo4j = {}
  end
  
  Neography::Config.server = neo4j['hostname'] || 'localhost'
  Neography::Config.port =  (ENV['port'] || "7474").to_i
  Neography::Config.authentication = 'basic'
  Neography::Config.username = ENV['username']||"test"
  Neography::Config.password = ENV['password']||"test"
  
  @neo = Rest.new
  puts @neo.configuration
  @root = Node.load(0)
end

get '/healthcheck' do
  if @root
    "OK"
  else
    "FAIL: #{ENV['VMC_SERVICES']}"
  end
end

get '/' do
  "<h2>Add a Q&amp;A!</h2>" +
  "<form method='post' action='/add'>Question: <input name=question/> Answer: <input type=text name=answer/><input type=submit/></form>" +
  "<h1>Answers from Neo4j!</h1>" +
  "<dl>" +
    @root.outgoing(:ANSWER).collect { |n| "<dt>Question: #{n.question}</dt><dd>Answer: #{n.answer}</dd>"}.join +
  "</dl>"
end

post '/add' do 
  answer = params[:answer]||'Everything'
  question = params[:question]||'What?'
  node = Node.create("answer" => answer, "question" => question) 
  @root.outgoing(:ANSWER) << node
end