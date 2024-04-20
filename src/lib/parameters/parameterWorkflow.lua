---Provide a window name and parameter options, and this workflow will automatically manage state, generate input fields, and handle setting conversion.
---@param windowName string
---@param ... string | table
function parameterWorkflow(windowName, ...)
    local parameterTable = constructParameters(...)

    retrieveParameters(windowName, parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)

    saveParameters(windowName, parameterTable)

    return settings
end
