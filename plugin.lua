---@diagnostic disable: duplicate-set-field
DEFAULT_MENU_ID = 1                          -- integer

DEFAULT_MSX_LIST = '69 420 727 1337'         -- integer[any]
DEFAULT_DELAY = 1                            -- integer
DEFAULT_OFFSET = 0                           -- integer
DEFAULT_SPACING = 1.1                        -- float
DEFAULT_MSX_BOUNDS = { 0, 400 }              -- integer[2]
DEFAULT_DISTANCE = { 15, 15 }                -- integer[2]
DEFAULT_LINE_COUNT = 10                      -- integer
DEFAULT_LINE_DURATION = 0.5                  -- integer
DEFAULT_FPS = 91                             -- float
DEFAULT_CENTER = 200                         -- integer
DEFAULT_MAX_SPREAD = 200                     -- integer
DEFAULT_PROGRESSION_EXPONENT = 1             -- float
DEFAULT_BOUND_COEFFICIENTS = { 0, -4, 4, 0 } -- integer[4]
DEFAULT_PATH_COEFFICIENTS = { -1, 3, -3, 1 } -- integer[4]
DEFAULT_COLOR_LIST = '1 8 4 16 12 2 3 6'     -- integer[any]

INCREMENT = 64                               -- integer
MAX_ITERATIONS = 1000                        -- integer
FRAME_SIZE = 500                             -- integer

SPLITSCROLL_MODE = true                      -- boolean
OFFSET_SECURITY_CONSTANT = 2                 -- integer

-- END DEFAULT SETTINGS (DONT DELETE THIS LINE)

LINE_STANDARD_MENU_LIST = {
    'Spread',
    'At Notes (Preserve Location)',
    'At Notes (Preserve Snap)',
    "Rainbow"
}

CREATE_LINE_TAB_LIST = {
    'Standard',
    'Fixed',
    'Animation (LAGGY)'
}

SV_VIBRO_MENU_LIST = {
    "Linear",
    "Polynomial",
    "Stack"
}

CREATE_SV_TAB_LIST = {
    "Still Vibro"
}

DELETION_TYPE_LIST = {
    'Timing Lines + Scroll Velocities',
    'Timing Lines Only',
    'Scroll Velocities Only',
}

EDIT_TAB_LIST = {
    "Add Forefront Teleport",
    "Copy + Paste",
    "Set Line Visibility",
    "Reverse SV Order"
}

