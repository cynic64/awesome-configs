local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local naughty = require('naughty')
local watch = require('awful.widget.watch')
local gears = require('gears')
local radical = require('radical')
local cairo = require('lgi').cairo

local bigfont = 'Monaco 24'
local font = 'Monaco 10'
local smallfont = 'Monaco 8'

panel_icon = wibox.widget {
    image  = icondir .. 'menu.png',
    resize = true,
    widget = wibox.widget.imagebox
}

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

local function mirror(widget)
    return wibox.container.mirror(widget, {horizontal = true})
end

local function mark_text(text, color)
    return '<span foreground="' .. color ..'">' .. text .. '</span>'
end

local function arc_tick(color)
    return mirror(wibox.widget{
        -- minutes
        start_angle = math.pi * 1.5,
        value = 1,
        rounded_edge = true,
        max_value = 100,
        thickness = 4,
        colors = { color },
        widget = wibox.container.arcchart
    })
end

local function dec_to_hex(color)
    return '#' .. string.format('%x', color[1] * 255) .. string.format('%x', color[2] * 255) .. string.format('%x', color[3] * 255)
end

local function clockify(value)
    -- value: 0..100
    return 1.99 * math.pi * (value / 100 + 0.75)
end

local function create_clock()
    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, 256, 256)
    local cr  = cairo.Context(img)
    -- arc method: x, y, radius, start, end
    local centerx, centery = 128, 128

    --[[
    cr:set_source(gears.color(xterm.greay))
    cr:arc(centerx, centery, 100, -0.5 * math.pi, 1.5 * math.pi)
    cr:stroke()
    cr:arc(centerx, centery, 90, -0.5 * math.pi, 1.5 * math.pi)
    cr:stroke()
    cr:arc(centerx, centery, 80, -0.5 * math.pi, 1.5 * math.pi)
    cr:stroke()
    cr:arc(centerx, centery, 70, -0.5 * math.pi, 1.5 * math.pi)
    cr:stroke()
    ]]

    return img, cr
end

local function make_arc(radius, color, value)
    cr:set_source(gears.color(color))
    cr:set_line_width(4)
    cr:arc(128, 128, radius, -0.5 * math.pi, (2 * value - 0.5) * math.pi)
    cr:stroke()
end

img, cr = create_clock()

local small_image = wibox.widget {
    -- temp: 10
    image = icondir .. 'clock.png',
    widget = wibox.widget.imagebox,
}
local w = wibox.widget {
    {
        -- clock: 1
        {
            -- background
            widget = wibox.widget.imagebox,
            resize = true,
            image = img
        },
        {
            font = bigfont,
            widget = wibox.widget.textbox,
            align = 'center'
        },
        layout = wibox.layout.stack
    },
    {
        -- music stats: 2
        {
            value = 0.5,
            widget = wibox.container.radialprogressbar,
            forced_height = 32,
            forced_width = 192,
            border_color = '#ffffff22',
            color = xterm.white
        },
        {
            text = '',
            font = font,
            widget = wibox.widget.textbox,
            align = 'center',
            valign = 'center'
        },
        layout = wibox.layout.stack
    },
    {
        -- ram usage: 3
        {
            value = 50,
            max_value = 100,
            widget = wibox.container.radialprogressbar,
            forced_height = 32,
            forced_width = 192,
            border_color = '#ffffff22',
            color = xterm.white
        },
        {
            markup = mark_text('ram usage', xterm.yellow),
            font = smallfont,
            widget = wibox.widget.textbox,
            align = 'center',
            valign = 'center'
        },
        layout = wibox.layout.stack
    },
    {
        -- /dev/sda4: 4
        {
            value = 50,
            max_value = 100,
            widget = wibox.container.radialprogressbar,
            forced_height = 32,
            forced_width = 192,
            border_color = '#ffffff22',
            color = xterm.white
        },
        {
            markup = mark_text('/', xterm.green),
            font = smallfont,
            widget = wibox.widget.textbox,
            align = 'center',
            valign = 'center'
        },
        layout = wibox.layout.stack
    },
    {
        -- /dev/sda7: 5
        {
            value = 50,
            max_value = 100,
            widget = wibox.container.radialprogressbar,
            forced_height = 32,
            forced_width = 192,
            border_color = '#ffffff22',
            color = xterm.white
        },
        {
            markup = mark_text('home', xterm.green),
            font = smallfont,
            widget = wibox.widget.textbox,
            align = 'center',
            valign = 'center'
        },
        layout = wibox.layout.stack
    },
    {
        -- cpu graph: 6
        {
            max_value = 1,
            color = xterm.greay,
            border_color = '#ffffff00',
            background_color = 'transparent',
            widget = wibox.widget.graph,
            forced_height = 80,
            step_width = 4,
            step_spacing = 1
        },
        {
            markup = mark_text('cpu', xterm.red),
            align = 'center',
            font = smallfont,
            widget = wibox.widget.textbox
        },
        layout = wibox.layout.stack
    },
    {
        -- packet monitor - tx: 7
        {
            scale = true,
            color = xterm.cyan,
            border_color = '#ffffff00',
            widget = wibox.widget.graph,
            forced_height = 80,
            step_width = 4,
            step_spacing = 1,
            background_color = 'transparent'
        },
        {
            markup = mark_text('tx', xterm.cyan),
            font = smallfont,
            align = 'center',
            widget = wibox.widget.textbox,
        },
        layout = wibox.layout.stack
    },
    {
        -- packet monitor - rx: 8
        {
            scale = true,
            color = xterm.red,
            border_color = '#ffffff00',
            widget = wibox.widget.graph,
            forced_height = 80,
            step_width = 4,
            step_spacing = 1,
            background_color = 'transparent'
        },
        {
            markup = mark_text('rx', xterm.red),
            font = smallfont,
            align = 'center',
            widget = wibox.widget.textbox
        },
        layout = wibox.layout.stack
    },
    {
        -- todo: 9
        markup = 'TODO:',
        font = font,
        widget = wibox.widget.textbox,
        align = 'center'
    },
    {
        -- date: 10
        text = '',
        font = font,
        align = 'center',
        widget = wibox.widget.textbox
    },
    layout = wibox.layout.fixed.vertical
}

