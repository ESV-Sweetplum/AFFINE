---Gets the percentage from the starting value.
---@param starting number
---@param value number
---@param ending number
---@param progressionExponent? number
---@return number
function getProgress(starting, value, ending, progressionExponent)
    local progressionExponent = progressionExponent or 1
    local baseProgress = (value - starting) / (ending - starting)
    if (progressionExponent >= 1) then
        return baseProgress ^ progressionExponent
    else
        return 1 - (1 - baseProgress) ^ (1 / progressionExponent)
    end
end
