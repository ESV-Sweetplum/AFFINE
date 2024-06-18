---Gets all selected note offsets, with no duplicate values.
---@return integer[]
function getSelectedOffsets()
    local offsets = {}

    if (#state.SelectedHitObjects == 0) then
        return {}
    end

    for _, hitObject in ipairs(state.SelectedHitObjects) do
        if (table.contains(offsets, hitObject.StartTime)) then goto continue end
        table.insert(offsets, hitObject.StartTime)
        ::continue::
    end

    table.sort(offsets)

    return offsets
end
