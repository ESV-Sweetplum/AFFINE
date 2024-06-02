---@diagnostic disable: undefined-field
---Gets the multiplier of the most recent SV at a `time`.
---@param time number # The time to search at.
---@return number
function mostRecentSV(time)
    if (map.GetScrollVelocityAt(time)) then
        return map.GetScrollVelocityAt(time).Multiplier
    end
    return 1
end
