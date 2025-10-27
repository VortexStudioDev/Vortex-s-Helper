-- Security check: Only runs on client side
if not game:GetService("RunService"):IsClient() then
    return
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- Safely wait for PlayerGui
local playerGui = player:WaitForChild("PlayerGui")

-- Server IDs storage
local usedServerIds = {}

-- STATUS DISPLAY SYSTEM
local statusLabel = nil
local currentTab = 1

-- MODULE DEĞİŞKENLERİ
local desyncActive = false
local autoLazerEnabled = false
local autoLazerThread = nil
local advancedDesyncActive = false

-- Blacklist for Auto Lazer
local blacklistNames = {"gametesterbrow"}
local blacklist = {}
for _, name in ipairs(blacklistNames) do
    blacklist[string.lower(name)] = true
end

-- ADVANCED DESYNC SİSTEMİ
local antiHitActive = false
local clonerActive = false
local desyncRunning = false
local cloneListenerConn
local antiHitRunning = false
local lockdownRunning = false
local lockdownConn = nil
local invHealthConns = {}
local desyncHighlights = {}

local function safeDisconnectConn(conn)
    if conn and typeof(conn) == "RBXScriptConnection" then
        pcall(function()
            conn:Disconnect()
        end)
    end
end

local function addDesyncHighlight(model)
    if not model or desyncHighlights[model] then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "DesyncHighlight"
    highlight.FillColor = Color3.fromRGB(0, 255, 100)
    highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = model
    desyncHighlights[model] = highlight
end

local function removeDesyncHighlight(model)
    local hl = desyncHighlights[model]
    if hl then
        pcall(function() hl:Destroy() end)
        desyncHighlights[model] = nil
    end
end

local function makeInvulnerable(model)
    if not model or not model.Parent then return end
    
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local maxHealth = 1e9
    pcall(function()
        hum.MaxHealth = maxHealth
        hum.Health = maxHealth
    end)

    if invHealthConns[model] then
        safeDisconnectConn(invHealthConns[model])
        invHealthConns[model] = nil
    end
    
    invHealthConns[model] = hum.HealthChanged:Connect(function()
        pcall(function()
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end)
    end)

    if not model:FindFirstChildOfClass("ForceField") then
        local ff = Instance.new("ForceField")
        ff.Visible = false
        ff.Parent = model
    end

    addDesyncHighlight(model)

    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    end)
end

local function removeInvulnerable(model)
    if not model then return end
    
    if invHealthConns[model] then
        safeDisconnectConn(invHealthConns[model])
        invHealthConns[model] = nil
    end
    
    for _, ff in ipairs(model:GetChildren()) do
        if ff:IsA("ForceField") then
            pcall(function() ff:Destroy() end)
        end
    end
    
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
            local safeMax = 100
            hum.MaxHealth = safeMax
            if hum.Health > safeMax then hum.Health = safeMax end
        end)
    end
    
    removeDesyncHighlight(model)
end

local function trySetFlag()
    pcall(function()
        if setfflag then setfflag("WorldStepMax", "-99999999999999") end
    end)
end

local function resetFlag()
    pcall(function()
        if setfflag then setfflag("WorldStepMax", "1") end
    end)
end

local function activateDesync()
    if desyncRunning then return end
    desyncRunning = true
    trySetFlag()
end

local function deactivateDesync()
    if not desyncRunning then return end
    desyncRunning = false
    resetFlag()
end

local function performDesyncLockdown(duration, onComplete)
    if lockdownRunning then
        if onComplete then pcall(onComplete) end
        return
    end
    lockdownRunning = true

    local char = player.Character
    if not char then
        lockdownRunning = false
        if onComplete then pcall(onComplete) end
        return
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then
        lockdownRunning = false
        if onComplete then pcall(onComplete) end
        return
    end

    local savedWalk = hum.WalkSpeed
    local savedJump = hum.JumpPower
    local savedUseJumpPower = hum.UseJumpPower

    hum.WalkSpeed = 0
    hum.JumpPower = 0
    hum.UseJumpPower = true
    hum.PlatformStand = true

    local fixedCFrame = hrp.CFrame

    if lockdownConn then
        lockdownConn:Disconnect()
        lockdownConn = nil
    end

    local lastCFrameTime = 0
    local CFRAME_UPDATE_INTERVAL = 0.15
    lockdownConn = RunService.Heartbeat:Connect(function()
        if not hrp or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        local now = tick()
        pcall(function()
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
            if (now - lastCFrameTime) >= CFRAME_UPDATE_INTERVAL then
                hrp.CFrame = fixedCFrame
                lastCFrameTime = now
            end
        end)
    end)

    task.delay(duration, function()
        if lockdownConn then
            lockdownConn:Disconnect()
            lockdownConn = nil
        end

        if hum and hum.Parent then
            pcall(function()
                hum.WalkSpeed = savedWalk or 16
                hum.JumpPower = savedJump or 50
                hum.UseJumpPower = savedUseJumpPower or true
                hum.PlatformStand = false
            end)
        end

        lockdownRunning = false
        if onComplete then pcall(onComplete) end
    end)
