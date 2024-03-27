---@diagnostic disable: undefined-global, duplicate-set-field
-- LAST UPDATED: 2021-02-02

-- ./ImGui.NET/src/ImGui.NET/Generated/ImGuiInputTextFlags.gen.cs
imgui_input_text_flags = {
    None = 0,
    CharsDecimal = 1 << 0,
    CharsHexadecimal = 1 << 1,
    CharsUppercase = 1 << 2,
    CharsNoBlank = 1 << 3,
    AutoSelectAll = 1 << 4,
    EnterReturnsTrue = 1 << 5,
    CallbackCompletion = 1 << 6,
    CallbackHistory = 1 << 7,
    CallbackAlways = 1 << 8,
    CallbackCharFilter = 1 << 9,
    AllowTabInput = 1 << 10,
    CtrlEnterForNewLine = 1 << 11,
    NoHorizontalScroll = 1 << 12,
    AlwaysInsertMode = 1 << 13,
    ReadOnly = 1 << 14,
    Password = 1 << 15,
    NoUndoRedo = 1 << 16,
    CharsScientific = 1 << 17,
    CallbackResize = 1 << 18,
    Multiline = 1 << 20,
    NoMarkEdited = 1 << 21,
}

-- ./ImGui.NET/src/ImGui.NET/Generated/ImGuiDataType.gen.cs
imgui_data_type = {
    S8 = 0,
    U8 = 1,
    S16 = 2,
    U16 = 3,
    S32 = 4,
    U32 = 5,
    S64 = 6,
    U64 = 7,
    Float = 8,
    Double = 9,
    COUNT = 10,
}

-- ./ImGui.NET/src/ImGui.NET/Generated/ImGuiTreeNodeFlags.gen.cs
imgui_tree_node_flags = {
    None = 0,
    Selected = 1 << 0,
    Framed = 1 << 1,
    AllowItemOverlap = 1 << 2,
    NoTreePushOnOpen = 1 << 3,
    NoAutoOpenOnLog = 1 << 4,
    DefaultOpen = 1 << 5,
    OpenOnDoubleClick = 1 << 6,
    OpenOnArrow = 1 << 7,
    Leaf = 1 << 8,
    Bullet = 1 << 9,
    FramePadding = 1 << 10,
    SpanAvailWidth = 1 << 11,
    SpanFullWidth = 1 << 12,
    NavLeftJumpsBackHere = 1 << 13,
    CollapsingHeader = Framed | NoTreePushOnOpen | NoAutoOpenOnLog,
}

-- ./ImGui.NET/src/ImGui.NET/Generated/ImGuiSelectableFlags.gen.cs
imgui_selectable_flags = {
    None = 0,
    DontClosePopups = 1 << 0,
    SpanAllColumns = 1 << 1,
    AllowDoubleClick = 1 << 2,
    Disabled = 1 << 3,
    AllowItemOverlap = 1 << 4,
}

-- ./ImGui.NET/src/ImGui.NET/Generated/ImGuiMouseCursor.gen.cs
imgui_mouse_cursor = {
    None = -1,
    Arrow = 0,
    TextInput = 1,
    ResizeAll = 2,
    ResizeNS = 3,
    ResizeEW = 4,
    ResizeNESW = 5,
    ResizeNWSE = 6,
    Hand = 7,
    NotAllowed = 8,
    COUNT = 9,
}

-- ./ImGui.NET/src/ImGui.NET/Generated/ImGuiCond.gen.cs
imgui_cond = {
    None = 0,
    Always = 1 << 0,
    Once = 1 << 1,
    FirstUseEver = 1 << 2,
    Appearing = 1 << 3,
}

-- ./ImGui.NET/src/ImGui.NET/Generated/ImGuiWindowFlags.gen.cs
imgui_window_flags = {
    None = 0,
    NoTitleBar = 1 << 0,
    NoResize = 1 << 1,
    NoMove = 1 << 2,
    NoScrollbar = 1 << 3,
    NoScrollWithMouse = 1 << 4,
    NoCollapse = 1 << 5,
    AlwaysAutoResize = 1 << 6,
    NoBackground = 1 << 7,
    NoSavedSettings = 1 << 8,
    NoMouseInputs = 1 << 9,
    MenuBar = 1 << 10,
    HorizontalScrollbar = 1 << 11,
    NoFocusOnAppearing = 1 << 12,
    NoBringToFrontOnFocus = 1 << 13,
    AlwaysVerticalScrollbar = 1 << 14,
    AlwaysHorizontalScrollbar = 1<< 15,
    AlwaysUseWindowPadding = 1 << 16,
    NoNavInputs = 1 << 18,
    NoNavFocus = 1 << 19,
    UnsavedDocument = 1 << 20,
    NoDocking = 1 << 21,
    NoNav = NoNavInputs | NoNavFocus,
    NoDecoration = NoTitleBar | NoResize | NoScrollbar | NoCollapse,
    NoInputs = NoMouseInputs | NoNavInputs | NoNavFocus,
    NavFlattened = 1 << 23,
    ChildWindow = 1 << 24,
    Tooltip = 1 << 25,
    Popup = 1 << 26,
    Modal = 1 << 27,
    ChildMenu = 1 << 28,
    DockNodeHost = 1 << 29,
}

-- ./ImGui.NET/src/ImGui.NET/Generated/ImGuiDir.gen.cs
imgui_dir = {
    None = -1,
    Left = 0,
    Right = 1,
    Up = 2,
    Down = 3,
    COUNT = 4,
}

-- ./ImGui.NET/src/ImGui.NET/Generated/ImGuiDragDropFlags.gen.cs
imgui_drag_drop_flags = {
    None = 0,
    SourceNoPreviewTooltip = 1 << 0,
    SourceNoDisableHover = 1 << 1,
    SourceNoHoldToOpenOthers = 1 << 2,
    SourceAllowNullID = 1 << 3,
    SourceExtern = 1 << 4,
    SourceAutoExpirePayload = 1 << 5,
    AcceptBeforeDelivery = 1 << 10,
    AcceptNoDrawDefaultRect = 1 << 11,
    AcceptNoPreviewTooltip = 1 << 12,
    AcceptPeekOnly = AcceptBeforeDelivery | AcceptNoDrawDefaultRect,
}

-- ./ImGui.NET/src/ImGui.NET/Generated/ImGuiTabBarFlags.gen.cs
imgui_tab_bar_flags = {
    None = 0,
    Reorderable = 1 << 0,
    AutoSelectNewTabs = 1 << 1,
    TabListPopupButton = 1 << 2,
    NoCloseWithMiddleMouseButton = 1 << 3,
    NoTabListScrollingButtons = 1 << 4,
    NoTooltip = 1 << 5,
    FittingPolicyResizeDown = 1 << 6,
    FittingPolicyScroll = 1 << 7,
    FittingPolicyMask = FittingPolicyResizeDown | FittingPolicyScroll,
    FittingPolicyDefault = FittingPolicyResizeDown,
}

-- ./ImGui.NET/src/ImGui.NET/Generated/ImGuiTabItemFlags.gen.cs
imgui_tab_item_flags = {
    None = 0,
    UnsavedDocument = 1 << 0,
    SetSelected = 1 << 1,
    NoCloseWithMiddleMouseButton = 1 << 2,
    NoPushId = 1 << 3,
    NoTooltip = 1 << 4,
}

