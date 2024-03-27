function strToTable(str, predicate) 
    t = {}

    for i in string.gmatch(str, predicate) do
        t[#t + 1] = i
    end
    
    return t
end