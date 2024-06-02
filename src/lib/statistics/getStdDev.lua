---Gets the statistical standard deviation from a numerical table.
---@param table number[] # The dataset to operate on.
---@return number
function getStdDev(table)
    local mean = getMean(table)
    local variance = getVariance(table, mean)
    return variance ^ 0.5
end
