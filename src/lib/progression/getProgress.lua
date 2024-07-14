---Gets the progress from the starting value, to the ending value. Returns a number in [0,1] assuming `starting` < `value` < `ending`.
---@param starting number # The start of the progression bar.
---@param value number # The current value within the progression bar.
---@param ending number # The end of the progression bar.
---@param progressionExponent? number # Determines then movement within the progression bar.
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

---Restricts a value between two numbers.
---@param value number # The value to restrict.
---@param min number # The minimum the value must be.
---@param max number # The maximum the value must be.
---@return number
function clamp(value, min, max)
    if (value > max) then return max end
    if (value < min) then return min end
    return value
end
