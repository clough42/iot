-- MQTT LED
--
-- Monitor an MQTT topic and control an LED and a buzzer.

local ledstrip = require("common/ledstrip")

local BROKER = "mqtt"
local TOPIC = "sensor/10488302"
local TOPIC_VALUE = TOPIC .. "/value"
local TOPIC_STATUS = TOPIC .. "/status"
local ON_VALUE = 1


function connect(m)
    ledstrip.flash(5,115);
    print("Connected")
    m:subscribe(TOPIC_VALUE, 0)
end

function offline()
    print("Offline")
end

function message(client, topic, message)
    local parsed = cjson.decode(message)
    print("Got value: " .. parsed.value)
    if parsed.value == ON_VALUE then
        print("LED ON")
        ledstrip.solid(115);
    else
        print("LED OFF")
        ledstrip.flashonce(0);
    end
end


ledstrip.flash(4,115);
print("Contacting broker...")
local m = mqtt.Client("LED-" .. node.chipid(), 120, nil, nil)
m:on("offline", offline)
m:on("connect", connect)
m:on("message", message)
m:connect(BROKER)




