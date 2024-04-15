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
    lineDuration = DEFAULT_LINE_DURATION,
    progressionExponent = DEFAULT_PROGRESSION_EXPONENT,
    boundCoefficients = DEFAULT_BOUND_COEFFICIENTS,
    pathCoefficients = DEFAULT_PATH_COEFFICIENTS,
    fps = DEFAULT_FPS,
    center = DEFAULT_CENTER,
    maxSpread = DEFAULT_MAX_SPREAD,
    colorList = DEFAULT_COLOR_LIST
}


---Given a set of input names, creates an ordered table of key value pairs (normal table isn't used to preserve order).
---@param ... string | table
---@return Parameter[]
function constructParameters(...)
    local parameterTable = {}

    for _, v in ipairs({ ... }) do
        if (type(v) == "table") then
            table.insert(parameterTable, {
                inputType = v.inputType,
                key = v.key,
                value = v.value,
                label = v.label,
                sameLine = v.sameLine or false,
                tooltip = v.tooltip or ""
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
