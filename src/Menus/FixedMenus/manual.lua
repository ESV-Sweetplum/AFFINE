function FixedManualMenu()
    local settings = parameterWorkflow("fixed_manual", 'msxList', 'offset', 'delay', 'spacing')

    local offsets = getStartAndEndNoteOffsets()

    if NoteActivated(offsets) then
        msxTable = table.split(settings.msxList, "%S+")
        local tbl = tableToLines(msxTable, offsets.startOffset + settings.delay, settings.offset, settings.spacing)
        generateAffines(tbl.lines, tbl.svs, offsets.startOffset, offsets.endOffset, "Manual Fixed")

        setDebug("Line Count: " .. #tbl.lines .. " // SV Count: " .. #tbl.svs)
    end
end