-- ./ImGui.NET/src/ImGui.NET/Generated/ImGuiColorEditFlags.gen.cs
imgui_color_edit_flags = {
    None = 0,
    NoAlpha = 1 << 1,
    NoPicker = 1 << 2,
    NoOptions = 1 << 3,
    NoSmallPreview = 1 << 4,
    NoInputs = 1 << 5,
    NoTooltip = 1 << 6,
    NoLabel = 1 << 7,
    NoSidePreview = 1 << 8,
    NoDragDrop = 1 << 9,
    NoBorder = 1 << 10,
    AlphaBar = 1 << 16,
    AlphaPreview = 1 << 17,
    AlphaPreviewHalf = 1 << 18,
    HDR = 1 << 19,
    DisplayRGB = 1 << 20,
    DisplayHSV = 1 << 21,
    DisplayHex = 1 << 22,
    Uint8 = 1 << 23,
    Float = 1 << 24,
    PickerHueBar = 1 << 25,
    PickerHueWheel = 1 << 26,
    InputRGB = 1 << 27,
    InputHSV = 1 << 28,
    _OptionsDefault = Uint8 | DisplayRGB | InputRGB | PickerHueBar,
    _DisplayMask = DisplayRGB | DisplayHSV | DisplayHex,
    _DataTypeMask = Uint8 | Float,
    _PickerMask = PickerHueWheel | PickerHueBar,
    _InputMask = InputRGB | InputHSV,
}

-- ./ImGui.NET/src/ImGui.NET/Generated/ImGuiKey.gen.cs
imgui_key = {
    Tab = 0,
    LeftArrow = 1,
    RightArrow = 2,
    UpArrow = 3,
    DownArrow = 4,
    PageUp = 5,
    PageDown = 6,
    Home = 7,
    End = 8,
    Insert = 9,
    Delete = 10,
    Backspace = 11,
    Space = 12,
    Enter = 13,
    Escape = 14,
    KeyPadEnter = 15,
    A = 16,
    C = 17,
    V = 18,
    X = 19,
    Y = 20,
    Z = 21,
    COUNT = 22,
}

-- ./ImGui.NET/src/ImGui.NET/Generated/ImGuiCol.gen.cs
imgui_col = {
    Text = 0,
    TextDisabled = 1,
    WindowBg = 2,
    ChildBg = 3,
    PopupBg = 4,
    Border = 5,
    BorderShadow = 6,
    FrameBg = 7,
    FrameBgHovered = 8,
    FrameBgActive = 9,
    TitleBg = 10,
    TitleBgActive = 11,
    TitleBgCollapsed = 12,
    MenuBarBg = 13,
    ScrollbarBg = 14,
    ScrollbarGrab = 15,
    ScrollbarGrabHovered = 16,
    ScrollbarGrabActive = 17,
    CheckMark = 18,
    SliderGrab = 19,
    SliderGrabActive = 20,
    Button = 21,
    ButtonHovered = 22,
    ButtonActive = 23,
    Header = 24,
    HeaderHovered = 25,
    HeaderActive = 26,
    Separator = 27,
    SeparatorHovered = 28,
    SeparatorActive = 29,
    ResizeGrip = 30,
    ResizeGripHovered = 31,
    ResizeGripActive = 32,
    Tab = 33,
    TabHovered = 34,
    TabActive = 35,
    TabUnfocused = 36,
    TabUnfocusedActive = 37,
    DockingPreview = 38,
    DockingEmptyBg = 39,
    PlotLines = 40,
    PlotLinesHovered = 41,
    PlotHistogram = 42,
    PlotHistogramHovered = 43,
    TextSelectedBg = 44,
    DragDropTarget = 45,
    NavHighlight = 46,
    NavWindowingHighlight = 47,
    NavWindowingDimBg = 48,
    ModalWindowDimBg = 49,
    COUNT = 50,
}

-- ./ImGui.NET/src/ImGui.NET/Generated/ImGuiComboFlags.gen.cs
imgui_combo_flags = {
    None = 0,
    PopupAlignLeft = 1 << 0,
    HeightSmall = 1 << 1,
    HeightRegular = 1 << 2,
    HeightLarge = 1 << 3,
    HeightLargest = 1 << 4,
    NoArrowButton = 1 << 5,
    NoPreview = 1 << 6,
    HeightMask = HeightSmall | HeightRegular | HeightLarge | HeightLargest,
}

-- ./ImGui.NET/src/ImGui.NET/Generated/ImGuiFocusedFlags.gen.cs
imgui_focused_flags = {
    None = 0,
    ChildWindows = 1 << 0,
    RootWindow = 1 << 1,
    AnyWindow = 1 << 2,
    RootAndChildWindows = RootWindow | ChildWindows,
}

-- ./ImGui.NET/src/ImGui.NET/Generated/ImGuiHoveredFlags.gen.cs
imgui_hovered_flags = {
    None = 0,
    ChildWindows = 1 << 0,
    RootWindow = 1 << 1,
    AnyWindow = 1 << 2,
    AllowWhenBlockedByPopup = 1 << 3,
    AllowWhenBlockedByActiveItem = 1 << 5,
    AllowWhenOverlapped = 1 << 6,
    AllowWhenDisabled = 1 << 7,
    RectOnly = AllowWhenBlockedByPopup | AllowWhenBlockedByActiveItem | AllowWhenOverlapped,
    RootAndChildWindows = RootWindow | ChildWindows,
}

-- ./Quaver/Quaver.API/Quaver.API/Enums/GameMode.cs
game_mode = {
    Keys4 = 1,
    Keys7 = 2
}

-- ./Quaver/Quaver.API/Quaver.API/Enums/Hitsounds.cs
hitsounds = {
    Normal = 1 << 0, -- This is 1, but Normal should be played regardless if it's 0 or 1.
    Whistle = 1 << 1, -- 2
    Finish = 1 << 2, -- 4
    Clap = 1 << 3 -- 8
}

-- ./Quaver/Quaver.API/Quaver.API/Enums/TimeSignature.cs
time_signature = {
    Quadruple = 4,
    Triple = 3,
}

-- ./Quaver/Quaver.Shared/Screens/Edit/Actions/EditorActionType.cs
action_type = {
    None = -1,
    PlaceHitObject,
    RemoveHitObject,
    ResizeLongNote,
    RemoveHitObjectBatch,
    PlaceHitObjectBatch,
    FlipHitObjects,
    MoveHitObjects,
    AddHitsound,
    RemoveHitsound,
    CreateLayer,
    RemoveLayer,
    RenameLayer,
    MoveToLayer,
    ColorLayer,
    ToggleLayerVisibility,
    AddScrollVelocity,
    RemoveScrollVelocity,
    AddScrollVelocityBatch,
    RemoveScrollVelocityBatch,
    AddTimingPoint,
    RemoveTimingPoint,
    AddTimingPointBatch,
    RemoveTimingPointBatch,
    ChangePreviewTime,
    ChangeTimingPointOffset,
    ChangeTimingPointBpm,
    ChangeTimingPointHidden,
    ResetTimingPoint,
    ChangeTimingPointBpmBatch,
    ChangeTimingPointOffsetBatch,
    ChangeScrollVelocityOffsetBatch,
    ChangeScrollVelocityMultiplierBatch,
    ApplyOffset,
    ResnapHitObjects,
    Batch
}

