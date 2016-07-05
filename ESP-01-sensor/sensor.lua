-- ESP-01 Sensor Node
--
-- Basic one-switch sensor node for ESP-01 hardware.
-- Connect a single switch between GPIO0 and GPIO2 (GPIO0 outputs LOW as a hack to avoid causing
-- the MCU to go into programming mode if the switch is closed on startup.
--
-- This code starts the enduser_setup module, and after it gets an IP address, it connects to
-- the MQTT broker and starts up the handlers to watch the input pins.

local watch = require("watcher")
local telemetry = require("telemetry")


local INPUT_PIN = 4
local GROUND_PIN = 3
local BROKER_HOSTNAME = "mqtt"


function onchange(level)
    print("Switch changed: " .. level)
    telemetry.publishvalue(level)
end


print("Starting up sensor")
watch.ground(GROUND_PIN)
watch.watchpin(INPUT_PIN, onchange)
telemetry.init(BROKER_HOSTNAME)
