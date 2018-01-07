-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- collision
require("collision")()

-- requiring my functions
require('my-widgets.casi')
require('my-widgets.bart')
require('my-widgets.artemis')
require('my-widgets.axe')
require('my-widgets.spawner')
require('my-widgets.bias')

-- tree-tile
local treetile = require("treetile")

-- set efficiency and minimal-ness
efficiency = true
minimized = true

current_wall = 'wire'
current_mon = 'artemis'         -- either artemis, axe, or none

-- helpful functions
function blur_wall()
        tag = awful.screen.focused().selected_tag
        visible_clients = false
        for _, c in ipairs(tag:clients()) do
            if not c.minimized and c.name ~= '"cmus"' and c.name ~= 'neofetch' and c.name ~= 'cava' and c.opacity > 0 and c.name ~= 'pipes.sh' and c.name ~= 'pstree' then
                visible_clients = true
            end
        end
        if visible_clients then
            gears.wallpaper.fit('/home/void/stuff/awesome/blurred/' .. current_wall .. '.blur')
            axebox.visible = false
            artemis_visible = false
            for _, c in ipairs(client.get()) do
                if c.name == '"cmus"' or c.name == 'cava' or c.name == 'neofetch' or c.name == 'pipes.sh' or c.name == 'pstree' then
                    c.minimized = true
                end
            end
        else
            gears.wallpaper.fit('/home/void/stuff/awesome/pngs/' .. current_wall)
            if current_mon == 'artemis' then
                axebox.visible = false
                artemis_visible = true
            elseif current_mon == 'axe' then
                axebox.visible = true
                artemis_visible = false
            else
                axebox.visible = false
                artemis_visible = false
            end
            art_update()
        end
end

