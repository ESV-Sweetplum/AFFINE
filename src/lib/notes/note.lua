---@diagnostic disable: return-type-mismatch
--- Creates a HitObject. To place it, you must use an `action`.
---@param startTime integer # The start time of the note.
---@param lane integer # The lane the note is located in. For 4K, must be in [1,4], and for 7K, must be in [1,7].
---@param endTime? integer # The end time of the note. Optional parameter only defined for long notes.
---@param hitsound? any # Not supported, only done for the wrapper.
---@param editorLayer? integer # Not supported, only done for the wrapper.
---@return HitObjectInfo
function note(startTime, lane, endTime, hitsound, editorLayer)
    return utils.CreateHitObject(startTime, lane, endTime or 0, hitsound or 0, editorLayer or 0)
end
