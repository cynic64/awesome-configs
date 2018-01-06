-- the amazing, all new, epic, AXE-CLOCK! --
local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local naughty = require('naughty')
local watch = require('awful.widget.watch')
local gears = require('gears')
local cairo = require('lgi').cairo

require('my-widgets.tools')
require('my-widgets.casi')
local s_width, s_height = 1920, 1080
local watch_bg = '#44444488'
local watch_x = s_width * 0.2

local cairobox = wibox.widget {
    widget = wibox.widget.imagebox
}

box = wibox { width = s_width, height = s_height, widget = cairobox, visible = false, bg = '#88888800' }

local function hand(cr, x, y, length, value, width)
    -- cr: cairo context
    -- x and y: center of hand
    -- length: length of hand
    -- value: 0..1
    -- width: line thickness
    cr:set_line_width(width)
    local angle = value * 360 - 90
    local _ = diagonal(x, y, angle, length)
    cr:move_to(x, y)
    cr:line_to(_[1], _[2])
    cr:stroke()

end

function color_severity(value, color)
    local cr, cg, cb = color:match('#(..)(..)(..)')
    local nr, ng, nb = 128, 128, 128
    local sr, sg, sb = tonumber(cr, 16), tonumber(cg, 16), tonumber(cb, 16)
    local dr, dg, db = sr - nr, sg - ng, sb - nb
    dr = dr * value
    dg = dg * value
    db = db * value
    nr = nr + dr
    ng = ng + dg
    nb = nb + db
    nr = string.format('%x', math.floor(nr))
    ng = string.format('%x', math.floor(ng))
    nb = string.format('%x', math.floor(nb))
    if string.len(nr) < 2 then nr = '0' .. nr end
    if string.len(ng) < 2 then ng = '0' .. ng end
    if string.len(nb) < 2 then nb = '0' .. nb end
    return '#' .. nr  .. ng .. nb
end

function toggle_axe()
    box.visible = not box.visible
    update_axe()
end

local function circular_plot(cr, x, y, points, color, height, invert)
    -- if invert is true, graph will be upside-down
    local q = 36
    local scale = 0.3

    cr:set_source(gears.color(color .. '22'))
    cr:set_line_width(2)

    -- this is one style - to use it, uncomment it
    --[[
    local i = 1
    for _=#points-q,#points do
        pcall(function()
                i = i + 1
                if points[_] > 1 then
                    points[_] = 1
                end
                local current_angle = -(360 * (i - 2) / q - 270)
                local current_height = height - (height * points[_] / 2)
                if invert == true then current_height = height + (height * points[_] / 2) end
                local new_pos = diagonal(x, y, current_angle, current_height)
                local nx, ny = new_pos[1], new_pos[2]

                if i == 2 then cr:move_to(nx, ny)
                else cr:line_to(nx, ny)
                end
        end)
    end
    -- now make an arc back to where we started, so we can close the path
    if #points < q then
        i = #points
    else
        i = q + 1
    end

    local start_angle = (i - 1) * (360 / q) - 90
    local end_angle = -90
    cr:arc(x, y, height, math.rad(end_angle), math.rad(start_angle))
    cr:fill()


    local i = 1
    for _=#points-q,#points do
        pcall(function()
                i = i + 1
                if points[_] > 1 then
                    points[_] = 1
                end
                local current_angle = -(360 * (i - 2) / q - 270)
                local current_height = height - (height * points[_] / 2)
                if invert == true then current_height = height + (height * points[_] / 2) end
                local new_pos = diagonal(x, y, current_angle, current_height)
                local nx, ny = new_pos[1], new_pos[2]

                if i == 2 then cr:move_to(nx, ny)
                else cr:line_to(nx, ny)
                end
        end)
    end
    cr:set_source(gears.color(color))
    cr:stroke()
    ]]

    -- this is another, and is currently used
    -- pardon the yank-abuse
    cr:set_line_cap('ROUND')
    q = 200
    cr:set_line_width(8)
    local i = 1
    for _=#points-q,#points do
        pcall(function()
                i = i + 1
                if points[_] > 1 then
                    points[_] = 1
                end
                local current_angle = -(360 * (i - 2) / q - 270)
                local current_height = height + (height * (0.1 + points[_]) * scale)
                if invert then
                    current_height = height - (height * (0.1 + points[_]) * scale)
                end
                local od = diagonal(x, y, current_angle, height)
                local cd = diagonal(x, y, current_angle, current_height)
                cr:set_source(gears.color(color_severity(points[_], color) .. '55'))
                cr:move_to(od[1], od[2])
                cr:line_to(cd[1], cd[2])
                cr:stroke()
        end)
    end
end

