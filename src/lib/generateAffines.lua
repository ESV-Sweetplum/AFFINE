---Places given svs and lines, and cleans both.
---@param lines TimingPointInfo[]
---@param svs SliderVelocityInfo[]
---@param lower number
---@param upper number
---@param affineType string
---@param debugData? table
function generateAffines(lines, svs, lower, upper, affineType, debugData)
    if (not upper or upper == lower) then
        ---@diagnostic disable-next-line: cast-local-type
        upper = map.GetNearestSnapTimeFromTime(true, 1, lower);
    end

    lines = cleanLines(lines, lower, upper)
    svs = cleanSVs(svs, lower, upper)

    local debugString = ""
    if (debugData) then
        for k, v in pairs(debugData) do
            debugString = debugString .. " | " .. k .. ": " .. v
        end
    end

    local bookmarks = {
        utils.CreateBookmark(lower, affineType .. " Start" .. debugString),
        utils.CreateBookmark(upper, affineType .. " End")
    }

    actions.PerformBatch({
        utils.CreateEditorAction(action_type.AddTimingPointBatch, lines),
        utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs),
        utils.CreateEditorAction(action_type.AddBookmarkBatch, bookmarks),
    })
end
