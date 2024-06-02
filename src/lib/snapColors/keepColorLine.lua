---Simplifies the workflow to find and maintain snap colors.
---@param time number # The time to apply the color maintaining to.
---@param hidden? boolean # Determines if the timing lines generated will be visible during gameplay.
---@return TimingPointInfo[]
function keepColorLine(time, hidden)
    color = colorFromTime(time)
    return applyColorToTime(color, time, hidden or false)
end
