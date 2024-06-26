function StandardRainbowMenu()
    local parameterTable = constructParameters("colorList")

    retrieveParameters("rainbow", parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)
    local offsets = getSelectedOffsets()
    if NoteActivated(offsets) then
        local lines = {}
        local rainbowTable = strToTable(settings.colorList, "%S+")
        local rainbowIndex = 1

        if (type(offsets) == "integer") then return end

        local hidden = false

        for _, offset in pairs(offsets) do
            if (rainbowIndex == 1) then hidden = false else hidden = true end
            lines = concatTables(lines, applyColorToTime(rainbowTable[rainbowIndex], offset, hidden))
            rainbowIndex = rainbowIndex + 1
            if (rainbowIndex > #rainbowTable) then
                rainbowIndex = 1
            end
        end

        lines = cleanLines(lines, offsets[1] - 10, offsets[#offsets] + 10)

        actions.PlaceTimingPointBatch(lines)
    end

    saveParameters("rainbow", parameterTable)
end
