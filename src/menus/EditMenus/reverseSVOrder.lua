function ReverseSVOrderMenu()
    local settings = parameterWorkflow("edit_reverseSV", {
        inputType = "Checkbox",
        key = "preserveRelativeTime",
        label = "Preserve Time?",
        value = true
    })

    if RangeActivated("Switch", "SVs") then
        local svsToReverse = getSVsInRange(offsets.startOffset, offsets.endOffset)

        local newSVs = reverseSVs(svsToReverse, offsets.startOffset, offsets.endOffset, settings.preserveRelativeTime)

        actions.PerformBatch({
            utils.CreateEditorAction(action_type.AddScrollVelocityBatch, newSVs),
            utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, svsToReverse)
        })
    end
end

function reverseSVs(svs, startTime, endTime, preserveTime)
    if preserveTime then
        local newTbl = {}
        for _, item in ipairs(svs) do
            local timeDist = item.StartTime - startTime

            table.insert(newTbl, sv(endTime - timeDist, item.Multiplier))
        end

        return newTbl
    else
        local newTbl = {}

        for idx, item in ipairs(svs) do
            table.insert(newTbl, sv(svs[#svs - idx + 1].StartTime, item.Multiplier))
        end

        return newTbl
    end
end
