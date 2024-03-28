function activationButton(text)
    text = text or "Place"
    return imgui.Button(text .. " Lines")
end

function rangeActivated(offsets, text)
    text = text or "Place"
    if rangeSelected(offsets) then
        return activationButton(text) or (utils.IsKeyPressed(keys.A) and not utils.IsKeyDown(keys.LeftControl))
    else
        return imgui.Text("Select a Region to " .. text .. " Lines.")
    end
end

function noteActivated(offsets, text)
    text = text or "Place"
    if noteSelected(offsets) then
        return activationButton(text) or (utils.IsKeyPressed(keys.A) and not utils.IsKeyDown(keys.LeftControl))
    else
        return imgui.Text("Select a Note to " .. text .. " Lines.")
    end
end

function plot(polynomialCoefficients)
    imgui.Begin("Boundary Height vs. Time", imgui_window_flags.AlwaysAutoResize)

    local RESOLUTION = 20
    local tbl = {}
    for i = 0, RESOLUTION do
        local progress = i / RESOLUTION

        table.insert(tbl,
            (polynomialCoefficients[1] * progress ^ 2 + polynomialCoefficients[2] * progress + polynomialCoefficients[3]))
    end

    imgui.PlotLines("", tbl, #tbl, 0,
        'Equation: y = ' ..
        polynomialCoefficients[1] .. 'x^2 + ' .. polynomialCoefficients[2] .. 'x + ' .. polynomialCoefficients[3], 0,
        1,
        { 250, 150 })

    imgui.End()
end
