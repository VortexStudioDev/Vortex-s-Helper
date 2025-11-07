-- Basit ve Temiz Kurd Hub UI
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- UI Oluşturma
local screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
screenGui.Name = "SimpleKurdHub"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 200, 0, 180)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.Text = "Kurd Hub Mini"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

local titleCorner = Instance.new("UICorner", title)
titleCorner.CornerRadius = UDim.new(0, 8)

-- Butonlar
local buttons = {}

local function createButton(index, text, yPosition)
    local button = Instance.new("TextButton", mainFrame)
    button.Size = UDim2.new(0.9, 0, 0, 30)
    button.Position = UDim2.new(0.05, 0, 0, 35 + (index * 35))
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.BorderSizePixel = 0
    
    local buttonCorner = Instance.new("UICorner", button)
    buttonCorner.CornerRadius = UDim.new(0, 6)
    
    buttons[index] = button
    return button
end

-- Özellik butonları
createButton(1, "🚀 120 FPS No Lag", 0)
createButton(2, "🦘 Infinite Jump", 1)
createButton(3, "🎯 Auto Laser Steal", 2)
createButton(4, "🏠 Base ESP", 3)

-- ===========================
-- 120 FPS NO LAG ÖZELLİĞİ
-- ===========================
buttons[1].MouseButton1Click:Connect(function()
    -- FPS optimize
    settings().Rendering.QualityLevel = 1
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
    
    -- Grafik ayarları
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") then
            obj.Material = Enum.Material.Plastic
        elseif obj:IsA("Decal") then
            obj:Destroy()
        end
    end
    
    -- FPS arttırıcı
    local fpsBoost = Instance.new("BoolValue")
    fpsBoost.Name = "FPSBoost"
    fpsBoost.Value = true
    
    buttons[1].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
end)

-- ===========================
-- INFINITE JUMP ÖZELLİĞİ
-- ===========================
local infiniteJumpEnabled = false
local jumpConnection

local function setupInfiniteJump()
    if jumpConnection then
        jumpConnection:Disconnect()
    end
    
    jumpConnection = UserInputService.JumpRequest:Connect(function()
        if infiniteJumpEnabled and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart then
                rootPart.Velocity = Vector3.new(rootPart.Velocity.X, 50, rootPart.Velocity.Z)
            end
        end
    end)
end

buttons[2].MouseButton1Click:Connect(function()
    infiniteJumpEnabled = not infiniteJumpEnabled
    
    if infiniteJumpEnabled then
        buttons[2].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        setupInfiniteJump()
    else
        buttons[2].BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        if jumpConnection then
            jumpConnection:Disconnect()
        end
    end
end)

-- ===========================
-- AUTO LASER STEAL ÖZELLİĞİ
-- ===========================
local autoStealEnabled = false
local stealConnection

local function findNearestPlayer()
    local nearestPlayer = nil
    local shortestDistance = math.huge
    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not localRoot then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local distance = (localRoot.Position - targetRoot.Position).Magnitude
                if distance < shortestDistance and distance < 50 then
                    shortestDistance = distance
                    nearestPlayer = player
                end
            end
        end
    end
    
    return nearestPlayer
end

local function autoStealLoop()
    if stealConnection then
        stealConnection:Disconnect()
    end
    
    stealConnection = RunService.Heartbeat:Connect(function()
        if not autoStealEnabled then return end
        
        local nearestPlayer = findNearestPlayer()
        if nearestPlayer and nearestPlayer.Character then
            local targetPart = nearestPlayer.Character:FindFirstChild("UpperTorso") or 
                             nearestPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if targetPart then
                -- Laser cape kullanımı (oyuna özel implementasyon)
                pcall(function()
                    local laserRemote = ReplicatedStorage:FindFirstChild("UseLaser")
                    if laserRemote then
                        laserRemote:FireServer(targetPart)
                    end
                end)
            end
        end
    end)
end

buttons[3].MouseButton1Click:Connect(function()
    autoStealEnabled = not autoStealEnabled
    
    if autoStealEnabled then
        buttons[3].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        autoStealLoop()
    else
        buttons[3].BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        if stealConnection then
            stealConnection:Disconnect()
        end
    end
end)

-- ===========================
-- BASE ESP ÖZELLİĞİ
-- ===========================
local baseESPEnabled = false
local espFolder = Instance.new("Folder")
espFolder.Name = "BaseESP"
espFolder.Parent = game.CoreGui

local function createBaseESP()
    for _, plot in pairs(Workspace:GetChildren()) do
        if plot.Name:find("Plot") or plot:FindFirstChild("Purchases") then
            local mainPart = plot:FindFirstChild("Main") or plot:FindFirstChild("Base")
            
            if mainPart then
                local highlight = Instance.new("Highlight")
                highlight.Name = plot.Name .. "_ESP"
                highlight.Adornee = mainPart
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.7
                highlight.Parent = espFolder
                
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "BaseLabel"
                billboard.Adornee = mainPart
                billboard.Size = UDim2.new(0, 200, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = mainPart
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = "BASE - " .. plot.Name
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.TextStrokeTransparency = 0
                label.Font = Enum.Font.GothamBold
                label.TextSize = 14
                label.Parent = billboard
            end
        end
    end
end

local function removeBaseESP()
    for _, child in pairs(espFolder:GetChildren()) do
        child:Destroy()
    end
end

buttons[4].MouseButton1Click:Connect(function()
    baseESPEnabled = not baseESPEnabled
    
    if baseESPEnabled then
        buttons[4].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        createBaseESP()
    else
        buttons[4].BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        removeBaseESP()
    end
end)

-- Karakter değişikliklerini dinle
LocalPlayer.CharacterAdded:Connect(function(character)
    if infiniteJumpEnabled then
        setupInfiniteJump()
    end
end)

-- Başlangıçta infinite jump'ı aktif et
task.spawn(function()
    wait(2)
    infiniteJumpEnabled = true
    buttons[2].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    setupInfiniteJump()
end)

warn("Simple Kurd Hub Loaded!")
