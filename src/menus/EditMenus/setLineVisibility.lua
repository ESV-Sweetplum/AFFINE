function SetVisibilityMenu()
    local settings = parameterWorkflow("edit_setVisibility",
        customParameter("RadioBoolean", { "Turn Lines Invisible", "Turn Lines Visible" }, "enable", false))

    if NoteActivated() then
        local linesToRemove = getLinesInRange(offsets.startOffset, offsets.endOffset)

        local linesToAdd = {}

        for _, currentLine in pairs(linesToRemove) do
            table.insert(linesToAdd, line(currentLine.StartTime, currentLine.Bpm, not settings.enable))
        end

        actions.PerformBatch({
            utils.CreateEditorAction(action_type.RemoveTimingPointBatch, linesToRemove),
            utils.CreateEditorAction(action_type.AddTimingPointBatch, linesToAdd)
        })
    end
end
