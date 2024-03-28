function cleanLines(lines, lower, upper)
    local lastLineTime = lines[#lines].StartTime

    local tbl = {}

    for _, currentLine in pairs(lines) do
        if (currentLine.StartTime >= lower and currentLine.StartTime <= upper) then
            table.insert(tbl, currentLine)
        end
    end

    table.insert(tbl, line(map.GetNearestSnapTimeFromTime(true, 1, lastLineTime) - 2))
    table.insert(tbl, line(map.GetNearestSnapTimeFromTime(true, 1, lastLineTime)))

    return tbl
end
