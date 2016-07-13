/**
 * Listen to all sensor messages and publish them to IFTTT
 */

const mqtt = require("mqtt");
const mysql = require("mysql");

console.log("Broker: " + process.env.MQTT_BROKER);

var dbconnection = mysql.createConnection({
    host: process.env.MYSQL_HOST,
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: process.env.MYSQL_DATABASE
});

function updatesensor(sensorid, message) {
    console.log("Saving status for sensor " + sensorid + ": " + message.status)    ;
    dbconnection.query(
        'INSERT INTO sensor (chipid, mac, hostname, ip, status) ' +
        'VALUES (?, ?, ?, ?, ?) ' +
        'ON DUPLICATE KEY UPDATE mac = VALUES(mac), hostname = VALUES(hostname), ip = VALUES(ip), status = VALUES(status)',
        [message.chipid, message.mac, message.hostname, message.ip, message.status],
        function (error, results, fields) {
            if( error ) {
                console.log("Database error: " + error.stack);
            }
        }
    );
}

function storesensorvalue(sensorid, message) {
    console.log("Saving value of sensor " + sensorid + ": " + message.value);
    dbconnection.query('INSERT INTO sensorvalue (chipid, value) VALUES (?, ?)', [sensorid, message.value], function (error, results, fields) {
        if( error ) {
            console.log("Database error: " + error.stack);
        }
    });
}

dbconnection.connect(function(err) {
    if( err ) {
        console.log("Error connecting to database: " + err.stack);
    }
    else {
        console.log("Database connected.");

        const client = mqtt.connect(process.env.MQTT_BROKER);

        client.on('connect', function () {
            client.subscribe('sensor/+/value');
            client.subscribe('sensor/+/status');
        });

        client.on('message', function (topic, message) {
            try {
                var topicparts = topic.split("/")
                var sensorid = topicparts[1];
                var messagetype = topicparts[2];
                jsmessage = JSON.parse(message.toString());

                switch (messagetype) {
                    case "value":
                        console.log("Got value for sensor " + sensorid);
                        storesensorvalue(sensorid, jsmessage);
                        break;
                    case "status":
                        console.log("Got status for sensor " + sensorid);
                        updatesensor(sensorid, jsmessage);
                        break;
                }
            }
            catch (err) {
                console.log("Caught error: " + err.stack);
            }
        });
    }
});




