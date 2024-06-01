function TrailFollowMenu()
    local settings = parameterWorkflow("animation_trail_follow", 'msxBounds', 'progressionExponent', 'lineCount',
        customParameter("Float", "Proportional Delay", "delay", 0.05), 'spacing', "boundCoefficients")

    if RangeActivated() then
        local currentTime = offsets.startOffset + settings.spacing
        local iterations = 0
        local lines = {}
        local svs = {}
        local frameLengths = {}

        while (currentTime < offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local msxTable = {}

            for i = 1, settings.lineCount do
                local progress = clamp(getProgress(offsets.startOffset, currentTime, offsets.endOffset,
                    settings.progressionExponent) - (i - 1) * settings.delay, 0, 1)

                table.insert(msxTable,
                    mapProgress(settings.msxBounds[1], evaluateCoefficients(settings.boundCoefficients, progress),
                        settings.msxBounds[2]))
            end

            local tbl = tableToAffineFrame(msxTable, currentTime, 0, settings.spacing)

            if (tbl.time > offsets.endOffset) then break end

            timeDiff = tbl.time - currentTime

            table.insert(frameLengths, timeDiff + 2)

            currentTime = currentTime + timeDiff

            lines = combineTables(lines, tbl.lines)
            svs = combineTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, FRAME_SIZE)

            currentTime = currentTime + 2
            iterations = iterations + 1
        end

        local stats = getStatisticsFromTable(frameLengths)

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset, "Following Trail",
            constructDebugTable(lines, svs, stats))
        setDebug("Line Count: " .. #lines .. " // SV Count: " .. #svs)
    end

    PolynomialPlot(settings.boundCoefficients, settings.progressionExponent)
end
