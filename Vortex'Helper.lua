local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Basit Bildirim
local function showNotification(message, isSuccess)
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "DesyncNotify"
    notificationGui.ResetOnSpawn = false
    notificationGui.Parent = CoreGui
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 200, 0, 50)
    notification.Position = UDim2.new(0.5, -100, 0.2, 0)
    notification.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    notification.BorderSizePixel = 0
    notification.Parent = notificationGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = isSuccess and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 80, 80)
    stroke.Thickness = 2
    stroke.Parent = notification

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -10, 1, -10)
    text.Position = UDim2.new(0, 5, 0, 5)
    text.BackgroundTransparency = 1
    text.Text = message
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextSize = 12
    text.Font = Enum.Font.GothamBold
    text.TextWrapped = true
    text.Parent = notification

    task.delay(2, function()
        notificationGui:Destroy()
    end)
end

-- Quantum Cloner Desync Sistemi
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

-- TAM LOCKDOWN SİSTEMİ
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

    -- Karakteri gizle
    local originalTransparency = {}
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            originalTransparency[part] = part.Transparency
            part.Transparency = 1
        end
    end

    -- Karakteri kitliyoruz
    local savedWalk = hum.WalkSpeed
    local savedJump = hum.JumpPower
    local savedUseJumpPower = hum.UseJumpPower

    hum.WalkSpeed = 0
    hum.JumpPower = 0
    hum.UseJumpPower = true
    hum.PlatformStand = true

    local fixedCFrame = hrp.CFrame

    -- Eski connection'ı temizle
    if lockdownConn then
        lockdownConn:Disconnect()
        lockdownConn = nil
    end

    -- Karakteri sabit tut
    lockdownConn = RunService.Heartbeat:Connect(function()
        if not hrp or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        pcall(function()
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            hrp.CFrame = fixedCFrame
        end)
    end)

    showNotification("🛡️ Lockdown Active...", false)

    -- Belirtilen süre sonunda lockdown'u kaldır
    task.delay(duration, function()
        if lockdownConn then
            lockdownConn:Disconnect()
            lockdownConn = nil
        end

        -- Görünürlüğü geri getir
        for part, transparency in pairs(originalTransparency) do
            if part and part.Parent then
                part.Transparency = transparency
            end
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
        showNotification("✅ Lockdown Complete", true)
        if onComplete then pcall(onComplete) end
    end)
end

