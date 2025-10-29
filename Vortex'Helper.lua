-- Vortex Hub - Clean Edition
-- Features: Inf Jump (19 limit), FLY TO BASE, ESP Base, ESP Best, ESP Player, Auto Laser

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

----------------------------------------------------------------
-- NOTIFICATION SYSTEM
----------------------------------------------------------------
local function showNotification(message, isSuccess)
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "VortexNotify"
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

----------------------------------------------------------------
-- INF JUMP / JUMP BOOST (19 LIMIT)
----------------------------------------------------------------
local NORMAL_GRAV = 196.2
local REDUCED_GRAV = 40
local NORMAL_JUMP = 50
local BOOST_JUMP = 19
local BOOST_SPEED = 32

local gravityLow = false

local function setJumpPower(jump)
    local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if h then
        h.JumpPower = jump
        h.UseJumpPower = true
    end
end

local speedBoostConn
local function enableSpeedBoostAssembly(state)
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
                        h.MoveDirection.X * BOOST_SPEED,
                        root.Velocity.Y,
                        h.MoveDirection.Z * BOOST_SPEED
                    )
                end
            end
        end)
    end
end

local infiniteJumpConn
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
    Workspace.Gravity = gravityLow and REDUCED_GRAV or NORMAL_GRAV
    setJumpPower(gravityLow and BOOST_JUMP or NORMAL_JUMP)
    enableSpeedBoostAssembly(gravityLow)
    enableInfiniteJump(gravityLow)
    showNotification("Inf Jump " .. (gravityLow and "ON" or "OFF"), gravityLow)
end

----------------------------------------------------------------
-- FLY TO BASE
----------------------------------------------------------------
local flyActive = false
local flyConn, flyAtt, flyLV

local function clearFlyConnections()
    if flyConn then pcall(function() flyConn:Disconnect() end) flyConn = nil end
end

local function destroyFlyBodies()
    if flyLV then pcall(function() flyLV:Destroy() end) flyLV = nil end
    if flyAtt then pcall(function() flyAtt:Destroy() end) flyAtt = nil end
end

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
        clearFlyConnections()
        destroyFlyBodies()
        Workspace.Gravity = gravityLow and REDUCED_GRAV or NORMAL_GRAV
        flyActive = false
        showNotification("Fly to Base OFF", false)
        return
    end

    local destPart = findMyDeliveryPart()
    if not destPart then
        showNotification("Delivery not found!", false)
        return
    end

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not (hum and hrp) then return end

    Workspace.Gravity = 20
    hum.UseJumpPower = true
    hum.JumpPower = 7
    flyActive = true

    flyAtt = Instance.new("Attachment")
    flyAtt.Name = "FlyToBaseAttachment"
    flyAtt.Parent = hrp

    flyLV = Instance.new("LinearVelocity")
    flyLV.Attachment0 = flyAtt
    flyLV.RelativeTo = Enum.ActuatorRelativeTo.World
    flyLV.MaxForce = math.huge
    flyLV.Parent = hrp

    flyConn = RunService.Heartbeat:Connect(function()
        if not flyActive then return end
        local pos = hrp.Position
        local destPos = destPart.Position
        local dir = (destPos - pos).Unit
        flyLV.VectorVelocity = dir * 22
        if (pos - destPos).Magnitude < 10 then
            startFlyToBase()
            showNotification("Base Reached!", true)
        end
    end)

    showNotification("Fly to Base ON!", true)
end

----------------------------------------------------------------
-- ESP SYSTEMS
----------------------------------------------------------------
local espBaseActive = false
local espBestActive = false
local espPlayerActive = false
local espObjects = {}
local playerEspBoxes = {}

