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
        polynomialCoefficients[1] .. 't^2 + ' .. polynomialCoefficients[2] .. 't + ' .. polynomialCoefficients[3], 0,
        1,
        { 250, 150 })

    imgui.End()
end
