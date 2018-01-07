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
local cairo = require("lgi").cairo

icondir = '/home/void/stuff/awesome/icons/'
titlebars_enabled = false
efficiency = false
artemis_visible = true

-- Extra widgets
--require("my-widgets.arcs")
--require("my-widgets.tag-magic")
--require("my-widgets.dock")
--require("my-widgets.spawner")
--require("my-widgets.artemis")
require("my-widgets.bart")
--require("my-widgets.rache")
--require("my-widgets.tools")
--local rache = require('my-widgets.rache')

-- Load Debian menu entries
--require("debian.menu")

-- create a window hiding menu with rache
--[[
rache.add({ name = 'tasklist', width = 200, height = 120, x = 1920 / 2 - 200, y = 1080 / 2 - 60 }, function(name)
    for _, c in ipairs(awful.screen.focused().selected_tag:clients()) do
        if c.name == name then
            c.minimized = not c.minimized
        end
    end
    rache.toggle('tasklist')
end)
]]

-- smart borders
local setSmartBorders = function(c, firstRender)
    if not titlebars_enabled then
        awful.titlebar(c, {
            size = 0,
            position = 'top'
        })
        awful.titlebar(c, {
            size = 0,
            position = 'left'
        })
        awful.titlebar(c, {
            size = 0,
            position = 'right'
        })
        awful.titlebar(c, {
            size = 0,
            position = 'bottom'
        })
        return
    end

    local border_width = 24
    local total_width = c.width
    local total_height = c.height
    local line_thickness = 1
    local padding = 12
    local tri = 16

    local text_color = xterm.white
    local text_bg = '#222222'
    local line_color = '#ffffffbb'
    local bg = gears.color('#00000000')

    local border_dir = '/home/nicky/stuff/awesome/borders/'

    local function hexagon(cr, center_x, width)
        cr:set_source(gears.color(text_bg))
        cr:rectangle(center_x - width / 2 - padding, 0, width + 2 * padding, border_width)
        cr:fill()

        cr:move_to(center_x - width / 2 - padding + 1, 0)
        cr:line_to(center_x - width / 2 - padding - tri, border_width / 2)
        cr:line_to(center_x - width / 2 - padding + 1, border_width)
        cr:close_path()
        cr:fill()

        cr:move_to(center_x + width / 2 + padding - 1, 0)
        cr:line_to(center_x + width / 2 + padding + tri, border_width / 2)
        cr:line_to(center_x + width / 2 + padding - 1, border_width)
        cr:close_path()
        cr:fill()

        cr:set_source(gears.color(line_color))
        cr:move_to(center_x - width / 2 - padding, 0)
        cr:line_to(center_x - width / 2 - padding - tri, border_width / 2)
        cr:line_to(center_x - width / 2 - padding, border_width)
        cr:line_to(center_x + width / 2 + padding, border_width)
        cr:line_to(center_x + width / 2 + padding + tri, border_width / 2)
        cr:line_to(center_x + width / 2 + padding, 0)
        cr:close_path()
        cr:stroke()
    end

    local function draw_text(cr, text, center_x)
        -- for now, assumes a top titlebar
        -- we need to know how long the title is to set the size of the rect
        local width = cr:text_extents(text).width
        hexagon(cr, center_x, width)

        cr:set_source(gears.color(text_color))
        cr:move_to(center_x - width / 2, border_width * 0.75)
        cr:show_text(text)
    end

    -- for some reasons, the client height/width are not the same at first
    -- render (when called by request title bar) and when resizing
    if firstRender then
      total_width = total_width + border_width
    else
      total_height = total_height - border_width
    end

    -- Create surfaces --
    local imgTop = cairo.ImageSurface.create(cairo.Format.ARGB32, total_width, border_width)
    local crTop  = cairo.Context(imgTop)
    local imgLeft = cairo.ImageSurface.create(cairo.Format.ARGB32, padding * 2, total_height)
    local crLeft  = cairo.Context(imgLeft)
    local imgRight = cairo.ImageSurface.create(cairo.Format.ARGB32, padding * 2, total_height)
    local crRight  = cairo.Context(imgRight)
    local imgBot = cairo.ImageSurface.create(cairo.Format.ARGB32, total_width, padding * 2)
    local crBot  = cairo.Context(imgBot)

    crTop:set_source(bg)
    crBot:set_source(bg)
    crLeft:set_source(bg)
    crRight:set_source(bg)
    crTop:rectangle(0, 0, total_width, border_width)
    crBot:rectangle(0, 0, total_width, border_width)
    crLeft:rectangle(0, 0, border_width, total_height)
    crRight:rectangle(0, 0, border_width, total_height)
    crTop:fill()
    crBot:fill()
    crLeft:fill()
    crRight:fill()

    crBot:set_source(gears.color(line_color))
    crBot:set_line_width(line_thickness)
    crLeft:set_source(gears.color(line_color))
    crLeft:set_line_width(line_thickness)

    crTop:select_font_face('Monaco')
    crTop:set_font_size(12)

    -- fancy border top: top left
    local img = cairo.ImageSurface.create_from_png(border_dir .. 'top_left.png')
    crTop:set_source_surface(img)
    crTop:rectangle(0, 0, 102, border_width)
    crTop:fill()

    -- top: top right (img is 102 pixels wide)
    local img = cairo.ImageSurface.create_from_png(border_dir .. 'top_right.png')
    crTop:set_source_surface(img, total_width - 102, 0)
    crTop:rectangle(total_width - 102, 0, 102, border_width)
    crTop:fill()

    -- fancy border bottom: bottm left
    local img = cairo.ImageSurface.create_from_png(border_dir .. 'bottom_left.png')
    crBot:set_source_surface(img)
    crBot:rectangle(0, 0, 102, border_width)
    crBot:fill()

    -- bottom: top bottom (img is 102 pixels wide)
    local img = cairo.ImageSurface.create_from_png(border_dir .. 'bottom_right.png')
    crBot:set_source_surface(img, total_width - 102, 0)
    crBot:rectangle(total_width - 102, 0, 102, border_width)
    crBot:fill()

    -- fancy border left: top left
    local img = cairo.ImageSurface.create_from_png(border_dir .. 'left_top_left.png')
    crLeft:set_source_surface(img, 0, 0)
    crLeft:rectangle(0, 0, border_width, 102)
    crLeft:fill()

    -- fancy border left: bottom left. here the height is 53
    local img = cairo.ImageSurface.create_from_png(border_dir .. 'left_bottom_left.png')
    crLeft:set_source_surface(img, 0, total_height - border_width - 53)
    crLeft:rectangle(0, total_height - border_width - 53, border_width, 53)
    crLeft:fill()


    -- top line
    crTop:set_source(gears.color(line_color))
    crTop:set_line_width(line_thickness)

    crTop:move_to(90, border_width / 2)
    crTop:line_to(total_width - 90, border_width / 2)
    crTop:stroke()

    -- bottom line
    crBot:set_source(gears.color(line_color))
    crBot:set_line_width(line_thickness)

    crBot:move_to(90, border_width / 2)
    crBot:line_to(total_width - 90, border_width / 2)
    crBot:stroke()

    -- right line
    crRight:set_source(gears.color(line_color))
    crRight:set_line_width(line_thickness)

    crRight:move_to(border_width / 2 + 2, 50)
    crRight:line_to(border_width / 2 + 2, total_height - 70)
    crRight:stroke()

    -- left line
    crLeft:set_source(gears.color(line_color))
    crLeft:set_line_width(line_thickness)

    crLeft:move_to(border_width / 2 - 3, 53)
    crLeft:line_to(border_width / 2 - 3, total_height - 70)
    crLeft:stroke()

    -- bottom hexagon
    hexagon(crBot, total_width / 2, border_width * 6)     -- * 6 b/c 6 icons

    -- fancy border right: top right
    local img = cairo.ImageSurface.create_from_png(border_dir .. 'right_top_right.png')
    crRight:set_source_surface(img, 0, 0)
    crRight:rectangle(0, 0, border_width, 102)
    crRight:fill()

    -- fancy border right: bottom right here the height is 53
    local img = cairo.ImageSurface.create_from_png(border_dir .. 'right_bottom_right.png')
    crRight:set_source_surface(img, 0, total_height - border_width - 53)
    crRight:rectangle(0, total_height - border_width - 53, border_width, 53)
    crRight:fill()

    -- info --
    -- current tags
    local tags = awful.screen.focused().selected_tags
    local txt = ''
    for _, t in ipairs(tags) do
        if txt == '' then
            txt = t.name
        else
            txt = txt .. ' ' .. t.name
            end
    end

    draw_text(crTop, tostring(c.name) .. ' | ' .. tostring(c.instance) .. ' | ' .. tostring(txt), total_width / 2)

    awful.titlebar(c, {
      size = border_width,
      position = "top",
      bg_normal = "transparent",
      bg_focus = "transparent",
      bgimage_focus = imgTop,
      }) : setup { layout = wibox.layout.stack }

    awful.titlebar(c, {
      size = padding * 2,
      position = "left",
      bg_normal = "transparent",
      bg_focus = "transparent",
      bgimage_focus = imgLeft,
    }) : setup { layout = wibox.layout.align.horizontal, }

    awful.titlebar(c, {
      size = padding * 2,
      position = "right",
      bg_normal = "transparent",
      bg_focus = "transparent",
      bgimage_focus = imgRight,
    }) : setup { layout = wibox.layout.align.horizontal, }

    awful.titlebar(c, {
      size = padding * 2,
      position = "bottom",
      bg_normal = "transparent",
      bg_focus = "transparent",
      bgimage_focus = imgBot,
      }) : setup {
          wibox.widget {
              { -- we need a manual layout because flex doesn't quite center it correctly
                  buttons = buttons,
                  awful.titlebar.widget.floatingbutton (c),
                  awful.titlebar.widget.maximizedbutton(c),
                  awful.titlebar.widget.stickybutton   (c),
                  awful.titlebar.widget.ontopbutton    (c),
                  awful.titlebar.widget.closebutton    (c),
                  awful.widget.layoutbox(),
                  layout  = wibox.layout.fixed.horizontal,
                  point = { x = total_width / 2 - 24 * 3, y = 0 }
              },
              layout = wibox.layout.manual
          },
          layout = wibox.layout.stack
      }
