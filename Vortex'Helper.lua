-- Chered Hub - Desync Body (Anti-Hit) Script
-- Orijinalinden ayrıştırılmış temiz versiyon

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI oluştur
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CheredDesyncGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Ana buton
local desyncButton = Instance.new("TextButton")
desyncButton.Name = "DesyncButton"
desyncButton.Size = UDim2.new(0, 180, 0, 45)
desyncButton.Position = UDim2.new(0, 20, 0, 20)
desyncButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
desyncButton.Text = "🛡️ DESYNC BODY"
desyncButton.TextColor3 = Color3.fromRGB(255, 255, 255)
desyncButton.Font = Enum.Font.GothamBold
desyncButton.TextSize = 14
desyncButton.BorderSizePixel = 0
desyncButton.ZIndex = 10
desyncButton.Parent = screenGui

-- Buton stil
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = desyncButton

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 2
stroke.Transparency = 0.3
stroke.Parent = desyncButton

-- Desync değişkenleri
local antiHitActive = false
local clonerActive = false
local desyncActive = false
local antiHitRunning = false
local lockdownRunning = false

local cloneListenerConn = nil
local lockdownConn = nil
local invHealthConns = {}
local desyncHighlights = {}

-- Yardımcı fonksiyonlar
local function notify(title, text, duration)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

local function safeDisconnect(conn)
    if conn and typeof(conn) == "RBXScriptConnection" then
        pcall(function() conn:Disconnect() end)
    end
end

-- Highlight ekleme
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

-- Highlight kaldırma
local function removeDesyncHighlight(model)
    local hl = desyncHighlights[model]
    if hl then
        pcall(function() hl:Destroy() end)
        desyncHighlights[model] = nil
    end
end

-- Ölümsüzlük ekleme
local function makeInvulnerable(model)
    if not model or not model.Parent then return end
    
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    -- Health ayarı
    pcall(function()
        hum.MaxHealth = 1e9
        hum.Health = 1e9
    end)

    -- Health değişimini izleme
    if invHealthConns[model] then
        safeDisconnect(invHealthConns[model])
    end
    
    invHealthConns[model] = hum.HealthChanged:Connect(function()
        pcall(function()
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end)
    end)

    -- ForceField ekleme
    if not model:FindFirstChildOfClass("ForceField") then
        local ff = Instance.new("ForceField")
        ff.Visible = false
        ff.Parent = model
    end

    -- Highlight ekleme
    addDesyncHighlight(model)

    -- State ayarları
    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    end)
end

-- Ölümsüzlük kaldırma
local function removeInvulnerable(model)
    if not model then return end
    
    -- Health connection'ı temizle
    if invHealthConns[model] then
        safeDisconnect(invHealthConns[model])
        invHealthConns[model] = nil
    end

    -- ForceField'leri temizle
    for _, ff in ipairs(model:GetChildren()) do
        if ff:IsA("ForceField") then
            pcall(function() ff:Destroy() end)
        end
    end

    -- Humanoid state'leri sıfırla
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
            hum.MaxHealth = 100
            if hum.Health > 100 then
                hum.Health = 100
            end
        end)
    end

    -- Highlight'ı kaldır
    removeDesyncHighlight(model)
end

-- FPS flag ayarları
local function trySetFlag()
    pcall(function()
        if setfflag then
            setfflag('WorldStepMax', '-99999999999999')
        end
    end)
end

local function resetFlag()
    pcall(function()
        if setfflag then
            setfflag('WorldStepMax', '1')
        end
    end)
end

-- Desync aktivasyonu
local function activateDesync()
    if desyncActive then return end
    desyncActive = true
    trySetFlag()
end

local function deactivateDesync()
    if not desyncActive then return end
    desyncActive = false
    resetFlag()
end

