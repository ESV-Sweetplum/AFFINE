function GlitchMenu()
    local settings = {
        msxBounds = DEFAULT_MSX_BOUNDS,
        msxBounds2 = DEFAULT_MSX_BOUNDS,
        spacing = DEFAULT_SPACING,
        lineCount = DEFAULT_LINE_COUNT,
        fps = DEFAULT_FPS,
        debug = 'Lines // SVs'
    }

    retrieveStateVariables("glitch", settings)

    _, settings.msxBounds = imgui.InputInt2("Start Lower/Upper MSX", settings.msxBounds)
    _, settings.msxBounds2 = imgui.InputInt2("End Lower/Upper MSX", settings.msxBounds2)
    _, settings.lineCount = imgui.InputInt("Line Count", settings.lineCount)

    _, settings.fps = imgui.InputFloat("Animation FPS", settings.fps)
    _, settings.spacing = imgui.InputFloat("MS Spacing", settings.spacing)

    local offsets = getStartAndEndNoteOffsets()

    if rangeSelected(offsets) then
        local activationButton = imgui.Button("Place Lines")

        if (activationButton) then
            local time = offsets.startOffset
            local lines = {}
            local svs = {}

            local INCREMENT = 64

            while (time < offsets.endOffset) do
                local progress = getProgress(offsets.startOffset, time, offsets.endOffset)

                local lowerBound = mapProgress(settings.msxBounds[1], progress, settings.msxBounds2[1])
                local upperBound = mapProgress(settings.msxBounds[2], progress, settings.msxBounds2[2])

                msxTable = {}
                for i = 1, settings.lineCount do
                    table.insert(msxTable, math.random(upperBound, lowerBound))
                end
                local tbl = returnFixedLines(msxTable, time, 0, settings.spacing)

                time = math.max(time + (1000 / settings.fps) - 2, tbl.time)

                lines = concatTables(lines, tbl.lines)
                svs = concatTables(svs, tbl.svs)

                table.insert(svs, utils.CreateScrollVelocity(time + (1 / INCREMENT), 64000))
                table.insert(svs, utils.CreateScrollVelocity(time + (2 / INCREMENT), 0))

                time = time + 2
            end

            settings.debug = #lines .. " // " .. #svs
            actions.PerformBatch({
                utils.CreateEditorAction(action_type.AddTimingPointBatch, lines),
                utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs)
            })
        end
    else
        imgui.Text("Select a Note to Place Lines.")
    end

    imgui.Text(settings.debug)

    saveStateVariables("glitch", settings)
end
