function StandardAtNotesMenu(preservationType)
    local times = getSelectedOffsets()

    if NoteActivated() then
        local lines = {}

        if (type(times) == "integer") then return end

        if (preservationType == 1) then -- PRESERVE SNAP
            for _, time in pairs(times) do
                lines = combineTables(lines, keepColorLine(time))
            end
            lines = cleanLines(lines, times[1], times[#times] + 10)
        else -- PRESERVE LOCATION
            for _, time in pairs(times) do
                table.insert(lines, line(time))
            end
        end

        actions.PlaceTimingPointBatch(lines)
    end
end
