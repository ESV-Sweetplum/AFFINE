function BasicManualAnimationMenu()
    local settings = {
        startStr            = "69 420 727 1337",
        endStr              = "69 420 727 1337",
        progressionExponent = 1,
        spacing             = DEFAULT_SPACING,
        fps                 = DEFAULT_FPS,
        debug               = 'Lines // SVs'
    }

    retrieveStateVariables("animation_manual", settings)

    _, settings.startStr = imgui.InputText("Start Keyframes", settings.startStr, 6942)
    _, settings.endStr = imgui.InputText("End Keyframes", settings.endStr, 6942)
    _, settings.progressionExponent = imgui.InputFloat("Progression Exponent", settings.progressionExponent)

    _, settings.fps = imgui.InputFloat("Animation FPS", settings.fps)
    _, settings.spacing = imgui.InputFloat("MS Spacing", settings.spacing)

    local offsets = getStartAndEndNoteOffsets()

    if rangeActivated(offsets) then
        startMsxTable = strToTable(settings.startStr, "%S+")
        endMsxTable = strToTable(settings.endStr, "%S+")

        local currentTime = offsets.startOffset + 1
        local iterations = 0
        local lines = {}
        local svs = {}

        while (currentTime < offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset) ^
                (1 / settings.progressionExponent)

            local msxTable = {}

            for i = 1, #endMsxTable do
                table.insert(msxTable, mapProgress(startMsxTable[i], progress, endMsxTable[i]))
            end

            local tbl = tableToLines(msxTable, currentTime, 0, settings.spacing)

            if (tbl.time > offsets.endOffset) then break end

            currentTime = math.max(currentTime + (1000 / settings.fps) - 2, tbl.time)

            lines = concatTables(lines, tbl.lines)
            svs = concatTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, 1000)

            currentTime = currentTime + 2
        end

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset)

        settings.debug = #lines .. " // " .. #svs
    end

    saveStateVariables("animation_manual", settings)
end
