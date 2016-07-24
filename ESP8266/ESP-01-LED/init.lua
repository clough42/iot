-- Initialization

local ledstrip = require("ledstrip");

START_FILE = "led.lua"


-- Give the user one last opportunity to avoid starting the sensor by removing init.lua
function startup()
    ledstrip.flash(3,115);
    if file.open("init.lua") == nil then
        print("init.lua deleted or renamed")
    else
        print("Running")
        file.close("init.lua")
        -- the actual application is stored in 'sensor.lua'
        dofile(START_FILE)
    end
end

-- Wait for IP to become valid
function waitforip()
    ledstrip.flash(2,115);
    tmr.alarm(1, 1000, 1, function()
        if wifi.sta.getip() == nil then
            print("Waiting for IP address...")
        else
            tmr.stop(1)
            print("WiFi connection established, IP address: " .. wifi.sta.getip())
            print("You have 3 seconds to abort")
            print("Waiting...")
            tmr.alarm(1, 3000, 0, startup)
        end
    end)
end

-- Start end-user wifi setup
print("Initializing End User WiFi Setup")
ledstrip.flash(1,115);
enduser_setup.start(waitforip)
