INPUT_DICTIONARY = {
    msxList = function (v) return InputTextWrapper("MSX List", v) end,
    msxList1 = function (v) return InputTextWrapper("Start MSX List", v) end,
    msxList2 = function (v) return InputTextWrapper("End MSX List", v) end,
    msxBounds = function (v) return InputInt2Wrapper("Lower/Upper MSX", v) end,
    msxBounds1 = function (v) return InputInt2Wrapper("Start Lower/Upper MSX", v) end,
    msxBounds2 = function (v) return InputInt2Wrapper("End Lower/Upper MSX", v) end,
    offset = function (v) return InputIntWrapper("MSX Offset", v) end,
    delay = function (v) return InputIntWrapper("MS Delay", v) end,
    spacing = function (v) return InputFloatWrapper("MS Spacing", v) end,
    debug = function (v) if v ~= '' then return imgui.Text(v) end end,
    distance = function (v) return InputInt2Wrapper('Distance Between Lines', v) end,
    lineCount = function (v) return InputIntWrapper("Line Count", v) end,
    progressionExponent = function (v) return InputFloatWrapper("Progression Exponent", v) end,
    fps = function (v) return InputFloatWrapper("Animation FPS", v) end
}

function parameterInputs(parameterTable)
    for _, tbl in ipairs(parameterTable) do
        tbl.value = INPUT_DICTIONARY[tbl.key](tbl.value)
    end
end
