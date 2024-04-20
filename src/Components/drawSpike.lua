---@diagnostic disable: undefined-field, need-check-nil
function drawSpike(xPos)
    local spikeSize = 25

    local color = rgbaToUint(255, 255, 255, 255)
    local o = imgui.GetOverlayDrawList()
    local sz = state.WindowSize

    o.AddTriangleFilled({ xPos, sz[2] }, { xPos + sz[1] / spikeSize, sz[2] },
        { xPos + sz[1] / (2 * spikeSize), sz[2] - sz[1] / spikeSize }, color)
end
