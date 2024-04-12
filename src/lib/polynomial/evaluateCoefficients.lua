---Takes a table of coefficients, and returns a number corresponding to a y-value of a polynomial.
---@param coefficients number[]
---@param xVal number
---@return number
function evaluateCoefficients(coefficients, xVal)
    local sum = 0
    local degree = #coefficients - 1

    for idx, coefficient in pairs(coefficients) do
        sum = sum + (xVal) ^ (degree - idx + 1) * coefficient
    end
    
    return sum
end
