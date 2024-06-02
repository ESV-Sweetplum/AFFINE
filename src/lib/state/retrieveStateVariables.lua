---Gets all state stored information about a table.
---@param menu string # The name of the menu.
---@param variables table # The table to pull information for.
function retrieveStateVariables(menu, variables)
    for key in pairs(variables) do
        if (state.GetValue(menu .. key) ~= nil) then
            variables[key] = state.GetValue(menu .. key)
        end
    end
end
