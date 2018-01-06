-- niceandclean, awesome3 theme, by Blazeix, based off of ghost1227's openbox theme.
-- modified af now

--{{{ Main
local awful = require("awful")
awful.util = require("awful.util")

theme = {}

-- possible layouts are: "10ich","large","1920",""
-- no they aren't, I deleted those
conky_layout = "" 

home          = os.getenv("HOME")
config        = "/home/nicky/.config/awesome"
shared        = "/usr/share/awesome"
if not awful.util.file_readable(shared .. "/icons/awesome16.png") then
    shared    = "/usr/share/local/awesome"
end
sharedicons   = shared .. "/icons"
sharedthemes  = shared .. "/themes"
themes        = config .. "/themes"
themename     = "/niceandclean"
if not awful.util.file_readable(themes .. themename .. "/theme.lua") then
	themes = sharedthemes
end
themedir = themes .. themename


theme.wallpaper = home .. '/stuff/awesome/bg.png'

--}}}

theme.font          = "URW Gothic L 10"

theme.bg_normal     = "#00000000"
theme.bg_focus      = "#ffffff44"
theme.bg_urgent     = "#440000ff"
theme.bg_minimize   = "#00000000"

theme.fg_normal     = "#ffffffff"
theme.fg_focus      = "#000000bb"
theme.fg_urgent     = "#ffffffbb"
theme.fg_minimize   = "#ffffffbb"

theme.border_width  = "1"
theme.border_normal = "#888888"
theme.border_marked = "#662222"
theme.border_focus  = "#aa7755"
theme.border_color = '#888888'

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Display the taglist squares
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = themedir .. "/submenu.png"
theme.menu_height = "15"
theme.menu_width  = "110"
theme.menu_border_width = "0"

-- Notifications
theme.notification_opactiy = 0.5
theme.notification_bg = '#222222'
--theme.notification_shape = gears.shape.rounded_rect

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = icondir .. 'close.png'
theme.titlebar_close_button_focus = icondir .. "close.png"

theme.titlebar_ontop_button_normal_inactive = icondir .. 'ontop.png'
theme.titlebar_ontop_button_focus_inactive = icondir .. 'ontop.png'
theme.titlebar_ontop_button_normal_active = icondir .. 'ontop-active.png'
theme.titlebar_ontop_button_focus_active = icondir .. 'ontop-active.png'

theme.titlebar_sticky_button_normal_inactive = icondir .. 'sticky.png'
theme.titlebar_sticky_button_focus_inactive = icondir .. 'sticky.png'
theme.titlebar_sticky_button_normal_active = icondir .. 'sticky-active.png'
theme.titlebar_sticky_button_focus_active = icondir .. 'sticky-active.png'

theme.titlebar_floating_button_normal_inactive = icondir .. 'floating.png'
theme.titlebar_floating_button_focus_inactive = icondir .. 'floating.png'
theme.titlebar_floating_button_normal_active = icondir .. 'floating-active.png'
theme.titlebar_floating_button_focus_active = icondir .. 'floating-active.png'

theme.titlebar_maximized_button_normal_inactive = icondir .. 'maxi.png'
theme.titlebar_maximized_button_focus_inactive = icondir .. 'maxi.png'
theme.titlebar_maximized_button_normal_active = icondir .. 'maxi-active.png'
theme.titlebar_maximized_button_focus_active = icondir .. 'maxi-active.png'

-- You can use your own layout icons like this:

theme.tasklist_disable_task_name = true
-- theme.tasklist_disable_icon = true
-- theme.tasklist_shape = gears.shape.rounded_bar
--

--theme.titlebar_bgimage = '/home/nicky/stuff/awesome/titlebar-image.png'
theme.useless_gap = 8

theme.focused_opacity = 0.95
theme.unfocused_opacity = 0.7
theme.focus_diff = 0.25

return theme
