---@diagnostic disable: return-type-mismatch
---Creates a SliderVelocity. To place it, you must use an `action`.
---@param time number
---@param multiplier number
---@return SliderVelocityInfo
function sv(time, multiplier)
    return utils.CreateScrollVelocity(time, multiplier)
end
