---Returns all bookmarks within a temporal boundary.
---@param lower number # Lower bound of the constraint.
---@param upper number # Upper bound of the constraint.
---@return BookmarkInfo[]
function getBookmarksInRange(lower, upper)
    local base = map.Bookmarks

    local tbl = {}

    for _, v in pairs(base) do
        if (v.StartTime >= lower) and (v.StartTime <= upper) then
            table.insert(tbl, v)
        end
    end

    return tbl
end
