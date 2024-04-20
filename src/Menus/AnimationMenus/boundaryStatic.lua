function StaticBoundaryMenu()
    local parameterTable = constructParameters("msxBounds", "distance", "progressionExponent", "spacing",
        "boundCoefficients", {
            inputType = "RadioBoolean",
            key = "evalUnder",
            label = { "Render Over Boundary", "Render Under Boundary" },
            value = true
        })

    retrieveParameters("animation_static_polynomial", parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if RangeActivated(offsets) then
        local currentTime = offsets.startOffset + settings.spacing

        local iterations = 0
        local lines = {}
        local svs = {}
        local frameLengths = {}


        while ((currentTime + (2 / INCREMENT)) <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset,
                settings.progressionExponent)

            local boundary = settings.msxBounds[2] * evaluateCoefficients(settings.boundCoefficients, progress)

            local tbl = placeStaticFrame(currentTime, settings.msxBounds[1], settings.msxBounds[2], settings.distance,
                settings.spacing, boundary, settings.evalUnder)

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

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset, "Static Boundary",
            constructDebugTable(lines, svs, stats))
        setDebug("Line Count: " .. #lines .. " // SV Count: " .. #svs)
    end

    Plot(settings.boundCoefficients, settings.progressionExponent)

    saveParameters("animation_static_polynomial", parameterTable)
end

function placeStaticFrame(startTime, min, max, lineDistance, spacing, boundary, evalUnder)
    msxTable = {}
    local msx = min
    local iterations = 0

    while (msx <= max) and (iterations < MAX_ITERATIONS) do
        local progress = getProgress(min, msx, max)
        if (evalUnder) then
            if (msx <= boundary) then table.insert(msxTable, msx) end
        else
            if (msx >= boundary) then table.insert(msxTable, msx) end
        end
        msx = msx + mapProgress(lineDistance[1], progress, lineDistance[2])
        iterations = iterations + 1
    end

    return tableToLines(msxTable, startTime, 0, spacing)
end