-- ./Quaver/Quaver.Shared/Scripting/ImGuiWrapper.cs
function imgui.AcceptDragDropPayload(type) end
function imgui.AcceptDragDropPayload(type, flags) end
function imgui.AlignTextToFramePadding() end
function imgui.ArrowButton(str_id, dir) end
function imgui.Begin(name, flags) end
function imgui.Begin(name) end
function imgui.Begin(name, p_open) end
function imgui.Begin(name, p_open, flags) end
function imgui.BeginChild(str_id) end
function imgui.BeginChild(str_id, size) end
function imgui.BeginChild(str_id, size, border) end
function imgui.BeginChild(str_id, size, border, flags) end
function imgui.BeginChild(id) end
function imgui.BeginChild(id, size) end
function imgui.BeginChild(id, size, border) end
function imgui.BeginChild(id, size, border, flags) end
function imgui.BeginChildFrame(id, size) end
function imgui.BeginChildFrame(id, size, flags) end
function imgui.BeginCombo(label, preview_value) end
function imgui.BeginCombo(label, preview_value, flags) end
function imgui.BeginDragDropSource() end
function imgui.BeginDragDropSource(flags) end
function imgui.BeginDragDropTarget() end
function imgui.BeginGroup() end
function imgui.BeginMainMenuBar() end
function imgui.BeginMenu(label) end
function imgui.BeginMenu(label, enabled) end
function imgui.BeginMenuBar() end
function imgui.BeginPopup(str_id) end
function imgui.BeginPopup(str_id, flags) end
function imgui.BeginPopupContextItem() end
function imgui.BeginPopupContextItem(str_id) end
function imgui.BeginPopupContextItem(str_id, mouse_button) end
function imgui.BeginPopupContextVoid() end
function imgui.BeginPopupContextVoid(str_id) end
function imgui.BeginPopupContextVoid(str_id, mouse_button) end
function imgui.BeginPopupContextWindow() end
function imgui.BeginPopupContextWindow(str_id) end
function imgui.BeginPopupContextWindow(str_id, mouse_button) end
function imgui.BeginPopupContextWindow(str_id, mouse_button, also_over_items) end
function imgui.BeginPopupModal(name) end
function imgui.BeginPopupModal(name, p_open) end
function imgui.BeginPopupModal(name, p_open, flags) end
function imgui.BeginTabBar(str_id) end
function imgui.BeginTabBar(str_id, flags) end
function imgui.BeginTabItem(label) end
function imgui.BeginTabItem(label, p_open) end
function imgui.BeginTabItem(label, p_open, flags) end
function imgui.BeginTooltip() end
function imgui.Bullet() end
function imgui.BulletText(fmt) end
function imgui.Button(label) end
function imgui.Button(label, size) end
function imgui.CalcItemWidth() end
function imgui.CalcTextSize(text) end
function imgui.CaptureKeyboardFromApp() end
function imgui.CaptureKeyboardFromApp(want_capture_keyboard_value) end
function imgui.CaptureMouseFromApp() end
function imgui.CaptureMouseFromApp(want_capture_mouse_value) end
function imgui.Checkbox(label, v) end
function imgui.CheckboxFlags(label, flags, flags_value) end
function imgui.CloseCurrentPopup() end
function imgui.CollapsingHeader(label) end
function imgui.CollapsingHeader(label, flags) end
function imgui.CollapsingHeader(label, p_open) end
function imgui.CollapsingHeader(label, p_open, flags) end
function imgui.ColorButton(desc_id, col) end
function imgui.ColorButton(desc_id, col, flags) end
function imgui.ColorButton(desc_id, col, flags, size) end
function imgui.ColorEdit3(label, col) end
function imgui.ColorEdit3(label, col, flags) end
function imgui.ColorEdit4(label, col) end
function imgui.ColorEdit4(label, col, flags) end
function imgui.ColorPicker3(label, col) end
function imgui.ColorPicker3(label, col, flags) end
function imgui.ColorPicker4(label, col) end
function imgui.ColorPicker4(label, col, flags) end
function imgui.ColorPicker4(label, col, flags, ref_col) end
function imgui.Columns() end
function imgui.Columns(count) end
function imgui.Columns(count, id) end
function imgui.Columns(count, id, border) end
function imgui.Combo(label, current_item, items, items_count) end
function imgui.Combo(label, current_item, items, items_count, popup_max_height_in_items) end
function imgui.Combo(label, current_item, items_separated_by_zeros) end
function imgui.Combo(label, current_item, items_separated_by_zeros, popup_max_height_in_items) end
function imgui.CreateContext() end
function imgui.CreateContext(shared_font_atlas) end
function imgui.CreateVector2(x, y) end
function imgui.CreateVector3(x, y, z) end
function imgui.CreateVector4(w, x, y, z) end
function imgui.DebugCheckVersionAndDataLayout(version_str, sz_io, sz_style, sz_vec2, sz_vec4, sz_drawvert) end
function imgui.DestroyContext() end
function imgui.DestroyContext(ctx) end
function imgui.DragFloat(label, v) end
function imgui.DragFloat(label, v, v_speed) end
function imgui.DragFloat(label, v, v_speed, v_min) end
function imgui.DragFloat(label, v, v_speed, v_min, v_max) end
function imgui.DragFloat(label, v, v_speed, v_min, v_max, format) end
function imgui.DragFloat(label, v, v_speed, v_min, v_max, format, power) end
function imgui.DragFloat2(label, v) end
function imgui.DragFloat2(label, v, v_speed) end
function imgui.DragFloat2(label, v, v_speed, v_min) end
function imgui.DragFloat2(label, v, v_speed, v_min, v_max) end
function imgui.DragFloat2(label, v, v_speed, v_min, v_max, format) end
function imgui.DragFloat2(label, v, v_speed, v_min, v_max, format, power) end
function imgui.DragFloat3(label, v) end
function imgui.DragFloat3(label, v, v_speed) end
function imgui.DragFloat3(label, v, v_speed, v_min) end
function imgui.DragFloat3(label, v, v_speed, v_min, v_max) end
function imgui.DragFloat3(label, v, v_speed, v_min, v_max, format) end
function imgui.DragFloat3(label, v, v_speed, v_min, v_max, format, power) end
function imgui.DragFloat4(label, v) end
function imgui.DragFloat4(label, v, v_speed) end
function imgui.DragFloat4(label, v, v_speed, v_min) end
function imgui.DragFloat4(label, v, v_speed, v_min, v_max) end
function imgui.DragFloat4(label, v, v_speed, v_min, v_max, format) end
function imgui.DragFloat4(label, v, v_speed, v_min, v_max, format, power) end
function imgui.DragFloatRange2(label, v_current_min, v_current_max) end
function imgui.DragFloatRange2(label, v_current_min, v_current_max, v_speed) end
function imgui.DragFloatRange2(label, v_current_min, v_current_max, v_speed, v_min) end
function imgui.DragFloatRange2(label, v_current_min, v_current_max, v_speed, v_min, v_max) end
function imgui.DragFloatRange2(label, v_current_min, v_current_max, v_speed, v_min, v_max, format) end
function imgui.DragFloatRange2(label, v_current_min, v_current_max, v_speed, v_min, v_max, format, format_max) end
function imgui.DragFloatRange2(label, v_current_min, v_current_max, v_speed, v_min, v_max, format, format_max, power) end
function imgui.DragInt(label, v, v_speed, v_min, v_max) end
function imgui.DragInt(label, v, v_speed, v_min, v_max, format) end
function imgui.DragInt(label, v) end
function imgui.DragInt(label, v, v_speed) end
function imgui.DragInt(label, v, v_speed, v_min) end
function imgui.DragInt2(label, v) end
function imgui.DragInt2(label, v, v_speed) end
function imgui.DragInt2(label, v, v_speed, v_min) end
function imgui.DragInt2(label, v, v_speed, v_min, v_max) end
function imgui.DragInt2(label, v, v_speed, v_min, v_max, format) end
function imgui.DragInt3(label, v) end
function imgui.DragInt3(label, v, v_speed) end
function imgui.DragInt3(label, v, v_speed, v_min) end
function imgui.DragInt3(label, v, v_speed, v_min, v_max) end
function imgui.DragInt3(label, v, v_speed, v_min, v_max, format) end
function imgui.DragInt4(label, v) end
function imgui.DragInt4(label, v, v_speed) end
function imgui.DragInt4(label, v, v_speed, v_min) end
function imgui.DragInt4(label, v, v_speed, v_min, v_max) end
function imgui.DragInt4(label, v, v_speed, v_min, v_max, format) end
function imgui.DragIntRange2(label, v_current_min, v_current_max) end
function imgui.DragIntRange2(label, v_current_min, v_current_max, v_speed) end
function imgui.DragIntRange2(label, v_current_min, v_current_max, v_speed, v_min) end
function imgui.DragIntRange2(label, v_current_min, v_current_max, v_speed, v_min, v_max) end
function imgui.DragIntRange2(label, v_current_min, v_current_max, v_speed, v_min, v_max, format) end
function imgui.DragIntRange2(label, v_current_min, v_current_max, v_speed, v_min, v_max, format, format_max) end
function imgui.DragScalar(label, data_type, v, v_speed) end
function imgui.DragScalar(label, data_type, v, v_speed, v_min) end
function imgui.DragScalar(label, data_type, v, v_speed, v_min, v_max) end
function imgui.DragScalar(label, data_type, v, v_speed, v_min, v_max, format) end
function imgui.DragScalar(label, data_type, v, v_speed, v_min, v_max, format, power) end
function imgui.DragScalarN(label, data_type, v, components, v_speed) end
function imgui.DragScalarN(label, data_type, v, components, v_speed, v_min) end
function imgui.DragScalarN(label, data_type, v, components, v_speed, v_min, v_max) end
function imgui.DragScalarN(label, data_type, v, components, v_speed, v_min, v_max, format) end
function imgui.DragScalarN(label, data_type, v, components, v_speed, v_min, v_max, format, power) end
function imgui.Dummy(size) end
function imgui.End() end
function imgui.EndChild() end
function imgui.EndChildFrame() end
function imgui.EndCombo() end
function imgui.EndDragDropSource() end
function imgui.EndDragDropTarget() end
function imgui.EndFrame() end
function imgui.EndGroup() end
function imgui.EndMainMenuBar() end
function imgui.EndMenu() end
function imgui.EndMenuBar() end
function imgui.EndPopup() end
function imgui.EndTabBar() end
function imgui.EndTabItem() end
function imgui.EndTooltip() end
function imgui.GetClipboardText() end
function imgui.GetColorU32(idx) end
function imgui.GetColorU32(idx, alpha_mul) end
function imgui.GetColorU32(col) end
function imgui.GetColorU32(col) end
function imgui.GetColumnIndex() end
function imgui.GetColumnOffset() end
function imgui.GetColumnOffset(column_index) end
function imgui.GetColumnsCount() end
function imgui.GetColumnWidth() end
function imgui.GetColumnWidth(column_index) end
function imgui.GetContentRegionAvail() end
function imgui.GetContentRegionAvailWidth() end
function imgui.GetContentRegionMax() end
function imgui.GetCurrentContext() end
function imgui.GetCursorPos() end
function imgui.GetCursorPosX() end
function imgui.GetCursorPosY() end
function imgui.GetCursorScreenPos() end
function imgui.GetCursorStartPos() end
function imgui.GetDragDropPayload() end
function imgui.GetDrawData() end
function imgui.GetDrawListSharedData() end
function imgui.GetFont() end
function imgui.GetFontSize() end
function imgui.GetFontTexUvWhitePixel() end
function imgui.GetFrameCount() end
function imgui.GetFrameHeight() end
function imgui.GetFrameHeightWithSpacing() end
function imgui.GetID(ptr_id) end
function imgui.GetID(str_id) end
function imgui.GetIO() end
function imgui.GetItemRectMax() end
function imgui.GetItemRectMin() end
function imgui.GetItemRectSize() end
function imgui.GetKeyIndex(imgui_key) end
function imgui.GetKeyPressedAmount(key_index, repeat_delay, rate) end
function imgui.GetMouseCursor() end
function imgui.GetMouseDragDelta() end
function imgui.GetMouseDragDelta(button) end
function imgui.GetMouseDragDelta(button, lock_threshold) end
function imgui.GetMousePos() end
function imgui.GetMousePosOnOpeningCurrentPopup() end
function imgui.GetOverlayDrawList() end
function imgui.GetScrollMaxX() end
function imgui.GetScrollMaxY() end
function imgui.GetScrollX() end
function imgui.GetScrollY() end
function imgui.GetStateStorage() end
function imgui.GetStyle() end
function imgui.GetStyleColorName(idx) end
function imgui.GetTextLineHeight() end
function imgui.GetTextLineHeightWithSpacing() end
function imgui.GetTime() end
function imgui.GetTreeNodeToLabelSpacing() end
function imgui.GetVersion() end
function imgui.GetWindowContentRegionMax() end
function imgui.GetWindowContentRegionMin() end
function imgui.GetWindowContentRegionWidth() end
function imgui.GetWindowDrawList() end
function imgui.GetWindowHeight() end
function imgui.GetWindowPos() end
function imgui.GetWindowSize() end
function imgui.GetWindowWidth() end
function imgui.Image(user_texture_id, size) end
function imgui.Image(user_texture_id, size, uv0) end
function imgui.Image(user_texture_id, size, uv0, uv1) end
function imgui.Image(user_texture_id, size, uv0, uv1, tint_col) end
function imgui.Image(user_texture_id, size, uv0, uv1, tint_col, border_col) end
function imgui.ImageButton(user_texture_id, size) end
function imgui.ImageButton(user_texture_id, size, uv0) end
function imgui.ImageButton(user_texture_id, size, uv0, uv1) end
function imgui.ImageButton(user_texture_id, size, uv0, uv1, frame_padding) end
function imgui.ImageButton(user_texture_id, size, uv0, uv1, frame_padding, bg_col) end
function imgui.ImageButton(user_texture_id, size, uv0, uv1, frame_padding, bg_col, tint_col) end
function imgui.Indent() end
function imgui.Indent(indent_w) end
function imgui.InputDouble(label, v, step) end
function imgui.InputDouble(label, v, step, step_fast) end
function imgui.InputDouble(label, v, step, step_fast, format) end
function imgui.InputDouble(label, v, step, step_fast, format, flags) end
function imgui.InputDouble(label, v) end
function imgui.InputFloat(label, v) end
function imgui.InputFloat(label, v, step) end
function imgui.InputFloat(label, v, step, step_fast) end
function imgui.InputFloat(label, v, step, step_fast, format) end
function imgui.InputFloat(label, v, step, step_fast, format, flags) end
function imgui.InputFloat2(label, v) end
function imgui.InputFloat2(label, v, format) end
function imgui.InputFloat2(label, v, format, flags) end
function imgui.InputFloat3(label, v) end
function imgui.InputFloat3(label, v, format) end
function imgui.InputFloat3(label, v, format, flags) end
function imgui.InputFloat4(label, v) end
function imgui.InputFloat4(label, v, format) end
function imgui.InputFloat4(label, v, format, flags) end
function imgui.InputInt(label, v) end
function imgui.InputInt(label, v, step) end
function imgui.InputInt(label, v, step, step_fast) end
function imgui.InputInt(label, v, step, step_fast, flags) end
function imgui.InputInt2(label, v) end
function imgui.InputInt2(label, v, flags) end
function imgui.InputInt3(label, v) end
function imgui.InputInt3(label, v, flags) end
function imgui.InputInt4(label, v) end
function imgui.InputInt4(label, v, flags) end
function imgui.InputScalar(label, data_type, v) end
function imgui.InputScalar(label, data_type, v, step) end
function imgui.InputScalar(label, data_type, v, step, step_fast) end
function imgui.InputScalar(label, data_type, v, step, step_fast, format) end
function imgui.InputScalar(label, data_type, v, step, step_fast, format, flags) end
function imgui.InputScalarN(label, data_type, v, components) end
function imgui.InputScalarN(label, data_type, v, components, step) end
function imgui.InputScalarN(label, data_type, v, components, step, step_fast) end
function imgui.InputScalarN(label, data_type, v, components, step, step_fast, format) end
function imgui.InputScalarN(label, data_type, v, components, step, step_fast, format, flags) end
function imgui.InputText(label, buf, buf_size) end
function imgui.InputText(label, buf, buf_size, flags) end
function imgui.InputText(label, buf, buf_size, flags, callback) end
function imgui.InputText(label, buf, buf_size, flags, callback, user_data) end
function imgui.InputText(label, input, maxLength) end
function imgui.InputText(label, input, maxLength, flags) end
function imgui.InputText(label, input, maxLength, flags, callback) end
function imgui.InputText(label, input, maxLength, flags, callback, user_data) end
function imgui.InputText(label, buf, buf_size) end
function imgui.InputText(label, buf, buf_size, flags) end
function imgui.InputText(label, buf, buf_size, flags, callback) end
function imgui.InputText(label, buf, buf_size, flags, callback, user_data) end
function imgui.InputTextMultiline(label, input, maxLength, size) end
function imgui.InputTextMultiline(label, input, maxLength, size, flags) end
function imgui.InputTextMultiline(label, input, maxLength, size, flags, callback) end
function imgui.InputTextMultiline(label, input, maxLength, size, flags, callback, user_data) end
function imgui.InvisibleButton(str_id, size) end
function imgui.IsAnyItemActive() end
function imgui.IsAnyItemFocused() end
function imgui.IsAnyItemHovered() end
function imgui.IsAnyMouseDown() end
function imgui.IsItemActive() end
function imgui.IsItemClicked() end
function imgui.IsItemClicked(mouse_button) end
function imgui.IsItemDeactivated() end
function imgui.IsItemDeactivatedAfterEdit() end
function imgui.IsItemEdited() end
function imgui.IsItemFocused() end
function imgui.IsItemHovered() end
function imgui.IsItemHovered(flags) end
function imgui.IsItemVisible() end
function imgui.IsKeyDown(user_key_index) end
function imgui.IsKeyPressed(user_key_index) end
function imgui.IsKeyPressed(user_key_index, rep) end
function imgui.IsKeyReleased(user_key_index) end
function imgui.IsMouseClicked(button) end
function imgui.IsMouseClicked(button, rep) end
function imgui.IsMouseDoubleClicked(button) end
function imgui.IsMouseDown(button) end
function imgui.IsMouseDragging() end
function imgui.IsMouseDragging(button) end
function imgui.IsMouseDragging(button, lock_threshold) end
function imgui.IsMouseHoveringRect(r_min, r_max) end
function imgui.IsMouseHoveringRect(r_min, r_max, clip) end
function imgui.IsMousePosValid() end
function imgui.IsMousePosValid(mouse_pos) end
function imgui.IsMouseReleased(button) end
function imgui.IsPopupOpen(str_id) end
function imgui.IsRectVisible(size) end
function imgui.IsRectVisible(rect_min, rect_max) end
function imgui.IsWindowAppearing() end
function imgui.IsWindowCollapsed() end
function imgui.IsWindowFocused() end
function imgui.IsWindowFocused(flags) end
function imgui.IsWindowHovered() end
function imgui.IsWindowHovered(flags) end
function imgui.LabelText(label, fmt) end
function imgui.ListBox(label, current_item, items, items_count) end
function imgui.ListBox(label, current_item, items, items_count, height_in_items) end
function imgui.ListBoxFooter() end
function imgui.ListBoxHeader(label) end
function imgui.ListBoxHeader(label, size) end
function imgui.ListBoxHeader(label, items_count) end
function imgui.ListBoxHeader(label, items_count, height_in_items) end
function imgui.LoadIniSettingsFromDisk(ini_filename) end
function imgui.LoadIniSettingsFromMemory(ini_data) end
function imgui.LoadIniSettingsFromMemory(ini_data, ini_size) end
function imgui.LogButtons() end
function imgui.LogFinish() end
function imgui.LogText(fmt) end
function imgui.LogToClipboard() end
function imgui.LogToClipboard(max_depth) end
function imgui.LogToFile() end
function imgui.LogToFile(max_depth) end
function imgui.LogToFile(max_depth, filename) end
function imgui.LogToTTY() end
function imgui.LogToTTY(max_depth) end
function imgui.MemAlloc(size) end
function imgui.MemFree(ptr) end
function imgui.MenuItem(label, enabled) end
function imgui.MenuItem(label) end
function imgui.MenuItem(label, shortcut) end
function imgui.MenuItem(label, shortcut, selected) end
function imgui.MenuItem(label, shortcut, selected, enabled) end
function imgui.MenuItem(label, shortcut, p_selected) end
function imgui.MenuItem(label, shortcut, p_selected, enabled) end
function imgui.NewFrame() end
function imgui.NewLine() end
function imgui.NextColumn() end
function imgui.OpenPopup(str_id) end
function imgui.OpenPopupOnItemClick() end
function imgui.OpenPopupOnItemClick(str_id) end
function imgui.OpenPopupOnItemClick(str_id, mouse_button) end
function imgui.PlotHistogram(label, values, values_count) end
function imgui.PlotHistogram(label, values, values_count, values_offset) end
function imgui.PlotHistogram(label, values, values_count, values_offset, overlay_text) end
function imgui.PlotHistogram(label, values, values_count, values_offset, overlay_text, scale_min) end
function imgui.PlotHistogram(label, values, values_count, values_offset, overlay_text, scale_min, scale_max) end
function imgui.PlotHistogram(label, values, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size) end
function imgui.PlotHistogram(label, values, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size, stride) end
function imgui.PlotLines(label, values, values_count) end
function imgui.PlotLines(label, values, values_count, values_offset) end
function imgui.PlotLines(label, values, values_count, values_offset, overlay_text) end
function imgui.PlotLines(label, values, values_count, values_offset, overlay_text, scale_min) end
function imgui.PlotLines(label, values, values_count, values_offset, overlay_text, scale_min, scale_max) end
function imgui.PlotLines(label, values, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size) end
function imgui.PlotLines(label, values, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size, stride) end
function imgui.PopAllowKeyboardFocus() end
function imgui.PopButtonRepeat() end
function imgui.PopClipRect() end
function imgui.PopFont() end
function imgui.PopID() end
function imgui.PopItemWidth() end
function imgui.PopStyleColor() end
function imgui.PopStyleColor(count) end
function imgui.PopStyleVar() end
function imgui.PopStyleVar(count) end
function imgui.PopTextWrapPos() end
function imgui.ProgressBar(fraction) end
function imgui.ProgressBar(fraction, size_arg) end
function imgui.ProgressBar(fraction, size_arg, overlay) end
function imgui.PushAllowKeyboardFocus(allow_keyboard_focus) end
function imgui.PushButtonRepeat(rep) end
function imgui.PushClipRect(clip_rect_min, clip_rect_max, intersect_with_current_clip_rect) end
function imgui.PushFont(font) end
function imgui.PushID(int_id) end
function imgui.PushID(ptr_id) end
function imgui.PushID(str_id) end
function imgui.PushItemWidth(item_width) end
function imgui.PushStyleColor(idx, col) end
function imgui.PushStyleColor(idx, col) end
function imgui.PushStyleVar(idx, val) end
function imgui.PushStyleVar(idx, val) end
function imgui.PushTextWrapPos() end
function imgui.PushTextWrapPos(wrap_local_pos_x) end
function imgui.RadioButton(label, active) end
function imgui.RadioButton(label, v, v_button) end
function imgui.Render() end
function imgui.ResetMouseDragDelta() end
function imgui.ResetMouseDragDelta(button) end
function imgui.SameLine() end
function imgui.SameLine(local_pos_x) end
function imgui.SameLine(local_pos_x, spacing_w) end
function imgui.Selectable(label) end
function imgui.Selectable(label, selected) end
function imgui.Selectable(label, selected, flags) end
function imgui.Selectable(label, selected, flags, size) end
function imgui.Selectable(label, p_selected) end
function imgui.Selectable(label, p_selected, flags) end
function imgui.Selectable(label, p_selected, flags, size) end
function imgui.Separator() end
function imgui.SetClipboardText(text) end
function imgui.SetColorEditOptions(flags) end
function imgui.SetColumnOffset(column_index, offset_x) end
function imgui.SetColumnWidth(column_index, width) end
function imgui.SetCurrentContext(ctx) end
function imgui.SetCursorPos(local_pos) end
function imgui.SetCursorPosX(local_x) end
function imgui.SetCursorPosY(local_y) end
function imgui.SetCursorScreenPos(pos) end
function imgui.SetDragDropPayload(type, data, size) end
function imgui.SetDragDropPayload(type, data, size, cond) end
function imgui.SetItemAllowOverlap() end
function imgui.SetItemDefaultFocus() end
function imgui.SetKeyboardFocusHere() end
function imgui.SetKeyboardFocusHere(offset) end
function imgui.SetMouseCursor(type) end
function imgui.SetNextTreeNodeOpen(is_open) end
function imgui.SetNextTreeNodeOpen(is_open, cond) end
function imgui.SetNextWindowBgAlpha(alpha) end
function imgui.SetNextWindowCollapsed(collapsed) end
function imgui.SetNextWindowCollapsed(collapsed, cond) end
function imgui.SetNextWindowContentSize(size) end
function imgui.SetNextWindowFocus() end
function imgui.SetNextWindowPos(pos) end
function imgui.SetNextWindowPos(pos, cond) end
function imgui.SetNextWindowPos(pos, cond, pivot) end
function imgui.SetNextWindowSize(size) end
function imgui.SetNextWindowSize(size, cond) end
function imgui.SetNextWindowSizeConstraints(size_min, size_max) end
function imgui.SetNextWindowSizeConstraints(size_min, size_max, custom_callback) end
function imgui.SetNextWindowSizeConstraints(size_min, size_max, custom_callback, custom_callback_data) end
function imgui.SetScrollFromPosY(local_y) end
function imgui.SetScrollFromPosY(local_y, center_y_ratio) end
function imgui.SetScrollHereY() end
function imgui.SetScrollHereY(center_y_ratio) end
function imgui.SetScrollX(scroll_x) end
function imgui.SetScrollY(scroll_y) end
function imgui.SetStateStorage(storage) end
function imgui.SetTabItemClosed(tab_or_docked_window_label) end
function imgui.SetTooltip(fmt) end
function imgui.SetWindowCollapsed(collapsed) end
function imgui.SetWindowCollapsed(collapsed, cond) end
function imgui.SetWindowCollapsed(name, collapsed) end
function imgui.SetWindowCollapsed(name, collapsed, cond) end
function imgui.SetWindowFocus() end
function imgui.SetWindowFocus(name) end
function imgui.SetWindowFontScale(scale) end
function imgui.SetWindowPos(name, pos) end
function imgui.SetWindowPos(name, pos, cond) end
function imgui.SetWindowPos(pos) end
function imgui.SetWindowPos(pos, cond) end
function imgui.SetWindowSize(name, size) end
function imgui.SetWindowSize(name, size, cond) end
function imgui.SetWindowSize(size) end
function imgui.SetWindowSize(size, cond) end
function imgui.ShowAboutWindow() end
function imgui.ShowAboutWindow(p_open) end
function imgui.ShowDemoWindow() end
function imgui.ShowDemoWindow(p_open) end
function imgui.ShowFontSelector(label) end
function imgui.ShowMetricsWindow() end
function imgui.ShowMetricsWindow(p_open) end
function imgui.ShowStyleEditor() end
function imgui.ShowStyleEditor(ptr) end
function imgui.ShowStyleSelector(label) end
function imgui.ShowUserGuide() end
function imgui.SliderAngle(label, v_rad) end
function imgui.SliderAngle(label, v_rad, v_degrees_min) end
function imgui.SliderAngle(label, v_rad, v_degrees_min, v_degrees_max) end
function imgui.SliderAngle(label, v_rad, v_degrees_min, v_degrees_max, format) end
function imgui.SliderFloat(label, v, v_min, v_max) end
function imgui.SliderFloat(label, v, v_min, v_max, format) end
function imgui.SliderFloat(label, v, v_min, v_max, format, power) end
function imgui.SliderFloat2(label, v, v_min, v_max) end
function imgui.SliderFloat2(label, v, v_min, v_max, format) end
function imgui.SliderFloat2(label, v, v_min, v_max, format, power) end
function imgui.SliderFloat3(label, v, v_min, v_max) end
function imgui.SliderFloat3(label, v, v_min, v_max, format) end
function imgui.SliderFloat3(label, v, v_min, v_max, format, power) end
function imgui.SliderFloat4(label, v, v_min, v_max, format, power) end
function imgui.SliderFloat4(label, v, v_min, v_max) end
function imgui.SliderFloat4(label, v, v_min, v_max, format) end
function imgui.SliderInt(label, v, v_min, v_max) end
function imgui.SliderInt(label, v, v_min, v_max, format) end
function imgui.SliderInt2(label, v, v_min, v_max) end
function imgui.SliderInt2(label, v, v_min, v_max, format) end
function imgui.SliderInt3(label, v, v_min, v_max) end
function imgui.SliderInt3(label, v, v_min, v_max, format) end
function imgui.SliderInt4(label, v, v_min, v_max) end
function imgui.SliderInt4(label, v, v_min, v_max, format) end
function imgui.SliderScalar(label, data_type, v, v_min, v_max) end
function imgui.SliderScalar(label, data_type, v, v_min, v_max, format) end
function imgui.SliderScalar(label, data_type, v, v_min, v_max, format, power) end
function imgui.SliderScalarN(label, data_type, v, components, v_min, v_max) end
function imgui.SliderScalarN(label, data_type, v, components, v_min, v_max, format) end
function imgui.SliderScalarN(label, data_type, v, components, v_min, v_max, format, power) end
function imgui.SmallButton(label) end
function imgui.Spacing() end
function imgui.StyleColorsClassic() end
function imgui.StyleColorsClassic(dst) end
function imgui.StyleColorsDark() end
function imgui.StyleColorsDark(dst) end
function imgui.StyleColorsLight() end
function imgui.StyleColorsLight(dst) end
function imgui.Text(fmt) end
function imgui.TextColored(col, fmt) end
function imgui.TextDisabled(fmt) end
function imgui.TextUnformatted(text) end
function imgui.TextWrapped(fmt) end
function imgui.TreeAdvanceToLabelPos() end
function imgui.TreeNode(ptr_id, fmt) end
function imgui.TreeNode(label) end
function imgui.TreeNode(str_id, fmt) end
function imgui.TreeNodeEx(ptr_id, flags, fmt) end
function imgui.TreeNodeEx(label) end
function imgui.TreeNodeEx(label, flags) end
function imgui.TreeNodeEx(str_id, flags, fmt) end
function imgui.TreePop() end
function imgui.TreePush() end
function imgui.TreePush(ptr_id) end
function imgui.TreePush(str_id) end
function imgui.Unindent() end
function imgui.Unindent(indent_w) end
function imgui.Value(prefix, b) end
function imgui.Value(prefix, v) end
function imgui.Value(prefix, v) end
function imgui.Value(prefix, v) end
function imgui.Value(prefix, v, float_format) end
function imgui.VSliderFloat(label, size, v, v_min, v_max) end
function imgui.VSliderFloat(label, size, v, v_min, v_max, format) end
function imgui.VSliderFloat(label, size, v, v_min, v_max, format, power) end
function imgui.VSliderInt(label, size, v, v_min, v_max) end
function imgui.VSliderInt(label, size, v, v_min, v_max, format) end
function imgui.VSliderScalar(label, size, data_type, v, v_min, v_max) end
function imgui.VSliderScalar(label, size, data_type, v, v_min, v_max, format) end
function imgui.VSliderScalar(label, size, data_type, v, v_min, v_max, format, power) end

