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

        while (currentTime <= offsets.endOffset) and (iterations <= MAX_ITERATIONS) do
            local vibroHeight = mapProgress(settings.msxBounds[1],
                getProgress(offsets.startOffset, currentTime, offsets.endOffset, settings.progressionExponent),
                settings.msxBounds[2])

            if (settings.oneSided) then
                local tempSVTbl = insertTeleport({}, currentTime, vibroHeight)
                currentTime = currentTime + 1000 / settings.fps
                tempSVTbl = insertTeleport(tempSVTbl, currentTime, vibroHeight)
                currentTime = currentTime + 1000 / settings.fps

                if (currentTime < offsets.endOffset) then
                    svs = combineTables(svs, tempSVTbl)
                end
            else
                if (iterations == 1) then
                    svs = insertTeleport({}, currentTime, vibroHeight)
                else
                    local tempSVTbl = insertTeleport({}, currentTime, vibroHeight * -2)
                    currentTime = currentTime + 1000 / settings.fps
                    tempSVTbl = insertTeleport(tempSVTbl, currentTime, vibroHeight * 2)
                    currentTime = currentTime + 1000 / settings.fps

                    if (currentTime < offsets.endOffset - 2) then
                        svs = combineTables(svs, tempSVTbl)
                    end
                end
                currentTime = currentTime + 1
                svs = insertTeleport(svs, currentTime, vibroHeight * -1)
            end
        end

        actions.PlaceScrollVelocityBatch(cleanSVs(svs, offsets.startOffset, offsets.endOffset))

        setDebug("SV Count: " .. #svs)
    end
end
