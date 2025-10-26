-- Chered Hub - Ultra Optimized Mobile Edition
-- Discord: https://discord.gg/qvVEZt3q88
-- Tarih: 2025-10-10

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ÖN BELLEK SİSTEMİ
local Cache = {
    Descendants = {},
    LastUpdate = {},
    Config = {},
    ESP = {},
    Sounds = {}
}

-- PERFORMANS AYARLARI
local PERFORMANCE = {
    ESP_UPDATE = 2.0, -- ESP güncelleme aralığı
    CACHE_LIFETIME = 5, -- Önbellek ömrü
    MAX_SOUNDS = 2, -- Maksimum ses
    DEBOUNCE_TIME = 0.3 -- Debounce süresi
}

-- TEMEL FONKSİYONLAR
local function SafePCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        return nil
    end
    return result
end

local function GetCachedDescendants(obj)
    if not obj then return {} end
    
    local now = tick()
    local cached = Cache.Descendants[obj]
    
    if cached and (now - cached.time) < PERFORMANCE.CACHE_LIFETIME then
        return cached.data
    end
    
    local descendants = SafePCall(function() return obj:GetDescendants() end) or {}
    Cache.Descendants[obj] = {data = descendants, time = now}
    
    return descendants
end

local function CleanCache()
    local now = tick()
    for key, data in pairs(Cache.Descendants) do
        if not key or not key.Parent or (now - data.time) > PERFORMANCE.CACHE_LIFETIME then
            Cache.Descendants[key] = nil
        end
    end
end

-- SES YÖNETİMİ
local function PlayOptimizedSound(soundId, volume)
    SafePCall(function()
        -- Eski sesleri temizle
        for i = #Cache.Sounds, 1, -1 do
            if not Cache.Sounds[i] or not Cache.Sounds[i].Parent then
                table.remove(Cache.Sounds, i)
            end
        end
        
        -- Ses sınırlaması
        if #Cache.Sounds >= PERFORMANCE.MAX_SOUNDS then
            local oldest = table.remove(Cache.Sounds, 1)
            if oldest then oldest:Destroy() end
        end
        
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Volume = volume or 1
        sound.Looped = false
        sound.Parent = SoundService
        
        table.insert(Cache.Sounds, sound)
        sound:Play()
        
        sound.Ended:Connect(function()
            task.delay(0.3, function()
                SafePCall(function() sound:Destroy() end)
            end)
        end)
    end)
end

-- KONFİGÜRASYON YÖNETİMİ
local CONFIG = {
    ESPBest = false,
    ESPSecret = false,
    ESPBase = false,
    ESPPlayer = false
}

-- GUI TEMİZLEME
local function CleanOldGUI()
    local oldGUI = playerGui:FindFirstChild("CheredHub_FULL")
    if oldGUI then SafePCall(function() oldGUI:Destroy() end) end
end

CleanOldGUI()

-- ANA GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = "CheredHub_FULL"
GUI.ResetOnSpawn = false
GUI.Parent = playerGui

-- BUTON OLUŞTURMA
local function CreateButton(parent, size, position, text, color, cornerRadius)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = color
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.BorderSizePixel = 0
    button.Parent = parent
    
    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(0, cornerRadius or 12)
    
    local stroke = Instance.new("UIStroke", button)
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(120, 180, 255)
    stroke.Transparency = 0.4
    
    return button
end

-- DRAG SİSTEMİ
local function MakeDraggable(guiObject)
    local dragging = false
    local dragInput, dragStart, startPos

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ESP SİSTEMİ
local ESP = {
    Boxes = {},
    Enabled = false
}

function ESP:Clear()
    for _, data in pairs(self.Boxes) do
        SafePCall(function()
            if data.Box then data.Box:Destroy() end
            if data.Text then data.Text:Destroy() end
        end)
    end
    self.Boxes = {}
end

