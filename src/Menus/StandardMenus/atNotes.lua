function StandardAtNotesMenu()
    local offsets = getSelectedOffsets()

    if NoteActivated(offsets) then
        local lines = {}

        if (type(offsets) == "integer") then return end

        for _, offset in pairs(offsets) do
            lines = concatTables(lines, keepColorLine(offset))
        end

        lines = cleanLines(lines, offsets[1], offsets[#offsets] + 10)

        actions.PlaceTimingPointBatch(lines)
    end
end
