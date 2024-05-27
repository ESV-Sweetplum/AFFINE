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
        return clamp(baseProgress ^ progressionExponent, 0, 1)
    else
        return clamp(1 - (1 - baseProgress) ^ (1 / progressionExponent), 0, 1)
    end
end

function clamp(value, min, max)
    return math.max(math.min(value, max), min)
end
