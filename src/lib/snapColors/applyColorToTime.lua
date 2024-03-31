function applyColorToTime(color, time, hidden)
    local lines = {}

    ---@diagnostic disable-next-line: undefined-field
    local bpm = map.GetTimingPointAt(time).Bpm

    local timingDist = 4

    if (color == 1) then
        table.insert(lines, line(time, bpm, hidden))
    else
        table.insert(lines, line(time - timingDist / 2, 60000 / (timingDist * color / 2), hidden))
        table.insert(lines, line(time + timingDist / 2, bpm, hidden))
    end

    return lines
end
