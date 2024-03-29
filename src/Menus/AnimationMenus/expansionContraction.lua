function ExpansionContractionMenu()
    local parameterTable = constructParameters('msxBounds', 'distance', 'spacing')

    retrieveParameters("animation_expansion_contraction", parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if RangeActivated(offsets) then
        local currentTime = offsets.startOffset + 1

        local iterations = 0

        local lines = {}
        local svs = {}

        while (currentTime <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset)

            local distance = mapProgress(settings.distance[1], progress, settings.distance[2])

            local tbl = placeAutomaticFrame(currentTime, settings.msxBounds[1], settings.msxBounds[2], settings.spacing,
                { distance, distance })

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

    saveParameters("animation_expansion_contraction", parameterTable)
end
