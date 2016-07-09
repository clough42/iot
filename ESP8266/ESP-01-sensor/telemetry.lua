-- MQTT Telemetry
--
-- Telemetry transport for one sensor

local telemetry = {}

local SENSORID = node.chipid()
local CLIENTID = "sensor-"..SENSORID
local TOPIC_STATUS = "sensor/"..SENSORID.."/status"
local TOPIC_VALUE = "sensor/"..SENSORID.."/value"
local STATUS_UP = "up"
local STATUS_DOWN = "down"
local KEEPALIVE = 60

-- mqtt client object
local broker = nil
local client = nil
local initialvalue = nil


-- error handling
local function success(client)
    print("MQTT Success")
end
local function error(client, message)
    print("MQTT Failure")
    print("Restarting in 30 seconds...")
    tmr.alarm(0,30000,tmr.ALARM_SINGLE, function()
        node.restart()
    end)
end


-- generate payload for a status message
local function statuspayload(status_value)
    local payload = {
        status = status_value,
        chipid = SENSORID,
        ip = wifi.sta.getip(),
        mac = wifi.sta.getmac(),
        hostname = wifi.sta.gethostname()
        }
    return cjson.encode(payload)
end

-- on connect to broker
local function mqttconnected(c)
    print("MQTT connected")
    -- status up message
    client:publish(TOPIC_STATUS, statuspayload(STATUS_UP), 0, 1, success, error)
    telemetry.publishvalue(initialvalue)
end


-- Publish a telemetry value
function telemetry.publishvalue(val)
    currentvalue = val
    payload = {
        value = val
    }
    client:publish(TOPIC_VALUE, cjson.encode(payload), 0, 1, success, error)
end

-- Initialize telemetry (including lwt)
function telemetry.init(broker, initialval)
    initialvalue = initialval
    client = mqtt.Client(CLIENTID, KEEPALIVE, nil, nil)
    client:on("connect", mqttconnected)
    client:on("offline", error)
    -- status down message as lwt
    client:lwt(TOPIC_STATUS, statuspayload(STATUS_DOWN), 0, 1)
    client:connect(broker, 1883, 0, nil, error)
end



return telemetry
