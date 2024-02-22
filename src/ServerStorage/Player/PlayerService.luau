local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local PlayerData = require(script.Parent.PlayerData)

local PlayerService = Knit.CreateService {
    Name = "PlayerService",
    Client = {},
}

local function CreatePlayerData(player)
    if PlayerData.Data[player.UserId] then return end
    PlayerData.Data[player.UserId] = PlayerData.Default
end

function PlayerService:GetPlayerData(player : Player) : table
    return PlayerData.Data[player.UserId]
end

function PlayerService:KnitStart()
    task.wait(1)
    Knit.GetService("InventoryService"):Add(Players.IamACoolGuy_1230, 100_001, 1, nil)
end

function PlayerService:KnitInit()
    Players.PlayerAdded:Connect(CreatePlayerData)
end

return PlayerService