local RESOLUTION = 50

---Creates a new window with a plot
---@param polynomialCoefficients number[]
---@param progressionExponent number
---@param title? string
function PolynomialPlot(polynomialCoefficients, progressionExponent, title)
    imgui.Begin(title or "Boundary Height vs. Time", imgui_window_flags.AlwaysAutoResize)
    local tbl = {}

    if (polynomialCoefficients == state.GetValue("cachedCoefficients")) then
        tbl = state.GetValue("cachedPlotValues")
    else
        for i = 0, RESOLUTION do
            local progress = getProgress(0, i, RESOLUTION, progressionExponent)

            table.insert(tbl,
                evaluateCoefficients(polynomialCoefficients, progress))
        end
    end

    state.SetValue("cachedCoefficients", polynomialCoefficients)
    state.SetValue("cachedPlotValues", tbl)

    imgui.PlotLines("Polynomial Plot", tbl, #tbl, 0,
        polynomialString(polynomialCoefficients, progressionExponent),
        0, 1,
        { 250, 150 })

    imgui.End()
end

---Plots a sinusoidal graph given cycle counts and phase shift.
---@param nx [number, number] # Start and End cycle counts. The sine function will have `nx[2]` cycles in total.
---@param phi number # Phase shift represented as a number in [0,1).
---@param title string # Title of the plot window.
function SinusoidalPlot(nx, phi, title)
    imgui.Begin(title or "Boundary Height vs. Time", imgui_window_flags.AlwaysAutoResize)

    local tbl = {}

    for i = 0, RESOLUTION do
        local x = i / RESOLUTION
        local fn = function (v) return nx[1] + (nx[2] - nx[1]) * v end

        table.insert(tbl, math.sin(2 * math.pi * (x * fn(x) + phi)))
    end

    imgui.PlotLines("Sinusoidal Plot", tbl, #tbl, 0,
        "",
        -1, 1,
        { 250, 150 })

    imgui.End()
end

function Plot(fn, label, windowName)
    imgui.Begin(windowName or "Boundary Height vs. Time", imgui_window_flags.AlwaysAutoResize)

    local tbl = {}
    local min, max = 0, 0

    for i = 0, RESOLUTION do
        local y = fn(i / RESOLUTION)
        table.insert(tbl, y)
        min = math.min(y, min)
        max = math.max(y, max)
    end

    imgui.PlotLines(windowName .. " Plot", tbl, #tbl, 0,
        label,
        min, max,
        { 250, 150 })

    imgui.End()
end
