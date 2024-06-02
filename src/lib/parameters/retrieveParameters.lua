---Gets parameters for a certain menu.
---@param menu string # The name of the menu.
---@param parameterTable Parameter[] # The parameter table to write to.
function retrieveParameters(menu, parameterTable)
    for idx, tbl in ipairs(parameterTable) do
        if (state.GetValue(menu .. idx .. tbl.key) ~= nil) then
            parameterTable[idx].value = state.GetValue(menu .. idx .. tbl.key)
        end
    end
end
