---Takes a string, and splits it using a predicate. Similar to Array.split().
---@param str string
---@param predicate string
---@return table
function strToTable(str, predicate)
    t = {}

    for i in string.gmatch(str, predicate) do
        t[#t + 1] = i
    end

    return t
end
