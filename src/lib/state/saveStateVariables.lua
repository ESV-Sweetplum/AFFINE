function saveStateVariables(menu, variables)
    for key in pairs(variables) do
        state.SetValue(menu .. key, variables[key])
    end
end
