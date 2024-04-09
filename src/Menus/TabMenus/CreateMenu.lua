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
