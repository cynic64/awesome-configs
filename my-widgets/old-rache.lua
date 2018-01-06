local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local naughty = require('naughty')
local watch = require('awful.widget.watch')
local gears = require('gears')
local cairo = require('lgi').cairo
require('my-widgets.tools')

local bl_width, bl_height = 400, 150
local bg_color = '#222222cc'
local line_color = '#ffffffbb'
local unfilled_opacity = '44'
local text_color = '#ffffff'


local bart_list_w = wibox.widget {
    widget = wibox.widget.imagebox
}

local bart_list_cairo = bart_list_w.children[1]

local bart_list = wibox { width = bl_width, height = bl_height, visible = false, bg = bg_color, ontop = true, widget = bart_list_w }

awful.placement.centered(bart_list)

selected_idx = 1
last_selected_idx = selected_idx

local function bart_list_draw()
    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, bl_width, bl_height)
    local cr = cairo.Context(img)

    cr:select_font_face('Monaco')
    cr:set_font_size(16)

    -- current clients
    local x, y = bl_width / 2, 30
    local v_gap = 30
    local tag = awful.screen.focused().selected_tag
    for i, client in ipairs(tag:clients()) do
        if i == selected_idx then
            cr:set_source(gears.color(xterm.red))
            cr:rectangle(x - 200, y - v_gap, 400, v_gap)
            cr:fill()
        end
        center_text(cr, x, y, client.name)
        y = y + v_gap
    end

    bart_list_cairo.image = img
end

function bart_list_toggle()
    bart_list.visible = not bart_list.visible
    bart_list_draw()
end

local function bart_list_select()
    _ = mouse.coords()
    local x, y = _.x, _.y
    -- correct for bart_list's position
    local bx, by = bart_list.x, bart_list.y
    x, y = x - bx, y - by

    local px, py = bl_width / 2, 30
    local v_gap = 30
    for i=1,10 do
        -- generate rect
        local rect = { px - 200, py - v_gap, 400, v_gap }
        if x > rect[1] and x < rect[1] + rect[3] and y > rect[2] and y < rect[2] + rect[4] then
            selected_idx = i
            break
        end

        py = py + v_gap
    end

    if selected_idx ~= last_selected_idx then
        bart_list_draw()
        last_selected_idx = selected_idx
    end
end

local function bart_list_click()
    local tag = awful.screen.focused().selected_tag
    for i, client in ipairs(tag:clients()) do
        if i == selected_idx then
            client.minimized = not client.minimized
        end
    end
end

bart_list:connect_signal('mouse::move', bart_list_select)
bart_list:connect_signal('button::press', bart_list_click)

