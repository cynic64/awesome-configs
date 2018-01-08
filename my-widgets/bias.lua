-- if the mouse is clicked over the wallpaper, make shit appear
local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local naughty = require('naughty')
local watch = require('awful.widget.watch')
local gears = require('gears')
local cairo = require('lgi').cairo

local opac = 0.7

local function show_cave()
    for _, c in ipairs(client.get()) do
        if c.name == '"cmus"' or c.name == 'cava' or c.name == 'neofetch' or c.name == 'pipes.sh' or c.name == 'pstree' or c.name == 'htop' then
            if bias_state == 'hidden' then
                -- test
                c.opacity = opac
                c.minimized = false
                axebox.visible = false
                artemis_visible = false
                art_update()
            elseif bias_state == 'shown' then
                c.opacity = 0
                c.minimized = true
                if current_mon == 'artemis' then artemis_visible = true
                elseif current_mon == 'axe' then axebox.visible = true
                end
                art_update()
            end
            if visible_clients then c.ontop = true else c.ontop = false end
        end
    end
    if bias_state == 'hidden' then bias_state = 'shown'
    else bias_state = 'hidden' end
end

local hitbox = wibox { width = 1920, height = 1080, visible = true, opacity = 0, bg='#ff0000', below = true }

hitbox:connect_signal('button::press', show_cave)
axebox:connect_signal('button::press', show_cave)
