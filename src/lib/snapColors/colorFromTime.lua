---Gets the snap color from a given time.
---@param time number
---@return number
function colorFromTime(time)
    local timingPoint = map.GetTimingPointAt(time)
    if (not timingPoint) then return 1 end
    barToBarDistance = (60000 / timingPoint.Bpm) or 69
    local timeAboveBar = (time - timingPoint.StartTime) % barToBarDistance

    if (timeAboveBar < barToBarDistance / 17) then return 1 end
    if ((barToBarDistance - (time - timingPoint.StartTime)) % barToBarDistance < barToBarDistance / 17) then return 1 end

    if (timeAboveBar > (barToBarDistance / 2)) then
        approximateSnap = barToBarDistance / ((barToBarDistance - (time - timingPoint.StartTime)) % barToBarDistance)
    else
        approximateSnap = barToBarDistance / timeAboveBar
    end

    return approximateSnap -- ROUNDING
end
