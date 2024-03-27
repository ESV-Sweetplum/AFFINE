function getOffsets()
    local offsets = {}

    if (#state.SelectedHitObjects == 0) then
        return -1
    end

    for i, hitObject in pairs(state.SelectedHitObjects) do
        table.insert(offsets, hitObject.StartTime)
    end

    return offsets
end
