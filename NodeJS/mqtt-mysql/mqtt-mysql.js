/**
 * Listen to all sensor messages and publish them to IFTTT
 */

const Promise = require("bluebird");
const mqtt = require("mqtt");
const mysql = require("promise-mysql");

var dbConnection;

function updatesensor(sensorid, message) {
    dbConnection.query(
        'INSERT INTO sensor (chipid, mac, hostname, ip, status) ' +
        'VALUES (?, ?, ?, ?, ?) ' +
        'ON DUPLICATE KEY UPDATE mac = VALUES(mac), hostname = VALUES(hostname), ip = VALUES(ip), status = VALUES(status)',
        [message.chipid, message.mac, message.hostname, message.ip, message.status]
    ).then(function(results, fields) {
        console.log("Saved status for sensor " + sensorid + ": " + message.status);
    }).catch(function(e) {
        console.log("Database error: ", e);
    });
}

function storesensorvalue(sensorid, message) {
    dbConnection.query(
        'INSERT INTO sensorvalue (chipid, value) VALUES (?, ?)',
        [sensorid, message.value]
    ).then(function(results, fields) {
        console.log("Saved value for sensor " + sensorid + ": " + message.value);
    }).catch(function(e) {
        console.log("Database error: ", e);
    });
}

function handleMessage(topic, message) {
    try {
        var topicParts = topic.split("/")
        var sensorId = topicParts[1];
        var messageType = topicParts[2];
        var parsedMessage = JSON.parse(message.toString());

        switch (messageType) {
            case "value":
                console.log("Got value for sensor " + sensorId);
                storesensorvalue(sensorId, parsedMessage);
                break;
            case "status":
                console.log("Got status for sensor " + sensorId);
                updatesensor(sensorId, parsedMessage);
                break;
        }
    }
    catch (e) {
        console.log("Caught error handling message: ", e);
    }
}


mysql.createConnection({
    host: process.env.MYSQL_HOST,
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: process.env.MYSQL_DATABASE
}).then(function(conn) {
    dbConnection = conn;
}).then(function() {
    mqtt.connect(process.env.MQTT_BROKER)
        .subscribe('sensor/+/value')
        .subscribe('sensor/+/status')
        .on('message', handleMessage);
}).catch(function(e) {
    console.log("Error connecting to database: ", e);
});





