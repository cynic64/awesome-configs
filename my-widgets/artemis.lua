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
local hex_color = '#222222cc'
local line_color = '#ffffffbb'
local unfilled_opacity = '44'
local text_color = '#ffffff88'
local padding = 4
local space = 200
artemis_visible = true

function log(text)
    if text then
        local f = io.open('/home/void/stuff/awesome/log.txt', 'a')
        --f = io.open('/dev/null', 'a')
        io.output(f)
        io.write(text .. '\n')
        io.close(f)
    end
end

xterm = {
    fg = '#ffffff',
    bg = '#222222',
    black = '#222222',
    red = '#f08899',
    green = '#aae8cc',
    yellow = '#eeee77',
    blue = '#88bbd8',
    magenta = '#ff88cc',
    cyan = '#6699c8',
    white = '#665544',
    greay = '#888888'
}

function round(number, places)
    shift = 10 ^ places
    _ = math.floor(number * shift) / shift
    return _
end

function reload_xterm()
    local f = io.open('/home/void/.Xresources', 'r')
    local text = f:read('*all')
    f:close()

    local color0 = string.match(text, 'color0: #([0123456789abcdef]+)')
    local color1 = string.match(text, 'color1: #([0123456789abcdef]+)')
    local color2 = string.match(text, 'color2: #([0123456789abcdef]+)')
    local color3 = string.match(text, 'color3: #([0123456789abcdef]+)')
    local color4 = string.match(text, 'color4: #([0123456789abcdef]+)')
    local color5 = string.match(text, 'color5: #([0123456789abcdef]+)')
    local color6 = string.match(text, 'color6: #([0123456789abcdef]+)')
    local color7 = string.match(text, 'color7: #([0123456789abcdef]+)')
    local color8 = string.match(text, 'color8: #([0123456789abcdef]+)')
    local color9 = string.match(text, 'color9: #([0123456789abcdef]+)')
    local color10 = string.match(text, 'color10: #([0123456789abcdef]+)')
    local color11 = string.match(text, 'color11: #([0123456789abcdef]+)')
    local color12 = string.match(text, 'color12: #([0123456789abcdef]+)')
    local color13 = string.match(text, 'color13: #([0123456789abcdef]+)')
    local color14 = string.match(text, 'color14: #([0123456789abcdef]+)')
    local color15 = string.match(text, 'color15: #([0123456789abcdef]+)')

    local foreground = string.match(text, 'foreground: #([0123456789abcdef]+)')
    local background = string.match(text, 'background: #([0123456789abcdef]+)')

    xterm.fg = '#' .. foreground
    xterm.bg = '#' .. background
    xterm.black = '#' .. color0
    xterm.red = '#' .. color1
    xterm.green = '#' .. color2
    xterm.yellow = '#' .. color3
    xterm.blue = '#' .. color4
    xterm.magenta = '#' .. color5
    xterm.cyan = '#' .. color6
    xterm.white = '#cccccc'
end

local function plot(cr, x, y, points, color, invert)
    -- if invert is true, graph will be upside-down
    local gap, height = 10, 100
    local q = 38

    cr:set_source(gears.color(color .. '88'))
    cr:set_line_width(2)
    cr:move_to(x, y)
    local lx, ly = x, y

    local i = 1
    for _=#points-q,#points do
        pcall(function()
            i = i + 1
            if points[_] > 1 then
                points[_] = 1
            end
            local nx, ny = x + i * gap, y - height * points[_]
            local lx, ly = x + (i - 1) * gap, y - height * points[_ - 1]
            if invert then
                nx, ny = x + i * gap, y + height * points[_]
                lx, ly = x + (i - 1) * gap, y + height * points[_ - 1]
            end

            cr:curve_to(lx + 5, ly, nx - 5, ny, nx, ny)
        end)
    end
    cr:stroke()
end

local function make_arc(cr, x, y, radius, color, value)
    cr:set_line_width(0.6)
    cr:set_source(gears.color(hex_color))
    cr:arc(x, y, radius + padding, 0, 2 * math.pi)
    cr:fill()

    cr:set_line_width(4)
    cr:set_source(gears.color(color .. unfilled_opacity))
    cr:arc(x, y, radius, -0.5 * math.pi, (2 * 1 - 0.5) * math.pi)
    cr:stroke()

    cr:set_source(gears.color(color))
    cr:arc(x, y, radius, -0.5 * math.pi, (2 * value - 0.5) * math.pi)
    cr:stroke()
end

