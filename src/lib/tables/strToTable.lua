local separatorTable = { " ", "!", "@", "#", "$", "%", "^", "&" }

---Transforms an encoded string into a table.
---@param str string # The string to convert.
---@param nestingIdx? number # The current depth of the tabular search.
---@return table
function strToTable(str, nestingIdx)
    local tbl = {}
    local nestingIdx = nestingIdx or 0

    for kvPair in str:gmatch("[^" .. separatorTable[nestingIdx + 1] .. "]+") do
        if kvPair:match("^{.+}$") then
            table.insert(tbl, strToTable(kvPair:sub(2, kvPair:len() - 1), nestingIdx + 1))
        else
            if (kvPair:find("^(%w+)=(%S+)$")) then
                k, v = kvPair:match("^(%w+)=(%S+)$")
                if v:match("^{.+}$") then
                    tbl[k] = strToTable(v:sub(2, v:len() - 1), nestingIdx + 1)
                else
                    tbl[k] = v
                end
            else
                table.insert(tbl, kvPair)
            end
        end
    end

    return tbl
end
