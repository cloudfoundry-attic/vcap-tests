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
        value = @amq_msg
      end
    end
     render :text => value
  end

  private 
  
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

end
