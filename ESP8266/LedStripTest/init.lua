-- Initialization

START_FILE = "ledstrip.lua"


-- Give the user one last opportunity to avoid starting the sensor by removing init.lua
function startup()
    if file.open("init.lua") == nil then
        print("init.lua deleted or renamed")
    else
        print("Running")
        file.close("init.lua")
        -- the actual application is stored in 'sensor.lua'
        dofile(START_FILE)
    end
end

print("You have 3 seconds to abort")
print("Waiting...")
tmr.alarm(1, 3000, 0, startup)

