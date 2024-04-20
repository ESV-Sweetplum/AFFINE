function SpectrumMenu()
    local settings = parameterWorkflow("animation_spectrum", "center", "maxSpread", "distance", "progressionExponent",
        "spacing",
        "boundCoefficients", {
            inputType = "Checkbox",
            key = "inverse",
            label = "Inverse?",
            value = false
        })


    if RangeActivated(offsets) then
        local currentTime = offsets.startOffset + settings.spacing

        local iterations = 0
        local lines = {}
        local svs = {}
        local frameLengths = {}

        while ((currentTime + (2 / INCREMENT)) <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset,
                settings.progressionExponent)


            local heightDifferential = settings.maxSpread *
                evaluateCoefficients(settings.boundCoefficients, progress)

            local tbl = placeSpectrumFrame(currentTime, settings.center, settings.maxSpread, settings.distance,
                settings.spacing, heightDifferential, settings.inverse)

            if (tbl.time > offsets.endOffset) then break end

            table.insert(frameLengths, tbl.time - currentTime + 2)

            currentTime = tbl.time

            lines = combineTables(lines, tbl.lines)
            svs = combineTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, FRAME_SIZE)

            iterations = iterations + 1

            currentTime = currentTime + 2
        end

        local stats = getStatisticsFromTable(frameLengths)

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset, "Spectrum",
            constructDebugTable(lines, svs, stats))
        setDebug("Line Count: " .. #lines .. " // SV Count: " .. #svs)
    end
    Plot(settings.boundCoefficients, settings.progressionExponent)
end

function placeSpectrumFrame(startTime, center, maxSpread, lineDistance, spacing, boundary, inverse)
    msxTable = {}

    local iterations = 0

    if (inverse) then
        local msx = center + maxSpread

        while (msx >= center + boundary) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(center, msx, center + maxSpread)
            table.insert(msxTable, msx)
            table.insert(msxTable, 2 * center - msx)
            msx = msx - mapProgress(lineDistance[1], progress, lineDistance[2])
            iterations = iterations + 1
        end

        return tableToLines(msxTable, startTime, 0, spacing)
    else
        local msx = center

        while (msx <= center + boundary) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(center, msx, center + maxSpread)
            table.insert(msxTable, msx)
            table.insert(msxTable, 2 * center - msx)
            msx = msx + mapProgress(lineDistance[1], progress, lineDistance[2])
            iterations = iterations + 1
        end

        return tableToLines(msxTable, startTime, 0, spacing)
    end
end
