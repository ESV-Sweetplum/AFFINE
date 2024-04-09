---Gets the percentage from the starting value.
---@param starting number
---@param value number
---@param ending number
---@return number
function getProgress(starting, value, ending)
    return (value - starting) / (ending - starting)
end
