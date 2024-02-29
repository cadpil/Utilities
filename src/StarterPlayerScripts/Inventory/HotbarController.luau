local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local WordNumbers = require(ReplicatedStorage.Source.Utils.WordToNumber)

local Player = Knit.Player

local InventoryController = nil
local ItemService = nil
local HotbarController = Knit.CreateController {
    Name = "HotbarController",
    LoadedAnimations = {}
}

local function loadAnimation(id : string)
    local anim = Instance.new("Animation")
    anim.AnimationId = id
    local track = Player.Character.Humanoid.Animator:LoadAnimation(anim)
    HotbarController.LoadedAnimations[id] = track
end

local function EquipItem(item)
    HotbarController.equipped = item
    item.Reference:TweenSize(UDim2.new(0.1, 0, 0.865, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.1, true, nil)

    ItemService:GetSubClass(item.SubClass):andThen(function(info)
        HotbarController.equipped.Animations = info.Animations
        if not HotbarController.LoadedAnimations[HotbarController.equipped.Animations.Use] then
            loadAnimation(HotbarController.equipped.Animations.Use)
        end
    end)
end

local function UnequipItem()
    if not HotbarController.equipped then return end
    HotbarController.equipped.Reference:TweenSize(UDim2.new(0.1, 0, 0.8, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.1, true, nil)
    HotbarController.equipped = nil
end

local function UseItem()
    local equipped = HotbarController.equipped
    if not equipped then return end

    HotbarController.LoadedAnimations[equipped.Animations.Use]:Play()
end

local function KeyPressed(input, processed)
    if processed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 and HotbarController.equipped then
        InventoryController:UseItem():andThen(function(result)
            if not result then return end
            UseItem()
            return
        end)
    end

    if not (input.KeyCode.Value >= Enum.KeyCode.One.Value and input.KeyCode.Value <= Enum.KeyCode.Nine.Value) then return end

    local actualInput = WordNumbers[input.KeyCode.Name]
    InventoryController:KeybindPressed(actualInput):andThen(function(result)
        if result == true then
            UnequipItem()
            EquipItem(InventoryController.Inventory.Hotbar[actualInput])
        else
            UnequipItem()
        end
    end)
end

function HotbarController:KnitStart()
    InventoryController = Knit.GetController("InventoryController")
    ItemService = Knit.GetService("ItemService")

    UIS.InputBegan:Connect(KeyPressed)

    InventoryController.InventoryService.ItemUnequippedSignal:Connect(UnequipItem)
end

return HotbarController