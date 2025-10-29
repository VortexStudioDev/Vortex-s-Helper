-- Vortex Hub - Clean & Working Edition
-- Features: Inf Jump (19 limit), FLY TO BASE, ESP Base, ESP Best, ESP Player

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

----------------------------------------------------------------
-- NOTIFICATION SYSTEM
----------------------------------------------------------------
local function showNotification(message, isSuccess)
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "VortexNotify"
    notificationGui.ResetOnSpawn = false
    notificationGui.Parent = playerGui
    
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

----------------------------------------------------------------
-- INF JUMP / JUMP BOOST (19 LIMIT - SAFE)
----------------------------------------------------------------
local NORMAL_GRAV = 196.2
local REDUCED_GRAV = 60
local NORMAL_JUMP = 50
local BOOST_JUMP = 19

local gravityLow = false
local speedBoostConn
local infiniteJumpConn

local function setJumpPower(jump)
    local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if h then
        h.JumpPower = jump
    end
end

local function enableSpeedBoost(state)
    if speedBoostConn then
        speedBoostConn:Disconnect()
        speedBoostConn = nil
    end
    if state then
        speedBoostConn = RunService.Heartbeat:Connect(function()
            local char = player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                local h = char:FindFirstChildOfClass("Humanoid")
                if root and h and h.MoveDirection.Magnitude > 0 then
                    root.Velocity = Vector3.new(
                        h.MoveDirection.X * 25,
                        root.Velocity.Y,
                        h.MoveDirection.Z * 25
                    )
                end
            end
        end)
    end
end

local function enableInfiniteJump(state)
    if infiniteJumpConn then
        infiniteJumpConn:Disconnect()
        infiniteJumpConn = nil
    end
    if state then
        infiniteJumpConn = UserInputService.JumpRequest:Connect(function()
            local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if h and gravityLow and h:GetState() ~= Enum.HumanoidStateType.Seated then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Velocity = Vector3.new(root.Velocity.X, h.JumpPower, root.Velocity.Z)
                end
            end
        end)
    end
end

local function switchGravityJump()
    gravityLow = not gravityLow
    
    if gravityLow then
        Workspace.Gravity = REDUCED_GRAV
        setJumpPower(BOOST_JUMP)
        enableSpeedBoost(true)
        enableInfiniteJump(true)
        showNotification("Inf Jump ON", true)
    else
        Workspace.Gravity = NORMAL_GRAV
        setJumpPower(NORMAL_JUMP)
        enableSpeedBoost(false)
        enableInfiniteJump(false)
        showNotification("Inf Jump OFF", false)
    end
end

----------------------------------------------------------------
-- FLY TO BASE (SAFE)
----------------------------------------------------------------
local flyActive = false
local flyConn

local function findMyDeliveryPart()
    local plots = Workspace:FindFirstChild("Plots")
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled then
                local delivery = plot:FindFirstChild("DeliveryHitbox")
                if delivery and delivery:IsA("BasePart") then
                    return delivery
                end
            end
        end
    end
    return nil
end

local function startFlyToBase()
    if flyActive then
        if flyConn then
            flyConn:Disconnect()
            flyConn = nil
        end
        Workspace.Gravity = gravityLow and REDUCED_GRAV or NORMAL_GRAV
        flyActive = false
        showNotification("Fly to Base OFF", false)
        return
    end

    local destPart = findMyDeliveryPart()
    if not destPart then
        showNotification("Base not found!", false)
        return
    end

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not (hum and hrp) then return end

    Workspace.Gravity = 0
    flyActive = true

    flyConn = RunService.Heartbeat:Connect(function()
        if not flyActive then return end
        
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local pos = hrp.Position
        local destPos = destPart.Position
        local direction = (destPos - pos).Unit
        
        hrp.Velocity = direction * 50
        
        if (pos - destPos).Magnitude < 10 then
            startFlyToBase()
            showNotification("Base reached!", true)
        end
    end)

    showNotification("Fly to Base ON!", true)
end

----------------------------------------------------------------
-- ESP SYSTEMS (SAFE)
----------------------------------------------------------------
local espBaseActive = false
local espBestActive = false
local espPlayerActive = false
local espObjects = {}