end
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
beautiful.init("/home/nicky/.config/awesome/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
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
                                    --{ "Debian", debian.menu.Debian_menu.Debian },
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
mytextclock = wibox.widget.textclock("%H:%M")

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
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

local tasklist_buttons = awful.util.table.join(
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

function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.fit(wallpaper, s)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    local l = awful.layout.suit  -- Just to save some typing: use an alias.

    awful.tag.add('term', {
        icon = icondir .. 'term.png',
        layout = l.tile,
        screen = s,
        selected = true
    })

    awful.tag.add('www', {
        icon = icondir .. 'www.png',
        layout = l.tile,
        screen = s,
    })

    awful.tag.add('top', {
        icon = icondir .. 'top.png',
        layout = l.tile,
        screen = s,
    })

    awful.tag.add('gimp', {
        icon = icondir .. 'gimp.png',
        layout = l.tile,
        screen = s,
    })

    awful.tag.add('music', {
        icon = icondir .. 'music.png',
        layout = l.tile,
        screen = s,
    })

    awful.tag.add('blend', {
        icon = icondir .. 'blend.png',
        layout = l.tile,
        screen = s,
    })

    awful.tag.add('rc', {
        icon = icondir .. 'rc.png',
        layout = l.tile,
        screen = s,
    })

    awful.tag.add('arc', {
        icon = icondir .. 'arc.png',
        layout = l.tile,
        screen = s,
    })

    awful.tag.add('9', {
        icon = icondir .. '9.png',
        layout = l.tile,
        screen = s,
    })

    local mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    --awful.screen.padding(screen[s], { top = 100, left = 100, right = 100, bottom = 100 })
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

function spawn_tools()
    awful.spawn('urxvt -name cmus -e cmus')
    awful.spawn('blender')
    awful.spawn('gimp')
    awful.spawn('vivaldi')
end
local step = 0.05
-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- mine! :D
    --[[
    awful.key({ modkey }, 'space', function()
        local clients = awful.screen.focused().selected_tag:clients()
        local names = { }
        for _, client in ipairs(clients) do
            table.insert(names, client.name)
        end
        rache.set_items('tasklist', names)
        rache.toggle('tasklist')
    end,
              {description = "spawner", group = "idk"}),
      ]]
    awful.key({ modkey }, ',', function()
        theme.focused_opacity = theme.focused_opacity - step
        theme.unfocused_opacity = theme.focused_opacity - step - theme.focus_diff
        if theme.focused_opacity < 0 then theme.focused_opacity = 0 end
        if theme.unfocused_opacity < 0 then theme.unfocused_opacity = 0 end
        for _, c in ipairs(client.get()) do
            if client.focus == c then
                c.opacity = theme.focused_opacity
            else
                c.opacity = theme.unfocused_opacity
            end
        end
    end,
              {description = "lower opacity", group = "idk"}),

    awful.key({ modkey }, '.', function()
        theme.focused_opacity = theme.focused_opacity + step
        theme.unfocused_opacity = theme.focused_opacity + step - theme.focus_diff
        if theme.focused_opacity > 1 then theme.focused_opacity = 1 end
        if theme.unfocused_opacity > 1 then theme.unfocused_opacity = 1 end
        for _, c in ipairs(client.get()) do
            if client.focus == c then
                c.opacity = theme.focused_opacity
            else
                c.opacity = theme.unfocused_opacity
            end
        end
    end,
              {description = "increase opacity", group = "idk"}),

    awful.key({ modkey }, 'x', function() spawner() end,
              {description = "spawner", group = "idk"}),

    awful.key({ modkey, 'Shift' }, 'f', function()
        if client.focus.opacity > 0 then client.focus.opacity = 0
        else client.focus.opacity = beautiful.focused_opacity end
    end,
              {description = "focused -> transparent", group = "idk"}),

    awful.key({ modkey }, 'c', function()
        local clients = awful.screen.focused().selected_tag:clients()
        local s = ''
        for _, c in ipairs(clients) do
            s = c.name .. '\n' .. s
        end

        awful.spawn.easy_async_with_shell('echo "' .. s .. '" | rofi -dmenu', function(stdout)
            for _, c in ipairs(client.get()) do
                if c.name == stdout then
                    c.minimized = false
                end
            end
        end)
    end,
              {description = "tasklist", group = "idk"}),

    awful.key({ modkey }, 'p', function()
        client.focus.floating = not client.focus.floating end,
              {description='pop window', group="idk"}),

    awful.key({ modkey,           }, "m", function() awful.spawn('music-remote') end,
              {description="music remote", group="idk"}),

    awful.key({ modkey, 'Shift' }, 'space', layoutswitcher,
              {description = "switch layouts", group = "idk"}),

    awful.key({ modkey }, 't', function()
                  awful.spawn('urxvt -name popup')
              end,
              {description = "drop-down terminal", group = "idk"}),

    awful.key({ modkey, 'Shift' }, 't', function()
                  titlebars_enabled = not titlebars_enabled
                  for _, c in ipairs(client.get()) do
                      setSmartBorders(c)
                  end
              end,
              {description = "toggle titlebars", group = "idk"}),

    -- Not mine! :P

    awful.key({ modkey,           }, "Left",   function()
        awful.tag.viewprev()
        --bart_update()
    end,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  function()
        awful.tag.viewnext()
        --bart_update()
    end,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", function()
        awful.tag.history.restore()
        --bart_update()
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
    awful.key({ modkey,           }, "Return", function () awful.spawn('urxvt') end,
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
    --[[
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),
    ]]

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
    awful.key({ modkey },            "r",     function () awful.spawn.with_shell('menu') end,
              {description = "run prompt", group = "launcher"}),

    --[[
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    ]]
    -- Menubar
    --[[
    awful.key({ modkey, 'Shift' }, ',', function() mywibar.visible = false end,
              {description = "hide sidebar", group = "launcher"}),
    awful.key({ modkey, 'Shift' }, '.', function() mywibar.visible = true end,
              {description = "show sidebar", group = "launcher"}),
    ]]
    awful.key({ modkey }, 'a', add_tag,  
              {description = "add tag", group = "tag"}),
    awful.key({ modkey, 'Shift' }, 'a', delete_tag,  
              {description = "delete tag", group = "tag"})
)

clientkeys = awful.util.table.join(
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
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                        --bart_update()
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
                      --bart_update()
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
                      --bart_update()
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = awful.util.table.join(
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
      properties = { focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false,
     }
    },
    --[[
    { rule = { instance = "cairo-dock" },
      type = "dock",
      properties = {
                floating = true,
                ontop = true, 
                focus = true,
      } 
    },
    ]]
    --[[
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },
    ]]

    { rule_any = {class = { 'Vivaldi-stable' }
      }, properties = { tag = 'www' }
    },

    { rule_any = {instance = { 'megasync' }
      }, properties = { tag = 'arc' }
    },

    { rule = { instance = 'popup' },
      properties = { floating = true, ontop = true, sticky = true, width = 1920, height = 320 }
    },

    { rule = { instance = "cmus" },
        properties = { tag = 'music' } },

    { rule = { instance = "top" },
        properties = { tag = 'top' } },

    -- Gimp to the gimp tag
    { rule = { instance = "gimp" },
      properties = { screen = 1, tag = "gimp" } }, 

    -- RB to music
    { rule = { class = "Rhythmbox" },
      properties = { screen = 1, tag = "music" } }, 

    -- Blender to blender
    { rule = { class = "Blender" },
      properties = { screen = 1, tag = "blend" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    c.opacity = beautiful.focused_opacity
    c.borders_enabled = false
    c.border_width = beautiful.border_width
    --c.border_color = beautiful.border_color

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
    --bart_update()
    --[[
    c.shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 16)
        --gears.shape.hexagon(cr, w, h)
    end
    ]]
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
--[[
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
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
            layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.layout.align.horizontal
    }
    awful.titlebar.hide(c)
end)
]]
client.connect_signal("request::titlebars", function(c) setSmartBorders(c, true) end)
client.connect_signal("property::size", setSmartBorders)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c)
    c.opacity = beautiful.focused_opacity
    setSmartBorders(c, false)
end)
client.connect_signal("unfocus", function(c)
    c.opacity = beautiful.unfocused_opacity
end)
client.connect_signal("unmanage", function(c)
    --bart_update()
end)

--update_tag()
--reload_xterm()
--awful.spawn.with_shell('exec compton -b -c -f -r 16 -l -24 -t -25 -I 0.03 -o 1 -z')
--awful.spawn.with_shell('xrdb /home/nicky/.Xresources')
--awful.spawn('fixbt')
--awful.spawn('megasync')

--efficient()
--bart_update()
