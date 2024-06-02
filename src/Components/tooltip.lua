---Creates a tooltip hoverable element.
---@param text string # The text of the tooltip during hovering.
function Tooltip(text)
    imgui.SameLine(0, 4)
    imgui.TextDisabled("(?)")
    if not imgui.IsItemHovered() then return end
    imgui.BeginTooltip()
    imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
    imgui.Text(text)
    imgui.PopTextWrapPos()
    imgui.EndTooltip()
end
