---Returns true if the table contains the specified element.
---@param table table
---@param element any
---@return boolean
---@diagnostic disable-next-line: duplicate-set-field
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end
