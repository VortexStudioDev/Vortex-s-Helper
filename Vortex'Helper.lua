-- Vortex Hub - Optimized Edition
-- Features: Inf Jump, FLY TO BASE, FPS Devourer, ESP Base, ESP Best, ESP Player, Auto Laser
-- Settings Save System

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
-- SAVE SYSTEM
----------------------------------------------------------------
local CONFIG_DIR = "Vortex'sHelpers"
local CONFIG_FILE = CONFIG_DIR .. "/vortex_config.json"

local defaultConfig = {
    espBase = false,
    espBest = false,
    espPlayer = false,
    autoLaser = false
}

local currentConfig = {}

local function ensureDir()
    if isfolder and not isfolder(CONFIG_DIR) then
        pcall(function() makefolder(CONFIG_DIR) end)
    end
end

local function loadConfig()
    for k, v in pairs(defaultConfig) do
        currentConfig[k] = v
    end
    
    if not (isfile and readfile and isfile(CONFIG_FILE)) then return end
    
    local ok, data = pcall(function() return readfile(CONFIG_FILE) end)
    if ok and data and #data > 0 then
        local decoded = game:GetService("HttpService"):JSONDecode(data)
        if decoded then
            for k, v in pairs(defaultConfig) do
                if decoded[k] ~= nil then
                    currentConfig[k] = decoded[k]
                end
            end
        end
    end
end

local function saveConfig()
    if not writefile then return end
    ensureDir()
    local json = game:GetService("HttpService"):JSONEncode(currentConfig)
    pcall(function() writefile(CONFIG_FILE, json) end)
end

----------------------------------------------------------------
-- FPS DEVOURER
----------------------------------------------------------------
local function enableFPSDevourer()
    pcall(function()
        if setfpscap then setfpscap(999) end
    end)
    
    local lighting = game:GetService("Lighting")
    pcall(function()
        lighting.GlobalShadows = false
        lighting.FogEnd = 100000
        lighting.Brightness = 2
    end)
    
    showNotification("FPS Devourer Activated!", true)
end

----------------------------------------------------------------
-- INF JUMP / JUMP BOOST
----------------------------------------------------------------
local NORMAL_GRAV = 196.2
local REDUCED_GRAV = 40
local NORMAL_JUMP = 50
local BOOST_JUMP = 120
local BOOST_SPEED = 32

local gravityLow = false
local sourceActive = false

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
    sourceActive = gravityLow
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
            startFlyToBase() -- Turn off when reached
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
    currentConfig.espBase = espBaseActive
    saveConfig()
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
    currentConfig.espBest = espBestActive
    saveConfig()
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
    currentConfig.espPlayer = espPlayerActive
    saveConfig()
    if espPlayerActive then
        updatePlayerESP()
        showNotification("ESP Player ON", true)
    else
        updatePlayerESP()
        showNotification("ESP Player OFF", false)
    end
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
    if not targetPlayer or not targetPlayer.Character or targetPlayer == Players.LocalPlayer then return false end
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
        task.wait(0.6)
    end
end

local function toggleAutoLaser()
    autoLaserEnabled = not autoLaserEnabled
    currentConfig.autoLaser = autoLaserEnabled
    saveConfig()
    
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

