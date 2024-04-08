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
    -- {function tables}

    retrieveStateVariables("main", settings)

    imgui.BeginTabBar("Main Tabs")

    if imgui.BeginTabItem("Create") then
        local mainMenuIndex = settings.menuID - 1
        local _, mainMenuIndex = imgui.Combo("Line Placement Type", mainMenuIndex, CREATE_MENU_LIST, #CREATE_MENU_LIST)
        settings.menuID = mainMenuIndex + 1
        chooseMenu(CREATE_MENU_FUNCTIONS, settings.menuID)
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
