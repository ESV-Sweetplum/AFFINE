function FixedRandomMenu()
    local settings = parameterWorkflow("fixed_random", 'msxBounds', 'lineCount', 'delay', 'spacing')

    if NoteActivated() then
        msxTable = {}
        for _ = 1, settings.lineCount do
            table.insert(msxTable, math.random(settings.msxBounds[1], settings.msxBounds[2]))
        end
        local tbl = tableToAffineFrame(msxTable, offsets.startOffset + settings.delay, 0, settings.spacing)

        generateAffines(tbl.lines, tbl.svs, offsets.startOffset, offsets.endOffset, "Random Fixed")
        setDebug("Line Count: " .. #tbl.lines .. " // SV Count: " .. #tbl.svs)
    end
end
