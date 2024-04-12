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
FRAME_SIZE = 500                               -- integer

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

---@meta TimingPointInfo

---@class TimingPointInfo
---@field StartTime number
---@field Bpm number
---@field Signature number
---@field Hidden boolean

---@class TableStats
---@field mean number
---@field variance number
---@field stdDev number

---@meta SliderVelocityInfo

---@class SliderVelocityInfo
---@field StartTime number
---@field Multiplier number

---@meta Parameter

---@class Parameter
---@field key string
---@field value any
---@field inputType? string
---@field label? string
---@field sameLine? boolean
---@field tooltip? string

---@meta HitObjectInfo

---@class HitObjectInfo
---@field StartTime number
---@field Lane 1|2|3|4|5|6|7
---@field EndTime number
---@field HitSound any
---@field EditorLayer integer

---@class BookmarkInfo
---@field StartTime integer
---@field Note string

---@meta AffineSaveTable

---@class AffineSaveTable
---@field label string
---@field lower number
---@field upper number
---@field numLines number
---@field numSVs number
---@field lineOffsets number[]
---@field svOffsets number[]

---@meta AffineFrame

---@class AffineFrame
---@field lines TimingPointInfo[]
---@field svs SliderVelocityInfo[]
---@field time number

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

    if (imgui.Button("Delete selected item")) then
        tbl = globalData[selectedID]

        local EPSILON = 0.001

        local linesToRemove = {}
        local svsToRemove = {}
        local bookmarksToRemove = {
            findBookmark(tbl.lower + EPSILON, tbl.lower, tbl.upper),
            findBookmark(tbl.upper + EPSILON, tbl.lower, tbl.upper),
        }

        for _, v in pairs(tbl.lineOffsets) do
            local timingPoint = map.GetTimingPointAt(v + EPSILON)
            ---@cast timingPoint TimingPointInfo
            if (timingPoint.StartTime >= tbl.lower and timingPoint.StartTime <= tbl.upper) then
                table.insert(linesToRemove, timingPoint)
            end
        end

        for _, v in pairs(tbl.svOffsets) do
            local scrollVelocity = map.GetScrollVelocityAt(v + EPSILON)
            ---@cast scrollVelocity SliderVelocityInfo
            if (scrollVelocity.StartTime >= tbl.lower and scrollVelocity.StartTime <= tbl.upper) then
                table.insert(svsToRemove, scrollVelocity)
            end
        end

        actions.PerformBatch({
            utils.CreateEditorAction(action_type.RemoveTimingPointBatch, linesToRemove),
            utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, svsToRemove),
            utils.CreateEditorAction(action_type.RemoveBookmarkBatch, bookmarksToRemove)
        })

        table.remove(globalData, selectedID)
        saveMapState(globalData)
    end

    state.SetValue("selectedID", selectedID)
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
                lines = combineTables(lines, keepColorLine(note.StartTime, true))
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
        local rainbowTable = table.split(settings.colorList, "%S+")
        local rainbowIndex = 1

        if (type(offsets) == "integer") then return end

        local hidden = false

        for _, offset in pairs(offsets) do
            if (rainbowIndex == 1) then hidden = false else hidden = true end
            lines = combineTables(lines, applyColorToTime(rainbowTable[rainbowIndex], offset, hidden))
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
                lines = combineTables(lines, keepColorLine(offset))
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

        generateAffines(tbl.lines, tbl.svs, offsets.startOffset, offsets.endOffset, "Random Fixed")
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
        msxTable = table.split(settings.msxList, "%S+")
        local tbl = tableToLines(msxTable, offsets.startOffset + settings.delay, settings.offset, settings.spacing)
        generateAffines(tbl.lines, tbl.svs, offsets.startOffset, offsets.endOffset, "Manual Fixed")

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

        generateAffines(tbl.lines, tbl.svs, offsets.startOffset, offsets.endOffset, "Automatic Fixed")
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
        local frameLengths = {}

        while ((currentTime + (2 / INCREMENT)) <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset) ^
                settings.progressionExponent

            local heightDifferential = settings.maxSpread *
                (settings.polynomialCoefficients[1] * progress ^ 2 + settings.polynomialCoefficients[2] * progress + settings.polynomialCoefficients[3])

            local tbl = placeSpectrumFrame(currentTime, settings.center, settings.maxSpread, settings.distance,
                settings.spacing, heightDifferential, settings.inverse)

            if (tbl.time > offsets.endOffset) then break end

            table.insert(frameLengths, tbl.time - currentTime)

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
        startMsxTable = table.split(settings.msxList1, "%S+")
        endMsxTable = table.split(settings.msxList2, "%S+")

        local currentTime = offsets.startOffset + 1
        local iterations = 0
        local lines = {}
        local svs = {}
        local frameLengths = {}

        while (currentTime < offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset) ^
                settings.progressionExponent

            local msxTable = {}

            for i = 1, #endMsxTable do
                table.insert(msxTable, mapProgress(startMsxTable[i], progress, endMsxTable[i]))
            end

            local tbl = tableToLines(msxTable, currentTime, 0, settings.spacing)

            if (tbl.time > offsets.endOffset) then break end

            timeDiff = math.max(1000 / settings.fps - 2, tbl.time - currentTime)

            table.insert(frameLengths, timeDiff)

            currentTime = currentTime + timeDiff

            lines = combineTables(lines, tbl.lines)
            svs = combineTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, FRAME_SIZE)

            currentTime = currentTime + 2
        end

        local stats = getStatisticsFromTable(frameLengths)

        generateAffines(lines, svs, offsets.startOffset, offsets.endOffset, "Manual Animation",
            constructDebugTable(lines, svs, stats))
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
            local tbl = tableToLines(msxTable, currentTime + 5, 0, settings.spacing)

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
        local frameLengths = {}

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
        local frameLengths = {}

        while (currentTime <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset) ^
                settings.progressionExponent

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
        local frameLengths = {}

        while ((currentTime + (2 / INCREMENT)) <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset) ^
                settings.progressionExponent

            local boundary = settings.msxBounds[2] *
                (settings.polynomialCoefficients[1] * progress ^ 2 + settings.polynomialCoefficients[2] * progress + settings.polynomialCoefficients[3])

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
        local frameLengths = {}

        while ((currentTime + (2 / INCREMENT)) <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset) ^
                settings.progressionExponent

            local polynomialHeight = (settings.polynomialCoefficients[1] * progress ^ 2 + settings.polynomialCoefficients[2] * progress + settings.polynomialCoefficients[3])

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
---@return SliderVelocityInfo[]
function teleport(time, dist)
    return {
        sv(time, INCREMENT * dist),
        sv(time + (1 / INCREMENT), 64000)
    }
