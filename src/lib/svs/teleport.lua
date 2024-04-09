---Generates two svs for a teleport.
---@param time number
---@param dist number
---@return SliderVelocityInfo[]
function teleport(time, dist)
    return {
        sv(time, INCREMENT * dist),
        sv(time + (1 / INCREMENT), 64000)
    }
end

---Adds a teleport sv to an existsing table of svs.
---@param svs SliderVelocityInfo[]
---@param time number
---@param dist number
---@return SliderVelocityInfo[]
function insertTeleport(svs, time, dist)
    return concatTables(svs, teleport(time, dist))
end