end

local function activateClonerDesync(callback)
    if clonerActive then
        if callback then callback() end
        return
    end
    clonerActive = true

    local Backpack = player:FindFirstChildOfClass("Backpack")
    local function equipQuantumCloner()
        if not Backpack then return end
        local tool = Backpack:FindFirstChild("Quantum Cloner")
        if tool then
            local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid:EquipTool(tool) end
        end
    end
    equipQuantumCloner()

    local REUseItem = ReplicatedStorage.Packages.Net:FindFirstChild("RE/UseItem")
    if REUseItem then REUseItem:FireServer() end
    
    local REQuantumClonerOnTeleport = ReplicatedStorage.Packages.Net:FindFirstChild("RE/QuantumCloner/OnTeleport")
    if REQuantumClonerOnTeleport then REQuantumClonerOnTeleport:FireServer() end

    local cloneName = tostring(player.UserId) .. "_Clone"
    cloneListenerConn = Workspace.ChildAdded:Connect(function(obj)
        if obj.Name == cloneName and obj:IsA("Model") then
            pcall(function() makeInvulnerable(obj) end)
            local origChar = player.Character
            if origChar then pcall(function() makeInvulnerable(origChar) end) end
            
            if cloneListenerConn then
                cloneListenerConn:Disconnect()
                cloneListenerConn = nil
            end

            performDesyncLockdown(1.6, function()
                if callback then pcall(callback) end
            end)
        end
    end)
end

local function deactivateClonerDesync()
    if not clonerActive then
        local existingClone = Workspace:FindFirstChild(tostring(player.UserId) .. "_Clone")
        if existingClone then
            pcall(function()
                removeInvulnerable(existingClone)
                existingClone:Destroy()
            end)
        end
        clonerActive = false
        return
    end

    clonerActive = false
    local char = player.Character
    if char then removeInvulnerable(char) end
    
    local clone = Workspace:FindFirstChild(tostring(player.UserId) .. "_Clone")
    if clone then
        removeInvulnerable(clone)
        pcall(function() clone:Destroy() end)
    end

    if cloneListenerConn then
        cloneListenerConn:Disconnect()
        cloneListenerConn = nil
    end
end

local function executeAdvancedDesync()
    if antiHitRunning then return end
    antiHitRunning = true

    activateDesync()
    task.wait(0.1)
    activateClonerDesync(function()
        deactivateDesync()
        antiHitRunning = false
        antiHitActive = true
        showNotification("🛡️ Advanced Desync Activated!", true)
    end)
end

local function deactivateAdvancedDesync()
    if antiHitRunning then
        if cloneListenerConn then
            cloneListenerConn:Disconnect()
            cloneListenerConn = nil
        end
        antiHitRunning = false
    end

    deactivateClonerDesync()
    deactivateDesync()
    antiHitActive = false

    if player.Character then removeInvulnerable(player.Character) end

    local possibleClone = Workspace:FindFirstChild(tostring(player.UserId) .. "_Clone")
    if possibleClone then
        pcall(function()
            removeInvulnerable(possibleClone)
            possibleClone:Destroy()
        end)
    end

    for model, _ in pairs(desyncHighlights) do
        removeDesyncHighlight(model)
    end

    showNotification("❌ Advanced Desync Deactivated!", false)
end

