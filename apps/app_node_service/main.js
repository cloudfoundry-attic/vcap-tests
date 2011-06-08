var sys = require("sys");
var http = require('http');
var url_lib = require('url');
var mongoose = require('mongoose');
var msg_value="";

var port = process.env.VMC_APP_PORT || 8080;

var server = http.createServer( function(req, res) {
  var url = url_lib.parse(req.url);
  var path = url.pathname;
  if(path === '/hello') {
    res.writeHead(200, { 'content-type': 'text/plain' });
    res.end('Hello from node.js');
  } else if(path === '/env') {
    var services =  eval('(' + process.env.VMC_SERVICES + ')');
    res.writeHead(200, { 'content-type': 'text/plain' });
    res.end('env: '+ sys.inspect(services));
  } else if(path === '/crash') {
    res.writeHead(500, { 'content-type': 'text/plain' });
    res.end('it should crash');
  }
  else if(path.match(/\/service/)) {
    var service = path.split('/')[2];
    var key = path.split('/')[3];
    if(req.method === 'GET') {
      if(service === 'redis') {
        value = redis_get(key);
      }else if(service === 'mongo') {
        value = mongo_get(key);
      }else if(service === 'mysql') {
        value = mysql_get(key);
      }else if(service === 'rabbit') {
        value = msg_value;
      }
      res.end(value);
    } else if(req.method === 'POST') {
      var qs = require('querystring');
      var value = '';
      var body = '';
      req.on('data', function (data) {
        body += data;
      });
      setTimeout(function() {
        value = body;
        if(service === 'redis') {
          redis_post(key, value);
        }else if(service === 'mongo') {
          mongo_post(key, value);
        }else if(service === 'mysql') {
          mysql_post(key, value);
        }else if(service === 'rabbit') {
          rabbit(key, value);
        }
        res.end(value);
      }, 100 );
    }
  } else {
   res.writeHead(404);
   res.end('');
  }
});

server.listen(port);

function redis_get(key){
  var client = redis_services();
  var v =  client.get(key, function (err, reply) {
    v = reply.toString();
    return v; //, function(err, value) { return value; });
  });
  client.end();
  return v;
}

function redis_post(key, value){
  var client= redis_services();
  client.set(key, value);
  client.end();
}

function mysql_post(key, value){
  db = mysql_services();
  db.query('insert into data_values (id, data_value) values(\''+key+'\',\''+value+'\');');
  db.close();
}

function mysql_get(key){
  db = mysql_services();
  var v = dump_rows(db.query('select data_value from  data_values where id = '+ key));
  db.close();
  return v;
}

function mongo_post(key, value){
  var db = mongo_services();
  var coll = mongoose.noSchema('test',db);
  data_value = mongoose.get('data_values',db);
  d = new data_value({ "id": key, "data_value": value });
  d.save();
}

function mongo_get(key){
  var db = mongo_services();
  var coll = mongoose.noSchema('test',db);
  data_value = mongoose.get('data_values',db);
  return data_value.find({ "id": key } ).data_value;
}

function mongo_services(){
  var mongo_service = load_service('mongo');
  db = mongoose.createConnection("mongo://"
                                 + mongo_service["username"]
                                 + ":" + mongo_service["password"]
                                 + "@" + mongo_service["hostname"]
                                 + ":" + mongo_service["port"]
                                 + "/" + mongo_service["db"]);
  return db;
}

function mysql_services(){
  var mysql_service = load_service('mysql');

  var db = require("./lib/nodejs-mysql-native").createTCPClient( mysql_service['hostname'], mysql_service['port'] );
  db.auto_prepare = true;
  db.auth(mysql_service['name'], mysql_service['user'], mysql_service['password'] );
  return db;
}


function redis_services(){
  var redis_service = load_service('redis');
  var redis = require("./lib/node_redis");
  var client = redis.createClient(redis_service['port'], redis_service['hostname']);
  client.auth(redis_service['password']);
  return client;
}

function load_service(service_name){
  var services =  eval('(' + process.env.VMC_SERVICES + ')');
  var service = null;
  services.forEach(function(s){
    if(s.vendor.toLowerCase() === service_name.toLowerCase()){
      service = s.options;
    }
  });
  return service;
}

function rabbit(key, value){
  var service = load_service('rabbitmq');
  var connection = amqp.createConnection({ :host => service['hostname'], :port => service['port'], :user => service['user'], :password => service['pass'], :vhost => service['vhost'] );
  connection.addListener('ready', function(){
    var exchange = connection.exchange(key);
    var queue = connection.queue(key);
    exchange.publish(key, value);
    queue.subscribe( {ack:true}, function(message){
      msg_value = message.data.toString();
      queue.shift()
    });
  });
}


