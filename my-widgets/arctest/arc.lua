local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")

local HOME = os.getenv("HOME")

arc = wibox.widget {
    max_value = 1,
    rounded_edge = true,
    thickness = 2,
    start_angle = 0,
    forced_height = 20,
    forced_width = 20,
    bg = 'ffffff',
    paddings = 2,
    widget = wibox.container.arcchart,
    colors = { '#ff0000', '#00ff00', '#0000ff' },
    set_value = function(self, value)
        self.value = value
    end,
}

arc.values = { 0.1, 0.3, 0.5 }
