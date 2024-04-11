local separatorTable = { " ", "!", "@", "#", "$", "%", "^", "&" }

function tableToStr(tbl, nestingIdx)
    local str = ""
    local nestingIdx = nestingIdx or 0


    for k, v in pairs(tbl) do
        local value

        if (type(v) == "table") then
            value = "{" .. tableToStr(v, nestingIdx + 1) .. "}"
        else
            value = v
        end
        if (type(k) == "number") then
            str = str .. value .. separatorTable[nestingIdx + 1]
        else
            str = str .. k .. "=" .. value .. separatorTable[nestingIdx + 1]
        end
    end
    return str:sub(1, str:len() - 1)
end
