local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI oluştur
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CheredHub_FULL"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Desync butonu
local btnDesync = Instance.new("TextButton")
btnDesync.Name = "DesyncButton"
btnDesync.Size = UDim2.new(0, 200, 0, 42)
btnDesync.Position = UDim2.new(0, 20, 0, 20)
btnDesync.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
btnDesync.Text = "🛡️ DESYNC BODY"
btnDesync.TextColor3 = Color3.fromRGB(255, 255, 255)
btnDesync.Font = Enum.Font.GothamBold
btnDesync.TextSize = 14
btnDesync.BorderSizePixel = 0
btnDesync.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = btnDesync

local btnStroke = Instance.new("UIStroke")
btnStroke.Thickness = 1.5
btnStroke.Color = Color3.fromRGB(120, 180, 255)
btnStroke.Transparency = 0.4
btnStroke.Parent = btnDesync

-- Desync değişkenleri
local antiHitActive = false
local clonerActive = false
local desyncActive = false
local cloneListenerConn
local antiHitRunning = false

local lockdownRunning = false
local lockdownConn = nil

local invHealthConns = {}
local desyncHighlights = {}

-- Yardımcı fonksiyonlar
local function notify(title, text, dur)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title or "Info", 
            Text = text or "", 
            Duration = dur or 3
        })
    end)
end

local function safeDisconnectConn(conn)
    if conn and typeof(conn) == "RBXScriptConnection" then
        pcall(function() conn:Disconnect() end)
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

    pcall(function()
        hum.MaxHealth = 1e9
        hum.Health = 1e9
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
            if hum.Health > safeMax then
                hum.Health = safeMax
            end
        end)
    end
    
    removeDesyncHighlight(model)
end

local function trySetFlag()
    pcall(function()
        if setfflag then
            setfflag("WorldStepMax", "-99999999999999")
        end
    end)
end

local function resetFlag()
    pcall(function()
        if setfflag then
            setfflag("WorldStepMax", "1")
        end
    end)
end

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

    local overlayGui = Instance.new("ScreenGui")
    overlayGui.Name = "NameliunDesyncOverlay"
    overlayGui.ResetOnSpawn = false
    overlayGui.Parent = playerGui

    local blackFrame = Instance.new("Frame", overlayGui)
    blackFrame.Size = UDim2.new(2, 0, 2, 0)
    blackFrame.Position = UDim2.new(-0.5, 0, -0.5, 0)
    blackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blackFrame.BackgroundTransparency = 0
    blackFrame.ZIndex = 9999

    local label = Instance.new("TextLabel", blackFrame)
    label.Size = UDim2.new(1, 0, 0, 120)
    label.Position = UDim2.new(0, 0, 0.45, -60)
    label.BackgroundTransparency = 1
    label.Text = "🛡️ Chered is desyncing you 🛡️"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 36
    label.ZIndex = 10000

    local barBg = Instance.new("Frame", overlayGui)
    barBg.Size = UDim2.new(0.35, 0, 0, 8)
    barBg.Position = UDim2.new(0.325, 0, 0.55, 0)
    barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 10000
    local barCorner = Instance.new("UICorner", barBg)
    barCorner.CornerRadius = UDim.new(0, 4)

    local barFill = Instance.new("Frame", barBg)
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    barFill.BorderSizePixel = 0
    barFill.ZIndex = 10001
    local barFillCorner = Instance.new("UICorner", barFill)
    barFillCorner.CornerRadius = UDim.new(0, 4)

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tweenGoal = { Size = UDim2.new(1, 0, 1, 0) }
    local tween = TweenService:Create(barFill, tweenInfo, tweenGoal)
    tween:Play()

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

        pcall(function() overlayGui:Destroy() end)

        notify("Desync", "Desync Successful! 🛡️", 4)

        lockdownRunning = false
        if onComplete then pcall(onComplete) end
    end)
end

local function activateClonerDesync(callback)
    if clonerActive then
        if callback then pcall(callback) end
        return
    end
    clonerActive = true

    local Backpack = player:FindFirstChildOfClass("Backpack")
    local function equipQuantumCloner()
        if not Backpack then return end
        local tool = Backpack:FindFirstChild("Quantum Cloner")
        if tool then
            local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:EquipTool(tool)
            end
        end
    end
    equipQuantumCloner()

    local REUseItem = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Net") and ReplicatedStorage.Packages.Net:FindFirstChild("RE/UseItem")
    if REUseItem then
        REUseItem:FireServer()
    end
    
    local REQuantumClonerOnTeleport = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Net") and ReplicatedStorage.Packages.Net:FindFirstChild("RE/QuantumCloner/OnTeleport")
    if REQuantumClonerOnTeleport then
        REQuantumClonerOnTeleport:FireServer()
    end

    local cloneName = tostring(player.UserId) .. "_Clone"
    cloneListenerConn = Workspace.ChildAdded:Connect(function(obj)
        if obj.Name == cloneName and obj:IsA("Model") then
            pcall(function() makeInvulnerable(obj) end)
            local origChar = player.Character
            if origChar then
                pcall(function() makeInvulnerable(origChar) end)
            end
            if cloneListenerConn then
                cloneListenerConn:Disconnect()
            end
            cloneListenerConn = nil

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
    if char then
        removeInvulnerable(char)
    end
    
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

local function deactivateAntiHit()
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

    if player.Character then
        removeInvulnerable(player.Character)
    end

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

    notify("Anti-Hit deactivated. ❌", "", 2)
    updateDesyncButton()
end

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
        notify("Anti-Hit activated! 🛡️", "", 3)
        updateDesyncButton()
    end)
end

local function updateDesyncButton()
    if antiHitRunning then
        btnDesync.BackgroundColor3 = Color3.fromRGB(255, 220, 60)
        btnDesync.Text = "⏳ DESYNC ACTIVE"
    elseif antiHitActive then
        btnDesync.BackgroundColor3 = Color3.fromRGB(120, 255, 120)
        btnDesync.Text = "✅ DESYNC ON"
    else
        btnDesync.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
        btnDesync.Text = "🛡️ DESYNC BODY"
    end
end

btnDesync.MouseButton1Click:Connect(function()
    if antiHitRunning then return end
    
    if antiHitActive then
        deactivateAntiHit()
    else
        executeAntiHit()
    end
end)

player.CharacterAdded:Connect(function()
    task.delay(0.3, function()
        local clone = Workspace:FindFirstChild(tostring(player.UserId) .. "_Clone")
        if clone then
            pcall(function()
                removeInvulnerable(clone)
                clone:Destroy()
            end)
        end
    end)
end)

player.CharacterRemoving:Connect(function(ch)
    pcall(function() removeInvulnerable(ch) end)
end)

updateDesyncButton()

print("Chered Hub Desync Body yüklendi!")
