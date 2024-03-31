function keepColorLine(time, hidden)
    color = colorFromTime(time)
    return applyColorToTime(color, time, hidden or false)
end
