---Places given svs and lines, and cleans both.
---@param lines TimingPointInfo[]
---@param svs SliderVelocityInfo[]
---@param lower number
---@param upper number
---@param keepColors? boolean
function generateAffines(lines, svs, lower, upper, keepColors)
    if (not upper or upper == lower) then
        ---@diagnostic disable-next-line: cast-local-type
        upper = map.GetNearestSnapTimeFromTime(true, 1, lower);
    end

    lines = cleanLines(lines, lower, upper)
    svs = cleanSVs(svs, lower, upper)

    actions.PerformBatch({
        utils.CreateEditorAction(action_type.AddTimingPointBatch, lines),
        utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs),
    })
end
