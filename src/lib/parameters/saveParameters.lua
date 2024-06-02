---Saves parameters for a certain menu.
---@param menu string # The name of the menu.
---@param parameterTable Parameter[] # The parameter table to save.
function saveParameters(menu, parameterTable)
    for idx, tbl in ipairs(parameterTable) do
        state.setValue(menu .. idx .. tbl.key, tbl.value)
    end
end
