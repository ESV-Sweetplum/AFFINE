---When given a progression value in [0,1], returns the numerical distance along the progress line.
---@param starting number # The start of the progression bar.
---@param progress number # The progress of the value.
---@param ending number # The end of the progression bar.
---@return number
function mapProgress(starting, progress, ending)
    return progress * (ending - starting) + starting
end
