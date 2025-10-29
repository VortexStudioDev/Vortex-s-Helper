-- Vortex Hub - Ultimate Edition
-- Features: Inf Jump, FLY TO BASE, Auto Laser, ESP Base, ESP Best, ESP Player, Steal Floor
-- Tab System: Tab 1 (Movement), Tab 2 (Visual)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
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
-- INF JUMP / JUMP BOOST
----------------------------------------------------------------
local NORMAL_GRAV = 196.2
local REDUCED_GRAV = 60
local NORMAL_JUMP = 50
local BOOST_JUMP = 75

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
                        h.MoveDirection.X * 28,
                        root.Velocity.Y,
                        h.MoveDirection.Z * 28
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
        showNotification("Inf Jump ON 🦘", true)
    else
        Workspace.Gravity = NORMAL_GRAV
        setJumpPower(NORMAL_JUMP)
        enableSpeedBoost(false)
        enableInfiniteJump(false)
        showNotification("Inf Jump OFF", false)
    end
end

----------------------------------------------------------------
-- FLY TO BASE (ORIGINAL VERSION)
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

    local startGravity = Workspace.Gravity
    Workspace.Gravity = 0
    flyActive = true

    flyConn = RunService.Heartbeat:Connect(function()
        if not flyActive or not player.Character then 
            if flyConn then flyConn:Disconnect() end
            return 
        end
        
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local pos = hrp.Position
        local destPos = destPart.Position
        local direction = (destPos - pos).Unit
        
        -- Original hız - hızlanma yok
        hrp.Velocity = direction * 50
        
        if (pos - destPos).Magnitude < 8 then
            Workspace.Gravity = startGravity
            flyActive = false
            if flyConn then flyConn:Disconnect() end
            showNotification("🏠 Base reached!", true)
        end
    end)

    showNotification("Fly to Base ON! 🚀", true)
end

----------------------------------------------------------------
-- AUTO LASER
----------------------------------------------------------------
local autoLaserEnabled = false
local autoLaserThread = nil

local blacklistNames = {"gametesterbrow"}
local blacklist = {}
for _, name in ipairs(blacklistNames) do
    blacklist[string.lower(name)] = true
end

local function getLaserRemote()
    local remote = nil
    pcall(function()
        if ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Net") then
            remote = ReplicatedStorage.Packages.Net:FindFirstChild("RE/UseItem") or ReplicatedStorage.Packages.Net:FindFirstChild("RE"):FindFirstChild("UseItem")
        end
        if not remote then
            remote = ReplicatedStorage:FindFirstChild("RE/UseItem") or ReplicatedStorage:FindFirstChild("UseItem")
        end
    end)
    return remote
end

local function isValidTarget(targetPlayer)
    if not targetPlayer or not targetPlayer.Character or targetPlayer == player then return false end
    local name = targetPlayer.Name and string.lower(targetPlayer.Name) or ""
    if blacklist[name] then return false end
    local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return false end
    return humanoid.Health > 0
end

local function findNearestAllowed()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = player.Character.HumanoidRootPart.Position
    local nearest = nil
    local nearestDist = math.huge
    for _, pl in ipairs(Players:GetPlayers()) do
        if isValidTarget(pl) then
            local targetHRP = pl.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local d = (targetHRP.Position - myPos).Magnitude
                if d < nearestDist then
                    nearestDist = d
                    nearest = pl
                end
            end
        end
    end
    return nearest
end

local function safeFire(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
    local remote = getLaserRemote()
    if remote and remote.FireServer then
        pcall(function()
            remote:FireServer(targetHRP.Position, targetHRP)
        end)
    end
end

local function autoLaserWorker()
    while autoLaserEnabled do
        local target = findNearestAllowed()
        if target then
            safeFire(target)
        end
        local t0 = tick()
        while tick() - t0 < 0.6 do
            if not autoLaserEnabled then break end
            RunService.Heartbeat:Wait()
        end
    end
end

local function toggleAutoLaser()
    autoLaserEnabled = not autoLaserEnabled
    if autoLaserEnabled then
        showNotification("Auto Laser ON 🔫", true)
        if autoLaserThread then
            task.cancel(autoLaserThread)
        end
        autoLaserThread = task.spawn(autoLaserWorker)
    else
        showNotification("Auto Laser OFF", false)
        if autoLaserThread then
            task.cancel(autoLaserThread)
            autoLaserThread = nil
        end
    end
end

----------------------------------------------------------------
-- STEAL FLOOR
----------------------------------------------------------------
local stealFloorActive = false
local stealFloorConn

local function teleportToGround()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum and hum.Health > 0) then
        return
    end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { char }

    local rayResult = Workspace:Raycast(hrp.Position, Vector3.new(0, -1500, 0), rayParams)
    if rayResult then
        hrp.CFrame = CFrame.new(
            hrp.Position.X,
            rayResult.Position.Y + hum.HipHeight,
            hrp.Position.Z
        )
    end