-- EKRANDA GÖRÜNEN BİLDİRİM SİSTEMİ
local function showNotification(message, isSuccess)
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "NotificationGUI"
    notificationGui.ResetOnSpawn = false
    notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notificationGui.Parent = CoreGui
    
    local notification = Instance.new("Frame")
    notification.Name = "VortexNotification"
    notification.Size = UDim2.new(0, 280, 0, 70)
    notification.Position = UDim2.new(0.5, -140, 0.3, 0)
    notification.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    notification.BackgroundTransparency = 0
    notification.BorderSizePixel = 0
    notification.ZIndex = 1000
    notification.ClipsDescendants = true
    notification.Parent = notificationGui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 10)
    notifCorner.Parent = notification
    
    local notifStroke = Instance.new("UIStroke")
    notifStroke.Color = isSuccess and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    notifStroke.Thickness = 3
    notifStroke.Parent = notification
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 50, 1, 0)
    icon.Position = UDim2.new(0, 0, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = isSuccess and "✅" or "❌"
    icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    icon.TextSize = 24
    icon.Font = Enum.Font.GothamBold
    icon.ZIndex = 1001
    icon.Parent = notification
    
    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(1, -60, 1, -10)
    notifText.Position = UDim2.new(0, 55, 0, 5)
    notifText.BackgroundTransparency = 1
    notifText.Text = message
    notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifText.TextSize = 14
    notifText.Font = Enum.Font.GothamBold
    notifText.TextStrokeTransparency = 0.8
    notifText.TextXAlignment = Enum.TextXAlignment.Left
    notifText.TextYAlignment = Enum.TextYAlignment.Top
    notifText.TextWrapped = true
    notifText.ZIndex = 1001
    notifText.Parent = notification
    
    notification.MouseEnter:Connect(function()
        notification.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    end)
    
    notification.MouseLeave:Connect(function()
        notification.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    end)
    
    notification.Position = UDim2.new(0.5, -140, 0.2, 0)
    local tweenIn = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -140, 0.3, 0)
    })
    tweenIn:Play()

    tweenIn.Completed:Connect(function()
        wait(1.5)
        
        if notification and notification.Parent then
            local tweenOut = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -140, 0.2, 0),
                BackgroundTransparency = 1
            })
            
            for _, child in pairs(notification:GetChildren()) do
                if child:IsA("TextLabel") then
                    child.TextTransparency = 1
                end
            end
            
            tweenOut:Play()
            
            tweenOut.Completed:Connect(function()
                if notificationGui and notificationGui.Parent then
                    notificationGui:Destroy()
                end
            end)
        end
    end)
end

-- Kalan kodlar aynı kalacak, sadece Tab 4'e Advanced Desync butonu eklenecek
-- [AUTO LAZER, VORTEX ANA SİSTEM FONKSİYONLARI, GUI OLUŞTURMA kodları buraya gelecek]

-- YENİ: Tab 4 - Modüller Butonları (Güncellenmiş)
local desyncButton = Instance.new("TextButton")
desyncButton.Name = "DesyncButton"
desyncButton.Size = UDim2.new(1, -6, 0, 22)
desyncButton.Position = UDim2.new(0, 3, 0, 5)
desyncButton.BackgroundColor3 = Color3.fromRGB(150, 100, 220)
desyncButton.Text = "DESYNC: OFF"
desyncButton.TextColor3 = Color3.fromRGB(255, 255, 255)
desyncButton.TextSize = 9
desyncButton.Font = Enum.Font.GothamBold
desyncButton.AutoButtonColor = false
desyncButton.TextYAlignment = Enum.TextYAlignment.Center
desyncButton.Parent = contentTab4

local advancedDesyncButton = Instance.new("TextButton")
advancedDesyncButton.Name = "AdvancedDesyncButton"
advancedDesyncButton.Size = UDim2.new(1, -6, 0, 22)
advancedDesyncButton.Position = UDim2.new(0, 3, 0, 32)
advancedDesyncButton.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
advancedDesyncButton.Text = "ADV DESYNC: OFF"
advancedDesyncButton.TextColor3 = Color3.fromRGB(255, 255, 255)
advancedDesyncButton.TextSize = 9
advancedDesyncButton.Font = Enum.Font.GothamBold
advancedDesyncButton.AutoButtonColor = false
advancedDesyncButton.TextYAlignment = Enum.TextYAlignment.Center
advancedDesyncButton.Parent = contentTab4

