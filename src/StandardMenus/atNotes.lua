function StandardAtNotesMenu()
    local offsets = getOffsets()

    if noteSelected(offsets) then
        local activationButton = imgui.Button("Place Lines")

        if (activationButton) then
            local lines = {}

            if (type(offsets) == "integer") then return end

            for _, offset in pairs(offsets) do
                table.insert(lines, utils.CreateTimingPoint(offset, map.GetCommonBpm()))
            end

            actions.PlaceTimingPointBatch(lines)
        end
    else
        imgui.Text("Select a Note to Place Lines.")
    end
end
