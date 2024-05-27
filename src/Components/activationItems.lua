function activationButton(text)
    text = text or "Place"
    return imgui.Button(text .. " Lines")
end

function RangeActivated(text, item)
    text = text or "Place"
    item = item or "Lines"
    if rangeSelected() then
        return activationButton(text) or (utils.IsKeyPressed(keys.A) and not utils.IsKeyDown(keys.LeftControl))
    else
        return imgui.Text("Select a Region to " .. text .. " " .. item .. ".")
    end
end

function NoteActivated(text, item)
    text = text or "Place"
    item = item or "Lines"
    if noteSelected() then
        return activationButton(text) or (utils.IsKeyPressed(keys.A) and not utils.IsKeyDown(keys.LeftControl))
    else
        return imgui.Text("Select a Note to " .. text .. " " .. item .. ".")
    end
end
