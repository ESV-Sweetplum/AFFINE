---@diagnostic disable: cast-local-type

---Creates an `InputInt` element.
---@param label string
---@param v integer
---@param tooltip string
---@return integer
function InputIntWrapper(label, v, tooltip)
    _, v = imgui.InputInt(label, v, 0, 0)
    Tooltip(tooltip)
    ---@cast v integer
    return v
end

---Creates an `InputFloat` element.
---@param label string
---@param v number
---@param tooltip string
---@return number
function InputFloatWrapper(label, v, tooltip)
    _, v = imgui.InputFloat(label, v, 0, 0, "%.2f")
    Tooltip(tooltip)
    ---@cast v number
    return v
end

---Creates an `InputText` element.
---@param label string
---@param v string
---@param tooltip string
---@return string
function InputTextWrapper(label, v, tooltip)
    _, v = imgui.InputText(label, v, 6942)
    Tooltip(tooltip)
    ---@cast v string
    return v
end

---Creates an `InputTextMultiline` element.
---@param label string
---@param v string
---@param tooltip string
---@return string
function InputTextMultilineWrapper(label, v, tooltip)
    _, v = imgui.InputTextMultiline(label, v, 6942)
    Tooltip(tooltip)
    ---@cast v string
    return v
end

---Creates an `InputInt2` element.
---@param label string
---@param v integer[]
---@param tooltip string
---@return integer[]
function InputInt2Wrapper(label, v, tooltip)
    _, v = imgui.InputInt2(label, v)
    Tooltip(tooltip)
    ---@cast v integer[]
    return v
end

---Creates an `InputInt3` element.
---@param label string
---@param v integer[]
---@param tooltip string
---@return integer[]
function InputInt3Wrapper(label, v, tooltip)
    _, v = imgui.InputInt3(label, v)
    Tooltip(tooltip)
    ---@cast v integer[]
    return v
end

---Creates an `InputInt4` element.
---@param label string
---@param v integer[]
---@param tooltip string
---@return integer[]
function InputInt4Wrapper(label, v, tooltip)
    _, v = imgui.InputInt4(label, v)
    Tooltip(tooltip)
    ---@cast v integer[]
    return v
end

---Creates an `InputFloat2` element.
---@param label string
---@param v number[]
---@param tooltip string
---@return number[]
function InputFloat2Wrapper(label, v, tooltip)
    _, v = imgui.InputFloat2(label, v, "%.2f")
    Tooltip(tooltip)
    ---@cast v number[]
    return v
end

---Creates an `InputFloat3` element.
---@param label string
---@param v number[]
---@param tooltip string
---@return number[]
function InputFloat3Wrapper(label, v, tooltip)
    _, v = imgui.InputFloat3(label, v, "%.2f")
    Tooltip(tooltip)
    ---@cast v number[]
    return v
end

---Creates an `InputFloat4` element.
---@param label string
---@param v number[]
---@param tooltip string
---@return number[]
function InputFloat4Wrapper(label, v, tooltip)
    _, v = imgui.InputFloat4(label, v, "%.2f")
    Tooltip(tooltip)
    ---@cast v number[]
    return v
end

---Creates an `Checkbox` element.
---@param label string
---@param v boolean
---@param tooltip string
---@return boolean
function CheckboxWrapper(label, v, tooltip, sameLine)
    if (sameLine) then imgui.SameLine(0, 7.5) end
    _, v = imgui.Checkbox(label, v)
    Tooltip(tooltip)
    ---@cast v boolean
    return v
end

---Creates an `SliderInt` element.
---@param label string
---@param v integer
---@param limits integer[]
---@param tooltip" string
---@return integer
function SliderIntWrapper(label, v, limits, tooltip)
    _, v = imgui.SliderInt(label, v, limits[1], limits[2])
    Tooltip(tooltip)
    ---@cast v integer
    return v
end
