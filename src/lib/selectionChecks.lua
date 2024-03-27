function noteSelected(offsets)
    return offsets ~= -1
end

function rangeSelected(offsets)
    return (offsets ~= -1) and (offsets.startOffset ~= offsets.endOffset) 
end