local function activateClonerDesync(callback)
    if clonerActive then
        showNotification("⚠️ Cloner already active", false)
        return
    end
    clonerActive = true

    local Backpack = player:FindFirstChildOfClass("Backpack")
    local function equipQuantumCloner()
        if not Backpack then 
            showNotification("❌ No Backpack", false)
            clonerActive = false -- ÖNEMLİ: Sıfırla
            return 
        end
        local tool = Backpack:FindFirstChild("Quantum Cloner")
        if not tool then 
            showNotification("❌ No Quantum Cloner", false)
            clonerActive = false -- ÖNEMLİ: Sıfırla
            return 
        end
        
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then 
            humanoid:EquipTool(tool)
            task.wait(0.5)
        end
    end
    equipQuantumCloner()

    -- Eğer clonerActive false ise çık (hata oldu)
    if not clonerActive then return end

    local REUseItem = ReplicatedStorage.Packages.Net:FindFirstChild("RE/UseItem")
    if REUseItem then 
        REUseItem:FireServer()
        showNotification("⚡ Activating Quantum...", false)
    else
        showNotification("❌ RE/UseItem not found", false)
        clonerActive = false -- ÖNEMLİ: Sıfırla
        return
    end
    
    task.wait(0.2)
    
    local REQuantumClonerOnTeleport = ReplicatedStorage.Packages.Net:FindFirstChild("RE/QuantumCloner/OnTeleport")
    if REQuantumClonerOnTeleport then 
        REQuantumClonerOnTeleport:FireServer()
    else
        showNotification("❌ Quantum Cloner remote not found", false)
        clonerActive = false -- ÖNEMLİ: Sıfırla
        return
    end

    local cloneName = tostring(player.UserId) .. "_Clone"
    
    -- Clone oluşumunu dinle
    cloneListenerConn = Workspace.ChildAdded:Connect(function(obj)
        if obj.Name == cloneName and obj:IsA("Model") then
            showNotification("🔮 Clone Created!", true)
            
            pcall(function() 
                makeInvulnerable(obj)
            end)
            
            local origChar = player.Character
            if origChar then 
                pcall(function() 
                    makeInvulnerable(origChar)
                end) 
            end
            
            if cloneListenerConn then
                cloneListenerConn:Disconnect()
                cloneListenerConn = nil
            end

            -- 3 SANİYE LOCKDOWN
            performDesyncLockdown(3, function()
                clonerActive = false -- ÖNEMLİ: İşlem bitince sıfırla
                if callback then pcall(callback) end
            end)
        end
    end)

    -- 7 saniye timeout - ÖNEMLİ FIX
    task.delay(7, function()
        if cloneListenerConn then
            cloneListenerConn:Disconnect()
            cloneListenerConn = nil
        end
        if not antiHitActive then
            showNotification("❌ Desync Failed - Timeout", false)
        end
        clonerActive = false -- ÖNEMLİ: Timeout'ta sıfırla
        antiHitRunning = false -- ÖNEMLİ: Timeout'ta sıfırla
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
    if antiHitRunning then 
        showNotification("⏳ Already running...", false)
        return 
    end
    antiHitRunning = true

    showNotification("🚀 Starting Quantum Desync...", false)
    
    activateDesync()
    task.wait(0.1)
    activateClonerDesync(function()
        deactivateDesync()
        antiHitRunning = false -- ÖNEMLİ: İşlem bitince sıfırla
        antiHitActive = true
        showNotification("✅ Desync Active!\n🛡️ You are invisible", true)
    end)
end

local function deactivateAdvancedDesync()
    if antiHitRunning then
        if cloneListenerConn then
            cloneListenerConn:Disconnect()
            cloneListenerConn = nil
        end
        antiHitRunning = false -- ÖNEMLİ: Sıfırla
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
    
    showNotification("🔴 Desync No Active", false)
end

-- KÜÇÜK BUTON (80x35)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "QuantumDesyncButton"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local desyncButton = Instance.new("TextButton")
desyncButton.Name = "Deysnc"
desyncButton.Size = UDim2.new(0, 80, 0, 35)
desyncButton.Position = UDim2.new(0, 10, 0.5, -17)
desyncButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
desyncButton.BackgroundTransparency = 0.3
desyncButton.Text = "DESYNC"
desyncButton.TextColor3 = Color3.fromRGB(255, 255, 255)
desyncButton.TextSize = 12
desyncButton.Font = Enum.Font.GothamBold
desyncButton.Draggable = true
desyncButton.Parent = screenGui

-- Buton stilleri
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = desyncButton

local buttonStroke = Instance.new("UIStroke")
buttonStroke.Color = Color3.fromRGB(200, 230, 255)
buttonStroke.Thickness = 1.5
buttonStroke.Parent = desyncButton

-- Buton etkileşimleri
desyncButton.MouseEnter:Connect(function()
    TweenService:Create(desyncButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.1
    }):Play()
end)

desyncButton.MouseLeave:Connect(function()
    TweenService:Create(desyncButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.3
    }):Play()
end)

-- Buton tıklama
desyncButton.MouseButton1Click:Connect(function()
    if antiHitRunning then
        desyncButton.Text = "WORKING"
        desyncButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        return
    end
    
    if antiHitActive then
        deactivateAdvancedDesync()
        desyncButton.Text = "DESYNC"
        desyncButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    else
        executeAdvancedDesync()
        desyncButton.Text = "ACTIVE"
        desyncButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    end
end)

-- Character reset - TÜM DEĞİŞKENLERİ SIFIRLA
player.CharacterAdded:Connect(function()
    task.delay(0.5, function()
        antiHitActive = false
        clonerActive = false
        antiHitRunning = false
        desyncRunning = false
        lockdownRunning = false
        
        desyncButton.Text = "DESYNC"
        desyncButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
        
        local clone = Workspace:FindFirstChild(tostring(player.UserId) .. "_Clone")
        if clone then
            pcall(function()
                removeInvulnerable(clone)
                clone:Destroy()
            end)
        end
    end)
end)

print("✅ Quantum Desync Loaded!")
print("🔧 Fixed: Multiple uses now work properly!")
