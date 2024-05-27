---Creates a new window with a plot
---@param polynomialCoefficients number[]
---@param progressionExponent number
---@param title? string
function Plot(polynomialCoefficients, progressionExponent, title)
    imgui.Begin(title or "Boundary Height vs. Time", imgui_window_flags.AlwaysAutoResize)
    local tbl = {}

    if (polynomialCoefficients == state.GetValue("cachedCoefficients")) then
        tbl = state.GetValue("cachedPlotValues")
    else
        local RESOLUTION = 50
        for i = 0, RESOLUTION do
            local progress = getProgress(0, i, RESOLUTION, progressionExponent)

            table.insert(tbl,
                evaluateCoefficients(polynomialCoefficients, progress))
        end
    end

    state.SetValue("cachedCoefficients", polynomialCoefficients)
    state.SetValue("cachedPlotValues", tbl)

    imgui.PlotLines("", tbl, #tbl, 0,
        polynomialString(polynomialCoefficients, progressionExponent),
        0, 1,
        { 250, 150 })

    imgui.End()
end
