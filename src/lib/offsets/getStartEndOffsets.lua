function getStartAndEndNoteOffsets()
    local offsets = {}

    if (#state.SelectedHitObjects == 0) then
        return -1
    end

    for i, hitObject in pairs(state.SelectedHitObjects) do
        offsets[i] = hitObject.StartTime
    end

    return { startOffset = math.min(table.unpack(offsets)), endOffset = math.max(table.unpack(offsets)) }
end
