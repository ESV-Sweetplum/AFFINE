---@meta Parameter

---@class Parameter # Used for auto-state management and generating inputs.
---@field key string # The name of the variable to reference later.
---@field value any # The initial value of the parameter.
---@field inputType? string # The type of the input. (e.g. `Float` or `Int`)
---@field label? string # The label of the input.
---@field sameLine? boolean # Determines if the input is on the same line as the one before it.
---@field tooltip? string # A tooltip appended to the end of the input. Hovering over it displays this text.
