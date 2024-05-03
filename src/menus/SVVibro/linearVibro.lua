---@diagnostic disable: undefined-field
function linearVibroMenu()
    local settings = parameterWorkflow("linearVibro", "msxBounds", "fps", "progressionExponent", {
        inputType = "Checkbox",
        key = "oneSided",
        label = "One-Sided Vibro?",
        value = false
    })

    if RangeActivated() then
        local currentTime = offsets.startOffset
        local svs = {}
        local iterations = 1

        local teleportSign = 1
        local maxVibroHeight = 0
        while (currentTime <= offsets.endOffset) and (iterations <= MAX_ITERATIONS) do
            local vibroHeight = mapProgress(settings.msxBounds[1],
                getProgress(offsets.startOffset, currentTime, offsets.endOffset, settings.progressionExponent),
                settings.msxBounds[2])

            local recentSVValue = map.GetScrollVelocityAt(currentTime).Multiplier

            if (settings.oneSided == true) then
                local tempSVTbl = insertTeleport({}, currentTime, vibroHeight * -1, recentSVValue)
                currentTime = currentTime + 1000 / settings.fps
                tempSVTbl = insertTeleport(tempSVTbl, currentTime, vibroHeight, recentSVValue)

                if (currentTime < offsets.endOffset) then
                    svs = combineTables(svs, tempSVTbl)
                    currentTime = currentTime + 1000 / settings.fps
                end
            else
                local tempSVTbl = insertTeleport({}, currentTime,
                    iterations == 1 and vibroHeight or vibroHeight * 2 * teleportSign, recentSVValue)

                if (currentTime < offsets.endOffset - 2) then
                    svs = combineTables(svs, tempSVTbl)
                    currentTime = currentTime + 1000 / settings.fps
                    teleportSign = -1 * teleportSign
                end
                maxVibroHeight = math.max(maxVibroHeight, vibroHeight)
            end
            iterations = iterations + 1
        end

        if (settings.oneSided == false) then
            currentTime = offsets.endOffset - 1
            svs = insertTeleport(svs, currentTime, maxVibroHeight * teleportSign,
                map.GetScrollVelocityAt(currentTime).Multiplier)
        end

        actions.PlaceScrollVelocityBatch(cleanSVs(svs, offsets.startOffset, offsets.endOffset))

        setDebug("SV Count: " .. #svs)
    end
end
