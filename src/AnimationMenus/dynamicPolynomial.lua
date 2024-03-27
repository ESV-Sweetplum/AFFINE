function DynamicPolynomialMenu()
    local settings = {
        msxBounds = DEFAULT_MSX_BOUNDS,
        spacing = DEFAULT_SPACING,
        distance = DEFAULT_DISTANCE,
        polynomialCoefficients = { -4, 4, 0 },
        evalOver = true,
        debug = 'Lines // SVs'
    }

    retrieveStateVariables("animation_polynomial", settings)

    _, settings.msxBounds = imgui.InputInt2("Start/End MSX", settings.msxBounds)
    _, settings.distance = imgui.InputInt2("Distance Between Lines", settings.distance)

    _, settings.spacing = imgui.InputFloat("MS Spacing", settings.spacing)

    _, settings.polynomialCoefficients = imgui.InputFloat3("Coefficients", settings.polynomialCoefficients, "%.2f")

    if imgui.RadioButton("Change Bottom Bound", not settings.evalOver) then
        settings.evalOver = false
    end

    imgui.SameLine(0, 7.5)

    if imgui.RadioButton("Change Top Bound", settings.evalOver) then
        settings.evalOver = true
    end

    local offsets = getStartAndEndNoteOffsets()

    if rangeActivated(offsets) then
        local currentTime = offsets.startOffset + 1

        local iterations = 0


        local lines = {}
        local svs = {}


        while ((currentTime + (2 / INCREMENT)) < offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset)

            local polynomialHeight = (settings.polynomialCoefficients[1] * progress ^ 2 + settings.polynomialCoefficients[2] * progress + settings.polynomialCoefficients[3])

            local tbl = placeFrame(currentTime, settings.msxBounds[1], settings.msxBounds[2], settings.distance,
                settings.spacing, polynomialHeight, settings.evalOver)

            currentTime = tbl.time

            lines = concatTables(lines, tbl.lines)
            svs = concatTables(svs, tbl.svs)

            table.insert(svs, utils.CreateScrollVelocity(currentTime + (1 / INCREMENT), 64000))
            table.insert(svs, utils.CreateScrollVelocity(currentTime + (2 / INCREMENT), 0))

            iterations = iterations + 1

            currentTime = currentTime + 2
        end
        settings.debug = #lines .. ' // ' .. #svs

        actions.PerformBatch({
            utils.CreateEditorAction(action_type.AddTimingPointBatch, lines),
            utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs)
        })
    end

    imgui.Text(settings.debug)

    saveStateVariables("animation_polynomial", settings)
end

function placeFrame(startTime, min, max, lineDistance, spacing, polynomialHeight, evalOver)
    msxTable = {}
    local msx = min
    local iterations = 0

    while (msx < max) and (iterations < MAX_ITERATIONS) do
        local progress = getProgress(min, msx, max)
        if (evalOver) then
            table.insert(msxTable, (msx - min) * polynomialHeight + min)
        else
            table.insert(msxTable, max - (msx - min) * (1 - polynomialHeight))
        end
        msx = msx + mapProgress(lineDistance[1], progress, lineDistance[2])
        iterations = iterations + 1
    end

    return returnFixedLines(msxTable, startTime, 0, spacing)
end
