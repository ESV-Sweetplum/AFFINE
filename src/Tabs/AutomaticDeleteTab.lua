function AutomaticDeleteTab()
    local selectedID = state.GetValue("selectedID") or 1

    for id, tbl in pairs(globalData) do
        imgui.Selectable(
            "Type: " ..
            tbl.label ..
            " // Lower/Upper Offset: " ..
            tbl.lower .. ":" .. tbl.upper .. " // # Lines: " .. tbl.numLines .. " // # SVs: " .. tbl.numSVs,
            selectedID == id)
        if (imgui.IsItemClicked()) then
            selectedID = id
        end
    end

    if (#globalData == 0) then
        imgui.Text("Create an animation or fixed lines to display them here.")
    else
        if (imgui.Button("Delete selected item")) then
            tbl = globalData[selectedID]

            local linesToRemove = getLinesInRange(tbl.lower, tbl.upper)
            local svsToRemove = getSVsInRange(tbl.lower, tbl.upper)

            actions.PerformBatch({
                utils.CreateEditorAction(action_type.RemoveTimingPointBatch, linesToRemove),
                utils.CreateEditorAction(action_type.RemoveScrollVelocityBatch, svsToRemove),
                -- utils.CreateEditorAction(action_type.RemoveBookmarkBatch, bookmarksToRemove)
            })

            table.remove(globalData, selectedID)
            saveMapState(globalData)
        end

        if (imgui.Button("Delete faulty entry")) then
            table.remove(globalData, selectedID)
            saveMapState(globalData)
        end
    end

    state.SetValue("selectedID", selectedID)
end
