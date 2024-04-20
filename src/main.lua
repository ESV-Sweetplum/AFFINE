function chooseMenu(tbl, menuID)
    if (tbl[menuID]) then
        tbl[menuID]();
    end
end

globalData = {} ---@type AffineSaveTable[]
debugText = ""
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
    -- {function tables}

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

    if imgui.BeginTabItem("Delete (Automatic) [BETA]") then
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
