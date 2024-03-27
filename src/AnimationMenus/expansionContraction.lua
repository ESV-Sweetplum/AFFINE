function ExpansionContractionMenu()
    local settings = {
        msxBounds = DEFAULT_MSX_BOUNDS,
        spacing = DEFAULT_SPACING,
        distance = DEFAULT_DISTANCE,
        debug = 'Lines // SVs'
    }

    retrieveStateVariables("animation_expansion_contraction", settings)

    _, settings.msxBounds = imgui.InputInt2("Start/End MSX", settings.msxBounds)
    _, settings.distance = imgui.InputInt2("Distance Between Lines", settings.distance)

    _, settings.spacing = imgui.InputFloat("MS Spacing", settings.spacing)

    local offsets = getStartAndEndNoteOffsets()

    if rangeActivated(offsets) then
        local currentTime = offsets.startOffset + 1

        local iterations = 0

        local lines = {}
        local svs = {}

        while (currentTime <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset)

            local distance = mapProgress(settings.distance[1], progress, settings.distance[2])

            local msx = settings.msxBounds[1]
            local iterations = 0

            local msxTable = {}

            while (msx <= settings.msxBounds[2]) do
                table.insert(msxTable, msx)
                msx = msx + distance
            end

            local tbl = returnFixedLines(msxTable, currentTime, 0, settings.spacing)

            if (tbl.time > offsets.endOffset) then break end

            currentTime = tbl.time

            lines = concatTables(lines, tbl.lines)
            svs = concatTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, 1000)

            iterations = iterations + 1

            currentTime = currentTime + 2
        end
        svs = cleanSVs(svs, offsets.startOffset, offsets.endOffset)

        settings.debug = #lines .. ' // ' .. #svs

        actions.PerformBatch({
            utils.CreateEditorAction(action_type.AddTimingPointBatch, lines),
            utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs)
        })
    end

    imgui.Text(settings.debug)

    saveStateVariables("animation_expansion_contraction", settings)
end
