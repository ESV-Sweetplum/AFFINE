function FlashbangMenu()
    local settings = parameterWorkflow("fixed_automatic", 'msxBounds', 'distance', 'delay', 'spacing')

    if NoteActivated() then
        local tbl = placeAutomaticFrame(offsets.startOffset + settings.delay, settings.msxBounds[1],
            settings.msxBounds[2],
            settings.spacing, settings.distance)

        tbl.svs = insertTeleport(tbl.svs, offsets.startOffset, -10000000, 0)
        tbl.svs = insertTeleport(tbl.svs, (offsets.startOffset + offsets.endOffset) / 2, 10000000 + (offsets.endOffset - offsets.startOffset) / 2, 1)

        generateAffines(tbl.lines, tbl.svs, offsets.startOffset, offsets.endOffset, "Flashbang")
        setDebug("Line Count: " .. #tbl.lines .. " // SV Count: " .. #tbl.svs)
    end
end