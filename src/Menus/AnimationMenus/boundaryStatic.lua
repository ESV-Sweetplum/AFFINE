function StaticBoundaryMenu()
    local parameterTable = constructParameters("msxBounds", "distance", "spacing", "polynomialCoefficients", {
        inputType = "RadioBoolean",
        key = "evalUnder",
        label = { "Render Over Boundary", "Render Under Boundary" },
        value = true
    })

    retrieveParameters("animation_polynomial", parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if rangeActivated(offsets) then
        local currentTime = offsets.startOffset + 1

        local iterations = 0
        local lines = {}
        local svs = {}


        while ((currentTime + (2 / INCREMENT)) <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset)

            local boundary = settings.msxBounds[2] *
                (settings.polynomialCoefficients[1] * progress ^ 2 + settings.polynomialCoefficients[2] * progress + settings.polynomialCoefficients[3])

            local tbl = placeStaticFrame(currentTime, settings.msxBounds[1], settings.msxBounds[2], settings.distance,
                settings.spacing, boundary, settings.evalUnder)

            if (tbl.time > offsets.endOffset) then break end

            currentTime = tbl.time

            lines = concatTables(lines, tbl.lines)
            svs = concatTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, 1000)

            iterations = iterations + 1

            currentTime = currentTime + 2
        end

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset)
        parameterTable[#parameterTable].value = "Line Count: " .. #lines .. " // SV Count: " .. #svs
    end

    Plot(settings.polynomialCoefficients)

    saveParameters("animation_polynomial", parameterTable)
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
