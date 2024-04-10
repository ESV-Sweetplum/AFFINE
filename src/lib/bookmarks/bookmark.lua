---@diagnostic disable: return-type-mismatch
--- Creates a Bookmark. To place it, you must use an `action`.
---@param time integer
---@param note string
---@return BookmarkInfo
function bookmark(time, note)
    return utils.CreateBookmark(time, note)
end
