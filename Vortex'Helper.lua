local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- Desync Sistemi
local antiHitActive = false
local cloneListenerConn = nil

local function makeInvulnerable(model)
    if not model then return end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum.MaxHealth = 1e9
            hum.Health = 1e9
            if not model:FindFirstChildOfClass("ForceField") then
                Instance.new("ForceField", model).Visible = false
            end
        end)
    end
end

local function activateDesync()
    pcall(function() if setfflag then setfflag("WorldStepMax", "-99999999999999") end end)
    
    local Backpack = player:FindFirstChildOfClass("Backpack")
    if Backpack and Backpack:FindFirstChild("Quantum Cloner") then
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:EquipTool(Backpack["Quantum Cloner"]) end
    end

    local REUseItem = ReplicatedStorage.Packages.Net:FindFirstChild("RE/UseItem")
    local REQuantumCloner = ReplicatedStorage.Packages.Net:FindFirstChild("RE/QuantumCloner/OnTeleport")
    if REUseItem then REUseItem:FireServer() end
    if REQuantumCloner then REQuantumCloner:FireServer() end

    local cloneName = tostring(player.UserId) .. "_Clone"
    cloneListenerConn = Workspace.ChildAdded:Connect(function(obj)
        if obj.Name == cloneName and obj:IsA("Model") then
            makeInvulnerable(obj)
            makeInvulnerable(player.Character)
            if cloneListenerConn then cloneListenerConn:Disconnect() end
        end
    end)
end

local function deactivateDesync()
    pcall(function() if setfflag then setfflag("WorldStepMax", "1") end end)
    if cloneListenerConn then cloneListenerConn:Disconnect() end
    
    local clone = Workspace:FindFirstChild(tostring(player.UserId) .. "_Clone")
    if clone then pcall(function() clone:Destroy() end) end
end

-- Buton Oluşturma
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DesyncBtn"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local desyncButton = Instance.new("TextButton")
desyncButton.Name = "Deysnc"
desyncButton.Size = UDim2.new(0, 100, 0, 40)  -- %20 küçültülmüş
desyncButton.Position = UDim2.new(0, 10, 0.5, -20)
desyncButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
desyncButton.BackgroundTransparency = 0.4
desyncButton.Text = "Deysnc"
desyncButton.TextColor3 = Color3.fromRGB(0, 0, 0)
desyncButton.TextSize = 12
desyncButton.Font = Enum.Font.GothamBold
desyncButton.Draggable = true
desyncButton.Parent = screenGui

-- Geliştirilmiş Tasarım
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = desyncButton

local buttonStroke = Instance.new("UIStroke")
buttonStroke.Color = Color3.fromRGB(255, 255, 255)
buttonStroke.Thickness = 1.5
buttonStroke.Transparency = 0.7
buttonStroke.Parent = desyncButton

-- Gradient efekti
local buttonGradient = Instance.new("UIGradient")
buttonGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 80, 200))
})
buttonGradient.Rotation = 90
buttonGradient.Parent = desyncButton

-- Buton İşlevleri
desyncButton.MouseEnter:Connect(function()
    desyncButton.BackgroundTransparency = 0.2
end)

desyncButton.MouseLeave:Connect(function()
    desyncButton.BackgroundTransparency = 0.4
end)

desyncButton.MouseButton1Click:Connect(function()
    if antiHitActive then
        deactivateDesync()
        antiHitActive = false
        desyncButton.Text = "Deysnc"
        buttonGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 80, 200))
        })
    else
        activateDesync()
        antiHitActive = true
        desyncButton.Text = "AKTİF"
        buttonGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 100)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 50))
        })
    end
end)

-- Character reset
player.CharacterAdded:Connect(function()
    antiHitActive = false
    desyncButton.Text = "Deysnc"
    buttonGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 80, 200))
    })
end)

print("🚀 Desync Butonu Hazır!")
