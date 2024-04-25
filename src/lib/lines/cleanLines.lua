---Removes lines above or below the specified boundary. Then, adds an extra line at the nearest 1/1 snap to maintain snap coloring.
---@param lines TimingPointInfo[]
---@param lower number
---@param upper number
---@return TimingPointInfo[]
function cleanLines(lines, lower, upper)
    local lastLineTime = upper
    if (#lines > 0) then
        lastLineTime = math.max(lines[#lines].StartTime, upper)
    end

    local tbl = {}

    local lineDictionary = {}

    for _, currentLine in pairs(lines) do
        if (table.contains(lineDictionary, currentLine.StartTime)) then goto continue end
        if (currentLine.StartTime >= lower and currentLine.StartTime <= upper) then
            table.insert(tbl, currentLine)
            table.insert(lineDictionary, currentLine.StartTime)
        end
        ::continue::
    end

    table.insert(tbl, line(map.GetNearestSnapTimeFromTime(true, 1, lastLineTime) - 2))
    table.insert(tbl, line(map.GetNearestSnapTimeFromTime(true, 1, lastLineTime)))

    return tbl
end
