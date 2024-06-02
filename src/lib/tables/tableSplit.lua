---Takes a string, and splits it using a predicate. Similar to Array.split().
---@param str string # The string to split.
---@param predicate string # The search group to split by.
---@return table
function table.split(str, predicate)
    t = {}

    for i in string.gmatch(str, predicate) do
        t[#t + 1] = i
    end

    return t
end
