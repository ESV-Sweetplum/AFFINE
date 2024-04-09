DEFAULT_MENU_ID = 1                            -- integer

DEFAULT_MSX_LIST = '69 420 727 1337'           -- integer[any]
DEFAULT_DELAY = 1                              -- integer
DEFAULT_OFFSET = 0                             -- integer
DEFAULT_SPACING = 1.1                          -- float
DEFAULT_MSX_BOUNDS = { 0, 400 }                -- integer[2]
DEFAULT_DISTANCE = { 15, 15 }                  -- integer[2]
DEFAULT_LINE_COUNT = 10                        -- integer
DEFAULT_FPS = 90                               -- float
DEFAULT_CENTER = 200                           -- integer
DEFAULT_MAX_SPREAD = 200                       -- integer
DEFAULT_PROGRESSION_EXPONENT = 1               -- float
DEFAULT_POLYNOMIAL_COEFFICIENTS = { -4, 4, 0 } -- integer[3]
DEFAULT_COLOR_LIST = '1 8 4 16 2 12 3 6'       -- integer[any]

INCREMENT = 64                                 -- integer
MAX_ITERATIONS = 1000                          -- integer

-- END DEFAULT SETTINGS (DONT DELETE THIS LINE)

ANIMATION_MENU_LIST = {
    'Manual (Basic)',
    'Incremental',
    'Boundary (Static)',
    'Boundary (Dynamic)',
    'Glitch',
    'Spectrum',
    'Expansion / Contraction'
}

CREATE_TAB_LIST = {
    'Standard',
    'Fixed',
    'Animation (LAGGY)'
}

DELETION_TYPE_LIST = {
    'Timing Lines + Scroll Velocities',
    'Timing Lines Only',
    'Scroll Velocities Only',
}

EDIT_TAB_LIST = {
    "Copy + Paste",
    -- "Offset"
}

FIXED_MENU_LIST = {
    'Manual',
    'Automatic',
    'Random'
}

STANDARD_MENU_LIST = {
    'Spread',
    'At Notes (Preserve Location)',
    'At Notes (Preserve Snap)',
    "Rainbow"
}

function DeleteMenu()
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