-- Main Frame (60% smaller)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 150, 0, 220)
mainFrame.Position = UDim2.new(0.5, -75, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
mainFrame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(100, 150, 255)
stroke.Transparency = 0.3
stroke.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.Text = "VORTEX HUB"
title.TextColor3 = Color3.fromRGB(100, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BackgroundTransparency = 1
title.Parent = mainFrame

-- V Logo (Toggle Button)
local logoButton = Instance.new("TextButton")
logoButton.Size = UDim2.new(0, 30, 0, 30)
logoButton.Position = UDim2.new(1, -35, 0, -35)
logoButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
logoButton.Text = "V"
logoButton.TextColor3 = Color3.new(1, 1, 1)
logoButton.Font = Enum.Font.GothamBlack
logoButton.TextSize = 16
logoButton.Parent = gui

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(1, 0)
logoCorner.Parent = logoButton

logoButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Button Creation Function
local function createButton(parent, text, yPos, active, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 25)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = active and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        callback()
        btn.BackgroundColor3 = (not active) and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    end)
    
    return btn
end

-- Create Buttons
local yPos = 30
createButton(mainFrame, "FPS Devourer", yPos, false, enableFPSDevourer)
yPos = yPos + 30
createButton(mainFrame, gravityLow and "Inf Jump ON" or "Inf Jump OFF", yPos, gravityLow, switchGravityJump)
yPos = yPos + 30
createButton(mainFrame, "Fly to Base", yPos, flyActive, startFlyToBase)
yPos = yPos + 30
createButton(mainFrame, espBaseActive and "ESP Base ON" or "ESP Base OFF", yPos, espBaseActive, toggleBaseESP)
yPos = yPos + 30
createButton(mainFrame, espBestActive and "ESP Best ON" or "ESP Best OFF", yPos, espBestActive, toggleBestESP)
yPos = yPos + 30
createButton(mainFrame, espPlayerActive and "ESP Player ON" or "ESP Player OFF", yPos, espPlayerActive, togglePlayerESP)
yPos = yPos + 30
createButton(mainFrame, autoLaserEnabled and "Auto Laser ON" or "Auto Laser OFF", yPos, autoLaserEnabled, toggleAutoLaser)

-- Make draggable
local dragging = false
local dragInput, dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
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
        if espBaseActive then updateBaseESP() end
        if espBestActive then updateBestESP() end
        if espPlayerActive then updatePlayerESP() end
        task.wait(2)
    end
end)

-- Load config and initialize
loadConfig()
espBaseActive = currentConfig.espBase
espBestActive = currentConfig.espBest
espPlayerActive = currentConfig.espPlayer
autoLaserEnabled = currentConfig.autoLaser

enableFPSDevourer()
showNotification("Vortex Hub Loaded!", true)

print("🎯 Vortex Hub Activated!")
print("✅ FPS Devourer: ON")
print("🦘 Inf Jump: Ready")
print("🚀 Fly to Base: Ready")
print("🏠 ESP Base: " .. (espBaseActive and "ON" or "OFF"))
print("🔥 ESP Best: " .. (espBestActive and "ON" or "OFF"))
print("👥 ESP Player: " .. (espPlayerActive and "ON" or "OFF"))
print("🔫 Auto Laser: " .. (autoLaserEnabled and "ON" or "OFF"))-- Chered Hub - Sadeleştirilmiş Versiyon
-- Alınan Özellikler: Inf Jump / JumpBoost, FLY TO BASE, FPS Devourer, ESP Base, ESP Best
-- Discord: https://discord.gg/qvVEZt3q88

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UserInputService = game:GetService('UserInputService')
local Workspace = game:GetService('Workspace')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')
local player = Players.LocalPlayer

----------------------------------------------------------------
-- FPS DEVOURER (Optimizasyon)
----------------------------------------------------------------
local function enableFPSDevourer()
    pcall(function()
        if setfpscap then
            setfpscap(999)
        end
    end)
    
    -- Görsel kaliteyi düşürerek FPS artışı
    for _, lighting in pairs(Workspace:GetChildren()) do
        if lighting:IsA("Part") or lighting:IsA("UnionOperation") or lighting:IsA("MeshPart") then
            pcall(function()
                lighting.Material = Enum.Material.Plastic
                lighting.Reflectance = 0
            end)
        end
    end
    
    -- Lighting ayarları
    local lighting = game:GetService("Lighting")
    pcall(function()
        lighting.GlobalShadows = false
        lighting.FogEnd = 100000
        lighting.Brightness = 2
    end)
    
    -- Character optimizasyonu
    player.CharacterAdded:Connect(function(char)
        wait(0.5)
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    part.Material = Enum.Material.Plastic
                    part.Reflectance = 0
                end)
            end
        end
    end)
end

----------------------------------------------------------------
-- INF JUMP / JUMP BOOST
----------------------------------------------------------------
local NORMAL_GRAV = 196.2
local REDUCED_GRAV = 40
local NORMAL_JUMP = 50
local BOOST_JUMP = 120
local BOOST_SPEED = 32

local spoofedGravity = NORMAL_GRAV
pcall(function()
    local mt = getrawmetatable(Workspace)
    if mt then
        setreadonly(mt, false)
        local oldIndex = mt.__index
        mt.__index = function(self, k)
            if k == 'Gravity' then
                return spoofedGravity
            end
            return oldIndex(self, k)
        end
        setreadonly(mt, true)
    end
end)

local gravityLow = false
local sourceActive = false