-- Preparation
panel = wibox { width = 1, height = 1080, widget = w, ontop = true, opacity = 0, visible = true, bg = 'transparent' }

-- Making visible
awful.placement.right(panel)

local lock = false
local running = true

panel:connect_signal('button::press', function()
    lock = not lock
end)
panel:connect_signal('mouse::enter', function()
    panel.width = 256
    panel.opacity = 0.8
    awful.placement.right(panel)
end)
panel:connect_signal('mouse::leave', function()
    if not lock then
        panel.width = 1
        panel.opacity = 0
        awful.placement.right(panel)
    else
        panel.opacity = 0.5
    end
end)

w.children[1]:connect_signal('button::press', function()
    running = not running
    lock = not lock
end)

local todo_compact = false
w.children[9]:connect_signal('button::press', function()
    todo_compact = not todo_compact
end)

watch('echo', 4, function()
    if running then
        -- cpu core loads
        clock = os.clock()
        awful.spawn.easy_async(
            'cpu-ping',
            function(stdout)
                local cpu0, cpu1, cpu2, cpu3, cpu4, cpu5, cpu6, cpu7 = string.match(stdout, string.rep('([0123456789 ]+)\n', 7) .. '([0123456789 ]+)')
                local cpus = { cpu0, cpu1, cpu2, cpu3, cpu4, cpu5, cpu6, cpu7 }
                local cpu_loads = { }
                local widget_idx = 5
                for i, line in ipairs(cpus) do
                    local user, nice, system, idle = string.match(line, '(%d+) (%d+) (%d+) (%d+)')
                    local being_used = tonumber(user) + tonumber(nice) + tonumber(system)
                    local total = being_used + tonumber(idle)
                    cpu_loads[#cpu_loads + 1] = being_used / total * 100
                end

                stats.cpu0 = cpu_loads[1] / 100
                stats.cpu1 = cpu_loads[2] / 100
                stats.cpu2 = cpu_loads[3] / 100
                stats.cpu3 = cpu_loads[4] / 100
                stats.cpu4 = cpu_loads[5] / 100
                stats.cpu5 = cpu_loads[6] / 100
                stats.cpu6 = cpu_loads[7] / 100
                stats.cpu7 = cpu_loads[8] / 100
        end)

        -- cpu graph
        clock = os.clock()
        awful.spawn.easy_async(
            'cpu',
            function(stdout)
                local value = 1 - (tonumber(stdout) / 100)
                local graph = w.children[6].children[1]
                graph:add_value(value)
                if value > 0.8 then
                    graph.color = xterm.red
                else
                    graph.color = xterm.greay
                end
            end)
        log('\tcpu: ' .. tostring(os.clock() - clock))

        -- todo list
        clock = os.clock()
        awful.spawn.easy_async(
            {'cat', '/home/nicky/.todo'},
            function(stdout)
                -- stats.todo = stdout
                if not todo_compact then
                    w.children[9].markup = '<b>TODO:</b>\n' .. stdout
                else
                    w.children[9].markup = mark_text('<b>TODO</b>', xterm.greay)
                end
            end)
        log('\ttodo: ' .. tostring(os.clock() - clock))

        -- music progress-bar
        clock = os.clock()
        awful.spawn.easy_async(
            'how_much',
            function(stdout)
                w.children[2].children[1].value = tonumber(stdout)
                stats.music_progress = tonumber(stdout)
            end)
        log('\thow_much: ' .. tostring(os.clock() - clock))

        -- music info
        clock = os.clock()
        awful.spawn.easy_async(
            'currently_playing',
            function(stdout)
                stdout = string.gsub(stdout, '\n', '')
                w.children[2].children[2].text = stdout
                stats.currently_playing = stdout
            end)
        log('\tcurrently_playing: ' .. tostring(os.clock() - clock))

        -- whether music is playing
        clock = os.clock()
        awful.spawn.easy_async(
            'is_playing',
            function(stdout)
                stdout = string.gsub(stdout, '\n', '')
                if stdout == 'playing' then
                    w.children[2].children[2].opacity = 1
                else
                    w.children[2].children[2].opacity = 0.1
                end
                stats.is_playing = stdout
            end)
        log('\tis_playing: ' .. tostring(os.clock() - clock))

        -- packet monitor, tx and rx
        clock = os.clock()
        awful.spawn.easy_async(
            {'wifi-stats', 'tx'},
            function(stdout)
                w.children[7].children[1]:add_value(tonumber(stdout))
                w.children[7].children[1].markup = mark_text('tx', xterm.cyan)
            end)

        awful.spawn.easy_async(
            {'wifi-stats', 'rx'},
            function(stdout)
                w.children[8].children[1]:add_value(tonumber(stdout))
                w.children[7].children[1].markup = mark_text('rx', xterm.red)
            end)
        log('\twifi-stats: ' .. tostring(os.clock() - clock))

        -- ram usage
        clock = os.clock()
        awful.spawn.easy_async(
            'ram2',
            function(stdout)
                stdout = string.match(stdout, '(%d+)\n')
                w.children[3].children[2].markup = mark_text('ram: ' .. stdout .. '%', xterm.yellow)
                w.children[3].children[1].value = tonumber(stdout)
                stats.ram = tonumber(stdout) / 100
            end)
        log('\tram2: ' .. tostring(os.clock() - clock))

        -- cpu temps
        clock = os.clock()
        awful.spawn.easy_async(
            'cpu_temp',
            function(stdout)
                local cpu0, cpu1, cpu2, cpu3 = string.match(stdout, '(%d+)\n(%d+)\n(%d+)\n(%d+)')
                stats.cpu0_temp = tonumber(cpu0) / 100
                stats.cpu1_temp = tonumber(cpu1) / 100
                stats.cpu2_temp = tonumber(cpu2) / 100
                stats.cpu3_temp = tonumber(cpu3) / 100
            end)
        log('\tcpu_temp: ' .. tostring(os.clock() - clock))

        -- battery
        clock = os.clock()
        awful.spawn.easy_async(
            'bat',
            function(stdout)
                stats.battery = tonumber(stdout) / 100
            end)
        log('\tbat: ' .. tostring(os.clock() - clock))

        -- hard drive-meter
        clock = os.clock()
        awful.spawn.easy_async(
            'hd-full',
            function(stdout)
                local root, home = string.match(stdout, '(%d+)%%\n(%d+)')
                w.children[4].children[1].value = tonumber(root)
                w.children[4].children[2].markup = mark_text('/: ' .. root .. '%', xterm.green)

                w.children[5].children[1].value = tonumber(home)
                w.children[5].children[2].markup = mark_text('/home: ' .. home .. '%', xterm.green)
                stats.root = tonumber(root) / 100
                stats.home = tonumber(home) / 100
            end)
        log('\thd-full: ' .. tostring(os.clock() - clock))

        -- fan dials
        clock = os.clock()
        awful.spawn.easy_async(
            'fan',
            function(stdout)
                local fan1, fan2 = string.match(stdout, 'Processor Fan:%s+(%d+) RPM\nProcessor Fan:%s+(%d+)')
                stats.fan1 = tonumber(fan1) / 3600
                stats.fan2 = tonumber(fan2) / 4100
            end)
        log('\tfan: ' .. tostring(os.clock() - clock))

        -- date
        clock = os.clock()
        awful.spawn.easy_async(
            { 'date', '+%d %b' },
            function(stdout)
                w.children[10].text = stdout
            end)
        log('\tdate: ' .. tostring(os.clock() - clock))

        clock = os.clock()
        make_arc(126, xterm.red, stats.cpu0_temp)
        make_arc(122, xterm.red, stats.cpu1_temp)
        make_arc(118, xterm.red, stats.cpu2_temp)
        make_arc(114, xterm.red, stats.cpu3_temp)

        make_arc(110, xterm.cyan, stats.cpu0)
        make_arc(106, xterm.cyan, stats.cpu1)
        make_arc(102, xterm.cyan, stats.cpu2)
        make_arc(98, xterm.cyan, stats.cpu3)
        make_arc(94, xterm.cyan, stats.cpu4)
        make_arc(90, xterm.cyan, stats.cpu5)
        make_arc(86, xterm.cyan, stats.cpu6)
        make_arc(82, xterm.cyan, stats.cpu7)

        make_arc(78, xterm.green, stats.fan1)
        make_arc(74, xterm.green, stats.fan2)

        make_arc(70, xterm.yellow, stats.battery)

        w.children[1].children[1].image = img
        log('\tarcs: ' .. tostring(os.clock() - clock))
    end
    -- clock
    awful.spawn.easy_async(
        { 'date', '+\n%I:%M' },
        function(stdout)
            w.children[1].children[2].text = stdout
    end)
end)
