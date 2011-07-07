package org.cloudfoundry.canonical.apps;

import java.net.URI;
import java.net.URISyntaxException;

import net.sf.json.JSONObject;
import net.sf.json.JSONSerializer;

import org.cloudfoundry.runtime.env.CloudEnvironment;
import org.cloudfoundry.runtime.service.messaging.RabbitServiceCreator;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.connection.SingleConnectionFactory;

public class RabbitSRSServiceCreator extends RabbitServiceCreator {

	private CloudEnvironment cloudEnvironment;

	public RabbitSRSServiceCreator(CloudEnvironment cloudEnvironment) {
		super(cloudEnvironment);
		this.cloudEnvironment = cloudEnvironment;
	}

	public ConnectionFactory createService() {
		String env = this.cloudEnvironment.getValue("VCAP_SERVICES");
		JSONObject jsonObject = (JSONObject) JSONSerializer.toJSON(env);
		JSONObject rabbit = (JSONObject) jsonObject.getJSONArray(
				"rabbitmq-srs-2.4.1").get(0);
		String strUrl = rabbit.getJSONObject("credentials").getString("url");
		URI uri = null;
		try {
			uri = new URI(strUrl);
		} catch (URISyntaxException e) {
			e.printStackTrace();
		}
		SingleConnectionFactory connectionFactory = new SingleConnectionFactory(
				uri.getHost());
		connectionFactory.setVirtualHost(uri.getPath().substring(1));
		connectionFactory.setUsername(uri.getUserInfo().split(":")[0]);
		connectionFactory.setPassword(uri.getUserInfo().split(":")[1]);
		connectionFactory.setPort(uri.getPort());
		return connectionFactory;
	}
}