local function setJumpPower(jump)
    local h = player.Character and player.Character:FindFirstChildOfClass('Humanoid')
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
                local root = char:FindFirstChild('HumanoidRootPart')
                local h = char:FindFirstChildOfClass('Humanoid')
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
            local h = player.Character and player.Character:FindFirstChildOfClass('Humanoid')
            if h and gravityLow and h:GetState() ~= Enum.HumanoidStateType.Seated then
                local root = player.Character:FindFirstChild('HumanoidRootPart')
                if root then
                    root.Velocity = Vector3.new(
                        root.Velocity.X,
                        h.JumpPower,
                        root.Velocity.Z
                    )
                end
            end
        end)
    end
end

local function antiRagdoll()
    local char = player.Character
    if char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA('BodyVelocity') or v:IsA('BodyAngularVelocity') then
                v:Destroy()
            end
        end
    end
end

local function toggleForceField()
    local char = player.Character
    if char then
        if gravityLow then
            if not char:FindFirstChildOfClass('ForceField') then
                local ff = Instance.new('ForceField', char)
                ff.Visible = false
            end
        else
            for _, ff in ipairs(char:GetChildren()) do
                if ff:IsA('ForceField') then
                    ff:Destroy()
                end
            end
        end
    end
end

local function switchGravityJump()
    gravityLow = not gravityLow
    sourceActive = gravityLow
    Workspace.Gravity = gravityLow and REDUCED_GRAV or NORMAL_GRAV
    setJumpPower(gravityLow and BOOST_JUMP or NORMAL_JUMP)
    enableSpeedBoostAssembly(gravityLow)
    enableInfiniteJump(gravityLow)
    antiRagdoll()
    toggleForceField()
    spoofedGravity = NORMAL_GRAV
end

----------------------------------------------------------------
-- FLY TO BASE
----------------------------------------------------------------
local flyActive = false
local flyConn
local flyAtt, flyLV
local flyCharRemovingConn
local destTouchedConn
local destPartRef
local flyRestoreOldGravity, flyRestoreOldJumpPower

local FLY_SUCCESS_SOUND_ID = 'rbxassetid://144686873'
local FLY_SUCCESS_VOLUME = 1

local FLY_GRAV = 20
local FLY_JUMP = 7
local FLY_STOPDIST = 7
local FLY_XZ_SPEED = 22
local FLY_Y_BASE = -1.0
local FLY_Y_MAX = -2.2
local FLY_TIME_STEP = 1.5

local function clearFlyConnections()
    if flyConn then
        pcall(function()
            flyConn:Disconnect()
        end)
        flyConn = nil
    end
    if flyCharRemovingConn then
        pcall(function()
            flyCharRemovingConn:Disconnect()
        end)
        flyCharRemovingConn = nil
    end
    if destTouchedConn then
        pcall(function()
            destTouchedConn:Disconnect()
        end)
        destTouchedConn = nil
    end
end

local function destroyFlyBodies()
    if flyLV then
        pcall(function()
            flyLV:Destroy()
        end)
        flyLV = nil
    end
    if flyAtt then
        pcall(function()
            flyAtt:Destroy()
        end)
        flyAtt = nil
    end
    destPartRef = nil
end

local function findMyDeliveryPart()
    local plots = Workspace:FindFirstChild('Plots')
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild('PlotSign')
            if sign and sign:FindFirstChild('YourBase') and sign.YourBase.Enabled then
                local delivery = plot:FindFirstChild('DeliveryHitbox')
                if delivery and delivery:IsA('BasePart') then
                    return delivery
                end
            end
        end
    end
    return nil
end

local function flyGetDescent(dist)
    local maxdist = 200
    dist = math.clamp(dist, 0, maxdist)
    local t = 1 - (dist / maxdist)
    return FLY_Y_BASE + (FLY_Y_MAX - FLY_Y_BASE) * t
end

local function restoreSourceAndPhysics()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass('Humanoid')
    if hum then
        if gravityLow then
            Workspace.Gravity = REDUCED_GRAV
            setJumpPower(BOOST_JUMP)
            enableSpeedBoostAssembly(true)
            enableInfiniteJump(true)
        else
            Workspace.Gravity = NORMAL_GRAV
            setJumpPower(NORMAL_JUMP)
            enableSpeedBoostAssembly(false)
            enableInfiniteJump(false)
        end
        spoofedGravity = NORMAL_GRAV
    else
        Workspace.Gravity = flyRestoreOldGravity or NORMAL_GRAV
        spoofedGravity = NORMAL_GRAV
        pcall(function()
            if hum and flyRestoreOldJumpPower then
                hum.JumpPower = flyRestoreOldJumpPower
            end
        end)
    end
