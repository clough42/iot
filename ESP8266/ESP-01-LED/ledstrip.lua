-- LED Strip
--
-- Module for controlling a five-segment WS2812b LED strip

local ledstrip = {}

local NUM_LEDS = 5;
local TIMER = 0;
local FLASHRATE = 500;
local flashstate = 0;

ws2812.init()
local buffer = ws2812.newBuffer(NUM_LEDS,3);
buffer:fill(0,0,0);


local function hueToRgb(hue)
    if hue >=0 and hue < 60  then return 255, hue * 255 / 60, 0 end;
    if hue >=60 and hue < 120  then return (120-hue) * 255 / 60, 255, 0 end;
    if hue >=120 and hue < 180  then return 0, 255, (hue-120) * 255 / 60 end;
    if hue >=180 and hue < 240  then return 0, (240-hue) * 255 / 60, 255 end;
    if hue >=240 and hue < 300  then return (hue-240) * 255 / 60, 0, 255 end;
    if hue >=300 and hue < 360  then return 255,0,(360-hue) * 255 / 60 end;
end


function ledstrip.flash(numleds, hue)
    print("Flash " .. numleds);
    local r,g,b = hueToRgb(hue);
    flashstate = 0;
    tmr.alarm(TIMER, FLASHRATE, tmr.ALARM_AUTO, function()
        flashstate = 1 - flashstate;
        if flashstate > 0 then
            print("flash on");
            for i=1, numleds, 1 do
                buffer:set(i,r,g,b);
            end
        else
            print("flash off");
            buffer:fill(0,0,0);
        end
        buffer:write();
    end)
end

function ledstrip.flashonce(hue)
    local r,g,b = hueToRgb(hue);
    buffer:fill(r,g,b);
    buffer:write();
    tmr.alarm(TIMER, FLASHRATE, tmr.ALARM_SINGLE, function()
        ledstrip.stop();
    end)
end

function ledstrip.solid(hue)
    ledstrip.stop();
    local r,g,b = hueToRgb(hue);
    for i=1, NUM_LEDS, 1 do
        buffer:set(i,r,g,b);
    end
    buffer:write();
end

function ledstrip.stop()
    tmr.unregister(TIMER);
    buffer:fill(0,0,0);
    buffer:write();
end


return ledstrip;
