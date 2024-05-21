---@diagnostic disable: undefined-field
function AddForefrontTeleportMenu()
    local settings = parameterWorkflow("edit_addForefrontTeleport", "msxList")

    if NoteActivated() then
        local offsets = getSelectedOffsets()

        local svs = {}
        local msxList = table.split(settings.msxList, "%S+")

        local mostRecentSV = map.GetScrollVelocityAt(offsets[1]).Multiplier

        for idx, v in pairs(offsets) do
            svs = insertTeleport(svs, v - 1, tonumber(msxList[(idx - 1) % #msxList + 1]), mostRecentSV)
        end

        actions.Perform(utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs))
    end
end
