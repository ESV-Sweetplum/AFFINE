function generateAffines(lines, svs, lower, upper)
    if (not upper or upper == lower) then
        upper = map.GetNearestSnapTimeFromTime(true, 1, lower);
    end

    lines = cleanLines(lines, lower, upper)
    svs = cleanSVs(svs, lower, upper)

    actions.PerformBatch({
        utils.CreateEditorAction(action_type.AddTimingPointBatch, lines),
        utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs)
    })
end
