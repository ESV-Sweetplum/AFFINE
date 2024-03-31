function line(time, bpm, hidden)
    if (hidden == nil) then hidden = false end
    local data = map.GetTimingPointAt(time)

    if (not data) then
        data = {
            Bpm = map.GetCommonBpm(),
            Signature = time_signature.Quadruple,
            Hidden = false
        }
    end

    return utils.CreateTimingPoint(time, bpm or data.Bpm, data.Signature, hidden)
end
