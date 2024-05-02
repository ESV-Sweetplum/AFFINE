---Takes a table of coefficients, and returns a string representing the equation.
---@param coefficients number[]
---@param power number
---@return string
function polynomialString(coefficients, power)
    local explanatoryVariable = "t"

    local str = 'Equation: y = '
    local degree = #coefficients - 1
    for idx, coefficient in pairs(coefficients) do
        if (coefficient == 0) then goto continue end
        effectiveDegree = (degree - idx + 1) * power
        sign = "+"
        if (coefficient < 0) then sign = "-" end
        if (idx == 1) then
            if (coefficient < 0) then signText = "-" else signText = "" end
        else
            signText = " " .. sign .. " "
        end
        coefficientText = math.abs(coefficient)
        if (coefficientText == 1 and effectiveDegree ~= 0) then coefficientText = "" end
        if (effectiveDegree == 0) then
            str = str .. signText .. coefficientText
        elseif (effectiveDegree == 1) then
            str = str .. signText .. coefficientText .. explanatoryVariable
        else
            str = str .. signText .. coefficientText .. explanatoryVariable .. "^" .. effectiveDegree
        end
        ::continue::
    end

    return str
end