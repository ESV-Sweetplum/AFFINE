---@diagnostic disable: undefined-field
function sinusoidalVibroMenu()
    local settings = parameterWorkflow("sinusoidalVibro", "msxBounds",
        customParameter("Float", "# of Cycles", "cycleCount", 1),
        customParameter("Float", "Phase Shift", "phaseShift", 0),
        "fps",
        "progressionExponent", "oneSided")

    local PI = 3.14159265358979

    if RangeActivated() then
        local vibroHeightFn = function (v)
            local x = getProgress(offsets.startOffset, v, offsets.endOffset, settings.progressionExponent)
            local fx = mapProgress(settings.msxBounds[1], x, settings.msxBounds[2])
            return fx * math.sin(2 * PI * (settings.cycleCount * x + settings.phaseShift))
        end

        placeVibratoGroupsByFn(vibroHeightFn, settings.oneSided, settings.fps)
    end

    SinusoidalPlot({ settings.cycleCount, settings.cycleCount }, settings.phaseShift)
end
