function StandardSpreadMenu()
    local settings = {
        distance = DEFAULT_DISTANCE
    }

    retrieveStateVariables("standard_spread", settings)

    _, settings.distance = imgui.InputInt2("Distance Between Lines", settings.distance)

    local offsets = getStartAndEndNoteOffsets()

    if rangeActivated(offsets) then
        local lines = {}
        local msx = offsets.startOffset

        local iterations = 0

        while (msx <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, msx, offsets.endOffset)

            table.insert(lines, line(msx))

            msx = msx + mapProgress(settings.distance[1], progress, settings.distance[2])

            iterations = iterations + 1
        end

        lines = cleanLines(lines, offsets.startOffset, offsets.endOffset)

        actions.PlaceTimingPointBatch(lines)
    end

    saveStateVariables("standard_spread", settings)
end
