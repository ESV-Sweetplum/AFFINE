 
 
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

    if rangeActivated(offsets) then
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

        actions.PlaceTimingPointBatch(lines)
    end

    saveParameters('standard_spread', parameterTable)
end
 
 
 function StandardAtNotesMenu()
    local offsets = getSelectedOffsets()

    if noteActivated(offsets) then
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

    if noteActivated(offsets) then
        msxTable = {}
        for _ = 1, settings.lineCount do
            table.insert(msxTable, math.random(settings.msxBounds[1], settings.msxBounds[2]))
        end
        local tbl = tableToLines(msxTable, offsets.startOffset + settings.delay, 0, settings.spacing)

        generateAffines(tbl.lines, tbl.svs, offsets.startOffset, offsets.endOffset)
    end

    saveParameters("fixed_random", parameterTable)
end
 
 
 function FixedManualMenu()
    local parameterTable = constructParameters('msxList', 'offset', 'delay', 'spacing')

    retrieveParameters("fixed_manual", parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if noteActivated(offsets) then
        msxTable = strToTable(settings.msxList, "%S+")
        local tbl = tableToLines(msxTable, offsets.startOffset + settings.delay, settings.offset, settings.spacing)
        generateAffines(tbl.lines, tbl.svs, offsets.startOffset)
    end

    saveParameters("fixed_manual", parameterTable)
end
 
 
 function FixedAutomaticMenu()
    local parameterTable = constructParameters('msxBounds', 'distance', 'delay', 'spacing')

    retrieveParameters("fixed_automatic", parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if noteActivated(offsets) then
        local tbl = placeAutomaticFrame(offsets.startOffset + settings.delay, settings.msxBounds[1],
            settings.msxBounds[2],
            settings.spacing, settings.distance)

        generateAffines(tbl.lines, tbl.svs, offsets.startOffset, offsets.endOffset)
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
    local settings = {
        center = DEFAULT_CENTER,
        maxSpread = DEFAULT_MAX_SPREAD,
        spacing = DEFAULT_SPACING,
        distance = DEFAULT_DISTANCE,
        polynomialCoefficients = { -4, 4, 0 },
        inverse = false,
        debug = 'Lines // SVs'
    }

    retrieveStateVariables("animation_spectrum", settings)

    _, settings.center = imgui.InputInt("Center MSX", settings.center)
    _, settings.maxSpread = imgui.InputInt("Max MSX Spread", settings.maxSpread)
    _, settings.distance = imgui.InputInt2("Distance Between Lines", settings.distance)

    _, settings.spacing = imgui.InputFloat("MS Spacing", settings.spacing)

    _, settings.polynomialCoefficients = imgui.InputFloat3("Coefficients", settings.polynomialCoefficients, "%.2f")

    _, settings.inverse = imgui.Checkbox("Inverse?", settings.inverse)

    local offsets = getStartAndEndNoteOffsets()

    if rangeActivated(offsets) then
        local currentTime = offsets.startOffset + 1

        local iterations = 0
        local lines = {}
        local svs = {}

        while ((currentTime + (2 / INCREMENT)) <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset)

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
    end
    plot(settings.polynomialCoefficients)




    saveStateVariables("animation_spectrum", settings)
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

    if rangeActivated(offsets) then
        startMsxTable = strToTable(settings.msxList1, "%S+")
        endMsxTable = strToTable(settings.msxList2, "%S+")

        local currentTime = offsets.startOffset + 1
        local iterations = 0
        local lines = {}
        local svs = {}

        while (currentTime < offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset) ^
                (1 / settings.progressionExponent)

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
    end

    saveParameters("animation_manual", parameterTable)
end
 
 
 function IncrementalAnimationMenu()
    local settings = {
        msxList = "50 100 150 200",
        spacing = DEFAULT_SPACING,
        bounce = false
    }

    retrieveStateVariables("animation_incremental", settings)

    _, settings.msxList = imgui.InputText("List", settings.msxList, 6942)
    _, settings.spacing = imgui.InputFloat("MS Spacing", settings.spacing)

    if imgui.RadioButton("12341234", not settings.bounce) then
        settings.bounce = false
    end

    imgui.SameLine(0, 7.5)

    if imgui.RadioButton("1234321", settings.bounce) then
        settings.bounce = true
    end

    local offsets = getStartAndEndNoteOffsets()

    if rangeActivated(offsets) then
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

            for i = 1, currentHeight do
                table.insert(msxTable, totalMsxTable[i])
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
    end

    saveStateVariables("animation_incremental", settings)
end
 
 
 function GlitchMenu()
    local parameterTable = constructParameters('msxBounds1', 'msxBounds2', 'lineCount', 'fps', 'spacing')

    retrieveParameters("glitch", parameterTable)

    parameterInputs(parameterTable)

    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if rangeActivated(offsets) then
        local currentTime = offsets.startOffset
        local lines = {}
        local svs = {}

        while (currentTime <= offsets.endOffset) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset)

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
    end



    saveParameters("glitch", parameterTable)
end
 
 
 function ExpansionContractionMenu()
    local parameterTable = constructParameters('msxBounds', 'distance', 'spacing')

    retrieveParameters("animation_expansion_contraction", parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)
    local offsets = getStartAndEndNoteOffsets()

    if rangeActivated(offsets) then
        local currentTime = offsets.startOffset + 1

        local iterations = 0

        local lines = {}
        local svs = {}

        while (currentTime <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset)

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
    end

    saveParameters("animation_expansion_contraction", parameterTable)
end
 
 
 function StaticBoundaryMenu()
    local settings = {
        msxBounds = DEFAULT_MSX_BOUNDS,
        spacing = DEFAULT_SPACING,
        distance = DEFAULT_DISTANCE,
        polynomialCoefficients = { -4, 4, 0 },
        evalUnder = true,
        debug = 'Lines // SVs'
    }

    retrieveStateVariables("animation_polynomial", settings)

    _, settings.msxBounds = imgui.InputInt2("Start/End MSX", settings.msxBounds)
    _, settings.distance = imgui.InputInt2("Distance Between Lines", settings.distance)

    _, settings.spacing = imgui.InputFloat("MS Spacing", settings.spacing)

    _, settings.polynomialCoefficients = imgui.InputFloat3("Coefficients", settings.polynomialCoefficients, "%.2f")

    if imgui.RadioButton("Render Over Boundary", not settings.evalUnder) then
        settings.evalUnder = false
    end

    imgui.SameLine(0, 7.5)

    if imgui.RadioButton("Render Under Boundary", settings.evalUnder) then
        settings.evalUnder = true
    end

    local offsets = getStartAndEndNoteOffsets()

    if rangeActivated(offsets) then
        local currentTime = offsets.startOffset + 1

        local iterations = 0
        local lines = {}
        local svs = {}


        while ((currentTime + (2 / INCREMENT)) <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset)

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
    end

    plot(settings.polynomialCoefficients)



    saveStateVariables("animation_polynomial", settings)
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

        while ((currentTime + (2 / INCREMENT)) <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset)

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
    end
    plot(settings.polynomialCoefficients)




    saveStateVariables("animation_polynomial", settings)
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
    fps = DEFAULT_FPS
}


