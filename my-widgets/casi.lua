local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local naughty = require('naughty')
local watch = require('awful.widget.watch')
local gears = require('gears')
local cairo = require('lgi').cairo
require('my-widgets.tools')

TICK_SPEED = 2

cpu_points = {
    cpu0 = {},
    cpu1 = {},
    cpu2 = {},
    cpu3 = {},
    cpu4 = {},
    cpu5 = {},
    cpu6 = {},
    cpu7 = {}
}

rx_points = {}
tx_points = {}
ping_points = {}

stats = {
    date = '',
    hours = 0,
    minutes = 0,
    album_cover = '',
    queue = { 'No music queued.' },
    music_cache = { },
    position = '00:00 / 00:00',
    wifi = { 'Ifconfig not running' },
    syslog = { 'No syslog.' },
    top_cpu = { 'No CPU info.' },
    top_mem = { 'No RAM info.' },
    todo = { 'Nothing to do.' },
    rx = 0,
    last_rx = 0,
    tx = 0,
    last_tx = 0,
    ping = 0,
    uptime = 'No uptime.',
    log = { 'no log' },
    cpu0 = 0,
    cpu1 = 0,
    cpu2 = 0,
    cpu3 = 0,
    cpu4 = 0,
    cpu5 = 0,
    cpu6 = 0,
    cpu7 = 0,
    currently_playing = 'No music playing.',
    root = 0,
    battery = 0,
    fan1 = 0,
    fan2 = 0,
    temp0 = 0,
    temp1 = 0,
    temp2 = 0,
    temp3 = 0,
    temp4 = 0,
    temp5 = 0,
    temp6 = 0,
    temp7 = 0,
    temp8 = 0,
    ram = 0,
    swap = 0,
    schedule = { }
}

-- functions that needn't be constantly updated
watch('echo', 60, function()
    -- music cache
    awful.spawn.easy_async_with_shell('cat ~/stuff/awesome/cmus-cache.txt', function(stdout)
        cache = { }
        for line in stdout:gmatch('[^\r\n]+') do
            filename, title = line:match('<(.-)> <(.-)>')
            cache[filename] = title
        end
        stats.music_cache = cache
    end)

    -- usage of hard drive
    awful.spawn.easy_async('df', function(stdout)
        local root_used, root_available = stdout:match('/dev/sda2 +%d+ +(%d+) +(%d+)')
        -- local home_used, home_available = stdout:match('/dev/sda7 +%d+ +(%d+) +(%d+)')
        root_used, root_available = tonumber(root_used), tonumber(root_available)
        -- home_used, home_available = tonumber(home_used), tonumber(home_available)
        stats.root = root_used / (root_used + root_available)
        -- stats.home = home_used / (home_used + home_available)
    end)

    -- to-do
    awful.spawn.easy_async_with_shell('cat /home/void/.todo', function(stdout)
        local lines = { 'Todo:' }
        for line in stdout:gmatch('[^\r\n]+') do
            table.insert(lines, line)
        end
        stats.todo = lines
    end)

    -- time
    awful.spawn.easy_async('date "+%R"', function(stdout)
        local hours, minutes = stdout:match('(%d%d):(%d%d)')
        stats.hours = tonumber(hours)
        stats.minutes = tonumber(minutes)
    end)

    -- date
    awful.spawn.easy_async('date "+%d %b"', function(stdout)
        stdout = stdout:match('(.+)\n')
        stats.date = stdout
    end)

    -- battery
    awful.spawn.easy_async('acpi', function(stdout)
        local percent = stdout:match(' (%d+)%%')
        stats.battery = tonumber(percent / 100)
    end)
end)