local function hexagon(cr, center_x, center_y, width, height)
    cr:set_line_width(1)
    cr:set_source(gears.color(hex_color))
    cr:rectangle(center_x - width / 2 - padding, center_y - height / 2, width + 2 * padding, height)
    cr:fill()

    cr:move_to(center_x - width / 2 - padding, center_y - height / 2)
    cr:line_to(center_x - width / 2 - padding - height / 2, center_y)
    cr:line_to(center_x - width / 2 - padding, center_y + height / 2)
    cr:close_path()
    cr:fill()

    cr:move_to(center_x + width / 2 + padding, center_y - height / 2)
    cr:line_to(center_x + width / 2 + padding + height / 2, center_y)
    cr:line_to(center_x + width / 2 + padding, center_y + height / 2)
    cr:close_path()
    cr:fill()

    cr:set_source(gears.color(line_color))
    cr:move_to(center_x - width / 2 - padding, center_y - height / 2)
    cr:line_to(center_x - width / 2 - padding - height / 2, center_y)
    cr:line_to(center_x - width / 2 - padding, height / 2 + center_y)
    cr:line_to(center_x + width / 2 + padding, height / 2 + center_y)
    cr:line_to(center_x + width / 2 + padding + height / 2, center_y)
    cr:line_to(center_x + width / 2 + padding, center_y - height / 2)
    cr:close_path()
    cr:stroke()
end

local function draw_text(cr, center_x, center_y, text)
    local width = cr:text_extents(text).width
    hexagon(cr, center_x, center_y - 5, width + padding, 30)
    cr:set_source(gears.color(text_color))
    cr:move_to(center_x - width / 2, center_y)
    cr:show_text(text)
end

local w = wibox.widget {
    {
        -- cairo surface
        widget = wibox.widget.imagebox
    },
    {
        -- time
        font = 'Liberation Mono for Powerline 100',
        text = 'yo!',
        align = 'center',
        widget = wibox.widget.textbox
    },
    {
        -- date
        font = 'Liberation Mono for Powerline 20',
        text = 'hello',
        align = 'center',
        widget = wibox.widget.textbox
    },
    layout = wibox.layout.stack
}

local w_cairo = w.children[1]
local w_time = w.children[2]
local w_date = w.children[3]

-- preparation
local artemis = wibox { width = s_width, height = s_height, visible = true, bg = '#00000000', below = true, widget = w }
awful.placement.left(artemis)

