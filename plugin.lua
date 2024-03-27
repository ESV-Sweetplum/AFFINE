 
 
 ANIMATION_MENU_LIST = {
    'Boundary (Static)',
    'Boundary (Dynamic)',
    'Glitch',
    'Expansion / Contraction'
} 
 
 DEFAULT_DELAY = 1
DEFAULT_OFFSET = 0
DEFAULT_SPACING = 1.01
DEFAULT_MSX_BOUNDS = { 0, 400 }
DEFAULT_DISTANCE = { 15, 15 }
DEFAULT_LINE_COUNT = 10
DEFAULT_FPS = 90

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
    local settings = {
        distance = DEFAULT_DISTANCE
    }

    retrieveStateVariables("standard_spread", settings)

    _, settings.distance = imgui.InputInt2("Distance Between Lines", settings.distance)

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

        actions.PlaceTimingPointBatch(lines)
    end

    saveStateVariables("standard_spread", settings)
end
 
 
 function StandardAtNotesMenu()
    local offsets = getOffsets()

    if noteActivated(offsets) then
        local lines = {}

        if (type(offsets) == "integer") then return end

        for _, offset in pairs(offsets) do
            table.insert(lines, line(offset))
        end
        actions.PlaceTimingPointBatch(lines)
    end
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
 
 
 function getAllSVs(lower, upper)
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
        if (state.GetValue(menu..key) ~= nil) then
            variables[key] = state.GetValue(menu..key)
        end
    end
end

function saveStateVariables(menu, variables)
    for key in pairs(variables) do
        state.SetValue(menu..key, variables[key])
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
 
 
 function getOffsets()
    local offsets = {}

    if (#state.SelectedHitObjects == 0) then
        return -1
    end

    for i, hitObject in pairs(state.SelectedHitObjects) do
        table.insert(offsets, hitObject.StartTime)
    end

    return offsets
end
 
 
 function line(time)
    return utils.CreateTimingPoint(time, map.GetCommonBpm())
end
 
 
 function getAllLines(lower, upper)
    local base = map.TimingPoints

    local tbl = {}

    for _, v in pairs(base) do
        if (v.StartTime >= lower) and (v.StartTime <= upper) then
            table.insert(tbl, v)
        end
    end

    return tbl
end
 
 
 function placeFixedLines(svTable, time, msxOffset, spacing)
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


    actions.PerformBatch({
        utils.CreateEditorAction(action_type.AddTimingPointBatch, lines),
        utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs)
    })
end

function returnFixedLines(svTable, time, msxOffset, spacing)
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
 
 
 function FixedRandomMenu()
    local settings = {
        delay = DEFAULT_DELAY,
        msxBounds = DEFAULT_MSX_BOUNDS,
        spacing = DEFAULT_SPACING,
        lineCount = DEFAULT_LINE_COUNT
    }

    retrieveStateVariables("fixed_random", settings)

    _, settings.msxBounds = imgui.InputInt2("Start/End MSX", settings.msxBounds)
    _, settings.lineCount = imgui.InputInt("Line Count", settings.lineCount)

    _, settings.delay = imgui.InputInt("Delay", settings.delay)
    _, settings.spacing = imgui.InputFloat("MS Spacing", settings.spacing)

    local offsets = getStartAndEndNoteOffsets()

    if noteActivated(offsets) then
        msxTable = {}
        for i = 1, settings.lineCount do
            table.insert(msxTable, math.random(settings.msxBounds[1], settings.msxBounds[2]))
        end
        placeFixedLines(msxTable, offsets.startOffset + settings.delay, 0, settings.spacing)
    end

    saveStateVariables("fixed_random", settings)
end
 
 
 function FixedManualMenu()
    local settings = {
        offset = DEFAULT_OFFSET,
        delay = DEFAULT_DELAY,
        inputStr = "69 420 727 1337",
        spacing = DEFAULT_SPACING
    }

    retrieveStateVariables("fixed_manual", settings)

    _, settings.inputStr = imgui.InputText("List", settings.inputStr, 6942)
    _, settings.offset = imgui.InputInt("MSX Offset", settings.offset)
    _, settings.delay = imgui.InputInt("Delay", settings.delay)
    _, settings.spacing = imgui.InputFloat("MS Spacing", settings.spacing)

    local offsets = getStartAndEndNoteOffsets()

    if noteActivated(offsets) then
        msxTable = strToTable(settings.inputStr, "%S+")
        placeFixedLines(msxTable, offsets.startOffset + settings.delay, settings.offset, settings.spacing)
    end

    saveStateVariables("fixed_manual", settings)
