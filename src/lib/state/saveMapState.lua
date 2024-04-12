function saveMapState(table)
    if (map.Bookmarks[1]) then
        if (map.Bookmarks[1].note:find("DATA: ")) then
            actions.RemoveBookmark(map.Bookmarks[1])
        end
    end
    local bm = bookmark(-69420, "DATA: " .. tableToStr(table))
    actions.AddBookmarkBatch({ bm })
end
