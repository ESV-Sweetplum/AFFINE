---Returns true if a note is selected.
---@param offsets any
---@return boolean
function noteSelected(offsets)
    return offsets ~= -1
end

---Returns true if two or more notes are selected, with differing offsets.
---@param offsets any
---@return boolean
function rangeSelected(offsets)
    return (offsets ~= -1) and (offsets.startOffset ~= offsets.endOffset) 
end
