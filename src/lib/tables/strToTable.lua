local separatorTable = { " ", "!", "@", "#", "$", "%", "^", "&" }

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
