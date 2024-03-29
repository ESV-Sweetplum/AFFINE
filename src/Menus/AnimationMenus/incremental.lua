function IncrementalAnimationMenu()
    local settings = {
        inputStr = "50 100 150 200",
        spacing = DEFAULT_SPACING,
        bounce = false
    }

    retrieveStateVariables("animation_incremental", settings)

    _, settings.inputStr = imgui.InputText("List", settings.inputStr, 6942)
    _, settings.spacing = imgui.InputFloat("MS Spacing", settings.spacing)

    if imgui.RadioButton("12341234", not settings.bounce) then
        settings.bounce = false
    end

    imgui.SameLine(0, 7.5)

    if imgui.RadioButton("1234321", settings.bounce) then
        settings.bounce = true
    end

    local offsets = getStartAndEndNoteOffsets()

    if rangeActivated(offsets) then
        local times = getSelectedOffsets()

        local currentIndex = 1
        local currentHeight = 1

        local currentAddition = 1

        local totalMsxTable = strToTable(settings.inputStr, "%S+")
        local MAX_HEIGHT = #totalMsxTable

        local lines = {}
        local svs = {}

        while (currentIndex <= #times) do
            local currentTime = times[currentIndex] + 1

            local msxTable = {}

            for i = 1, currentHeight do
                table.insert(msxTable, totalMsxTable[i])
            end

            local tbl = tableToLines(msxTable, currentTime + 5, 0, settings.spacing)

            lines = concatTables(lines, tbl.lines)
            svs = concatTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, 1000)

            currentIndex = currentIndex + 1

            if (settings.bounce) then
                if (currentHeight == MAX_HEIGHT) then
                    currentAddition = -1
                elseif (currentHeight == 1) then
                    currentAddition = 1
                end
                currentHeight = currentHeight + currentAddition
            else
                if (currentHeight == MAX_HEIGHT) then
                    currentHeight = 1
                else
                    currentHeight = currentHeight + 1
                end
            end
        end

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset)
    end

    saveStateVariables("animation_incremental", settings)
end
