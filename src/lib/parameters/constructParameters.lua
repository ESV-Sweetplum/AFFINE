DEFAULT_DICTIONARY = {
    msxBounds = DEFAULT_MSX_BOUNDS,
    msxBounds1 = DEFAULT_MSX_BOUNDS,
    msxBounds2 = DEFAULT_MSX_BOUNDS,
    msxList = DEFAULT_MSX_LIST,
    msxList1 = DEFAULT_MSX_LIST,
    msxList2 = DEFAULT_MSX_LIST,
    offset = DEFAULT_OFFSET,
    spacing = DEFAULT_SPACING,
    delay = DEFAULT_DELAY,
    distance = DEFAULT_DISTANCE,
    lineCount = DEFAULT_LINE_COUNT,
    progressionExponent = DEFAULT_PROGRESSION_EXPONENT,
    polynomialCoefficients = DEFAULT_POLYNOMIAL_COEFFICIENTS,
    fps = DEFAULT_FPS,
    center = DEFAULT_CENTER,
    maxSpread = DEFAULT_MAX_SPREAD,
    colorList = DEFAULT_COLOR_LIST
}

function constructParameters(...)
    local parameterTable = {}

    for _, v in ipairs({ ... }) do
        if (type(v) == "table") then
            table.insert(parameterTable, {
                inputType = v.inputType,
                key = v.key,
                value = v.value,
                label = v.label,
                sameLine = v.sameLine or false
            })
            goto continue
        end
        table.insert(parameterTable, {
            key = v,
            value = DEFAULT_DICTIONARY[v]
        })
        ::continue::
    end

    table.insert(parameterTable, { key = "debug", value = "" })

    return parameterTable
end
