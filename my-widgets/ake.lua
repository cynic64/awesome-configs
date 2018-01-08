local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local naughty = require('naughty')
local watch = require('awful.widget.watch')
local gears = require('gears')
local cairo = require('lgi').cairo
require('my-widgets.tools')
local rache = require('my-widgets.rache')

local s_width, s_height = 1920, 32
local bg_color = '#222222cc'
local line_color = '#ffffffbb'
local unfilled_opacity = '44'
local text_color = '#ffffff'
local padding = 4
local text_y = 24

local w = wibox.widget {
    {
        -- cairo surface
        widget = wibox.widget.imagebox
    },
    layout = wibox.layout.stack
}
ake = wibox { width = s_width, height = s_height, visible = true, bg = bg_color, ontop = true, widget = w }

awful.placement.top(ake)
ake.opacity = 1

ake:connect_signal('button::press', function()
                        if ake.opacity == 1 then ake.opacity = 0
                        elseif ake.opacity == 0 then ake.opacity = 1 end
end)

local w_cairo = w.children[1]

local current_idx = 0

-- x-coordinates for text in box highlights
local positions = {
    {
        -- efficiency
        center = 70,
        stop = 140
    },
    {
        -- minimal
        center = 200,
        stop = 260
    },
    {
        -- current wall
        center = 350,
        stop = 470
    },
    {
        -- current monitor
        center = 600,
        stop = 710
    },
    {
        -- bias
        center = 770,
        stop = 840
    },
    {
        -- gaps
        center = 900,
        stop = 980
    },
    {
        -- padding
        center = 1050,
        stop = 1150
    },
    {
        -- border
        center = 1200,
        stop = 1300
    },
}

function ake_update()
    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, s_width, s_height)
    local cr = cairo.Context(img)

    cr:set_source(gears.color(bg_color))
    cr:rectangle(0, 0, s_width, s_height)
    cr:fill()
    cr:set_line_width(0.5)
    cr:set_source(gears.color(xterm.cyan))
    cr:rectangle(0, 0, s_width, s_height)
    cr:stroke()

    cr:select_font_face('SauceCodePro Nerd Font Mono')
    cr:set_font_size(12)
    cr:set_line_width(1)

    -- boxes
    local start = 0
    for idx, coords in ipairs(positions) do
        cr:set_source(gears.color(xterm.green))
        if idx == current_idx then
            cr:set_source(gears.color(xterm.red))
        end
        cr:move_to(start+2, 1)
        cr:line_to(coords.stop-2, 1)
        cr:line_to(coords.stop-2, s_height - 1)
        cr:line_to(start+2, s_height - 1)
        cr:close_path()
        cr:stroke()
        start = coords.stop
    end

    cr:set_source(gears.color(text_color))
    center_text(cr, 70, text_y, 'efficiency: ' .. tostring(efficiency))
    center_text(cr, 200, text_y, 'minimal: ' .. tostring(minimized))
    center_text(cr, 350, text_y, 'current wallpaper: ' .. tostring(current_wall))
    center_text(cr, 600, text_y, 'current monitor: ' .. tostring(current_mon))
    center_text(cr, 770, text_y, 'bias: ' .. tostring(bias_state))
    center_text(cr, 900, text_y, 'gaps: ' .. tostring(beautiful.useless_gap))
    center_text(cr, 1050, text_y, 'padding: ' .. tostring(screen.primary.padding.top))
    center_text(cr, 1200, text_y, 'border: ' .. tostring(beautiful.border_width))

    -- update cairo surface
    w_cairo.image = img
end

ake:connect_signal('mouse::enter', function()
    current_idx = 1
    ake_update()
    keygrabber.run(function(mod, key, event)
        if event == 'release' then return end
        
        if key == 'Left' then
            current_idx = current_idx - 1
            if current_idx < 1 then current_idx = 1
            end
        elseif key == 'Right' then
            current_idx = current_idx + 1
            if current_idx > #positions then current_idx = #positions
            end
        end

        ake_update()
    end)
end)

ake:connect_signal('mouse::leave', function()
    keygrabber.stop()
    current_idx = 0
end)

function check_mouseover()
    local _ = mouse.coords()
    local x, y = _.x, _.y
    -- correct for ake's position
    x = x - ake.x
    y = y - ake.y

    local last_menu = current_menu
    current_menu = 'none'
    for name, rect in pairs(menu_rects) do
        if is_in_rect(x, y, rect) then
            current_menu = name
        end
    end

    if current_menu ~= last_menu then
        last_menu = current_menu
        if current_menu ~= 'none' then
            if current_menu == 'music' then
                rache.set_items('music', stats.queue)
            end
            rache.toggle(current_menu)
        end
    end
end
awful.spawn.easy_async_with_shell('sleep 1', function()
                                      ake_update()
end)

watch('echo', 60, function()
          ake_update()
end)
