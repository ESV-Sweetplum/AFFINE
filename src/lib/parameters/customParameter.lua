---Function wrapper for custom parameters.
---@param inputType inputType
---@param label string | string[]
---@param key string
---@param value any
---@param sameLine? boolean
---@return table
function customParameter(inputType, label, key, value, sameLine)
    return {
        inputType = inputType,
        label = label,
        key = key,
        value = value,
        sameLine = sameLine or false
    }
end
