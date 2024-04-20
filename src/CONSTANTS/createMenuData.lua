CREATE_MENU_LIST = {
    'Standard',
    'Fixed',
    'Animation (LAGGY)'
}

CREATE_MENU_FUNCTIONS = {
    function () CreateMenu("Standard", "Standard Placement", STANDARD_MENU_FUNCTIONS, STANDARD_MENU_LIST) end,
    function () CreateMenu("Fixed", "Fixed Placement", FIXED_MENU_FUNCTIONS, FIXED_MENU_LIST) end,
    function () CreateMenu("Animation", "Animation", ANIMATION_MENU_FUNCTIONS, ANIMATION_MENU_LIST) end
}
