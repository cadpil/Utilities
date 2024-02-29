local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local function loadType(parent, nameMatch)
    for _, module in pairs(parent:GetDescendants()) do
        if module:IsA("ModuleScript") and module.Name:match(nameMatch.."$") then
            require(module)
        end
    end
end
loadType(script.Parent, "Controller")

Knit.Start():catch(warn)