function StandardSpreadMenu()
    local settings = parameterWorkflow("standard_spread", 'distance')

    if RangeActivated() then
        local lines = {}
        local msx = offsets.startOffset

        local iterations = 0

        while (msx <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, msx, offsets.endOffset)

            table.insert(lines, line(msx))

            msx = msx + mapProgress(settings.distance[1], progress, settings.distance[2])

            iterations = iterations + 1
        end

        local notes = getNotesInRange(offsets.startOffset, offsets.endOffset)
        if (type(notes) ~= "integer") then
            for _, note in pairs(notes) do
                lines = combineTables(lines, keepColorLine(note.StartTime, true))
            end
        end

        lines = cleanLines(lines, offsets.startOffset, offsets.endOffset)

        setDebug("Line Count: " .. #lines) -- DEBUG TEXT

        actions.PlaceTimingPointBatch(lines)
    end
end