end
 
 
 function FixedAutomaticMenu()
    local settings = {
        offset = DEFAULT_OFFSET,
        delay = DEFAULT_DELAY,
        msxBounds = DEFAULT_MSX_BOUNDS,
        spacing = DEFAULT_SPACING,
        distance = DEFAULT_DISTANCE,
        debug = "Line Count"
    }

    retrieveStateVariables("fixed_automatic", settings)

    _, settings.msxBounds = imgui.InputInt2("Start/End MSX", settings.msxBounds)
    _, settings.distance = imgui.InputInt2("Distance Between Lines", settings.distance)

    _, settings.offset = imgui.InputInt("MSX Offset", settings.offset)
    _, settings.delay = imgui.InputInt("Delay", settings.delay)
    _, settings.spacing = imgui.InputFloat("MS Spacing", settings.spacing)

    local offsets = getStartAndEndNoteOffsets()

    if noteActivated(offsets) then
        msxTable = {}
        local msx = settings.msxBounds[1]
        local iterations = 0
        while (msx <= settings.msxBounds[2]) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(settings.msxBounds[1], msx, settings.msxBounds[2])
            table.insert(msxTable, msx)
            msx = msx + mapProgress(settings.distance[1], progress, settings.distance[2])
            iterations = iterations + 1
        end
        placeFixedLines(msxTable, offsets.startOffset + settings.delay, settings.offset, settings.spacing)
        settings.debug = iterations
    end

    imgui.Text(settings.debug)

    saveStateVariables("fixed_automatic", settings)
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

    if imgui.RadioButton("Over", not settings.evalUnder) then
        settings.evalUnder = false
    end

    imgui.SameLine(0, 7.5)

    if imgui.RadioButton("Under", settings.evalUnder) then
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

        svs = cleanSVs(svs, offsets.startOffset, offsets.endOffset)

        settings.debug = #lines .. ' // ' .. #svs

        actions.PerformBatch({
            utils.CreateEditorAction(action_type.AddTimingPointBatch, lines),
            utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs)
        })
    end

    imgui.Text(settings.debug)

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

    return returnFixedLines(msxTable, startTime, 0, spacing)
end
 
 
 function GlitchMenu()
    local settings = {
        msxBounds = DEFAULT_MSX_BOUNDS,
        msxBounds2 = DEFAULT_MSX_BOUNDS,
        spacing = DEFAULT_SPACING,
        lineCount = DEFAULT_LINE_COUNT,
        fps = DEFAULT_FPS,
        debug = 'Lines // SVs'
    }

    retrieveStateVariables("glitch", settings)

    _, settings.msxBounds = imgui.InputInt2("Start Lower/Upper MSX", settings.msxBounds)
    _, settings.msxBounds2 = imgui.InputInt2("End Lower/Upper MSX", settings.msxBounds2)
    _, settings.lineCount = imgui.InputInt("Line Count", settings.lineCount)

    _, settings.fps = imgui.InputFloat("Animation FPS", settings.fps)
    _, settings.spacing = imgui.InputFloat("MS Spacing", settings.spacing)

    local offsets = getStartAndEndNoteOffsets()

    if rangeActivated(offsets) then
        local time = offsets.startOffset
        local lines = {}
        local svs = {}

        while (time <= offsets.endOffset) do
            local progress = getProgress(offsets.startOffset, time, offsets.endOffset)

            local lowerBound = mapProgress(settings.msxBounds[1], progress, settings.msxBounds2[1])
            local upperBound = mapProgress(settings.msxBounds[2], progress, settings.msxBounds2[2])

            msxTable = {}
            for i = 1, settings.lineCount do
                table.insert(msxTable, math.random(upperBound, lowerBound))
            end
            local tbl = returnFixedLines(msxTable, time, 0, settings.spacing)

            if (tbl.time > offsets.endOffset) then break end

            time = math.max(time + (1000 / settings.fps) - 2, tbl.time)

            lines = concatTables(lines, tbl.lines)
            svs = concatTables(svs, tbl.svs)

            insertTeleport(svs, time + 1 / INCREMENT, 1000)

            time = time + 2
        end

        svs = cleanSVs(svs, offsets.startOffset, offsets.endOffset)

        settings.debug = #lines .. " // " .. #svs
        actions.PerformBatch({
            utils.CreateEditorAction(action_type.AddTimingPointBatch, lines),
            utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs)
        })
    end

    imgui.Text(settings.debug)

    saveStateVariables("glitch", settings)
