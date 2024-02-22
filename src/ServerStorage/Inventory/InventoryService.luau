local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local InventoryService = Knit.CreateService {
    Name = "InventoryService",
    Client = {}
}

local function createArray(size)
    local array = {}
    for i = 1, size do
        array[tostring(i)] = i
    end
    return array
end

local function loopAndRemove(items, array)
    for _, data in items do
        if array[tostring(data.Keybind)] then
            array[tostring(data.Keybind)] = nil
        end
    end
    
    return array
end

local function findFree(array) : number
    local smallest = 100
    for index, keybind in pairs(array) do
        if keybind < smallest then
            smallest = tonumber(index)
        end
    end
    return smallest
end

function InventoryService:FindItemInInventory(items : table, itemId : number)
    local ItemService = Knit.GetService("ItemService")

    for _, data in pairs(items) do
        if data.ItemId ~= itemId then continue end
        if data.Quantity >= ItemService:Get(itemId).MaxStack then continue end
        return data.Keybind
    end

    return -1
end

function InventoryService:CalculateOverflow(player, itemId, quantity, reference)
    local ItemService = Knit.GetService("ItemService")
    local maxStack = ItemService:Get(itemId).MaxStack

    if reference.Quantity + quantity > maxStack then
        local remainder = (reference.Quantity + quantity) - maxStack
        local toAdd = quantity - remainder
        reference.Quantity += toAdd
        self:Add(player, itemId, remainder)
    else
        reference.Quantity += quantity
    end
end

function InventoryService:Add(player : Player, itemId : number, quantity : number, location : string)
    --print("Quantity" .. tostring(quantity))
    local PlayerService = Knit.GetService("PlayerService")
    local PlayerData = PlayerService:GetPlayerData(player)
    
    local itemSlot = -1
    local itemLocation = nil

    for _location, items in pairs(PlayerData.Inventory) do
        itemSlot = self:FindItemInInventory(items, itemId)
        if itemSlot <= 0 then continue end
        --Check if the current loop of location is equal to the location we want to add an item to, if it is then stop because we dont want to add to other location
        if location == "Hotbar" then 
            itemSlot = -1 
            break 
        end

        itemLocation = _location
        break
    end

    --If a slot with the item already exists and it can be stacked then add the quantity
    if itemSlot > 0 then
        local reference = PlayerData.Inventory[itemLocation][itemSlot]
        self:CalculateOverflow(player, itemId, quantity, reference)
        return
    end

    --Create arrays containing all possible keybinds for hotbar and backpack
    local freeHotbar : table = createArray(PlayerData.HotbarMaximum)
    local freeBackpack : table = createArray(PlayerData.BackpackMaximum)
    
    --Remove the keybinds that are already taken so we can find the ones not in use
    freeHotbar = loopAndRemove(PlayerData.Inventory.Hotbar, freeHotbar)
    freeBackpack = loopAndRemove(PlayerData.Inventory.Backpack, freeBackpack)

    --Set slot equal to the first free slot in hotbar, if there isnt one then set to first free slot in backpack, otherwise nil
    freeHotbar = findFree(freeHotbar)
    freeBackpack = findFree(freeBackpack)
    local slot : number = (freeHotbar ~= 100 and (location == "Hotbar" or location == nil)) and freeHotbar or (freeBackpack ~= 100 and freeBackpack or nil)
    if not slot then
        return "full"
    end
    location = (freeHotbar ~= 100 and (location == "Hotbar" or location == nil)) and "Hotbar" or "Backpack"

    --Finally set PlayerData.Inventory[(if hotbar free then hotbar else backpack)][the free slot we just found] to item info
    PlayerData.Inventory[location][slot] = Knit.GetService("ItemService"):Get(itemId)

    local reference = PlayerData.Inventory[location][slot]
    reference.Keybind = slot

    self:CalculateOverflow(player, itemId, quantity, reference)
end

function InventoryService:KnitStart()

end


function InventoryService:KnitInit()
    
end

return InventoryService