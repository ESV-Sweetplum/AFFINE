function placeFixedLines(svTable, time, msxOffset, spacing)
    local lines = {}
    local svs = {}
  
    for _, msx in pairs(svTable) do
  
      local INCREMENT = 64
  
      local speed = INCREMENT * (msx + msxOffset)

      table.insert(lines, utils.CreateTimingPoint(time, map.GetCommonBpm()))
      table.insert(svs, utils.CreateScrollVelocity(time, speed * -1))
      table.insert(svs, utils.CreateScrollVelocity(time - (1 / INCREMENT), speed))
      table.insert(svs, utils.CreateScrollVelocity(time + (1 / INCREMENT), 0))
  
      time = time + spacing
    end
  
  
    actions.PerformBatch({
      utils.CreateEditorAction(action_type.AddTimingPointBatch, lines),
      utils.CreateEditorAction(action_type.AddScrollVelocityBatch, svs)
  })
end

function returnFixedLines(svTable, time, msxOffset, spacing)
    local lines = {}
    local svs = {}
  
    for _, msx in pairs(svTable) do
  
      local INCREMENT = 64
  
      local speed = INCREMENT * (msx + msxOffset)

      table.insert(lines, utils.CreateTimingPoint(time, map.GetCommonBpm()))
      table.insert(svs, utils.CreateScrollVelocity(time, speed * -1))
      table.insert(svs, utils.CreateScrollVelocity(time - (1 / INCREMENT), speed))
      table.insert(svs, utils.CreateScrollVelocity(time + (1 / INCREMENT), 0))
  
      time = time + spacing
    end

    local tbl = {
      lines = lines,
      svs = svs,
      time = time
    }
  return tbl
end