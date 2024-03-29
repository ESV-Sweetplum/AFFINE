function InputIntWrapper(label, v, tooltip)
    _, v = imgui.InputInt(label, v, 0, 0)
    return v
end

function InputFloatWrapper(label, v, tooltip)
    _, v = imgui.InputFloat(label, v, 0, 0, "%.2f")
    return v
end

function InputTextWrapper(label, v, tooltip)
    _, v = imgui.InputText(label, v, 6942)
    return v
end

function InputInt2Wrapper(label, v, tooltip)
    _, v = imgui.InputInt2(label, v)
    return v
end

function CheckboxWrapper(label, v, tooltip)
    imgui.SameLine(0, 7.5)
    _, v = imgui.Checkbox(label, v)
    return v
end
