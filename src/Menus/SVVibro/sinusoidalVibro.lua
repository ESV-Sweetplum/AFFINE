---@diagnostic disable: undefined-field
function sinusoidalVibroMenu()
    local settings = parameterWorkflow("sinusoidalVibro", "msxBounds",
        customParameter("Float", "# of Cycles", "cycleCount", 1),
        customParameter("Float", "Phase Shift", "phaseShift", 0),
        "fps",
        "progressionExponent", "oneSided")

    if RangeActivated() then
        local vibroHeightFn = function (v)
            local x = getProgress(offsets.startOffset, v, offsets.endOffset, settings.progressionExponent)
            local fx = mapProgress(settings.msxBounds[1], x, settings.msxBounds[2])
            return fx * math.sin(2 * math.pi * (settings.cycleCount * x + settings.phaseShift))
        end

        placeVibratoGroupsByFn(vibroHeightFn, settings.oneSided, settings.fps)
    end
end
