/**
 * Listen to garage door and publish results to Pushover
 */

const mqtt = require("mqtt")
const request = require("request")

console.log("Broker: " + process.env.MQTT_BROKER)
const client = mqtt.connect(process.env.MQTT_BROKER)

console.log("Token: " + process.env.IFTTT_MAKER_TOKEN)

function ifttt(sensorid, value) {
    request.post(
        'https://maker.ifttt.com/trigger/' + sensorid + '/with/key/' + process.env.IFTTT_MAKER_TOKEN,
        { form: {
                value1: value
        } },
        function (error, response, body) {
            console.log("Body: " + body)
        }
    );
}

client.on('connect', function() {
    client.subscribe('sensor/+/value')
})

client.on('message', function(topic, message) {
    var sensorid = topic.split("/")[1]
    jsmessage = JSON.parse(message.toString())
    var value = jsmessage.value
    console.log("Message: sensor=" + sensorid + ", value=" + value)
    ifttt(sensorid, value)
})

