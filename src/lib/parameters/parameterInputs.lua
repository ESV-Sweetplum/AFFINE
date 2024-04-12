INPUT_DICTIONARY = {
    msxList = function (v)
        return InputTextWrapper("MSX List", v,
            "List of MSX values to place. For each number given, a timing line will be placed at that number MSX above the receptor.")
    end,
    msxList1 = function (v)
        return InputTextWrapper("Start MSX List", v,
            "List of MSX values to place. For each number given, a timing line will be placed at that number MSX above the receptor. These timing lines represent the start of the animation.")
    end,
    msxList2 = function (v)
        return InputTextWrapper("End MSX List", v,
            "List of MSX values to place. For each number given, a timing line will be placed at that number MSX above the receptor. These timing lines represent the end of the animation.")
    end,
    msxBounds = function (v)
        return InputInt2Wrapper("Lower/Upper MSX", v,
            "The lowest MSX and highest MSX values timing lines can reach. Anything outside of these bounds will be ignored.")
    end,
    msxBounds1 = function (v)
        return InputInt2Wrapper("Start Lower/Upper MSX", v,
            "The lowest MSX and highest MSX values timing lines can reach, at the start of the animation.")
    end,
    msxBounds2 = function (v)
        return InputInt2Wrapper("End Lower/Upper MSX", v,
            "The lowest MSX and highest MSX values timing lines can reach, at the end of the animation.")
    end,
    offset = function (v)
        return InputIntWrapper("MSX Offset", v,
            "Adds this MSX value to all MSX values in the MSX List above.")
    end,
    delay = function (v)
        return InputIntWrapper("MS Delay", v,
            "MS Delay waits for this value of milliseconds to place the timing lines. Could be useful if you have conflicting SVs.")
    end,
    center = function (v)
        return InputIntWrapper("Center MSX", v,
            "The center of the spectrum, an MSX distance above the receptor.")
    end,
    maxSpread = function (v)
        return InputIntWrapper("Max MSX Spread", v,
            "The maximum distance away from the center that a timing line can reach.")
    end,
    spacing = function (v)
        return InputFloatWrapper("MS Spacing", v,
            "The MS distance between two timing lines. Recommended to keep this below 2.")
    end,
    debug = function (v)
        if v ~= '' then
            imgui.Text(v)
            return v
        end
    end,
    distance = function (v)
        return InputInt2Wrapper('Distance Between Lines', v,
            "Represents the distance between two adjacent timing lines, measured in MSX. If in Expansion/Contraction, the two numbers represent the start and end distance of the animation. If not in Expansion/Contraction, the two numbers represent the start and end distance of the frame.")
    end,
    lineCount = function (v) return InputIntWrapper("Line Count", v, "The number of timing lines to place on one frame.") end,
    progressionExponent = function (v)
        return InputFloatWrapper("Progression Exponent", v,
            "Adjust this to change how the animation progresses over time. The higher the number, the slower the animation takes to start, but it ramps up much faster. If you aren't familiar with exponential graphs, keep this at 1.")
    end,
    fps = function (v)
        return InputFloatWrapper("Animation FPS", v,
            "Maximum FPS of the animation. Note that if there are too many timing lines, the animation (not game) FPS will go down.")
    end,
    polynomialCoefficients = function (v)
        return InputFloat4Wrapper("Coefficients", v,
            "The boundary follows a curve, described by these coefficients. You can see what the boundary height vs. time graph looks like on the plot.")
    end,
    colorList = function (v)
        return InputTextWrapper("Snap Color List", v,
            "These numbers are the denominator of the snaps. Here are the corresponding values:\n1 = Red\n2 = Blue\n3 = Purple\n4 = Yellow\n6 = Pink\n8 = Orange\n12 = Pink\n16 = Green")
    end
}

CUSTOM_INPUT_DICTIONARY = {
    Int = function (label, v, tooltip, sameLine) return InputIntWrapper(label, v, tooltip) end,
    RadioBoolean = function (labels, v, tooltip, sameLine) return RadioBoolean(labels[1], labels[2], v, tooltip) end,
    Checkbox = function (label, v, tooltip, sameLine) return CheckboxWrapper(label, v, tooltip, sameLine) end,
    Int2 = function (label, v, tooltip, sameLine) return InputInt2Wrapper(label, v, tooltip) end,
    Float = function (label, v, tooltip, sameLine) return InputFloatWrapper(label, v, tooltip) end
}

---Creates imgui inputs using the given parameter table.
---@param parameterTable Parameter[]
function parameterInputs(parameterTable)
    for _, tbl in ipairs(parameterTable) do
        if (tbl.inputType ~= nil) then
            tbl.value = CUSTOM_INPUT_DICTIONARY[tbl.inputType](tbl.label, tbl.value, tbl.tooltip, tbl.sameLine or false)
        else
            tbl.value = INPUT_DICTIONARY[tbl.key](tbl.value)
        end
    end
end
