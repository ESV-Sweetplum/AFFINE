---@diagnostic disable: return-type-mismatch
---Creates an `imgui.Button` with the action "{action} {object}s.".
---@param action? string # The action the button will perform (e.g. `Place`, `Remove`, etc.)
---@param object? string # The object group to perform it on (e.g. `Lines`, `SVs`, etc.)
---@return boolean
function activationButton(action, object)
    action = action or "Place"
    object = object or "Lines"
    return imgui.Button(action .. " " .. object)
end

---Returns a boolean if a range is selected, and a corresponding button is activated.
---@param action? string # The action the button will perform (e.g. `Place`, `Remove`, etc.)
---@param object? string # The object group to perform it on (e.g. `Lines`, `SVs`, etc.)
---@return boolean
function RangeActivated(action, object)
    action = action or "Place"
    object = object or "Lines"
    if rangeSelected() then
        return activationButton(action) or (utils.IsKeyPressed(keys.A) and not utils.IsKeyDown(keys.LeftControl))
    else
        imgui.Text("Select a Region to " .. action .. " " .. object .. ".")
        return false
    end
end

---Returns a boolean if a note is selected, and a corresponding button is activated.
---@param action? string # The action the button will perform (e.g. `Place`, `Remove`, etc.)
---@param object? string # The object group to perform it on (e.g. `Lines`, `SVs`, etc.)
---@return boolean
function NoteActivated(action, object)
    action = action or "Place"
    object = object or "Lines"
    if noteSelected() then
        return activationButton(action) or (utils.IsKeyPressed(keys.A) and not utils.IsKeyDown(keys.LeftControl))
    else
        return imgui.Text("Select a Note to " .. action .. " " .. object .. ".")
    end
end
