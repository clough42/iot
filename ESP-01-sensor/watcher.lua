local watcher = {}

-- Watch the state of a pin, and fire changefunc(level) when it changes
function watcher.watchpin(pin, changefunc)
    local TIMER_NO = 3
    local DEBOUNCE_TIME = 500
    
    function debounce(pin, time, func)
        local laststate = gpio.read(pin)
        return function (...)
            tmr.unregister(TIMER_NO);
            tmr.alarm(TIMER_NO, 500, tmr.ALARM_SINGLE, function()
                local current = gpio.read(pin)
                if current ~= lastState then
                    func(current)
                    lastState = current
                 end 
            end)
        end
    end
    
    gpio.mode(pin, gpio.INT, gpio.PULLUP)
    gpio.trig(pin, "both", debounce(pin, DEBOUNCE_TIME, changefunc))
end

-- Use a GPIO pin as a ground for a switch
-- ESP-01 workaround, to make sure the sense pin is never grounded on boot
function watcher.ground(pin)
    gpio.mode(pin, gpio.OUTPUT)
    gpio.write(pin, gpio.LOW)
end

return watcher