-- Initialization

-- Give the user one last opportunity to avoid starting the sensor by removing init.lua
function startup()
    if file.open("init.lua") == nil then
        print("init.lua deleted or renamed")
    else
        print("Running")
        file.close("init.lua")
        -- the actual application is stored in 'sensor.lua'
        dofile("sensor.lua")
    end
end

-- Wait for IP to become valid
function waitforip()
    tmr.alarm(1, 1000, 1, function()
        if wifi.sta.getip() == nil then
            print("Waiting for IP address...")
        else
            tmr.stop(1)
            print("WiFi connection established, IP address: " .. wifi.sta.getip())
            print("You have 3 seconds to abort")
            print("Waiting...")
            tmr.alarm(0, 3000, 0, startup)
        end
    end)
end

-- Start end-user wifi setup
print("Initializing End User WiFi Setup")
enduser_setup.start(waitforip)
