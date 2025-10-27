-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Simple Notification
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

-- Quantum Cloner Desync System
local antiHitActive = false
local clonerActive = false
local desyncRunning = false
local cloneListenerConn
local antiHitRunning = false
local lockdownRunning = false
local lockdownConn = nil

local function safeDisconnectConn(conn)
    if conn and typeof(conn) == "RBXScriptConnection" then
        pcall(function()
            conn:Disconnect()
        end)
    end
end

local function makeInvulnerable(model)
    if not model or not model.Parent then return end
    
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    pcall(function()
        if not model:FindFirstChildOfClass("ForceField") then
            local ff = Instance.new("ForceField")
            ff.Visible = false
            ff.Parent = model
        end
    end)
end

local function removeInvulnerable(model)
    if not model then return end
    
    for _, ff in ipairs(model:GetChildren()) do
        if ff:IsA("ForceField") then
            pcall(function() ff:Destroy() end)
        end
    end
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

-- SIMPLIFIED LOCKDOWN SYSTEM
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

    -- Lock character movement
    local savedWalk = hum.WalkSpeed
    local savedJump = hum.JumpPower

    hum.WalkSpeed = 0
    hum.JumpPower = 0
    hum.PlatformStand = true

    local fixedCFrame = hrp.CFrame

    -- Clean old connection
    if lockdownConn then
        lockdownConn:Disconnect()
        lockdownConn = nil
    end

    -- Keep character in place
    lockdownConn = RunService.Heartbeat:Connect(function()
        if not hrp or not player.Character then
            return
        end
        pcall(function()
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
            hrp.CFrame = fixedCFrame
        end)
    end)

    showNotification("🛡️ Lockdown Active...", false)

    -- Remove lockdown after duration
    task.delay(duration, function()
        if lockdownConn then
            lockdownConn:Disconnect()
            lockdownConn = nil
        end

        if hum and hum.Parent then
            pcall(function()
                hum.WalkSpeed = savedWalk or 16
                hum.JumpPower = savedJump or 50
                hum.PlatformStand = false
            end)
        end

        lockdownRunning = false
        showNotification("✅ Desync Complete!", true)
        if onComplete then pcall(onComplete) end
    end)
end

local function activateClonerDesync(callback)
    if clonerActive then
        showNotification("⚠️ Already active", false)
        return
    end
    clonerActive = true

    -- Find Quantum Cloner tool
    local Backpack = player:FindFirstChildOfClass("Backpack")
    local character = player.Character
    
    if not Backpack then 
        showNotification("❌ No Backpack", false)
        clonerActive = false
        return 
    end
    
    local tool = Backpack:FindFirstChild("Quantum Cloner")
    if not tool then 
        showNotification("❌ No Quantum Cloner", false)
        clonerActive = false
        return 
    end
    
    -- Equip tool
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then 
        humanoid:EquipTool(tool)
        task.wait(0.5)
    end

    -- Find remotes
    local packages = ReplicatedStorage:FindFirstChild("Packages")
    if not packages then
        showNotification("❌ Packages not found", false)
        clonerActive = false
        return
    end
    
    local netFolder = packages:FindFirstChild("Net")
    if not netFolder then
        showNotification("❌ Net folder not found", false)
        clonerActive = false
        return
    end
    
    local REUseItem = netFolder:FindFirstChild("RE/UseItem")
    local REQuantumClonerOnTeleport = netFolder:FindFirstChild("RE/QuantumCloner/OnTeleport")
    
    if not REUseItem or not REQuantumClonerOnTeleport then
        showNotification("❌ Remotes not found", false)
        clonerActive = false
        return
    end

    -- Fire remotes
    REUseItem:FireServer()
    showNotification("⚡ Activating...", false)
    task.wait(0.2)
    REQuantumClonerOnTeleport:FireServer()

    local cloneName = tostring(player.UserId) .. "_Clone"
    
    -- Listen for clone creation
    cloneListenerConn = Workspace.ChildAdded:Connect(function(obj)
        if obj.Name == cloneName and obj:IsA("Model") then
            showNotification("🔮 Clone Created!", true)
            
            -- Make clone invulnerable
            pcall(function() 
                makeInvulnerable(obj)
            end)
            
            -- Make original character invulnerable
            local origChar = player.Character
            if origChar then 
                pcall(function() 
                    makeInvulnerable(origChar)
                end) 
            end
            
            -- Cleanup listener
            if cloneListenerConn then
                cloneListenerConn:Disconnect()
                cloneListenerConn = nil
            end

            -- 2 second lockdown
            performDesyncLockdown(2, function()
                clonerActive = false
                if callback then pcall(callback) end
            end)
        end
    end)

    -- 5 second timeout
    task.delay(5, function()
        if cloneListenerConn then
            cloneListenerConn:Disconnect()
            cloneListenerConn = nil
        end
        if not antiHitActive then
            showNotification("❌ Desync Failed", false)
        end
        clonerActive = false
        antiHitRunning = false
    end)
end

local function deactivateClonerDesync()
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
        showNotification("⏳ Please wait...", false)
        return 
    end
    antiHitRunning = true

    showNotification("🚀 Starting Desync...", false)
    
    activateDesync()
    task.wait(0.1)
    
    activateClonerDesync(function()
        deactivateDesync()
        antiHitRunning = false
        antiHitActive = true
        showNotification("✅ Desync Active!", true)
    end)
end

local function deactivateAdvancedDesync()
    antiHitRunning = false
    antiHitActive = false

    if cloneListenerConn then
        cloneListenerConn:Disconnect()
        cloneListenerConn = nil
    end

    deactivateClonerDesync()
    deactivateDesync()

    if player.Character then removeInvulnerable(player.Character) end

    local possibleClone = Workspace:FindFirstChild(tostring(player.UserId) .. "_Clone")
    if possibleClone then
        pcall(function()
            removeInvulnerable(possibleClone)
            possibleClone:Destroy()
        end)
    end
    
    showNotification("🔴 Desync Deactivated", false)
end

-- SMALL BUTTON (80x35)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "QuantumDesyncButton"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local desyncButton = Instance.new("TextButton")
desyncButton.Name = "DesyncButton"
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

-- Button styles
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = desyncButton

local buttonStroke = Instance.new("UIStroke")
buttonStroke.Color = Color3.fromRGB(200, 230, 255)
buttonStroke.Thickness = 1.5
buttonStroke.Parent = desyncButton

-- Button interactions
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

-- Fixed button click handler
desyncButton.MouseButton1Click:Connect(function()
    if antiHitRunning then
        showNotification("⏳ Please wait...", false)
        return
    end
    
    if antiHitActive then
        -- Deactivate desync
        antiHitRunning = true
        desyncButton.Text = "STOPPING"
        desyncButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        
        deactivateAdvancedDesync()
        
        task.wait(0.3)
        antiHitRunning = false
        desyncButton.Text = "DESYNC"
        desyncButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    else
        -- Activate desync
        antiHitRunning = true
        desyncButton.Text = "WORKING"
        desyncButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        executeAdvancedDesync()
        
        -- Update button if successful
        task.delay(3, function()
            if antiHitActive and antiHitRunning then
                antiHitRunning = false
                desyncButton.Text = "ACTIVE"
                desyncButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            elseif not antiHitActive and antiHitRunning then
                -- Failed - reset button
                antiHitRunning = false
                desyncButton.Text = "DESYNC"
                desyncButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
            end
        end)
    end
end)

-- Character reset
player.CharacterAdded:Connect(function()
    task.delay(1, function()
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

print("✅ Desync System Loaded!")
