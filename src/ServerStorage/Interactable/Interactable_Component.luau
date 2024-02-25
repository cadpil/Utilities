local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)

local Interactable = Component.new({Tag="Interactable"})


local function CreateProximityPrompt(part : BasePart) : ProximityPrompt
    local prompt = Instance.new("ProximityPrompt")
    prompt.Parent = part
    return prompt
end

function Interactable:Construct()
    self._trove = Trove.new()
    self.prompt = CreateProximityPrompt(self.Instance)
end

function Interactable:Start()
    
end

function Interactable:Destroy()
    self._trove:Destroy()
end

return Interactable