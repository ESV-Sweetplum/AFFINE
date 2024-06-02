---Converts a string separated by spaces and new lines into a 2D table.
---@param str string # The string to transform.
---@return string[][]
function strToMatrix(str)
    local finalTbl = {}
    local initTbl = table.split(str, "[^\r\n]+")
    for _, substr in pairs(initTbl) do
        table.insert(finalTbl, table.split(substr, "%S+"))
    end

    return finalTbl
end
