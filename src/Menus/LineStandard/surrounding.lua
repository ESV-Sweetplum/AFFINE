function StandardSurroundingMenu()
    local settings = parameterWorkflow("standard_surrounding", 'distance', 'msxBounds')

    if NoteActivated() then
        local lines = {}
        local ms = offsets.startOffset + settings.msxBounds[1]

        local iterations = 0

        while (ms <= offsets.startOffset + settings.msxBounds[2]) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset + settings.msxBounds[1], ms,
                offsets.startOffset + settings.msxBounds[2])

            table.insert(lines, line(ms))

            ms = ms + mapProgress(settings.distance[1], progress, settings.distance[2])

            iterations = iterations + 1
        end

        local notes = getNotesInRange(offsets.startOffset + settings.msxBounds[1],
            offsets.startOffset + settings.msxBounds[2])
        if (type(notes) ~= "integer") then
            for _, note in pairs(notes) do
                lines = combineTables(lines, keepColorLine(note.StartTime, true))
            end
        end

        lines = cleanLines(lines, offsets.startOffset + settings.msxBounds[1],
            offsets.startOffset + settings.msxBounds[2])

        setDebug("Line Count: " .. #lines) -- DEBUG TEXT

        actions.PlaceTimingPointBatch(lines)
    end
end
