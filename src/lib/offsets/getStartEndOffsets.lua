---Gets the first and last note offsets.
---@return {startOffset: integer, endOffset: integer}
function getStartAndEndNoteOffsets()
    local offsets = {}

    if (#state.SelectedHitObjects == 0) then
        return { startOffset = -1, endOffset = -1 }
    end


    for _, hitObject in pairs(state.SelectedHitObjects) do
        if (table.contains(offsets, hitObject.StartTime)) then goto continue end
        table.insert(offsets, hitObject.StartTime)
        ::continue::
    end

    if (#offsets == 1) then
        return { startOffset = offsets[1], endOffset = -1 }
    end

    return { startOffset = math.min(table.unpack(offsets)), endOffset = math.max(table.unpack(offsets)) }
end
