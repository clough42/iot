-- MQTT LED
--
-- Monitor an MQTT topic and control an LED and a buzzer.

local BROKER = "mqtt"
local TOPIC = "sensor/10488302"
local TOPIC_VALUE = TOPIC .. "/value"
local TOPIC_STATUS = TOPIC .. "/status"
local ON_VALUE = 1
local LED_PIN = 4
local BUZZER_PIN = 3

gpio.mode(LED_PIN, gpio.OUTPUT)
gpio.write(LED_PIN, gpio.LOW)
gpio.mode(BUZZER_PIN, gpio.OUTPUT)
gpio.write(BUZZER_PIN, gpio.LOW)


function flash(ms)
    tmr.alarm(0, ms, tmr.ALARM_AUTO, function() 
        gpio.write(LED_PIN, 1 - gpio.read(LED_PIN))
    end)
end

function beep(num, ms)
    if num > 0  then
        gpio.write(BUZZER_PIN, gpio.HIGH)
        tmr.alarm(1, ms, tmr.ALARM_SINGLE, function()
            gpio.write(BUZZER_PIN, gpio.LOW)
            tmr.alarm(1, ms, tmr.ALARM_SINGLE, function()
                beep(num - 1, ms)
            end)
        end)
    end
end

function solid(val)
    tmr.stop(0)
    gpio.write(LED_PIN, val)
end

function connect(m)
    flash(400)
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
        solid(1)
        beep(3,50)
    else
        print("LED OFF")
        solid(0)
        beep(2,50)
    end
end


flash(300)
print("Contacting broker...")
local m = mqtt.Client("LED-" .. node.chipid(), 120, nil, nil)
m:on("offline", offline)
m:on("connect", connect)
m:on("message", message)
m:connect(BROKER)




