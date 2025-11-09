 local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local function removeForceField(player)
    if player.Character then
        local forceField = player.Character:FindFirstChildOfClass("ForceField")
        if forceField then
            forceField:Destroy()
        end
    end
end

local function monitorPlayer(player)
    removeForceField(player)
    
    player.CharacterAdded:Connect(function(character)
        wait(1)
        removeForceField(player)
        
        local forceFieldConnection
        forceFieldConnection = character.ChildAdded:Connect(function(child)
            if child:IsA("ForceField") then
                task.wait(0.1)
                child:Destroy()
            end
        end)
        
        character.AncestryChanged:Connect(function()
            forceFieldConnection:Disconnect()
        end)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    monitorPlayer(player)
end

Players.PlayerAdded:Connect(monitorPlayer)

RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local forceField = player.Character:FindFirstChildOfClass("ForceField")
            if forceField then
                forceField:Destroy()
            end
        end
    end
end)
