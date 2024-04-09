---Gets all selected note offsets, with no duplicate values.
---@return -1 | integer[]
function getSelectedOffsets()
    local offsets = {}

    if (#state.SelectedHitObjects == 0) then
        return -1
    end

    for _, hitObject in pairs(state.SelectedHitObjects) do
        if (table.contains(offsets, hitObject.StartTime)) then goto continue end
        table.insert(offsets, hitObject.StartTime)
        ::continue::
    end

    return offsets
end
