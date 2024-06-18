---Gets the first and last note offsets.
---@return {startOffset: integer, endOffset: integer}
function getStartAndEndNoteOffsets()
    local startOffset = 1 / 0
    local endOffset = -1 / 0

    if (#state.SelectedHitObjects == 0) then
        return { startOffset = -1, endOffset = -1 }
    end

    for _, hitObject in pairs(state.SelectedHitObjects) do
        if (hitObject.StartTime < startOffset) then startOffset = hitObject.startTime end
        if (hitObject.StartTime > endOffset) then endOffset = hitObject.startTime end
    end

    if (startOffset == endOffset) then
        return { startOffset = startOffset, endOffset = -1 }
    end

    return { startOffset = startOffset, endOffset = endOffset }
end
