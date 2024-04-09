---Simplifies the workflow to find and maintain snap colors.
---@param time number
---@param hidden boolean
---@return TimingPointInfo[]
function keepColorLine(time, hidden)
    color = colorFromTime(time)
    return applyColorToTime(color, time, hidden or false)
end