end

---Adds a teleport sv to an existsing table of svs.
---@param svs SliderVelocityInfo[]
---@param time number
---@param dist number
---@return SliderVelocityInfo[]
function insertTeleport(svs, time, dist)
    return combineTables(svs, teleport(time, dist))
end

---@diagnostic disable: return-type-mismatch
---Creates a SliderVelocity. To place it, you must use an `action`.
---@param time number
---@param multiplier number
---@return SliderVelocityInfo
function sv(time, multiplier)
    return utils.CreateScrollVelocity(time, multiplier)
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
    table.insert(tbl, sv(upper + 1, 1))

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

function saveMapState(table)
    if (map.Bookmarks[1]) then
        if (map.Bookmarks[1].note:find("DATA: ")) then
            actions.RemoveBookmark(map.Bookmarks[1])
        end
    end
    local bm = bookmark(-69420, "DATA: " .. tableToStr(table))
    actions.AddBookmarkBatch({ bm })
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
    if (not string.find(map.Bookmarks[1].note, "DATA: ")) then return default end

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

---Returns true if a note is selected.
---@param offsets any
---@return boolean
function noteSelected(offsets)
    return offsets ~= -1
end

---Returns true if two or more notes are selected, with differing offsets.
---@param offsets any
---@return boolean
function rangeSelected(offsets)
    return (offsets ~= -1) and (offsets.startOffset ~= offsets.endOffset) 
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
---@return number
function getProgress(starting, value, ending)
    return (value - starting) / (ending - starting)
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
    progressionExponent = DEFAULT_PROGRESSION_EXPONENT,
    polynomialCoefficients = DEFAULT_POLYNOMIAL_COEFFICIENTS,
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

---Gets the first and last note offsets.
---@return -1 | {startOffset: integer, endOffset: integer}
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

---Gets all selected note offsets, with no duplicate values.
---@return -1 | integer[]
function getSelectedOffsets()
    local offsets = {}

    if (#state.SelectedHitObjects == 0) then
        return -1
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
        numSVs = #svs,
        lineOffsets = {},
        svOffsets = {}
    } ---@type AffineSaveTable

    for _, line in pairs(lines) do
        table.insert(newGlobalTable.lineOffsets, line.StartTime)
    end

    for _, sv in pairs(svs) do
        table.insert(newGlobalTable.svOffsets, sv.StartTime)
    end

    table.insert(globalData, newGlobalTable)

    saveMapState(globalData)

    actions.PerformBatch({
        utils.CreateEditorAction(action_type.AddTimingPointBatch, lines),
        utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs),
        utils.CreateEditorAction(action_type.AddBookmarkBatch, bookmarks),
    })
end

function findBookmark(time, lower, upper)
    local lower = lower or 0
    local upper = upper or 1e69
    local bookmarks = map.Bookmarks

    if (not #bookmarks) then return end
    if (#bookmarks == 1) then return bookmarks[1] end

    for i = 1, #bookmarks do
        if bookmarks[i].StartTime > time then
            if (bookmarks[i].StartTime < lower or bookmarks[i].StartTime > upper) then return end
            return bookmarks[i - 1]
        end
    end
    if (bookmarks[#bookmarks].StartTime < lower or bookmarks[#bookmarks].StartTime > upper) then return end
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

---Creates an `InputFloat3` element.
---@param label string
---@param v number[]
---@param tooltip string
---@return number[]
function InputFloat3Wrapper(label, v, tooltip)
    _, v = imgui.InputFloat3(label, v, "%.2f")
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

globalData = {} ---@type AffineSaveTable[]
local loaded = false

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

    if imgui.BeginTabItem("Delete (Automatic)") then
        AutomaticDeleteTab()
        imgui.EndTabItem()
    end
    if imgui.BeginTabItem("Delete (Manual)") then
        ManualDeleteTab()
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

function onLoad()
    globalData = getMapState()
    loaded = true
end
