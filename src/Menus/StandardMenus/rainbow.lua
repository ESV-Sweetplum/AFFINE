function StandardRainbowMenu()
    local offsets = getSelectedOffsets()

    local rainbowTable = { 1, 8, 4, 16, 2, 12, 3, 6 }

    if NoteActivated(offsets) then
        local lines = {}
        local rainbowIndex = 1

        if (type(offsets) == "integer") then return end

        local hidden = false

        for _, offset in pairs(offsets) do
            if (rainbowIndex == 1) then hidden = false else hidden = true end
            lines = concatTables(lines, applyColorToTime(rainbowTable[rainbowIndex], offset, hidden))
            rainbowIndex = rainbowIndex + 1
            if (rainbowIndex > 8) then
                rainbowIndex = 1
            end
        end

        lines = cleanLines(lines, offsets[1], offsets[#offsets] + 10)

        actions.PlaceTimingPointBatch(lines)
    end
end
