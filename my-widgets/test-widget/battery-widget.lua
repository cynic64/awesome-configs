local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local watch = require("awful.widget.watch")

-- acpi sample outputs
-- Battery 0: Discharging, 75%, 01:51:38 remaining
-- Battery 0: Charging, 53%, 00:57:43 until charged
local PATH_TO_ICONS = "/home/nicky/.config/awesome/my-widgets/test-widget/"

battery_widget = wibox.widget {
    {
        id = "icon",
        widget = wibox.widget.imagebox,
        resize = true
    },
    layout = wibox.container.margin(_, 0, 0, 3),
    set_image = function(self, path)
        self.icon.image = path
    end
}

watch(
    "bat", 1,
    function(widget, stdout, stderr, exitreason, exitcode)
        local percent = tonumber(stdout)
        local level

        if percent < 12.5 then
            level = "1"
        elseif percent < 25 then
            level = "2"
        elseif percent < 37.5 then
            level = "3"
        elseif percent < 50 then
            level = "4"
        elseif percent < 62.5 then
            level = "5"
        elseif percent < 75 then
            level = "6"
        elseif percent < 87.5 then
            level = "7"
        else
            level = "8"
        end

        widget.image = PATH_TO_ICONS .. level .. ".png"
    end,
    battery_widget
)

-- Popup with battery info
-- One way of creating a pop-up notification - naughty.notify
local notification
function show_battery_status()
    awful.spawn.easy_async([[bash -c 'acpi | head -n 1']],
        function(stdout, _, _, _)
            notification = naughty.notify {
                text = stdout,
                title = "Battery status",
                timeout = 5,
                hover_timeout = 0.5,
                width = 200,
            }
        end)
end

battery_widget:connect_signal("mouse::enter", function() show_battery_status() end)
battery_widget:connect_signal("mouse::leave", function() naughty.destroy(notification) end)
