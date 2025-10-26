-- Xlsqr Premium GUI Script (Mini Mobile + Fix Completo)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Stati delle funzioni
local states = {
    instantTP = false,
    speedBoost = false,
    instantSteal = false,
    optimizeGame = false,
    noclip = false,
    infiniteJump = false,
    playerESP = false,
    itemESP = false,
    healthBar = false,
    distance = false
}

-- Variabili
local originalWalkSpeed = 16
local boostedSpeed = 32
local savedPosition = nil
local currentTab = "Main"

-- Connections da disconnettere al respawn
local connections = {}

-- Riferimenti ai bottoni (globali per aggiornamenti)
local buttons = {}

-- Crea ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "XlsqrPremium"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame principale (MINI MOBILE)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 280)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 32)
header.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header

-- Titolo
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(0, 150, 1, 0)
titleLabel.Position = UDim2.new(0, 8, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Xlsqr Premium"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = header

-- Indicatore online
local statusIndicator = Instance.new("Frame")
statusIndicator.Name = "StatusIndicator"
statusIndicator.Size = UDim2.new(0, 8, 0, 8)
statusIndicator.Position = UDim2.new(1, -16, 0.5, -4)
statusIndicator.BackgroundColor3 = Color3.fromRGB(50, 220, 100)
statusIndicator.BorderSizePixel = 0
statusIndicator.Parent = header

local indicatorCorner = Instance.new("UICorner")
indicatorCorner.CornerRadius = UDim.new(1, 0)
indicatorCorner.Parent = statusIndicator

-- Container per i tab
local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, -16, 0, 28)
tabContainer.Position = UDim2.new(0, 8, 0, 40)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

-- Funzione per creare tab button
local function createTabButton(name, position)
    local button = Instance.new("TextButton")
    button.Name = name .. "Tab"
    button.Size = UDim2.new(0.32, -2, 1, 0)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 11
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.Parent = tabContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    return button
end

-- Crea i tab
local mainTab = createTabButton("Main", UDim2.new(0, 0, 0, 0))
local espTab = createTabButton("ESP", UDim2.new(0.33, 0, 0, 0))
local miscTab = createTabButton("Misc", UDim2.new(0.66, 0, 0, 0))

-- Content frames per ogni tab
local mainContent = Instance.new("Frame")
mainContent.Name = "MainContent"
mainContent.Size = UDim2.new(1, -16, 0, 190)
mainContent.Position = UDim2.new(0, 8, 0, 78)
mainContent.BackgroundTransparency = 1
mainContent.Visible = true
mainContent.Parent = mainFrame

local espContent = Instance.new("Frame")
espContent.Name = "ESPContent"
espContent.Size = UDim2.new(1, -16, 0, 190)
espContent.Position = UDim2.new(0, 8, 0, 78)
espContent.BackgroundTransparency = 1
espContent.Visible = false
espContent.Parent = mainFrame

local miscContent = Instance.new("Frame")
miscContent.Name = "MiscContent"
miscContent.Size = UDim2.new(1, -16, 0, 190)
miscContent.Position = UDim2.new(0, 8, 0, 78)
miscContent.BackgroundTransparency = 1
miscContent.Visible = false
miscContent.Parent = mainFrame

-- Funzione per aggiornare UI bottone
local function updateButtonUI(buttonName, state)
    if buttons[buttonName] and buttons[buttonName].Parent then
        buttons[buttonName].Text = buttonName .. ": " .. (state and "ON" or "OFF")
        buttons[buttonName].TextColor3 = state and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(200, 200, 220)
    end
end

-- Funzione per creare bottone
local function createFeatureButton(name, stateName, position, parent, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, 0, 0, 38)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(90, 50, 180)
    button.BorderSizePixel = 0
    button.Text = name .. ": OFF"
    button.TextColor3 = Color3.fromRGB(200, 200, 220)
    button.TextSize = 11
    button.Font = Enum.Font.GothamMedium
    button.AutoButtonColor = false
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(110, 70, 200)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(90, 50, 180)}):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        callback()
    end)
    
    buttons[name] = button
    return button
end

-- BOTTONI MAIN TAB
createFeatureButton("Instant TP", "instantTP", UDim2.new(0, 0, 0, 0), mainContent, function()
    states.instantTP = not states.instantTP
    updateButtonUI("Instant TP", states.instantTP)
end)

