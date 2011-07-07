class ServiceController < ApplicationController

  def hello
    render :text => 'hello from rails'
  end

  def env
    render :text => ENV['VMC_SERVICES']
  end

  def crash
    raise "It should crash"
  end

  def service
    value = ''
    if request.post?
      value = request.raw_post
      if params[:service] == 'redis'
        $redis[params[:key]] = value
      elsif params[:service] == 'mysql'
        DataValue.new(:key => params[:key], :data_value => value).save
      elsif params[:service] == 'mongo'
        MongoDataValue.new(:key => params[:key], :data_value => value).save
      elsif params[:service] == 'rabbit'
        client = rabbit_service
        value = write_to_rabbit(params[:key], value, client)
      elsif params[:service] == 'rabbitsrs'
        client = rabbit_srs_service
        value = write_to_rabbit(params[:key], value, client)
      end
    else
      if params[:service] == 'redis'
        value = $redis[params[:key]]
      elsif params[:service] == 'mysql'
        value = DataValue.where(:key => params[:key]).first.data_value
      elsif params[:service] == 'mongo'
        value = MongoDataValue.find_by_key(params[:key]).data_value
      elsif params[:service] == 'rabbit'
        client = rabbit_service
        value = read_from_rabbit params[:key], client
      elsif params[:service] == 'rabbitsrs'
        client = rabbit_srs_service
        value = read_from_rabbit params[:key], client
      end
    end
     render :text => value
  end

  private 
  
  def load_service(service_name)
    services = JSON.parse(ENV['VMC_SERVICES'])
    service = services.find {|service| service["vendor"].downcase == service_name}
    service = service["options"] if service
  end

  def rabbit_srs_service
    service = load_service('rabbitmq-srs')
    uri = URI.parse(service['url'])
    host = uri.host
    port = uri.port
    user = uri.user
    pass = uri.password
    vhost = uri.path[1..uri.path.length]
    Carrot.new( :host => host, :port => port, :user => user, :pass => pass, :vhost => vhost )
  end

  def write_to_rabbit(key, value, client)
    q = client.queue(key)
    q.publish(value)
  end

  def read_from_rabbit(key, client )
    q = client.queue(key)
    msg = q.pop(:ack => true)
    q.ack
    msg
  end

  def rabbit_service
    service = load_service('rabbitmq')
    Carrot.new( :host => service['hostname'], :port => service['port'], :user => service['user'], :pass => service['pass'], :vhost => service['vhost'] )
  end
end
