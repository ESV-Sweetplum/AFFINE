---Takes a table of coefficients, and returns a number corresponding to a y-value of a polynomial.
---@param coefficients number[] # A table of coefficients of a degree `n` polynomial. For a table `{a,b,c,d}`, represents the polynomial ax^3+bx^2+cx+d.
---@param xVal number # The `x` value to evaluate this polynomial at.
---@return number
function evaluateCoefficients(coefficients, xVal)
    local sum = 0
    local degree = #coefficients - 1

    for idx, coefficient in pairs(coefficients) do
        sum = sum + (xVal) ^ (degree - idx + 1) * coefficient
    end

    return sum
end
