function saveMapState(table, place)
    if (map.Bookmarks[1]) then
        if (map.Bookmarks[1].note:find("DATA: ")) and (map.Bookmarks[1].StartTime == -69420) then
            actions.RemoveBookmark(map.Bookmarks[1])
        end
    end
    local bm = bookmark(-69420, "DATA: " .. tableToStr(table))
    if (place == false) then return bm end
    actions.AddBookmarkBatch({ bm })
    return bm
end
