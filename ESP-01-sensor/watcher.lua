-- GPIO Pin Watcher
--
-- Create a new object to watch a GPIO input pin.  You can read the value
-- explicitly and you can register a callback to be notified when it changes.

Watcher = {}
Watcher.__index = Watcher

setmetatable(Watcher, {
    __call = function (cls, ...)
        return cls.create(...)
    end,
})


-- Construct a new Watcher instance
function Watcher.create(pin)
    local new = setmetatable({}, Watcher)
    new.laststate = -1;
    new.timer = 3
    new.debouncetime = 500
    new.callback = nil
    new.pin = pin;
    gpio.mode(pin, gpio.INT, gpio.PULLUP)
    return new
end

local function debounce(self)
    return function(val) 
        tmr.unregister(self.timer)
        tmr.alarm(self.timer, self.debouncetime, tmr.ALARM_SINGLE, function()
            local current = gpio.read(self.pin)
            if current ~= self.laststate then
                self.callback(current)
                self.laststate = current
            end
        end)
    end
end

-- Watch for pin state changes
function Watcher:watch(callback)
    self.callback = callback
    gpio.trig(self.pin, "both", debounce(self));
end

-- Read the current stat of the pin
function Watcher:read()
    return gpio.read(self.pin)
end


return Watcher
