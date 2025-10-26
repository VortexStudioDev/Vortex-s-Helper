-- Vortex'Helper - ESP Only System
-- Discord: https://discord.gg/vortexhelper

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI'yi temizle
local oldGui = playerGui:FindFirstChild("VortexHelper")
if oldGui then oldGui:Destroy() end

-- Ana GUI
local VortexHelper = Instance.new("ScreenGui")
VortexHelper.Name = "VortexHelper"
VortexHelper.ResetOnSpawn = false
VortexHelper.Parent = playerGui

-- Ana Menü
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = VortexHelper

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 150, 255)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Başlık
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "🛡️ Vortex'Helper 🛡️\nESP System"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BackgroundTransparency = 1
Title.TextYAlignment = Enum.TextYAlignment.Center
Title.Parent = MainFrame

-- Açma/Kapama Butonu
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -30)
ToggleButton.Text = "⚡"
ToggleButton.TextColor3 = Color3.white
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 24
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
ToggleButton.Parent = VortexHelper

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

-- Buton oluşturma fonksiyonu
local function CreateButton(parent, text, position, color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 40)
    button.Position = position
    button.Text = text
    button.TextColor3 = Color3.white
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.BackgroundColor3 = color
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    return button
end

-- ESP Sistemleri
local ESP = {
    Players = {
        Enabled = false,
        Boxes = {}
    },
    BestPets = {
        Enabled = false
    },
    SecretPets = {
        Enabled = false
    },
    Bases = {
        Enabled = false
    }
}

-- Bildirim fonksiyonu
local function Notify(title, message)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = message,
        Duration = 3
    })
end

-- Player ESP
local function CreatePlayerESP(targetPlayer)
    if ESP.Players.Boxes[targetPlayer] then return end
    
    local character = targetPlayer.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- ESP Kutusu
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "VortexPlayerESP"
    box.Size = Vector3.new(4, 6, 2)
    box.Adornee = humanoidRootPart
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Color3 = Color3.fromRGB(0, 255, 0)
    box.Transparency = 0.3
    box.Parent = humanoidRootPart
    
    -- İsim etiketi
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "VortexPlayerTag"
    billboard.Size = UDim2.new(0, 200, 0, 40)
    billboard.Adornee = humanoidRootPart
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = humanoidRootPart
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = targetPlayer.Name
    label.TextColor3 = Color3.fromRGB(0, 255, 0)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = billboard
    
    ESP.Players.Boxes[targetPlayer] = {
        Box = box,
        Tag = billboard
    }
end

local function UpdatePlayerESP()
    if not ESP.Players.Enabled then return end
    
    for targetPlayer, espData in pairs(ESP.Players.Boxes) do
        if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if espData.Box then espData.Box:Destroy() end
            if espData.Tag then espData.Tag:Destroy() end
            ESP.Players.Boxes[targetPlayer] = nil
        end
    end
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player then
            CreatePlayerESP(targetPlayer)
        end
    end
end

local function ClearPlayerESP()
    for targetPlayer, espData in pairs(ESP.Players.Boxes) do
        if espData.Box then espData.Box:Destroy() end
        if espData.Tag then espData.Tag:Destroy() end
    end
    ESP.Players.Boxes = {}
end