local function make_ticks(cr, x, y, radius)
    -- background
    cr:set_source(gears.color(watch_bg))
    cr:arc(x, y, radius, 0, 2 * math.pi)
    cr:fill()

    -- makes the ticks that go on the outside of a clock
    -- first: outer circle
    -- thickness is based on radius
    cr:set_source(gears.color(xterm.white))
    cr:set_line_width(radius / 32)
    cr:arc(x, y, radius, 0, 2 * math.pi)
    cr:stroke()

    local angles = { }
    for i = 0, 11 do     -- 12 ticks
        table.insert(angles, i / 12 * 360)
    end

    cr:set_line_width(1)
    for _, angle in ipairs(angles) do
        local length1, length2 = radius * 0.9, radius
        local start_point = diagonal(x, y, angle, length1)
        local end_point = diagonal(x, y, angle, length2)
        cr:move_to(start_point[1], start_point[2])
        cr:line_to(end_point[1], end_point[2])
        cr:stroke()
    end
end

function update_axe()
    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, s_width, s_height)
    local cr = cairo.Context(img)

    -- gradient
    local gradient = cairo.Pattern.create_radial(watch_x, s_height / 2, 256, watch_x, s_height / 2, 1000)
    gradient.add_color_stop_rgba(gradient, 0, 0, 0, 0, 0.8)
    gradient.add_color_stop_rgba(gradient, 1, 0, 0, 0, 0)
    cr:set_source(gradient)
    cr:rectangle(0, 0, 1920, 1080)
    cr:fill()

    -- outer ring
    make_ticks(cr, watch_x, s_height / 2, 256)

    -- cpu graphs
    circular_plot(cr, watch_x, s_height / 2, cpu_points.cpu0, xterm.yellow, 256, true)
    circular_plot(cr, watch_x, s_height / 2, cpu_points.cpu1, xterm.yellow, 256, true)
    circular_plot(cr, watch_x, s_height / 2, cpu_points.cpu2, xterm.yellow, 256, true)
    circular_plot(cr, watch_x, s_height / 2, cpu_points.cpu3, xterm.yellow, 256, true)
    circular_plot(cr, watch_x, s_height / 2, cpu_points.cpu4, xterm.yellow, 256, true)
    circular_plot(cr, watch_x, s_height / 2, cpu_points.cpu5, xterm.yellow, 256, true)
    circular_plot(cr, watch_x, s_height / 2, cpu_points.cpu6, xterm.yellow, 256, true)
    circular_plot(cr, watch_x, s_height / 2, cpu_points.cpu7, xterm.yellow, 256, true)
    -- wifi graphs
    circular_plot(cr, watch_x, s_height / 2, rx_points, xterm.red, 256, false)
    circular_plot(cr, watch_x, s_height / 2, tx_points, xterm.blue, 256, false)
    circular_plot(cr, watch_x, s_height / 2, ping_points, xterm.green, 256, false)

    -- mini-ring 1 (cpu loads)
    local _ = diagonal(watch_x, s_height / 2, 180 - 29 - 90, 140)
    local clx, cly = _[1], _[2]
    make_ticks(cr, clx, cly, 64)
    -- hands
    cr:set_source(gears.color(color_severity(stats.cpu1, xterm.red)))
    hand(cr, clx, cly, 64, stats.cpu1, 2)
    cr:set_source(gears.color(color_severity(stats.cpu2, xterm.green)))
    hand(cr, clx, cly, 40, stats.cpu3, 2)
    cr:set_source(gears.color(color_severity(stats.cpu3, xterm.blue)))
    hand(cr, clx, cly, 16, stats.cpu5, 2)
    -- center dot
    cr:set_source(gears.color(xterm.yellow))
    cr:arc(clx, cly, 4, 0, 2 * math.pi)
    cr:fill()

    -- mini-ring 2 (temperature, battery, ram)
    local _ = diagonal(watch_x, s_height / 2, 180 + 29 - 90, 140)
    local clx, cly = _[1], _[2]
    make_ticks(cr, clx, cly, 64)
    -- hands
    cr:set_source(gears.color(color_severity(stats.temp1, xterm.red)))
    hand(cr, clx, cly, 64, stats.temp1, 2)
    cr:set_source(gears.color(color_severity(1 - stats.battery, xterm.yellow)))
    hand(cr, clx, cly, 40, 1 - stats.battery, 2)
    cr:set_source(gears.color(color_severity(stats.ram, xterm.cyan)))
    hand(cr, clx, cly, 16, stats.ram, 2)
    -- center dot
    cr:set_source(gears.color(xterm.green))
    cr:arc(clx, cly, 4, 0, 2 * math.pi)
    cr:fill()

    -- hour hand
    cr:set_source(gears.color(xterm.white))
    hand(cr, watch_x, s_height / 2, 128, stats.hours / 12 + stats.minutes / 60 / 12, 4)

    -- minute hand
    cr:set_source(gears.color(xterm.red))
    hand(cr, watch_x, s_height / 2, 192, stats.minutes / 60, 2)

    -- center dot
    cr:set_source(gears.color(xterm.white))
    cr:arc(watch_x, s_height / 2, 8, 0, 2 * math.pi)
    cr:fill()

    -- re-draw outer ring (cpu graph may draw over it)
    cr:set_line_width(8)
    cr:arc(watch_x, s_height / 2, 256, 0, 2 * math.pi)
    cr:stroke()

    -- update image
    cairobox.image = img
end

watch(
    'echo',
    TICK_SPEED,
    function()
        if box.visible then
            update_axe()
        end
    end
)