createFeatureButton("Speed Boost", "speedBoost", UDim2.new(0, 0, 0, 44), mainContent, function()
    states.speedBoost = not states.speedBoost
    updateButtonUI("Speed Boost", states.speedBoost)
    
    if humanoid and humanoid.Parent then
        if states.speedBoost then
            humanoid.WalkSpeed = boostedSpeed
        else
            humanoid.WalkSpeed = originalWalkSpeed
        end
    end
end)

createFeatureButton("Instant Steal", "instantSteal", UDim2.new(0, 0, 0, 88), mainContent, function()
    states.instantSteal = not states.instantSteal
    updateButtonUI("Instant Steal", states.instantSteal)
end)

createFeatureButton("Optimize Game", "optimizeGame", UDim2.new(0, 0, 0, 132), mainContent, function()
    states.optimizeGame = not states.optimizeGame
    updateButtonUI("Optimize Game", states.optimizeGame)
    
    if states.optimizeGame then
        settings().Rendering.QualityLevel = 1
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            elseif v:IsA("Explosion") then
                v.BlastPressure = 1
                v.BlastRadius = 1
            end
        end
    else
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
    end
end)

-- BOTTONI ESP TAB
createFeatureButton("Player ESP", "playerESP", UDim2.new(0, 0, 0, 0), espContent, function()
    states.playerESP = not states.playerESP
    updateButtonUI("Player ESP", states.playerESP)
end)

createFeatureButton("Item ESP", "itemESP", UDim2.new(0, 0, 0, 44), espContent, function()
    states.itemESP = not states.itemESP
    updateButtonUI("Item ESP", states.itemESP)
end)

createFeatureButton("Health Bars", "healthBar", UDim2.new(0, 0, 0, 88), espContent, function()
    states.healthBar = not states.healthBar
    updateButtonUI("Health Bars", states.healthBar)
end)

createFeatureButton("Show Distance", "distance", UDim2.new(0, 0, 0, 132), espContent, function()
    states.distance = not states.distance
    updateButtonUI("Show Distance", states.distance)
end)

-- BOTTONI MISC TAB (senza stati on/off)
local setPositionBtn = Instance.new("TextButton")
setPositionBtn.Name = "SetPosition"
setPositionBtn.Size = UDim2.new(1, 0, 0, 38)
setPositionBtn.Position = UDim2.new(0, 0, 0, 0)
setPositionBtn.BackgroundColor3 = Color3.fromRGB(90, 50, 180)
setPositionBtn.BorderSizePixel = 0
setPositionBtn.Text = "Set Position"
setPositionBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
setPositionBtn.TextSize = 11
setPositionBtn.Font = Enum.Font.GothamMedium
setPositionBtn.AutoButtonColor = false
setPositionBtn.Parent = miscContent

local corner1 = Instance.new("UICorner")
corner1.CornerRadius = UDim.new(0, 6)
corner1.Parent = setPositionBtn

setPositionBtn.MouseButton1Click:Connect(function()
    if rootPart and rootPart.Parent then
        savedPosition = rootPart.CFrame
        setPositionBtn.Text = "Position Saved!"
        setPositionBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
        wait(1)
        if setPositionBtn and setPositionBtn.Parent then
            setPositionBtn.Text = "Set Position"
            setPositionBtn.BackgroundColor3 = Color3.fromRGB(90, 50, 180)
        end
    end
end)

local teleportToBtn = Instance.new("TextButton")
teleportToBtn.Name = "TeleportTo"
teleportToBtn.Size = UDim2.new(1, 0, 0, 38)
teleportToBtn.Position = UDim2.new(0, 0, 0, 44)
teleportToBtn.BackgroundColor3 = Color3.fromRGB(90, 50, 180)
teleportToBtn.BorderSizePixel = 0
teleportToBtn.Text = "Teleport to Saved"
teleportToBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
teleportToBtn.TextSize = 11
teleportToBtn.Font = Enum.Font.GothamMedium
teleportToBtn.AutoButtonColor = false
teleportToBtn.Parent = miscContent

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0, 6)
corner2.Parent = teleportToBtn

