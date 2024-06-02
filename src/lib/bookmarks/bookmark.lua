---@diagnostic disable: return-type-mismatch
--- Creates a Bookmark. To place it, you must use an `action`.
---@param time integer # The time of the bookmark.
---@param note string # The contents of the bookmark.
---@return BookmarkInfo
function bookmark(time, note)
    return utils.CreateBookmark(time, note)
end
