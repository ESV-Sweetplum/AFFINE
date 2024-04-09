---Outputs settings based on inputted parameters.
---@param parameterTable Parameter[]
---@return table
function parametersToSettings(parameterTable)
    local settings = {}

    for _, tbl in ipairs(parameterTable) do
        settings[tbl.key] = tbl.value
    end

    return settings
end
