---@enum CREATE_LINE_TAB_LIST
CREATE_LINE_TAB_LIST = {
    'Standard',
    'Fixed',
    'Animation (LAGGY)'
}

---@enum CREATE_LINE_TAB_FUNCTIONS
CREATE_LINE_TAB_FUNCTIONS = {
    function () CreateMenu("Standard", "Standard Placement", LINE_STANDARD_MENU_LIST, LINE_STANDARD_MENU_FUNCTIONS) end,
    function () CreateMenu("Fixed", "Fixed Placement", LINE_FIXED_MENU_LIST, LINE_FIXED_MENU_FUNCTIONS) end,
    function () CreateMenu("Animation", "Animation", LINE_ANIMATION_MENU_LIST, LINE_ANIMATION_MENU_FUNCTIONS) end
}