-- ESP Base
local function updateBaseESP()
    if not espBaseActive then 
        for _, obj in pairs(espObjects) do
            pcall(function() obj:Destroy() end)
        end
        espObjects = {}
        return 
    end
    
    for _, obj in pairs(espObjects) do
        pcall(function() obj:Destroy() end)
    end
    espObjects = {}
    
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return end

    local myPlotName
    for _, plot in pairs(plots:GetChildren()) do
        local plotSign = plot:FindFirstChild("PlotSign")
        if plotSign and plotSign:FindFirstChild("YourBase") and plotSign.YourBase.Enabled then
            myPlotName = plot.Name
            break
        end
    end

    if not myPlotName then return end

    for _, plot in pairs(plots:GetChildren()) do
        if plot.Name ~= myPlotName then
            local purchases = plot:FindFirstChild("Purchases")
            local pb = purchases and purchases:FindFirstChild("PlotBlock")
            local main = pb and pb:FindFirstChild("Main")
            
            if main then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "Base_ESP"
                billboard.Size = UDim2.new(0, 140, 0, 36)
                billboard.StudsOffset = Vector3.new(0, 5, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = main

                local label = Instance.new("TextLabel")
                label.Text = "BASE"
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextScaled = true
                label.TextColor3 = Color3.fromRGB(220, 0, 60)
                label.Font = Enum.Font.Arcade
                label.TextStrokeTransparency = 0.5
                label.TextStrokeColor3 = Color3.new(0, 0, 0)
                label.Parent = billboard

                table.insert(espObjects, billboard)
            end
        end
    end
end

-- ESP Best
local function updateBestESP()
    if not espBestActive then 
        for _, obj in pairs(espObjects) do
            if obj.Name == "Best_ESP" then
                pcall(function() obj:Destroy() end)
            end
        end
        return 
    end

    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return end

    for _, plot in ipairs(plots:GetChildren()) do
        for _, pet in ipairs(plot:GetDescendants()) do
            if pet:IsA("Model") and pet:FindFirstChild("Head") then
                local displayName = pet:FindFirstChild("DisplayName")
                if displayName and displayName:IsA("TextLabel") then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "Best_ESP"
                    billboard.Size = UDim2.new(0, 200, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 4, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = pet
                    
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = "BEST PET"
                    label.TextColor3 = Color3.fromRGB(255, 255, 0)
                    label.Font = Enum.Font.GothamBold
                    label.TextSize = 14
                    label.TextStrokeTransparency = 0
                    label.Parent = billboard

                    table.insert(espObjects, billboard)
                    break
                end
            end
        end
    end
end

-- ESP Player
local function updatePlayerESP()
    if not espPlayerActive then
        for _, obj in pairs(espObjects) do
            if obj.Name == "Player_ESP" then
                pcall(function() obj:Destroy() end)
            end
        end
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "Player_ESP"
            billboard.Adornee = hrp
            billboard.Size = UDim2.new(0, 200, 0, 30)
            billboard.StudsOffset = Vector3.new(0, 4, 0)
            billboard.AlwaysOnTop = true
            
            local label = Instance.new("TextLabel", billboard)
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(255, 0, 0)
            label.TextStrokeTransparency = 0
            label.Text = plr.Name
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            billboard.Parent = hrp

            table.insert(espObjects, billboard)
        end
    end
end

-- ESP Toggle Functions
local function toggleBaseESP()
    espBaseActive = not espBaseActive
    if espBaseActive then
        showNotification("ESP Base ON", true)
    else
        showNotification("ESP Base OFF", false)
    end
    updateBaseESP()
end

local function toggleBestESP()
    espBestActive = not espBestActive
    if espBestActive then
        showNotification("ESP Best ON", true)
    else
        showNotification("ESP Best OFF", false)
    end
    updateBestESP()
end

local function togglePlayerESP()
    espPlayerActive = not espPlayerActive
    if espPlayerActive then
        showNotification("ESP Player ON", true)
    else
        showNotification("ESP Player OFF", false)
    end
    updatePlayerESP()
end

----------------------------------------------------------------
-- GUI CREATION (CLEAN & WORKING)
----------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "VortexHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- V Logo (Toggle Button)
local logoButton = Instance.new("TextButton")
logoButton.Name = "VortexLogo"
logoButton.Size = UDim2.new(0, 40, 0, 40)
logoButton.Position = UDim2.new(0, 20, 0, 20)
logoButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
logoButton.Text = "V"
logoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
logoButton.TextSize = 18
logoButton.Font = Enum.Font.GothamBlack
logoButton.AutoButtonColor = false
logoButton.ZIndex = 1000
logoButton.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = logoButton

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(200, 230, 255)
stroke.Thickness = 2
stroke.Parent = logoButton

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 160, 0, 200)
mainFrame.Position = UDim2.new(0.5, -80, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.ZIndex = 999
mainFrame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(80, 160, 255)
frameStroke.Thickness = 2
frameStroke.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
header.BackgroundTransparency = 0.1
header.BorderSizePixel = 0
header.ZIndex = 1000
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "VORTEX HUB"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Center
title.ZIndex = 1001
title.Parent = header

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 1001
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- Content area
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -10, 1, -40)
contentFrame.Position = UDim2.new(0, 5, 0, 35)
contentFrame.BackgroundTransparency = 1
contentFrame.ZIndex = 1000
contentFrame.Parent = mainFrame

-- Button Creation Function
local function createButton(parent, text, yPos, active, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = active and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 100)
    btn.Text = text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ZIndex = 1001
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(255, 255, 255)
    btnStroke.Transparency = 0.7
    btnStroke.Thickness = 1
    btnStroke.Parent = btn
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = active and Color3.fromRGB(0, 180, 20) or Color3.fromRGB(100, 100, 120)
    end)
    
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = active and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 100)
    end)
    
    btn.MouseButton1Click:Connect(callback)
    
    return btn
