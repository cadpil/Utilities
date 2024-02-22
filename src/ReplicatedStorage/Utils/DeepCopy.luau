local deepCopy = {}

function deepCopy.DeepCopy(t, seen)
    local result = {}
    seen = seen or {}
    seen[t] = result
    for key, value in pairs(t) do
        if type(value) == "table" then
            result[key] = seen[value] or deepCopy.deep_copy(value, seen)
        else
            result[key] = value
        end
    end
    return result
end

return deepCopy