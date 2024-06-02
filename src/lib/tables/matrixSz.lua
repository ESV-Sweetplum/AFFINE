---Returns two variables corresponding to row and column count of a matrix.
---@param mtrx any[][] # The matrix to measure.
---@return integer
---@return integer
function matrixSz(mtrx)
    local rows, columns = 0, #mtrx

    for _, tbl in pairs(mtrx) do
        rows = math.max(rows, #tbl)
    end

    return rows, columns
end
