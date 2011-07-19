package org.cloudfoundry.canonical.apps;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.UnknownHostException;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;

import org.cloudfoundry.runtime.env.AbstractServiceInfo;
import org.cloudfoundry.runtime.env.CloudEnvironment;
import org.cloudfoundry.runtime.env.MongoServiceInfo;
import org.cloudfoundry.runtime.env.RedisServiceInfo;
import org.cloudfoundry.runtime.service.messaging.RabbitServiceCreator;
import org.springframework.amqp.AmqpException;
import org.springframework.amqp.rabbit.connection.Connection;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;

import redis.clients.jedis.Jedis;

import com.mongodb.DBCursor;
import com.mongodb.Mongo;
import com.mongodb.DB;
import com.mongodb.DBCollection;
import com.mongodb.BasicDBObject;
import com.mongodb.MongoException;
import com.rabbitmq.client.Channel;

@Controller
public class ServiceController {

	private ReferenceDataRepository referenceRepository;

	@Autowired
	public void setReferenceRepository(
			ReferenceDataRepository referenceRepository) {
		this.referenceRepository = referenceRepository;
	}

	@RequestMapping(value = "/", method = RequestMethod.GET)
	public void hello(HttpServletResponse response) throws IOException {
		PrintWriter out = response.getWriter();
		out.print("hello from spring");
	}

	@RequestMapping(value = "/crash", method = RequestMethod.GET)
	public void crash(HttpServletResponse response) throws IOException{
		PrintWriter out = response.getWriter();
//		Thread.currentThread().interrupt();
		System.exit(0);
		out.println("it should not get here");
	}

	@RequestMapping(value = "/service/mongo/{key}", method = RequestMethod.POST)
	public void mongo_post(@RequestBody String body, @PathVariable String key,
			HttpServletResponse response) throws IOException {
		PrintWriter out = response.getWriter();
		BasicDBObject doc = new BasicDBObject();
		doc.put("key", key);
		doc.put("data_value", body);
		DBCollection coll = loadMongo();
		coll.insert(doc);
		out.print(body);
	}

	@RequestMapping(value = "/service/mongo/{key}", method = RequestMethod.GET)
	public void mongo_get(@PathVariable String key, HttpServletResponse response)
			throws IOException {
		PrintWriter out = response.getWriter();
		DBCollection coll = loadMongo();
		BasicDBObject query = new BasicDBObject();
		query.put("key", key);
		DBCursor cur = coll.find(query);
		String value = "";
		while (cur.hasNext()) {
			value = (String) cur.next().get("data_value");
		}
		out.print(value);
	}

	@RequestMapping(value = "/service/redis/{key}", method = RequestMethod.POST)
	public void redis_post(@RequestBody String body, @PathVariable String key,
			HttpServletResponse response) throws IOException {
		PrintWriter out = response.getWriter();
		Jedis jedis = loadJedis();
		jedis.set(key, body);
		out.print(body);
	}

	@RequestMapping(value = "/service/redis/{key}", method = RequestMethod.GET)
	public void redis_get(@PathVariable String key, HttpServletResponse response)
			throws IOException {
		PrintWriter out = response.getWriter();
		Jedis jedis = loadJedis();
		out.print(jedis.get(key));
	}

	@RequestMapping(value = "/service/mysql/{key}", method = RequestMethod.POST)
	public void mysql_post(@RequestBody String body, @PathVariable String key,
			HttpServletResponse response) throws IOException {
		PrintWriter out = response.getWriter();
		DataValue d = new DataValue();
		d.setId(key);
		d.setDataValue(body);
		referenceRepository.save(d);
		out.print(body);
	}

	@RequestMapping(value = "/service/mysql/{key}", method = RequestMethod.GET)
	public void mysql_get(@PathVariable String key, HttpServletResponse response)
			throws IOException {
		PrintWriter out = response.getWriter();
		DataValue d = referenceRepository.find(key);
		out.print(d.getDataValue());
	}

	@RequestMapping(value = "/service/rabbit/{key}", method = RequestMethod.POST)
	public void rabbit_post(@RequestBody String body, @PathVariable String key,
			HttpServletResponse response) throws IOException {
		PrintWriter out = response.getWriter();
		RabbitTemplate amq = loadRabbit(key);
		amq.convertAndSend(key, body);
		out.print(body);
	}

