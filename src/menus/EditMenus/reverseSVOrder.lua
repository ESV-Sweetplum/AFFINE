function ReverseSVOrderMenu()
    local settings = parameterWorkflow("edit_reverseSV", "delay",
        customParameter("Int", "Large Value Filter", "llv", 69420),
        customParameter("Checkbox", "Preserve Time?", "preserveRelativeTime", true))

    if RangeActivated("Switch", "SVs") then
        local svsInRange = getSVsInRange(offsets.startOffset + settings.delay, offsets.endOffset - settings.delay)

        if (#svsInRange == 0) then return end

        local svsToReverse = {}

        for _, v in pairs(svsInRange) do
            if (math.abs(v.Multiplier) < settings.llv) then table.insert(svsToReverse, v) end
        end

        local newSVs = reverseSVs(svsToReverse, offsets.startOffset + settings.delay, offsets.endOffset - settings.delay,
            settings.preserveRelativeTime)

        if (#svsToReverse == 0) then
            print("fuck you")
            return
        end

        actions.PerformBatch({
            utils.CreateEditorAction(action_type.AddScrollVelocityBatch, newSVs),
            utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, svsToReverse)
        })
    end
end

---Reverses the svs, either in place, or with respect to time.
---@param svs SliderVelocityInfo[]
---@param startTime number
---@param endTime number
---@param preserveTime boolean
---@return SliderVelocityInfo[]
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
