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
     puts "this hsould always run"
    if request.post?
      value = request.raw_post
      if params[:service] == 'redis'
        $redis[params[:key]] = value
      elsif params[:service] == 'mysql'
        DataValue.new(:key => params[:key], :data_value => value).save
      elsif params[:service] == 'mongo'
        MongoDataValue.new(:key => params[:key], :data_value => value).save
      elsif params[:service] == 'rabbit'
        rabbit(params[:key], value)
      end
    else
      if params[:service] == 'redis'
        value = $redis[params[:key]]
      elsif params[:service] == 'mysql'
        value = DataValue.where(:key => params[:key]).first.data_value
      elsif params[:service] == 'mongo'
        value = MongoDataValue.find_by_key(params[:key]).data_value
      elsif params[:service] == 'rabbit'
        filename = "./#{params[:key]}.txt"
        puts "does this file exists? #{File.exists?(filename)}"
        File.open(filename, 'r') {|f| value = f.read }
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

  def rabbit(key, value)
    service = load_service('rabbitmq')
    EM.fork do
     AMQP.start(:host => service['hostname'], :port => service['port'], :user => service['user'], :password => service['pass'], :vhost => service['vhost'] ) do |connection|
        channel  = AMQP::Channel.new(connection)
        queue    = channel.queue( key , :auto_delete => true)
        queue.publish value, :routing_key => queue.name
        queue.pop do |payload|
          File.open("./#{key}.txt", 'w') {|f| f.write(payload) }
          puts "it should show"
          EM.stop { exit }
          connection.close{ EM.stop }
          
        end
      end
    end
  end
end
