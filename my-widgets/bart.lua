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

local w = wibox.widget {
    {
        -- cairo surface
        widget = wibox.widget.imagebox
    },
    layout = wibox.layout.stack
}

-- create menus
rache.add( { name = 'tags', width = 200, height = 100, x = 100, y = 100 }, function() end)
rache.add( { name = 'layout', width = 200, height = 100, x = 200, y = 200 }, function() end)
rache.add( { name = 'music', width = 400, height = 200, x = 1920 / 2 + 300 - 400 / 2, y = 1080 - 32 - 200 }, function(clicked_title)
        log('yo!')
        log(clicked_title)
        for i, title in ipairs(stats.queue) do
            if title == clicked_title then
                for _=1,i-1 do
                    awful.spawn.easy_async_with_shell('cmus-remote --next', function()
                                                          stats.currently_playing = clicked_title
                                                          bart_update()
                    end)
                end
            end
        end
end)
rache.add(
    { name = 'colors', width = 160, height = 400, x = 1920 - 500, y = 1080 - 32 - 400 },
    function(choice)
        local _ = 'python3 /home/void/stuff/python/wall-based.py ' .. choice
        awful.spawn.easy_async_with_shell(_,
                                          function()
                                              gears.wallpaper.fit('/home/void/stuff/awesome/bg.png')
                                              reload_xterm()
                                              beautiful.border_color = xterm.red
                                              for _, c in ipairs(client.get()) do
                                                  if client.focus == c then
                                                      c.border_color = beautiful.border_color
                                                  else
                                                      c.border_color = '#000000'
                                                  end
                                              end
                                              art_update()
                                              bart_update()
        end)
end)

-- generate a list of wallpapers
awful.spawn.easy_async_with_shell('ls ~/stuff/awesome/pngs', function(stdout)
                                      local walls = { }
                                      for line in stdout:gmatch('[^\r\n]+') do
                                          table.insert(walls, line)
                                      end
                                      rache.set_items('colors', walls)
end)

bart = wibox { width = s_width, height = s_height, visible = true, bg = bg_color, ontop = true, widget = w }

awful.placement.bottom(bart)
bart.opacity = 1

bart:connect_signal('button::press', function()
                        if bart.opacity == 1 then bart.opacity = 0
                        elseif bart.opacity == 0 then bart.opacity = 1 end
end)

local w_cairo = w.children[1]

local menu_rects = {
    tags = { 0, 0, 280, s_height } ,
    layout = { 280, 0, 40, s_height },
    music = { s_width / 2 + 200, 0, 200, s_height },
    colors = { s_width - 620, 0, 160, s_height }
}

local current_menu = 'none'

