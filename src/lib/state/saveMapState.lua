function saveMapState(table)
    if (map.Bookmarks[1]) then
        if (map.Bookmarks[1].note:find("DATA: ")) then
            actions.RemoveBookmark(map.Bookmarks[1])
        end
    end
    bookmark(-69420, "DATA: " .. tableToStr(table))
end