end
 
 
 function ExpansionContractionMenu()
    local settings = {
        msxBounds = DEFAULT_MSX_BOUNDS,
        spacing = DEFAULT_SPACING,
        distance = DEFAULT_DISTANCE,
        debug = 'Lines // SVs'
    }

    retrieveStateVariables("animation_expansion_contraction", settings)

    _, settings.msxBounds = imgui.InputInt2("Start/End MSX", settings.msxBounds)
    _, settings.distance = imgui.InputInt2("Distance Between Lines", settings.distance)

    _, settings.spacing = imgui.InputFloat("MS Spacing", settings.spacing)

    local offsets = getStartAndEndNoteOffsets()

    if rangeActivated(offsets) then
        local currentTime = offsets.startOffset + 1

        local iterations = 0

        local lines = {}
        local svs = {}

        while (currentTime <= offsets.endOffset) and (iterations < MAX_ITERATIONS) do
            local progress = getProgress(offsets.startOffset, currentTime, offsets.endOffset)

            local distance = mapProgress(settings.distance[1], progress, settings.distance[2])

            local msx = settings.msxBounds[1]
            local iterations = 0

            local msxTable = {}

            while (msx <= settings.msxBounds[2]) do
                table.insert(msxTable, msx)
                msx = msx + distance
            end

            local tbl = returnFixedLines(msxTable, currentTime, 0, settings.spacing)

            if (tbl.time > offsets.endOffset) then break end

            currentTime = tbl.time

            lines = concatTables(lines, tbl.lines)
            svs = concatTables(svs, tbl.svs)

            insertTeleport(svs, currentTime + 1 / INCREMENT, 1000)

            iterations = iterations + 1

            currentTime = currentTime + 2
        end
        svs = cleanSVs(svs, offsets.startOffset, offsets.endOffset)

        settings.debug = #lines .. ' // ' .. #svs

        actions.PerformBatch({
            utils.CreateEditorAction(action_type.AddTimingPointBatch, lines),
            utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs)
        })
    end

    imgui.Text(settings.debug)

    saveStateVariables("animation_expansion_contraction", settings)
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
        svs = cleanSVs(svs, offsets.startOffset, offsets.endOffset)

        settings.debug = #lines .. ' // ' .. #svs

        actions.PerformBatch({
            utils.CreateEditorAction(action_type.AddTimingPointBatch, lines),
            utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs)
        })
    end

    imgui.Text(settings.debug)

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

    return returnFixedLines(msxTable, startTime, 0, spacing)
end
 
 
 function chooseMenu(tbl, menuID)
    if (tbl[menuID]) then
        tbl[menuID]();
    end
end

function draw()
    imgui.Begin("AFFINE", imgui_window_flags.AlwaysAutoResize)

    local settings = {
        menuID = 1
    }

    -- IMPORTANT: DO NOT DELETE NEXT LINE BEFORE COMPILING.
     
 
 ANIMATION_MENU_FUNCTIONS = {
    StaticBoundaryMenu,
    DynamicBoundaryMenu,
    GlitchMenu,
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
        menuID = 1
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
        menuID = 1
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
        menuID = 1
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
        svs = getAllSVs(offsets.startOffset, offsets.endOffset)
        lines = getAllLines(offsets.startOffset, offsets.endOffset)

        local actionTable = {}

        if (math.fmod(settings.deletionType, 2) ~= 0) then
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
