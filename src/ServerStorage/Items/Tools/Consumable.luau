local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)
local Knit = require(ReplicatedStorage.Packages.Knit)

local consumable = {}
consumable.__index = consumable

function consumable.new(player : Player, instance : Instance, data : table)
    local self = setmetatable(data, consumable)

    self.Player = player
    self.Instance = instance
    self._trove = Trove.new()

    return self
end

function consumable:Use()
    local thread
    thread = task.spawn(function()
        task.wait(self.Stats.Time)
        if not self.Player.Character or self.Player.Character.Humanoid.Health <= 0 then 
            task.cancel(thread) 
            return false 
        end
        self.Player.Character.Humanoid.Health += self.Stats.Health or 0
        self:destroy()
        Knit.GetService("InventoryService").Client:EquipItem(self.Player, self.Keybind)
    end)
    self._trove:Add(thread)

    return true, 1
end

function consumable:destroy()
    self.Instance:Destroy()
    self._trove:Destroy()
    self = nil
end

return consumable