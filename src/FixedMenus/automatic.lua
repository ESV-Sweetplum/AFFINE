function FixedAutomaticMenu()
    local settings = {
        delay = DEFAULT_DELAY,
        msxBounds = DEFAULT_MSX_BOUNDS,
        spacing = DEFAULT_SPACING,
        distance = DEFAULT_DISTANCE,
        debug = "Line Count"
    }

    retrieveStateVariables("fixed_automatic", settings)

    _, settings.msxBounds = imgui.InputInt2("Start/End MSX", settings.msxBounds)
    _, settings.distance = imgui.InputInt2("Distance Between Lines", settings.distance)

    _, settings.delay = imgui.InputInt("Delay", settings.delay)
    _, settings.spacing = imgui.InputFloat("MS Spacing", settings.spacing)

    local offsets = getStartAndEndNoteOffsets()

    if noteActivated(offsets) then
        local tbl = placeAutomaticFrame(offsets.startOffset + settings.delay, settings.msxBounds[1],
            settings.msxBounds[2],
            settings.spacing, settings.distance)

        actions.PerformBatch({
            utils.CreateEditorAction(action_type.AddTimingPointBatch, tbl.lines),
            utils.CreateEditorAction(action_type.AddScrollVelocityBatch, tbl.svs)
        })
    end

    imgui.Text(settings.debug)

    saveStateVariables("fixed_automatic", settings)
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
    return returnFixedLines(msxTable, startTime, 0, spacing)
end
