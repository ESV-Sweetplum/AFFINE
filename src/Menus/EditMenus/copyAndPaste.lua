---@diagnostic disable: need-check-nil, inject-field
function CopyAndPasteMenu()
    local settings = parameterWorkflow("copy_and_paste", {
        inputType = "Checkbox",
        key = "includeBM",
        label = "Include Bookmarks?",
        value = true
    })

    local tbl = {
        storedLines = {},
        storedSVs = {},
        storedBookmarks = {}
    }

    retrieveStateVariables("CopyAndPaste", tbl)

    if RangeActivated("Copy") then
        if (type(offsets) == "integer") then return end

        local lines = getLinesInRange(offsets.startOffset, offsets.endOffset)

        local svs = getSVsInRange(offsets.startOffset, offsets.endOffset)

        local bookmarks = getBookmarksInRange(offsets.startOffset, offsets.endOffset)

        local zeroOffsetLines = {}
        local zeroOffsetSVs = {}
        local zeroOffsetBookmarks = {}

        for _, givenLine in pairs(lines) do
            table.insert(zeroOffsetLines,
                line(givenLine.StartTime - offsets.startOffset, givenLine.Bpm, givenLine.Hidden))
        end

        for _, givenSV in pairs(svs) do
            table.insert(zeroOffsetSVs, sv(givenSV.StartTime - offsets.startOffset, givenSV.Multiplier))
        end

        for _, givenBookmark in pairs(bookmarks) do
            table.insert(zeroOffsetBookmarks, bookmark(givenBookmark.StartTime - offsets.startOffset, givenBookmark.Note))
        end

        tbl.storedLines = zeroOffsetLines
        tbl.storedSVs = zeroOffsetSVs
        if (settings.includeBM) then tbl.storedBookmarks = zeroOffsetBookmarks end
    end

    if (#tbl.storedLines > 0 or #tbl.storedSVs > 0) then
        if NoteActivated("Paste") then
            if (type(offsets) == "integer") then return end

            local linesToAdd = {}
            local svsToAdd = {}
            local bookmarksToAdd = {}

            for _, storedLine in pairs(tbl.storedLines) do
                table.insert(linesToAdd,
                    line(storedLine.StartTime + offsets.startOffset, storedLine.Bpm, storedLine.Hidden))
            end
            for _, storedSV in pairs(tbl.storedSVs) do
                table.insert(svsToAdd, sv(storedSV.StartTime + offsets.startOffset, storedSV.Multiplier))
            end
            for _, storedBookmark in pairs(tbl.storedBookmarks) do
                table.insert(bookmarksToAdd,
                    bookmark(storedBookmark.StartTime + offsets.startOffset, storedBookmark.Note))
            end

            actions.PerformBatch({
                utils.CreateEditorAction(action_type.AddTimingPointBatch, linesToAdd),
                utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svsToAdd),
                utils.CreateEditorAction(action_type.AddBookmarkBatch, bookmarksToAdd),
            })
        end
    end

    addSeparator()

    imgui.Text(#tbl.storedLines ..
        " Stored Lines // " .. #tbl.storedSVs .. " Stored SVs // " .. #tbl.storedBookmarks .. " Stored Bookmarks")

    saveStateVariables("CopyAndPaste", tbl)
end
