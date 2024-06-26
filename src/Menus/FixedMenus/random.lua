function FixedRandomMenu()
    local parameterTable = constructParameters('msxBounds', 'lineCount', 'delay', 'spacing')

    retrieveParameters("fixed_random", parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)

    local offsets = getStartAndEndNoteOffsets()

    if NoteActivated(offsets) then
        msxTable = {}
        for _ = 1, settings.lineCount do
            table.insert(msxTable, math.random(settings.msxBounds[1], settings.msxBounds[2]))
        end
        local tbl = tableToLines(msxTable, offsets.startOffset + settings.delay, 0, settings.spacing)

        generateAffines(tbl.lines, tbl.svs, offsets.startOffset, offsets.endOffset)
        parameterTable[#parameterTable].value = "Line Count: " .. #tbl.lines .. " // SV Count: " .. #tbl.svs
    end


    saveParameters("fixed_random", parameterTable)
end
