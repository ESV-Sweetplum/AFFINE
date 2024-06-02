---Creates two radio buttons, one for true and one for false.
---@param labelFalse string # Label for the radio button corresponding to `false`.
---@param labelTrue string # Label for the radio button corresponding to `true`.
---@param v boolean # The value of the current variable.
---@return boolean
function RadioBoolean(labelFalse, labelTrue, v)
    if imgui.RadioButton(labelFalse, not v) then
        v = false
    end

    imgui.SameLine(0, 7.5)

    if imgui.RadioButton(labelTrue, v) then
        v = true
    end

    return v
end
