LINE_STANDARD_MENU_LIST = {
    'Spread',
    'At Notes (Preserve Location)',
    'At Notes (Preserve Snap)',
    "Rainbow"
}

LINE_STANDARD_MENU_FUNCTIONS = {
    StandardSpreadMenu,
    function () StandardAtNotesMenu(2) end,
    function () StandardAtNotesMenu(1) end,
    StandardRainbowMenu
}


LINE_FIXED_MENU_LIST = {
    'Manual',
    'Automatic',
    'Random'
}

LINE_FIXED_MENU_FUNCTIONS = {
    FixedManualMenu,
    FixedAutomaticMenu,
    FixedRandomMenu
}


LINE_ANIMATION_MENU_LIST = {
    'Manual (Basic)',
    'Incremental',
    'Boundary (Static)',
    'Boundary (Dynamic)',
    'Glitch',
    'Spectrum',
    'Expansion / Contraction',
    'Converge / Diverge'
}

LINE_ANIMATION_MENU_FUNCTIONS = {
    BasicManualAnimationMenu,
    IncrementalAnimationMenu,
    StaticBoundaryMenu,
    DynamicBoundaryMenu,
    GlitchMenu,
    SpectrumMenu,
    ExpansionContractionMenu,
    ConvergeDivergeMenu
}
