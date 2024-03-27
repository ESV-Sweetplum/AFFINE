function FixedManualMenu()
    local settings = {
        offset = DEFAULT_OFFSET,
        delay = DEFAULT_DELAY,
        inputStr = "69 420 727 1337",
        spacing = DEFAULT_SPACING
    }

    retrieveStateVariables("fixed_manual", settings)

    _, settings.inputStr = imgui.InputText("List", settings.inputStr, 6942)
    _, settings.offset = imgui.InputInt("MSX Offset", settings.offset)
    _, settings.delay = imgui.InputInt("Delay", settings.delay)
    _, settings.spacing = imgui.InputFloat("MS Spacing", settings.spacing)

    local offsets = getStartAndEndNoteOffsets()

    if noteSelected(offsets) then
        local activationButton = imgui.Button("Place the shit")

        if (activationButton) then
            msxTable = strToTable(settings.inputStr, "%S+")
            placeFixedLines(msxTable, offsets.startOffset + settings.delay, settings.offset, settings.spacing)
        end
    else
        imgui.Text("select note to place sv :)")
    end

    saveStateVariables("fixed_manual", settings)
end
