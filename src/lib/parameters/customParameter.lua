---Function wrapper for custom parameters.
---@param inputType inputType # The name of the data type used for the input.
---@param label string | string[] # The label of the input.
---@param key string # The variable name that will be used as a key in the `settings` table.
---@param value any # The initial value of this input.
---@param sameLine? boolean # Determines whether or not this input is on the same line as the previous input.
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
