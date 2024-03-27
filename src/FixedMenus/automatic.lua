function FixedAutomaticMenu()
    local settings = {
        offset = DEFAULT_OFFSET,
        delay = DEFAULT_DELAY,
        msxBounds = DEFAULT_MSX_BOUNDS,
        spacing = DEFAULT_SPACING,
        distance = DEFAULT_DISTANCE,
        debug = "Line Count"
    }

    retrieveStateVariables("fixed_automatic", settings)

    _, settings.msxBounds = imgui.InputInt2("Start/End MSX", settings.msxBounds)
    _, settings.distance = imgui.InputInt2("Distance Between Lines", settings.distance)

    _, settings.offset = imgui.InputInt("MSX Offset", settings.offset)
    _, settings.delay = imgui.InputInt("Delay", settings.delay)
    _, settings.spacing = imgui.InputFloat("MS Spacing", settings.spacing)

    local offsets = getStartAndEndNoteOffsets()

    if noteSelected(offsets) then
        local activationButton = imgui.Button("Place the shit")

        if (activationButton) then
            msxTable = {}
            local MAX_ITERATIONS = 1000
            local msx = settings.msxBounds[1]
            local iterations = 0
            while (msx <= settings.msxBounds[2]) and (iterations < MAX_ITERATIONS) do
                local progress = getProgress(settings.msxBounds[1], msx, settings.msxBounds[2])
                table.insert(msxTable, msx)
                msx = msx + mapProgress(settings.distance[1], progress, settings.distance[2])
                iterations = iterations + 1
            end
            placeFixedLines(msxTable, offsets.startOffset + settings.delay, settings.offset, settings.spacing)
            settings.debug = iterations
        end
    else
        imgui.Text("select note to place sv :)")
    end

    imgui.Text(settings.debug)

    saveStateVariables("fixed_automatic", settings)
end