-- ESP Base
local function updateBaseESP()
    if not espBaseActive then return end
    
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
            local gui = main and main:FindFirstChild("BillboardGui")
            local timeLb = gui and gui:FindFirstChild("RemainingTime")
            
            if timeLb and main then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "Base_ESP"
                billboard.Size = UDim2.new(0, 140, 0, 36)
                billboard.StudsOffset = Vector3.new(0, 5, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = main

                local label = Instance.new("TextLabel")
                label.Text = timeLb.Text
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
local function parseMoneyPerSec(text)
    if not text then return 0 end
    local mult = 1
    local numberStr = text:match('[%d%.]+')
    if not numberStr then return 0 end
    if text:find("K") then mult = 1_000
    elseif text:find("M") then mult = 1_000_000
    elseif text:find("B") then mult = 1_000_000_000
    elseif text:find("T") then mult = 1_000_000_000_000
    elseif text:find("Q") then mult = 1_000_000_000_000_000 end
    return (tonumber(numberStr) or 0) * mult
end

local function updateBestESP()
    if not espBestActive then return end
    
    for _, plot in ipairs(Workspace:GetChildren()) do
        if plot:IsA("Model") then
            for _, inst in ipairs(plot:GetDescendants()) do
                if inst:IsA("BillboardGui") and inst.Name == "Best_ESP" then
                    pcall(function() inst:Destroy() end)
                end
            end
        end
    end

    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return end

    local bestPetInfo = nil
    for _, plot in ipairs(plots:GetChildren()) do
        for _, desc in ipairs(plot:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Name == "Rarity" and desc.Parent and desc.Parent:FindFirstChild("DisplayName") then
                local parentModel = desc.Parent.Parent
                local genLabel = desc.Parent:FindFirstChild("Generation")
                if genLabel and genLabel:IsA("TextLabel") then
                    local mps = parseMoneyPerSec(genLabel.Text)
                    if not bestPetInfo or mps > bestPetInfo.mps then
                        bestPetInfo = {
                            petName = desc.Parent.DisplayName.Text,
                            genText = genLabel.Text,
                            mps = mps,
                            model = parentModel,
                        }
                    end
                end
            end
        end
    end

    if bestPetInfo and bestPetInfo.mps > 0 and bestPetInfo.model then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "Best_ESP"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 4, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = bestPetInfo.model
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = bestPetInfo.petName .. "\n" .. bestPetInfo.genText
        label.TextColor3 = Color3.fromRGB(255, 255, 0)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextStrokeTransparency = 0
        label.Parent = billboard

        table.insert(espObjects, billboard)
    end
end

-- ESP Player
local function updatePlayerESP()
    if not espPlayerActive then
        for _, objs in pairs(playerEspBoxes) do
            if objs.box then pcall(function() objs.box:Destroy() end) end
            if objs.text then pcall(function() objs.text:Destroy() end) end
        end
        playerEspBoxes = {}
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            if not playerEspBoxes[plr] then
                playerEspBoxes[plr] = {}
                local box = Instance.new("BoxHandleAdornment")
                box.Size = Vector3.new(4, 6, 4)
                box.Adornee = hrp
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Transparency = 0.5
                box.Color3 = Color3.fromRGB(255, 0, 0)
                box.Parent = hrp
                playerEspBoxes[plr].box = box

                local billboard = Instance.new("BillboardGui")
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
                playerEspBoxes[plr].text = billboard
                billboard.Parent = hrp
            end
        else
            if playerEspBoxes[plr] then
                if playerEspBoxes[plr].box then pcall(function() playerEspBoxes[plr].box:Destroy() end) end
                if playerEspBoxes[plr].text then pcall(function() playerEspBoxes[plr].text:Destroy() end) end
                playerEspBoxes[plr] = nil
            end
        end
    end
end

-- ESP Toggle Functions
local function toggleBaseESP()
    espBaseActive = not espBaseActive
    if espBaseActive then
        updateBaseESP()
        showNotification("ESP Base ON", true)
    else
        updateBaseESP()
        showNotification("ESP Base OFF", false)
    end
end

local function toggleBestESP()
    espBestActive = not espBestActive
    if espBestActive then
        updateBestESP()
        showNotification("ESP Best ON", true)
    else
        updateBestESP()
        showNotification("ESP Best OFF", false)
    end
end

local function togglePlayerESP()
    espPlayerActive = not espPlayerActive
    if espPlayerActive then
        updatePlayerESP()
        showNotification("ESP Player ON", true)
    else
        updatePlayerESP()
        showNotification("ESP Player OFF", false)
    end
end

----------------------------------------------------------------
-- AUTO LASER (FIXED)
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
    while autoLaserEnabled and player.Character do
        local target = findNearestAllowed()
        if target then
            safeFire(target)
        end
        task.wait(0.6)
    end
end

local function toggleAutoLaser()
    autoLaserEnabled = not autoLaserEnabled
    if autoLaserEnabled then
        showNotification("Auto Laser ON - Equip Laser Item!", true)
        if autoLaserThread then task.cancel(autoLaserThread) end
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
-- GUI CREATION
----------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "VortexHub"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- V Logo (Toggle Button)
local logoButton = Instance.new("TextButton")
logoButton.Name = "VortexLogo"
logoButton.Size = UDim2.new(0, 30, 0, 30)
logoButton.Position = UDim2.new(0, 10, 0, 10)
logoButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
logoButton.Text = "V"
logoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
logoButton.TextSize = 14
logoButton.Font = Enum.Font.GothamBlack
logoButton.AutoButtonColor = false
logoButton.ZIndex = 100
logoButton.Draggable = true
logoButton.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = logoButton

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(200, 230, 255)
stroke.Thickness = 1.8
stroke.Parent = logoButton

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 140, 0, 132)
mainFrame.Position = UDim2.new(0.5, -70, 0.5, -66)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.ZIndex = 50
mainFrame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(60, 140, 200)
frameStroke.Thickness = 2
frameStroke.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 20)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
header.BackgroundTransparency = 0.2
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 1, 0)
title.Position = UDim2.new(0, 5, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Vortex Hub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 10
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Center
title.Parent = header

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 16, 0, 16)
closeBtn.Position = UDim2.new(1, -20, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 12
closeBtn.Font = Enum.Font.GothamBold
closeBtn.AutoButtonColor = false
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeBtn

-- Content area
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -8, 1, -25)
contentFrame.Position = UDim2.new(0, 4, 0, 21)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Button Creation Function
local function createButton(parent, text, yPos, active, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 20)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = active and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(255, 255, 255)
    btnStroke.Transparency = 0.8
    btnStroke.Thickness = 1
    btnStroke.Parent = btn
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = active and Color3.fromRGB(0, 180, 20) or Color3.fromRGB(180, 20, 20)
    end)
    
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = active and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    end)
    
    btn.MouseButton1Click:Connect(callback)
    
    return btn
