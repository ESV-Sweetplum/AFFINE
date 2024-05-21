function ReverseSVOrderMenu()
    if RangeActivated("Switch", "SVs") then
        local svsToReverse = getSVsInRange(offsets.startOffset, offsets.endOffset)

        local newSVs = reverseSVs(svsToReverse)

        actions.PerformBatch({
            utils.CreateEditorAction(action_type.AddScrollVelocityBatch, newSVs),
            utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, svsToReverse)
        })
    end
end

function reverseSVs(svs)
    local newTbl = {}

    for idx, item in ipairs(svs) do
        table.insert(newTbl, sv(svs[#svs - idx + 1].StartTime, item.Multiplier))
    end

    return newTbl
end
