---Creates a new window with a plot
---@param polynomialCoefficients number[]
---@param progressionExponent number
---@param title? string
function Plot(polynomialCoefficients, progressionExponent, title)
    imgui.Begin(title or "Boundary Height vs. Time", imgui_window_flags.AlwaysAutoResize)

    local RESOLUTION = 50
    local tbl = {}
    for i = 0, RESOLUTION do
        local progress = (i / RESOLUTION) ^ (progressionExponent)

        table.insert(tbl,
            (polynomialCoefficients[1] * progress ^ 2 + polynomialCoefficients[2] * progress + polynomialCoefficients[3]))
    end

    local sign1 = "+"
    local sign2 = "+"

    if (polynomialCoefficients[2] < 0) then
        sign1 = "-"
    end

    if (polynomialCoefficients[3] < 0) then
        sign2 = "-"
    end

    imgui.PlotLines("", tbl, #tbl, 0,
        'Equation: y = ' ..
        polynomialCoefficients[1] ..
        't^' ..
        string.sub(2 * progressionExponent, 1, 4) ..
        ' ' .. sign1 .. ' ' ..
        polynomialCoefficients[2] ..
        't^' .. string.sub(progressionExponent, 1, 4) .. ' ' .. sign2 .. ' ' .. polynomialCoefficients[3], 0,
        1,
        { 250, 150 })

    imgui.End()
end
