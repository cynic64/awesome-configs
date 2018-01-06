local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local naughty = require('naughty')
local watch = require('awful.widget.watch')
local gears = require('gears')
local cairo = require('lgi').cairo

local cr = cairo.Context(img)
local speed = 2

local shapes = {
    gears.shape.rounded_rect,
    gears.shape.hexagon,
    gears.shape.octogon,
    function(cr, w, h)
        return gears.shape.infobubble(cr, w, h, 20, 10, w/2 - 10)
    end
}

local function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

local function dec_to_hex(color)
    return '#' .. string.format('%x', color[1] * 255) .. string.format('%x', color[2] * 255) .. string.format('%x', color[3] * 255)
end

local function random_color()
    local r, g, b = round(math.random(), 2), round(math.random(), 2), round(math.random(), 2)
    r = r * 0.5 + 0.1
    g = g * 0.5 + 0.1
    b = b * 0.5 + 0.1

    return { r, g, b }
end

local desired_color = random_color()
local current_color = random_color()

local function approach_color(color1, color2)
    local step = 0.02
    local r1, g1, b1 = color1[1], color1[2], color1[3]
    local r2, g2, b2 = color2[1], color2[2], color2[3]
    local r3, g3, b3 = r1, g1, b1


    if r1 < r2 then r3 = r1 + step
    elseif r1 > r2 then r3 = r1 - step
    end

    if g1 < g2 then g3 = g1 + step
    elseif g1 > g2 then g3 = g1 - step
    end

    if b1 < b2 then b3 = b1 + step
    elseif b1 > b2 then b3 = b1 - step
    end

    if math.abs(r3 - r2) < step then r3 = r2 end
    if math.abs(g3 - g2) < step then g3 = g2 end
    if math.abs(b3 - b2) < step then b3 = b2 end

    return { r3, g3, b3 }
end

music_widget = wibox.widget {
    {
        max_value     = 1,
        forced_height = 20,
        forced_width  = 100,
        paddings      = 1,
        border_width  = 0,
        color         = '#444444',
        background_color = '#222222',
        widget        = wibox.widget.progressbar,
        shape         = gears.shape.rounded_bar
    },
    {
        markup = '',
        align = 'center',
        valign = 'center',
        forced_width = 192,
        widget = wibox.widget.textbox,
    },
    layout = wibox.layout.stack
}

batteryarc_widget = wibox.widget {
    {
        widget = wibox.container.background,
        bg = '#000000'
    },
    {
        image  = icondir .. 'bat.png',
        resize = true,
        widget = wibox.widget.imagebox
    },
    {
        max_value = 1,
        rounded_edge = true,
        colors = { '#bbbbbb' },
        thickness = 3,
        start_angle = 0,
        paddings = 2,
        widget = wibox.container.arcchart,
        set_value = function(self, value)
            self.value = value
        end,
    },
    layout = wibox.layout.stack
}

fanarc_widget = wibox.widget {
    {
        image  = icondir .. 'fan.png',
        resize = true,
        widget = wibox.widget.imagebox
    },
    {
        max_value = 2,
        rounded_edge = true,
        thickness = 3,
        start_angle = 0,
        colors = { '#fb2245', '#1ab2ff' },
        paddings = 2,
        widget = wibox.container.arcchart,
        set_value = function(self, value)
            self.value = value
        end,
    },
    layout = wibox.layout.stack
}

cpuarc_widget = wibox.widget {
    {
        image  = icondir .. 'cpu.png',
        resize = true,
        widget = wibox.widget.imagebox
    },
    {
        max_value = 1,
        rounded_edge = true,
        thickness = 3,
        start_angle = 0,
        paddings = 2,
        widget = wibox.container.arcchart,
        set_value = function(self, value)
            self.value = value
        end,
    },
    layout = wibox.layout.stack
}

ramarc_widget = wibox.widget {
    {
        image  = icondir .. 'ram.png',
        resize = true,
        widget = wibox.widget.imagebox
    },
    {
        max_value = 1,
        rounded_edge = true,
        thickness = 3,
        start_angle = 0,
        paddings = 2,
        widget = wibox.container.arcchart,
        set_value = function(self, value)
            self.value = value
        end,
    },
    layout = wibox.layout.stack
}

