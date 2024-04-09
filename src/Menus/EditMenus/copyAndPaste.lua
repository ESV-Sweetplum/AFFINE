function CopyAndPasteMenu()
    local offsets = getStartAndEndNoteOffsets()

    local storedLines = state.GetValue("storedLines") or {}
    local storedSVs = state.GetValue("storedSVs") or {}

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
        imgui.Text("hi 3")

        for _, givenSV in pairs(svs) do
            table.insert(zeroOffsetSVs, sv(givenSV.StartTime - offsets.startOffset, givenSV.Multiplier))
        end
        imgui.Text("hi 4")

        state.SetValue("storedLines", zeroOffsetLines)
        state.SetValue("storedSVs", zeroOffsetSVs)
        imgui.Text("hi 5")
    end

    if (#storedLines or #storedSVs) then
        if NoteActivated(offsets, "Paste") then
            if (type(offsets) == "integer") then return end

            local linesToAdd = {}
            local svsToAdd = {}

            for _, storedLine in pairs(storedLines) do
                table.insert(linesToAdd,
                    line(storedLine.StartTime + offsets.startOffset, storedLine.Bpm, storedLine.Hidden))
            end
            for _, storedSV in pairs(storedSVs) do
                table.insert(svsToAdd, sv(storedSV.StartTime + offsets.startOffset, storedSV.Multiplier))
            end

            actions.PerformBatch({
                utils.CreateEditorAction(action_type.AddTimingPointBatch, linesToAdd),
                utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svsToAdd),
            })
        end
    end

    addSeparator()

    imgui.Text(#storedLines .. " Stored Lines // " .. #storedSVs .. " Stored SVs")
end
