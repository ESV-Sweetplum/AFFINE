function getSelectedOffsets()
    local offsets = {}

    if (#state.SelectedHitObjects == 0) then
        return -1
    end

    for i, hitObject in pairs(state.SelectedHitObjects) do
        if (table.contains(offsets, hitObject.StartTime)) then goto continue end
        table.insert(offsets, hitObject.StartTime)
        ::continue::
    end

    return offsets
end
