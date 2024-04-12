function ManualDeleteTab()
    local settings = {
        deletionType = DEFAULT_MENU_ID
    }

    retrieveStateVariables("deletion", settings)

    local deletionTypeIndex = settings.deletionType - 1
    local _, deletionTypeIndex = imgui.Combo("Deletion Type", deletionTypeIndex, DELETION_TYPE_LIST,
        #DELETION_TYPE_LIST)
    addSeparator()
    settings.deletionType = deletionTypeIndex + 1

    local offsets = getStartAndEndNoteOffsets()

    if (RangeActivated(offsets, "Remove")) then
        svs = getSVsInRange(offsets.startOffset, offsets.endOffset)
        lines = getLinesInRange(offsets.startOffset, offsets.endOffset)

        local actionTable = {}

        if (settings.deletionType % 2 ~= 0) then
            table.insert(actionTable,
                utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, svs))
        end

        if (settings.deletionType <= 2) then
            table.insert(actionTable, utils.CreateEditorAction(action_type.RemoveTimingPointBatch, lines))
        end

        actions.PerformBatch(actionTable)
    end

    saveStateVariables("deletion", settings)
end
