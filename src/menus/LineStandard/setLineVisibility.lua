function SetVisibilityMenu()
    local settings = parameterWorkflow("standard_setVisibility", {
        inputType = "RadioBoolean",
        key = "enable",
        label = { "Turn Lines Invisible", "Turn Lines Visible" },
        value = false
    })

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
