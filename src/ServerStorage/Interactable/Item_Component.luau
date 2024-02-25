local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)

local InventoryService = Knit.GetService("InventoryService")

local Item = Component.new({Tag="Item"})

function Item:Construct()
    self._trove = Trove.new()

    self.ItemId = self.Instance:GetAttribute("ItemId")
    self.Quantity = self.Instance:GetAttribute("Quantity")
end

function Item:Trigger(player : Player)
    local result = InventoryService:Add(player, self.ItemId, self.Quantity, nil)
    if result ~= true then return end

    self.Instance:Destroy()
end

function Item:Start()
    self.prompt = self.Instance:FindFirstChildWhichIsA("ProximityPrompt")
    self._trove:Add(self.prompt.Triggered:Connect(function(player)
        self:Trigger(player)
    end))
end

function Item:Stop()
    self._trove:Destroy()
end

return Item