local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local wibox = require("wibox")
local watch = require("awful.widget.watch")

local HOME = os.getenv("HOME")

-- only text
local text = wibox.widget {
    id = "txt",
    font = "Monospace 10",
    widget = wibox.widget.textbox
}

-- mirror the text, because the whole widget will be mirrored after
local mirrored_text = wibox.container.mirror(text, { horizontal = true })

-- mirrored text with background
local mirrored_text_with_background = wibox.container.background(mirrored_text)

local fanarc = wibox.widget {
    mirrored_text_with_background,
    max_value = 1,
    rounded_edge = true,
    thickness = 2,
    start_angle = 4.71238898, -- 2pi*3/4
    forced_height = 17,
    forced_width = 17,
    bg = "#ffffff11",
    paddings = 0,
    widget = wibox.container.arcchart,
    set_value = function(self, value)
        self.value = value
    end,
}

-- mirror the widget, so that chart value increases clockwise
fanarc_widget = wibox.container.mirror(fanarc, { horizontal = true })

watch("fan", 1,
    function(widget, stdout, stderr, exitreason, exitcode)
        local fanType
        -- local _, status, charge_str, time = string.m
        local charge = tonumber(stdout)
        widget.value = charge / 3500
        mirrored_text_with_background.bg = beautiful.widget_transparent
        mirrored_text_with_background.fg = beautiful.widget_main_color
        local red = 255 * widget.value
        local green = 255 - red
        local blue = 255 - red

        fanarc.colors = { beautiful.widget_green }
        -- fanarc.colors = { '#' .. string.format('%x', red) .. string.format('%x', green) .. string.format('%x', blue) }
    end,
    fanarc
)

-- Popup with fan info
-- One way of creating a pop-up notification - naughty.notify
local notification
function show_fan_status()
    awful.spawn.easy_async([[bash -c 'sensors']],
        function(stdout, _, _, _)
            notification = naughty.notify {
                text = stdout,
                title = "Fan status",
                timeout = 5,
                hover_timeout = 0.5,
                width = 400,
            }
        end)
end

fanarc:connect_signal("mouse::enter", function() show_fan_status() end)
fanarc:connect_signal("mouse::leave", function() naughty.destroy(notification) end)

-- Alternative to naughty.notify - tooltip. You can compare both and choose the preferred one

--battery_popup = awful.tooltip({objects = {battery_widget}})

-- To use colors from beautiful theme put
-- following lines in rc.lua before require("battery"):
-- beautiful.tooltip_fg = beautiful.fg_normal
-- beautiful.tooltip_bg = beautiful.bg_normal

