function ConvergeDivergeMenu()
    local parameterTable = constructParameters("center", "maxSpread", "lineCount", "lineDuration", "progressionExponent",
        "spacing", "pathCoefficients")

    retrieveParameters("animation_convergeDiverge", parameterTable)

    parameterInputs(parameterTable)

    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if RangeActivated(offsets) then
        local currentTime = offsets.startOffset + 1

        local iterations = 0
        local lines = {}
        local svs = {}
        local frameLengths = {}

        while ((currentTime + (2 / INCREMENT)) <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            -- do something
            iterations = iterations + 1
        end

        local stats = getStatisticsFromTable(frameLengths)

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset, "Converge/Diverge",
            constructDebugTable(lines, svs, stats))
        parameterTable[#parameterTable].value = "Line Count: " .. #lines .. " // SV Count: " .. #svs
    end
    Plot(settings.pathCoefficients, settings.progressionExponent)

    saveParameters("animation_convergeDiverge", parameterTable)
end
