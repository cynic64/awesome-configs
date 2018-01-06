local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local naughty = require('naughty')
local watch = require('awful.widget.watch')
local gears = require('gears')
local cairo = require('lgi').cairo

home = os.getenv('HOME') .. '/'
function log(text)
    local f = io.open(home .. 'stuff/awesome/log.txt', 'a')
    --f = io.open('/dev/null', 'a')
    io.output(f)
    io.write(text .. '\n')
    io.close(f)
end

function diagonal(x, y, angle, length)
    local angle = math.rad(angle)
    local xm, ym = math.cos(angle), math.sin(angle)

    return { x + xm * length, y + ym * length }
end

function center_text(cr, x, y, text)
    cr:set_source(gears.color('#ffffff'))
    local _ = cr:text_extents(text)
    local width, height = _.width, _.height
    cr:move_to(x - width / 2, y - height / 2)
    cr:show_text(text)
    cr:stroke()
end

function is_in_rect(x, y, rect)
    if x > rect[1] and x < rect[1] + rect[3] and y > rect[2] and y < rect[2] + rect[4] then
        return true
    end
    return false
end

