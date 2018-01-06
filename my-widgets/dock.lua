local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local naughty = require('naughty')
local gears = require('gears')

local iid = '/home/nicky/stuff/awesome/instance_icons/'

local w = wibox.widget {
    {
        resize = true,
        opacity = 1,
        widget = wibox.widget.imagebox
    },
    {
        resize = true,
        opacity = 0.5,
        image = iid .. 'spacer.png',
        widget = wibox.widget.imagebox
    },
    {
        resize = true,
        opacity = 0.5,
        image = iid .. 'xterm.png',
        widget = wibox.widget.imagebox
    },
    {
        resize = true,
        opacity = 0.5,
        image = iid .. 'Opera.png',
        widget = wibox.widget.imagebox
    },
    {
        resize = true,
        opacity = 0.5,
        image = iid .. 'gimp.png',
        widget = wibox.widget.imagebox
    },
    {
        resize = true,
        opacity = 0.5,
        image = iid .. 'rhythmbox.png',
        widget = wibox.widget.imagebox
    },
    {
        resize = true,
        opacity = 0.5,
        image = iid .. 'Blender.png',
        widget = wibox.widget.imagebox
    },
    {
        resize = true,
        opacity = 0.5,
        image = icondir .. 'vis.png',
        widget = wibox.widget.imagebox
    },
    {
        resize = true,
        opacity = 0.5,
        image = iid .. 'spacer.png',
        widget = wibox.widget.imagebox
    },
    {
        resize = true,
        opacity = 0.5,
        image = icondir .. 'blend.png',
        widget = wibox.widget.imagebox
    },
    {
        resize = true,
        opacity = 0.5,
        image = icondir .. 'arc.png',
        widget = wibox.widget.imagebox
    },
    {
        resize = true,
        opacity = 0.5,
        image = icondir .. 'menu.png',
        widget = wibox.widget.imagebox
    },
    layout = wibox.layout.flex.vertical
}

bw = 0

-- Preparation
dock = wibox { width = 1, height = 300, widget = w, ontop = true, opacity = 0, visible = true }

-- Making visible
awful.placement.left(dock)

local lock = false

dock:connect_signal('button::press', function()
    lock = not lock
end)
dock:connect_signal('mouse::enter', function()
    dock.width = 36
    dock.opacity = 0.8
    awful.placement.left(dock)
end)
dock:connect_signal('mouse::leave', function()
    if not lock then
        dock.width = 1
        dock.opacity = 0
        awful.placement.left(dock)
    else
        dock.opacity = 0.5
    end
end)

w.children[3]:connect_signal('button::press', function() awful.spawn('urxvt') end)
w.children[4]:connect_signal('button::press', function() awful.spawn('vivaldi') end)
w.children[5]:connect_signal('button::press', function() awful.spawn('gimp') end)
w.children[6]:connect_signal('button::press', function() awful.spawn('urxvt -e cmus') end)
w.children[7]:connect_signal('button::press', function() awful.spawn('blender') end)
w.children[8]:connect_signal('button::press', function() awful.spawn('urxvt -fn "xft:Monaco:pixelsize=2" -e vis') end)

w.children[10]:connect_signal('button::press', colorswitcher)
w.children[11]:connect_signal('button::press', gap_changer)
w.children[12]:connect_signal('button::press', layoutswitcher)
