function StandardAtNotesMenu(preservationType)
    local offsets = getSelectedOffsets()

    if NoteActivated(offsets) then
        local lines = {}

        if (type(offsets) == "integer") then return end

        if (preservationType == 1) then -- PRESERVE SNAP
            for _, offset in pairs(offsets) do
                lines = concatTables(lines, keepColorLine(offset))
            end
        else -- PRESERVE LOCATION
            for _, offset in pairs(offsets) do
                table.insert(lines, line(offset))
            end
        end
        lines = cleanLines(lines, offsets[1], offsets[#offsets] + 10)

        actions.PlaceTimingPointBatch(lines)
    end
end
