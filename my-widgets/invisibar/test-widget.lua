local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local watch = require("awful.widget.watch")

local PATH_TO_ICONS = "/home/nicky/.config/awesome/my-widgets/test-widget/"

invisibar_widget = wibox.widget {
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

invisibar_widget.image = PATH_TO_ICONS .. "8.png"

-- Popup with bar info
-- One way of creating a pop-up notification - naughty.notify
local notification
function hide_bar()
    theme.bg_normal = "#00000000"
    theme.bg_focus = "#00000000"
    theme.bg_urgent = "#00000000"
    theme.font = "sans 16"
end

function show_bar()
    theme.bg_normal = "434e2cff"
    theme.bg_focus = "#0c0d0cff"
    theme.bg_urgent = "#343534ff"
    theme.font = "sans 8"
    naughy.destroy(notification)
end

invisibar_widget:connect_signal("mouse::enter", function() hide_bar() end)
invisibar_widget:connect_signal("mouse::leave", function() show_bar() end)
