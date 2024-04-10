function chooseMenu(tbl, menuID)
    if (tbl[menuID]) then
        tbl[menuID]();
    end
end

function draw()
    imgui.Begin("AFFINE", imgui_window_flags.AlwaysAutoResize)

    -- imgui.SetWindowSize)

    imgui.PushItemWidth(300)
    local prevVal = state.GetValue("prevVal") or 0
    local colStatus = state.GetValue("colStatus") or 0

    imgui.PushStyleColor(imgui_col.Border, { colStatus, colStatus, colStatus, 1 })

    local modTime = (state.SongTime - map.GetTimingPointAt(state.SongTime).StartTime) %
        ((60000 / map.GetTimingPointAt(state.SongTime).Bpm))

    local frameTime = modTime - prevVal

    if ((modTime < prevVal)) then
        colStatus = 1
    else
        colStatus = colStatus - frameTime / (60000 / map.GetTimingPointAt(state.SongTime).Bpm)
    end

    if ((state.SongTime - map.GetTimingPointAt(state.SongTime).StartTime) < 0) then
        colStatus = 0
    end

    state.SetValue("colStatus", math.max(colStatus, 0))
    state.SetValue("prevVal", modTime)

    local settings = {
        menuID = DEFAULT_MENU_ID
    }

    -- drawCapybara2(0)
    -- drawSpike(state.WindowSize[1] * 1.5 / 25)

    -- IMPORTANT: DO NOT DELETE NEXT LINE BEFORE COMPILING.
    -- {function tables}

    retrieveStateVariables("main", settings)

    imgui.BeginTabBar("Main Tabs")

    addPadding()

    if imgui.BeginTabItem("Create") then
        local mainMenuIndex = settings.menuID - 1
        local _, mainMenuIndex = imgui.Combo(" ", mainMenuIndex, CREATE_MENU_LIST, #CREATE_MENU_LIST)
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
