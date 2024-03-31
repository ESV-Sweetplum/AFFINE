function generateAffines(lines, svs, lower, upper, keepColors)
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

function getNotesInRange(lower, upper)
    local base = map.HitObjects

    local tbl = {}

    for _, v in pairs(base) do
        if (v.StartTime >= lower) and (v.StartTime <= upper) then
            table.insert(tbl, v.StartTime)
        end
    end

    return tbl
end
