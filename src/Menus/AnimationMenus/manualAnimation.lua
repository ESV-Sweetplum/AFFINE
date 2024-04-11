function BasicManualAnimationMenu()
    local parameterTable = constructParameters('msxList1', 'msxList2', 'progressionExponent', 'fps', 'spacing')

    retrieveParameters("animation_manual", parameterTable)
    parameterInputs(parameterTable)

    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if RangeActivated(offsets) then
        startMsxTable = table.split(settings.msxList1, "%S+")
        endMsxTable = table.split(settings.msxList2, "%S+")

        local currentTime = offsets.startOffset + 1
        local iterations = 0
        local lines = {}
        local svs = {}
        local frameLengths = {}

        while (currentTime < offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset) ^
                settings.progressionExponent

            local msxTable = {}

            for i = 1, #endMsxTable do
                table.insert(msxTable, mapProgress(startMsxTable[i], progress, endMsxTable[i]))
            end

            local tbl = tableToLines(msxTable, currentTime, 0, settings.spacing)

            if (tbl.time > offsets.endOffset) then break end

            timeDiff = math.max(1000 / settings.fps - 2, tbl.time - currentTime)

            table.insert(frameLengths, timeDiff)

            currentTime = currentTime + timeDiff

            lines = combineTables(lines, tbl.lines)
            svs = combineTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, FRAME_SIZE)

            currentTime = currentTime + 2
        end

        local stats = getStatisticsFromTable(frameLengths)

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset, "Manual Animation",
            constructDebugTable(lines, svs, stats))
        parameterTable[#parameterTable].value = "Line Count: " .. #lines .. " // SV Count: " .. #svs
    end

    saveParameters("animation_manual", parameterTable)
end
