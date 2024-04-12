---@diagnostic disable: need-check-nil, inject-field
function CopyAndPasteMenu()
    local offsets = getStartAndEndNoteOffsets()

    local tbl = {
        storedLines = {},
        storedSVs = {}
    }

    retrieveStateVariables("CopyAndPaste", tbl)

    if RangeActivated(offsets, "Copy") then
        if (type(offsets) == "integer") then return end

        local lines = getLinesInRange(offsets.startOffset, offsets.endOffset)

        local svs = getSVsInRange(offsets.startOffset, offsets.endOffset)

        local zeroOffsetLines = {}
        local zeroOffsetSVs = {}

        for _, givenLine in pairs(lines) do
            table.insert(zeroOffsetLines,
                line(givenLine.StartTime - offsets.startOffset, givenLine.Bpm, givenLine.Hidden))
        end

        for _, givenSV in pairs(svs) do
            table.insert(zeroOffsetSVs, sv(givenSV.StartTime - offsets.startOffset, givenSV.Multiplier))
        end

        tbl.storedLines = zeroOffsetLines
        tbl.storedSVs = zeroOffsetSVs
    end

    if (#tbl.storedLines > 0 or #tbl.storedSVs > 0) then
        if NoteActivated(offsets, "Paste") then
            if (type(offsets) == "integer") then return end

            local linesToAdd = {}
            local svsToAdd = {}

            for _, storedLine in pairs(tbl.storedLines) do
                table.insert(linesToAdd,
                    line(storedLine.StartTime + offsets.startOffset, storedLine.Bpm, storedLine.Hidden))
            end
            for _, storedSV in pairs(tbl.storedSVs) do
                table.insert(svsToAdd, sv(storedSV.StartTime + offsets.startOffset, storedSV.Multiplier))
            end

            actions.PerformBatch({
                utils.CreateEditorAction(action_type.AddTimingPointBatch, linesToAdd),
                utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svsToAdd),
            })
        end
    end

    addSeparator()

    imgui.Text(#tbl.storedLines .. " Stored Lines // " .. #tbl.storedSVs .. " Stored SVs")
    saveStateVariables("CopyAndPaste", tbl)
end
