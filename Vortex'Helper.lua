-- Kurd Hub Mini - Tüm Özellikler Çalışır Halde
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")

local LocalPlayer = Players.LocalPlayer

-- UI Oluşturma
local screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
screenGui.Name = "KurdHubMini"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 250, 0, 220)
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
createButton(3, "🎯 Auto Laser Steal", 2)
createButton(4, "🏠 Base ESP", 3)

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
-- 3. AUTO LASER STEAL MODE
-- ===========================
local autoStealEnabled = false
local stealConnection

local function enableAutoSteal()
    if stealConnection then
        stealConnection:Disconnect()
    end
    
    stealConnection = RunService.Heartbeat:Connect(function()
        if not autoStealEnabled then return end
        
        -- Tüm steal promptlarını otomatik etkinleştir
        for _, prompt in pairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                local actionText = string.lower(prompt.ActionText)
                if string.find(actionText, "steal") or string.find(actionText, "brain") then
                    fireproximityprompt(prompt)
                end
            end
        end
        
        -- Laser tool kontrolü
        local character = LocalPlayer.Character
        if character then
            local laserTool = character:FindFirstChild("Laser Cape") or LocalPlayer.Backpack:FindFirstChild("Laser Cape")
            if laserTool then
                -- En yakın oyuncuyu bul
                local nearestPlayer = nil
                local nearestDistance = math.huge
                local localRoot = character:FindFirstChild("HumanoidRootPart")
                
                if localRoot then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                            if targetRoot then
                                local distance = (localRoot.Position - targetRoot.Position).Magnitude
                                if distance < nearestDistance and distance < 50 then
                                    nearestDistance = distance
                                    nearestPlayer = player
                                end
                            end
                        end
                    end
                    
                    -- Laser kullan
                    if nearestPlayer and nearestPlayer.Character then
                        local targetPart = nearestPlayer.Character:FindFirstChild("UpperTorso") or 
                                         nearestPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if targetPart then
                            -- Laser tool'u kullan
                            laserTool.Parent = character
                            wait(0.1)
                            -- Laser ateşleme kodu (oyuna özel)
                            pcall(function()
                                local remote = ReplicatedStorage:FindFirstChild("UseLaser")
                                if remote then
                                    remote:FireServer(targetPart.Position)
                                end
                            end)
                        end
                    end
                end
            end
        end
    end)
end

local function disableAutoSteal()
    if stealConnection then
        stealConnection:Disconnect()
        stealConnection = nil
    end
end

buttons[3].MouseButton1Click:Connect(function()
    autoStealEnabled = not autoStealEnabled
    
    if autoStealEnabled then
        buttons[3].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        buttons[3].Text = "✅ Auto Steal Active"
        enableAutoSteal()
    else
        buttons[3].BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        buttons[3].Text = "🎯 Auto Laser Steal"
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

local function findPlots()
    local plots = {}
    
    -- Farklı plot türlerini ara
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:find("Plot") or obj.Name:find("Base") then
            table.insert(plots, obj)
        end
        
        -- Purchases olan objeleri kontrol et
        if obj:FindFirstChild("Purchases") then
            table.insert(plots, obj)
        end
    end
    
    return plots
end

local function createBaseESP()
    -- Önceki ESP'leri temizle
    for _, child in pairs(baseESPFolder:GetChildren()) do
        child:Destroy()
    end
    
    local plots = findPlots()
    
    for _, plot in pairs(plots) do
        local mainPart = nil
        
        -- Ana parçayı bul
        if plot:IsA("Model") then
            mainPart = plot:FindFirstChild("Main") or plot:FindFirstChild("Base") or plot:FindFirstChild("HumanoidRootPart")
            if not mainPart then
                for _, part in pairs(plot:GetChildren()) do
                    if part:IsA("Part") then
                        mainPart = part
                        break
                    end
                end
            end
        elseif plot:IsA("Part") then
            mainPart = plot
        end
        
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
        
        -- Sürekli güncelle
        coroutine.wrap(function()
            while baseESPEnabled do
                createBaseESP()
                wait(3)
            end
        end)()
    else
        buttons[4].BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        buttons[4].Text = "🏠 Base ESP"
        removeBaseESP()
    end
end)

-- Karakter değişikliklerini dinle
LocalPlayer.CharacterAdded:Connect(function(character)
    if infiniteJumpEnabled then
        setupInfiniteJump()
    end
end)

-- UI'ı sürükleme özelliği
local dragging = false
local dragInput, dragStart, startPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

warn("✅ Kurd Hub Mini Yüklendi! Tüm özellikler çalışır durumda.")
