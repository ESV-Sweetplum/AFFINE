function TrailFollowMenu()
    local settings = parameterWorkflow("animation_trail_static", 'msxBounds', 'progressionExponent', 'lineCount',
        'spacing', "boundCoefficients")

    if RangeActivated() then
        local currentTime = offsets.startOffset + settings.spacing
        local iterations = 0
        local lines = {}
        local svs = {}
        local frameLengths = {}

        local preservedMsxValues = {}
        local nextCheckpoint = 1 / settings.lineCount

        while (currentTime < offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local msxTable = {}

            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset,
                settings.progressionExponent)

            local msxValue = mapProgress(settings.msxBounds[1],
                evaluateCoefficients(settings.boundCoefficients, progress),
                settings.msxBounds[2])

            if (progress >= nextCheckpoint) then
                nextCheckpoint = nextCheckpoint + 1 / settings.lineCount
                table.insert(preservedMsxValues, msxValue)
            end

            msxTable = combineTables(msxTable, preservedMsxValues)

            table.insert(msxTable, msxValue)

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

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset, "Static Trail",
            constructDebugTable(lines, svs, stats))
        setDebug("Line Count: " .. #lines .. " // SV Count: " .. #svs)
    end

    Plot(settings.boundCoefficients, settings.progressionExponent)
end
