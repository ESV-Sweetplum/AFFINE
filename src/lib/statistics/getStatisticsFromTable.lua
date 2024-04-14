---Gets statistical analysis of a numerical table.
---@param table number[]
---@return TableStats
function getStatisticsFromTable(table)
    local stdDev = getStdDev(table)

    local tbl = {
        mean = getMean(table),
        variance = stdDev ^ 2,
        stdDev = stdDev
    }

    return tbl
end