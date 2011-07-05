package org.cloudfoundry.canonical.apps;

import java.util.Map;

import org.cloudfoundry.runtime.env.CloudEnvironment;
import org.cloudfoundry.runtime.env.RabbitServiceInfo;
import org.cloudfoundry.runtime.service.messaging.RabbitServiceCreator;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.connection.SingleConnectionFactory;

//TODO: Remove this once Env has hostname and host on it.
public class CorrectRabbitServiceCreator extends RabbitServiceCreator {
	
	public CorrectRabbitServiceCreator(CloudEnvironment cloudEnvironment) {
		super(cloudEnvironment);
	}

	public ConnectionFactory createService(RabbitServiceInfo serviceInfo) {
		SingleConnectionFactory connectionFactory = (SingleConnectionFactory) super.createService(serviceInfo);
		connectionFactory.setHost(serviceInfo.getHost());
		return connectionFactory;
	}
	
}

class CorrectRabbitServiceInfo extends RabbitServiceInfo {
	
	Map<String,Object> credentials;
	
	public CorrectRabbitServiceInfo(Map<String, Object> serviceInfo){
		super(serviceInfo);
		this.credentials = (Map<String, Object>) serviceInfo.get("credentials");
	}
	
	public String getHost() {
		String host = (String) credentials.get("host");
    if(host == null){
      host = (String) credentials.get("hostname");
    }
    return host;
	}
}