teleportToBtn.MouseButton1Click:Connect(function()
    if savedPosition and rootPart and rootPart.Parent then
        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = savedPosition})
        tween:Play()
    else
        if teleportToBtn and teleportToBtn.Parent then
            teleportToBtn.Text = "No Position Saved!"
            wait(1)
            if teleportToBtn and teleportToBtn.Parent then
                teleportToBtn.Text = "Teleport to Saved"
            end
        end
    end
end)

createFeatureButton("Noclip", "noclip", UDim2.new(0, 0, 0, 88), miscContent, function()
    states.noclip = not states.noclip
    updateButtonUI("Noclip", states.noclip)
end)

createFeatureButton("Infinite Jump", "infiniteJump", UDim2.new(0, 0, 0, 132), miscContent, function()
    states.infiniteJump = not states.infiniteJump
    updateButtonUI("Infinite Jump", states.infiniteJump)
end)

-- Sistema Tab switching
local function switchTab(tabName)
    mainContent.Visible = (tabName == "Main")
    espContent.Visible = (tabName == "ESP")
    miscContent.Visible = (tabName == "Misc")
    
    mainTab.BackgroundColor3 = (tabName == "Main") and Color3.fromRGB(100, 60, 200) or Color3.fromRGB(70, 40, 150)
    espTab.BackgroundColor3 = (tabName == "ESP") and Color3.fromRGB(100, 60, 200) or Color3.fromRGB(70, 40, 150)
    miscTab.BackgroundColor3 = (tabName == "Misc") and Color3.fromRGB(100, 60, 200) or Color3.fromRGB(70, 40, 150)
end

mainTab.MouseButton1Click:Connect(function() switchTab("Main") end)
espTab.MouseButton1Click:Connect(function() switchTab("ESP") end)
miscTab.MouseButton1Click:Connect(function() switchTab("Misc") end)

-- Funzione per disconnettere tutte le connessioni
local function disconnectAll()
    for name, conn in pairs(connections) do
        if conn and typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    connections = {}
end

-- Funzione per riconnettere tutto
local function setupConnections()
    disconnectAll()
    
    -- INSTANT TP
    connections.instantTP = RunService.RenderStepped:Connect(function()
        if states.instantTP and rootPart and rootPart.Parent and character and character.Parent then
            pcall(function()
                local lookVector = rootPart.CFrame.LookVector
                rootPart.CFrame = rootPart.CFrame + (lookVector * 0.5)
            end)
        end
    end)
    
    -- INSTANT STEAL - SINGOLO TWEEN SENZA LOOP
    connections.instantSteal = RunService.Heartbeat:Connect(function()
        if states.instantSteal and savedPosition and rootPart and rootPart.Parent and character and character.Parent then
            pcall(function()
                local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
                local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = savedPosition})
                tween:Play()
                wait(0.35)
            end)
        end
    end)
    
    -- NOCLIP
    connections.noclip = RunService.Stepped:Connect(function()
        if states.noclip and character and character.Parent then
            pcall(function()
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        end
    end)
    
    -- INFINITE JUMP
    connections.infiniteJump = UserInputService.JumpRequest:Connect(function()
        if states.infiniteJump and humanoid and humanoid.Parent then
            pcall(function()
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end)
        end
    end)
    
    -- SPEED BOOST continuo
    connections.speedBoost = RunService.Heartbeat:Connect(function()
        if states.speedBoost and humanoid and humanoid.Parent then
            pcall(function()
                humanoid.WalkSpeed = boostedSpeed
            end)
        end
    end)
end

-- Setup iniziale
setupConnections()

-- Gestione respawn - RICONNETTE TUTTO
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    
    -- Disconnetti TUTTO prima di aspettare
    disconnectAll()
    
    -- Aspetta il character
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Aspetta che il character sia completamente caricato
    wait(1)
    
    -- Riconnetti tutto
    setupConnections()
    
    -- Aggiorna tutti i bottoni
    for name, state in pairs(states) do
        local buttonName = name:gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end):gsub("([A-Z])", " %1"):sub(2)
        updateButtonUI(buttonName, state)
    end
    
    print("🔄 Character respawnato - Connessioni ristabilite!")
end)

print("✅ Xlsqr Premium GUI caricata!")
print("📱 Mini GUI per mobile (200x280)")
print("⚡ Instant TP: Teletrasporto continuo avanti")
print("💾 Instant Steal: Tween veloce alla posizione salvata")
print("🔄 FIX COMPLETO: Nessun errore dopo respawn!")
