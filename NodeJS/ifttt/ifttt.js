/**
 * Listen to garage door and publish results to Pushover
 */

const mqtt = require("mqtt")
const request = require("request")

const client = mqtt.connect("mqtt://mqtt.clough.local")

function iftt(value) {
    request.post(
        'https://maker.ifttt.com/trigger/{event}/with/key/',
        { form: {
            token: process.env.PUSHOVER_TOKEN,
            user: process.env.PUSHOVER_USER,
            message: message
        } },
        function (error, response, body) {
            if (!error && response.statusCode == 200) {
                console.log(body)
            }
        }
    );
}

client.on('connect', function() {
    client.subscribe('sensor/+/value')
})

client.on('message', function(topic, message) {
    console.log("Topic: " + topic)
    jsmessage = JSON.parse(message.toString())
    console.log("Value: " + jsmessage.value)

})

