function WipeMenu()
    local settings = parameterWorkflow("animation_wipe", 'msxBounds', 'distance', 'progressionExponent', 'lineCount',
        'spacing', "boundCoefficients")

    if RangeActivated() then
        local currentTime = offsets.startOffset + settings.spacing
        local iterations = 0
        local lines = {}
        local svs = {}
        local frameLengths = {}

        local initialMsxValues = {}
        local previousMsxValue = -1e69

        local backgroundMsxValue = settings.msxBounds[1]

        while (backgroundMsxValue <= settings.msxBounds[2]) and (iterations < MAX_ITERATIONS) do
            table.insert(initialMsxValues, backgroundMsxValue)
            local progress = getProgress(settings.msxBounds[1], backgroundMsxValue, settings.msxBounds[2])
            backgroundMsxValue = backgroundMsxValue + mapProgress(settings.distance[1], progress, settings.distance[2])
            iterations = iterations + 1
        end

        iterations = 0

        while (currentTime < offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local msxTable = {}

            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset,
                settings.progressionExponent)

            local msxValue = mapProgress(settings.msxBounds[1],
                evaluateCoefficients(settings.boundCoefficients, progress),
                settings.msxBounds[2])

            for i = 1, #initialMsxValues do
                if (sign(previousMsxValue - initialMsxValues[i]) ~= sign(msxValue - initialMsxValues[i])) then
                    table.remove(initialMsxValues, i)
                end -- Check if primary wiper has crossed desired line
            end

            msxTable = combineTables(msxTable, initialMsxValues)

            table.insert(msxTable, msxValue)

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

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset, "Wipe",
            constructDebugTable(lines, svs, stats))
        setDebug("Line Count: " .. #lines .. " // SV Count: " .. #svs)
    end

    Plot(settings.boundCoefficients, settings.progressionExponent)
end

function sign(x)
    return x > 0 and 1 or x < 0 and -1 or 0
end
