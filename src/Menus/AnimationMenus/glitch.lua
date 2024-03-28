function GlitchMenu()
    local settings = {
        msxBounds = DEFAULT_MSX_BOUNDS,
        msxBounds2 = DEFAULT_MSX_BOUNDS,
        spacing = DEFAULT_SPACING,
        lineCount = DEFAULT_LINE_COUNT,
        fps = DEFAULT_FPS,
        debug = 'Lines // SVs'
    }

    retrieveStateVariables("glitch", settings)

    _, settings.msxBounds = imgui.InputInt2("Start Lower/Upper MSX", settings.msxBounds)
    _, settings.msxBounds2 = imgui.InputInt2("End Lower/Upper MSX", settings.msxBounds2)
    _, settings.lineCount = imgui.InputInt("Line Count", settings.lineCount)

    _, settings.fps = imgui.InputFloat("Animation FPS", settings.fps)
    _, settings.spacing = imgui.InputFloat("MS Spacing", settings.spacing)

    local offsets = getStartAndEndNoteOffsets()

    if rangeActivated(offsets) then
        local currentTime = offsets.startOffset
        local lines = {}
        local svs = {}

        while (currentTime <= offsets.endOffset) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset)

            local lowerBound = mapProgress(settings.msxBounds[1], progress, settings.msxBounds2[1])
            local upperBound = mapProgress(settings.msxBounds[2], progress, settings.msxBounds2[2])

            msxTable = {}
            for i = 1, settings.lineCount do
                table.insert(msxTable, math.random(upperBound, lowerBound))
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

    imgui.Text(settings.debug)

    saveStateVariables("glitch", settings)
end
