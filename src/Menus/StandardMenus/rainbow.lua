function StandardRainbowMenu()
    local settings = parameterWorkflow("rainbow", "colorList")

    local times = getSelectedOffsets()
    if NoteActivated(times) then
        local lines = {}
        local rainbowTable = table.split(settings.colorList, "%S+")
        local rainbowIndex = 1

        if (type(times) == "integer") then return end

        local hidden = false

        for _, time in pairs(times) do
            if (rainbowIndex == 1) then hidden = false else hidden = true end
            lines = combineTables(lines, applyColorToTime(rainbowTable[rainbowIndex], time, hidden))
            rainbowIndex = rainbowIndex + 1
            if (rainbowIndex > #rainbowTable) then
                rainbowIndex = 1
            end
        end

        lines = cleanLines(lines, offsets[1] - 10, offsets[#offsets] + 10)

        actions.PlaceTimingPointBatch(lines)
    end
end
