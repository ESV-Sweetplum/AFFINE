function RadioBoolean(labelFalse, labelTrue, v, tooltip)
    if imgui.RadioButton(labelFalse, not v) then
        v = false
    end

    imgui.SameLine(0, 7.5)

    if imgui.RadioButton(labelTrue, v) then
        v = true
    end

    return v
end
