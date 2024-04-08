function CreateMenu(menuName, typeText, list, functions)
    local settings = {
        menuID = DEFAULT_MENU_ID
    }

    retrieveStateVariables(menuName, settings)

    local createMenuIndex = settings.menuID - 1
    local _, createMenuIndex = imgui.Combo("  ", createMenuIndex, list,
        #list)
    addSeparator()
    settings.menuID = createMenuIndex + 1
    imgui.PushItemWidth(150)

    chooseMenu(functions, settings.menuID)

    saveStateVariables(menuName, settings)
end