end

local function toggleStealFloor()
    stealFloorActive = not stealFloorActive
    
    if stealFloorActive then
        showNotification("Steal Floor ON 🏗️", true)
        
        if stealFloorConn then
            stealFloorConn:Disconnect()
        end
        
        stealFloorConn = ProximityPromptService.PromptTriggered:Connect(function(prompt, who)
            if who == player then
                local act = (prompt.ActionText or ""):lower()
                if string.find(act, "steal") then
                    teleportToGround()
                end
            end
        end)
    else
        showNotification("Steal Floor OFF", false)
        if stealFloorConn then
            stealFloorConn:Disconnect()
            stealFloorConn = nil
        end
    end
end

----------------------------------------------------------------
-- ESP SYSTEMS
----------------------------------------------------------------
local espBaseActive = false
local espBestActive = false
local espPlayerActive = false
local espObjects = {}

-- ESP Base
local function updateBaseESP()
    if not espBaseActive then 
        for _, obj in pairs(espObjects) do
            if obj.Name == "Base_ESP" then
                pcall(function() obj:Destroy() end)
            end
        end
        return 
    end
    
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
            
            if main and not main:FindFirstChild("Base_ESP") then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "Base_ESP"
                billboard.Size = UDim2.new(0, 160, 0, 40)
                billboard.StudsOffset = Vector3.new(0, 6, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = main

                local label = Instance.new("TextLabel")
                label.Text = "🏠 ENEMY BASE"
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextScaled = true
                label.TextColor3 = Color3.fromRGB(255, 50, 50)
                label.Font = Enum.Font.GothamBold
                label.TextStrokeTransparency = 0.3
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
                    if not pet:FindFirstChild("Best_ESP") then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "Best_ESP"
                        billboard.Size = UDim2.new(0, 200, 0, 60)
                        billboard.StudsOffset = Vector3.new(0, 5, 0)
                        billboard.AlwaysOnTop = true
                        billboard.Parent = pet
                        
                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.Text = "🔥 BEST PET\n💎 HIGH VALUE"
                        label.TextColor3 = Color3.fromRGB(255, 215, 0)
                        label.Font = Enum.Font.GothamBold
                        label.TextSize = 12
                        label.TextStrokeTransparency = 0
                        label.Parent = billboard

                        table.insert(espObjects, billboard)
                    end
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
            
            if not hrp:FindFirstChild("Player_ESP") then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "Player_ESP"
                billboard.Adornee = hrp
                billboard.Size = UDim2.new(0, 200, 0, 40)
                billboard.StudsOffset = Vector3.new(0, 5, 0)
                billboard.AlwaysOnTop = true
                
                local label = Instance.new("TextLabel", billboard)
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.fromRGB(255, 0, 0)
                label.TextStrokeTransparency = 0.2
                label.Text = "👤 " .. plr.Name
                label.Font = Enum.Font.GothamBold
                label.TextSize = 12
                billboard.Parent = hrp

                table.insert(espObjects, billboard)
            end
        end
    end
end

-- ESP Toggle Functions
local function toggleBaseESP()
    espBaseActive = not espBaseActive
    showNotification("ESP Base " .. (espBaseActive and "ON 🏠" or "OFF"), espBaseActive)
    updateBaseESP()
end

local function toggleBestESP()
    espBestActive = not espBestActive
    showNotification("ESP Best " .. (espBestActive and "ON 🔥" or "OFF"), espBestActive)
    updateBestESP()
end

local function togglePlayerESP()
    espPlayerActive = not espPlayerActive
    showNotification("ESP Player " .. (espPlayerActive and "ON 👥" or "OFF"), espPlayerActive)
    updatePlayerESP()
end

----------------------------------------------------------------
-- GUI CREATION
----------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "VortexHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- V Logo (Toggle Button)
local logoButton = Instance.new("TextButton")
logoButton.Name = "VortexLogo"
logoButton.Size = UDim2.new(0, 45, 0, 45)
logoButton.Position = UDim2.new(0, 15, 0, 15)
logoButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
logoButton.Text = "V"
logoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
logoButton.TextSize = 20
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
mainFrame.Size = UDim2.new(0, 180, 0, 250)
mainFrame.Position = UDim2.new(0.5, -90, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.05
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

-- Header with Tabs
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
header.BackgroundTransparency = 0.1
header.BorderSizePixel = 0
header.ZIndex = 1000
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

-- Tab Buttons
local tab1Btn = Instance.new("TextButton")
tab1Btn.Name = "Tab1"
tab1Btn.Size = UDim2.new(0.5, -5, 0, 25)
tab1Btn.Position = UDim2.new(0, 5, 0, 5)
tab1Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
tab1Btn.Text = "MOVEMENT"
tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
tab1Btn.TextSize = 11
tab1Btn.Font = Enum.Font.GothamBold
tab1Btn.AutoButtonColor = false
tab1Btn.ZIndex = 1001
tab1Btn.Parent = header

local tab2Btn = Instance.new("TextButton")
tab2Btn.Name = "Tab2"
tab2Btn.Size = UDim2.new(0.5, -5, 0, 25)
tab2Btn.Position = UDim2.new(0.5, 0, 0, 5)
tab2Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
tab2Btn.Text = "VISUAL"
tab2Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
tab2Btn.TextSize = 11
tab2Btn.Font = Enum.Font.GothamBold
tab2Btn.AutoButtonColor = false
tab2Btn.ZIndex = 1001
tab2Btn.Parent = header

local tab1Corner = Instance.new("UICorner")
tab1Corner.CornerRadius = UDim.new(0, 6)
tab1Corner.Parent = tab1Btn

local tab2Corner = Instance.new("UICorner")
tab2Corner.CornerRadius = UDim.new(0, 6)
tab2Corner.Parent = tab2Btn

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
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

-- Tab Content Frames
local contentTab1 = Instance.new("Frame")
contentTab1.Name = "Tab1Content"
contentTab1.Size = UDim2.new(1, -10, 1, -45)
contentTab1.Position = UDim2.new(0, 5, 0, 40)
contentTab1.BackgroundTransparency = 1
contentTab1.ZIndex = 1000
contentTab1.Visible = true
contentTab1.Parent = mainFrame

local contentTab2 = Instance.new("Frame")
contentTab2.Name = "Tab2Content"
contentTab2.Size = UDim2.new(1, -10, 1, -45)
contentTab2.Position = UDim2.new(0, 5, 0, 40)
contentTab2.BackgroundTransparency = 1
contentTab2.ZIndex = 1000
contentTab2.Visible = false
contentTab2.Parent = mainFrame

-- Button Creation Function
local function createButton(parent, text, yPos, active, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = active and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 100)
    btn.Text = text .. (active and " ON" or " OFF")
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
    
    btn.MouseButton1Click:Connect(function()
        callback()
        task.wait(0.1)
        local newState = not active
        btn.BackgroundColor3 = newState and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 100)
        btn.Text = text .. (newState and " ON" or " OFF")
    end)
    
    return btn
end

-- Tab 1 Buttons (Movement)
local yPos1 = 0
createButton(contentTab1, "🦘 Inf Jump", yPos1, gravityLow, switchGravityJump)
yPos1 = yPos1 + 35
createButton(contentTab1, "🚀 Fly to Base", yPos1, flyActive, startFlyToBase)
yPos1 = yPos1 + 35
createButton(contentTab1, "🔫 Auto Laser", yPos1, autoLaserEnabled, toggleAutoLaser)
yPos1 = yPos1 + 35
createButton(contentTab1, "🏗️ Steal Floor", yPos1, stealFloorActive, toggleStealFloor)

-- Tab 2 Buttons (Visual)
local yPos2 = 0
createButton(contentTab2, "🏠 ESP Base", yPos2, espBaseActive, toggleBaseESP)
yPos2 = yPos2 + 35
createButton(contentTab2, "🔥 ESP Best", yPos2, espBestActive, toggleBestESP)
yPos2 = yPos2 + 35
createButton(contentTab2, "👥 ESP Player", yPos2, espPlayerActive, togglePlayerESP)

-- Tab Switching Function
local currentTab = 1

local function switchTab(tabNumber)
    currentTab = tabNumber
    
    if tabNumber == 1 then
        contentTab1.Visible = true
        contentTab2.Visible = false
        tab1Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tab2Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        tab2Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    else
        contentTab1.Visible = false
        contentTab2.Visible = true
        tab1Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        tab1Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        tab2Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        tab2Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

-- Tab Button Events
tab1Btn.MouseButton1Click:Connect(function() switchTab(1) end)
tab2Btn.MouseButton1Click:Connect(function() switchTab(2) end)

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
print("🦘 Inf Jump: Ready")
print("🚀 Fly to Base: Ready (Original Version)")
print("🔫 Auto Laser: Ready")
print("🏗️ Steal Floor: Ready")
print("🏠 ESP Base: " .. (espBaseActive and "ON" or "OFF"))
print("🔥 ESP Best: " .. (espBestActive and "ON" or "OFF"))
print("👥 ESP Player: " .. (espPlayerActive and "ON" or "OFF"))