end

-- Create Buttons
local yPos = 0
createButton(contentFrame, "Inf Jump " .. (gravityLow and "ON" or "OFF"), yPos, gravityLow, switchGravityJump)
yPos = yPos + 22
createButton(contentFrame, "Fly to Base", yPos, flyActive, startFlyToBase)
yPos = yPos + 22
createButton(contentFrame, "ESP Base " .. (espBaseActive and "ON" or "OFF"), yPos, espBaseActive, toggleBaseESP)
yPos = yPos + 22
createButton(contentFrame, "ESP Best " .. (espBestActive and "ON" or "OFF"), yPos, espBestActive, toggleBestESP)
yPos = yPos + 22
createButton(contentFrame, "ESP Player " .. (espPlayerActive and "ON" or "OFF"), yPos, espPlayerActive, togglePlayerESP)
yPos = yPos + 22
createButton(contentFrame, "Auto Laser " .. (autoLaserEnabled and "ON" or "OFF"), yPos, autoLaserEnabled, toggleAutoLaser)

-- Logo button hover
logoButton.MouseEnter:Connect(function()
    logoButton.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
end)

logoButton.MouseLeave:Connect(function()
    logoButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
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

-- ESP Update Loop
task.spawn(function()
    while true do
        if espBaseActive then updateBaseESP() end
        if espBestActive then updateBestESP() end
        if espPlayerActive then updatePlayerESP() end
        task.wait(2)
    end
end)

showNotification("🚀 Vortex Hub Loaded!", true)

print("🎯 Vortex Hub Activated!")
print("🦘 Inf Jump: Ready (19 Limit)")
print("🚀 Fly to Base: Ready")
print("🏠 ESP Base: " .. (espBaseActive and "ON" or "OFF"))
print("🔥 ESP Best: " .. (espBestActive and "ON" or "OFF"))
print("👥 ESP Player: " .. (espPlayerActive and "ON" or "OFF"))
print("🔫 Auto Laser: " .. (autoLaserEnabled and "ON" or "OFF"))
