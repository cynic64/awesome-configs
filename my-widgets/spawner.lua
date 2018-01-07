local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local naughty = require('naughty')
local gears = require('gears')
require('my-widgets.tools')

local programs = 'echo "efficiency\nminimal\ncolorswitcher\nemacs wall\naxe\ndisable axe/artemis\ncave\ngap changer\nborder width\npadding\nspawn tools\nlock\nunhide all\ntoggle titlebars\nfocus\nmake wallpaper\nvis" | rofi -dmenu'

function update_tag()
    -- current tag
    log('tags switched')
    local tag, i
    current_tag = 'idk'
    local tags = root.tags()
    for _, tag in ipairs(tags) do
        if tag.selected then
            current_tag = tag
        end
    end
    log('\t' .. current_tag.name)

    w.children[1].image = icondir .. current_tag.name .. '.png'
end

function change_colors(stdout)
    if not stdout then return end
    current_wall = stdout
    awful.spawn.easy_async_with_shell(
        'python3 /home/void/stuff/python/wall-based.py ' .. stdout,
        function()
            gears.wallpaper.fit('/home/void/stuff/awesome/black.jpg')
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
            update_axe()
            blur_wall()
        end)
end

function colorswitcher()
    awful.spawn.easy_async_with_shell(
        'ls /home/void/stuff/awesome/pngs/ | shuf | rofi -dmenu',
        function(stdout)
            stdout = stdout:match('(.+)\n')
            change_colors(stdout)
        end)
end

function gap_changer()
    awful.spawn.easy_async_with_shell(
        'echo "0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12\n13\n14\n15\n16\n17\n18\n19\n20\n21\n22\n23\n24\n25\n26\n27\n28\n29\n30\n31\n32" | rofi -show -dmenu',
        function(stdout)
            beautiful.useless_gap = tonumber(stdout)
            local current_layout = awful.layout.get()
            awful.layout.set(awful.layout.suit.magnifier)
            awful.layout.set(current_layout)
            bart_update()
    end)
end

function border_changer()
    awful.spawn.easy_async_with_shell(
        'echo "0\n1\n2\n3\n4" | rofi -show -dmenu',
        function(stdout)
            stdout = tonumber(stdout)
            beautiful.border_width = stdout
            for _, c in ipairs(client.get()) do
                c.border_width = stdout
            end
            bart_update()
    end)
end

function padding_changer()
    awful.spawn.easy_async_with_shell(
        'echo "0\n20\n40\n60\n80\n100\n120\n140\n160\n180\n200" | rofi -show -dmenu',
        function(stdout)
            stdout = tonumber(stdout)
            screen.primary.padding = { top = stdout, left = stdout, bottom = stdout, right = stdout }
    end)
    bart_update()
end

function efficient()
    if efficiency then       -- make things inefficient
        _ = 100
        screen.primary.padding = { top = _, left = _, right = _, bottom = _ }

        stdout = 1
        beautiful.border_width = stdout
        for _, c in ipairs(client.get()) do
            c.border_width = stdout
        end

        stdout = 16
        beautiful.useless_gap = tonumber(stdout)
        local current_layout = awful.layout.get()
        awful.layout.set(awful.layout.suit.magnifier)
        awful.layout.set(current_layout)
    else                     -- make thing efficient
        _ = 0
        screen.primary.padding = { top = _, left = _, right = _, bottom = 32 }

        stdout = 0
        beautiful.border_width = stdout
        for _, c in ipairs(client.get()) do
            c.border_width = stdout
        end

        stdout = 0
        beautiful.useless_gap = tonumber(stdout)
        local current_layout = awful.layout.get()
        awful.layout.set(awful.layout.suit.magnifier)
        awful.layout.set(current_layout)
    end
    efficiency = not efficiency
    bart_update()
end

function layoutswitcher()
    awful.spawn.easy_async_with_shell(
        'echo "tile\nfloating\nfair\nmax\nmagnifier" | rofi -dmenu -show',
        function(out)
            local l = awful.layout.suit
            local out = string.match(out, '(.+)\n')
            if out == 'floating' then
                awful.layout.set(l.floating)
            elseif out == 'tile' then
                awful.layout.set(l.tile)
            elseif out == 'fair' then
                awful.layout.set(l.fair)
            elseif out == 'max' then
                awful.layout.set(l.max)
            elseif out == 'magnifier' then
                awful.layout.set(l.magnifier)
            elseif out == 'treetile' then
                awful.layout.set(treetile)
            end
            bart_update()
    end)
end

function spawner()
    awful.spawn.easy_async_with_shell(
        programs,
        function(out)
            local out = string.match(out, '(.+)\n')
            if out == 'colorswitcher' then
                colorswitcher()
            elseif out == 'gap changer' then
                gap_changer()
            elseif out == 'spawn tools' then
                spawn_tools()
            elseif out == 'lock' then
                awful.spawn('xtrlock')
            elseif out == 'unhide all' then
                for _, c in ipairs(client.get()) do
                    c.minimized = false
                end
            elseif out == 'emacs wall' then
                gears.wallpaper.fit('/home/void/useless-shit/emacs-wall.png')
            elseif out == 'toggle titlebars' then
                for _, c in ipairs(client.get()) do
                    awful.titlebar.toggle(c)
                end
            elseif out == 'focus' then
                if client.focus.opacity < 1 then
                    client.focus.opacity = 1
                else
                    client.focus.opacity = beautiful.unfocused_opacity
                end
            elseif out == 'vis' then
                awful.spawn('urxvt -fn "xft:Monaco:pixelsize=2" -e vis')
            elseif out == 'border width' then
                border_changer()
            elseif out == 'padding' then
                padding_changer()
            elseif out == 'efficiency' then
                efficient()
            elseif out == 'make wallpaper' then
                client.focus.sticky = true
                client.focus.fullscreen = true
                client.focus.below = true
                client.focus.focusable = false
                client.focus.opacity = 1
            elseif out == 'minimal' then
                if not minimal then       -- make things minimal
                    gears.wallpaper.fit('/home/void/stuff/awesome/black.jpg')
                    current_mon = 'was ' .. current_mon
                    art_update()
                    update_axe()
                    bart.opacity = 0
                    efficiency = false
                    efficient()
                    awful.screen.focused().padding = { top = 0, bottom = 0, left = 0, right = 0 }
                    minimal = true
                elseif minimal then
                    current_mon = current_mon:match('was (.+)')
                    art_update()
                    update_axe()
                    bart.opacity = 1
                    efficiency = true
                    efficient()
                    minimal = false
                end
            elseif out == 'axe' then
                toggle_axe()
                artemis_visible = not artemis_visible
                if artemis_visible then current_mon = 'artemis' else current_mon = 'axe' end
                art_update()
            elseif out == 'disable axe/artemis' then
                current_mon = 'none'
                blur_wall()
            elseif out == 'cave' then
                awful.spawn.with_shell('zsh ~/stuff/zsh/scripts/cave')
            end
    end)
end
