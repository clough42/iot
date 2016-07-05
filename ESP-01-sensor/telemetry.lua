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
local client = nil


-- error handling
local function success(client)
    print("MQTT Success")
end
local function error(client, message)
    print("MQTT Failure: " .. message)
end


-- generate payload for a status message
local function statuspayload(status_value)
    local payload = {
        status = status_value,
        chipid = CHIPID,
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
    -- status down message as lwt
    client:lwt(TOPIC_STATUS, statuspayload(STATUS_DOWN), 0, 1)
end


-- Publish a telemetry value
function telemetry.publishvalue(val)
    currentvalue = val
    payload = {
        value = val
    }
    client:publish(topic(VALUE), cjson.encode(payload), 0, 1, success, error)
end

-- Initialize telemetry (including lwt)
function telemetry.init(broker)
    currentvalue = initialval
    client = mqtt.Client(CLIENTID, KEEPALIVE, nil, nil)
    client:on("connect", mqttconnected)
    client:connect(broker, 1883, 0)
end



return telemetry
