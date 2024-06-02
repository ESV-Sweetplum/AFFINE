---@diagnostic disable: return-type-mismatch
---Creates a SliderVelocity. To place it, you must use an `action`.
---@param time number # The time to place the SV.
---@param multiplier number # The speed multiplier that gets applied onto the gameplay.
---@return SliderVelocityInfo
function sv(time, multiplier)
    return utils.CreateScrollVelocity(time, multiplier)
end
