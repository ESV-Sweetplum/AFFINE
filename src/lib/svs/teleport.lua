function teleport(time, dist)
    return {
        sv(time, INCREMENT * dist),
        sv(time + (1 / INCREMENT), 64000)
    }
end

function insertTeleport(svs, time, dist)
    return concatTables(svs, teleport(time, dist))
end
