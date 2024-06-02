---Debug table constructor for placing AFFINE frames.
---@param lines TimingPointInfo[] # The lines placed a batch.
---@param svs SliderVelocityInfo[] # The svs placed a batch.
---@param stats? TableStats # Statistics about the AFFINE frame.
---@return table
function constructDebugTable(lines, svs, stats)
    local tbl = {
        L = #lines,
        S = #svs
    }

    if (stats) then
        tbl.mspfMean = string.format("%.2f", stats.mean)
        tbl.mspfStdDev = string.format("%.2f", stats.stdDev)
    end

    return tbl
end
