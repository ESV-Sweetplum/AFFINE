---Gets the statistical standard deviation from a numerical table.
---@param table number[]
---@return number
function getStdDev(table)
    local mean = getMean(table)
    local variance = getVariance(table, mean)
    return variance ^ 0.5
end
