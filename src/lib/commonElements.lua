function activationButton()
    return imgui.Button("Place Lines")
end

function rangeActivated(offsets)
    if rangeSelected(offsets) then
        return activationButton() or (utils.IsKeyPressed(keys.A) and not utils.IsKeyDown(keys.LeftControl))
    else
        return imgui.Text("Select a Region to Place Lines.")
    end
end

function noteActivated(offsets)
    if noteSelected(offsets) then
        return activationButton() or (utils.IsKeyPressed(keys.A) and not utils.IsKeyDown(keys.LeftControl))
    else
        return imgui.Text("Select a Note to Place Lines.")
    end
end
