---Returns all HitObjects within a certain temporal range.
---@param lower number
---@param upper number
---@return HitObjectInfo[]
function getNotesInRange(lower, upper)
    local base = map.HitObjects

    local tbl = {}

    for _, v in pairs(base) do
        if (v.StartTime >= lower) and (v.StartTime <= upper) then
            table.insert(tbl, v)
        end
    end

    return tbl
end
