function chooseMenu(tbl, menuID)
    if (tbl[menuID]) then
        tbl[menuID]();
    end
end

local data = {}
local loaded = false


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
        if ((not loaded) or imgui.Button("Get")) then
            data = getData({})
        end

        for _, tbl in pairs(data) do
            local str = ""

            for k, v in pairs(tbl) do
                local valStr
                if (type(v) == "table") then
                    valStr = "{" .. tableToStr(v) .. "}"
                else
                    valStr = v
                end

                str = str .. " " .. valStr
            end
            imgui.Selectable(str)
        end

        if (imgui.Button("Save")) then
            saveData(data)
        end
    end
    if imgui.BeginTabItem("Delete (Manual)") then
        ManualDeleteMenu()
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

function saveData(table)
    if (map.Bookmarks[1]) then
        if (map.Bookmarks[1].note:find("DATA: ")) then
            actions.RemoveBookmark(map.Bookmarks[1])
        end
    end
    bookmark(-69420, "DATA: " .. tableToStr(table))
end

function getData(default)
    if (not map.Bookmarks[1]) then return default end
    if (not string.find(map.Bookmarks[1].note, "DATA: ")) then return default end

    local str = map.Bookmarks[1].note:sub(7, map.Bookmarks[1].note:len())

    return strToTable(str)
end
