---Takes a table of strings, and returns an AFFINE frame.
---@param svTable string[]
---@param time number
---@param msxOffset number
---@param spacing number
---@return AffineFrame
function tableToAffineFrame(svTable, time, msxOffset, spacing)
    local lines = {}
    local svs = {}

    for _, msx in pairs(svTable) do
        local speed = INCREMENT * (msx + msxOffset)

        table.insert(lines, line(time))
        table.insert(svs, sv(time, speed * -1))
        table.insert(svs, sv(time - (1 / INCREMENT), speed))
        table.insert(svs, sv(time + (1 / INCREMENT), 0))

        time = time + spacing
    end

    local tbl = {
        lines = lines,
        svs = svs,
        time = time
    }
    return tbl
end
