require 'sinatra'
require 'redis'
require 'json'
require 'mongo'
require 'mysql2'
require 'mq'

@amq_msg
get '/hello' do
  'Hello from Sinatra'
end

get '/crash' do
  raise "This should crash!!!!"
end

get '/service/redis/:key' do
  redis = load_redis
  redis[params[:key]]
end

post '/service/redis/:key' do
  redis = load_redis
  redis[params[:key]] = request.env["rack.input"].read
end

post '/service/mongo/:key' do
  coll = load_mongo
  value = request.env["rack.input"].read 
  coll.insert( { '_id' => params[:key], 'data_value' => value } )  
  value
end

get '/service/mongo/:key' do
  coll = load_mongo
  coll.find('_id' => params[:key]).to_a.first['data_value']
end

not_found do
  'This is nowhere to be found.'
end

post '/service/mysql/:key' do
  client = load_mysql
  value = request.env["rack.input"].read 
  result = client.query("insert into data_values (id, data_value) values('#{params[:key]}','#{value}');")
  value 
end

get '/service/mysql/:key' do
  client = load_mysql
  result = client.query("select data_value from  data_values where id = '#{params[:key]}'")
  result.first['data_value']
end

post '/service/rabbit/:key' do
  value = request.env["rack.input"].read 
  rabbit(params[:key], value)
  value 
end

get '/service/rabbit/:key' do
  @amq_msg
end

def load_redis
  redis_service = load_service('redis')
  Redis.new({:host => redis_service["hostname"], :port => redis_service["port"], :password => redis_service["password"]})
end

def load_mysql
  mysql_service = load_service('mysql') 
  client = Mysql2::Client.new(:host => mysql_service['hostname'], :username => mysql_service['user'], :port => mysql_service['port'], :password => mysql_service['password'], :database => mysql_service['name'])
  result = client.query("SELECT table_name FROM information_schema.tables WHERE table_name = 'data_values'");
  client.query("Create table data_values ( id varchar(20), data_value varchar(20)); ") if result.count != 1 
  client
end

def load_mongo
  mongodb_service = load_service('mongodb') 
  conn = Mongo::Connection.new(mongodb_service['hostname'], mongodb_service['port'])
  db = conn[mongodb_service['db']]
  coll = db['data_values'] if db.authenticate(mongodb_service['username'], mongodb_service['password'])
end

def load_service(service_name)
  services = JSON.parse(ENV['VMC_SERVICES'])
  service = services.find {|service| service["vendor"].downcase == service_name}
  service = service["options"] if service
end

def rabbit(key, value)
  service = ENV['VMC_SERVICES']
  EventMachine.run do
    connection = AMQP.start(:host => service['hostname'], :port => service['port'], :user => service['user'], :password => service['pass'], :vhost => service['vhost'] )
    channel  = AMQP::Channel.new(connection)
    queue    = channel.queue(key, :auto_delete => true)
    exchange = channel.direct("")
    queue.subscribe do |payload|
      connection.close {
        EventMachine.stop { exit }
      }
    end

    exchange.publish value, :routing_key => queue.name
  end
  
end

