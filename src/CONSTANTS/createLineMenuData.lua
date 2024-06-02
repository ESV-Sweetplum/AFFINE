---@enum LINE_STANDARD_MENU_LIST
LINE_STANDARD_MENU_LIST = {
    'Spread',
    'At Notes (Preserve Location)',
    'At Notes (Preserve Snap)',
    "Rainbow"
}

---@enum LINE_STANDARD_MENU_FUNCTIONS
LINE_STANDARD_MENU_FUNCTIONS = {
    StandardSpreadMenu,
    function () StandardAtNotesMenu(2) end,
    function () StandardAtNotesMenu(1) end,
    StandardRainbowMenu
}


---@enum LINE_FIXED_MENU_LIST
LINE_FIXED_MENU_LIST = {
    'Manual',
    'Automatic',
    'Random'
}

---@enum LINE_FIXED_MENU_FUNCTIONS
LINE_FIXED_MENU_FUNCTIONS = {
    FixedManualMenu,
    FixedAutomaticMenu,
    FixedRandomMenu
}


---@enum LINE_ANIMATION_MENU_LIST
LINE_ANIMATION_MENU_LIST = {
    'Manual (Basic)',
    'Incremental',
    'Boundary (Static)',
    'Boundary (Dynamic)',
    'Glitch',
    'Spectrum',
    'Expansion / Contraction',
    'Converge / Diverge',
    'Trail (Static)',
    'Trail (Follow)',
}

---@enum LINE_ANIMATION_MENU_FUNCTIONS
LINE_ANIMATION_MENU_FUNCTIONS = {
    BasicManualAnimationMenu,
    IncrementalAnimationMenu,
    StaticBoundaryMenu,
    DynamicBoundaryMenu,
    GlitchMenu,
    SpectrumMenu,
    ExpansionContractionMenu,
    ConvergeDivergeMenu,
    TrailStaticMenu,
    TrailFollowMenu
}
