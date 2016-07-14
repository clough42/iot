/**
 * Listen to all sensor messages and publish them to IFTTT
 */

const Promise = require("bluebird");
const mqtt = require("mqtt");
const mysql = require("mysql");


function updatesensor(sensorid, message) {
    dbQuery(
        'INSERT INTO sensor (chipid, mac, hostname, ip, status) ' +
        'VALUES (?, ?, ?, ?, ?) ' +
        'ON DUPLICATE KEY UPDATE mac = VALUES(mac), hostname = VALUES(hostname), ip = VALUES(ip), status = VALUES(status)',
        [message.chipid, message.mac, message.hostname, message.ip, message.status]
    ).then(function(results, fields) {
        console.log("Saved status for sensor " + sensorid + ": " + message.status);
    }).catch(function(e) {
        console.log("Database error: " + e.stack);
    });
}

function storesensorvalue(sensorid, message) {
    dbQuery(
        'INSERT INTO sensorvalue (chipid, value) VALUES (?, ?)',
        [sensorid, message.value]
    ).then(function(results, fields) {
        console.log("Saved value for sensor " + sensorid + ": " + message.value);
    }).catch(function(e) {
        console.log("Database error: " + e.stack);
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
        console.log("Caught error handling message: " + e.stack);
    }
}


var dbConnection = mysql.createConnection({
    host: process.env.MYSQL_HOST,
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: process.env.MYSQL_DATABASE
});
var dbConnect = Promise.promisify(dbConnection.connect, {context: dbConnection});
var dbQuery = Promise.promisify(dbConnection.query, {context: dbConnection});

dbConnect().then(function(result) {
    mqtt.connect(process.env.MQTT_BROKER)
        .subscribe('sensor/+/value')
        .subscribe('sensor/+/status')
        .on('message', handleMessage);
}).catch(function(e) {
    console.log("Error connecting to database: " + e.stack);
});





