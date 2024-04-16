function ConvergeDivergeMenu()
    local parameterTable = constructParameters("center", "maxSpread", "lineCount", "lineDuration", "progressionExponent",
        "spacing", "pathCoefficients", {
            inputType = "Checkbox",
            key = "renderBelow",
            label = "Render Below?",
            value = true,
        }, {
            inputType = "Checkbox",
            key = "renderAbove",
            label = "Render Above?",
            value = true,
            sameLine = true
        }
        , {
            inputType = "Checkbox",
            key = "prefill",
            label = "Pre-Filled?",
            value = false,
        }
        , {
            inputType = "Checkbox",
            key = "terminateEarly",
            label = "Terminate Life Cycle?",
            value = false,
            sameLine = true
        })

    retrieveParameters("animation_convergeDiverge", parameterTable)

    parameterInputs(parameterTable)

    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if RangeActivated(offsets) then
        local currentTime = offsets.startOffset + 1

        local iterations = 0
        local lines = {}
        local svs = {}
        local frameLengths = {}
        local lineProgressionTable = {}
        local timeToGenerateClone = settings.lineDuration / settings.lineCount
        local lastClonedProgress = -1 * timeToGenerateClone

        if (settings.prefill) then
            for i = 1, settings.lineCount do
                table.insert(lineProgressionTable, -1 * i * timeToGenerateClone)
            end
        end

        while ((currentTime + (2 / INCREMENT)) <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset,
                settings.progressionExponent)

            if (not settings.terminateEarly) or (progress < 1 - settings.lineDuration + timeToGenerateClone) then
                if (progress - lastClonedProgress > timeToGenerateClone) then
                    lastClonedProgress = lastClonedProgress + timeToGenerateClone
                    table.insert(lineProgressionTable, progress)
                end
            end

            local msxTable = {}
            for idx, v in pairs(lineProgressionTable) do
                local lineProgression = progress - v
                if (lineProgression > settings.lineDuration) then
                    table.remove(lineProgressionTable, idx)
                else
                    local lineProgress = lineProgression / settings.lineDuration
                    local height = evaluateCoefficients(settings.pathCoefficients, lineProgress)
                    if (settings.renderAbove) then
                        table.insert(msxTable, mapProgress(settings.center, height, settings.center + settings.maxSpread))
                    end
                    if (settings.renderBelow) then
                        table.insert(msxTable, mapProgress(settings.center, height, settings.center - settings.maxSpread))
                    end
                end
            end


            local tbl = tableToLines(msxTable, currentTime, 0, settings.spacing)

            if (tbl.time > offsets.endOffset) then break end

            timeDiff = tbl.time - currentTime

            table.insert(frameLengths, timeDiff + 1)

            currentTime = currentTime + timeDiff

            lines = combineTables(lines, tbl.lines)
            svs = combineTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, FRAME_SIZE)

            currentTime = currentTime + 1

            iterations = iterations + 1
        end

        local stats = getStatisticsFromTable(frameLengths)

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset, "Converge/Diverge",
            constructDebugTable(lines, svs, stats))
        parameterTable[#parameterTable].value = "Line Count: " .. #lines .. " // SV Count: " .. #svs
    end
    Plot(settings.pathCoefficients, settings.progressionExponent, "Line Path Over Duration of Life Cycle")

    saveParameters("animation_convergeDiverge", parameterTable)
end
