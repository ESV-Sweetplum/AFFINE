function StandardAtNotesMenu()
    local offsets = getOffsets()
  
    if noteSelected(offsets) then
      local activationButton = imgui.Button("Place the shit")
  
      if (activationButton) then

        local lines = {}

        if (type(offsets) == "integer") then return end

       for _, offset in pairs(offsets) do
        table.insert(lines, utils.CreateTimingPoint(offset, map.GetCommonBpm()))
       end

       actions.PlaceTimingPointBatch(lines)
      end
    else
      imgui.Text("select note to place sv :)")
    end
end