function CreateMenu(menuName, typeText, list, functions)
    local settings = {
        menuID = DEFAULT_MENU_ID
    }

    retrieveStateVariables(menuName, settings)

    local createMenuIndex = settings.menuID - 1
    local _, createMenuIndex = imgui.Combo(typeText .. " Type", createMenuIndex, list,
        #list)
    addSeparator()
    settings.menuID = createMenuIndex + 1

    chooseMenu(functions, settings.menuID)

    saveStateVariables(menuName, settings)
end

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

        local notes = getNotesInRange(offsets.startOffset, offsets.endOffset)
        if (type(notes) ~= "integer") then
            for _, note in pairs(notes) do
                lines = concatTables(lines, keepColorLine(note.StartTime, true))
            end
        end

        lines = cleanLines(lines, offsets.startOffset, offsets.endOffset + 10)

        parameterTable[#parameterTable].value = "Line Count: " .. #lines -- DEBUG TEXT

        actions.PlaceTimingPointBatch(lines)
    end

    saveParameters('standard_spread', parameterTable)
end

function StandardRainbowMenu()
    local parameterTable = constructParameters("colorList")

    retrieveParameters("rainbow", parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)
    local offsets = getSelectedOffsets()
    if NoteActivated(offsets) then
        local lines = {}
        local rainbowTable = strToTable(settings.colorList, "%S+")
        local rainbowIndex = 1

        if (type(offsets) == "integer") then return end

        local hidden = false

        for _, offset in pairs(offsets) do
            if (rainbowIndex == 1) then hidden = false else hidden = true end
            lines = concatTables(lines, applyColorToTime(rainbowTable[rainbowIndex], offset, hidden))
            rainbowIndex = rainbowIndex + 1
            if (rainbowIndex > #rainbowTable) then
                rainbowIndex = 1
            end
        end

        lines = cleanLines(lines, offsets[1] - 10, offsets[#offsets] + 10)

        actions.PlaceTimingPointBatch(lines)
    end

    saveParameters("rainbow", parameterTable)
end

function StandardAtNotesMenu(preservationType)
    local offsets = getSelectedOffsets()

    if NoteActivated(offsets) then
        local lines = {}

        if (type(offsets) == "integer") then return end

        if (preservationType == 1) then -- PRESERVE SNAP
            for _, offset in pairs(offsets) do
                lines = concatTables(lines, keepColorLine(offset))
            end
        else -- PRESERVE LOCATION
            for _, offset in pairs(offsets) do
                table.insert(lines, line(offset))
            end
        end
        lines = cleanLines(lines, offsets[1], offsets[#offsets] + 10)

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

function CopyAndPasteMenu()
    local offsets = getStartAndEndNoteOffsets()

    local storedLines = state.GetValue("storedLines") or {}
    local storedSVs = state.GetValue("storedSVs") or {}

    if RangeActivated(offsets, "Copy") then
        if (type(offsets) == "integer") then return end

        local lines = getLinesInRange(offsets.startOffset, offsets.endOffset)
        local svs = getSVsInRange(offsets.startOffset, offsets.endOffset)

        local zeroOffsetLines = {}
        local zeroOffsetSVs = {}

        for _, givenLine in pairs(lines) do
            table.insert(zeroOffsetLines,
                line(givenLine.StartTime - offsets.startOffset, givenLine.Bpm, givenLine.Hidden))
        end
        imgui.Text("hi 3")

        for _, givenSV in pairs(svs) do
            table.insert(zeroOffsetSVs, sv(givenSV.StartTime - offsets.startOffset, givenSV.Multiplier))
        end
        imgui.Text("hi 4")

        state.SetValue("storedLines", zeroOffsetLines)
        state.SetValue("storedSVs", zeroOffsetSVs)
        imgui.Text("hi 5")
    end

    if (#storedLines or #storedSVs) then
        if NoteActivated(offsets, "Paste") then
            if (type(offsets) == "integer") then return end

            local linesToAdd = {}
            local svsToAdd = {}

            for _, storedLine in pairs(storedLines) do
                table.insert(linesToAdd,
                    line(storedLine.StartTime + offsets.startOffset, storedLine.Bpm, storedLine.Hidden))
            end
            for _, storedSV in pairs(storedSVs) do
                table.insert(svsToAdd, sv(storedSV.StartTime + offsets.startOffset, storedSV.Multiplier))
            end

            actions.PerformBatch({
                utils.CreateEditorAction(action_type.AddTimingPointBatch, linesToAdd),
                utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svsToAdd),
            })
        end
    end

    addSeparator()

    imgui.Text(#storedLines .. " Stored Lines // " .. #storedSVs .. " Stored SVs")
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

function keepColorLine(time, hidden)
    color = colorFromTime(time)
    return applyColorToTime(color, time, hidden or false)
end

function colorFromTime(time)
    local timingPoint = map.GetTimingPointAt(time)
    if (not timingPoint) then return 1 end
    barToBarDistance = (60000 / timingPoint.Bpm) or 69
    local timeAboveBar = (time - timingPoint.StartTime) % barToBarDistance

    if (timeAboveBar < barToBarDistance / 17) then return 1 end
    if ((barToBarDistance - (time - timingPoint.StartTime)) % barToBarDistance < barToBarDistance / 17) then return 1 end

    if (timeAboveBar > (barToBarDistance / 2)) then
        approximateSnap = barToBarDistance / ((barToBarDistance - (time - timingPoint.StartTime)) % barToBarDistance)
    else
        approximateSnap = barToBarDistance / timeAboveBar
    end

    return approximateSnap -- ROUNDING
end

function applyColorToTime(color, time, hidden)
    local lines = {}

    ---@diagnostic disable-next-line: undefined-field
    local bpm = map.GetTimingPointAt(time).Bpm

    local timingDist = 4

    if (color == 1) then
        table.insert(lines, line(time, bpm, hidden))
    else
        table.insert(lines, line(time - timingDist / 2, 60000 / (timingDist * color / 2), hidden))
        table.insert(lines, line(time + timingDist / 2, bpm, hidden))
    end

    return lines
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

function getNotesInRange(lower, upper)
    local base = map.HitObjects

    local tbl = {}

    for _, v in pairs(base) do
        if (v.StartTime >= lower) and (v.StartTime <= upper) then
            table.insert(tbl, v)
        end
    end

    return tbl
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

function line(time, bpm, hidden)
    if (hidden == nil) then hidden = false end
    local data = map.GetTimingPointAt(time)

    if (not data) then
        data = {
            Bpm = map.GetCommonBpm(),
            Signature = time_signature.Quadruple,
            Hidden = false
        }
    end

    return utils.CreateTimingPoint(time, bpm or data.Bpm, data.Signature, hidden)
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

    local lineDictionary = {}

    for _, currentLine in pairs(lines) do
        if (table.contains(lineDictionary, currentLine.StartTime)) then goto continue end
        if (currentLine.StartTime >= lower and currentLine.StartTime <= upper) then
            table.insert(tbl, currentLine)
            table.insert(lineDictionary, currentLine.StartTime)
        end
        ::continue::
    end

    table.insert(tbl, line(map.GetNearestSnapTimeFromTime(true, 1, lastLineTime) - 2))
    table.insert(tbl, line(map.GetNearestSnapTimeFromTime(true, 1, lastLineTime)))

    return tbl
end

function generateAffines(lines, svs, lower, upper, keepColors)
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

---@diagnostic disable: undefined-field, need-check-nil
function drawSpike(xPos)
    local spikeSize = 25

    local color = rgbaToUint(255, 255, 255, 255)
    local o = imgui.GetOverlayDrawList()
    local sz = state.WindowSize

    o.AddTriangleFilled({ xPos, sz[2] }, { xPos + sz[1] / spikeSize, sz[2] },
        { xPos + sz[1] / (2 * spikeSize), sz[2] - sz[1] / spikeSize }, color)
end

---@diagnostic disable: need-check-nil, undefined-field
function relativePoint(point, xChange, yChange)
    return { point[1] + xChange, point[2] + yChange }
end

function drawCapybara2(yPos)
    local o = imgui.GetOverlayDrawList()
    local sz = state.WindowSize

    local topLeftCapyPoint = { 0, sz[2] - 165 - yPos } -- originally -200
    local p1 = relativePoint(topLeftCapyPoint, 0, 95)
    local p2 = relativePoint(topLeftCapyPoint, 0, 165)
    local p3 = relativePoint(topLeftCapyPoint, 58, 82)
    local p3b = relativePoint(topLeftCapyPoint, 108, 82)
    local p4 = relativePoint(topLeftCapyPoint, 58, 165)
    local p5 = relativePoint(topLeftCapyPoint, 66, 29)
    local p6 = relativePoint(topLeftCapyPoint, 105, 10)
    local p7 = relativePoint(topLeftCapyPoint, 122, 126)
    local p7b = relativePoint(topLeftCapyPoint, 133, 107)
    local p8 = relativePoint(topLeftCapyPoint, 138, 11)
    local p9 = relativePoint(topLeftCapyPoint, 145, 82)
    local p10 = relativePoint(topLeftCapyPoint, 167, 82)
    local p10b = relativePoint(topLeftCapyPoint, 172, 80)
    local p11 = relativePoint(topLeftCapyPoint, 172, 50)
    local p12 = relativePoint(topLeftCapyPoint, 179, 76)
    local p12b = relativePoint(topLeftCapyPoint, 176, 78)
    local p12c = relativePoint(topLeftCapyPoint, 176, 70)
    local p13 = relativePoint(topLeftCapyPoint, 185, 50)

    local p14 = relativePoint(topLeftCapyPoint, 113, 10)
    local p15 = relativePoint(topLeftCapyPoint, 116, 0)
    local p16 = relativePoint(topLeftCapyPoint, 125, 2)
    local p17 = relativePoint(topLeftCapyPoint, 129, 11)
    local p17b = relativePoint(topLeftCapyPoint, 125, 11)

    local p18 = relativePoint(topLeftCapyPoint, 91, 0)
    local p19 = relativePoint(topLeftCapyPoint, 97, 0)
    local p20 = relativePoint(topLeftCapyPoint, 102, 1)
    local p21 = relativePoint(topLeftCapyPoint, 107, 11)
    local p22 = relativePoint(topLeftCapyPoint, 107, 19)
    local p23 = relativePoint(topLeftCapyPoint, 103, 24)
    local p24 = relativePoint(topLeftCapyPoint, 94, 17)
    local p25 = relativePoint(topLeftCapyPoint, 88, 9)

    local p26 = relativePoint(topLeftCapyPoint, 123, 33)
    local p27 = relativePoint(topLeftCapyPoint, 132, 30)
    local p28 = relativePoint(topLeftCapyPoint, 138, 38)
    local p29 = relativePoint(topLeftCapyPoint, 128, 40)

    local p30 = relativePoint(topLeftCapyPoint, 102, 133)
    local p31 = relativePoint(topLeftCapyPoint, 105, 165)
    local p32 = relativePoint(topLeftCapyPoint, 113, 165)

    local p33 = relativePoint(topLeftCapyPoint, 102, 131)
    local p34 = relativePoint(topLeftCapyPoint, 82, 138)
    local p35 = relativePoint(topLeftCapyPoint, 85, 165)
    local p36 = relativePoint(topLeftCapyPoint, 93, 165)

    local p37 = relativePoint(topLeftCapyPoint, 50, 80)
    local p38 = relativePoint(topLeftCapyPoint, 80, 40)
    local p39 = relativePoint(topLeftCapyPoint, 115, 30)
    local p40 = relativePoint(topLeftCapyPoint, 40, 92)
    local p41 = relativePoint(topLeftCapyPoint, 80, 53)
    local p42 = relativePoint(topLeftCapyPoint, 107, 43)
    local p43 = relativePoint(topLeftCapyPoint, 40, 104)
    local p44 = relativePoint(topLeftCapyPoint, 70, 56)
    local p45 = relativePoint(topLeftCapyPoint, 100, 53)
    local p46 = relativePoint(topLeftCapyPoint, 45, 134)
    local p47 = relativePoint(topLeftCapyPoint, 50, 80)
    local p48 = relativePoint(topLeftCapyPoint, 70, 87)
    local p49 = relativePoint(topLeftCapyPoint, 54, 104)
    local p50 = relativePoint(topLeftCapyPoint, 50, 156)
    local p51 = relativePoint(topLeftCapyPoint, 79, 113)
    local p52 = relativePoint(topLeftCapyPoint, 55, 24)
    local p53 = relativePoint(topLeftCapyPoint, 85, 25)
    local p54 = relativePoint(topLeftCapyPoint, 91, 16)
    local p55 = relativePoint(topLeftCapyPoint, 45, 33)
    local p56 = relativePoint(topLeftCapyPoint, 75, 36)
    local p57 = relativePoint(topLeftCapyPoint, 81, 22)
    local p58 = relativePoint(topLeftCapyPoint, 45, 43)
    local p59 = relativePoint(topLeftCapyPoint, 73, 38)
    local p60 = relativePoint(topLeftCapyPoint, 61, 32)
    local p61 = relativePoint(topLeftCapyPoint, 33, 55)
    local p62 = relativePoint(topLeftCapyPoint, 73, 45)
    local p63 = relativePoint(topLeftCapyPoint, 55, 36)
    local p64 = relativePoint(topLeftCapyPoint, 32, 95)
    local p65 = relativePoint(topLeftCapyPoint, 53, 42)
    local p66 = relativePoint(topLeftCapyPoint, 15, 75)
    local p67 = relativePoint(topLeftCapyPoint, 0, 125)
    local p68 = relativePoint(topLeftCapyPoint, 53, 62)
    local p69 = relativePoint(topLeftCapyPoint, 0, 85)
    local p70 = relativePoint(topLeftCapyPoint, 0, 165)
    local p71 = relativePoint(topLeftCapyPoint, 29, 112)
    local p72 = relativePoint(topLeftCapyPoint, 0, 105)

    local p73 = relativePoint(topLeftCapyPoint, 73, 70)
    local p74 = relativePoint(topLeftCapyPoint, 80, 74)
    local p75 = relativePoint(topLeftCapyPoint, 92, 64)
    local p76 = relativePoint(topLeftCapyPoint, 60, 103)
    local p77 = relativePoint(topLeftCapyPoint, 67, 83)
    local p78 = relativePoint(topLeftCapyPoint, 89, 74)
    local p79 = relativePoint(topLeftCapyPoint, 53, 138)
    local p80 = relativePoint(topLeftCapyPoint, 48, 120)
    local p81 = relativePoint(topLeftCapyPoint, 73, 120)
    local p82 = relativePoint(topLeftCapyPoint, 46, 128)
    local p83 = relativePoint(topLeftCapyPoint, 48, 165)
    local p84 = relativePoint(topLeftCapyPoint, 74, 150)
    local p85 = relativePoint(topLeftCapyPoint, 61, 128)
    local p86 = relativePoint(topLeftCapyPoint, 83, 100)
    local p87 = relativePoint(topLeftCapyPoint, 90, 143)
    local p88 = relativePoint(topLeftCapyPoint, 73, 143)
    local p89 = relativePoint(topLeftCapyPoint, 120, 107)
    local p90 = relativePoint(topLeftCapyPoint, 116, 133)
    local p91 = relativePoint(topLeftCapyPoint, 106, 63)
    local p92 = relativePoint(topLeftCapyPoint, 126, 73)
    local p93 = relativePoint(topLeftCapyPoint, 127, 53)
    local p94 = relativePoint(topLeftCapyPoint, 91, 98)
    local p95 = relativePoint(topLeftCapyPoint, 101, 76)
    local p96 = relativePoint(topLeftCapyPoint, 114, 99)
    local p97 = relativePoint(topLeftCapyPoint, 126, 63)
    local p98 = relativePoint(topLeftCapyPoint, 156, 73)
    local p99 = relativePoint(topLeftCapyPoint, 127, 53)

    local color1 = rgbaToUint(250, 250, 225, 255)
    local color2 = rgbaToUint(240, 180, 140, 255)
    local color3 = rgbaToUint(195, 90, 120, 255)
    local color4 = rgbaToUint(115, 5, 65, 255)

    local color5 = rgbaToUint(100, 5, 45, 255)
    local color6 = rgbaToUint(200, 115, 135, 255)
    local color7 = rgbaToUint(175, 10, 70, 255)
    local color8 = rgbaToUint(200, 90, 110, 255)
    local color9 = rgbaToUint(125, 10, 75, 255)
    local color10 = rgbaToUint(220, 130, 125, 255)

    o.AddQuadFilled(p18, p19, p24, p25, color4)
    o.AddQuadFilled(p19, p20, p21, p22, color1)
    o.AddQuadFilled(p19, p22, p23, p24, color4)

    o.AddQuadFilled(p14, p15, p16, p17, color4)
    o.AddTriangleFilled(p17b, p16, p17, color1)

    o.AddQuadFilled(p1, p2, p4, p3, color3)
    o.AddQuadFilled(p1, p3, p6, p5, color3)
    o.AddQuadFilled(p3, p4, p7, p9, color2)
    o.AddQuadFilled(p3, p6, p11, p10, color2)
    o.AddQuadFilled(p6, p8, p13, p11, color1)
    o.AddQuadFilled(p13, p12, p10, p11, color6)
    o.AddTriangleFilled(p10b, p12b, p12c, color7)

    o.AddTriangleFilled(p9, p7b, p3b, color8)

    o.AddQuadFilled(p26, p27, p28, p29, color5)

    o.AddQuadFilled(p7, p30, p31, p32, color5)
    o.AddQuadFilled(p33, p34, p35, p36, color5)

    o.AddTriangleFilled(p37, p38, p39, color8)
    o.AddTriangleFilled(p40, p41, p42, color8)
    o.AddTriangleFilled(p43, p44, p45, color8)
    o.AddTriangleFilled(p46, p47, p48, color8)
    o.AddTriangleFilled(p49, p50, p51, color2)

    o.AddTriangleFilled(p52, p53, p54, color9)
    o.AddTriangleFilled(p55, p56, p57, color9)
    o.AddTriangleFilled(p58, p59, p60, color9)
    o.AddTriangleFilled(p61, p62, p63, color9)
    o.AddTriangleFilled(p64, p65, p66, color9)
    o.AddTriangleFilled(p67, p68, p69, color9)
    o.AddTriangleFilled(p70, p71, p72, color9)

    o.AddTriangleFilled(p73, p74, p75, color10)
    o.AddTriangleFilled(p76, p77, p78, color10)
    o.AddTriangleFilled(p79, p80, p81, color10)
    o.AddTriangleFilled(p82, p83, p84, color10)
    o.AddTriangleFilled(p85, p86, p87, color10)
    o.AddTriangleFilled(p88, p89, p90, color10)
    o.AddTriangleFilled(p91, p92, p93, color10)
    o.AddTriangleFilled(p94, p95, p96, color10)
    o.AddTriangleFilled(p97, p98, p99, color10)
end

function rgbaToUint(r, g, b, a) return a * 16 ^ 6 + b * 16 ^ 4 + g * 16 ^ 2 + r end

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

    -- drawCapybara2(0)
    -- drawSpike(state.WindowSize[1] * 1.5 / 25)

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

CREATE_TAB_FUNCTIONS = {
    function () CreateMenu("Standard", "Standard Placement", STANDARD_MENU_LIST, STANDARD_MENU_FUNCTIONS) end,
    function () CreateMenu("Fixed", "Fixed Placement", FIXED_MENU_LIST, FIXED_MENU_FUNCTIONS) end,
    function () CreateMenu("Animation", "Animation", ANIMATION_MENU_LIST, ANIMATION_MENU_FUNCTIONS) end
}

EDIT_TAB_FUNCTIONS = {
    CopyAndPasteMenu,
    -- function () end -- OffsetMenu
}

FIXED_MENU_FUNCTIONS = {
    FixedManualMenu,
    FixedAutomaticMenu,
    FixedRandomMenu
}

STANDARD_MENU_FUNCTIONS = {
    StandardSpreadMenu,
    function () StandardAtNotesMenu(2) end,
    function () StandardAtNotesMenu(1) end,
    StandardRainbowMenu
}

    retrieveStateVariables("main", settings)

    imgui.BeginTabBar("Main Tabs")

    if imgui.BeginTabItem("Create") then
        local mainMenuIndex = settings.menuID - 1
        local _, mainMenuIndex = imgui.Combo("Line Placement Type", mainMenuIndex, CREATE_TAB_LIST, #CREATE_TAB_LIST)
        settings.menuID = mainMenuIndex + 1
        chooseMenu(CREATE_TAB_FUNCTIONS, settings.menuID)
        imgui.EndTabItem()
    end

    if imgui.BeginTabItem("Edit") then
        local mainMenuIndex = settings.menuID - 1
        local _, mainMenuIndex = imgui.Combo("Edit Type", mainMenuIndex, EDIT_TAB_LIST, #EDIT_TAB_LIST)
        settings.menuID = mainMenuIndex + 1
        chooseMenu(EDIT_TAB_FUNCTIONS, settings.menuID)
        imgui.EndTabItem()
    end
    if imgui.BeginTabItem("Delete") then
        DeleteMenu()
        imgui.EndTabItem()
    end

    imgui.EndTabBar()

    saveStateVariables("main", settings)

    imgui.End()
end

function addPadding()
    imgui.Dummy({ 0, 0 })
end

function addSeparator()
    addPadding()
    imgui.Separator()
    addPadding()
end
