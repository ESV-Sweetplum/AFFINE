STANDARD_MENU_LIST = {
    'Spread',
    'At Notes (Preserve Location)',
    'At Notes (Preserve Snap)',
    "Rainbow",
    "Set Line Visibility"
}

STANDARD_MENU_FUNCTIONS = {
    StandardSpreadMenu,
    function () StandardAtNotesMenu(2) end,
    function () StandardAtNotesMenu(1) end,
    StandardRainbowMenu,
    SetVisibilityMenu
}
