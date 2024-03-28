function generateAffines(lines, svs, lower, upper)
    lines = cleanLines(lines, lower, upper)
    svs = cleanSVs(svs, lower, upper)

    actions.PerformBatch({
        utils.CreateEditorAction(action_type.AddTimingPointBatch, lines),
        utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs)
    })
end
