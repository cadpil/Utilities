local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local InventoryService = Knit.CreateService {
    Name = "InventoryService",
    Client = {}
}

function InventoryService:FindItemInInventory(items : table, itemId : number)
    local ItemService = Knit.GetService("ItemService")

    for _, data in pairs(items) do
        if data.ItemId ~= itemId then continue end
        if data.Quantity >= ItemService:Get(itemId).MaxStack then continue end
        return data.Keybind
    end

    return -1
end

local function createArray(size)
    local array = {}
    for i = 1, size do
        table.insert(array, i)
    end
    return array
end

local function loopAndRemove(items, array)
    for _, data in items do
        if array[data.Keybind] then
            table.remove(array, data.Keybind)
        end
    end
    return array
end

function InventoryService:Add(player : Player, itemId : number, quantity : number, location : string)
    local PlayerService = Knit.GetService("PlayerService")
    local PlayerData = PlayerService:GetPlayerData(player)
    
    local itemSlot = -1
    local itemLocation = nil

    for _location, items in pairs(PlayerData.Inventory) do
        itemSlot = self:FindItemInInventory(items, itemId)
        if itemSlot <= 0 then continue end
        --Check if the current loop of location is equal to the location we want to add an item to, if it is then stop because we dont want to add to other location
        if _location == location then break end

        itemLocation = _location
        break
    end

    --If a slot with the item already exists and it can be stacked then add the quantity
    if itemSlot > 0 then
        PlayerData.Inventory[itemLocation][itemSlot].Quantity += quantity
        return
    end

    --Create arrays containing all possible keybinds for hotbar and backpack
    local freeHotbar : table = createArray(PlayerData.HotbarMaximum)
    local freeBackpack : table = createArray(PlayerData.BackpackMaximum)
    
    --Remove the keybinds that are already taken so we can find the ones not in use
    freeHotbar = loopAndRemove(PlayerData.Inventory.Hotbar, freeHotbar)
    freeBackpack = loopAndRemove(PlayerData.Inventory.Backpack, freeBackpack)

    --Set slot equal to the first free slot in hotbar, if there isnt one then set to first free slot in backpack, otherwise nil
    local slot : number = freeHotbar[1] or freeBackpack[1]
    if not slot then
        return "full"
    end

    --Finally set PlayerData.Inventory[(if hotbar free then hotbar else backpack)][the free slot we just found] to item info
    PlayerData.Inventory[freeHotbar[1] and "Hotbar" or "Backpack"][slot] = Knit.GetService("ItemService"):Get(itemId)
    PlayerData.Inventory[freeHotbar[1] and "Hotbar" or "Backpack"][slot].Keybind = slot
end

function InventoryService:KnitStart()

end


function InventoryService:KnitInit()
    
end

return InventoryService