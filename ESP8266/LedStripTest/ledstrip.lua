-- LED Bar
--
-- LED Bar test

local NUM_LEDS = 5;
local i = 1;
local d = 1;
local hue = 0;


local function hueToRgb(hue)
    if hue >=0 and hue < 60  then return 255, hue * 255 / 60, 0 end;
    if hue >=60 and hue < 120  then return (120-hue) * 255 / 60, 255, 0 end;
    if hue >=120 and hue < 180  then return 0, 255, (hue-120) * 255 / 60 end;
    if hue >=180 and hue < 240  then return 0, (240-hue) * 255 / 60, 255 end;
    if hue >=240 and hue < 300  then return (hue-240) * 255 / 60, 0, 255 end;
    if hue >=300 and hue < 360  then return 255,0,(360-hue) * 255 / 60 end;
end


ws2812.init()
local buffer = ws2812.newBuffer(NUM_LEDS,3);
buffer:fill(0,0,0);

tmr.alarm(0, 50, 1, function()
    hue = (hue + 1) % 360;
    local r,g,b = hueToRgb(hue);

    i = i + d;
    if( i == NUM_LEDS ) then d = -1 end
    if( i == 1 ) then d = 1 end
    buffer:fade(3);
    buffer:set(i, r,g,b);
    buffer:write();
end)

