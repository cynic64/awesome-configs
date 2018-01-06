local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local naughty = require('naughty')
local watch = require('awful.widget.watch')
local gears = require('gears')
local cairo = require('lgi').cairo
require('my-widgets.tools')

local bg_color = '#222222cc'
local line_color = '#ffffffbb'
local text_color = '#ffffff'
local font_face = 'Liberation Mono for Powerline'
local font_size = 16
local v_gap = 30
local v_start = 30

local rache = { }

local menus = { }

function rache.add(args, callback)
    --[[
        args must have:
        name
        items
        width
        height
        x
        y
    ]]
    local menu = wibox { width = args.width, height = args.height, visible = false, bg = bg_color, ontop = true }

    menu.items = { }
    menu.show_items = { }
    menu.filter = ''
    menu.grabbing = false

    -- position it
    local layout = (awful.placement.top_left)
    layout(menu, { offset = { x = args.x, y = args.y } } )

    -- create a blank cairobox
    menu.widget = wibox.widget {
        {
            -- cairo surface
            widget = wibox.widget.imagebox
        },
        layout = wibox.layout.stack
    }

    -- set indexes
    menu.current_idx = 1
    menu.last_idx = 1
    menu.start_idx = 1

    -- set callback
    menu.callback = callback

    -- connect signals
    menu:connect_signal('mouse::move', function() rache.get_index(args.name) end)
    menu:connect_signal('button::press', function()
                            callback(menu.shown_items[menu.current_idx])
    end)
    menu:connect_signal('mouse::leave', function() rache.toggle(args.name) end)

    menus[args.name] = menu
end

function rache.set_items(name, items)
    menus[name].items = items
    rache.filter(name)
end

function rache.toggle(name)
    m = menus[name]

    m.visible = not m.visible
    if m.visible then
        rache.draw(name)
        grabbing = true
        keygrabber.run(function(mod, key, event)
                if event == 'release' then return end

                if #key == 1 then
                    m.filter = m.filter .. key
                elseif key == 'BackSpace' then
                    if #m.filter > 1 then
                        m.filter = m.filter:match('(.+).')
                    elseif #m.filter == 1 then
                        m.filter = ''
                    end
                elseif key == 'Escape' then
                    keygrabber.stop()
                    grabbing = false
                elseif key == 'Down' then
                    m.start_idx = m.start_idx + 1
                    if m.start_idx > #m.shown_items then
                        m.start_idx = #m.show_items
                    end
                elseif key == 'Up' then
                    m.start_idx = m.start_idx - 1
                    if m.start_idx < 1 then
                        m.start_idx = 1
                    end
                end

                rache.draw(name)
        end)
    else
        if grabbing then
            keygrabber.stop()
        end
    end
end

function rache.filter(name)
    local m = menus[name]
    local new = { }

    -- filter
    for _, item in ipairs(m.items) do
        if item:lower():find(m.filter) then
            table.insert(new, item)
        end
    end

    -- scroll
    local max_items = math.floor(m.height / v_gap)
    local old_new = new
    local new = { }
    for i = m.start_idx, m.start_idx + max_items - 2 do
        table.insert(new, old_new[i])
    end

    -- add 'Filter: ' line
    table.insert(new, 1, 'Filter: ' .. m.filter)
    m.shown_items = new
end

function rache.draw(name)
    rache.filter(name)
    local m = menus[name]

    -- create a cairo context
    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, m.width, m.height)
    local cr = cairo.Context(img)

    -- set font
    cr:select_font_face(font_face)
    cr:set_font_size(font_size)

    -- draw items
    local x, y = m.width / 2, v_start
    for i, item in ipairs(m.shown_items) do
        -- highlight selected
        if i == m.current_idx then
            cr:set_source(gears.color(xterm.red))
            cr:rectangle(x - m.width / 2, y - v_gap, m.width, v_gap)
            cr:fill()
        end

        center_text(cr, x, y, item)

        y = y + v_gap
    end

    m.widget.children[1].image = img
end

function rache.get_index(name)
    -- sets menu index based on mouse position
    m = menus[name]

    _ = mouse.coords()
    local x, y = _.x, _.y
    -- correct for menu's position
    x, y = x - m.x, y - m.y

    local px, py = m.width / 2, v_start
    for i=1,#m.items do
        -- generate rect
        local rect = { px - m.width / 2, py - v_gap, m.width, v_gap }
        if is_in_rect(x, y, rect) then
            m.current_idx = i
            break
        end

        py = py + v_gap
    end

    if m.current_idx ~= m.last_idx then
        rache.draw(name)
        m.last_idx = m.current_idx
    end
end
return rache
