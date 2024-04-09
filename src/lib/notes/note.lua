---@diagnostic disable: return-type-mismatch
--- Creates a HitObject. To place it, you must use an `action`.
---@param startTime integer
---@param lane integer
---@param endTime? integer
---@param hitsound? any
---@param editorLayer? integer
---@return HitObjectInfo
function note(startTime, lane, endTime, hitsound, editorLayer)
    return utils.CreateHitObject(startTime, lane, endTime or 0, hitsound or 0, editorLayer or 0)
end
