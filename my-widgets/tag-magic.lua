local awful = require('awful')

tag_idx = 0

function delete_tag()
    local t = awful.screen.focused().selected_tag
    if not t then return end
    t:delete()
end

function add_tag()
    tag_idx = tag_idx + 1
    awful.tag.add(tostring(tag_idx),{screen=awful.screen.focused() }):view_only()
end