end

local function cleanupFly()
    clearFlyConnections()
    destroyFlyBodies()
    restoreSourceAndPhysics()
    flyActive = false
end

local function finishFly(success)
    cleanupFly()
end

local function startFlyToBase()
    if flyActive then
        finishFly(false)
        return
    end

    local destPart = findMyDeliveryPart()
    if not destPart then
        return
    end

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass('Humanoid')
    local hrp = char and char:FindFirstChild('HumanoidRootPart')
    if not (hum and hrp) then
        return
    end

    flyRestoreOldGravity = Workspace.Gravity
    flyRestoreOldJumpPower = hum.JumpPower

    enableSpeedBoostAssembly(false)
    enableInfiniteJump(false)

    Workspace.Gravity = FLY_GRAV
    spoofedGravity = NORMAL_GRAV
    hum.UseJumpPower = true
    hum.JumpPower = FLY_JUMP

    flyActive = true

    flyAtt = Instance.new('Attachment')
    flyAtt.Name = 'FlyToBaseAttachment'
    flyAtt.Parent = hrp

    flyLV = Instance.new('LinearVelocity')
    flyLV.Attachment0 = flyAtt
    flyLV.RelativeTo = Enum.ActuatorRelativeTo.World
    flyLV.MaxForce = math.huge
    flyLV.Parent = hrp

    destPartRef = destPart

    local reached = false
    local lastYUpdate = 0

    do
        local pos = hrp.Position
        local destPos = destPart.Position
        local distXZ = (Vector3.new(destPos.X, pos.Y, destPos.Z) - pos).Magnitude
        local yVel = flyGetDescent(distXZ)
        local dirXZ = Vector3.new(destPos.X - pos.X, 0, destPos.Z - pos.Z)
        if dirXZ.Magnitude > 0 then
            dirXZ = dirXZ.Unit
        else
            dirXZ = Vector3.new()
        end
        flyLV.VectorVelocity = Vector3.new(dirXZ.X * FLY_XZ_SPEED, yVel, dirXZ.Z * FLY_XZ_SPEED)
        lastYUpdate = tick()
    end

    destTouchedConn = destPart.Touched:Connect(function(hit)
        if not flyActive then
            return
        end
        local ch = player.Character
        if ch and hit and hit:IsDescendantOf(ch) then
            reached = true
            finishFly(true)
        end
    end)

    if flyConn then
        flyConn:Disconnect()
        flyConn = nil
    end
    flyConn = RunService.Heartbeat:Connect(function()
        if not flyActive then
            cleanupFly()
            return
        end

        if not (hrp and hrp.Parent and hum and hum.Parent) then
            finishFly(false)
            return
        end

        local pos = hrp.Position
        local destPos = destPart.Position
        local distXZ = (Vector3.new(destPos.X, pos.Y, destPos.Z) - pos).Magnitude

        if distXZ < FLY_STOPDIST and not reached then
            reached = true
            finishFly(true)
            return
        end

        if tick() - lastYUpdate >= FLY_TIME_STEP then
            local yVel = flyGetDescent(distXZ)
            local dirXZ = Vector3.new(destPos.X - pos.X, 0, destPos.Z - pos.Z)
            if dirXZ.Magnitude > 0 then
                dirXZ = dirXZ.Unit
            else
                dirXZ = Vector3.new()
            end
            flyLV.VectorVelocity = Vector3.new(
                dirXZ.X * FLY_XZ_SPEED,
                yVel,
                dirXZ.Z * FLY_XZ_SPEED
            )
            lastYUpdate = tick()
        end
    end)

    if flyCharRemovingConn then
        flyCharRemovingConn:Disconnect()
        flyCharRemovingConn = nil
    end
    flyCharRemovingConn = player.CharacterRemoving:Connect(function()
        if flyActive then
            finishFly(false)
        else
            cleanupFly()
        end
    end)
end

----------------------------------------------------------------
-- ESP BASE
----------------------------------------------------------------
local espBaseActive = false
local baseEspObjects = {}

local function clearBaseESP()
    for _, obj in pairs(baseEspObjects) do
        pcall(function()
            obj:Destroy()
        end)
    end
    baseEspObjects = {}
end