-- Best Pet ESP
local function UpdateBestPetESP()
    if not ESP.BestPets.Enabled then return end
    
    local plotsFolder = Workspace:FindFirstChild("Plots")
    if not plotsFolder then return end
    
    -- Önceki ESP'leri temizle
    for _, plot in pairs(plotsFolder:GetChildren()) do
        for _, descendant in pairs(plot:GetDescendants()) do
            if descendant.Name == "VortexBestPetESP" then
                descendant:Destroy()
            end
        end
    end
    
    local bestPet = nil
    local bestMPS = 0
    
    for _, plot in pairs(plotsFolder:GetChildren()) do
        for _, model in pairs(plot:GetDescendants()) do
            if model:IsA("Model") then
                local displayName = model:FindFirstChild("DisplayName")
                local generation = model:FindFirstChild("Generation")
                
                if displayName and generation then
                    local mpsText = generation.Text
                    local mps = tonumber(mpsText:match("%d+")) or 0
                    
                    if mps > bestMPS then
                        bestMPS = mps
                        bestPet = model
                    end
                end
            end
        end
    end
    
    if bestPet then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "VortexBestPetESP"
        billboard.Size = UDim2.new(0, 250, 0, 60)
        billboard.Adornee = bestPet.PrimaryPart or bestPet:FindFirstChild("HumanoidRootPart")
        billboard.StudsOffset = Vector3.new(0, 4, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = bestPet
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "🔥 BEST PET\n" .. bestMPS .. " MPS"
        label.TextColor3 = Color3.fromRGB(255, 215, 0)
        label.TextStrokeTransparency = 0
        label.Font = Enum.Font.GothamBold
        label.TextSize = 16
        label.Parent = billboard
    end
end

-- Secret Pet ESP
local function UpdateSecretPetESP()
    if not ESP.SecretPets.Enabled then return end
    
    local plotsFolder = Workspace:FindFirstChild("Plots")
    if not plotsFolder then return end
    
    -- Önceki ESP'leri temizle
    for _, plot in pairs(plotsFolder:GetChildren()) do
        for _, descendant in pairs(plot:GetDescendants()) do
            if descendant.Name == "VortexSecretPetESP" then
                descendant:Destroy()
            end
        end
    end
    
    for _, plot in pairs(plotsFolder:GetChildren()) do
        for _, model in pairs(plot:GetDescendants()) do
            if model:IsA("Model") then
                local rarityLabel = model:FindFirstChild("Rarity")
                local displayName = model:FindFirstChild("DisplayName")
                
                if rarityLabel and displayName and rarityLabel.Text == "Secret" then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "VortexSecretPetESP"
                    billboard.Size = UDim2.new(0, 200, 0, 50)
                    billboard.Adornee = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = model
                    
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = "💎 " .. displayName.Text .. " 💎"
                    label.TextColor3 = Color3.fromRGB(255, 0, 255)
                    label.TextStrokeTransparency = 0
                    label.Font = Enum.Font.GothamBold
                    label.TextSize = 14
                    label.Parent = billboard
                end
            end
        end
    end
end

-- Base ESP
local function UpdateBaseESP()
    if not ESP.Bases.Enabled then return end
    
    local plotsFolder = Workspace:FindFirstChild("Plots")
    if not plotsFolder then return end
    
    -- Önceki ESP'leri temizle
    for _, plot in pairs(plotsFolder:GetChildren()) do
        for _, descendant in pairs(plot:GetDescendants()) do
            if descendant.Name == "VortexBaseESP" then
                descendant:Destroy()
            end
        end
    end
    
    for _, plot in pairs(plotsFolder:GetChildren()) do
        local plotSign = plot:FindFirstChild("PlotSign")
        if plotSign then
            local yourBase = plotSign:FindFirstChild("YourBase")
            if yourBase and not yourBase.Enabled then
                local mainPart = plot:FindFirstChild("Main")
                if mainPart then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "VortexBaseESP"
                    billboard.Size = UDim2.new(0, 150, 0, 40)
                    billboard.Adornee = mainPart
                    billboard.StudsOffset = Vector3.new(0, 5, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = mainPart
                    
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = "🏠 ENEMY BASE"
                    label.TextColor3 = Color3.fromRGB(255, 50, 50)
                    label.TextStrokeTransparency = 0
                    label.Font = Enum.Font.GothamBold
                    label.TextSize = 14
                    label.Parent = billboard
                end
            end
        end
    end
end

-- Butonları oluştur
local buttons = {}
local buttonY = 70

buttons.playerESP = CreateButton(MainFrame, "👥 Player ESP", UDim2.new(0.05, 0, 0, buttonY), Color3.fromRGB(255, 50, 50))
buttons.bestPetESP = CreateButton(MainFrame, "🔥 Best Pet ESP", UDim2.new(0.05, 0, 0, buttonY + 50), Color3.fromRGB(255, 150, 50))
buttons.secretPetESP = CreateButton(MainFrame, "💎 Secret Pet ESP", UDim2.new(0.05, 0, 0, buttonY + 100), Color3.fromRGB(200, 50, 255))
buttons.baseESP = CreateButton(MainFrame, "🏠 Base ESP", UDim2.new(0.05, 0, 0, buttonY + 150), Color3.fromRGB(50, 150, 255))
buttons.discord = CreateButton(MainFrame, "📋 Discord", UDim2.new(0.05, 0, 0, buttonY + 200), Color3.fromRGB(100, 100, 255))

-- Buton fonksiyonları
buttons.playerESP.MouseButton1Click:Connect(function()
    ESP.Players.Enabled = not ESP.Players.Enabled
    if ESP.Players.Enabled then
        buttons.playerESP.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        Notify("Player ESP", "Player ESP: ON 👥")
        UpdatePlayerESP()
    else
        buttons.playerESP.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        Notify("Player ESP", "Player ESP: OFF 🚫")
        ClearPlayerESP()
    end
end)

buttons.bestPetESP.MouseButton1Click:Connect(function()
    ESP.BestPets.Enabled = not ESP.BestPets.Enabled
    if ESP.BestPets.Enabled then
        buttons.bestPetESP.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
        Notify("Best Pet ESP", "Best Pet ESP: ON 🔥")
        UpdateBestPetESP()
    else
        buttons.bestPetESP.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
        Notify("Best Pet ESP", "Best Pet ESP: OFF 🚫")
    end
end)

buttons.secretPetESP.MouseButton1Click:Connect(function()
    ESP.SecretPets.Enabled = not ESP.SecretPets.Enabled
    if ESP.SecretPets.Enabled then
        buttons.secretPetESP.BackgroundColor3 = Color3.fromRGB(255, 50, 255)
        Notify("Secret Pet ESP", "Secret Pet ESP: ON 💎")
        UpdateSecretPetESP()
    else
        buttons.secretPetESP.BackgroundColor3 = Color3.fromRGB(200, 50, 255)
        Notify("Secret Pet ESP", "Secret Pet ESP: OFF 🚫")
    end
end)

buttons.baseESP.MouseButton1Click:Connect(function()
    ESP.Bases.Enabled = not ESP.Bases.Enabled
    if ESP.Bases.Enabled then
        buttons.baseESP.BackgroundColor3 = Color3.fromRGB(50, 200, 255)
        Notify("Base ESP", "Base ESP: ON 🏠")
        UpdateBaseESP()
    else
        buttons.baseESP.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
        Notify("Base ESP", "Base ESP: OFF 🚫")
    end
end)

buttons.discord.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/vortexhelper")
    Notify("Discord", "Discord link copied! 📋")
end)

-- ESP Güncelleme Döngüleri
RunService.Heartbeat:Connect(function()
    UpdatePlayerESP()
end)

spawn(function()
    while true do
        wait(2)
        if ESP.BestPets.Enabled then
            UpdateBestPetESP()
        end
        if ESP.SecretPets.Enabled then
            UpdateSecretPetESP()
        end
        if ESP.Bases.Enabled then
            UpdateBaseESP()
        end
    end
end)

-- Menü toggle
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Sürükleme özelliği
local dragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

-- Player eklendiğinde/çıkarıldığında ESP'yi güncelle
Players.PlayerAdded:Connect(function(player)
    if ESP.Players.Enabled then
        wait(1)
        UpdatePlayerESP()
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ESP.Players.Boxes[player] then
        if ESP.Players.Boxes[player].Box then ESP.Players.Boxes[player].Box:Destroy() end
        if ESP.Players.Boxes[player].Tag then ESP.Players.Boxes[player].Tag:Destroy() end
        ESP.Players.Boxes[player] = nil
    end
end)

-- Başlangıç bildirimi
Notify("Vortex'Helper", "ESP System loaded! 🚀\nClick ⚡ to open menu.")
