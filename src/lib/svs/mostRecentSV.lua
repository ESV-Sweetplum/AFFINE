---@diagnostic disable: undefined-field
function mostRecentSV(time)
    if (map.GetScrollVelocityAt(time)) then
        return map.GetScrollVelocityAt(time).Multiplier
    end
    return 1
end
