 
 
 ANIMATION_MENU_LIST = {
    'Manual (Basic)',
    'Incremental',
    'Boundary (Static)',
    'Boundary (Dynamic)',
    'Glitch',
    'Spectrum',
    'Expansion / Contraction'
} 
 
 DEFAULT_MENU_ID = 1

DEFAULT_MSX_LIST = '69 420 727 1337'
DEFAULT_DELAY = 1
DEFAULT_OFFSET = 0
DEFAULT_SPACING = 1.1
DEFAULT_MSX_BOUNDS = { 0, 400 }
DEFAULT_DISTANCE = { 15, 15 }
DEFAULT_LINE_COUNT = 10
DEFAULT_FPS = 90
DEFAULT_CENTER = 200
DEFAULT_MAX_SPREAD = 200
DEFAULT_PROGRESSION_EXPONENT = 1
DEFAULT_POLYNOMIAL_COEFFICIENTS = { -4, 4, 0 }

INCREMENT = 64
MAX_ITERATIONS = 1000
 
 
 DELETION_TYPE_LIST = {
    'Timing Lines + Scroll Velocities',
    'Timing Lines Only',
    'Scroll Velocities Only',
}
 
 
 FIXED_MENU_LIST = {
    'Manual',
    'Automatic',
    'Random'
} 
 
 MAIN_MENU_LIST = {
    'Standard',
    'Fixed',
    'Animation (LAGGY)',
    'Deletion'
} 
 
 STANDARD_MENU_LIST = {
    'Spread',
    'At Notes'
} 
 
 function StandardSpreadMenu()
    local parameterTable = constructParameters('distance')

    retrieveParameters('standard_spread', parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if RangeActivated(offsets) then
        local lines = {}
        local msx = offsets.startOffset

        local iterations = 0

        while (msx <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, msx, offsets.endOffset)

            table.insert(lines, line(msx))

            msx = msx + mapProgress(settings.distance[1], progress, settings.distance[2])

            iterations = iterations + 1
        end

        lines = cleanLines(lines, offsets.startOffset, offsets.endOffset)

        parameterTable[#parameterTable].value = "Line Count: " .. #lines -- DEBUG TEXT

        actions.PlaceTimingPointBatch(lines)
    end

    saveParameters('standard_spread', parameterTable)
end
 
 
 function StandardAtNotesMenu()
    local offsets = getSelectedOffsets()

    if NoteActivated(offsets) then
        local lines = {}

        if (type(offsets) == "integer") then return end

        for _, offset in pairs(offsets) do
            table.insert(lines, line(offset))
        end

        actions.PlaceTimingPointBatch(lines)
    end
end
 
 
 function FixedRandomMenu()
    local parameterTable = constructParameters('msxBounds', 'lineCount', 'delay', 'spacing')

    retrieveParameters("fixed_random", parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)

    local offsets = getStartAndEndNoteOffsets()

    if NoteActivated(offsets) then
        msxTable = {}
        for _ = 1, settings.lineCount do
            table.insert(msxTable, math.random(settings.msxBounds[1], settings.msxBounds[2]))
        end
        local tbl = tableToLines(msxTable, offsets.startOffset + settings.delay, 0, settings.spacing)

        generateAffines(tbl.lines, tbl.svs, offsets.startOffset, offsets.endOffset)
        parameterTable[#parameterTable].value = "Line Count: " .. #tbl.lines .. " // SV Count: " .. #tbl.svs
    end


    saveParameters("fixed_random", parameterTable)
end
 
 
 function FixedManualMenu()
    local parameterTable = constructParameters('msxList', 'offset', 'delay', 'spacing')

    retrieveParameters("fixed_manual", parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if NoteActivated(offsets) then
        msxTable = strToTable(settings.msxList, "%S+")
        local tbl = tableToLines(msxTable, offsets.startOffset + settings.delay, settings.offset, settings.spacing)
        generateAffines(tbl.lines, tbl.svs, offsets.startOffset, offsets.endOffset)

        parameterTable[#parameterTable].value = "Line Count: " .. #tbl.lines .. " // SV Count: " .. #tbl.svs
    end


    saveParameters("fixed_manual", parameterTable)
end
 
 
 function FixedAutomaticMenu()
    local parameterTable = constructParameters('msxBounds', 'distance', 'delay', 'spacing')

    retrieveParameters("fixed_automatic", parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if NoteActivated(offsets) then
        local tbl = placeAutomaticFrame(offsets.startOffset + settings.delay, settings.msxBounds[1],
            settings.msxBounds[2],
            settings.spacing, settings.distance)

        generateAffines(tbl.lines, tbl.svs, offsets.startOffset, offsets.endOffset)
        parameterTable[#parameterTable].value = "Line Count: " .. #tbl.lines .. " // SV Count: " .. #tbl.svs
    end

    saveParameters("fixed_automatic", parameterTable)
end

function placeAutomaticFrame(startTime, low, high, spacing, distance)
    msxTable = {}
    local msx = low
    local iterations = 0
    while (msx <= high) and (iterations < MAX_ITERATIONS) do
        local progress = getProgress(low, msx, high)
        table.insert(msxTable, msx)
        msx = msx + mapProgress(distance[1], progress, distance[2])
        iterations = iterations + 1
    end
    return tableToLines(msxTable, startTime, 0, spacing)
end
 
 
 function SpectrumMenu()
    local parameterTable = constructParameters("center", "maxSpread", "distance", "progressionExponent", "spacing",
        "polynomialCoefficients", {
            inputType = "Checkbox",
            key = "inverse",
            label = "Inverse?",
            value = false
        })

    retrieveParameters("animation_spectrum", parameterTable)

    parameterInputs(parameterTable)

    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if RangeActivated(offsets) then
        local currentTime = offsets.startOffset + 1

        local iterations = 0
        local lines = {}
        local svs = {}

        while ((currentTime + (2 / INCREMENT)) <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset) ^
                settings.progressionExponent


            local heightDifferential = settings.maxSpread *
                (settings.polynomialCoefficients[1] * progress ^ 2 + settings.polynomialCoefficients[2] * progress + settings.polynomialCoefficients[3])

            local tbl = placeSpectrumFrame(currentTime, settings.center, settings.maxSpread, settings.distance,
                settings.spacing, heightDifferential, settings.inverse)

            if (tbl.time > offsets.endOffset) then break end

            currentTime = tbl.time

            lines = concatTables(lines, tbl.lines)
            svs = concatTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, 1000)

            iterations = iterations + 1

            currentTime = currentTime + 2
        end

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset)
        parameterTable[#parameterTable].value = "Line Count: " .. #lines .. " // SV Count: " .. #svs
    end
    Plot(settings.polynomialCoefficients, settings.progressionExponent)

    saveParameters("animation_spectrum", parameterTable)
end

function placeSpectrumFrame(startTime, center, maxSpread, lineDistance, spacing, boundary, inverse)
    msxTable = {}

    local iterations = 0

    if (inverse) then
        local msx = center + maxSpread

        while (msx >= center + boundary) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(center, msx, center + maxSpread)
            table.insert(msxTable, msx)
            table.insert(msxTable, 2 * center - msx)
            msx = msx - mapProgress(lineDistance[1], progress, lineDistance[2])
            iterations = iterations + 1
        end

        return tableToLines(msxTable, startTime, 0, spacing)
    else
        local msx = center

        while (msx <= center + boundary) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(center, msx, center + maxSpread)
            table.insert(msxTable, msx)
            table.insert(msxTable, 2 * center - msx)
            msx = msx + mapProgress(lineDistance[1], progress, lineDistance[2])
            iterations = iterations + 1
        end

        return tableToLines(msxTable, startTime, 0, spacing)
    end
end
 
 
 function BasicManualAnimationMenu()
    local parameterTable = constructParameters('msxList1', 'msxList2', 'progressionExponent', 'fps', 'spacing')

    retrieveParameters("animation_manual", parameterTable)
    parameterInputs(parameterTable)

    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if RangeActivated(offsets) then
        startMsxTable = strToTable(settings.msxList1, "%S+")
        endMsxTable = strToTable(settings.msxList2, "%S+")

        local currentTime = offsets.startOffset + 1
        local iterations = 0
        local lines = {}
        local svs = {}

        while (currentTime < offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset) ^
                settings.progressionExponent

            local msxTable = {}

            for i = 1, #endMsxTable do
                table.insert(msxTable, mapProgress(startMsxTable[i], progress, endMsxTable[i]))
            end

            local tbl = tableToLines(msxTable, currentTime, 0, settings.spacing)

            if (tbl.time > offsets.endOffset) then break end

            currentTime = math.max(currentTime + (1000 / settings.fps) - 2, tbl.time)

            lines = concatTables(lines, tbl.lines)
            svs = concatTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, 1000)

            currentTime = currentTime + 2
        end

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset)
        parameterTable[#parameterTable].value = "Line Count: " .. #lines .. " // SV Count: " .. #svs
    end

    saveParameters("animation_manual", parameterTable)
end
 
 
 function IncrementalAnimationMenu()
    local parameterTable = constructParameters('msxList', 'spacing', {
        inputType = "RadioBoolean",
        key = "bounce",
        label = { "12341234", "1234321" },
        value = false
    }, {
        inputType = "Checkbox",
        key = "allLinesVisible",
        label = "All Lines Visible?",
        value = true,
        sameLine = true
    })

    retrieveParameters("animation_incremental", parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)

    local offsets = getStartAndEndNoteOffsets()

    if RangeActivated(offsets) then
        local times = getSelectedOffsets()

        local currentIndex = 1
        local currentHeight = 1

        local currentAddition = 1

        local totalMsxTable = strToTable(settings.msxList, "%S+")
        local MAX_HEIGHT = #totalMsxTable

        local lines = {}
        local svs = {}

        while (currentIndex <= #times) do
            local currentTime = times[currentIndex] + 1

            local msxTable = {}

            if (settings.allLinesVisible) then
                for i = 1, currentHeight do
                    table.insert(msxTable, totalMsxTable[i])
                end
            else
                table.insert(msxTable, totalMsxTable[currentHeight])
            end
            local tbl = tableToLines(msxTable, currentTime + 5, 0, settings.spacing)

            lines = concatTables(lines, tbl.lines)
            svs = concatTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, 1000)

            currentIndex = currentIndex + 1

            if (settings.bounce) then
                if (currentHeight == MAX_HEIGHT) then
                    currentAddition = -1
                elseif (currentHeight == 1) then
                    currentAddition = 1
                end
                currentHeight = currentHeight + currentAddition
            else
                if (currentHeight == MAX_HEIGHT) then
                    currentHeight = 1
                else
                    currentHeight = currentHeight + 1
                end
            end
        end

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset)
        parameterTable[#parameterTable].value = "Line Count: " .. #lines .. " // SV Count: " .. #svs
    end

    saveParameters("animation_incremental", parameterTable)
end
 
 
 function GlitchMenu()
    local parameterTable = constructParameters('msxBounds1', 'msxBounds2', 'lineCount', 'progressionExponent', 'fps',
        'spacing')

    retrieveParameters("glitch", parameterTable)

    parameterInputs(parameterTable)

    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if RangeActivated(offsets) then
        local currentTime = offsets.startOffset
        local lines = {}
        local svs = {}

        while (currentTime <= offsets.endOffset) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset) ^
                settings.progressionExponent


            local lowerBound = mapProgress(settings.msxBounds1[1], progress, settings.msxBounds2[1])
            local upperBound = mapProgress(settings.msxBounds1[2], progress, settings.msxBounds2[2])

            msxTable = {}
            for i = 1, settings.lineCount do
                table.insert(msxTable, math.random(upperBound, lowerBound))
            end
            local tbl = tableToLines(msxTable, currentTime, 0, settings.spacing)

            if (tbl.time > offsets.endOffset) then break end

            currentTime = math.max(currentTime + (1000 / settings.fps) - 2, tbl.time)

            lines = concatTables(lines, tbl.lines)
            svs = concatTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, 1000)

            currentTime = currentTime + 2
        end

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset)
        parameterTable[#parameterTable].value = "Line Count: " .. #lines .. " // SV Count: " .. #svs
    end



    saveParameters("glitch", parameterTable)
end
 
 
 function ExpansionContractionMenu()
    local parameterTable = constructParameters('msxBounds', 'distance', 'progressionExponent', 'spacing')

    retrieveParameters("animation_expansion_contraction", parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if RangeActivated(offsets) then
        local currentTime = offsets.startOffset + 1

        local iterations = 0

        local lines = {}
        local svs = {}

        while (currentTime <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset) ^
                settings.progressionExponent

            local distance = mapProgress(settings.distance[1], progress, settings.distance[2])

            local tbl = placeAutomaticFrame(currentTime, settings.msxBounds[1], settings.msxBounds[2], settings.spacing,
                { distance, distance })

            if (tbl.time > offsets.endOffset) then break end

            currentTime = tbl.time

            lines = concatTables(lines, tbl.lines)
            svs = concatTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, 1000)

            iterations = iterations + 1

            currentTime = currentTime + 2
        end

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset)
        parameterTable[#parameterTable].value = "Line Count: " .. #lines .. " // SV Count: " .. #svs
    end

    saveParameters("animation_expansion_contraction", parameterTable)
end
 
 
 function StaticBoundaryMenu()
    local parameterTable = constructParameters("msxBounds", "distance", "progressionExponent", "spacing",
        "polynomialCoefficients", {
            inputType = "RadioBoolean",
            key = "evalUnder",
            label = { "Render Over Boundary", "Render Under Boundary" },
            value = true
        })

    retrieveParameters("animation_polynomial", parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if RangeActivated(offsets) then
        local currentTime = offsets.startOffset + 1

        local iterations = 0
        local lines = {}
        local svs = {}


        while ((currentTime + (2 / INCREMENT)) <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset) ^
                settings.progressionExponent


            local boundary = settings.msxBounds[2] *
                (settings.polynomialCoefficients[1] * progress ^ 2 + settings.polynomialCoefficients[2] * progress + settings.polynomialCoefficients[3])

            local tbl = placeStaticFrame(currentTime, settings.msxBounds[1], settings.msxBounds[2], settings.distance,
                settings.spacing, boundary, settings.evalUnder)

            if (tbl.time > offsets.endOffset) then break end

            currentTime = tbl.time

            lines = concatTables(lines, tbl.lines)
            svs = concatTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, 1000)

            iterations = iterations + 1

            currentTime = currentTime + 2
        end

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset)
        parameterTable[#parameterTable].value = "Line Count: " .. #lines .. " // SV Count: " .. #svs
    end

    Plot(settings.polynomialCoefficients, settings.progressionExponent)

    saveParameters("animation_polynomial", parameterTable)
end

function placeStaticFrame(startTime, min, max, lineDistance, spacing, boundary, evalUnder)
    msxTable = {}
    local msx = min
    local iterations = 0

    while (msx <= max) and (iterations < MAX_ITERATIONS) do
        local progress = getProgress(min, msx, max)
        if (evalUnder) then
            if (msx <= boundary) then table.insert(msxTable, msx) end
        else
            if (msx >= boundary) then table.insert(msxTable, msx) end
        end
        msx = msx + mapProgress(lineDistance[1], progress, lineDistance[2])
        iterations = iterations + 1
    end

    return tableToLines(msxTable, startTime, 0, spacing)
end
 
 
 function DynamicBoundaryMenu()
    local parameterTable = constructParameters("msxBounds", 'distance', "progressionExponent", "spacing",
        "polynomialCoefficients", {
            inputType = "RadioBoolean",
            key = "evalOver",
            label = { "Change Bottom Bound", "Change Top Bound" },
            value = true
        })

    retrieveParameters("animation_polynomial", parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if RangeActivated(offsets) then
        local currentTime = offsets.startOffset + 1

        local iterations = 0

        local lines = {}
        local svs = {}

        while ((currentTime + (2 / INCREMENT)) <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset) ^
                settings.progressionExponent

            local polynomialHeight = (settings.polynomialCoefficients[1] * progress ^ 2 + settings.polynomialCoefficients[2] * progress + settings.polynomialCoefficients[3])

            local tbl = placeDynamicFrame(currentTime, settings.msxBounds[1], settings.msxBounds[2], settings.distance,
                settings.spacing, polynomialHeight, settings.evalOver)

            if (tbl.time > offsets.endOffset) then break end

            currentTime = tbl.time

            lines = concatTables(lines, tbl.lines)
            svs = concatTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, 1000)

            iterations = iterations + 1

            currentTime = currentTime + 2
        end

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset)
        parameterTable[#parameterTable].value = "Line Count: " .. #lines .. " // SV Count: " .. #svs
    end
    Plot(settings.polynomialCoefficients, settings.progressionExponent)

    saveParameters("animation_polynomial", parameterTable)
end

function placeDynamicFrame(startTime, min, max, lineDistance, spacing, polynomialHeight, evalOver)
    msxTable = {}
    local msx = min
    local iterations = 0

    while (msx <= max) and (iterations < MAX_ITERATIONS) do
        local progress = getProgress(min, msx, max)
        if (evalOver) then
            table.insert(msxTable, (msx - min) * polynomialHeight + min)
        else
            table.insert(msxTable, max - (msx - min) * (1 - polynomialHeight))
        end
        msx = msx + mapProgress(lineDistance[1], progress, lineDistance[2])
        iterations = iterations + 1
    end

    return tableToLines(msxTable, startTime, 0, spacing)
end
 
 
 function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end
 
 
 function teleport(time, dist)
    return {
        sv(time, INCREMENT * dist),
        sv(time + (1 / INCREMENT), 64000)
    }
end

function insertTeleport(svs, time, dist)
    return concatTables(svs, teleport(time, dist))
end
 
 
 function sv(time, multiplier)
    return utils.CreateScrollVelocity(time, multiplier)
end
 
 
 function getSVsInRange(lower, upper)
    local base = map.ScrollVelocities

    local tbl = {}

    for _, v in pairs(base) do
        if (v.StartTime >= lower) and (v.StartTime <= upper) then
            table.insert(tbl, v)
        end
    end

    return tbl
end
 
 
  
 
 function cleanSVs(svs, lower, upper)
    local tbl = {}

    for _, currentSV in pairs(svs) do
        if (currentSV.StartTime >= lower and currentSV.StartTime <= upper) then
            table.insert(tbl, currentSV)
        end
    end

    table.insert(tbl, sv(lower, 0))
    table.insert(tbl, sv(upper + 1, 1))

    return tbl
end
 
 
 function strToTable(str, predicate) 
    t = {}

    for i in string.gmatch(str, predicate) do
        t[#t + 1] = i
    end
    
    return t
end 
 
 function retrieveStateVariables(menu, variables)
    for key in pairs(variables) do
        if (state.GetValue(menu .. key) ~= nil) then
            variables[key] = state.GetValue(menu .. key)
        end
    end
end

function saveStateVariables(menu, variables)
    for key in pairs(variables) do
        state.SetValue(menu .. key, variables[key])
    end
end

function retrieveParameters(menu, parameterTable)
    for idx, tbl in ipairs(parameterTable) do
        if (state.GetValue(menu .. idx .. tbl.key) ~= nil) then
            parameterTable[idx].value = state.GetValue(menu .. idx .. tbl.key)
        end
    end
end

function saveParameters(menu, parameterTable)
    for idx, tbl in ipairs(parameterTable) do
        state.setValue(menu .. idx .. tbl.key, tbl.value)
    end
end
 
 
 function noteSelected(offsets)
    return offsets ~= -1
end

function rangeSelected(offsets)
    return (offsets ~= -1) and (offsets.startOffset ~= offsets.endOffset) 
end 
 
 function mapProgress(starting, progress, ending)
    return progress * (ending - starting) + starting
end 
 
 function getProgress(starting, value, ending)
    return (value - starting) / (ending - starting)
end
 
 
 function parametersToSettings(parameterTable)
    local settings = {}

    for _, tbl in ipairs(parameterTable) do
        settings[tbl.key] = tbl.value
    end

    return settings
end
 
 
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
        return InputFloat3Wrapper("Coefficients", v,
            "The boundary follows a curve, described by these coefficients. You can see what the boundary height vs. time graph looks like on the plot.")
    end
}

CUSTOM_INPUT_DICTIONARY = {
    Int = function (label, v, tooltip, sameLine) return InputIntWrapper(label, v, tooltip) end,
    RadioBoolean = function (labels, v, tooltip, sameLine) return RadioBoolean(labels[1], labels[2], v, tooltip) end,
    Checkbox = function (label, v, tooltip, sameLine) return CheckboxWrapper(label, v, tooltip, sameLine) end,
    Int2 = function (label, v, tooltip, sameLine) return InputInt2Wrapper(label, v, tooltip) end,
    Float = function (label, v, tooltip, sameLine) return InputFloatWrapper(label, v, tooltip) end
}

function parameterInputs(parameterTable)
    for _, tbl in ipairs(parameterTable) do
        if (tbl.inputType ~= nil) then
            tbl.value = CUSTOM_INPUT_DICTIONARY[tbl.inputType](tbl.label, tbl.value, tbl.tooltip, tbl.sameLine or false)
        else
            tbl.value = INPUT_DICTIONARY[tbl.key](tbl.value)
        end
    end
end
 
 
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
    maxSpread = DEFAULT_MAX_SPREAD
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
 
 
 function getStartAndEndNoteOffsets()
    local offsets = {}

    if (#state.SelectedHitObjects == 0) then
        return -1
    end

    for i, hitObject in pairs(state.SelectedHitObjects) do
        offsets[i] = hitObject.StartTime
    end

    return { startOffset = math.min(table.unpack(offsets)), endOffset = math.max(table.unpack(offsets)) }
end
 
 
 function getSelectedOffsets()
    local offsets = {}

    if (#state.SelectedHitObjects == 0) then
        return -1
    end

    for i, hitObject in pairs(state.SelectedHitObjects) do
        if (table.contains(offsets, hitObject.StartTime)) then goto continue end
        table.insert(offsets, hitObject.StartTime)
        ::continue::
    end

    return offsets
end
 
 
 function tableToLines(svTable, time, msxOffset, spacing)
    local lines = {}
    local svs = {}

    for _, msx in pairs(svTable) do
        local speed = INCREMENT * (msx + msxOffset)

        table.insert(lines, line(time))
        table.insert(svs, sv(time, speed * -1))
        table.insert(svs, sv(time - (1 / INCREMENT), speed))
        table.insert(svs, sv(time + (1 / INCREMENT), 0))

        time = time + spacing
    end

    local tbl = {
        lines = lines,
        svs = svs,
        time = time
    }
    return tbl
end
 
 
 function line(time)
    local data = map.GetTimingPointAt(time)

    if (not data) then
        data = {
            Bpm = map.GetCommonBpm(),
            Signature = time_signature.Quadruple,
            Hidden = false
        }
    end

    return utils.CreateTimingPoint(time, data.Bpm, data.Signature)
end
 
 
 function getLinesInRange(lower, upper)
    local base = map.TimingPoints

    local tbl = {}

    for _, v in pairs(base) do
        if (v.StartTime >= lower) and (v.StartTime <= upper) then
            table.insert(tbl, v)
        end
    end

    return tbl
end
 
 
 function cleanLines(lines, lower, upper)
    local lastLineTime = math.max(lines[#lines].StartTime, upper)

    local tbl = {}

    for _, currentLine in pairs(lines) do
        if (currentLine.StartTime >= lower and currentLine.StartTime <= upper) then
            table.insert(tbl, currentLine)
        end
    end

    table.insert(tbl, line(map.GetNearestSnapTimeFromTime(true, 1, lastLineTime) - 2))
    table.insert(tbl, line(map.GetNearestSnapTimeFromTime(true, 1, lastLineTime)))

    return tbl
end
 
 
 function generateAffines(lines, svs, lower, upper)
    if (not upper or upper == lower) then
        upper = map.GetNearestSnapTimeFromTime(true, 1, lower);
    end

    lines = cleanLines(lines, lower, upper)
    svs = cleanSVs(svs, lower, upper)

    actions.PerformBatch({
        utils.CreateEditorAction(action_type.AddTimingPointBatch, lines),
        utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs)
    })
end
 
 
 function concatTables(t1, t2)
    for i=1, #t2 do
       t1[#t1+1] = t2[i]
    end
    return t1
 end 
 
 function Tooltip(text)
    imgui.SameLine(0, 4)
    imgui.TextDisabled("(?)")
    if not imgui.IsItemHovered() then return end
    imgui.BeginTooltip()
    imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
    imgui.Text(text)
    imgui.PopTextWrapPos()
    imgui.EndTooltip()
end
 
 
 function RadioBoolean(labelFalse, labelTrue, v, tooltip)
    if imgui.RadioButton(labelFalse, not v) then
        v = false
    end

    imgui.SameLine(0, 7.5)

    if imgui.RadioButton(labelTrue, v) then
        v = true
    end

    return v
end
 
 
 function Plot(polynomialCoefficients, progressionExponent, title)
    imgui.Begin(title or "Boundary Height vs. Time", imgui_window_flags.AlwaysAutoResize)

    local RESOLUTION = 50
    local tbl = {}
    for i = 0, RESOLUTION do
        local progress = (i / RESOLUTION) ^ (progressionExponent)

        table.insert(tbl,
            (polynomialCoefficients[1] * progress ^ 2 + polynomialCoefficients[2] * progress + polynomialCoefficients[3]))
    end

    local sign1 = "+"
    local sign2 = "+"

    if (polynomialCoefficients[2] < 0) then
        sign1 = "-"
    end

    if (polynomialCoefficients[3] < 0) then
        sign2 = "-"
    end

    imgui.PlotLines("", tbl, #tbl, 0,
        'Equation: y = ' ..
        polynomialCoefficients[1] ..
        't^' ..
        string.sub(2 * progressionExponent, 1, 4) ..
        ' ' .. sign1 .. ' ' ..
        polynomialCoefficients[2] ..
        't^' .. string.sub(progressionExponent, 1, 4) .. ' ' .. sign2 .. ' ' .. polynomialCoefficients[3], 0,
        1,
        { 250, 150 })

    imgui.End()
end
 
 
 function InputIntWrapper(label, v, tooltip)
    _, v = imgui.InputInt(label, v, 0, 0)
    Tooltip(tooltip)
    return v
end

function InputFloatWrapper(label, v, tooltip)
    _, v = imgui.InputFloat(label, v, 0, 0, "%.2f")
    Tooltip(tooltip)
    return v
end

function InputTextWrapper(label, v, tooltip)
    _, v = imgui.InputText(label, v, 6942)
    Tooltip(tooltip)
    return v
end

function InputInt2Wrapper(label, v, tooltip)
    _, v = imgui.InputInt2(label, v)
    Tooltip(tooltip)
    return v
end

function InputFloat3Wrapper(label, v, tooltip)
    _, v = imgui.InputFloat3(label, v, "%.2f")
    Tooltip(tooltip)
    return v
end

function CheckboxWrapper(label, v, tooltip, sameLine)
    if (sameLine) then imgui.SameLine(0, 7.5) end
    _, v = imgui.Checkbox(label, v)
    Tooltip(tooltip)
    return v
end
 
 
 function activationButton(text)
    text = text or "Place"
    return imgui.Button(text .. " Lines")
end

function RangeActivated(offsets, text)
    text = text or "Place"
    if rangeSelected(offsets) then
        return activationButton(text) or (utils.IsKeyPressed(keys.A) and not utils.IsKeyDown(keys.LeftControl))
    else
        return imgui.Text("Select a Region to " .. text .. " Lines.")
    end
end

function NoteActivated(offsets, text)
    text = text or "Place"
    if noteSelected(offsets) then
        return activationButton(text) or (utils.IsKeyPressed(keys.A) and not utils.IsKeyDown(keys.LeftControl))
    else
        return imgui.Text("Select a Note to " .. text .. " Lines.")
    end
end
 
 
 function chooseMenu(tbl, menuID)
    if (tbl[menuID]) then
        tbl[menuID]();
    end
end

function draw()
    imgui.Begin("AFFINE", imgui_window_flags.AlwaysAutoResize)

    local settings = {
        menuID = DEFAULT_MENU_ID
    }

    -- IMPORTANT: DO NOT DELETE NEXT LINE BEFORE COMPILING.
     
 
 ANIMATION_MENU_FUNCTIONS = {
    BasicManualAnimationMenu,
    IncrementalAnimationMenu,
    StaticBoundaryMenu,
    DynamicBoundaryMenu,
    GlitchMenu,
    SpectrumMenu,
    ExpansionContractionMenu
}
 
 
  
 
  
 
 FIXED_MENU_FUNCTIONS = {
    FixedManualMenu,
    FixedAutomaticMenu,
    FixedRandomMenu
}
 
 
 MAIN_MENU_FUNCTIONS = {
    StandardMenu,
    FixedMenu,
    AnimationMenu,
    DeletionMenu
}
 
 
 STANDARD_MENU_FUNCTIONS = {
    StandardSpreadMenu,
    StandardAtNotesMenu
}


    retrieveStateVariables("main", settings)

    local mainMenuIndex = settings.menuID - 1
    local _, mainMenuIndex = imgui.Combo("Line Placement Type", mainMenuIndex, MAIN_MENU_LIST, #MAIN_MENU_LIST)
    settings.menuID = mainMenuIndex + 1

    chooseMenu(MAIN_MENU_FUNCTIONS, settings.menuID)

    saveStateVariables("main", settings)

    imgui.End()
end

function AnimationMenu()
    local settings = {
        menuID = DEFAULT_MENU_ID
    }

    retrieveStateVariables("animation", settings)

    local animationMenuIndex = settings.menuID - 1
    local _, animationMenuIndex = imgui.Combo("Animation Type", animationMenuIndex, ANIMATION_MENU_LIST,
        #ANIMATION_MENU_LIST)
    addSeparator()
    settings.menuID = animationMenuIndex + 1

    chooseMenu(ANIMATION_MENU_FUNCTIONS, settings.menuID)

    saveStateVariables("animation", settings)
end

function StandardMenu()
    local settings = {
        menuID = DEFAULT_MENU_ID
    }

    retrieveStateVariables("standard", settings)

    local standardMenuIndex = settings.menuID - 1
    local _, standardMenuIndex = imgui.Combo("Standard Placement Type", standardMenuIndex, STANDARD_MENU_LIST,
        #STANDARD_MENU_LIST)
    addSeparator()
    settings.menuID = standardMenuIndex + 1

    chooseMenu(STANDARD_MENU_FUNCTIONS, settings.menuID)

    saveStateVariables("standard", settings)
end

function FixedMenu()
    local settings = {
        menuID = DEFAULT_MENU_ID
    }

    retrieveStateVariables("fixed", settings)

    local fixedMenuIndex = settings.menuID - 1
    local _, fixedMenuIndex = imgui.Combo("Fixed Placement Type", fixedMenuIndex, FIXED_MENU_LIST, #FIXED_MENU_LIST)
    addSeparator()
    settings.menuID = fixedMenuIndex + 1

    chooseMenu(FIXED_MENU_FUNCTIONS, settings.menuID)

    saveStateVariables("fixed", settings)
end

function DeletionMenu()
    local settings = {
        deletionType = DEFAULT_MENU_ID
    }

    retrieveStateVariables("deletion", settings)

    local deletionTypeIndex = settings.deletionType - 1
    local _, deletionTypeIndex = imgui.Combo("Deletion Type", deletionTypeIndex, DELETION_TYPE_LIST,
        #DELETION_TYPE_LIST)
    addSeparator()
    settings.deletionType = deletionTypeIndex + 1

    local offsets = getStartAndEndNoteOffsets()

    if (RangeActivated(offsets, "Remove")) then
        svs = getSVsInRange(offsets.startOffset, offsets.endOffset)
        lines = getLinesInRange(offsets.startOffset, offsets.endOffset)

        local actionTable = {}

        if (settings.deletionType % 2 ~= 0) then
            table.insert(actionTable,
                utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, svs))
        end

        if (settings.deletionType <= 2) then
            table.insert(actionTable, utils.CreateEditorAction(action_type.RemoveTimingPointBatch, lines))
        end

        actions.PerformBatch(actionTable)
    end

    saveStateVariables("deletion", settings)
end

function addPadding()
    imgui.Dummy({ 0, 0 })
end

function addSeparator()
    addPadding()
    imgui.Separator()
    addPadding()
end
