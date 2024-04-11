function getMapState(default)
    default = default or {}
    if (not map.Bookmarks[1]) then return default end
    if (not string.find(map.Bookmarks[1].note, "DATA: ")) then return default end

    local str = map.Bookmarks[1].note:sub(7, map.Bookmarks[1].note:len())

    return strToTable(str)
end
