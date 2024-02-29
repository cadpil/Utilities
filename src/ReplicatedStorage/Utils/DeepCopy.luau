local deepCopy = {}

function deepCopy.DeepCopy(t, seen)
    if not t then return nil end
    local result = {}
    seen = seen or {}
    seen[t] = result
    for key, value in pairs(t) do
        if type(value) == "table" then
            result[key] = seen[value] or deepCopy.DeepCopy(value, seen)
        else
            result[key] = value
        end
    end
    return result
end

return deepCopy