watch(
    'echo',
    TICK_SPEED,
    function()
        -- music progress
        awful.spawn.easy_async_with_shell('cmus-remote -Q', function(stdout)
            pcall(function()
                local duration = stdout:match('duration (%d+)')
                local position = stdout:match('position (%d+)')
                -- convert seconds to minutes:seconds
                local d_minutes = math.floor(duration / 60)
                local d_seconds = duration % 60
                local p_minutes = math.floor(position/ 60)
                local p_seconds = position % 60

                stats.position = string.format('%d:%2d / %d:%2d', p_minutes, p_seconds, d_minutes, d_seconds)
            end)
        end)

        -- current play queue
        awful.spawn.easy_async_with_shell('cmus-remote -C "save -"', function(stdout)
            -- split by \n
            local lines = { 'Play Queue:' }
            for line in stdout:gmatch('[^\r\n]+') do
                line = stats.music_cache[line]
                table.insert(lines, line)
            end
            stats.queue = lines
        end)

        -- cpu temperatures
        awful.spawn.easy_async_with_shell('cat /sys/class/thermal/thermal_zone0/temp /sys/class/thermal/thermal_zone1/temp /sys/class/thermal/thermal_zone2/temp /sys/class/thermal/thermal_zone3/temp /sys/class/thermal/thermal_zone4/temp /sys/class/thermal/thermal_zone5/temp /sys/class/thermal/thermal_zone6/temp /sys/class/thermal/thermal_zone7/temp /sys/class/thermal/thermal_zone8/temp', function(stdout)
            -- split by \n
            local lines = { }
            for line in stdout:gmatch('[^\r\n]+') do
                table.insert(lines, line)
            end
            stats.temp0 = tonumber(lines[1] / 100000)
            stats.temp1 = tonumber(lines[2] / 100000)
            stats.temp2 = tonumber(lines[3] / 100000)
            stats.temp3 = tonumber(lines[4] / 100000)
            stats.temp4 = tonumber(lines[5] / 100000)
            stats.temp5 = tonumber(lines[6] / 100000)
            stats.temp6 = tonumber(lines[7] / 100000)
            stats.temp7 = tonumber(lines[8] / 100000)
            stats.temp8 = tonumber(lines[9] / 100000)
        end)

        -- ram usage
        awful.spawn.easy_async('free', function(stdout)
            local ram_total, ram_used = stdout:match('Mem: +(%d+) + (%d+)')
            ram_total, ram_used = tonumber(ram_total), tonumber(ram_used)
            local swap_total, wap_used = stdout:match('Swap: +(%d+) + (%d+)')
            ram_total, ram_used = tonumber(ram_total), tonumber(ram_used)
            stats.ram = ram_used / ram_total
            stats.swap = swap_used / swap_total
        end)

        -- wifi monitor
        awful.spawn.easy_async_with_shell('ifconfig > /home/void/.ifconfig', function()
            local f = io.open('/home/void/.ifconfig', 'r')
            local text = f:read('*all')
            f:close()
            -- split into lines
            local lines = {}
            local append = false
            for line in text:gmatch('[^\r\n]+') do
                if line:find('wlp5s0') then
                    append = true
                end
                if append then
                    table.insert(lines, line)
                end
                if line:find('RX bytes') and append then
                    local _ = tonumber(line:match('RX bytes:%s*(%d+)'))
                    stats.rx = _ - stats.last_rx
                    stats.last_rx = _
                end
                if line:find('TX bytes') and append then
                    local _ = tonumber(line:match('TX bytes:%s*(%d+)'))
                    stats.tx = _ - stats.last_tx
                    stats.last_tx = _
                end
            end

            stats.wifi = lines
        end)

        -- ping
        awful.spawn.easy_async_with_shell('ping -c 1 www.google.com', function(stdout)
            -- split by \n
            local lines = {}
            for line in stdout:gmatch('[^\r\n]+') do
                if line:find('bytes from') then
                    stats.ping = tonumber(line:match('time=(%d+)'))
                end
            end
        end)

        -- syslog
        awful.spawn.easy_async_with_shell('cat /var/log/socklog/everything/current | tail -n 6 | cut -c 1-130', function(stdout)
            local lines = {'socklog:'}
            for line in stdout:gmatch('[^\r\n]+') do
                line = line:gsub('inspiron ', '')
                line = line:match('.-(%d%d:%d%d:%d%d.+)')
                table.insert(lines, line)
            end
            if #lines == 1 then
                lines = { 'No logging information :/' }
            end
            stats.syslog = lines
        end)

        -- top processes by cpu
        awful.spawn.easy_async('top_cpu', function(stdout)
            local lines = { 'CPU:' }
            for line in stdout:gmatch('[^\r\n]+') do
                table.insert(lines, line)
            end
            stats.top_cpu = lines
        end)

        -- top processes by ram
        awful.spawn.easy_async('top_mem', function(stdout)
            local lines = { 'RAM:' }
            for line in stdout:gmatch('[^\r\n]+') do
                table.insert(lines, line)
            end
            stats.top_mem = lines
        end)

        -- cpu load for each core
        awful.spawn.easy_async(
            'cpu-ping',
            function(stdout)
                pcall(function()
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
        end)

        -- album - artist currently playing
        awful.spawn.easy_async_with_shell('cmus-remote -Q', function(stdout)
            local artist, album = stdout:match('tag artist (.-)\ntag album (.-)\n')
            stats.currently_playing = artist .. ' - ' .. album
        end)

        -- album cover of currently playing album
        awful.spawn.easy_async_with_shell('cmus-remote -Q', function(stdout)
            local path = stdout:match('file (.-)\n')
            stats.album_cover = path .. '.png.small'
        end)

        table.insert(cpu_points.cpu0, stats.cpu0)
        table.insert(cpu_points.cpu1, stats.cpu1)
        table.insert(cpu_points.cpu2, stats.cpu2)
        table.insert(cpu_points.cpu3, stats.cpu3)
        table.insert(cpu_points.cpu4, stats.cpu4)
        table.insert(cpu_points.cpu5, stats.cpu5)
        table.insert(cpu_points.cpu6, stats.cpu6)
        table.insert(cpu_points.cpu7, stats.cpu7)

        table.insert(rx_points, stats.rx / (6000000))
        table.insert(tx_points, stats.tx / (6000000))
        table.insert(ping_points, stats.ping / 60)
    end
)
