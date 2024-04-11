---Saves parameters for a certain menu.
---@param menu string
---@param parameterTable Parameter[]
function saveParameters(menu, parameterTable)
    for idx, tbl in ipairs(parameterTable) do
        state.setValue(menu .. idx .. tbl.key, tbl.value)
    end
end
