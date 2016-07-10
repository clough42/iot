-- Initialization

START_FILE = "led.lua"
LED_PIN = 4
BUZZER_PIN = 3

gpio.mode(BUZZER_PIN, gpio.OUTPUT)
gpio.write(BUZZER_PIN, gpio.LOW)

function flash(ms)
    gpio.mode(LED_PIN, gpio.OUTPUT)
    tmr.alarm(0, ms, tmr.ALARM_AUTO, function() 
        gpio.write(LED_PIN, 1 - gpio.read(LED_PIN))
    end)
end

-- Give the user one last opportunity to avoid starting the sensor by removing init.lua
function startup()
    flash(200)
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
    flash(100)
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
flash(50)
enduser_setup.start(waitforip)
