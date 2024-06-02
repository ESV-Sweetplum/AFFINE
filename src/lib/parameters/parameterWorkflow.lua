---Provide a menu name and parameter options, and this workflow will automatically manage state, generate input fields, and handle setting conversion.
---@param name string # The name of the current menu. Used for separating state between menus.
---@param ... string | table # The name of the given setting, or a table representing a custom parameter.
---@return table
function parameterWorkflow(name, ...)
    local parameterTable = constructParameters(...)

    retrieveParameters(name, parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)

    saveParameters(name, parameterTable)

    return settings
end
