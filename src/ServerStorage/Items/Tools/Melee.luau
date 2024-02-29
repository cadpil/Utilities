local melee = {}
melee.__index = melee

function melee.new(player : Player, instance : Instance, data : table)
    local self = setmetatable(data, melee)

    self.Player = player
    self.Instance = instance

    return self
end

function melee:Use()
    print("Using")

    return true
end

function melee:destroy()
    self.Instance:Destroy()
    self = nil
end

return melee