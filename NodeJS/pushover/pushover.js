/**
 * Listen to garage door and publish results to Pushover
 */

const mqtt = require("mqtt")
const request = require("request")

const client = mqtt.connect("mqtt://mqtt.clough.local")

function pushover(message) {
    request.post(
        'https://api.pushover.net/1/messages.json',
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
    client.subscribe('sensor/10488302/value')
})

client.on('message', function(topic, message) {
    try {
        jsmessage = JSON.parse(message.toString())
        console.log("Message received: " + jsmessage.value)

        var doorState = "open"
        if (jsmessage.value == 0) {
            doorState = "closed"
        }
        pushover("The garage door is " + doorState + ".")
    }
    catch(error) {
        console.log("Error: " + error.stack)
    }
})