function ESP:UpdatePlayer()
    if not self.Enabled then return end
    
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            local humanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                if not self.Boxes[targetPlayer] then
                    -- Kutu oluştur
                    local box = Instance.new("BoxHandleAdornment")
                    box.Size = Vector3.new(4, 6, 4)
                    box.Adornee = humanoidRootPart
                    box.AlwaysOnTop = true
                    box.ZIndex = 10
                    box.Transparency = 0.5
                    box.Color3 = Color3.fromRGB(255, 0, 60)
                    box.Parent = humanoidRootPart
                    
                    -- İsim etiketi
                    local billboard = Instance.new("BillboardGui")
                    billboard.Adornee = humanoidRootPart
                    billboard.Size = UDim2.new(0, 200, 0, 30)
                    billboard.StudsOffset = Vector3.new(0, 4, 0)
                    billboard.AlwaysOnTop = true
                    
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.fromRGB(255, 0, 60)
                    label.TextStrokeTransparency = 0
                    label.Text = targetPlayer.Name
                    label.Font = Enum.Font.GothamBold
                    label.TextSize = 18
                    label.Parent = billboard
                    
                    billboard.Parent = humanoidRootPart
                    
                    self.Boxes[targetPlayer] = {Box = box, Text = billboard}
                else
                    -- Güncelleme
                    local data = self.Boxes[targetPlayer]
                    if data.Box then data.Box.Adornee = humanoidRootPart end
                    if data.Text then data.Text.Adornee = humanoidRootPart end
                end
            end
        else
            if self.Boxes[targetPlayer] then
                SafePCall(function()
                    if self.Boxes[targetPlayer].Box then self.Boxes[targetPlayer].Box:Destroy() end
                    if self.Boxes[targetPlayer].Text then self.Boxes[targetPlayer].Text:Destroy() end
                end)
                self.Boxes[targetPlayer] = nil
            end
        end
    end
end

-- ANA MENÜ
local MainMenu = Instance.new("Frame")
MainMenu.Size = UDim2.new(0, 220, 0, 350)
MainMenu.Position = UDim2.new(0.5, -110, 0.5, -175)
MainMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainMenu.BackgroundTransparency = 0.05
MainMenu.BorderSizePixel = 0
MainMenu.Visible = false
MainMenu.Parent = GUI

local MainCorner = Instance.new("UICorner", MainMenu)
MainCorner.CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "🛡️ CHERED HUB 🛡️"
Title.TextColor3 = Color3.fromRGB(120, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.BackgroundTransparency = 1
Title.Parent = MainMenu

-- ESP BUTONLARI
local ESPButtons = {
    CreateButton(MainMenu, UDim2.new(0.45, 0, 0, 30), UDim2.new(0.025, 0, 0, 50), "🔥 BEST", Color3.fromRGB(255, 80, 80), 8),
    CreateButton(MainMenu, UDim2.new(0.45, 0, 0, 30), UDim2.new(0.525, 0, 0, 50), "💎 SECRET", Color3.fromRGB(80, 160, 255), 8),
    CreateButton(MainMenu, UDim2.new(0.95, 0, 0, 30), UDim2.new(0.025, 0, 0, 90), "🏠 BASE ESP", Color3.fromRGB(80, 255, 140), 8),
    CreateButton(MainMenu, UDim2.new(0.95, 0, 0, 30), UDim2.new(0.025, 0, 0, 130), "👥 PLAYER ESP", Color3.fromRGB(255, 200, 80), 8)
}

-- ARAÇLAR MENÜSÜ
local ToolsMenu = Instance.new("Frame")
ToolsMenu.Size = UDim2.new(0, 200, 0, 280)
ToolsMenu.Position = UDim2.new(0.5, 120, 0.5, -140)
ToolsMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
ToolsMenu.BackgroundTransparency = 0.05
ToolsMenu.BorderSizePixel = 0
ToolsMenu.Parent = GUI

local ToolsCorner = Instance.new("UICorner", ToolsMenu)
ToolsCorner.CornerRadius = UDim.new(0, 12)

local ToolsTitle = Instance.new("TextLabel")
ToolsTitle.Size = UDim2.new(1, 0, 0, 30)
ToolsTitle.Text = "⚡ TOOLS ⚡"
ToolsTitle.TextColor3 = Color3.fromRGB(255, 120, 180)
ToolsTitle.Font = Enum.Font.GothamBold
ToolsTitle.TextSize = 18
ToolsTitle.BackgroundTransparency = 1
ToolsTitle.Parent = ToolsMenu

-- TOOL BUTONLARI
local ToolButtons = {
    CreateButton(ToolsMenu, UDim2.new(0.9, 0, 0, 35), UDim2.new(0.05, 0, 0, 40), "🛡️ DESYNC", Color3.fromRGB(255, 100, 100), 10),
    CreateButton(ToolsMenu, UDim2.new(0.9, 0, 0, 35), UDim2.new(0.05, 0, 0, 85), "🦘 INF JUMP", Color3.fromRGB(100, 255, 100), 10),
    CreateButton(ToolsMenu, UDim2.new(0.9, 0, 0, 35), UDim2.new(0.05, 0, 0, 130), "🚀 FLY BASE", Color3.fromRGB(100, 180, 255), 10),
    CreateButton(ToolsMenu, UDim2.new(0.9, 0, 0, 35), UDim2.new(0.05, 0, 0, 175), "🏗️ STEAL FLOOR", Color3.fromRGB(255, 180, 100), 10)
}

-- AÇMA BUTONU
local OpenButton = Instance.new("ImageButton")
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0, 20, 0.5, -25)
OpenButton.Image = "rbxassetid://129657171957977"
OpenButton.BackgroundTransparency = 1
OpenButton.Parent = GUI

