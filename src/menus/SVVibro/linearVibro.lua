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
                getProgress(offsets.startOffset, v, offsets.endOffset, settings.progressionExponent),
                settings.msxBounds[2])
        end

        placeVibratoSVs(vibroHeightFn, settings.oneSided, settings.fps)
    end
end

---Given a vibrato height function, places a clean set of vibrato SVs.
---@param vibroHeightFn function
---@param oneSided boolean
---@param fps number
function placeVibratoSVs(vibroHeightFn, oneSided, fps)
    local currentTime = offsets.startOffset
    local svs = {}
    local iterations = 1

    local teleportSign = 1
    local maxVibroHeight = 0
    while (currentTime <= offsets.endOffset) and (iterations <= MAX_ITERATIONS) do
        local vibroHeight = vibroHeightFn(currentTime)
        local recentSVValue = 1
        if (map.GetScrollVelocityAt(currentTime)) then recentSVValue = map.GetScrollVelocityAt(currentTime).Multiplier end

        if (oneSided) then
            local tempSVTbl = insertTeleport({}, currentTime, vibroHeight * -1, recentSVValue)
            currentTime = currentTime + 1000 / fps
            tempSVTbl = insertTeleport(tempSVTbl, currentTime, vibroHeight, recentSVValue)

            if (currentTime < offsets.endOffset) then
                svs = combineTables(svs, tempSVTbl)
            end
        else
            local tempSVTbl = insertTeleport({}, currentTime,
                iterations == 1 and vibroHeight or vibroHeight * 2 * teleportSign, recentSVValue)

            if (currentTime < offsets.endOffset - 2) then
                svs = combineTables(svs, tempSVTbl)
                teleportSign = -1 * teleportSign
            end
            maxVibroHeight = math.max(maxVibroHeight, vibroHeight)
        end
        currentTime = currentTime + 1000 / fps
        iterations = iterations + 1
    end

    if (not oneSided) then
        currentTime = offsets.endOffset - 1
        local multiplier = 1
        if (map.GetScrollVelocityAt(currentTime)) then multiplier = map.GetScrollVelocityAt(currentTime).Multiplier end
        svs = insertTeleport(svs, currentTime, maxVibroHeight * teleportSign,
            multiplier)
    end

    actions.PlaceScrollVelocityBatch(cleanSVs(svs, offsets.startOffset + 1, offsets.endOffset - 1))

    setDebug("SV Count: " .. #svs)
end
