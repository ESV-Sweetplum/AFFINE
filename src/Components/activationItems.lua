function activationButton(text)
    text = text or "Place"
    return imgui.Button(text .. " Lines")
end

function RangeActivated(text)
    text = text or "Place"
    if rangeSelected() then
        return activationButton(text) or (utils.IsKeyPressed(keys.A) and not utils.IsKeyDown(keys.LeftControl))
    else
        return imgui.Text("Select a Region to " .. text .. " Lines.")
    end
end

function NoteActivated(text)
    text = text or "Place"
    if noteSelected() then
        return activationButton(text) or (utils.IsKeyPressed(keys.A) and not utils.IsKeyDown(keys.LeftControl))
    else
        return imgui.Text("Select a Note to " .. text .. " Lines.")
    end
end
