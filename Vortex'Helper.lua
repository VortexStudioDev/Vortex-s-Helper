-- Kurd Hub Mini - Tüm Özellikler Çalışır Halde
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- UI Oluşturma
local screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
screenGui.Name = "KurdHubMini"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 220, 0, 250)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.Text = "🏴 Kurd Hub Mini"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local titleCorner = Instance.new("UICorner", title)
titleCorner.CornerRadius = UDim.new(0, 10)

-- Butonlar
local buttons = {}

local function createButton(index, text, yPosition)
    local button = Instance.new("TextButton", mainFrame)
    button.Size = UDim2.new(0.9, 0, 0, 35)
    button.Position = UDim2.new(0.05, 0, 0, 40 + (index * 40))
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
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
createButton(3, "🎯 Auto Laser Best Steal", 2)
createButton(4, "🏠 Base ESP", 3)
createButton(5, "👀 Player ESP", 4)

-- ===========================
-- 1. 120 FPS NO LAG ÖZELLİĞİ
-- ===========================
local fpsEnabled = false

buttons[1].MouseButton1Click:Connect(function()
    fpsEnabled = not fpsEnabled
    
    if fpsEnabled then
        -- FPS optimize edici ayarlar
        settings().Rendering.QualityLevel = 1
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
        
        -- Görsel efektleri kapat
        for _, effect in pairs(Workspace:GetDescendants()) do
            if effect:IsA("ParticleEmitter") or effect:IsA("Fire") or effect:IsA("Smoke") then
                effect.Enabled = false
            end
        end
        
        -- Grafikleri basitleştir
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("Part") then
                part.Material = Enum.Material.Plastic
                if part:FindFirstChildOfClass("Decal") then
                    part:FindFirstChildOfClass("Decal"):Destroy()
                end
            end
        end
        
        buttons[1].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        buttons[1].Text = "✅ 120 FPS Active"
    else
        buttons[1].BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        buttons[1].Text = "🚀 120 FPS No Lag"
    end
end)

-- ===========================
-- 2. INFINITE JUMP ÖZELLİĞİ
-- ===========================
local infiniteJumpEnabled = true
local jumpConnection

local function doInfiniteJump()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            rootPart.Velocity = Vector3.new(rootPart.Velocity.X, 50, rootPart.Velocity.Z)
        end
    end
end

local function setupInfiniteJump()
    if jumpConnection then
        jumpConnection:Disconnect()
    end
    
    jumpConnection = UserInputService.JumpRequest:Connect(function()
        if infiniteJumpEnabled then
            doInfiniteJump()
        end
    end)
end

buttons[2].MouseButton1Click:Connect(function()
    infiniteJumpEnabled = not infiniteJumpEnabled
    
    if infiniteJumpEnabled then
        buttons[2].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        buttons[2].Text = "✅ Infinite Jump"
        setupInfiniteJump()
    else
        buttons[2].BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        buttons[2].Text = "🦘 Infinite Jump"
    end
end)

-- Başlangıçta aktif
setupInfiniteJump()
buttons[2].BackgroundColor3 = Color3.fromRGB(0, 255, 0)

-- ===========================
-- 3. AUTO LASER BEST STEAL
-- ===========================
local autoStealEnabled = false
local stealConnection
local promptConnections = {}

local function disconnectAllPrompts()
    for _, connection in ipairs(promptConnections) do
        connection:Disconnect()
    end
    promptConnections = {}
end

local function onPromptShown(prompt)
    if autoStealEnabled and prompt and string.find(prompt.ActionText:lower(), "steal") then
        fireproximityprompt(prompt)
    end
end

local function enableAutoSteal()
    disconnectAllPrompts()
    
    -- Mevcut promptları kontrol et
    for _, prompt in pairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and string.find(prompt.ActionText:lower(), "steal") then
            fireproximityprompt(prompt)
        end
    end
    
    -- Yeni promptları dinle
    table.insert(promptConnections, ProximityPromptService.PromptShown:Connect(onPromptShown))
end

local function disableAutoSteal()
    disconnectAllPrompts()
end

buttons[3].MouseButton1Click:Connect(function()
    autoStealEnabled = not autoStealEnabled
    
    if autoStealEnabled then
        buttons[3].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        buttons[3].Text = "✅ Auto Steal Active"
        enableAutoSteal()
    else
        buttons[3].BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        buttons[3].Text = "🎯 Auto Laser Best Steal"
        disableAutoSteal()
    end
end)

