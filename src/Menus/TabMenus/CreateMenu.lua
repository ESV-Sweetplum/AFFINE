function CreateMenu(menuName, typeText, functions)
    local settings = {
        menuID = DEFAULT_MENU_ID
    }

    retrieveStateVariables(menuName, settings)

    local createMenuIndex = settings.menuID - 1
    local _, createMenuIndex = imgui.Combo(typeText .. " Type", createMenuIndex, ANIMATION_MENU_LIST,
        #ANIMATION_MENU_LIST)
    addSeparator()
    settings.menuID = createMenuIndex + 1

    chooseMenu(functions, settings.menuID)

    saveStateVariables(menuName, settings)
end
