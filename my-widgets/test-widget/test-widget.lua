local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local watch = require("awful.widget.watch")

local PATH_TO_ICONS = "/home/nicky/.config/awesome/my-widgets/test-widget/"

test_widget = wibox.widget {
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
    "fan", 1,
    function(widget, stdout, stderr, exitreason, exitcode)
        local percent = tonumber(stdout) / 35
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
    test_widget
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

test_widget:connect_signal("mouse::enter", function() show_fan_status() end)
test_widget:connect_signal("mouse::leave", function() naughty.destroy(notification) end)
