local RESOLUTION = 50

---Graphs a polynomial given the coefficients.
---@param plyCoeff [number, number, number, number] # The coefficients of the polynomial, in identical order. Modeled after standard form ax^3+bx^2+cx+d.
---@param prgExp number # Changes how the progress of animation is calculated.
---@param title? string # Title of the plot window.
function PolynomialPlot(plyCoeff, prgExp, title)
    imgui.Begin(title or "Boundary Height vs. Time", imgui_window_flags.AlwaysAutoResize)
    local tbl = {}

    if (plyCoeff == state.GetValue("cachedCoefficients")) then
        tbl = state.GetValue("cachedPlotValues")
    else
        for i = 0, RESOLUTION do
            local progress = getProgress(0, i, RESOLUTION, prgExp)

            table.insert(tbl,
                evaluateCoefficients(plyCoeff, progress))
        end
    end

    state.SetValue("cachedCoefficients", plyCoeff)
    state.SetValue("cachedPlotValues", tbl)

    imgui.PlotLines("", tbl, #tbl, 0,
        polynomialString(plyCoeff, prgExp),
        0, 1,
        { 250, 150 })

    imgui.End()
end

---Plots a sinusoidal graph given cycle counts and phase shift.
---@param nx [number, number] # Start and End cycle counts. The sine function will have `nx[2]` cycles in total.
---@param phi number # Phase shift represented as a number in [0,1).
---@param title? string # Title of the plot window.
function SinusoidalPlot(nx, phi, title)
    imgui.Begin(title or "Boundary Height vs. Time", imgui_window_flags.AlwaysAutoResize)

    local tbl = {}

    for i = 0, RESOLUTION do
        local x = i / RESOLUTION
        local fn = function (v) return nx[1] + (nx[2] - nx[1]) * v end

        table.insert(tbl, math.sin(2 * math.pi * (x * fn(x) + phi)))
    end

    imgui.PlotLines("", tbl, #tbl, 0,
        "",
        -1, 1,
        { 250, 150 })

    imgui.End()
end

---Plots a function.
---@param fn fun(v: number): number # The function to plot. It should take in a number `x` and output a number `f(x)`.
---@param label string # The label within the plot.
---@param title string # Title of the plot window.
function Plot(fn, label, title)
    imgui.Begin(title or "Boundary Height vs. Time", imgui_window_flags.AlwaysAutoResize)

    local tbl = {}
    local min, max = 0, 0

    for i = 0, RESOLUTION do
        local y = fn(i / RESOLUTION)
        table.insert(tbl, y)
        min = math.min(y, min)
        max = math.max(y, max)
    end

    imgui.PlotLines(title .. " Plot", tbl, #tbl, 0,
        label,
        min, max,
        { 250, 150 })

    imgui.End()
end
