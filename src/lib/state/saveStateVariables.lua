---Saves all stateinformation about a table within state.
---@param menu string # The name of the menu.
---@param variables table # The table to save into state.
function saveStateVariables(menu, variables)
    for key in pairs(variables) do
        state.SetValue(menu .. key, variables[key])
    end
end