end

-- Create Buttons
local yPos = 0
createButton(contentFrame, "🦘 Inf Jump " .. (gravityLow and "ON" or "OFF"), yPos, gravityLow, switchGravityJump)
yPos = yPos + 35
createButton(contentFrame, "🚀 Fly to Base", yPos, flyActive, startFlyToBase)
yPos = yPos + 35
createButton(contentFrame, "🏠 ESP Base " .. (espBaseActive and "ON" or "OFF"), yPos, espBaseActive, toggleBaseESP)
yPos = yPos + 35
createButton(contentFrame, "🔥 ESP Best " .. (espBestActive and "ON" or "OFF"), yPos, espBestActive, toggleBestESP)
yPos = yPos + 35
createButton(contentFrame, "👥 ESP Player " .. (espPlayerActive and "ON" or "OFF"), yPos, espPlayerActive, togglePlayerESP)

-- Logo button hover
logoButton.MouseEnter:Connect(function()
    logoButton.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
end)

logoButton.MouseLeave:Connect(function()
    logoButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
end)

-- Close button hover
closeBtn.MouseEnter:Connect(function()
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
end)

closeBtn.MouseLeave:Connect(function()
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
end)

-- Frame toggle
local frameOpen = false

logoButton.MouseButton1Click:Connect(function()
    frameOpen = not frameOpen
    mainFrame.Visible = frameOpen
end)

closeBtn.MouseButton1Click:Connect(function()
    frameOpen = false
    mainFrame.Visible = false
end)

-- Make logo draggable
local dragging = false
local dragInput, dragStart, startPos

logoButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = logoButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

logoButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        logoButton.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ESP Update Loop
task.spawn(function()
    while true do
        updateBaseESP()
        updateBestESP()
        updatePlayerESP()
        task.wait(1)
    end
end)

showNotification("🚀 Vortex Hub Loaded!", true)

print("✅ Vortex Hub Activated!")
print("🦘 Inf Jump: Ready (19 Limit)")
print("🚀 Fly to Base: Ready") 
print("🏠 ESP Base: " .. (espBaseActive and "ON" or "OFF"))
print("🔥 ESP Best: " .. (espBestActive and "ON" or "OFF"))
print("👥 ESP Player: " .. (espPlayerActive and "ON" or "OFF"))