function constructParameters(...)
    local parameterTable = {}

    for _, v in ipairs({ ... }) do
        table.insert(parameterTable, {
            key = v,
            value = DEFAULT_DICTIONARY[v]
        })
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
    local lastLineTime = lines[#lines].StartTime

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
    upper = upper or map.GetNearestSnapTimeFromTime(true, 1, lower);

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
 
 function activationButton(text)
    text = text or "Place"
    return imgui.Button(text .. " Lines")
end

function rangeActivated(offsets, text)
    text = text or "Place"
    if rangeSelected(offsets) then
        return activationButton(text) or (utils.IsKeyPressed(keys.A) and not utils.IsKeyDown(keys.LeftControl))
    else
        return imgui.Text("Select a Region to " .. text .. " Lines.")
    end
end

function noteActivated(offsets, text)
    text = text or "Place"
    if noteSelected(offsets) then
        return activationButton(text) or (utils.IsKeyPressed(keys.A) and not utils.IsKeyDown(keys.LeftControl))
    else
        return imgui.Text("Select a Note to " .. text .. " Lines.")
    end
end
 
 
 function tooltip(text)
    if not imgui.IsItemHovered() then return end
    imgui.BeginTooltip()
    imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
    imgui.Text(text)
    imgui.PopTextWrapPos()
    imgui.EndTooltip()
end
 
 
 function plot(polynomialCoefficients)
    imgui.Begin("Boundary Height vs. Time", imgui_window_flags.AlwaysAutoResize)

    local RESOLUTION = 20
    local tbl = {}
    for i = 0, RESOLUTION do
        local progress = i / RESOLUTION

        table.insert(tbl,
            (polynomialCoefficients[1] * progress ^ 2 + polynomialCoefficients[2] * progress + polynomialCoefficients[3]))
    end



    imgui.PlotLines("", tbl, #tbl, 0,
        'Equation: y = ' ..
        polynomialCoefficients[1] .. 't^2 + ' .. polynomialCoefficients[2] .. 't + ' .. polynomialCoefficients[3], 0,
        1,
        { 250, 150 })

    imgui.End()
end
 
 
 function InputIntWrapper(label, v)
    _, v = imgui.InputInt(label, v, 0, 0)
    return v
end

function InputFloatWrapper(label, v)
    _, v = imgui.InputFloat(label, v, 0, 0, "%.2f")
    return v
end

function InputTextWrapper(label, v)
    _, v = imgui.InputText(label, v, 6942)
    return v
end

function InputInt2Wrapper(label, v)
    _, v = imgui.InputInt2(label, v)
    return v
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
        deletionType = 1
    }

    retrieveStateVariables("deletion", settings)

    local deletionTypeIndex = settings.deletionType - 1
    local _, deletionTypeIndex = imgui.Combo("Deletion Type", deletionTypeIndex, DELETION_TYPE_LIST,
        #DELETION_TYPE_LIST)
    addSeparator()
    settings.deletionType = deletionTypeIndex + 1

    local offsets = getStartAndEndNoteOffsets()

    if (rangeActivated(offsets, "Remove")) then
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
