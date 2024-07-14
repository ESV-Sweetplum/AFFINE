function RemoveOverlappingSVsMenu() 
    local btn = imgui.Button("Fix")

    if (btn) then
        local svs = map.ScrollVelocities ---@type SliderVelocityInfo[]

        local svTimes = {}
        local svsToRemove = {}

        for _, sv in ipairs(svs) do
            if (table.contains(svTimes, sv.StartTime)) then
                table.insert(svsToRemove, sv)
            end
            table.insert(svTimes, sv.StartTime)
        end

        actions.PerformBatch({
            utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, svsToRemove)
        })
    end
end