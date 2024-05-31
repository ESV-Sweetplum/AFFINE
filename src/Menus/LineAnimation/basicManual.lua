function BasicManualAnimationMenu()
    local settings = parameterWorkflow("animation_manual", 'msxList1', 'msxList2', 'progressionTable', 'fps',
        'spacing')

    if RangeActivated() then
        startMsxTable = table.split(settings.msxList1, "%S+")
        endMsxTable = table.split(settings.msxList2, "%S+")
        progressionTable = table.split(settings.progressionTable, "%S+")

        if (#startMsxTable ~= #endMsxTable) then
            print("The start and end msx values are not of equal length.")
            return;
        end

        if (#endMsxTable ~= #progressionTable) then
            print("The msx table and progression table are not of equal length.")
            return;
        end

        local currentTime = offsets.startOffset + settings.spacing
        local iterations = 0
        local lines = {}
        local svs = {}
        local frameLengths = {}

        while (currentTime < offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local msxTable = {}

            for i = 1, #endMsxTable do
                local progressionExponent = tonumber(progressionTable[1])
                if (#progressionTable >= 2) and (#endMsxTable == #progressionTable) then
                    progressionExponent = progressionTable[i]
                end
                local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset,
                    progressionExponent)

                table.insert(msxTable, mapProgress(startMsxTable[i], progress, endMsxTable[i]))
            end

            local tbl = tableToAffineFrame(msxTable, currentTime, 0, settings.spacing)

            if (tbl.time > offsets.endOffset) then break end

            timeDiff = math.max(1000 / settings.fps - 2, tbl.time - currentTime)

            table.insert(frameLengths, timeDiff + 2)

            currentTime = currentTime + timeDiff

            lines = combineTables(lines, tbl.lines)
            svs = combineTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, FRAME_SIZE)

            currentTime = currentTime + 2
            iterations = iterations + 1
        end

        local stats = getStatisticsFromTable(frameLengths)

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset, "Manual Animation",
            constructDebugTable(lines, svs, stats))
        setDebug("Line Count: " .. #lines .. " // SV Count: " .. #svs)
    end
end