-- ./Quaver/Quaver.Shared/Scripting/LuaPluginState.cs
state.DeltaTime = 0.0 -- double
state.UnixTime = 0 -- long
state.IsWindowHovered = false -- bool
state.Values = {} -- Dictionary<string, object>
state.WindowSize = {} -- Vector2
function state.GetValue(key) end
function state.SetValue(key, value) end

-- ./Quaver/Quaver.Shared/Screens/Edit/Plugins/EditorPluginState.cs
state.SongTime = 0.0 -- double
state.SelectedHitObjects = {} -- List<HitObjectInfo>
state.CurrentTimingPoint = {} -- TimingPointInfo
state.CurrentLayer = {} -- EditorLayerInfo
state.CurrentSnap = 0 -- int
function state.PushImguiStyle() end

-- ./Quaver/Quaver.Shared/Screens/Edit/Plugins/EditorPluginMap.cs
map.Mode = game_mode.Keys4 -- GameMode
map.Normalized = false -- bool
map.ScrollVelocities = {} -- List<SliderVelocityInfo>
map.HitObjects = {} -- List<HitObjectInfo>
map.TimingPoints = {} -- List<TimingPointInfo>
map.EditorLayers = {} -- List<EditorLayerInfo>
map.DefaultLayer = {} -- EditorLayerInfo
map.TrackLength = 0.0 -- double
function map.ToString() end
function map.GetKeyCount(includeScratch) end
function map.GetCommonBpm() end
function map.GetTimingPointAt(time) end
function map.GetScrollVelocityAt(time) end
function map.GetTimingPointLength(point) end
function map.GetNearestSnapTimeFromTime(forwards, snap, time) end