local function updateBaseESP()
    if not espBaseActive then return end
    
    clearBaseESP()
    
    local plots = Workspace:FindFirstChild('Plots')
    if not plots then return end

    local myPlotName
    for _, plot in pairs(plots:GetChildren()) do
        local plotSign = plot:FindFirstChild('PlotSign')
        if plotSign and plotSign:FindFirstChild('YourBase') and plotSign.YourBase.Enabled then
            myPlotName = plot.Name
            break
        end
    end

    if not myPlotName then return end

    for _, plot in pairs(plots:GetChildren()) do
        if plot.Name ~= myPlotName then
            local purchases = plot:FindFirstChild('Purchases')
            local pb = purchases and purchases:FindFirstChild('PlotBlock')
            local main = pb and pb:FindFirstChild('Main')
            local gui = main and main:FindFirstChild('BillboardGui')
            local timeLb = gui and gui:FindFirstChild('RemainingTime')
            
            if timeLb and main then
                local billboard = Instance.new('BillboardGui')
                billboard.Name = 'Base_ESP'
                billboard.Size = UDim2.new(0, 140, 0, 36)
                billboard.StudsOffset = Vector3.new(0, 5, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = main

                local label = Instance.new('TextLabel')
                label.Text = timeLb.Text
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextScaled = true
                label.TextColor3 = Color3.fromRGB(220, 0, 60)
                label.Font = Enum.Font.Arcade
                label.TextStrokeTransparency = 0.5
                label.TextStrokeColor3 = Color3.new(0, 0, 0)
                label.Parent = billboard

                table.insert(baseEspObjects, billboard)
            end
        end
    end
end

local function toggleBaseESP()
    espBaseActive = not espBaseActive
    if espBaseActive then
        updateBaseESP()
        -- Her 2 saniyede bir güncelle
        while espBaseActive do
            wait(2)
            updateBaseESP()
        end
    else
        clearBaseESP()
    end
end

----------------------------------------------------------------
-- ESP BEST
----------------------------------------------------------------
local espBestActive = false
local bestEspObjects = {}

local function clearBestESP()
    for _, obj in pairs(bestEspObjects) do
        pcall(function()
            obj:Destroy()
        end)
    end
    bestEspObjects = {}
end

local function parseMoneyPerSec(text)
    if not text then
        return 0
    end
    local mult = 1
    local numberStr = text:match('[%d%.]+')
    if not numberStr then
        return 0
    end
    if text:find('K') then
        mult = 1_000
    elseif text:find('M') then
        mult = 1_000_000
    elseif text:find('B') then
        mult = 1_000_000_000
    elseif text:find('T') then
        mult = 1_000_000_000_000
    elseif text:find('Q') then
        mult = 1_000_000_000_000_000
    end
    local number = tonumber(numberStr)
    return number and number * mult or 0
end

local function updateBestESP()
    if not espBestActive then return end
    
    clearBestESP()
    
    local plots = Workspace:FindFirstChild('Plots')
    if not plots then return end

    local myPlotName
    for _, plot in ipairs(plots:GetChildren()) do
        local plotSign = plot:FindFirstChild('PlotSign')
        if plotSign and plotSign:FindFirstChild('YourBase') and plotSign.YourBase.Enabled then
            myPlotName = plot.Name
            break
        end
    end

    local bestPetInfo = nil

    for _, plot in ipairs(plots:GetChildren()) do
        if plot.Name ~= myPlotName then
            for _, desc in ipairs(plot:GetDescendants()) do
                if desc:IsA('TextLabel') and desc.Name == 'Rarity' and desc.Parent and desc.Parent:FindFirstChild('DisplayName') then
                    local parentModel = desc.Parent.Parent
                    local rarity = desc.Text
                    local displayName = desc.Parent.DisplayName.Text

                    if espBestActive then
                        local genLabel = desc.Parent:FindFirstChild('Generation')
                        if genLabel and genLabel:IsA('TextLabel') then
                            local mps = parseMoneyPerSec(genLabel.Text)
                            if not bestPetInfo or mps > bestPetInfo.mps then
                                bestPetInfo = {
                                    petName = displayName,
                                    genText = genLabel.Text,
                                    mps = mps,
                                    model = parentModel,
                                }
                            end
                        end
                    end
                end
            end
        end
    end

    if espBestActive then
        for _, plot in ipairs(plots:GetChildren()) do
            for _, inst in ipairs(plot:GetDescendants()) do
                if inst:IsA('BillboardGui') and inst.Name == 'Best_ESP' then
                    pcall(function()
                        inst:Destroy()
                    end)
                end
            end
        end
        
        if bestPetInfo and bestPetInfo.mps > 0 and bestPetInfo.model then
            local billboard = Instance.new('BillboardGui')
            billboard.Name = 'Best_ESP'
            billboard.Size = UDim2.new(0, 303, 0, 75)
            billboard.StudsOffset = Vector3.new(0, 4.84, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = bestPetInfo.model
            
            local nameLabel = Instance.new('TextLabel')
            nameLabel.Size = UDim2.new(1, 0, 0, 35)
            nameLabel.Position = UDim2.new(0, 0, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = bestPetInfo.petName
            nameLabel.TextColor3 = Color3.fromRGB(255, 0, 60)
            nameLabel.Font = Enum.Font.GothamSemibold
            nameLabel.TextSize = 25
            nameLabel.TextStrokeTransparency = 0.07
            nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            nameLabel.Parent = billboard
            
            local moneyLabel = Instance.new('TextLabel')
            moneyLabel.Size = UDim2.new(1, 0, 0, 22)
            moneyLabel.Position = UDim2.new(0, 0, 0, 35)
            moneyLabel.BackgroundTransparency = 1
            moneyLabel.Text = bestPetInfo.genText
            moneyLabel.TextColor3 = Color3.fromRGB(0, 240, 60)
            moneyLabel.Font = Enum.Font.GothamSemibold
            moneyLabel.TextSize = 22
            moneyLabel.TextStrokeTransparency = 0.17
            moneyLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            moneyLabel.Parent = billboard

            table.insert(bestEspObjects, billboard)
        end
    end
end

local function toggleBestESP()
    espBestActive = not espBestActive
    if espBestActive then
        updateBestESP()
        -- Her 2 saniyede bir güncelle
        while espBestActive do
            wait(2)
            updateBestESP()
        end
    else
        clearBestESP()
    end
end

----------------------------------------------------------------
-- GUI OLUŞTURMA
----------------------------------------------------------------
local playerGui = player:WaitForChild('PlayerGui')

-- Eski GUI'leri temizle
do
    local old = playerGui:FindFirstChild('SimpleHub_FULL')
    if old then
        pcall(function()
            old:Destroy()
        end)
    end
end

local gui = Instance.new('ScreenGui')
gui.Name = 'SimpleHub_FULL'
gui.ResetOnSpawn = false
gui.Parent = playerGui

local mainFrame = Instance.new('Frame')
mainFrame.Size = UDim2.new(0, 300, 0, 450)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui

local corner = Instance.new('UICorner', mainFrame)
corner.CornerRadius = UDim.new(0, 12)

local stroke = Instance.new('UIStroke', mainFrame)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(100, 150, 255)
stroke.Transparency = 0.3

local title = Instance.new('TextLabel', mainFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = '🚀 SIMPLE HUB 🚀'
title.TextColor3 = Color3.fromRGB(100, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.BackgroundTransparency = 1

local function createButton(parent, text, yPos, callback)
    local btn = Instance.new('TextButton', parent)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    
    local btnCorner = Instance.new('UICorner', btn)
    btnCorner.CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Butonları oluştur
local yPos = 50
createButton(mainFrame, '🎯 FPS Devourer AÇ', yPos, enableFPSDevourer)
yPos = yPos + 50
createButton(mainFrame, gravityLow and '✅ Inf Jump AÇIK' or '🦘 Inf Jump AÇ', yPos, switchGravityJump)
yPos = yPos + 50
createButton(mainFrame, '🚀 FLY TO BASE', yPos, startFlyToBase)
yPos = yPos + 50
createButton(mainFrame, espBaseActive and '✅ ESP Base AÇIK' or '🏠 ESP Base AÇ', yPos, toggleBaseESP)
yPos = yPos + 50
createButton(mainFrame, espBestActive and '✅ ESP Best AÇIK' or '🔥 ESP Best AÇ', yPos, toggleBestESP)

-- Sürükleme özelliği
local dragging = false
local dragInput, dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Başlangıçta FPS Devourer'ı etkinleştir
enableFPSDevourer()

print("🎯 Simple Hub Yüklendi!")
print("✅ FPS Devourer Aktif")
print("🦘 Inf Jump Hazır") 
print("🚀 Fly to Base Hazır")
print("🏠 ESP Base Hazır")
print("🔥 ESP Best Hazır")
