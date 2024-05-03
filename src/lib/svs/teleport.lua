---Generates two svs for a teleport.
---@param time number
---@param dist number
---@param endSV number
---@return SliderVelocityInfo[]
function teleport(time, dist, endSV)
    return {
        sv(time, INCREMENT * dist),
        sv(time + (1 / INCREMENT), endSV)
    }
end

---Adds a teleport sv to an existing table of svs.
---@param svs SliderVelocityInfo[]
---@param time number
---@param dist number
---@param remainingSV? number
---@return SliderVelocityInfo[]
function insertTeleport(svs, time, dist, remainingSV)
    return combineTables(svs, teleport(time, dist, remainingSV or 0))
end
