---@diagnostic disable: undefined-field
function polynomialVibroMenu()
    local settings = parameterWorkflow("polynomialVibro", "msxBounds", "boundCoefficients", "fps",
        "progressionExponent", "oneSided")

    if RangeActivated() then
        local vibroHeightFn = function (v)
            return mapProgress(settings.msxBounds[1], evaluateCoefficients(settings.boundCoefficients,
                    getProgress(offsets.startOffset, v, offsets.endOffset, settings.progressionExponent)),
                settings.msxBounds[2])
        end

        placeVibratoGroupsByFn(vibroHeightFn, settings.oneSided, settings.fps)
    end
end