function art_update()
    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, s_width, s_height)
    local cr = cairo.Context(img)
    if artemis_visible then
        cr:select_font_face('Liberation Mono for Powerline')
        cr:set_font_size(16)

        cr:set_source(gears.color(hex_color))
        cr:rectangle(0, s_height - 200, 1920, 1080)
        cr:rectangle(0, 0, space * 1.3, s_height - 200)
        cr:fill()

        hexagon(cr, s_width / 2, s_height / 2 - 75, 400, 400)

        local _ = stats.minutes
        if string.len(_) < 2 then
            _ = '0' .. _
        end
        w_date.text = stats.date
        w_time.text = stats.hours .. ':' .. _ .. '\n'

        -- WIDGETS --
        cr:set_font_size(10)

        -- fancy cpu graph - goes in center
        local x, y = s_width / 2 - 200, s_height / 2 - 160

        plot(cr, x, y, cpu_points.cpu0, xterm.white, false)
        plot(cr, x, y, cpu_points.cpu1, xterm.black, false)
        plot(cr, x, y, cpu_points.cpu2, xterm.red, false)
        plot(cr, x, y, cpu_points.cpu3, xterm.green, false)
        plot(cr, x, y, cpu_points.cpu4, xterm.yellow, false)
        plot(cr, x, y, cpu_points.cpu5, xterm.blue, false)
        plot(cr, x, y, cpu_points.cpu6, xterm.magenta, false)
        plot(cr, x, y, cpu_points.cpu7, xterm.cyan, false)

        -- fancy wifi graph
        y = y + 170
        plot(cr, x, y, rx_points, xterm.red, true)
        plot(cr, x, y, tx_points, xterm.green, true)
        plot(cr, x, y, ping_points, xterm.blue, true)

        local rx_mbps = round(stats.rx / 4 / 1024 / 1024, 4)
        local tx_mbps = round(stats.tx / 4 / 1024 / 1024, 4)
        cr:set_source(gears.color(xterm.red))
        cr:move_to(s_width / 2 - 250, s_height / 2 + 30)
        cr:show_text(rx_mbps .. ' M/s')
        cr:set_source(gears.color(xterm.green))
        cr:move_to(s_width / 2 - 250, s_height / 2 + 50)
        cr:show_text(tx_mbps .. ' M/s')
        cr:set_source(gears.color(xterm.blue))
        cr:move_to(s_width / 2 - 250, s_height / 2 + 70)
        cr:show_text(stats.ping .. ' ms')

        -- LEFT STATS--

        -- cpu loads
        local x, y = space / 2, 100
        local radar_size = 60

        make_arc(cr, x, y, radar_size - padding, xterm.white, stats.cpu0)
        make_arc(cr, x, y, radar_size - padding - 6, xterm.white, stats.cpu1)
        make_arc(cr, x, y, radar_size - padding - 6 * 2, xterm.white, stats.cpu2)
        make_arc(cr, x, y, radar_size - padding - 6 * 2, xterm.white, stats.cpu3)
        make_arc(cr, x, y, radar_size - padding - 6 * 3, xterm.white, stats.cpu4)
        make_arc(cr, x, y, radar_size - padding - 6 * 4, xterm.white, stats.cpu5)
        make_arc(cr, x, y, radar_size - padding - 6 * 5, xterm.white, stats.cpu6)
        make_arc(cr, x, y, radar_size - padding - 6 * 6, xterm.white, stats.cpu7)

        x = space / 2

        cr:move_to(x+80, y)
        cr:show_text('cpu loads')

        -- temperatures
        y = 240
        make_arc(cr, x, y, radar_size - padding - 6 * 0, xterm.red, stats.temp0)
        make_arc(cr, x, y, radar_size - padding - 6 * 1, xterm.red, stats.temp1)
        make_arc(cr, x, y, radar_size - padding - 6 * 2, xterm.red, stats.temp2)
        make_arc(cr, x, y, radar_size - padding - 6 * 3, xterm.red, stats.temp3)
        make_arc(cr, x, y, radar_size - padding - 6 * 4, xterm.red, stats.temp4)
        make_arc(cr, x, y, radar_size - padding - 6 * 5, xterm.red, stats.temp5)
        make_arc(cr, x, y, radar_size - padding - 6 * 6, xterm.red, stats.temp6)
        make_arc(cr, x, y, radar_size - padding - 6 * 7, xterm.red, stats.temp7)
        make_arc(cr, x, y, radar_size - padding - 6 * 8, xterm.red, stats.temp8)

        cr:move_to(x+80, y)
        cr:show_text('thermal')

        -- 3rd ring --
        -- filesystems
        y = 380
        make_arc(cr, x, y, radar_size - padding - 6 * 0, xterm.red, stats.root)
        --make_arc(cr, x, y, radar_size - padding - 6 * 1, xterm.cyan, stats.home)
        --make_arc(cr, x, y, radar_size - padding - 6 * 2, xterm.green, stats.mega)
        cr:set_source(gears.color(xterm.red))
        cr:move_to(x+80, y-60)
        cr:show_text('root')
        cr:set_source(gears.color(xterm.cyan))
        --cr:move_to(x+80, y-40)
        --cr:show_text('home')
        --cr:set_source(gears.color(xterm.green))
        --cr:move_to(x+80, y-20)
        --cr:show_text('mega')

        -- ram usage
        make_arc(cr, x, y, radar_size - padding - 6 * 1, xterm.white, stats.ram)
        cr:set_source(gears.color(xterm.white))
        cr:move_to(x+80, y)
        cr:show_text('RAM')

        -- swap usage, broken for now
        --[[
        make_arc(cr, x, y, radar_size - padding - 6 * 2, xterm.white, stats.swap)
        cr:set_source(gears.color(xterm.white))
        cr:move_to(x+80, y+20)
        cr:show_text('swap')
        ]]

        -- battery
        make_arc(cr, x, y, radar_size - padding - 6 * 3, xterm.yellow, stats.battery)
        cr:set_source(gears.color(xterm.yellow))
        cr:move_to(x+80, y+40)
        cr:show_text('battery')

        cr:set_font_size(16)

        -- BOTTOM WIDGETS --
        cr:set_font_size(10)
        cr:set_source(gears.color(text_color))
        -- syslog
        x = 10
        y = s_height - 200

        for _, line in ipairs(stats.syslog) do
            y = y + 20
            cr:move_to(x, y)
            cr:show_text(line)
        end

        -- top cpu processes
        x = 730
        y = s_height - 200

        for _, line in ipairs(stats.top_cpu) do
            y = y + 20
            cr:move_to(x, y)
            cr:show_text(line)
            cr:stroke()
        end

        -- top ram processes
        x = 1100
        y = s_height - 200

        for _, line in ipairs(stats.top_mem) do
            y = y + 20
            cr:move_to(x, y)
            cr:show_text(line)
        end

        -- todo
        x = s_width - space * 2
        y = s_height - 200

        for _, line in ipairs(stats.todo) do
            y = y + 20
            cr:move_to(x, y)
            cr:show_text(line)
        end

        x = space * 0.1
        y = s_height - 600

        for _, line in ipairs(stats.queue) do
            y = y + 20
            cr:move_to(x, y)
            cr:show_text(line)
        end

        cr:set_font_size(16)

        -- RIGHT STATS --
        -- uptime
        awful.spawn.easy_async_with_shell(
            'uptime -p',
            function(stdout)
                stats.uptime = string.match(stdout, '(.+)\n')
            end
        )

        local x, y = s_width - space, 50
        draw_text(cr, x, y, stats.uptime)

        -- music playing
        local y = 90
        draw_text(cr, x, y, stats.currently_playing)

        -- music position
        local y = 130
        draw_text(cr, x, y, stats.position)

    else
        w_time.text = ''
        w_date.text = ''
    end

    -- update cairo surface
    w_cairo.image = img
end

watch('echo', TICK_SPEED, function()
    art_update()
end)
