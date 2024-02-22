local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

for _, service in pairs(ServerStorage:GetDescendants()) do
    if service:IsA("ModuleScript") and service.Name:match("Service$") then
        require(service)
    end
end

Knit.Start():catch(warn)