-- global variables --
home = os.getenv('HOME') .. '/'
icondir = home .. 'stuff/awesome/icons/'

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
                               -- Make sure we don't go into an endless error loop
                               if in_error then return end
                               in_error = true

                               naughty.notify({ preset = naughty.config.presets.critical,
                                                title = "Oops, an error happened!",
                                                text = tostring(err) })
                               in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(home .. '.config/awesome/theme.lua')

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    treetile,
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    --awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
    { "hotkeys", function() return false, hotkeys_popup.show_help end},
    { "manual", terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end}
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                              { "open terminal", terminal }
}
                       })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
            if client.focus then
                client.focus:move_to_tag(t)
            end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
            if client.focus then
                client.focus:toggle_tag(t)
            end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
            if c == client.focus then
                c.minimized = true
            else
                -- Without this, the following
                -- :isvisible() makes no sense
                c.minimized = false
                if not c:isvisible() and c.first_tag then
                    c.first_tag:view_only()
                end
                -- This will also un-minimize
                -- the client, if needed
                client.focus = c
                c:raise()
            end
    end),
    awful.button({ }, 3, client_menu_toggle_fn()),
    awful.button({ }, 4, function ()
            awful.client.focus.byidx(1)
    end),
    awful.button({ }, 5, function ()
            awful.client.focus.byidx(-1)
end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.fit(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
        -- Wallpaper
        gears.wallpaper.fit('~/stuff/awesome/black.jpg')
        gears.wallpaper.fit(beautiful.wallpaper)

        -- Each screen has its own tag table.
        --awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
        local l = awful.layout.suit  -- Just to save some typing: use an alias.

        awful.tag.add('term', {
                          layout = l.tile,
                          screen = s,
                          selected = true
        })

        awful.tag.add('www', {
                          layout = l.tile,
                          screen = s,
        })

        awful.tag.add('top', {
                          layout = l.tile,
                          screen = s,
        })

        awful.tag.add('gimp', {
                          layout = l.tile,
                          screen = s,
        })

        awful.tag.add('music', {
                          layout = l.tile,
                          screen = s,
        })

        awful.tag.add('blend', {
                          layout = l.tile,
                          screen = s,
        })

        awful.tag.add('rc', {
                          layout = l.tile,
                          screen = s,
        })

        awful.tag.add('arc', {
                          layout = l.tile,
                          screen = s,
        })

        awful.tag.add('9', {
                          layout = l.fair,
                          screen = s,
        })

        -- Create a promptbox for each screen
        s.mypromptbox = awful.widget.prompt()
        -- Create an imagebox widget which will contain an icon indicating which layout we're using.
        -- We need one layoutbox per screen.
        s.mylayoutbox = awful.widget.layoutbox(s)
        s.mylayoutbox:buttons(gears.table.join(
                                  awful.button({ }, 1, function () awful.layout.inc( 1) end),
                                  awful.button({ }, 3, function () awful.layout.inc(-1) end),
                                  awful.button({ }, 4, function () awful.layout.inc( 1) end),
                                  awful.button({ }, 5, function () awful.layout.inc(-1) end)))
        -- Create a taglist widget
        s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

        -- Create a tasklist widget
        s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

        -- Create the wibox
        --s.mywibox = awful.wibar({ position = "top", screen = s })

        -- Add widgets to the wibox
        --[[
            s.mywibox:setup {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
            },
            s.mytasklist, -- Middle widget
            { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            wibox.widget.systray(),
            mytextclock,
            s.mylayoutbox,
            },
            }
        ]]
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
                 awful.button({ }, 3, function () mymainmenu:toggle() end),
                 awful.button({ }, 4, awful.tag.viewnext),
                 awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- idk where to put these
local popped_geo = { width = 1920/3, height = 1080/3, x = 1920*0.16, y = 1080*0.16 }

-- {{{ Key bindings
globalkeys = gears.table.join(
    -- snapping
    awful.key({ modkey}, 's',
        function()
            --[[
            keygrabber.run(function(mod, key, event)
                    if event == 'release' then return end
                    end
            end)
            ]]
            if not client.focus.floating then
                client.focus.floating = true
            end
            client.focus:geometry(popped_geo)
            awful.placement.centered(client.focus)
            keygrabber.run(function(mod, key, event)
                    if event == 'release' then return end

                    if key == 'w' then awful.placement.top(client.focus)
                    elseif key == 'x' then awful.placement.bottom(client.focus)
                    elseif key == 'a' then awful.placement.left(client.focus)
                    elseif key == 'd' then awful.placement.right(client.focus)
                    elseif key == 'q' then awful.placement.top_left(client.focus)
                    elseif key == 'e' then awful.placement.top_right(client.focus)
                    elseif key == 'z' then awful.placement.bottom_left(client.focus)
                    elseif key == 'c' then awful.placement.bottom_right(client.focus)
                    elseif key == 's' then awful.placement.centered(client.focus)
                    elseif key == 'Up' or key == 'k' or key == 'p' then
                        keygrabber.stop()
                        client.focus.floating = true
                        local axis = 'horizontally'
                        local f = awful.placement.scale
                            + awful.placement.top
                            + (axis and awful.placement['maximize_'..axis] or nil)
                        local geo = f(client.focus, {honor_workarea=true, to_percent = 0.5})
                    elseif key == 'Down' or key == 'j' or key == 'n' then
                        keygrabber.stop()
                        client.focus.floating = true
                        local axis = 'horizontally'
                        local f = awful.placement.scale
                            + awful.placement.bottom
                            + (axis and awful.placement['maximize_'..axis] or nil)
                        local geo = f(client.focus, {honor_workarea=true, to_percent = 0.5})
                    elseif key == 'Left' or key == 'h' or key == 'b' then
                        keygrabber.stop()
                        client.focus.floating = true
                        local axis = 'vertically'
                        local f = awful.placement.scale
                            + awful.placement.left
                            + (axis and awful.placement['maximize_'..axis] or nil)
                        local geo = f(client.focus, {honor_workarea=true, to_percent = 0.5})
                    elseif key == 'Right' or key == 'l' or key == 'f' then
                        keygrabber.stop()
                        client.focus.floating = true
                        local axis = 'vertically'
                        local f = awful.placement.scale
                            + awful.placement.right
                            + (axis and awful.placement['maximize_'..axis] or nil)
                        local geo = f(client.focus, {honor_workarea=true, to_percent = 0.5})
                    end
                    keygrabber.stop()
            end)
        end,
        {description = 'snap focused client', group = 'idk'}),

    awful.key({ modkey }, "x", spawner,
        {description = "spawner", group = "idk"}),

    awful.key({ modkey }, "=", function()
            local tag = awful.screen.focused().selected_tag
            for _, c in ipairs(tag:clients()) do
                c.opacity = 0
            end
            blur_wall()
        end,
        {description = "hide all", group = "idk"}),

    awful.key({ modkey }, "BackSpace", function()
            local tag = awful.screen.focused().selected_tag
            for _, c in ipairs(tag:clients()) do
                c.minimized = false
                c.opacity = 0.7
            end
            blur_wall()
        end,
        {description = "unhide all", group = "idk"}),

    awful.key({ modkey }, 'p', function()
            client.focus.floating = not client.focus.floating
            client.focus:geometry(popped_geo)
                               end,
        {description='pop window', group="idk"}),

    awful.key({ modkey, 'Shift'   }, "s",      hotkeys_popup.show_help,
        {description="show help", group="awesome"}),
    --[[
    awful.key({ modkey,           }, "Left", function()
            awful.tag.viewprev()
            bart_update()
                                             end,
        {description = "view previous", group = "tag"}),

    awful.key({ modkey,           }, "Right", function()
            awful.tag.viewnext()
            bart_update()
                                              end,
        {description = "view next", group = "tag"}),
    ]]

    awful.key({ modkey,           }, "Escape", function()
            blur_wall()
            awful.tag.history.restore()
            bart_update()
                                               end,
        {description = "go back", group = "tag"}),


    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
        {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
        {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
        {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
        {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
        {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
        {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
        {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
        {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
        {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
        {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
        {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
        {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
        {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
        {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
        {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function ()
            awful.layout.inc( 1)
            bart_update()
                                              end,
        {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function ()
            awful.layout.inc(-1)
            bart_update()
                                              end,
        {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
        function ()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                client.focus = c
                c:raise()
            end
        end,
        {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.spawn.with_shell('rofi -show run') end,
        {description = "run prompt", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
        {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
        {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
        {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
        {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
        {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
                                  -- View tag only.
                                  awful.key({ modkey }, "#" .. i + 9,
                                      function ()
                                          local screen = awful.screen.focused()
                                          local tag = screen.tags[i]
                                          if tag then
                                              tag:view_only()
                                          end
                                          bart_update()
                                          blur_wall()
                                      end,
                                      {description = "view tag #"..i, group = "tag"}),
                                  -- Toggle tag display.
                                  awful.key({ modkey, "Control" }, "#" .. i + 9,
                                      function ()
                                          local screen = awful.screen.focused()
                                          local tag = screen.tags[i]
                                          if tag then
                                              awful.tag.viewtoggle(tag)
                                          end
                                          bart_update()
                                      end,
                                      {description = "toggle tag #" .. i, group = "tag"}),
                                  -- Move client to tag.
                                  awful.key({ modkey, "Shift" }, "#" .. i + 9,
                                      function ()
                                          if client.focus then
                                              local tag = client.focus.screen.tags[i]
                                              if tag then
                                                  client.focus:move_to_tag(tag)
                                              end
                                          end
                                          bart_update()
                                      end,
                                      {description = "move focused client to tag #"..i, group = "tag"}),
                                  -- Toggle tag on focused client.
                                  awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                                      function ()
                                          if client.focus then
                                              local tag = client.focus.screen.tags[i]
                                              if tag then
                                                  client.focus:toggle_tag(tag)
                                              end
                                          end
                                          bart_update()
                                      end,
                                      {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false,
                     floating = false
      }
    },
    { rule = { name = 'cava' },
      properties = { floating = true, below = true, sticky = true, focusable = false, opacity = 0 },
      callback = function(c)
          c:geometry { width = 1920 / 3, height = 1080 / 3 }
          awful.placement.bottom_right(c)
      end
    },
    { rule = { name = 'pipes.sh' },
      properties = { floating = true, below = true, sticky = true, focusable = false, opacity = 0, geometry = { width = 1920 / 3, height = 1080 / 2 } },
      callback = function(c)
          c:geometry { width = 1920 / 3, height = 1080 / 2 }
          awful.placement.top_left(c)
      end
    },
    { rule = { name = 'pstree' },
      properties = { floating = true, below = true, sticky = true, focusable = false, opacity = 0, geometry = { width = 1920 / 3, height = 1080 / 2 } },
      callback = function(c)
          c:geometry { width = 1920 / 3, height = 1080 / 2 }
          awful.placement.bottom_left(c)
      end
    },
    { rule = { name = 'cmus' },
      properties = { floating = true, below = true, sticky = true, focusable = false, opacity = 0 },
      callback = function(c)
          c:geometry { width = 1920 / 3, height = 1080 / 3 }
          awful.placement.top_right(c)
      end
    },
    { rule = { name = 'neofetch' },
      properties = { floating = true, below = true, sticky = true, focusable = false, opacity = 0 },
      callback = function(c)
        c:geometry { width = 1920 / 3, height = 1080 / 3 }
        awful.placement.top_right(c, { offset = { y = 1080 / 3 } } )
      end
    }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
                          blur_wall()
                          -- Set the windows at the slave,
                          -- i.e. put it at the end of others instead of setting it master.
                          -- if not awesome.startup then awful.client.setslave(c) end

                          if awesome.startup and
                              not c.size_hints.user_position
                          and not c.size_hints.program_position then
                              -- Prevent clients from being unreachable after screen count changes.
                              awful.placement.no_offscreen(c)
                          end
                          bart_update()
                          c.border_width = beautiful.border_widthi
                          c.border_color = beautiful.border_color
                          if c.name == 'cava' or c.name == 'cmus' or c.name == 'neofetch' then
                              c.border_width = 0
                          end
                          if c.name == 'cmus' then
                              c.floating = true
                              c.below = true
                              c.sticky = true
                              c.focusable = false
                              c:geometry { width = 1920 / 3, height = 1080 / 3 }
                              awful.placement.top_right(c)
                          end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
                          -- buttons for the titlebar
                          local buttons = gears.table.join(
                              awful.button({ }, 1, function()
                                      client.focus = c
                                      c:raise()
                                      awful.mouse.client.move(c)
                              end),
                              awful.button({ }, 3, function()
                                      client.focus = c
                                      c:raise()
                                      awful.mouse.client.resize(c)
                              end)
                          )

                          awful.titlebar(c) : setup {
                              { -- Left
                                  awful.titlebar.widget.iconwidget(c),
                                  buttons = buttons,
                                  layout  = wibox.layout.fixed.horizontal
                              },
                              { -- Middle
                                  { -- Title
                                      align  = "center",
                                      widget = awful.titlebar.widget.titlewidget(c)
                                  },
                                  buttons = buttons,
                                  layout  = wibox.layout.flex.horizontal
                              },
                              { -- Right
                                  awful.titlebar.widget.floatingbutton (c),
                                  awful.titlebar.widget.maximizedbutton(c),
                                  awful.titlebar.widget.stickybutton   (c),
                                  awful.titlebar.widget.ontopbutton    (c),
                                  awful.titlebar.widget.closebutton    (c),
                                  layout = wibox.layout.fixed.horizontal()
                              },
                              layout = wibox.layout.align.horizontal
                                                    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
                          if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
                          and awful.client.focus.filter(c) then
                              client.focus = c
                          end
end)

client.connect_signal("focus", function(c)
                          c.border_color = beautiful.border_color
                          c.opacity = beautiful.focused_opacity
end)
client.connect_signal("unfocus", function(c)
                          c.border_color = '#000000'
                          c.opacity = beautiful.unfocused_opacity
end)

client.connect_signal('unmanage', function()
                          blur_wall()
                          bart_update()
end)

-- }}}

awful.spawn.with_shell('exec compton -b -c -f -r 16 -l -24 -t -25 -I 0.03 -o 0 -z')
awful.spawn.with_shell('xrdb -merge ~/.Xresources')
awful.spawn.with_shell('xset r rate 192 32')
bart_update()

local _ = 100
awful.screen.focused().padding = { top = _, bottom = _, left = _, right = _ }
reload_xterm()
efficient()
