---Returns all ScrollVelocities within a certain temporal range.
---@param lower number
---@param upper number
---@return SliderVelocityInfo[]
function getSVsInRange(lower, upper)
    local base = map.ScrollVelocities

    local tbl = {}

    for _, v in pairs(base) do
        if (v.StartTime >= lower) and (v.StartTime <= upper) then
            table.insert(tbl, v)
        end
    end

    return tbl
end
