---When given a progression value (0-1), returns the numerical distance along the progress line.
---@param starting number
---@param progress number
---@param ending number
---@return number
function mapProgress(starting, progress, ending)
    return progress * (ending - starting) + starting
end
