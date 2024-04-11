function GlitchMenu()
    local parameterTable = constructParameters('msxBounds1', 'msxBounds2', 'lineCount', 'progressionExponent', 'fps',
        'spacing')

    retrieveParameters("glitch", parameterTable)

    parameterInputs(parameterTable)

    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if RangeActivated(offsets) then
        local currentTime = offsets.startOffset
        local lines = {}
        local svs = {}
        local frameLengths = {}

        while (currentTime <= offsets.endOffset) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset) ^
                settings.progressionExponent


            local lowerBound = mapProgress(settings.msxBounds1[1], progress, settings.msxBounds2[1])
            local upperBound = mapProgress(settings.msxBounds1[2], progress, settings.msxBounds2[2])

            msxTable = {}
            for i = 1, settings.lineCount do
                table.insert(msxTable, math.random(upperBound, lowerBound))
            end
            local tbl = tableToLines(msxTable, currentTime, 0, settings.spacing)

            if (tbl.time > offsets.endOffset) then break end

            local timeDiff = math.max(1000 / settings.fps - 2, tbl.time - currentTime)

            table.insert(frameLengths, timeDiff + 2)

            currentTime = currentTime + timeDiff

            lines = combineTables(lines, tbl.lines)
            svs = combineTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, FRAME_SIZE)

            currentTime = currentTime + 2
        end

        local stats = getStatisticsFromTable(frameLengths)

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset, "Glitch",
            constructDebugTable(lines, svs, stats))
        parameterTable[#parameterTable].value = "Line Count: " .. #lines .. " // SV Count: " .. #svs
    end



    saveParameters("glitch", parameterTable)
end
