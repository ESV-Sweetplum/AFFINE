---Places given svs and lines, and cleans both.
---@param lines TimingPointInfo[] # The lines to place.
---@param svs SliderVelocityInfo[] # The svs to place.
---@param lower number # Lower bound of the constraint.
---@param upper number # Upper bound of the constraint.
---@param affineType string # The name of the effect being placed.
---@param debugData? table # Information about the AFFINE frame dataset.
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

    local newGlobalTable = {
        label = affineType:gsub(" ", ""),
        lower = lower,
        upper = upper,
        numLines = #lines,
        numSVs = (debugData and debugData.S) and debugData.S or #svs,
    } ---@type AffineSaveTable

    table.insert(globalData, newGlobalTable)

    table.insert(bookmarks, saveMapState(globalData, false))

    actions.PerformBatch({
        utils.CreateEditorAction(action_type.AddTimingPointBatch, lines),
        utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs),
        utils.CreateEditorAction(action_type.AddBookmarkBatch, bookmarks),
    })
end
