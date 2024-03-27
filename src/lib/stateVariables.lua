function retrieveStateVariables(menu, variables)
    for key in pairs(variables) do
        if (state.GetValue(menu..key) ~= nil) then
            variables[key] = state.GetValue(menu..key)
        end
    end
end

function saveStateVariables(menu, variables)
    for key in pairs(variables) do
        state.SetValue(menu..key, variables[key])
    end
end