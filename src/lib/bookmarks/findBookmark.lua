---Finds closest bookmark with `StartTime` less than `time`. If the bookmark isn't within the constraint defined by `[lower, upper]`, then no bookmark is returned.
---@param time number # The time in which to locate the nearest bookmark before this.
---@param lower number # Lower bound of the constraint.
---@param upper number # Upper bound of the constraint.
---@return BookmarkInfo
function findBookmark(time, lower, upper)
    lower = lower or 0
    upper = upper or 1e69
    local bookmarks = map.Bookmarks

    if (#bookmarks == 0) then return {} end
    if (#bookmarks == 1) then return bookmarks[1] end

    for i = 1, #bookmarks do
        if bookmarks[i].StartTime > time then
            if (bookmarks[i].StartTime < lower or bookmarks[i].StartTime > upper) then return {} end
            return bookmarks[i - 1]
        end
    end
    if (bookmarks[#bookmarks].StartTime < lower or bookmarks[#bookmarks].StartTime > upper) then return {} end
    return bookmarks[#bookmarks]
end
