if ENV['VMC_SERVICES']
  services = JSON.parse(ENV['VMC_SERVICES'])
  if services
    mongodb_service = services.find {|service| service["vendor"].downcase == "mongodb"}
    if mongodb_service
      mongodb_service = mongodb_service["options"]
    end


    MongoMapper.connection = Mongo::Connection.new(mongodb_service['hostname'], mongodb_service['port'])
    MongoMapper.database = mongodb_service['db']
    MongoMapper.database.authenticate(mongodb_service['username'], mongodb_service['password'])
#     MongoMapper.database = 'data_values'
#     db = MongoMapper.connection[mongodb_service['db']]
#     db.authenticate(mongodb_service['username'], mongodb_service['password'])
  end
end