function ManualDeleteTab()
    local settings = {
        deletionType = DEFAULT_MENU_ID
    }

    retrieveStateVariables("deletion", settings)

    local deletionTypeIndex = settings.deletionType - 1
    local _, deletionTypeIndex = imgui.Combo("Deletion Type", deletionTypeIndex, DELETION_TYPE_LIST,
        #DELETION_TYPE_LIST)
    addSeparator()
    settings.deletionType = deletionTypeIndex + 1

    if (RangeActivated("Remove")) then
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

---Create Menu
---@param menuName string
---@param typeText string
---@param list string[]
---@param functions fun()[]
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

function AutomaticDeleteTab()
    local selectedID = state.GetValue("selectedID") or 1

    for id, tbl in pairs(globalData) do
        imgui.Selectable(
            "Type: " ..
            tbl.label ..
            " // Lower/Upper Offset: " ..
            tbl.lower .. ":" .. tbl.upper .. " // # Lines: " .. tbl.numLines .. " // # SVs: " .. tbl.numSVs,
            selectedID == id)
        if (imgui.IsItemClicked()) then
            selectedID = id
        end
    end

    if (#globalData == 0) then
        imgui.Text("Create an animation or fixed lines to display them here.")
    else
        if (imgui.Button("Delete selected item")) then
            tbl = globalData[selectedID]

            local linesToRemove = getLinesInRange(tbl.lower, tbl.upper)
            local svsToRemove = getSVsInRange(tbl.lower, tbl.upper)

            actions.PerformBatch({
                utils.CreateEditorAction(action_type.RemoveTimingPointBatch, linesToRemove),
                utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, svsToRemove),
                -- utils.CreateEditorAction(action_type.RemoveBookmarkBatch, bookmarksToRemove)
            })

            table.remove(globalData, selectedID)
            saveMapState(globalData)
        end

        if (imgui.Button("Delete faulty entry")) then
            table.remove(globalData, selectedID)
            saveMapState(globalData)
        end
    end

    state.SetValue("selectedID", selectedID)
end

---@diagnostic disable: undefined-field

function stackVibroMenu()
    local settings = parameterWorkflow("stackVibro", "msxList", "fps")

    if RangeActivated() then
        local tbl = table.split(settings.msxList, "%S+")

        placeVibratoSVsByTbl(tbl, settings.fps)
    end
end

function placeVibratoSVsByTbl(tbl, fps)
    local currentTime = offsets.startOffset + OFFSET_SECURITY_CONSTANT
    local svs = {}
    local iterations = 1

    while (currentTime <= offsets.endOffset - 1) and (iterations <= MAX_ITERATIONS) do
        local _, decimalValue = math.modf(currentTime)
        if (decimalValue < 0.1) then currentTime = math.floor(currentTime) + 0.1 end
        if (decimalValue > 0.9) then currentTime = math.ceil(currentTime) - 0.1 end

        local vibroHeight = tbl[((iterations - 1) % #tbl) + 1]
        local recentSVValue = 1
        if (map.GetScrollVelocityAt(currentTime)) then recentSVValue = map.GetScrollVelocityAt(currentTime).Multiplier end

        local tempSVTbl = insertTeleport({}, currentTime, vibroHeight * -1, recentSVValue)
        currentTime = currentTime + 1000 / fps
        tempSVTbl = insertTeleport(tempSVTbl, currentTime, vibroHeight, recentSVValue)

        if (currentTime < offsets.endOffset - OFFSET_SECURITY_CONSTANT) then
            svs = combineTables(svs, tempSVTbl)
        end

        currentTime = currentTime + 1000 / fps
        iterations = iterations + 1
    end

    actions.PlaceScrollVelocityBatch(cleanSVs(svs, offsets.startOffset + OFFSET_SECURITY_CONSTANT,
        offsets.endOffset - OFFSET_SECURITY_CONSTANT))

    setDebug("SV Count: " .. #svs)
end

---@diagnostic disable: undefined-field
function polynomialVibroMenu()
    local settings = parameterWorkflow("polynomialVibro", "msxBounds", "boundCoefficients", "fps",
        "progressionExponent", {
            inputType = "Checkbox",
            key = "oneSided",
            label = "One-Sided Vibro?",
            value = false
        })

    if RangeActivated() then
        local vibroHeightFn = function (v)
            return mapProgress(settings.msxBounds[1], evaluateCoefficients(settings.boundCoefficients,
                    getProgress(offsets.startOffset, v, offsets.endOffset, settings.progressionExponent)),
                settings.msxBounds[2])
        end

        placeVibratoGroupsByFn(vibroHeightFn, settings.oneSided, settings.fps)
    end
end

---@diagnostic disable: undefined-field
function linearVibroMenu()
    local settings = parameterWorkflow("linearVibro", "msxBounds", "fps", "progressionExponent", {
        inputType = "Checkbox",
        key = "oneSided",
        label = "One-Sided Vibro?",
        value = false
    })

    if RangeActivated() then
        local vibroHeightFn = function (v)
            return mapProgress(settings.msxBounds[1],
                getProgress(offsets.startOffset, v, offsets.endOffset - 1, settings.progressionExponent),
                settings.msxBounds[2])
        end

        placeVibratoGroupsByFn(vibroHeightFn, settings.oneSided, settings.fps)
    end
end

---Given a vibrato height function, places a clean set of vibrato SVs.
---@param vibroHeightFn function
---@param oneSided boolean
---@param fps number
function placeVibratoGroupsByFn(vibroHeightFn, oneSided, fps)
    local selectedTimes = getSelectedOffsets()
    local svs = {}
    for i=1, #selectedTimes - 1 do
        svs = combineTables(svs, getVibratoSVsByFn(vibroHeightFn, oneSided, fps, selectedTimes[i], selectedTimes[i + 1]))
    end

    actions.PlaceScrollVelocityBatch(cleanSVs(svs, offsets.startOffset + OFFSET_SECURITY_CONSTANT,
    offsets.endOffset - OFFSET_SECURITY_CONSTANT))
    
    setDebug("SV Count: " .. #svs)
end

---Given a vibrato height function, returns a clean set of vibrato SVs between two values.
---@param vibroHeightFn function
---@param oneSided boolean
---@param fps number
---@param startTime number
---@param endTime number
---@return TimingPointInfo[]
function getVibratoSVsByFn(vibroHeightFn, oneSided, fps, startTime, endTime)
    local currentTime = startTime + OFFSET_SECURITY_CONSTANT
    local svs = {}
    local iterations = 1

    local teleportSign = 1
    while (currentTime <= endTime - 1) and (iterations <= MAX_ITERATIONS) do
        local _, decimalValue = math.modf(currentTime)
        if (decimalValue < 0.1) then currentTime = math.floor(currentTime) + 0.1 end
        if (decimalValue > 0.9) then currentTime = math.ceil(currentTime) - 0.1 end
        local vibroHeight = vibroHeightFn(currentTime)
        local recentSVValue = mostRecentSV(currentTime)

        if (oneSided) then
            local tempSVTbl = insertTeleport({}, currentTime, vibroHeight * -1, recentSVValue)
            currentTime = currentTime + 1000 / fps
            tempSVTbl = insertTeleport(tempSVTbl, currentTime, vibroHeight, recentSVValue)

            if (currentTime < endTime - OFFSET_SECURITY_CONSTANT) then
                svs = combineTables(svs, tempSVTbl)
            end
        else
            -- REDO LATER
            local tempSVTbl = insertTeleport({}, currentTime,
                iterations == 1 and vibroHeight or vibroHeight * 2 * teleportSign, recentSVValue)
                mostRecentHeight = vibroHeight * teleportSign

            if (currentTime < endTime - OFFSET_SECURITY_CONSTANT - 1) then
                svs = combineTables(svs, tempSVTbl)
                teleportSign = -1 * teleportSign
            end
        end
        currentTime = currentTime + 1000 / fps
        iterations = iterations + 1
    end

    if (not oneSided) then
        currentTime = endTime - OFFSET_SECURITY_CONSTANT - 1
        local multiplier = 1
        if (map.GetScrollVelocityAt(currentTime)) then multiplier = map.GetScrollVelocityAt(currentTime).Multiplier end
        svs = insertTeleport(svs, currentTime, mostRecentHeight * -1,
            multiplier)
    end

    return svs
end

function StandardSpreadMenu()
    local settings = parameterWorkflow("standard_spread", 'distance')

    if RangeActivated() then
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
                lines = combineTables(lines, keepColorLine(note.StartTime, true))
            end
        end

        lines = cleanLines(lines, offsets.startOffset, offsets.endOffset)

        setDebug("Line Count: " .. #lines) -- DEBUG TEXT

        actions.PlaceTimingPointBatch(lines)
    end
end

function StandardRainbowMenu()
    local settings = parameterWorkflow("standard_rainbow", "colorList")

    local times = getSelectedOffsets()
    if NoteActivated() then
        local lines = {}
        local rainbowTable = table.split(settings.colorList, "%S+")
        local rainbowIndex = 1

        if (type(times) == "integer") then return end

        local hidden = false

        for _, time in pairs(times) do
            if (rainbowIndex == 1) then hidden = false else hidden = true end
            lines = combineTables(lines, applyColorToTime(rainbowTable[rainbowIndex], time, hidden))
            rainbowIndex = rainbowIndex + 1
            if (rainbowIndex > #rainbowTable) then
                rainbowIndex = 1
            end
        end

        lines = cleanLines(lines, offsets[1] - 10, offsets[#offsets] + 10)

        actions.PlaceTimingPointBatch(lines)
    end
end

function StandardAtNotesMenu(preservationType)
    local times = getSelectedOffsets()

    if NoteActivated() then
        local lines = {}

        if (type(times) == "integer") then return end

        if (preservationType == 1) then -- PRESERVE SNAP
            for _, time in pairs(times) do
                lines = combineTables(lines, keepColorLine(time))
            end
            lines = cleanLines(lines, times[1], times[#times] + 10)
        else -- PRESERVE LOCATION
            for _, time in pairs(times) do
                table.insert(lines, line(time))
            end
        end

        actions.PlaceTimingPointBatch(lines)
    end
end

function FixedRandomMenu()
    local settings = parameterWorkflow("fixed_random", 'msxBounds', 'lineCount', 'delay', 'spacing')

    if NoteActivated() then
        msxTable = {}
        for _ = 1, settings.lineCount do
            table.insert(msxTable, math.random(settings.msxBounds[1], settings.msxBounds[2]))
        end
        local tbl = tableToAffineFrame(msxTable, offsets.startOffset + settings.delay, 0, settings.spacing)

        generateAffines(tbl.lines, tbl.svs, offsets.startOffset, offsets.endOffset, "Random Fixed")
        setDebug("Line Count: " .. #tbl.lines .. " // SV Count: " .. #tbl.svs)
    end
end

function FixedManualMenu()
    local settings = parameterWorkflow("fixed_manual", 'msxList', 'offset', 'delay', 'spacing')

    if NoteActivated() then
        msxTable = table.split(settings.msxList, "%S+")
        local tbl = tableToAffineFrame(msxTable, offsets.startOffset + settings.delay, settings.offset, settings.spacing)
        generateAffines(tbl.lines, tbl.svs, offsets.startOffset, offsets.endOffset, "Manual Fixed")

        setDebug("Line Count: " .. #tbl.lines .. " // SV Count: " .. #tbl.svs)
    end
end

function FixedAutomaticMenu()
    local settings = parameterWorkflow("fixed_automatic", 'msxBounds', 'distance', 'delay', 'spacing')

    if NoteActivated() then
        local tbl = placeAutomaticFrame(offsets.startOffset + settings.delay, settings.msxBounds[1],
            settings.msxBounds[2],
            settings.spacing, settings.distance)

        generateAffines(tbl.lines, tbl.svs, offsets.startOffset, offsets.endOffset, "Automatic Fixed")
        setDebug("Line Count: " .. #tbl.lines .. " // SV Count: " .. #tbl.svs)
    end
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
    return tableToAffineFrame(msxTable, startTime, 0, spacing)
end

function SpectrumMenu()
    local settings = parameterWorkflow("animation_spectrum", "center", "maxSpread", "distance", "progressionExponent",
        "spacing",
        "boundCoefficients", {
            inputType = "Checkbox",
            key = "inverse",
            label = "Inverse?",
            value = false
        })

    if RangeActivated() then
        local currentTime = offsets.startOffset + settings.spacing

        local iterations = 0
        local lines = {}
        local svs = {}
        local frameLengths = {}

        while ((currentTime + (2 / INCREMENT)) <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset,
                settings.progressionExponent)

            local heightDifferential = settings.maxSpread *
                evaluateCoefficients(settings.boundCoefficients, progress)

            local tbl = placeSpectrumFrame(currentTime, settings.center, settings.maxSpread, settings.distance,
                settings.spacing, heightDifferential, settings.inverse)

            if (tbl.time > offsets.endOffset) then break end

            table.insert(frameLengths, tbl.time - currentTime + 2)

            currentTime = tbl.time

            lines = combineTables(lines, tbl.lines)
            svs = combineTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, FRAME_SIZE)

            iterations = iterations + 1

            currentTime = currentTime + 2
        end

        local stats = getStatisticsFromTable(frameLengths)

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset, "Spectrum",
            constructDebugTable(lines, svs, stats))
        setDebug("Line Count: " .. #lines .. " // SV Count: " .. #svs)
    end
    Plot(settings.boundCoefficients, settings.progressionExponent)
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

        return tableToAffineFrame(msxTable, startTime, 0, spacing)
    else
        local msx = center

        while (msx <= center + boundary) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(center, msx, center + maxSpread)
            table.insert(msxTable, msx)
            table.insert(msxTable, 2 * center - msx)
            msx = msx + mapProgress(lineDistance[1], progress, lineDistance[2])
            iterations = iterations + 1
        end

        return tableToAffineFrame(msxTable, startTime, 0, spacing)
    end
end

function BasicManualAnimationMenu()
    local settings = parameterWorkflow("animation_manual", 'msxList1', 'msxList2', 'progressionExponent', 'fps',
        'spacing')

    if RangeActivated() then
        startMsxTable = table.split(settings.msxList1, "%S+")
        endMsxTable = table.split(settings.msxList2, "%S+")

        local currentTime = offsets.startOffset + settings.spacing
        local iterations = 0
        local lines = {}
        local svs = {}
        local frameLengths = {}

        while (currentTime < offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset,
                settings.progressionExponent)

            local msxTable = {}

            for i = 1, #endMsxTable do
                table.insert(msxTable, mapProgress(startMsxTable[i], progress, endMsxTable[i]))
            end

            local tbl = tableToAffineFrame(msxTable, currentTime, 0, settings.spacing)

            if (tbl.time > offsets.endOffset) then break end

            timeDiff = math.max(1000 / settings.fps - 2, tbl.time - currentTime)

            table.insert(frameLengths, timeDiff + 2)

            currentTime = currentTime + timeDiff

            lines = combineTables(lines, tbl.lines)
            svs = combineTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, FRAME_SIZE)

            currentTime = currentTime + 2
            iterations = iterations + 1
        end

        local stats = getStatisticsFromTable(frameLengths)

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset, "Manual Animation",
            constructDebugTable(lines, svs, stats))
        setDebug("Line Count: " .. #lines .. " // SV Count: " .. #svs)
    end
end

function IncrementalAnimationMenu()
    local settings = parameterWorkflow("animation_incremental", 'msxList', 'spacing', {
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

    if RangeActivated() then
        local times = getSelectedOffsets()

        local currentIndex = 1
        local currentHeight = 1

        local currentAddition = 1

        local totalMsxTable = table.split(settings.msxList, "%S+")
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
            local tbl = tableToAffineFrame(msxTable, currentTime + 5, 0, settings.spacing)

            lines = combineTables(lines, tbl.lines)
            svs = combineTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, FRAME_SIZE)

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

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset, "Incremental",
            constructDebugTable(lines, svs))
        setDebug("Line Count: " .. #lines .. " // SV Count: " .. #svs)
    end
end

function GlitchMenu()
    local settings = parameterWorkflow("animation_glitch", 'msxBounds1', 'msxBounds2', 'lineCount', 'progressionExponent',
        'fps',
        'spacing')

    if RangeActivated() then
        local currentTime = offsets.startOffset
        local lines = {}
        local svs = {}
        local frameLengths = {}

        while (currentTime <= offsets.endOffset) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset,
                settings.progressionExponent)

            local lowerBound = mapProgress(settings.msxBounds1[1], progress, settings.msxBounds2[1])
            local upperBound = mapProgress(settings.msxBounds1[2], progress, settings.msxBounds2[2])

            msxTable = {}
            for i = 1, settings.lineCount do
                table.insert(msxTable, math.random(upperBound, lowerBound))
            end
            local tbl = tableToAffineFrame(msxTable, currentTime, 0, settings.spacing)

            if (tbl.time > offsets.endOffset) then break end

            local timeDiff = math.max(1000 / settings.fps - 2, tbl.time - currentTime)

            table.insert(frameLengths, timeDiff + 2)

            currentTime = currentTime + timeDiff

            lines = combineTables(lines, tbl.lines)
            svs = combineTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, FRAME_SIZE)

            currentTime = currentTime + 2
        end

        local stats = getStatisticsFromTable(frameLengths)

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset, "Glitch",
            constructDebugTable(lines, svs, stats))
        setDebug("Line Count: " .. #lines .. " // SV Count: " .. #svs)
    end
end

function ExpansionContractionMenu()
    local settings = parameterWorkflow("animation_expansionContraction", 'msxBounds', 'distance', 'progressionExponent',
        'spacing')

    if RangeActivated() then
        local currentTime = offsets.startOffset + settings.spacing

        local iterations = 0

        local lines = {}
        local svs = {}
        local frameLengths = {}

        while (currentTime <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset,
                settings.progressionExponent)

            local distance = mapProgress(settings.distance[1], progress, settings.distance[2])

            local tbl = placeAutomaticFrame(currentTime, settings.msxBounds[1], settings.msxBounds[2], settings.spacing,
                { distance, distance })

            if (tbl.time > offsets.endOffset) then break end

            table.insert(frameLengths, tbl.time - currentTime + 2)

            currentTime = tbl.time

            lines = combineTables(lines, tbl.lines)
            svs = combineTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, FRAME_SIZE)

            iterations = iterations + 1

            currentTime = currentTime + 2
        end

        local stats = getStatisticsFromTable(frameLengths)

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset, "Expansion/Contraction",
            constructDebugTable(lines, svs, stats))
        setDebug("Line Count: " .. #lines .. " // SV Count: " .. #svs)
    end
end

function ConvergeDivergeMenu()
    local settings = parameterWorkflow("animation_convergeDiverge", "center", "maxSpread", "lineCount", "lineDuration",
        "progressionExponent",
        "spacing", "pathCoefficients", {
            inputType = "Checkbox",
            key = "renderBelow",
            label = "Render Below?",
            value = true,
        }, {
            inputType = "Checkbox",
            key = "renderAbove",
            label = "Render Above?",
            value = true,
            sameLine = true
        }
        , {
            inputType = "Checkbox",
            key = "prefill",
            label = "Pre-Filled?",
            value = false,
        }
        , {
            inputType = "Checkbox",
            key = "terminateEarly",
            label = "Terminate Life Cycle?",
            value = false,
            sameLine = true
        })

    if RangeActivated() then
        local currentTime = offsets.startOffset + settings.spacing

        local iterations = 0
        local lines = {}
        local svs = {}
        local frameLengths = {}
        local lineProgressionTable = {}
        local timeToGenerateClone = settings.lineDuration / settings.lineCount
        local lastClonedProgress = -1 * timeToGenerateClone

        if (settings.prefill) then
            for i = 1, settings.lineCount do
                table.insert(lineProgressionTable, -1 * i * timeToGenerateClone)
            end
        end

        while ((currentTime + (2 / INCREMENT)) <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset,
                settings.progressionExponent)

            if (not settings.terminateEarly) or (progress < 1 - settings.lineDuration + timeToGenerateClone) then
                if (progress - lastClonedProgress > timeToGenerateClone) then
                    lastClonedProgress = lastClonedProgress + timeToGenerateClone
                    table.insert(lineProgressionTable, progress)
                end
            end

            local msxTable = {}
            for idx, v in pairs(lineProgressionTable) do
                local lineProgression = progress - v
                if (lineProgression > settings.lineDuration) then
                    table.remove(lineProgressionTable, idx)
                else
                    local lineProgress = lineProgression / settings.lineDuration
                    local height = evaluateCoefficients(settings.pathCoefficients, lineProgress)
                    if (settings.renderAbove) then
                        table.insert(msxTable, mapProgress(settings.center, height, settings.center + settings.maxSpread))
                    end
                    if (settings.renderBelow) then
                        table.insert(msxTable, mapProgress(settings.center, height, settings.center - settings.maxSpread))
                    end
                end
            end

            local tbl = tableToAffineFrame(msxTable, currentTime, 0, settings.spacing)

            if (tbl.time > offsets.endOffset) then break end

            timeDiff = tbl.time - currentTime

            table.insert(frameLengths, timeDiff + 1)

            currentTime = currentTime + timeDiff

            lines = combineTables(lines, tbl.lines)
            svs = combineTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, FRAME_SIZE)

            currentTime = currentTime + 1

            iterations = iterations + 1
        end

        local stats = getStatisticsFromTable(frameLengths)

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset, "Converge/Diverge",
            constructDebugTable(lines, svs, stats))
        setDebug("Line Count: " .. #lines .. " // SV Count: " .. #svs)
    end
    Plot(settings.pathCoefficients, settings.progressionExponent, "Line Path Over Duration of Life Cycle")
end

function StaticBoundaryMenu()
    local settings = parameterWorkflow("animation_boundaryStatic", "msxBounds", "distance", "progressionExponent",
        "spacing",
        "boundCoefficients", {
            inputType = "RadioBoolean",
            key = "evalUnder",
            label = { "Render Over Boundary", "Render Under Boundary" },
            value = true
        })

    if RangeActivated() then
        local currentTime = offsets.startOffset + settings.spacing

        local iterations = 0
        local lines = {}
        local svs = {}
        local frameLengths = {}

        while ((currentTime + (2 / INCREMENT)) <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset,
                settings.progressionExponent)

            local boundary = settings.msxBounds[2] * evaluateCoefficients(settings.boundCoefficients, progress)

            local tbl = placeStaticFrame(currentTime, settings.msxBounds[1], settings.msxBounds[2], settings.distance,
                settings.spacing, boundary, settings.evalUnder)

            if (tbl.time > offsets.endOffset) then break end

            table.insert(frameLengths, tbl.time - currentTime + 2)

            currentTime = tbl.time

            lines = combineTables(lines, tbl.lines)
            svs = combineTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, FRAME_SIZE)

            iterations = iterations + 1

            currentTime = currentTime + 2
        end

        local stats = getStatisticsFromTable(frameLengths)

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset, "Static Boundary",
            constructDebugTable(lines, svs, stats))
        setDebug("Line Count: " .. #lines .. " // SV Count: " .. #svs)
    end

    Plot(settings.boundCoefficients, settings.progressionExponent)
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

    return tableToAffineFrame(msxTable, startTime, 0, spacing)
end

function DynamicBoundaryMenu()
    local settings = parameterWorkflow("animation_boundaryDynamic", "msxBounds", 'distance', "progressionExponent",
        "spacing",
        "boundCoefficients", {
            inputType = "RadioBoolean",
            key = "evalOver",
            label = { "Change Bottom Bound", "Change Top Bound" },
            value = true
        })

    if RangeActivated() then
        local currentTime = offsets.startOffset + settings.spacing

        local iterations = 0

        local lines = {}
        local svs = {}
        local frameLengths = {}

        while ((currentTime + (2 / INCREMENT)) <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset,
                settings.progressionExponent)

            local polynomialHeight = evaluateCoefficients(settings.boundCoefficients, progress)

            local tbl = placeDynamicFrame(currentTime, settings.msxBounds[1], settings.msxBounds[2], settings.distance,
                settings.spacing, polynomialHeight, settings.evalOver)

            if (tbl.time > offsets.endOffset) then break end

            table.insert(frameLengths, tbl.time - currentTime + 2)

            currentTime = tbl.time

            lines = combineTables(lines, tbl.lines)
            svs = combineTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, FRAME_SIZE)

            iterations = iterations + 1

            currentTime = currentTime + 2
        end

        local stats = getStatisticsFromTable(frameLengths)

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset, "Dynamic Boundary",
            constructDebugTable(lines, svs, stats))
        setDebug("Line Count: " .. #lines .. " // SV Count: " .. #svs)
    end
    Plot(settings.boundCoefficients, settings.progressionExponent)
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

    return tableToAffineFrame(msxTable, startTime, 0, spacing)
end

function SetVisibilityMenu()
    local settings = parameterWorkflow("edit_setVisibility", {
        inputType = "RadioBoolean",
        key = "enable",
        label = { "Turn Lines Invisible", "Turn Lines Visible" },
        value = false
    })

    if NoteActivated() then
        local linesToRemove = getLinesInRange(offsets.startOffset, offsets.endOffset)

        local linesToAdd = {}

        for _, currentLine in pairs(linesToRemove) do
            table.insert(linesToAdd, line(currentLine.StartTime, currentLine.Bpm, not settings.enable))
        end

        actions.PerformBatch({
            utils.CreateEditorAction(action_type.RemoveTimingPointBatch, linesToRemove),
            utils.CreateEditorAction(action_type.AddTimingPointBatch, linesToAdd)
        })
    end
end

function ReverseSVOrderMenu()
    if RangeActivated("Switch", "SVs") then
        local svsToReverse = getSVsInRange(offsets.startOffset, offsets.endOffset)

        local newSVs = reverseSVs(svsToReverse)

        actions.PerformBatch({
            utils.CreateEditorAction(action_type.AddScrollVelocityBatch, newSVs),
            utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, svsToReverse)
        })
    end
end

function reverseSVs(svs)
    local newTbl = {}

    for idx, item in ipairs(svs) do
        table.insert(newTbl, sv(svs[#svs - idx + 1].StartTime, item.Multiplier))
    end

    return newTbl
end

---@diagnostic disable: need-check-nil, inject-field
function CopyAndPasteMenu()
    local settings = parameterWorkflow("edit_copyAndPaste", {
        inputType = "Checkbox",
        key = "includeBM",
        label = "Include Bookmarks?",
        value = true
    })

    local tbl = {
        storedLines = {},
        storedSVs = {},
        storedBookmarks = {}
    }

    retrieveStateVariables("CopyAndPaste", tbl)

    if RangeActivated("Copy") then
        if (type(offsets) == "integer") then return end

        local lines = getLinesInRange(offsets.startOffset, offsets.endOffset)

        local svs = getSVsInRange(offsets.startOffset, offsets.endOffset)

        local bookmarks = getBookmarksInRange(offsets.startOffset, offsets.endOffset)

        local zeroOffsetLines = {}
        local zeroOffsetSVs = {}
        local zeroOffsetBookmarks = {}

        for _, givenLine in pairs(lines) do
            table.insert(zeroOffsetLines,
                line(givenLine.StartTime - offsets.startOffset, givenLine.Bpm, givenLine.Hidden))
        end

        for _, givenSV in pairs(svs) do
            table.insert(zeroOffsetSVs, sv(givenSV.StartTime - offsets.startOffset, givenSV.Multiplier))
        end

        for _, givenBookmark in pairs(bookmarks) do
            table.insert(zeroOffsetBookmarks, bookmark(givenBookmark.StartTime - offsets.startOffset, givenBookmark.Note))
        end

        tbl.storedLines = zeroOffsetLines
        tbl.storedSVs = zeroOffsetSVs
        if (settings.includeBM) then tbl.storedBookmarks = zeroOffsetBookmarks end
    end

    if (#tbl.storedLines > 0 or #tbl.storedSVs > 0) then
        if NoteActivated("Paste") then
            if (type(offsets) == "integer") then return end

            local linesToAdd = {}
            local svsToAdd = {}
            local bookmarksToAdd = {}

            for _, storedLine in pairs(tbl.storedLines) do
                table.insert(linesToAdd,
                    line(storedLine.StartTime + offsets.startOffset, storedLine.Bpm, storedLine.Hidden))
            end
            for _, storedSV in pairs(tbl.storedSVs) do
                table.insert(svsToAdd, sv(storedSV.StartTime + offsets.startOffset, storedSV.Multiplier))
            end
            for _, storedBookmark in pairs(tbl.storedBookmarks) do
                table.insert(bookmarksToAdd,
                    bookmark(storedBookmark.StartTime + offsets.startOffset, storedBookmark.Note))
            end

            actions.PerformBatch({
                utils.CreateEditorAction(action_type.AddTimingPointBatch, linesToAdd),
                utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svsToAdd),
                utils.CreateEditorAction(action_type.AddBookmarkBatch, bookmarksToAdd),
            })
        end
    end

    addSeparator()

    imgui.Text(#tbl.storedLines ..
        " Stored Lines // " .. #tbl.storedSVs .. " Stored SVs // " .. #tbl.storedBookmarks .. " Stored Bookmarks")

    saveStateVariables("CopyAndPaste", tbl)
end

---@diagnostic disable: undefined-field
function AddForefrontTeleportMenu()
    local settings = parameterWorkflow("edit_addForefrontTeleport", "msxList")

    if NoteActivated() then
        local offsets = getSelectedOffsets()

        local svs = {}
        local msxList = table.split(settings.msxList, "%S+")

        local mostRecentSV = map.GetScrollVelocityAt(offsets[1]).Multiplier

        for idx, v in pairs(offsets) do
            svs = insertTeleport(svs, v - 1, tonumber(msxList[(idx - 1) % #msxList + 1]), mostRecentSV)
        end

        actions.Perform(utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs))
    end
end

local separatorTable = { " ", "!", "@", "#", "$", "%", "^", "&" }

function tableToStr(tbl, nestingIdx)
    local str = ""
    local nestingIdx = nestingIdx or 0

    for k, v in pairs(tbl) do
        local value

        if (type(v) == "table") then
            value = "{" .. tableToStr(v, nestingIdx + 1) .. "}"
        else
            value = v
        end
        if (type(k) == "number") then
            str = str .. value .. separatorTable[nestingIdx + 1]
        else
            str = str .. k .. "=" .. value .. separatorTable[nestingIdx + 1]
        end
    end
    return str:sub(1, str:len() - 1)
end

---Takes a string, and splits it using a predicate. Similar to Array.split().
---@param str string
---@param predicate string
---@return table
function table.split(str, predicate)
    t = {}

    for i in string.gmatch(str, predicate) do
        t[#t + 1] = i
    end

    return t
end

---Returns true if the table contains the specified element.
---@param table table
---@param element any
---@return boolean
---@diagnostic disable-next-line: duplicate-set-field
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

local separatorTable = { " ", "!", "@", "#", "$", "%", "^", "&" }

function strToTable(str, nestingIdx)
    local tbl = {}
    local nestingIdx = nestingIdx or 0

    for kvPair in str:gmatch("[^" .. separatorTable[nestingIdx + 1] .. "]+") do
        if kvPair:match("^{.+}$") then
            table.insert(tbl, strToTable(kvPair:sub(2, kvPair:len() - 1), nestingIdx + 1))
        else
            if (kvPair:find("^(%w+)=(%S+)$")) then
                k, v = kvPair:match("^(%w+)=(%S+)$")
                if v:match("^{.+}$") then
                    tbl[k] = strToTable(v:sub(2, v:len() - 1), nestingIdx + 1)
                else
                    tbl[k] = v
                end
            else
                table.insert(tbl, kvPair)
            end
        end
    end

    return tbl
end

---Debug table constructor for placing AFFINE frames.
---@param lines TimingPointInfo[]
---@param svs SliderVelocityInfo[]
---@param stats? TableStats
---@return table
function constructDebugTable(lines, svs, stats)
    local tbl = {
        L = #lines,
        S = #svs
    }

    if (stats) then
        tbl.mspfMean = string.format("%.2f", stats.mean)
        tbl.mspfStdDev = string.format("%.2f", stats.stdDev)
    end

    return tbl
end

---Joins two tables together, with no nesting.
---@param t1 table
---@param t2 table
---@return table
function combineTables(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i]
    end
    return t1
end

---Generates two svs for a teleport.
---@param time number
---@param dist number
---@param endSV number
---@return SliderVelocityInfo[]
function teleport(time, dist, endSV)
    return {
        sv(time, INCREMENT * dist),
        sv(time + (1 / INCREMENT), endSV)
    }
end

---Adds a teleport sv to an existing table of svs.
---@param svs SliderVelocityInfo[]
---@param time number
---@param dist number
---@param remainingSV? number
---@return SliderVelocityInfo[]
function insertTeleport(svs, time, dist, remainingSV)
    return combineTables(svs, teleport(time, dist, remainingSV or 0))
end

---@diagnostic disable: return-type-mismatch
---Creates a SliderVelocity. To place it, you must use an `action`.
---@param time number
---@param multiplier number
---@return SliderVelocityInfo
function sv(time, multiplier)
    return utils.CreateScrollVelocity(time, multiplier)
end

---@diagnostic disable: undefined-field
function mostRecentSV(time)
    if (map.GetScrollVelocityAt(time)) then
        return map.GetScrollVelocityAt(time).Multiplier
    end
    return 1
end

---Returns all ScrollVelocities within a certain temporal range.
---@param lower number
---@param upper number
---@return SliderVelocityInfo[]
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

---Removes SVs outside of range, places 0.00x SV at the beginning, and places a 1.00x SV at the end.
---@param svs SliderVelocityInfo[]
---@param lower number
---@param upper number
---@return SliderVelocityInfo[]
function cleanSVs(svs, lower, upper)
    local tbl = {}

    for _, currentSV in pairs(svs) do
        if (currentSV.StartTime >= lower and currentSV.StartTime <= upper) then
            table.insert(tbl, currentSV)
        end
    end

    table.insert(tbl, sv(lower, 0))
    table.insert(tbl, sv(upper, 1))

    return tbl
end

---Gets the statistical variance
---@param table number[]
---@param mean? number
---@return number
function getVariance(table, mean)
    if (not mean) then mean = getMean(table) end

    local sum = 0
    for _, v in pairs(table) do
        sum = sum + (v - mean) ^ 2
    end

    return sum / (#table - 1)
end

---Gets the statistical standard deviation from a numerical table.
---@param table number[]
---@return number
function getStdDev(table)
    local mean = getMean(table)
    local variance = getVariance(table, mean)
    return variance ^ 0.5
end

---Gets statistical analysis of a numerical table.
---@param table number[]
---@return TableStats
function getStatisticsFromTable(table)
    local stdDev = getStdDev(table)

    local tbl = {
        mean = getMean(table),
        variance = stdDev ^ 2,
        stdDev = stdDev
    }

    return tbl
end

---Gets the statistical mean of a numerical table.
---@param table number[]
---@return number
function getMean(table)
    local sum = 0

    for _, v in pairs(table) do
        sum = sum + v
    end

    return sum / #table
end

function saveStateVariables(menu, variables)
    for key in pairs(variables) do
        state.SetValue(menu .. key, variables[key])
    end
end

function saveMapState(table, place)
    if (map.Bookmarks[1]) then
        if (map.Bookmarks[1].note:find("DATA: ")) and (map.Bookmarks[1].StartTime == -69420) then
            actions.RemoveBookmark(map.Bookmarks[1])
        end
    end
    local bm = bookmark(-69420, "DATA: " .. tableToStr(table))
    if (place == false) then return bm end
    actions.AddBookmarkBatch({ bm })
    return bm
end

function retrieveStateVariables(menu, variables)
    for key in pairs(variables) do
        if (state.GetValue(menu .. key) ~= nil) then
            variables[key] = state.GetValue(menu .. key)
        end
    end
end

function getMapState(default)
    default = default or {}
    if (not map.Bookmarks[1]) then return default end
    if (not string.find(map.Bookmarks[1].note, "DATA: ") or not map.Bookmarks[1].StartTime == -69420) then return default end

    local str = map.Bookmarks[1].note:sub(7, map.Bookmarks[1].note:len())

    return strToTable(str)
end

---Simplifies the workflow to find and maintain snap colors.
---@param time number
---@param hidden? boolean
---@return TimingPointInfo[]
function keepColorLine(time, hidden)
    color = colorFromTime(time)
    return applyColorToTime(color, time, hidden or false)
end

---Gets the snap color from a given time.
---@param time number
---@return number
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

---Takes a color and a time, and returns timing lines that make that time that color.
---@param color number
---@param time number
---@param hidden boolean
---@return TimingPointInfo[]
function applyColorToTime(color, time, hidden)
    local EPSILON = 0.3

    local lines = {}

    ---@diagnostic disable-next-line: undefined-field
    local bpm = map.GetTimingPointAt(time).Bpm

    local timingDist = 4

    if (math.abs(color - 1) <= EPSILON) then
        table.insert(lines, line(time, bpm, hidden))
    else
        table.insert(lines, line(time - timingDist / 2, 60000 / (timingDist * color / 2), hidden))
        table.insert(lines, line(time + timingDist / 2, bpm, hidden))
    end

    return lines
end

---Returns true if a note is selected.
---@return boolean
function noteSelected()
    return offsets.startOffset ~= -1
end

---Returns true if two or more notes are selected, with differing offsets.
---@return boolean
function rangeSelected()
    return offsets.endOffset ~= -1
end

---When given a progression value (0-1), returns the numerical distance along the progress line.
---@param starting number
---@param progress number
---@param ending number
---@return number
function mapProgress(starting, progress, ending)
    return progress * (ending - starting) + starting
end

---Gets the percentage from the starting value.
---@param starting number
---@param value number
---@param ending number
---@param progressionExponent? number
---@return number
function getProgress(starting, value, ending, progressionExponent)
    local progressionExponent = progressionExponent or 1
    local baseProgress = (value - starting) / (ending - starting)
    if (progressionExponent >= 1) then
        return baseProgress ^ progressionExponent
    else
        return 1 - (1 - baseProgress) ^ (1 / progressionExponent)
    end
end

---Takes a table of coefficients, and returns a string representing the equation.
---@param coefficients number[]
---@param power number
---@return string
function polynomialString(coefficients, power)
    local explanatoryVariable = "t"

    local str = 'Equation: y = '
    local degree = #coefficients - 1
    for idx, coefficient in pairs(coefficients) do
        if (coefficient == 0) then goto continue end
        effectiveDegree = (degree - idx + 1) * power
        sign = "+"
        if (coefficient < 0) then sign = "-" end
        if (idx == 1) then
            if (coefficient < 0) then signText = "-" else signText = "" end
        else
            signText = " " .. sign .. " "
        end
        coefficientText = math.abs(coefficient)
        if (coefficientText == 1 and effectiveDegree ~= 0) then coefficientText = "" end
        if (effectiveDegree == 0) then
            str = str .. signText .. coefficientText
        elseif (effectiveDegree == 1) then
            str = str .. signText .. coefficientText .. explanatoryVariable
        else
            str = str .. signText .. coefficientText .. explanatoryVariable .. "^" .. effectiveDegree
        end
        ::continue::
    end

    return str
end

---Takes a table of coefficients, and returns a number corresponding to a y-value of a polynomial.
---@param coefficients number[]
---@param xVal number
---@return number
function evaluateCoefficients(coefficients, xVal)
    local sum = 0
    local degree = #coefficients - 1

    for idx, coefficient in pairs(coefficients) do
        sum = sum + (xVal) ^ (degree - idx + 1) * coefficient
    end
    
    return sum
end

---Saves parameters for a certain menu.
---@param menu string
---@param parameterTable Parameter[]
function saveParameters(menu, parameterTable)
    for idx, tbl in ipairs(parameterTable) do
        state.setValue(menu .. idx .. tbl.key, tbl.value)
    end
end

---Gets parameters for a certain menu.
---@param menu string
---@param parameterTable Parameter[]
function retrieveParameters(menu, parameterTable)
    for idx, tbl in ipairs(parameterTable) do
        if (state.GetValue(menu .. idx .. tbl.key) ~= nil) then
            parameterTable[idx].value = state.GetValue(menu .. idx .. tbl.key)
        end
    end
end

---Provide a window name and parameter options, and this workflow will automatically manage state, generate input fields, and handle setting conversion.
---@param windowName string
---@param ... string | table
function parameterWorkflow(windowName, ...)
    local parameterTable = constructParameters(...)

    retrieveParameters(windowName, parameterTable)

    parameterInputs(parameterTable)
    local settings = parametersToSettings(parameterTable)

    saveParameters(windowName, parameterTable)

    return settings
end

---Outputs settings based on inputted parameters.
---@param parameterTable Parameter[]
---@return table
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
    lineCount = function (v)
        return InputIntWrapper("Line Count", v,
            "The number of timing lines to display simultaneously.")
    end,
    lineDuration = function (v)
        return InputFloatWrapper("Line Duration", v,
            "Each line created possesses a cloned lifecycle. The value of this parameter is equal to the percentage of the animation in which the lifecycle occurs.")
    end,
    progressionExponent = function (v)
        return InputFloatWrapper("Progression Exponent", v,
            "Adjust this to change how the animation progresses over time. The higher the number, the slower the animation takes to start, but it ramps up much faster. If you aren't familiar with exponential graphs, keep this at 1.")
    end,
    fps = function (v)
        return InputFloatWrapper("Animation FPS", v,
            "Maximum FPS of the animation. Note that if there are too many timing lines, the animation (not game) FPS will go down.")
    end,
    boundCoefficients = function (v)
        return InputFloat4Wrapper("Bound Coefficients", v,
            "The boundary follows a curve, described by these coefficients. You can see what the boundary height vs. time graph looks like on the plot.")
    end,
    pathCoefficients = function (v)
        return InputFloat4Wrapper("Path Coefficients", v,
            "Lines generated follow this temporal curve before disappearing. You can see what the height vs. time graph looks like on the plot.")
    end,
    colorList = function (v)
        return InputTextWrapper("Snap Color List", v,
            "These numbers are the denominator of the snaps. Here are the corresponding values:\n1 = Red\n2 = Blue\n3 = Purple\n4 = Yellow\n5 = White\n6 = Pink\n8 = Orange\n12 = Pink\n16 = Green")
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

    return parameterTable
end

---Gets the first and last note offsets.
---@return {startOffset: integer, endOffset: integer}
function getStartAndEndNoteOffsets()
    local offsets = {}

    if (#state.SelectedHitObjects == 0) then
        return { startOffset = -1, endOffset = -1 }
    end

    for _, hitObject in pairs(state.SelectedHitObjects) do
        if (table.contains(offsets, hitObject.StartTime)) then goto continue end
        table.insert(offsets, hitObject.StartTime)
        ::continue::
    end

    if (#offsets == 1) then
        return { startOffset = offsets[1], endOffset = -1 }
    end

    return { startOffset = math.min(table.unpack(offsets)), endOffset = math.max(table.unpack(offsets)) }
end

---Gets all selected note offsets, with no duplicate values.
---@return integer[]
function getSelectedOffsets()
    local offsets = {}

    if (#state.SelectedHitObjects == 0) then
        return {}
    end

    for _, hitObject in pairs(state.SelectedHitObjects) do
        if (table.contains(offsets, hitObject.StartTime)) then goto continue end
        table.insert(offsets, hitObject.StartTime)
        ::continue::
    end

    return offsets
end

---@diagnostic disable: return-type-mismatch
--- Creates a HitObject. To place it, you must use an `action`.
---@param startTime integer
---@param lane integer
---@param endTime? integer
---@param hitsound? any
---@param editorLayer? integer
---@return HitObjectInfo
function note(startTime, lane, endTime, hitsound, editorLayer)
    return utils.CreateHitObject(startTime, lane, endTime or 0, hitsound or 0, editorLayer or 0)
end

---Returns all HitObjects within a certain temporal range.
---@param lower number
---@param upper number
---@return HitObjectInfo[]
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

---Takes a table of strings, and returns an AFFINE frame.
---@param svTable string[]
---@param time number
---@param msxOffset number
---@param spacing number
---@return AffineFrame
function tableToAffineFrame(svTable, time, msxOffset, spacing)
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

---@diagnostic disable: return-type-mismatch
--- Creates a TimingPoint. To place it, you must use an `action`.
---@param time number
---@param bpm? number
---@param hidden? boolean
---@return TimingPointInfo
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

---Returns all timing points within a temporal boundary.
---@param lower number
---@param upper number
---@return TimingPointInfo[]
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

---Removes lines above or below the specified boundary. Then, adds an extra line at the nearest 1/1 snap to maintain snap coloring.
---@param lines TimingPointInfo[]
---@param lower number
---@param upper number
---@return TimingPointInfo[]
function cleanLines(lines, lower, upper)
    local lastLineTime = upper
    if (#lines > 0) then
        lastLineTime = math.max(lines[#lines].StartTime, upper)
    end

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

---Places given svs and lines, and cleans both.
---@param lines TimingPointInfo[]
---@param svs SliderVelocityInfo[]
---@param lower number
---@param upper number
---@param affineType string
---@param debugData? table
function generateAffines(lines, svs, lower, upper, affineType, debugData)
    if (not upper or upper == lower) then
        ---@diagnostic disable-next-line: cast-local-type
        upper = map.GetNearestSnapTimeFromTime(true, 1, lower);
    end

    lines = cleanLines(lines, lower, upper)
    svs = cleanSVs(svs, lower, upper)

    local debugString = ""
    if (debugData) then
        for k, v in pairs(debugData) do
            debugString = debugString .. " | " .. k .. ": " .. v
        end
    end

    local bookmarks = {
        utils.CreateBookmark(lower, affineType .. " Start" .. debugString),
        utils.CreateBookmark(upper, affineType .. " End")
    }

    local newGlobalTable = {
        label = affineType:gsub(" ", ""),
        lower = lower,
        upper = upper,
        numLines = #lines,
        numSVs = (debugData and debugData.S) and debugData.S or #svs,
    } ---@type AffineSaveTable

    table.insert(globalData, newGlobalTable)

    table.insert(bookmarks, saveMapState(globalData, false))

    actions.PerformBatch({
        utils.CreateEditorAction(action_type.AddTimingPointBatch, lines),
        utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs),
        utils.CreateEditorAction(action_type.AddBookmarkBatch, bookmarks),
    })
end

---Returns all bookmarks within a temporal boundary.
---@param lower number
---@param upper number
---@return BookmarkInfo[]
function getBookmarksInRange(lower, upper)
    local base = map.Bookmarks

    local tbl = {}

    for _, v in pairs(base) do
        if (v.StartTime >= lower) and (v.StartTime <= upper) then
            table.insert(tbl, v)
        end
    end

    return tbl
end

---Finds closest bookmark with StartTime less than time.
---@param time number
---@param lower number
---@param upper number
---@return BookmarkInfo
function findBookmark(time, lower, upper)
    local lower = lower or 0
    local upper = upper or 1e69
    local bookmarks = map.Bookmarks

    if (#bookmarks == 0) then return {} end
    if (#bookmarks == 1) then return bookmarks[1] end

    for i = 1, #bookmarks do
        if bookmarks[i].StartTime > time then
            if (bookmarks[i].StartTime < lower or bookmarks[i].StartTime > upper) then return {} end
            return bookmarks[i - 1]
        end
    end
    if (bookmarks[#bookmarks].StartTime < lower or bookmarks[#bookmarks].StartTime > upper) then return {} end
    return bookmarks[#bookmarks]
end

---@diagnostic disable: return-type-mismatch
--- Creates a Bookmark. To place it, you must use an `action`.
---@param time integer
---@param note string
---@return BookmarkInfo
function bookmark(time, note)
    return utils.CreateBookmark(time, note)
end

---Creates a tooltip hoverable element.
---@param text string
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

---Creates two radio buttons, one for true and one for false.
---@param labelFalse string
---@param labelTrue string
---@param v boolean
---@param tooltip string
---@return boolean
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

---Creates a new window with a plot
---@param polynomialCoefficients number[]
---@param progressionExponent number
---@param title? string
function Plot(polynomialCoefficients, progressionExponent, title)
    imgui.Begin(title or "Boundary Height vs. Time", imgui_window_flags.AlwaysAutoResize)

    local RESOLUTION = 50
    local tbl = {}
    for i = 0, RESOLUTION do
        local progress = getProgress(0, i, RESOLUTION, progressionExponent)

        table.insert(tbl,
            evaluateCoefficients(polynomialCoefficients, progress))
    end

    imgui.PlotLines("", tbl, #tbl, 0,
        polynomialString(polynomialCoefficients, progressionExponent),
        0, 1,
        { 250, 150 })

    imgui.End()
end

---@diagnostic disable: cast-local-type

---Creates an `InputInt` element.
---@param label string
---@param v integer
---@param tooltip string
---@return integer
function InputIntWrapper(label, v, tooltip)
    _, v = imgui.InputInt(label, v, 0, 0)
    Tooltip(tooltip)
    ---@cast v integer
    return v
end

---Creates an `InputFloat` element.
---@param label string
---@param v number
---@param tooltip string
---@return number
function InputFloatWrapper(label, v, tooltip)
    _, v = imgui.InputFloat(label, v, 0, 0, "%.2f")
    Tooltip(tooltip)
    ---@cast v number
    return v
end

---Creates an `InputText` element.
---@param label string
---@param v string
---@param tooltip string
---@return string
function InputTextWrapper(label, v, tooltip)
    _, v = imgui.InputText(label, v, 6942)
    Tooltip(tooltip)
    ---@cast v string
    return v
end

---Creates an `InputInt2` element.
---@param label string
---@param v integer[]
---@param tooltip string
---@return integer[]
function InputInt2Wrapper(label, v, tooltip)
    _, v = imgui.InputInt2(label, v)
    Tooltip(tooltip)
    ---@cast v integer[]
    return v
end

---Creates an `InputFloat4` element.
---@param label string
---@param v number[]
---@param tooltip string
---@return number[]
function InputFloat4Wrapper(label, v, tooltip)
    _, v = imgui.InputFloat4(label, v, "%.2f")
    Tooltip(tooltip)
    ---@cast v number[]
    return v
end

---Creates an `Checkbox` element.
---@param label string
---@param v boolean
---@param tooltip string
---@return boolean
function CheckboxWrapper(label, v, tooltip, sameLine)
    if (sameLine) then imgui.SameLine(0, 7.5) end
    _, v = imgui.Checkbox(label, v)
    Tooltip(tooltip)
    ---@cast v boolean
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

function RangeActivated(text, item)
    text = text or "Place"
    item = item or "Lines"
    if rangeSelected() then
        return activationButton(text) or (utils.IsKeyPressed(keys.A) and not utils.IsKeyDown(keys.LeftControl))
    else
        return imgui.Text("Select a Region to " .. text .. " " .. item .. ".")
    end
end

function NoteActivated(text, item)
    text = text or "Place"
    item = item or "Lines"
    if noteSelected() then
        return activationButton(text) or (utils.IsKeyPressed(keys.A) and not utils.IsKeyDown(keys.LeftControl))
    else
        return imgui.Text("Select a Note to " .. text .. " " .. item .. ".")
    end
end

function chooseMenu(tbl, menuID)
    if (tbl[menuID]) then
        tbl[menuID]();
    end
end

globalData = {} ---@type AffineSaveTable[]
debugText = ""
local loaded = false
offsets = { startOffset = -1, endOffset = -1 }

function draw()
    imgui.Begin("AFFINE", imgui_window_flags.AlwaysAutoResize)

    local settings = {
        menuID = DEFAULT_MENU_ID
    }

    if (not loaded) then
        onLoad()
    end

    -- drawCapybara2(0)
    -- drawSpike(state.WindowSize[1] * 1.5 / 25)

    -- IMPORTANT: DO NOT DELETE NEXT LINE BEFORE COMPILING.
    

LINE_STANDARD_MENU_FUNCTIONS = {
    StandardSpreadMenu,
    function () StandardAtNotesMenu(2) end,
    function () StandardAtNotesMenu(1) end,
    StandardRainbowMenu
}

LINE_FIXED_MENU_LIST = {
    'Manual',
    'Automatic',
    'Random'
}

LINE_FIXED_MENU_FUNCTIONS = {
    FixedManualMenu,
    FixedAutomaticMenu,
    FixedRandomMenu
}

LINE_ANIMATION_MENU_LIST = {
    'Manual (Basic)',
    'Incremental',
    'Boundary (Static)',
    'Boundary (Dynamic)',
    'Glitch',
    'Spectrum',
    'Expansion / Contraction',
    'Converge / Diverge'
}

LINE_ANIMATION_MENU_FUNCTIONS = {
    BasicManualAnimationMenu,
    IncrementalAnimationMenu,
    StaticBoundaryMenu,
    DynamicBoundaryMenu,
    GlitchMenu,
    SpectrumMenu,
    ExpansionContractionMenu,
    ConvergeDivergeMenu
}

CREATE_LINE_TAB_FUNCTIONS = {
    function () CreateMenu("Standard", "Standard Placement", LINE_STANDARD_MENU_LIST, LINE_STANDARD_MENU_FUNCTIONS) end,
    function () CreateMenu("Fixed", "Fixed Placement", LINE_FIXED_MENU_LIST, LINE_FIXED_MENU_FUNCTIONS) end,
    function () CreateMenu("Animation", "Animation", LINE_ANIMATION_MENU_LIST, LINE_ANIMATION_MENU_FUNCTIONS) end
}

SV_VIBRO_MENU_FUNCTIONS = {
    linearVibroMenu,
    polynomialVibroMenu,
    stackVibroMenu
}

CREATE_SV_TAB_FUNCTIONS = {
    function () CreateMenu("Still Vibro", "Vibro Placement", SV_VIBRO_MENU_LIST, SV_VIBRO_MENU_FUNCTIONS) end
}

EDIT_TAB_FUNCTIONS = {
    AddForefrontTeleportMenu,
    CopyAndPasteMenu,
    SetVisibilityMenu,
    ReverseSVOrderMenu,
}

    retrieveStateVariables("main", settings)

    imgui.BeginTabBar("Main Tabs")

    if imgui.BeginTabItem("Create Lines") then
        local mainMenuIndex = settings.menuID - 1
        local _, mainMenuIndex = imgui.Combo("Line Placement Type", mainMenuIndex, CREATE_LINE_TAB_LIST,
            #CREATE_LINE_TAB_LIST)
        settings.menuID = mainMenuIndex + 1
        chooseMenu(CREATE_LINE_TAB_FUNCTIONS, settings.menuID)
        imgui.EndTabItem()
    end

    if imgui.BeginTabItem("Create SVs") then
        local mainMenuIndex = settings.menuID - 1
        local _, mainMenuIndex = imgui.Combo("SV Placement Type", mainMenuIndex, CREATE_SV_TAB_LIST, #CREATE_SV_TAB_LIST)
        settings.menuID = mainMenuIndex + 1
        chooseMenu(CREATE_SV_TAB_FUNCTIONS, settings.menuID)
        imgui.EndTabItem()
    end

    if imgui.BeginTabItem("Edit") then
        local mainMenuIndex = settings.menuID - 1
        local _, mainMenuIndex = imgui.Combo("Edit Type", mainMenuIndex, EDIT_TAB_LIST, #EDIT_TAB_LIST)
        settings.menuID = mainMenuIndex + 1
        chooseMenu(EDIT_TAB_FUNCTIONS, settings.menuID)
        imgui.EndTabItem()
    end

    if imgui.BeginTabItem("Delete (Auto)") then
        AutomaticDeleteTab()
        imgui.EndTabItem()
    end
    if imgui.BeginTabItem("Delete (Manual)") then
        ManualDeleteTab()
        imgui.EndTabItem()
    end

    imgui.EndTabBar()

    if (debugText:len() > 0) then
        imgui.Text(debugText)
    end

    offsets = getStartAndEndNoteOffsets()

    saveStateVariables("main", settings)

    imgui.End()
end

function setDebug(text)
    debugText = text
end

function addPadding()
    imgui.Dummy({ 0, 0 })
end

function addSeparator()
    addPadding()
    imgui.Separator()
    addPadding()
end

function onLoad()
    globalData = getMapState()
    loaded = true
end
