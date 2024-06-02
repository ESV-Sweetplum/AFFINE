---Returns all timing points within a temporal boundary.
---@param lower number # Lower bound of the constraint.
---@param upper number # Upper bound of the constraint.
---@return TimingPointInfo[]
function getLinesInRange(lower, upper)
    local base = map.TimingPoints

    local tbl = {}

    for _, v in pairs(base) do
        if (v.StartTime >= lower) and (v.StartTime <= upper) then
            table.insert(tbl, v)
        end
    end

    return tbl
end