MakeDraggable(MainMenu)
MakeDraggable(ToolsMenu)
MakeDraggable(OpenButton)

-- BUTON FONKSİYONLARI
OpenButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = not MainMenu.Visible
end)

-- ESP BUTON İŞLEVLERİ
ESPButtons[4].MouseButton1Click:Connect(function() -- Player ESP
    ESP.Enabled = not ESP.Enabled
    ESPButtons[4].BackgroundColor3 = ESP.Enabled and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 200, 80)
    if not ESP.Enabled then
        ESP:Clear()
    end
end)

-- DESYNC SİSTEMİ
local DesyncActive = false
ToolButtons[1].MouseButton1Click:Connect(function()
    DesyncActive = not DesyncActive
    ToolButtons[1].BackgroundColor3 = DesyncActive and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 100, 100)
    
    if DesyncActive then
        PlayOptimizedSound("rbxassetid://144686873", 1)
    end
end)

-- INFINITE JUMP
local InfJumpActive = false
ToolButtons[2].MouseButton1Click:Connect(function()
    InfJumpActive = not InfJumpActive
    ToolButtons[2].BackgroundColor3 = InfJumpActive and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(100, 255, 100)
    
    if InfJumpActive then
        local connection
        connection = UserInputService.JumpRequest:Connect(function()
            if InfJumpActive and player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
end)

-- FLY TO BASE
local Flying = false
ToolButtons[3].MouseButton1Click:Connect(function()
    if Flying then return end
    
    Flying = true
    ToolButtons[3].BackgroundColor3 = Color3.fromRGB(60, 255, 60)
    ToolButtons[3].Text = "✈️ FLYING..."
    
    local character = player.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if humanoidRootPart then
        -- Basit fly implementasyonu
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 50, 0)
        bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
        bodyVelocity.Parent = humanoidRootPart
        
        task.wait(2)
        
        SafePCall(function() bodyVelocity:Destroy() end)
        PlayOptimizedSound("rbxassetid://144686873", 1)
    end
    
    Flying = false
    ToolButtons[3].BackgroundColor3 = Color3.fromRGB(100, 180, 255)
    ToolButtons[3].Text = "🚀 FLY BASE"
end)

-- ANA GÜNCELLEME DÖNGÜSÜ
task.spawn(function()
    while true do
        CleanCache()
        ESP:UpdatePlayer()
        task.wait(PERFORMANCE.ESP_UPDATE)
    end
end)

-- OYUNCU ÇIKIŞ TEMİZLİĞİ
Players.PlayerRemoving:Connect(function(leftPlayer)
    if ESP.Boxes[leftPlayer] then
        SafePCall(function()
            if ESP.Boxes[leftPlayer].Box then ESP.Boxes[leftPlayer].Box:Destroy() end
            if ESP.Boxes[leftPlayer].Text then ESP.Boxes[leftPlayer].Text:Destroy() end
        end)
        ESP.Boxes[leftPlayer] = nil
    end
end)

-- BAŞLANGIÇ BİLDİRİMİ
task.spawn(function()
    task.wait(1)
    PlayOptimizedSound("rbxassetid://144686873", 0.5)
end)

print("🛡️ Chered Hub - Ultra Optimized Mobile Edition Yüklendi!")
