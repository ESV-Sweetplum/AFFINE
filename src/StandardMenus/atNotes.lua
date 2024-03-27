function StandardAtNotesMenu()
    local offsets = getOffsets()

    if noteActivated(offsets) then
        local lines = {}

        if (type(offsets) == "integer") then return end

        for _, offset in pairs(offsets) do
            table.insert(lines, utils.CreateTimingPoint(offset, map.GetCommonBpm()))
        end
        actions.PlaceTimingPointBatch(lines)
    end
end
