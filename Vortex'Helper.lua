-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Simple Notification System
local function showNotification(message, isSuccess)
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "SimpleNotify"
    notificationGui.ResetOnSpawn = false
    notificationGui.Parent = CoreGui
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 200, 0, 40)
    notification.Position = UDim2.new(0.5, -100, 0.2, 0)
    notification.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    notification.BorderSizePixel = 0
    notification.Parent = notificationGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = notification
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = isSuccess and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 80, 80)
    stroke.Thickness = 1
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

-- Green Character Highlight System
local characterHighlights = {}

local function addCharacterHighlight(character)
    if not character or characterHighlights[character] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "DesyncCharacterHighlight"
    highlight.FillColor = Color3.fromRGB(0, 255, 100)
    highlight.OutlineColor = Color3.fromRGB(0, 200, 80)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    
    characterHighlights[character] = highlight
end

local function removeCharacterHighlight(character)
    local highlight = characterHighlights[character]
    if highlight then
        pcall(function() 
            highlight:Destroy() 
        end)
        characterHighlights[character] = nil
    end
end

local function removeAllHighlights()
    for character, highlight in pairs(characterHighlights) do
        pcall(function()
            highlight:Destroy()
        end)
    end
    characterHighlights = {}
end

-- Quantum Cloner Desync System
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
    addCharacterHighlight(model) -- Add green highlight

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
    removeCharacterHighlight(model) -- Remove green highlight
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
            if humanoid then 
                humanoid:EquipTool(tool)
                task.wait(0.5)
            end
        end
    end
    equipQuantumCloner()

    local REUseItem = ReplicatedStorage.Packages.Net:FindFirstChild("RE/UseItem")
    if REUseItem then 
        REUseItem:FireServer()
        showNotification("Activating Quantum Cloner...", false)
    end
    
    local REQuantumClonerOnTeleport = ReplicatedStorage.Packages.Net:FindFirstChild("RE/QuantumCloner/OnTeleport")
    if REQuantumClonerOnTeleport then 
        REQuantumClonerOnTeleport:FireServer()
    end

    local cloneName = tostring(player.UserId) .. "_Clone"
    cloneListenerConn = Workspace.ChildAdded:Connect(function(obj)
        if obj.Name == cloneName and obj:IsA("Model") then
            showNotification("Clone Created!", true)
            
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

    -- Timeout
    task.delay(5, function()
        if cloneListenerConn then
            cloneListenerConn:Disconnect()
            cloneListenerConn = nil
        end
        clonerActive = false
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
        showNotification("Already running...", false)
        return 
    end
    antiHitRunning = true

    showNotification("Starting Desync...", false)
    
    activateDesync()
    task.wait(0.1)
    activateClonerDesync(function()
        deactivateDesync()
        antiHitRunning = false
        antiHitActive = true
        showNotification("Desync Active!", true)
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
    
    removeAllHighlights() -- Remove all green highlights
    
    showNotification("Desync Deactivated", false)
end

-- GUI Creation (YOUR EXACT BUTON DESIGN)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "QuantumDesyncButton"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main Button (YOUR EXACT DESIGN)
local desyncButton = Instance.new("TextButton")
desyncButton.Name = "Deysnc"
desyncButton.Size = UDim2.new(0, 120, 0, 50)
desyncButton.Position = UDim2.new(0, 10, 0.5, -25)
desyncButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255) -- Blue color
desyncButton.BackgroundTransparency = 0.4 -- 60% transparent
desyncButton.Text = "Deysnc"
desyncButton.TextColor3 = Color3.fromRGB(0, 0, 0) -- Black text
desyncButton.TextSize = 14
desyncButton.Font = Enum.Font.GothamBold
desyncButton.TextWrapped = true
desyncButton.Draggable = true -- Movable
desyncButton.Parent = screenGui

-- Button corner rounding
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 12)
buttonCorner.Parent = desyncButton

-- Button border line
local buttonStroke = Instance.new("UIStroke")
buttonStroke.Color = Color3.fromRGB(200, 230, 255)
buttonStroke.Thickness = 2
buttonStroke.Transparency = 0.3
buttonStroke.Parent = desyncButton

-- Button shadow
local buttonShadow = Instance.new("ImageLabel")
buttonShadow.Name = "Shadow"
buttonShadow.Size = UDim2.new(1, 10, 1, 10)
buttonShadow.Position = UDim2.new(0, -5, 0, -5)
buttonShadow.BackgroundTransparency = 1
buttonShadow.Image = "rbxassetid://1316045217"
buttonShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
buttonShadow.ImageTransparency = 0.8
buttonShadow.ScaleType = Enum.ScaleType.Slice
buttonShadow.SliceCenter = Rect.new(10, 10, 118, 118)
buttonShadow.Parent = desyncButton

-- Button hover effect
desyncButton.MouseEnter:Connect(function()
    TweenService:Create(desyncButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.2,
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
end)

desyncButton.MouseLeave:Connect(function()
    TweenService:Create(desyncButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.4,
        TextColor3 = Color3.fromRGB(0, 0, 0)
    }):Play()
end)

-- Button click effect
desyncButton.MouseButton1Down:Connect(function()
    TweenService:Create(desyncButton, TweenInfo.new(0.1), {
        Size = UDim2.new(0, 115, 0, 48)
    }):Play()
end)

desyncButton.MouseButton1Up:Connect(function()
    TweenService:Create(desyncButton, TweenInfo.new(0.1), {
        Size = UDim2.new(0, 120, 0, 50)
    }):Play()
end)

-- Button click function
desyncButton.MouseButton1Click:Connect(function()
    if antiHitRunning then
        -- If working, make button orange
        TweenService:Create(desyncButton, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        }):Play()
        desyncButton.Text = "Working..."
        showNotification("Please wait...", false)
        return
    end
    
    if antiHitActive then
        -- Turn off
        deactivateAdvancedDesync()
        TweenService:Create(desyncButton, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(0, 100, 255)
        }):Play()
        desyncButton.Text = "Deysnc"
    else
        -- Turn on
        executeAdvancedDesync()
        TweenService:Create(desyncButton, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        }):Play()
        desyncButton.Text = "Active"
    end
end)

-- Reset when character changes
player.CharacterAdded:Connect(function()
    task.delay(0.3, function()
        antiHitActive = false
        antiHitRunning = false
        clonerActive = false
        desyncRunning = false
        lockdownRunning = false
        
        TweenService:Create(desyncButton, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(0, 100, 255)
        }):Play()
        desyncButton.Text = "Deysnc"
        
        local clone = Workspace:FindFirstChild(tostring(player.UserId) .. "_Clone")
        if clone then
            pcall(function()
                removeInvulnerable(clone)
                clone:Destroy()
            end)
        end
        
        removeAllHighlights() -- Remove all green highlights
        
        showNotification("Character Reset", true)
    end)
end)

-- Initial state
desyncButton.Text = "Deysnc"

-- Startup message
task.wait(1)
showNotification("Desync System Loaded", true)

print("✅ Quantum Desync Button Loaded!")
print("🛡️ Anti-Hit System Ready")
print("💚 Green Highlight System Ready")
