function FixedRandomMenu()
    local settings = {
        delay = DEFAULT_DELAY,
        msxBounds = DEFAULT_MSX_BOUNDS,
        spacing = DEFAULT_SPACING,
        lineCount = DEFAULT_LINE_COUNT
    }

    retrieveStateVariables("fixed_random", settings)

    _, settings.msxBounds = imgui.InputInt2("Start/End MSX", settings.msxBounds)
    _, settings.lineCount = imgui.InputInt("Line Count", settings.lineCount)

    _, settings.delay = imgui.InputInt("Delay", settings.delay)
    _, settings.spacing = imgui.InputFloat("MS Spacing", settings.spacing)

    local offsets = getStartAndEndNoteOffsets()

    if noteSelected(offsets) then
        local activationButton = imgui.Button("Place the shit")

        if (activationButton) then
            msxTable = {}
            for i = 1, settings.lineCount do
                table.insert(msxTable, math.random(settings.msxBounds[1], settings.msxBounds[2]))
            end
            placeFixedLines(msxTable, offsets.startOffset + settings.delay, 0, settings.spacing)
        end
    else
        imgui.Text("select note to place sv :)")
    end

    saveStateVariables("fixed_random", settings)
end