-- ./Quaver/Quaver.Shared/Screens/Edit/Plugins/EditorPluginUtils.cs
function utils.CreateScrollVelocity(time, multiplier) end
function utils.CreateHitObject(startTime, lane, endTime, hitsounds, editorLayer) end
function utils.CreateTimingPoint(startTime, bpm, signature, hidden) end
function utils.CreateEditorLayer(name, hidden, colorRgb) end
function utils.CreateEditorAction(type, args) end
function utils.EditorActionPlaceHitObject() end
function utils.EditorActionRemoveHitObject() end
function utils.EditorActionResizeLongNote() end
function utils.EditorActionRemoveHitObjectBatch() end
function utils.EditorActionPlaceHitObjectBatch() end
function utils.EditorActionCreateLayer() end
function utils.EditorActionRemoveLayer() end
function utils.EditorActionRenameLayer() end
function utils.EditorActionMoveObjectsToLayer() end
function utils.EditorActionChangeLayerColor() end
function utils.EditorActionToggleLayerVisibility() end
function utils.EditorActionAddScrollVelocity() end
function utils.EditorActionRemoveScrollVelocity() end
function utils.EditorActionAddScrollVelocityBatch() end
function utils.EditorActionRemoveScrollVelocityBatch() end
function utils.EditorActionAddTimingPoint() end
function utils.EditorActionRemoveTimingPoint() end
function utils.EditorActionAddTimingPointBatch() end
function utils.EditorActionRemoveTimingPointBatch() end
function utils.EditorActionChangeTimingPointOffset() end
function utils.EditorActionChangeTimingPointBpm() end
function utils.EditorActionResetTimingPoint() end
function utils.EditorActionChangeTimingPointBpmBatch() end
function utils.EditorActionChangeTimingPointOffsetBatch() end
function utils.EditorActionChangeScrollVelocityOffsetBatch() end
function utils.EditorActionChangeScrollVelocityMultiplierBatch() end
function utils.EditorActionResnapHitObjects() end
function utils.EditorActionBatch() end
function utils.MillisecondsToTime(time) end
function utils.IsKeyPressed(k) end
function utils.IsKeyReleased(k) end
function utils.IsKeyDown(k) end
function utils.IsKeyUp(k) end

