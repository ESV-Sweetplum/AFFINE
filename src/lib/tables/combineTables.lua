---Joins two table entries together into one table.
---@param t1 table # The first table.
---@param t2 table # The second table.
---@return table
function combineTables(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i]
    end
    return t1
end