-- Lockdown sistemi
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

    -- Değerleri kaydet
    local savedWalk = hum.WalkSpeed
    local savedJump = hum.JumpPower

    -- Karakteri kilitle
    hum.WalkSpeed = 0
    hum.JumpPower = 0
    hum.PlatformStand = true

    local fixedCFrame = hrp.CFrame

    -- Lockdown connection'ı
    safeDisconnect(lockdownConn)
    lockdownConn = RunService.Heartbeat:Connect(function()
        if not hrp or not player.Character then return end
        
        pcall(function()
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
            hrp.CFrame = fixedCFrame
        end)
    end)

    -- Lockdown UI
    local overlayGui = Instance.new("ScreenGui")
    overlayGui.Name = "DesyncOverlay"
    overlayGui.ResetOnSpawn = false
    overlayGui.Parent = playerGui

    local blackFrame = Instance.new("Frame")
    blackFrame.Size = UDim2.new(2, 0, 2, 0)
    blackFrame.Position = UDim2.new(-0.5, 0, -0.5, 0)
    blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    blackFrame.BackgroundTransparency = 0
    blackFrame.ZIndex = 9999
    blackFrame.Parent = overlayGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 80)
    label.Position = UDim2.new(0, 0, 0.4, -40)
    label.BackgroundTransparency = 1
    label.Text = "🛡️ DESYNC ACTIVE 🛡️"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 28
    label.ZIndex = 10000
    label.Parent = overlayGui

    -- Süre dolunca temizlik
    task.delay(duration, function()
        safeDisconnect(lockdownConn)
        
        if hum and hum.Parent then
            pcall(function()
                hum.WalkSpeed = savedWalk
                hum.JumpPower = savedJump
                hum.PlatformStand = false
            end
        end

        pcall(function() overlayGui:Destroy() end)
        lockdownRunning = false
        
        notify("DESYNC", "Desync Successful! 🛡️", 4)
        
        if onComplete then pcall(onComplete) end
    end)
end

-- Cloner desync aktivasyonu
local function activateClonerDesync(callback)
    if clonerActive then
        if callback then pcall(callback) end
        return
    end
    
    clonerActive = true

    -- Quantum Cloner'ı equip et
    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        local cloner = backpack:FindFirstChild("Quantum Cloner")
        if cloner then
            local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:EquipTool(cloner)
            end
        end
    end

    -- Cloner event'lerini tetikle
    local REUseItem = ReplicatedStorage:FindFirstChild("Packages") and 
                     ReplicatedStorage.Packages:FindFirstChild("Net") and
                     ReplicatedStorage.Packages.Net:FindFirstChild("RE/UseItem")
    
    if REUseItem then
        REUseItem:FireServer()
    end

    -- Klon dinleyicisi
    local cloneName = tostring(player.UserId) .. "_Clone"
    safeDisconnect(cloneListenerConn)
    
    cloneListenerConn = Workspace.ChildAdded:Connect(function(obj)
        if obj.Name == cloneName and obj:IsA("Model") then
            -- Klonu koruma altına al
            pcall(function() makeInvulnerable(obj) end)
            
            -- Orijinal karakteri koruma altına al
            local origChar = player.Character
            if origChar then
                pcall(function() makeInvulnerable(origChar) end)
            end
            
            safeDisconnect(cloneListenerConn)
            cloneListenerConn = nil

            -- Lockdown başlat
            performDesyncLockdown(1.6, function()
                if callback then pcall(callback) end
            end)
        end
    end)
end

-- Cloner desync kapatma
local function deactivateClonerDesync()
    if not clonerActive then
        -- Eski klonu temizle
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
    safeDisconnect(cloneListenerConn)

    -- Karakter korumasını kaldır
    local char = player.Character
    if char then
        removeInvulnerable(char)
    end

    -- Klonu temizle
    local clone = Workspace:FindFirstChild(tostring(player.UserId) .. "_Clone")
    if clone then
        removeInvulnerable(clone)
        pcall(function() clone:Destroy() end)
    end
end

-- Anti-Hit kapatma
local function deactivateAntiHit()
    if antiHitRunning then
        safeDisconnect(cloneListenerConn)
        antiHitRunning = false
    end

    deactivateClonerDesync()
    deactivateDesync()
    antiHitActive = false

    -- Karakter korumasını kaldır
    if player.Character then
        removeInvulnerable(player.Character)
    end

    -- Klon temizliği
    local possibleClone = Workspace:FindFirstChild(tostring(player.UserId) .. "_Clone")
    if possibleClone then
        pcall(function()
            removeInvulnerable(possibleClone)
            possibleClone:Destroy()
        end)
    end

    -- Highlight temizliği
    for model, _ in pairs(desyncHighlights) do
        removeDesyncHighlight(model)
    end

    notify("DESYNC", "Anti-Hit deactivated! ❌", 3)
    updateDesyncButton()
end

-- Anti-Hit çalıştırma
local function executeAntiHit()
    if antiHitRunning then return end
    antiHitRunning = true

    updateDesyncButton()

    activateDesync()
    task.wait(0.1)
    
    activateClonerDesync(function()
        deactivateDesync()
        antiHitRunning = false
        antiHitActive = true
        notify("DESYNC", "Anti-Hit activated! 🛡️", 3)
        updateDesyncButton()
    end)
end

-- Buton güncelleme
local function updateDesyncButton()
    if antiHitRunning then
        desyncButton.BackgroundColor3 = Color3.fromRGB(255, 200, 60)
        desyncButton.Text = "⏳ DESYNC ACTIVE"
    elseif antiHitActive then
        desyncButton.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
        desyncButton.Text = "✅ DESYNC ON"
    else
        desyncButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        desyncButton.Text = "🛡️ DESYNC BODY"
    end
end

-- Buton tıklama eventi
desyncButton.MouseButton1Click:Connect(function()
    if antiHitRunning then return end
    
    if antiHitActive then
        deactivateAntiHit()
    else
        executeAntiHit()
    end
end)

-- Karakter event'leri
player.CharacterAdded:Connect(function(character)
    task.delay(0.5, function()
        if antiHitActive then
            pcall(function() makeInvulnerable(character) end)
        end
    end)
end)

player.CharacterRemoving:Connect(function(character)
    pcall(function() removeInvulnerable(character) end)
end)

-- İlk güncelleme
updateDesyncButton()

print("✅ Chered Hub Desync Body yüklendi!")
print("🛡️ Buton ekranın sol üst köşesinde")