-- do multicolor stuff
--[[
watch(
    'how_much', speed * 10,
    function(widget, stdout, stderr, exitreason, exitcode)
        current_color = approach_color(current_color, desired_color)
        local cc, dc = current_color, desired_color
        if cc[1] == dc[1] and cc[2] == dc[2] and cc[3] == dc[3] then
            desired_color = random_color()
        end
    end
)
]]

-- music monitor
watch(
    '/home/nicky/stuff/zsh/scripts/currently_playing', speed,
    function(widget, stdout, stderr, exitreason, exitcode)
        music_widget.children[2].markup = stdout
    end
)

-- music monitor II
watch(
    'how_much', speed,
    function(widget, stdout, stderr, exitreason, exitcode)
        music_widget.children[1].value = tonumber(stdout)
    end
)

-- battery monitor
watch(
    'bat', speed * 4,
    function(widget, stdout, stderr, exitreason, exitcode)
        local value = tonumber(stdout)
        value = value / 100

        batteryarc_widget.children[3].value = value
    end,
    batteryarc_widget
)

-- fan monitor
watch(
    'fan', speed,
    function(widget, stdout, stderr, exitreason, exitcode)
        local fan1, fan2
        fan1 = tonumber(stdout:match('[0-9]+')) / 3750
        fan2 = (tonumber(stdout:match('\nProcessor Fan: [0-9]+'):match('[0-9]+')) / 4100)
        if fan1 > 1 then
            fan1 = 1
        end
        if fan2 > 1 then
            fan2 = 1
        end

        fw = fanarc_widget.children[2]

        fw.values = { fan1, fan2 }
        fan1_color = '#' .. string.format('%x', fan1 * 255) .. '0000'
        fan2_color = '#2222' .. string.format('%x', fan2 * 255)

        fw.colors = { fan1_color, fan2_color }
    end,
    fanarc_widget
)

-- cpu monitor
watch("cpu", speed,
    function(widget, stdout, stderr, exitreason, exitcode)
        local v = 1 - (tonumber(stdout) / 100)
        if v < 0.1 then v = 0.1 end

        cw = cpuarc_widget.children[2]
        cw.value = v
    end,
    cpuarc_widget
)

-- RAM monitor
watch("ram", speed,
    function(widget, stdout, stderr, exitreason, exitcode)
        local total_ram = 12169800
        local v = tonumber(stdout) / total_ram
        if v < 0.1 then v = 0.1 end

        rw = ramarc_widget.children[2]
        rw.value = v
    end,
    ramarc_widget
)

-- battery popup
local notification

function show_popup(txt)
    notification = naughty.notify { text = txt }
end

function show_command_popup(command, w)
    awful.spawn.easy_async(command,
        function(stdout, _, _, _)
            notification = naughty.notify {
                text = stdout,
                timeout = 5,
                hover_timeout = 0.5,
                width = w,
                opacity = 0.8,
            }
        end)
end

local w = 200

batteryarc_widget:connect_signal('mouse::enter', function() show_command_popup('acpi | grep "Battery 0"', w) end)
batteryarc_widget:connect_signal('mouse::leave', function() naughty.destroy(notification) end)
fanarc_widget:connect_signal('mouse::enter', function() show_command_popup('sensors', w*2) end)
fanarc_widget:connect_signal('mouse::leave', function() naughty.destroy(notification) end)
cpuarc_widget:connect_signal('mouse::enter', function() show_command_popup('minitop', w) end)
cpuarc_widget:connect_signal('mouse::leave', function() naughty.destroy(notification) end)
ramarc_widget:connect_signal('mouse::enter', function() show_command_popup('miniram', w*3) end)
ramarc_widget:connect_signal('mouse::leave', function() naughty.destroy(notification) end)
music_widget:connect_signal('button::press', function() awful.spawn('rhythmbox-client --play-pause') end)
music_widget:connect_signal('mouse::enter', function() show_command_popup('random-songs', w*2) end)
