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
    -- {function tables}

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
