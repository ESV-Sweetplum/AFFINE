---Gets the statistical variance
---@param table number[]
---@param mean? number
---@return number
function getVariance(table, mean)
    if (not mean) then mean = getMean(table) end

    local sum = 0
    for _, v in pairs(table) do
        sum = sum + (v - mean) ^ 2
    end

    return sum / (#table - 1)
end
