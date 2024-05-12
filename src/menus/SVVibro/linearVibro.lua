---@diagnostic disable: undefined-field
function linearVibroMenu()
    local settings = parameterWorkflow("linearVibro", "msxBounds", "fps", "progressionExponent", {
        inputType = "Checkbox",
        key = "oneSided",
        label = "One-Sided Vibro?",
        value = false
    })

    if RangeActivated() then
        local vibroHeightFn = function (v)
            return mapProgress(settings.msxBounds[1],
                getProgress(offsets.startOffset, v, offsets.endOffset - 1, settings.progressionExponent),
                settings.msxBounds[2])
        end

        placeVibratoSVsByFn(vibroHeightFn, settings.oneSided, settings.fps)
    end
end

---Given a vibrato height function, places a clean set of vibrato SVs.
---@param vibroHeightFn function
---@param oneSided boolean
---@param fps number
function placeVibratoSVsByFn(vibroHeightFn, oneSided, fps)
    local OFFSET_SECURITY_CONSTANT = 2

    local currentTime = offsets.startOffset + OFFSET_SECURITY_CONSTANT
    local svs = {}
    local iterations = 1

    local teleportSign = 1
    while (currentTime <= offsets.endOffset - 1) and (iterations <= MAX_ITERATIONS) do
        local _, decimalValue = math.modf(currentTime)
        if (decimalValue < 0.1) then currentTime = math.floor(currentTime) + 0.1 end
        if (decimalValue > 0.9) then currentTime = math.ceil(currentTime) - 0.1 end
        local vibroHeight = vibroHeightFn(currentTime)
        local recentSVValue = 1
        if (map.GetScrollVelocityAt(currentTime)) then recentSVValue = map.GetScrollVelocityAt(currentTime).Multiplier end

        if (oneSided) then
            local tempSVTbl = insertTeleport({}, currentTime, vibroHeight * -1, recentSVValue)
            currentTime = currentTime + 1000 / fps
            tempSVTbl = insertTeleport(tempSVTbl, currentTime, vibroHeight, recentSVValue)

            if (currentTime < offsets.endOffset - OFFSET_SECURITY_CONSTANT) then
                svs = combineTables(svs, tempSVTbl)
            end
        else
            -- REDO LATER
            local tempSVTbl = insertTeleport({}, currentTime,
                iterations == 1 and vibroHeight or vibroHeight * 2 * teleportSign, recentSVValue)

            if (currentTime < offsets.endOffset - OFFSET_SECURITY_CONSTANT - 1) then
                svs = combineTables(svs, tempSVTbl)
                teleportSign = -1 * teleportSign
            end
            mostRecentHeight = vibroHeight
        end
        currentTime = currentTime + 1000 / fps
        iterations = iterations + 1
    end

    if (not oneSided) then
        currentTime = offsets.endOffset - OFFSET_SECURITY_CONSTANT - 1
        local multiplier = 1
        if (map.GetScrollVelocityAt(currentTime)) then multiplier = map.GetScrollVelocityAt(currentTime).Multiplier end
        svs = insertTeleport(svs, currentTime, mostRecentHeight * -1,
            multiplier)
    end

    actions.PlaceScrollVelocityBatch(cleanSVs(svs, offsets.startOffset + OFFSET_SECURITY_CONSTANT,
        offsets.endOffset - OFFSET_SECURITY_CONSTANT))

    setDebug("SV Count: " .. #svs)
end
