---Removes lines above or below the specified boundary. Then, adds an extra line at the nearest 1/1 snap to maintain snap coloring.
---@param lines TimingPointInfo[] # A table of lines to clean.
---@param lower number # Lower boundary of the constraint.
---@param upper number # Upper boundary of the constraint.
---@return TimingPointInfo[]
function cleanLines(lines, lower, upper)
    local lastLineTime = upper
    if (#lines > 0) and (lines[#lines].StartTime > upper) then
        lastLineTime = lines[#lines].StartTime
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
