function StandardSpreadMenu()
    local settings = {
        distance = DEFAULT_DISTANCE
    }

    retrieveStateVariables("standard_spread", settings)

    _, settings.distance = imgui.InputInt2("Distance Between Lines", settings.distance)

    local offsets = getStartAndEndNoteOffsets()

    if rangeSelected(offsets) then
        local activationButton = imgui.Button("Place the shit")

        if (activationButton) then
            local lines = {}
            local msx = offsets.startOffset

            local iterations = 0
            local MAX_ITERATIONS = 1000

            while (msx < offsets.endOffset) and (iterations < MAX_ITERATIONS) do
                local progress = getProgress(offsets.startOffset, msx, offsets.endOffset)

                table.insert(lines, utils.CreateTimingPoint(msx, map.GetCommonBpm()))

                msx = msx + mapProgress(settings.distance[1], progress, settings.distance[2])

                iterations = iterations + 1
            end

            actions.PlaceTimingPointBatch(lines)
        end
    else
        imgui.Text("select two notes to place sv :)")
    end

    saveStateVariables("standard_spread", settings)
end