-- ./Quaver/Quaver.Shared/Screens/Edit/Actions/EditorPluginActionManager.cs
function actions.Perform(action) end
function actions.PerformBatch(actions) end
function actions.PlaceHitObject(h) end
function actions.PlaceHitObject(lane, startTime, endTime, layer, hitsounds) end
function actions.PlaceHitObjectBatch(hitObjects) end
function actions.RemoveHitObject(h) end
function actions.RemoveHitObjectBatch(hitObjects) end
function actions.ResizeLongNote(h, originalTime, time) end
function actions.PlaceScrollVelocity(sv) end
function actions.PlaceScrollVelocityBatch(svs) end
function actions.RemoveScrollVelocity(sv) end
function actions.RemoveScrollVelocityBatch(svs) end
function actions.PlaceTimingPoint(tp) end
function actions.RemoveTimingPoint(tp) end
function actions.PlaceTimingPointBatch(tps) end
function actions.RemoveTimingPointBatch(tps) end
function actions.ChangeTimingPointOffset(tp, offset) end
function actions.ChangeTimingPointBpm(tp, bpm) end
function actions.ChangeTimingPointHidden(tp, hidden) end
function actions.ChangeTimingPointBpmBatch(tps, bpm) end
function actions.ChangeTimingPointOffsetBatch(tps, offset) end
function actions.ResetTimingPoint(tp) end
function actions.GoToObjects(input) end
function actions.SetHitObjectSelection(hitObjects) end
function actions.DetectBpm() end
function actions.SetPreviewTime(time) end
function actions.CreateLayer(layer, index) end
function actions.RemoveLayer(layer) end
function actions.RenameLayer(layer, name) end
function actions.MoveHitObjectsToLayer(layer, hitObjects) end
function actions.ChangeLayerColor(layer, r, g, b) end
function actions.ToggleLayerVisibility(layer) end
function actions.ResnapNotes(snaps, hitObjectsToResnap) end

