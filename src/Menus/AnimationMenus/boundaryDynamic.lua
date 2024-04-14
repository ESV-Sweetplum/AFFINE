function DynamicBoundaryMenu()
    local parameterTable = constructParameters("msxBounds", 'distance', "progressionExponent", "spacing",
        "polynomialCoefficients", {
            inputType = "RadioBoolean",
            key = "evalOver",
            label = { "Change Bottom Bound", "Change Top Bound" },
            value = true
        })

    retrieveParameters("animation_dynamic_polynomial", parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if RangeActivated(offsets) then
        local currentTime = offsets.startOffset + 1

        local iterations = 0

        local lines = {}
        local svs = {}
        local frameLengths = {}

        while ((currentTime + (2 / INCREMENT)) <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset,
                settings.progressionExponent)

            local polynomialHeight = evaluateCoefficients(settings.polynomialCoefficients, progress)

            local tbl = placeDynamicFrame(currentTime, settings.msxBounds[1], settings.msxBounds[2], settings.distance,
                settings.spacing, polynomialHeight, settings.evalOver)

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

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset, "Dynamic Boundary",
            constructDebugTable(lines, svs, stats))
        parameterTable[#parameterTable].value = "Line Count: " .. #lines .. " // SV Count: " .. #svs
    end
    Plot(settings.polynomialCoefficients, settings.progressionExponent)

    saveParameters("animation_dynamic_polynomial", parameterTable)
end

function placeDynamicFrame(startTime, min, max, lineDistance, spacing, polynomialHeight, evalOver)
    msxTable = {}
    local msx = min
    local iterations = 0

    while (msx <= max) and (iterations < MAX_ITERATIONS) do
        local progress = getProgress(min, msx, max)
        if (evalOver) then
            table.insert(msxTable, (msx - min) * polynomialHeight + min)
        else
            table.insert(msxTable, max - (msx - min) * (1 - polynomialHeight))
        end
        msx = msx + mapProgress(lineDistance[1], progress, lineDistance[2])
        iterations = iterations + 1
    end

    return tableToLines(msxTable, startTime, 0, spacing)
end
