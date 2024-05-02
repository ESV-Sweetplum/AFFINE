function FixedAutomaticMenu()
    local settings = parameterWorkflow("fixed_automatic", 'msxBounds', 'distance', 'delay', 'spacing')

    if NoteActivated() then
        local tbl = placeAutomaticFrame(offsets.startOffset + settings.delay, settings.msxBounds[1],
            settings.msxBounds[2],
            settings.spacing, settings.distance)

        generateAffines(tbl.lines, tbl.svs, offsets.startOffset, offsets.endOffset, "Automatic Fixed")
        setDebug("Line Count: " .. #tbl.lines .. " // SV Count: " .. #tbl.svs)
    end
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
