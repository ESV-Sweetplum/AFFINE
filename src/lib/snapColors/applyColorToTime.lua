---Takes a color and a time, and returns timing lines that make that time that color.
---@param color number # The snap value of the color, in `1/color`. 1 represents red, 2 represents blue, etc.
---@param time number # The time to apply this coloring to.
---@param hidden boolean # Determines if the timing lines generated will be hidden during gameplay.
---@return TimingPointInfo[]
function applyColorToTime(color, time, hidden)
    local EPSILON = 0.3

    local lines = {}

    ---@diagnostic disable-next-line: undefined-field
    local bpm = map.GetTimingPointAt(time).Bpm

    local timingDist = 4

    if (math.abs(color - 1) <= EPSILON) then
        table.insert(lines, line(time, bpm, hidden))
    else
        table.insert(lines, line(time - timingDist / 2, 60000 / (timingDist * color / 2), hidden))
        table.insert(lines, line(time + timingDist / 2, bpm, hidden))
    end

    return lines
end
