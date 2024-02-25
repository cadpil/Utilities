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
    for _, player in pairs(Players:GetPlayers()) do
        CreatePlayerData(player)
    end
    Players.PlayerAdded:Connect(CreatePlayerData)
end

function PlayerService:KnitInit()
    
end

return PlayerService