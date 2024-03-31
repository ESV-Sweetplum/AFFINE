function StandardAtNotesMenu()
    local offsets = getSelectedOffsets()

    local color = state.GetValue("color") or 69

    imgui.Text(color)

    if NoteActivated(offsets) then
        local lines = {}

        if (type(offsets) == "integer") then return end

        for _, offset in pairs(offsets) do
            color = colorFromTime(offset)
            lines = concatTables(lines, applyColorToTime(color, offset))
        end

        lines = cleanLines(lines, offsets[1], offsets[#offsets] + 10)

        actions.PlaceTimingPointBatch(lines)
    end

    state.SetValue("color", color)
end
