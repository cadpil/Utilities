local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ItemService = nil
local PlayerService = nil
local InventoryService = Knit.CreateService {
    Name = "InventoryService",
    Client = {
        ItemAddedSignal = Knit.CreateSignal(),
        ItemRemovedSignal = Knit.CreateSignal()
    }
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


function InventoryService.Client:GetMaximumItems(player : Player, location : string)
    local playerData = PlayerService:GetPlayerData(player)
    return if location == "Hotbar" then playerData.HotbarMaximum else (if location == "Backpack" then playerData.BackpackMaximum else table.pack(playerData.HotbarMaximum, playerData.BackpackMaximum))
end

function InventoryService:FindItemInInventory(items : table, itemId : number, ignoreMax : boolean)
    for _, data in pairs(items) do
        if data.ItemId ~= itemId then continue end
        if data.Quantity >= ItemService:Get(itemId).MaxStack and ignoreMax then continue end
        return data.Keybind, data.Location
    end

    return -1, nil
end

function InventoryService:CalculateOverflow(player, itemId, quantity, reference)
    local maxStack = ItemService:Get(itemId).MaxStack

    if reference.Quantity + quantity > maxStack then
        local remainder = (reference.Quantity + quantity) - maxStack
        local toAdd = quantity - remainder
        reference.Quantity += toAdd

        InventoryService.Client.ItemAddedSignal:Fire(player, reference)
        return self:Add(player, itemId, remainder)
    else
        reference.Quantity += quantity
        InventoryService.Client.ItemAddedSignal:Fire(player, reference)
        return true
    end
end

function InventoryService:Remove(player : Player, itemId : number, quantity : number, location : string, keybind : number)
    local InventoryData = PlayerService:GetPlayerData(player).Inventory

    --First checks if item exists at said location and keybind, if not then check the entire inventory, if still no item then return
    if not InventoryData[location][keybind] then
        -- for _, items in pairs(InventoryData) do
        --     keybind, location = self:FindItemInInventory(items, itemId, false)
        --     if location then break end
        -- end
        -- if not location then return end
        return
    end

    local itemReference = InventoryData[location][keybind]
    itemReference.Quantity -= quantity
    self.Client.ItemRemovedSignal:Fire(player, itemReference)

    if itemReference.Quantity <= 0 then
        InventoryData[location][keybind] = nil
    end
end

function InventoryService:Add(player : Player, itemId : number, quantity : number, location : string)
    local PlayerData = PlayerService:GetPlayerData(player)
    
    local itemSlot = -1
    local itemLocation = nil

    for _location, items in pairs(PlayerData.Inventory) do
        itemSlot = self:FindItemInInventory(items, itemId, true)
        if itemSlot <= 0 then continue end
        --Check if the current loop of location is equal to the location we want to add an item to, if it is then stop because we dont want to add to other location
        if location == "Hotbar" then 
            itemSlot = -1 
            break 
        end

        itemLocation = _location
        break
    end

    print(itemSlot)
    print(location)

    --If a slot with the item already exists and it can be stacked then add the quantity
    if itemSlot > 0 then
        local reference = PlayerData.Inventory[itemLocation][itemSlot]
        return self:CalculateOverflow(player, itemId, quantity, reference)
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
    reference.Location = location

    return self:CalculateOverflow(player, itemId, quantity, reference)
end

function InventoryService:KnitStart()
    ItemService = Knit.GetService("ItemService")
    PlayerService = Knit.GetService("PlayerService")
end


function InventoryService:KnitInit()
    
end

return InventoryService