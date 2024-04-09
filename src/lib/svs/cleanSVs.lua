---Removes SVs outside of range, places 0.00x SV at the beginning, and places a 1.00x SV at the end.
---@param svs SliderVelocityInfo[]
---@param lower number
---@param upper number
---@return SliderVelocityInfo[]
function cleanSVs(svs, lower, upper)
    local tbl = {}

    for _, currentSV in pairs(svs) do
        if (currentSV.StartTime >= lower and currentSV.StartTime <= upper) then
            table.insert(tbl, currentSV)
        end
    end

    table.insert(tbl, sv(lower, 0))
    table.insert(tbl, sv(upper + 1, 1))

    return tbl
end