function bart_update()
    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, s_width, s_height)
    local cr = cairo.Context(img)

    cr:set_source(gears.color(bg_color))
    cr:rectangle(0, 0, s_width, s_height)
    cr:fill()
    cr:set_line_width(0.5)
    cr:set_source(gears.color(xterm.red))
    cr:rectangle(0, 0, s_width, s_height)
    cr:stroke()

    cr:select_font_face('Liberation Mono for Powerline')
    cr:set_font_size(12)
    cr:set_source(gears.color(text_color))

    -- taglist
    local tags = awful.screen.focused().tags
    local x, y = s_height / 2, s_height / 2
    local radius = (s_height * 0.6) / 2
    cr:set_line_width(0.5)

    for i, tag in ipairs(tags) do
        -- underline - red if it's selected
        cr:set_source(gears.color(line_color))
        if tag.selected then
            cr:set_source(gears.color(xterm.red))
        end
        cr:move_to(x - 10, s_height - 2)
        cr:line_to(x + 10, s_height - 2)
        cr:stroke()

        -- put a dot in the middle if it has clients
        -- 1 dot per client
        cr:set_source(gears.color(line_color))
        local _ = #tag:clients()
        if _ == 1 then
            cr:arc(x, y, radius / 6, 0 * math.pi, 2 * math.pi)
            cr:fill()
        elseif _ > 1 then
            local points = {}
            local step = 360 / _

            for i=1,_ do
                point = diagonal(x, y, step * i, radius / 2)
                table.insert(points, point)
            end

            for _, point in ipairs(points) do
                local px, py = point[1], point[2]
                cr:arc(px, py, radius / 6, 0, 2 * math.pi)
                cr:fill()
            end
        end

        x = x + 30
    end

    x, y = 300, s_height / 2
    radius = s_height / 2 - padding * 2
    cr:set_source(gears.color(xterm.red))
    local layout_name = awful.screen.focused().selected_tag.layout.name
    if layout_name == 'tile' then
        cr:rectangle(x - radius, y - radius, radius * 2, radius * 2)
        cr:move_to(x, y - radius)
        cr:line_to(x, y + radius)
        cr:move_to(x, y)
        cr:line_to(x + radius, y)
        cr:stroke()
    elseif layout_name == 'floating' then
        cr:arc(x, y, radius, 0, math.pi * 2)
        cr:stroke()
        cr:arc(x, y, radius / 2, 0, math.pi * 2)
        cr:stroke()
    elseif layout_name == 'fairv' then
        cr:rectangle(x - radius, y - radius, radius * 2, radius * 2)
        cr:move_to(x, y - radius)
        cr:line_to(x, y + radius)
        cr:move_to(x - radius, y)
        cr:line_to(x + radius, y)
        cr:stroke()
    elseif layout_name == 'max' then
        cr:rectangle(x - radius, y - radius, radius * 2, radius * 2)
        cr:move_to(x, y - radius / 2)
        cr:line_to(x, y + radius / 2)
        cr:move_to(x - radius / 2, y)
        cr:line_to(x + radius / 2, y)
        cr:stroke()
    elseif layout_name == 'magnifier' then
        cr:rectangle(x - radius, y - radius, radius * 2, radius * 2)
        cr:rectangle(x - radius / 2, y - radius / 2, radius, radius)
        cr:move_to(x, y - radius)
        cr:line_to(x, y - radius/ 2)
        cr:move_to(x, y + radius)
        cr:line_to(x, y + radius / 2)
        cr:move_to(x - radius, y)
        cr:line_to(x - radius / 2, y)
        cr:move_to(x + radius, y)
        cr:line_to(x + radius / 2, y)
        cr:stroke()
    elseif layout_name == 'treetile' then
        cr:move_to(x, y + radius)
        cr:line_to(x, y)
        cr:move_to(x - radius / 2, y)
        cr:line_to(x + radius / 2, y)
        cr:move_to(x - radius / 2, y)
        cr:line_to(x - radius / 2, y - radius / 2)
        cr:move_to(x + radius / 2, y)
        cr:line_to(x + radius / 2, y - radius / 2)
        cr:move_to(x + radius * 0.8, y - radius / 2)
        cr:line_to(x + radius * 0.2, y - radius / 2)
        cr:move_to(x - radius * 0.8, y - radius / 2)
        cr:line_to(x - radius * 0.2, y - radius / 2)
        cr:move_to(x + radius * 0.8, y - radius / 2)
        cr:line_to(x + radius * 0.8, y - radius * 0.75)
        cr:move_to(x + radius * 0.2, y - radius / 2)
        cr:line_to(x + radius * 0.2, y - radius * 0.75)
        cr:move_to(x - radius * 0.8, y - radius / 2)
        cr:line_to(x - radius * 0.8, y - radius * 0.75)
        cr:move_to(x - radius * 0.2, y - radius / 2)
        cr:line_to(x - radius * 0.2, y - radius * 0.75)
        cr:stroke()
    end

    -- schedule
    local total_start_x, total_stop_x = 350, s_width - 800
    local scale = (total_stop_x - total_start_x) / 1440
    -- load schedule
    awful.spawn.easy_async_with_shell(
        'cat ~/stuff/awesome/schedule.txt',
        function(stdout)
            stats.schedule = { }
            for line in stdout:gmatch('[^\r\n]+') do
                table.insert(stats.schedule, line)
            end
    end)


    cr:set_line_width(0.5)
    cr:set_font_size(8)
    for _, line in ipairs(stats.schedule) do
        local name, start_hour, start_min, stop_hour, stop_min, color = line:match('(%a+) (%d+):(%d+) %- (%d+):(%d+) (.+)')
        local start_t, stop_t = 60 * tonumber(start_hour) + tonumber(start_min), 60 * tonumber(stop_hour) + tonumber(stop_min)
        cr:set_source(gears.color(xterm[color]))
        local sx = total_start_x + start_t * scale + 1
        local ex = total_start_x + stop_t * scale - 1
        cr:move_to(sx, s_height - 2)
        cr:line_to(ex, s_height - 2)
        cr:stroke()
        center_text(cr, (sx + ex) / 2, s_height / 2 + 3, name)
    end
    cr:set_font_size(12)

    -- show current location
    local current_pos = stats.hours * 60 + stats.minutes
    local pos_x = total_start_x + current_pos * scale
    cr:move_to(pos_x, s_height * 0.75)
    cr:line_to(pos_x, s_height)

    -- music
    cr:set_source(gears.color(text_color))
    local width = cr:text_extents(stats.currently_playing).width
    local x = s_width / 2 + 300
    cr:move_to(x - width / 2, 20)
    cr:show_text(stats.currently_playing)
    cr:stroke()

    -- date
    cr:set_source(gears.color(text_color))
    cr:move_to(s_width - 130, 20)
    cr:show_text(stats.date)
    cr:stroke()

    -- time
    cr:set_source(gears.color(text_color))
    cr:move_to(s_width - 70, 20)
    cr:show_text(stats.hours .. ':' .. stats.minutes)
    cr:stroke()

    -- color circles
    _ = xterm
    local colors = { _.red, _.green, _.yellow, _.blue, _.magenta, _.cyan }
    local width = s_height * 0.75
    local x = s_width - 510
    local y = s_height / 2
    local radius = s_height / 6

    for i, color in ipairs(colors) do
        cr:set_source(gears.color(color))
        cr:arc(x, y, radius, 0, 2 * math.pi)
        cr:fill()

        x = x + width
    end

    -- gaps
    local width = cr:text_extents(beautiful.useless_gap).width
    x = s_width - 300 - width / 2
    _ = x + width / 2
    cr:set_source(gears.color(text_color))
    cr:move_to(x, 20)
    cr:show_text(beautiful.useless_gap)
    cr:stroke()

    -- gap 'icon'
    cr:set_source(gears.color(xterm.red))
    local spike = 4
    local v_dist = 12
    cr:move_to(_ + width, v_dist)
    cr:line_to(_ + width + spike, s_height / 2)
    cr:line_to(_ + width, s_height - v_dist)
    cr:stroke()
    cr:move_to(_ - width, v_dist)
    cr:line_to(_ - width - spike, s_height / 2)
    cr:line_to(_ - width, s_height - v_dist)
    cr:stroke()

    -- borders
    cr:set_source(gears.color(text_color))
    _ = s_width - 250
    radius = s_height / 4 + beautiful.border_width
    local width = cr:text_extents(beautiful.border_width).width
    cr:move_to(_ - width / 2, 20)
    cr:show_text(beautiful.border_width)
    cr:stroke()

    -- border 'icon'
    cr:set_source(gears.color(xterm.red))
    cr:set_line_width(1)
    cr:rectangle(_ - radius, s_height / 2 - radius, radius * 2 + 1, radius * 2)
    cr:stroke()

    -- padding
    local width = cr:text_extents(screen.primary.padding.bottom).width
    _ = s_width - 200
    radius = s_height * 0.6 / 2
    cr:set_source(gears.color(text_color))
    cr:move_to(_ - width / 2, 20)
    cr:show_text(screen.primary.padding.bottom)
    cr:stroke()

    -- padding 'icon'
    cr:set_source(gears.color(xterm.red))
    __ = screen.primary.padding.bottom / 32
    cr:rectangle(_ - width / 2 - radius - __, s_height / 2 - radius, width + radius * 2 + __ * 2, radius * 2)
    cr:stroke()

    -- battery meter
    local center_x = s_width - 85
    local width = 160
    cr:set_line_width(2)
    cr:set_source(gears.color(xterm.red))
    cr:move_to(center_x - width / 2, s_height * 0.8)
    cr:line_to(center_x - width / 2 + width * stats.battery, s_height * 0.8)
    cr:stroke()
    -- center_text(cr, center_x, s_height * 0.7, tostring(stats.battery * 100) .. '%')

    -- update cairo surface
    w_cairo.image = img
end

function check_mouseover()
    local _ = mouse.coords()
    local x, y = _.x, _.y
    -- correct for bart's position
    x = x - bart.x
    y = y - bart.y

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
                -- rache.set_items('music', stats.queue)
                rache.set_items('music', { 'a 1', 'a 2', 'wheee!', 'let\'s see if this works', 'scroll already!', 'more.', '.', 'how much farther?', 'derp.' })
            end
            rache.toggle(current_menu)
        end
    end
end

bart:connect_signal('mouse::move', check_mouseover)
bart:connect_signal('mouse::leave', function() current_menu = 'none' end)

awful.spawn.easy_async_with_shell('sleep 1', function()
                                      bart_update()
end)

watch('echo', 60, function()
          bart_update()
end)
