function IncrementalAnimationMenu()
    local settings = {
        msxList = "50 100 150 200",
        spacing = DEFAULT_SPACING,
        bounce = false,
        allLinesVisible = true
    }

    local parameterTable = constructParameters('msxList', 'spacing', {
        inputType = "RadioBoolean",
        key = "bounce",
        label = { "12341234", "1234321" },
        value = false
    }, {
        inputType = "Checkbox",
        key = "allLinesVisible",
        label = "All Lines Visible?",
        value = true
    })

    retrieveParameters("animation_incremental", parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)

    local offsets = getStartAndEndNoteOffsets()

    if rangeActivated(offsets) then
        local times = getSelectedOffsets()

        local currentIndex = 1
        local currentHeight = 1

        local currentAddition = 1

        local totalMsxTable = strToTable(settings.msxList, "%S+")
        local MAX_HEIGHT = #totalMsxTable

        local lines = {}
        local svs = {}

        while (currentIndex <= #times) do
            local currentTime = times[currentIndex] + 1

            local msxTable = {}

            if (settings.allLinesVisible) then
                for i = 1, currentHeight do
                    table.insert(msxTable, totalMsxTable[i])
                end
            else
                table.insert(msxTable, totalMsxTable[currentHeight])
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

    saveParameters("animation_incremental", parameterTable)
end
