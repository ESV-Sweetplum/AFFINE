function StandardAtNotesMenu()
    local settings = {
        debug = ''
    }

    retrieveStateVariables("atNotes", settings)

    local offsets = getSelectedOffsets()

    if noteActivated(offsets) then
        local lines = {}

        if (type(offsets) == "integer") then return end

        for _, offset in pairs(offsets) do
            table.insert(lines, line(offset))
        end

        settings.debug = #offsets

        actions.PlaceTimingPointBatch(lines)
    end

    imgui.Text(settings.debug)

    saveStateVariables('atNotes', settings)
end
