---Generates two svs for a teleport.
---@param time number # The time of the teleport.
---@param dist number # The distance of the teleport, in msx.
---@param endSV? number # The sv multiplier to use after the teleport is finished.
---@return SliderVelocityInfo[]
function teleport(time, dist, endSV)
    endSV = endSV or 1
    return {
        sv(time, INCREMENT * dist),
        sv(time + (1 / INCREMENT), endSV)
    }
end

---Adds a teleport sv to an existing table of svs.
---@param svs SliderVelocityInfo[] # The table of svs to add to.
---@param time number # The time of the teleport.
---@param dist number # The distance of the teleport, in msx.
---@param endSV? number # The sv multiplier to use after the teleport is finished.
---@return SliderVelocityInfo[]
function insertTeleport(svs, time, dist, endSV)
    return combineTables(svs, teleport(time, dist, endSV or 0))
end
