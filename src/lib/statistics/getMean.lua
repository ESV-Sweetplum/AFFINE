---Gets the statistical mean of a numerical table.
---@param table number[] # The dataset to operate on.
---@return number
function getMean(table)
    local sum = 0

    for _, v in pairs(table) do
        sum = sum + v
    end

    return sum / #table
end
