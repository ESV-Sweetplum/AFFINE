CREATE_LINE_TAB_LIST = {
    'Standard',
    'Fixed',
    'Animation (LAGGY)'
}

CREATE_LINE_TAB_FUNCTIONS = {
    function () CreateMenu("Standard", "Standard Placement", STANDARD_MENU_LIST, STANDARD_MENU_FUNCTIONS) end,
    function () CreateMenu("Fixed", "Fixed Placement", FIXED_MENU_LIST, FIXED_MENU_FUNCTIONS) end,
    function () CreateMenu("Animation", "Animation", ANIMATION_MENU_LIST, ANIMATION_MENU_FUNCTIONS) end
}
