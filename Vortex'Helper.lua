local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(c)
    character = c
    hrp = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
end)

-- Show a notification UI
local function showNotification(message)
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "VortexNotificationGUI"
    notificationGui.ResetOnSpawn = false
    notificationGui.Parent = CoreGui

    local notification = Instance.new("Frame")
    notification.Name = "VortexNotification"
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(0.5, -150, 0.2, 0)
    notification.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    notification.BackgroundTransparency = 0.1
    notification.BorderSizePixel = 0
    notification.ZIndex = 1000
    notification.Parent = notificationGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = notification

    local vortexLabel = Instance.new("TextLabel")
    vortexLabel.Text = "Vortex's Helper"
    vortexLabel.Size = UDim2.new(1, 0, 0, 20)
    vortexLabel.Position = UDim2.new(0, 0, 0, 5)
    vortexLabel.BackgroundTransparency = 1
    vortexLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
    vortexLabel.TextSize = 12
    vortexLabel.Font = Enum.Font.GothamBold
    vortexLabel.Parent = notification

    local notifText = Instance.new("TextLabel")
    notifText.Text = message
    notifText.Size = UDim2.new(1, -20, 0, 40)
    notifText.Position = UDim2.new(0, 10, 0, 25)
    notifText.BackgroundTransparency = 1
    notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifText.TextSize = 14
    notifText.Font = Enum.Font.GothamBold
    notifText.TextWrapped = true
    notifText.Parent = notification

    -- Tween animation for notifications
    local tweenIn = TweenService:Create(notification, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -150, 0.3, 0)})
    tweenIn:Play()
    tweenIn.Completed:Connect(function()
        wait(2)
        local tweenOut = TweenService:Create(notification, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -150, 0.2, 0), BackgroundTransparency = 1})
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            notificationGui:Destroy()
        end)
    end)
end

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "VortexHelper"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 180, 0, 80)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
frame.Active = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", frame)
title.Text = "Vortex's Helper"
title.Size = UDim2.new(1, 0, 0, 20)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(0, 150, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.ZIndex = 2

local tweenButton = Instance.new("TextButton", frame)
tweenButton.Text = "▶ START"
tweenButton.Size = UDim2.new(0.9, 0, 0, 30)
tweenButton.Position = UDim2.new(0.05, 0, 0.35, 0)
tweenButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
tweenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tweenButton.Font = Enum.Font.GothamBold
tweenButton.TextSize = 14
tweenButton.ZIndex = 2
Instance.new("UICorner", tweenButton).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Text = "Status: Idle"
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0.75, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10
statusLabel.ZIndex = 2

-- Drag GUI
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Anti Death
local function applyAntiDeath(state)
    if humanoid then
        for _, s in pairs({
            Enum.HumanoidStateType.FallingDown,
            Enum.HumanoidStateType.Ragdoll,
            Enum.HumanoidStateType.PlatformStanding,
            Enum.HumanoidStateType.Seated
        }) do
            humanoid:SetStateEnabled(s, not state)
        end
        if state then
            humanoid.Health = humanoid.MaxHealth
            humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                if humanoid.Health <= 0 then
                    humanoid.Health = humanoid.MaxHealth
                end
            end)
        end
    end
end

-- Base position bulma
local function getBasePosition()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    for _, plot in ipairs(plots:GetChildren()) do
        local sign = plot:FindFirstChild("PlotSign")
        local base = plot:FindFirstChild("DeliveryHitbox")
        if sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled and base then
            return base.Position
        end
    end
    return nil
end

local Y_OFFSET = 3
local STOP_DISTANCE = 10
local tweenSpeed = 24

local currentTween
local function tweenWalkTo(position)
    if currentTween then 
        currentTween:Cancel() 
        currentTween = nil
    end

    local startPos = hrp.Position
    local targetPos = Vector3.new(position.X, position.Y + Y_OFFSET, position.Z)
    local distance = (targetPos - startPos).Magnitude
    local speed = math.max(tweenSpeed, 16)
    local duration = distance / speed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)

    currentTween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
    currentTween:Play()

    humanoid:ChangeState(Enum.HumanoidStateType.Running)

    currentTween.Completed:Wait()
    currentTween = nil
end

local active = false
local walkThread

local function isAtBase(basePos)
    if not basePos or not hrp then return false end
    local dist = (hrp.Position - Vector3.new(basePos.X, basePos.Y + Y_OFFSET, basePos.Z)).Magnitude
    return dist <= STOP_DISTANCE
end

local function checkIfAtBase(basePos)
    while active and basePos do
        if isAtBase(basePos) then
            statusLabel.Text = "Status: Reached Base"
            showNotification("Base'e ulaşıldı!")
            stopTweenToBase()
            break
        end
        task.wait(0.1)
    end
end

local function walkToBase()
    local target = getBasePosition()
    if not target then
        statusLabel.Text = "Status: Base Not Found"
        showNotification("Base bulunamadı!")
        return
    end

    task.spawn(checkIfAtBase, target)
    
    while active do
        if not target then
            statusLabel.Text = "Status: Base Not Found"
            showNotification("Base bulunamadı!")
            task.wait(1)
            break
        end

        if isAtBase(target) then
            statusLabel.Text = "Status: Reached Base"
            showNotification("Base'e ulaşıldı!")
            stopTweenToBase()
            break
        end

        local path = PathfindingService:CreatePath()
        local success, err = pcall(function()
            path:ComputeAsync(hrp.Position, target)
        end)
        
        if not success then
            tweenWalkTo(target)
            break
        end

        if path.Status == Enum.PathStatus.Success then
            local waypoints = path:GetWaypoints()
            for i, waypoint in ipairs(waypoints) do
                if not active or isAtBase(target) then 
                    return 
                end
                
                if i == 1 and (waypoint.Position - hrp.Position).Magnitude < 2 then
                    continue
                end
                
                tweenWalkTo(waypoint.Position)
            end
        else
            tweenWalkTo(target)
        end

        task.wait(0.1)
    end
end

function startTweenToBase()
    if active then return end
    
    active = true
    applyAntiDeath(true)
    humanoid.WalkSpeed = tweenSpeed
    statusLabel.Text = "Status: Walking to Base..."
    tweenButton.Text = "■ STOP"
    showNotification("Base'e gidiliyor...")

    walkThread = task.spawn(function()
        while active do
            walkToBase()
            if not active then break end
            task.wait(0.5)
        end
    end)
end

function stopTweenToBase()
    if not active then return end
    active = false
    if currentTween then 
        currentTween:Cancel() 
        currentTween = nil
    end
    if walkThread then 
        task.cancel(walkThread) 
        walkThread = nil
    end
    humanoid.WalkSpeed = 16
    statusLabel.Text = "Status: Stopped"
    tweenButton.Text = "▶ START"
    showNotification("Yürüme durduruldu")
    
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

-- Buton tıklama
tweenButton.MouseButton1Click:Connect(function()
    if active then
        stopTweenToBase()
    else
        startTweenToBase()
    end
end)

-- Clean up
gui.Destroying:Connect(function()
    stopTweenToBase()
end)

-- Açılış bildirimi
showNotification("Vortex's Helper Aktif!")
