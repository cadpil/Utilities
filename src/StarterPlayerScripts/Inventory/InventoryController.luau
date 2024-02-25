local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InventoryAssets = ReplicatedStorage.Assets.GUI.Inventory

local Knit = require(ReplicatedStorage.Packages.Knit)
local Player = Knit.Player
local InventoryUi = Player.PlayerGui:WaitForChild("Inventory")

local InventoryService = nil
local InventoryController = Knit.CreateController {
    Name = "InventoryController",
    Inventory = {
        Hotbar = {},
        Backpack = {}
    }
}

function InventoryController:CreateInventoryUi(location : string)
    InventoryService:GetMaximumItems(location):andThen(function(maximum)
        local template = InventoryAssets:FindFirstChild(location.."Template")
        for i = 1, maximum do
            local newSlot = template:Clone()
            newSlot.Name = i

            if newSlot:FindFirstChild("KeybindText") then 
                newSlot.KeybindText.Text = i
            end

            newSlot.Parent = InventoryUi:FindFirstChild(location):FindFirstChild("MainFrame").Value

            self.Inventory[location][i] = {Reference = newSlot}
        end
    end)
end

local function updateItem(ReferenceFrame, info)
    ReferenceFrame.Icon.Image = info.Quantity > 0 and info.Icon or ""
    ReferenceFrame.QuantityText.Text = "x"..info.Quantity
    ReferenceFrame.QuantityText.Visible = info.Quantity > 1 and true or false
end

local function AddItem(info)
    local slot = InventoryController.Inventory[info.Location][info.Keybind]
    info.FrameReference = slot.Reference

    updateItem(slot.Reference, info)

    slot = info
end

local function RemoveItem(info)
    local slot = InventoryController.Inventory[info.Location][info.Keybind]
    local newData = info

    updateItem(slot.Reference, info)

    if info.Quantity <= 0 then
        newData = {slot.Reference}
    end

    slot = newData
end

function InventoryController.KnitInit()
    InventoryService = Knit.GetService("InventoryService")

    InventoryController:CreateInventoryUi("Hotbar")
    InventoryController:CreateInventoryUi("Backpack")
end

function InventoryController.KnitStart()
    InventoryService.ItemAddedSignal:Connect(AddItem)
    InventoryService.ItemRemovedSignal:Connect(RemoveItem)
end

return InventoryController