local autoLazerButton = Instance.new("TextButton")
autoLazerButton.Name = "AutoLazerButton"
autoLazerButton.Size = UDim2.new(1, -6, 0, 22)
autoLazerButton.Position = UDim2.new(0, 3, 0, 59)
autoLazerButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
autoLazerButton.Text = "AUTO LAZER: OFF"
autoLazerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoLazerButton.TextSize = 9
autoLazerButton.Font = Enum.Font.GothamBold
autoLazerButton.AutoButtonColor = false
autoLazerButton.TextYAlignment = Enum.TextYAlignment.Center
autoLazerButton.Parent = contentTab4

-- Buton stilleri
local desyncCorner = Instance.new("UICorner")
desyncCorner.CornerRadius = UDim.new(0, 4)
desyncCorner.Parent = desyncButton

local advancedDesyncCorner = Instance.new("UICorner")
advancedDesyncCorner.CornerRadius = UDim.new(0, 4)
advancedDesyncCorner.Parent = advancedDesyncButton

local lazerCorner = Instance.new("UICorner")
lazerCorner.CornerRadius = UDim.new(0, 4)
lazerCorner.Parent = autoLazerButton

-- YENİ: Advanced Desync Button events
advancedDesyncButton.MouseButton1Click:Connect(function()
    if antiHitRunning then
        showNotification("⏳ Advanced Desync is running...", false)
        return
    end
    
    if antiHitActive then
        deactivateAdvancedDesync()
        advancedDesyncButton.Text = "ADV DESYNC: OFF"
        advancedDesyncButton.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
    else
        executeAdvancedDesync()
        advancedDesyncButton.Text = "ADV DESYNC: ON"
        advancedDesyncButton.BackgroundColor3 = Color3.fromRGB(120, 255, 120)
    end
end)

advancedDesyncButton.MouseEnter:Connect(function()
    if antiHitActive then
        advancedDesyncButton.BackgroundColor3 = Color3.fromRGB(140, 255, 140)
    else
        advancedDesyncButton.BackgroundColor3 = Color3.fromRGB(255, 140, 140)
    end
end)

advancedDesyncButton.MouseLeave:Connect(function()
    if antiHitActive then
        advancedDesyncButton.BackgroundColor3 = Color3.fromRGB(120, 255, 120)
    else
        advancedDesyncButton.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
    end
end)

-- Character reset handler güncellendi
player.CharacterAdded:Connect(function()
    task.delay(0.3, function()
        desyncActive = false
        if desyncButton then
            desyncButton.Text = "DESYNC: OFF"
            desyncButton.BackgroundColor3 = Color3.fromRGB(150, 100, 220)
        end
        
        -- Advanced Desync reset
        antiHitActive = false
        if advancedDesyncButton then
            advancedDesyncButton.Text = "ADV DESYNC: OFF"
            advancedDesyncButton.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
        end
        
        local clone = Workspace:FindFirstChild(tostring(player.UserId) .. "_Clone")
        if clone then
            pcall(function()
                removeInvulnerable(clone)
                clone:Destroy()
            end)
        end
    end)
end)

-- Modules info güncellendi
local modulesInfo = Instance.new("TextLabel")
modulesInfo.Size = UDim2.new(1, -6, 0, 50)
modulesInfo.Position = UDim2.new(0, 3, 0, 86)
modulesInfo.BackgroundTransparency = 1
modulesInfo.Text = "Desync: Mobile Desync\nAdv Desync: Anti-Hit System\nAuto Lazer: Auto Target"
modulesInfo.TextColor3 = Color3.fromRGB(220, 220, 220)
modulesInfo.TextSize = 7
modulesInfo.Font = Enum.Font.Gotham
modulesInfo.TextWrapped = true
modulesInfo.TextYAlignment = Enum.TextYAlignment.Top
modulesInfo.Parent = contentTab4

print("✅ Vortex UI Loaded!")
print("⚙️ Version 2.1 - Advanced Desync Integrated")
print("📜 © 2025-2030 VortexTeamDev™ License")

-- Show initial status
updateStatusDisplay("System Ready", true)

-- Test notification
delay(1, function()
    showNotification("🚀 Vortex UI Ready! Modules: Desync + Adv Desync + AutoLazer", true)
end)