-- ./Quaver/Wobble/MonoGame/MonoGame.Framework/Input/Keys.cs
keys = {
    None = 0, -- Reserved.
    Back = 8, -- BACKSPACE key.
    Tab = 9, -- TAB key.
    Enter = 13, -- ENTER key.
    CapsLock = 20, -- CAPS LOCK key.
    Escape = 27, -- ESC key.
    Space = 32, -- SPACEBAR key.
    PageUp = 33, -- PAGE UP key.
    PageDown = 34, -- PAGE DOWN key.
    End = 35, -- END key.
    Home = 36, -- HOME key.
    Left = 37, -- LEFT ARROW key.
    Up = 38, -- UP ARROW key.
    Right = 39, -- RIGHT ARROW key.
    Down = 40, -- DOWN ARROW key.
    Select = 41, -- SELECT key.
    Print = 42, -- PRINT key.
    Execute = 43, -- EXECUTE key.
    PrintScreen = 44, -- PRINT SCREEN key.
    Insert = 45, -- INS key.
    Delete = 46, -- DEL key.
    Help = 47, -- HELP key.
    D0 = 48, -- Used for miscellaneous characters; it can vary by keyboard.
    D1 = 49, -- Used for miscellaneous characters; it can vary by keyboard.
    D2 = 50, -- Used for miscellaneous characters; it can vary by keyboard.
    D3 = 51, -- Used for miscellaneous characters; it can vary by keyboard.
    D4 = 52, -- Used for miscellaneous characters; it can vary by keyboard.
    D5 = 53, -- Used for miscellaneous characters; it can vary by keyboard.
    D6 = 54, -- Used for miscellaneous characters; it can vary by keyboard.
    D7 = 55, -- Used for miscellaneous characters; it can vary by keyboard.
    D8 = 56, -- Used for miscellaneous characters; it can vary by keyboard.
    D9 = 57, -- Used for miscellaneous characters; it can vary by keyboard.
    A = 65, -- A key.
    B = 66, -- B key.
    C = 67, -- C key.
    D = 68, -- D key.
    E = 69, -- E key.
    F = 70, -- F key.
    G = 71, -- G key.
    H = 72, -- H key.
    I = 73, -- I key.
    J = 74, -- J key.
    K = 75, -- K key.
    L = 76, -- L key.
    M = 77, -- M key.
    N = 78, -- N key.
    O = 79, -- O key.
    P = 80, -- P key.
    Q = 81, -- Q key.
    R = 82, -- R key.
    S = 83, -- S key.
    T = 84, -- T key.
    U = 85, -- U key.
    V = 86, -- V key.
    W = 87, -- W key.
    X = 88, -- X key.
    Y = 89, -- Y key.
    Z = 90, -- Z key.
    LeftWindows = 91, -- Left Windows key.
    RightWindows = 92, -- Right Windows key.
    Apps = 93, -- Applications key.
    Sleep = 95, -- Computer Sleep key.
    NumPad0 = 96, -- Numeric keypad 0 key.
    NumPad1 = 97, -- Numeric keypad 1 key.
    NumPad2 = 98, -- Numeric keypad 2 key.
    NumPad3 = 99, -- Numeric keypad 3 key.
    NumPad4 = 100, -- Numeric keypad 4 key.
    NumPad5 = 101, -- Numeric keypad 5 key.
    NumPad6 = 102, -- Numeric keypad 6 key.
    NumPad7 = 103, -- Numeric keypad 7 key.
    NumPad8 = 104, -- Numeric keypad 8 key.
    NumPad9 = 105, -- Numeric keypad 9 key.
    Multiply = 106, -- Multiply key.
    Add = 107, -- Add key.
    Separator = 108, -- Separator key.
    Subtract = 109, -- Subtract key.
    Decimal = 110, -- Decimal key.
    Divide = 111, -- Divide key.
    F1 = 112, -- F1 key.
    F2 = 113, -- F2 key.
    F3 = 114, -- F3 key.
    F4 = 115, -- F4 key.
    F5 = 116, -- F5 key.
    F6 = 117, -- F6 key.
    F7 = 118, -- F7 key.
    F8 = 119, -- F8 key.
    F9 = 120, -- F9 key.
    F10 = 121, -- F10 key.
    F11 = 122, -- F11 key.
    F12 = 123, -- F12 key.
    F13 = 124, -- F13 key.
    F14 = 125, -- F14 key.
    F15 = 126, -- F15 key.
    F16 = 127, -- F16 key.
    F17 = 128, -- F17 key.
    F18 = 129, -- F18 key.
    F19 = 130, -- F19 key.
    F20 = 131, -- F20 key.
    F21 = 132, -- F21 key.
    F22 = 133, -- F22 key.
    F23 = 134, -- F23 key.
    F24 = 135, -- F24 key.
    NumLock = 144, -- NUM LOCK key.
    Scroll = 145, -- SCROLL LOCK key.
    LeftShift = 160, -- Left SHIFT key.
    RightShift = 161, -- Right SHIFT key.
    LeftControl = 162, -- Left CONTROL key.
    RightControl = 163, -- Right CONTROL key.
    LeftAlt = 164, -- Left ALT key.
    RightAlt = 165, -- Right ALT key.
    BrowserBack = 166, -- Browser Back key.
    BrowserForward = 167, -- Browser Forward key.
    BrowserRefresh = 168, -- Browser Refresh key.
    BrowserStop = 169, -- Browser Stop key.
    BrowserSearch = 170, -- Browser Search key.
    BrowserFavorites = 171, -- Browser Favorites key.
    BrowserHome = 172, -- Browser Start and Home key.
	VolumeMute = 173, -- Volume Mute key.
    VolumeDown = 174, -- Volume Down key.
    VolumeUp = 175, -- Volume Up key.
    MediaNextTrack = 176, -- Next Track key.
    MediaPreviousTrack = 177, -- Previous Track key.
    MediaStop = 178, -- Stop Media key.
    MediaPlayPause = 179, -- Play/Pause Media key.
    LaunchMail = 180, -- Start Mail key.
    SelectMedia = 181, -- Select Media key.
    LaunchApplication1 = 182, -- Start Application 1 key.
    LaunchApplication2 = 183, -- Start Application 2 key.
    OemSemicolon = 186, -- The OEM Semicolon key on a US standard keyboard.
    OemPlus = 187, -- For any country/region, the '+' key.
    OemComma = 188, -- For any country/region, the ',' key.
    OemMinus = 189, -- For any country/region, the '-' key.
    OemPeriod = 190, -- For any country/region, the '.' key.
    OemQuestion = 191, -- The OEM question mark key on a US standard keyboard.
    OemTilde = 192, -- The OEM tilde key on a US standard keyboard.
    OemColon = 193, -- :
    OemExclamationMark = 194, -- !
    PunctuatedU = 195, -- ù
    Asterisk = 196, -- *
    Caret = 197, -- ^
    DollarSign = 198, -- $
    OemCloseParenthesis = 199, -- )
    Squared = 200, -- ²
    OemOpenBrackets = 219, -- The OEM open bracket key on a US standard keyboard.
    OemPipe = 220, -- The OEM pipe key on a US standard keyboard.
    OemCloseBrackets = 221, -- The OEM close bracket key on a US standard keyboard.
    OemQuotes = 222, -- The OEM singled/double quote key on a US standard keyboard.
    Oem8 = 223, -- Used for miscellaneous characters; it can vary by keyboard.
    OemBackslash = 226, -- The OEM angle bracket or backslash key on the RT 102 key keyboard.
    ProcessKey = 229, -- IME PROCESS key.
    Attn = 246, -- Attn key.
    Crsel = 247, -- CrSel key.
    Exsel = 248, -- ExSel key.
    EraseEof = 249, -- Erase EOF key.
    Play = 250, -- Play key.
    Zoom = 251, -- Zoom key.
    Pa1 = 253, -- PA1 key.
    OemClear = 254, -- CLEAR key.
    ChatPadGreen = 0xCA, -- Green ChatPad key.
    ChatPadOrange = 0xCB, -- Orange ChatPad key.
    Pause = 0x13, -- PAUSE key.
    ImeConvert = 0x1c, -- IME Convert key.
    ImeNoConvert = 0x1d, -- IME NoConvert key.
    Kana = 0x15, -- Kana key on Japanese keyboards.
    Kanji = 0x19, -- Kanji key on Japanese keyboards.
    OemAuto = 0xf3, -- OEM Auto key.
    OemCopy = 0xf2, -- OEM Copy key.
    OemEnlW = 0xf4 -- OEM Enlarge Window key.
}