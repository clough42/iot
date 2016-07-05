-- MQTT Telemetry
--
-- Telemetry transport for one sensor

local telemetry = {}

local CHIPID = node.chipid()
local CONNECT = "connect"
local VALUE = "value"
local DISCONNECT = "disconnect"
local TIMEOUT = 60

-- last known value
local currentvalue = nil
-- mqtt client object
local client = nil



local function success(client)
    print("MQTT Success")
end

local function error(client, message)
    print("MQTT Failure: " .. message)
end

-- generate payload for a message
local function payload(val)
    data = {
        chipid = CHIPID,
        ip = wifi.sta.getip(),
        mac = wifi.sta.getmac(),
        hostname = wifi.sta.gethostname()
        }
        
    if( val ~= nil ) then
        data.value = val
    end
    
    return cjson.encode(data)
end

-- generate topic for a message
local function topic(type) 
    return "/sensor/" .. CHIPID .. "/" .. type
end

-- on connect to broke
local function mqttconnected(c)
    print("MQTT connected")
    client:publish(topic(CONNECT), payload(currentvalue), 0, 0, success, error)
end

-- Initialize telemetry (including lwt)
function telemetry.init(broker, initialval)
    currentvalue = initialval
    client = mqtt.Client("sensor-"..node.chipid(), TIMEOUT, nil, nil)
    client:on("connect", mqttconnected)
    client:lwt(topic(DISCONNECT), payload(nil))
    client:connect(broker, 1883, 0)
end

-- Publish a telemetry value
function telemetry.publishvalue(val)
    currentvalue = val
    client:publish(topic(VALUE), payload(currentvalue), 0, 0, success, error)
end



return telemetry
