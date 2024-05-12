---@diagnostic disable: undefined-field

function stackVibroMenu()
    local settings = parameterWorkflow("stackVibro", "msxList", "fps")

    if RangeActivated() then
        local tbl = table.split(settings.msxList, "%S+")

        placeVibratoSVsByTbl(tbl, settings.fps)
    end
end

function placeVibratoSVsByTbl(tbl, fps)
    local OFFSET_SECURITY_CONSTANT = 2

    local currentTime = offsets.startOffset + OFFSET_SECURITY_CONSTANT
    local svs = {}
    local iterations = 1

    while (currentTime <= offsets.endOffset - 1) and (iterations <= MAX_ITERATIONS) do
        local _, decimalValue = math.modf(currentTime)
        if (decimalValue < 0.1) then currentTime = math.floor(currentTime) + 0.1 end
        if (decimalValue > 0.9) then currentTime = math.ceil(currentTime) - 0.1 end

        local vibroHeight = tbl[((iterations - 1) % #tbl) + 1]
        local recentSVValue = 1
        if (map.GetScrollVelocityAt(currentTime)) then recentSVValue = map.GetScrollVelocityAt(currentTime).Multiplier end

        local tempSVTbl = insertTeleport({}, currentTime, vibroHeight * -1, recentSVValue)
        currentTime = currentTime + 1000 / fps
        tempSVTbl = insertTeleport(tempSVTbl, currentTime, vibroHeight, recentSVValue)

        if (currentTime < offsets.endOffset - OFFSET_SECURITY_CONSTANT) then
            svs = combineTables(svs, tempSVTbl)
        end

        currentTime = currentTime + 1000 / fps
        iterations = iterations + 1
    end

    actions.PlaceScrollVelocityBatch(cleanSVs(svs, offsets.startOffset + OFFSET_SECURITY_CONSTANT,
        offsets.endOffset - OFFSET_SECURITY_CONSTANT))

    setDebug("SV Count: " .. #svs)
end