	@RequestMapping(value = "/service/rabbit/{key}", method = RequestMethod.GET)
	public void rabbit_get(@PathVariable String key,
			HttpServletResponse response) throws IOException {
		PrintWriter out = response.getWriter();
		RabbitTemplate amq = loadRabbit(key);
		out.print((String) amq.receiveAndConvert(key));
	}

	@RequestMapping(value = "/service/rabbitsrs/{key}", method = RequestMethod.POST)
	public void rabbitsrs_post(@RequestBody String body,
			@PathVariable String key, HttpServletResponse response)
			throws IOException {
		PrintWriter out = response.getWriter();
		RabbitTemplate amq = loadSRSRabbit(key);
		amq.convertAndSend(key, body);
		out.print(body);
	}

	@RequestMapping(value = "/service/rabbitsrs/{key}", method = RequestMethod.GET)
	public void rabbitsrs_get(@PathVariable String key,
			HttpServletResponse response) throws IOException {
		PrintWriter out = response.getWriter();
		RabbitTemplate amq = loadSRSRabbit(key);
		out.print((String) amq.receiveAndConvert(key));
	}

	private RabbitTemplate loadRabbit(String key) {
		try {
			Connection conn = connectionRabbit().createConnection();
			Channel channel = conn.createChannel(true);
			channel.exchangeDeclare(key, "direct");
			channel.queueDeclare(key, true, false, false, null);
			channel.close();
			return new RabbitTemplate(connectionRabbit());
		} catch (Exception e) {
			e.printStackTrace();
			throw new AmqpException("Failed to create rabbit template");
		}
	}

	private RabbitTemplate loadSRSRabbit(String key) {
		try {
			Connection conn = connectionRabbitSRS().createConnection();
			Channel channel = conn.createChannel(true);
			channel.exchangeDeclare(key, "direct");
			channel.queueDeclare(key, true, false, false, null);
			channel.close();
			return new RabbitTemplate(connectionRabbitSRS());
		} catch (Exception e) {
			e.printStackTrace();
			throw new AmqpException("Failed to create rabbit template");
		}
	}

	private ConnectionFactory connectionRabbitSRS() {
		return new RabbitSRSServiceCreator(environment()).createService();
	}

	private ConnectionFactory connectionRabbit() {
		return new RabbitServiceCreator(environment()).createSingletonService().service;
	}

	private Jedis loadJedis() {
		RedisServiceInfo service = (RedisServiceInfo) getService(RedisServiceInfo.class);
		Jedis jedis = new Jedis(service.getHost(), service.getPort());
		jedis.auth(service.getPassword());
		return jedis;
	}

	private DBCollection loadMongo() {
		Map<String, Object> service = (Map<String, Object>) getMongoSettings()
				.get("credentials");
		Mongo m = null;
		DBCollection coll = null;
		DB db = null;
		try {
			// TODO: We need to rewrite this when
			MongoServiceInfo mongoService = (MongoServiceInfo) getService(MongoServiceInfo.class);
			// org.cloudfoundry.runtime.env.MongoServiceInfo adds getUsername
			int port = ((Integer) service.get("port")).intValue();
			String host = (String) service.get("hostname");
			String name = (String) service.get("name");
			String password = (String) service.get("password");
			String username = (String) service.get("username");
			String db_name = (String) service.get("db");
			m = new Mongo(host, port);
			db = m.getDB(db_name);
			if (db.authenticate(username, password.toCharArray())) {
				coll = db.getCollection(name);
			}
		} catch (UnknownHostException e) {
		} catch (MongoException e) {
		}
		return coll;
	}

	// TODO: We need to rewrite this when
	// org.cloudfoundry.runtime.env.MongoServiceInfo adds getUsername
	private Map<String, Object> getMongoSettings() {
		CloudEnvironment env = environment();
		List<Map<String, Object>> services = env.getServices();

		for (Map<String, Object> service : services) {
			String label = (String) service.get("label");
			if (label.indexOf("mongodb-1.8") > -1) {
				return service;
			}
		}
		return null;
	}

	@RequestMapping(value = "/env", method = RequestMethod.GET)
	public void env(HttpServletResponse response) throws IOException {
		response.setContentType("text/plain");
		PrintWriter out = response.getWriter();
		CloudEnvironment env = environment();
		out.println(env.getValue("VCAP_SERVICES"));
	}

	private <T extends AbstractServiceInfo> AbstractServiceInfo getService(
			Class<T> service) {
		CloudEnvironment env = environment();
		return env.getServiceInfos(service).get(0);
	}

	@Bean
	CloudEnvironment environment() {
		return new CloudEnvironment();
	}

}
