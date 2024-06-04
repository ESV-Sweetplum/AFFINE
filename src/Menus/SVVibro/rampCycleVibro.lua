---@diagnostic disable: undefined-field
function rampCycleVibroMenu()
    local settings = parameterWorkflow("rampCycleVibro", "msxBounds",
        customParameter("Float2", "# of Cycles", "cycleCount", { 1, 2 }),
        customParameter("Float", "Phase Shift", "phaseShift", 0),
        "fps",
        "progressionExponent", "oneSided")

    if RangeActivated() then
        local vibroHeightFn = function (v)
            local x = getProgress(offsets.startOffset, v, offsets.endOffset, settings.progressionExponent)
            local fx = mapProgress(settings.msxBounds[1], x, settings.msxBounds[2])
            local ix = settings.cycleCount[1] * x + (settings.cycleCount[2] - settings.cycleCount[1]) / 2 * (x ^ 2)
            return fx * math.sin(2 * math.pi * (ix + settings.phaseShift))
        end

        placeVibratoGroupsByFn(vibroHeightFn, settings.oneSided, settings.fps)
    end

    SinusoidalPlot(settings.cycleCount, settings.phaseShift)
end
