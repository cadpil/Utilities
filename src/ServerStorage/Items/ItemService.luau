local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local DeepCopy = require(ReplicatedStorage.Source.Utils.DeepCopy)
local ItemsData = require(script.Parent.ItemsData)

local ItemService = Knit.CreateService {
    Name = "ItemService",
    Client = {}
}

function ItemService.Client:Get(player : Player, itemId : number)
    return self:Get(itemId)
end

function ItemService:Get(itemId : number)
    assert(type(itemId) == "number", "Must be an item id (number)")
    return DeepCopy.DeepCopy(ItemsData[itemId])
end

return ItemService