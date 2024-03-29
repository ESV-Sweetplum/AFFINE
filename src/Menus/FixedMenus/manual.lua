function FixedManualMenu()
    local parameterTable = constructParameters('msxList', 'offset', 'delay', 'spacing', {
        type = "Radio",
        key = "Your mother",
        defaultValue = false
    })

    retrieveParameters("fixed_manual", parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if noteActivated(offsets) then
        msxTable = strToTable(settings.msxList, "%S+")
        local tbl = tableToLines(msxTable, offsets.startOffset + settings.delay, settings.offset, settings.spacing)
        generateAffines(tbl.lines, tbl.svs, offsets.startOffset)
    end

    saveParameters("fixed_manual", parameterTable)
end
