---Returns true if a note is selected.
---@return boolean
function noteSelected()
    return offsets.startOffset ~= -1
end

---Returns true if two or more notes are selected, with differing offsets.
---@return boolean
function rangeSelected()
    return offsets.endOffset ~= -1
end
