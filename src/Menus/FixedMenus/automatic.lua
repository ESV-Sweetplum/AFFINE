function FixedAutomaticMenu()
    local parameterTable = constructParameters('msxBounds', 'distance', 'delay', 'spacing')

    retrieveParameters("fixed_automatic", parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if noteActivated(offsets) then
        local tbl = placeAutomaticFrame(offsets.startOffset + settings.delay, settings.msxBounds[1],
            settings.msxBounds[2],
            settings.spacing, settings.distance)

        generateAffines(tbl.lines, tbl.svs, offsets.startOffset, offsets.endOffset)
        parameterTable[#parameterTable].value = "Line Count: " .. #tbl.lines .. " // SV Count: " .. #tbl.svs
    end

    saveParameters("fixed_automatic", parameterTable)
end

function placeAutomaticFrame(startTime, low, high, spacing, distance)
    msxTable = {}
    local msx = low
    local iterations = 0
    while (msx <= high) and (iterations < MAX_ITERATIONS) do
        local progress = getProgress(low, msx, high)
        table.insert(msxTable, msx)
        msx = msx + mapProgress(distance[1], progress, distance[2])
        iterations = iterations + 1
    end
    return tableToLines(msxTable, startTime, 0, spacing)
end