-- ===========================
-- 4. BASE ESP ÖZELLİĞİ
-- ===========================
local baseESPEnabled = false
local baseESPFolder = Instance.new("Folder")
baseESPFolder.Name = "BaseESP"
baseESPFolder.Parent = game.CoreGui

local function createBaseESP()
    -- Plotları bul ve işaretle
    for _, plot in pairs(Workspace:GetChildren()) do
        if plot.Name:find("Plot") or plot:FindFirstChild("Purchases") then
            local mainPart = plot:FindFirstChild("Main") or plot:FindFirstChild("Base") or plot:FindFirstChild("Plot")
            
            if mainPart and not baseESPFolder:FindFirstChild(plot.Name .. "_ESP") then
                -- Highlight ekle
                local highlight = Instance.new("Highlight")
                highlight.Name = plot.Name .. "_ESP"
                highlight.Adornee = mainPart
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                highlight.FillTransparency = 0.7
                highlight.OutlineTransparency = 0
                highlight.Parent = baseESPFolder
                
                -- Billboard ekle
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "BaseLabel"
                billboard.Adornee = mainPart
                billboard.Size = UDim2.new(0, 200, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 5, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = baseESPFolder
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = "🏠 " .. plot.Name
                label.TextColor3 = Color3.fromRGB(255, 255, 0)
                label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                label.TextStrokeTransparency = 0
                label.Font = Enum.Font.GothamBold
                label.TextSize = 14
                label.Parent = billboard
            end
        end
    end
end

local function removeBaseESP()
    for _, child in pairs(baseESPFolder:GetChildren()) do
        child:Destroy()
    end
end

buttons[4].MouseButton1Click:Connect(function()
    baseESPEnabled = not baseESPEnabled
    
    if baseESPEnabled then
        buttons[4].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        buttons[4].Text = "✅ Base ESP Active"
        createBaseESP()
        
        -- Sürekli kontrol et
        while baseESPEnabled do
            createBaseESP()
            wait(5)
        end
    else
        buttons[4].BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        buttons[4].Text = "🏠 Base ESP"
        removeBaseESP()
    end
end)

-- ===========================
-- 5. PLAYER ESP ÖZELLİĞİ
-- ===========================
local playerESPEnabled = false
local playerESPFolder = Instance.new("Folder")
playerESPFolder.Name = "PlayerESP"
playerESPFolder.Parent = game.CoreGui

local espConnections = {}

local function createPlayerESP(player)
    if player == LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Mevcut ESP'yi temizle
    local existingESP = playerESPFolder:FindFirstChild(player.Name)
    if existingESP then
        existingESP:Destroy()
    end
    
    -- Yeni ESP oluştur
    local highlight = Instance.new("Highlight")
    highlight.Name = player.Name
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = playerESPFolder
    
    -- İsim etiketi
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerLabel"
    billboard.Adornee = humanoidRootPart
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = playerESPFolder
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "👤 " .. player.Name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = billboard
end

local function removePlayerESP(player)
    local esp = playerESPFolder:FindFirstChild(player.Name)
    if esp then
        esp:Destroy()
    end
end

local function enablePlayerESP()
    -- Mevcut oyuncular
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then
                createPlayerESP(player)
            end
            
            espConnections[player] = player.CharacterAdded:Connect(function(character)
                wait(1)
                createPlayerESP(player)
            end)
        end
    end
    
    -- Yeni oyuncular
    espConnections.playerAdded = Players.PlayerAdded:Connect(function(player)
        espConnections[player] = player.CharacterAdded:Connect(function(character)
            wait(1)
            createPlayerESP(player)
        end)
    end)
    
    -- Ayrılan oyuncular
    espConnections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
        removePlayerESP(player)
        if espConnections[player] then
            espConnections[player]:Disconnect()
            espConnections[player] = nil
        end
    end)
end

local function disablePlayerESP()
    for _, esp in pairs(playerESPFolder:GetChildren()) do
        esp:Destroy()
    end
    
    for key, connection in pairs(espConnections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
        espConnections[key] = nil
    end
end

buttons[5].MouseButton1Click:Connect(function()
    playerESPEnabled = not playerESPEnabled
    
    if playerESPEnabled then
        buttons[5].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        buttons[5].Text = "✅ Player ESP Active"
        enablePlayerESP()
    else
        buttons[5].BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        buttons[5].Text = "👀 Player ESP"
        disablePlayerESP()
    end
end)

-- Karakter değişikliklerini dinle
LocalPlayer.CharacterAdded:Connect(function(character)
    if infiniteJumpEnabled then
        setupInfiniteJump()
    end
end)

warn("✅ Kurd Hub Mini Yüklendi! Tüm özellikler çalışır durumda.")
