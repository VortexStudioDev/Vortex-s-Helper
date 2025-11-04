-- Vortex Helper - Premium Version
local Players = game:GetService('Players')
local UserInputService = game:GetService('UserInputService')
local Workspace = game:GetService('Workspace')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')
local CoreGui = game:GetService('CoreGui')
local HttpService = game:GetService('HttpService')
local player = Players.LocalPlayer

-- Tüm değişkenleri başta tanımla
local gravityLow = false
local fpsDevourerActive = false
local espBaseActive = false
local espBestActive = false
local playerEspActive = false
local stealFloorActive = false
local antiHitActive = false

-- Settings folder
local VortexFolder = Workspace:FindFirstChild("VortexHelper")
if not VortexFolder then
    VortexFolder = Instance.new("Folder")
    VortexFolder.Name = "VortexHelper"
    VortexFolder.Parent = Workspace
end

-- Save/Load settings
local function saveSettings()
    local settings = {
        infJump = gravityLow,
        espBase = espBaseActive,
        espBest = espBestActive,
        desync = antiHitActive,
        fpsDevourer = fpsDevourerActive,
        playerESP = playerEspActive,
        stealFloor = stealFloorActive
    }
    
    local success, result = pcall(function()
        local json = HttpService:JSONEncode(settings)
        VortexFolder:SetAttribute("Settings", json)
    end)
    
    return success
end

local function loadSettings()
    local saved = VortexFolder:GetAttribute("Settings")
    if saved then
        local success, settings = pcall(function()
            return HttpService:JSONDecode(saved)
        end)
        
        if success and settings then
            return settings
        end
    end
    return {}
end

-- Notification System
local notificationEnabled = true
local function showNotification(message, isSuccess)
    if not notificationEnabled then return end
    
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "VortexNotify"
    notificationGui.ResetOnSpawn = false
    notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notificationGui.Parent = CoreGui
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 220, 0, 50)
    notification.Position = UDim2.new(0.5, -110, 0.15, 0)
    notification.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    notification.BackgroundTransparency = 0
    notification.BorderSizePixel = 0
    notification.ZIndex = 1000
    notification.ClipsDescendants = true
    notification.Parent = notificationGui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notification
    
    local notifStroke = Instance.new("UIStroke")
    notifStroke.Color = isSuccess and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    notifStroke.Thickness = 2
    notifStroke.Parent = notification
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 40, 1, 0)
    icon.Position = UDim2.new(0, 0, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = isSuccess and "✅" or "❌"
    icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    icon.TextSize = 18
    icon.Font = Enum.Font.GothamBold
    icon.ZIndex = 1001
    icon.Parent = notification
    
    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(1, -45, 1, -10)
    notifText.Position = UDim2.new(0, 40, 0, 5)
    notifText.BackgroundTransparency = 1
    notifText.Text = message
    notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifText.TextSize = 12
    notifText.Font = Enum.Font.Gotham
    notifText.TextXAlignment = Enum.TextXAlignment.Left
    notifText.TextYAlignment = Enum.TextYAlignment.Top
    notifText.TextWrapped = true
    notifText.ZIndex = 1001
    notifText.Parent = notification
    
    notification.Position = UDim2.new(0.5, -110, 0.1, 0)
    local tweenIn = TweenService:Create(notification, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -110, 0.15, 0)
    })
    tweenIn:Play()

    tweenIn.Completed:Connect(function()
        wait(1.2)
        
        if notification and notification.Parent then
            local tweenOut = TweenService:Create(notification, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -110, 0.1, 0),
                BackgroundTransparency = 1
            })
            
            for _, child in pairs(notification:GetChildren()) do
                if child:IsA("TextLabel") then
                    child.TextTransparency = 1
                end
            end
            
            tweenOut:Play()
            
            tweenOut.Completed:Connect(function()
                if notificationGui and notificationGui.Parent then
                    notificationGui:Destroy()
                end
            end)
        end
    end)
end

-- FPS DEVOURER
local function enableFPSDevourer()
    fpsDevourerActive = true
    
    pcall(function()
        if setfpscap then
            setfpscap(999)
        end
    end)
    
    for _, lighting in pairs(Workspace:GetChildren()) do
        if lighting:IsA("Part") or lighting:IsA("UnionOperation") or lighting:IsA("MeshPart") then
            pcall(function()
                lighting.Material = Enum.Material.Plastic
                lighting.Reflectance = 0
            end)
        end
    end
    
    local lighting = game:GetService("Lighting")
    pcall(function()
        lighting.GlobalShadows = false
        lighting.FogEnd = 100000
        lighting.Brightness = 2
    end)
    
    saveSettings()
    showNotification("FPS Devourer Enabled", true)
end

local function disableFPSDevourer()
    fpsDevourerActive = false
    
    pcall(function()
        if setfpscap then
            setfpscap(60)
        end
    end)
    
    local lighting = game:GetService("Lighting")
    pcall(function()
        lighting.GlobalShadows = true
        lighting.Brightness = 1
    end)
    
    saveSettings()
    showNotification("FPS Devourer Disabled", false)
end

local function toggleFPSDevourer()
    if fpsDevourerActive then
        disableFPSDevourer()
    else
        enableFPSDevourer()
    end
end

-- INF JUMP
local NORMAL_GRAV = 196.2
local REDUCED_GRAV = 40
local NORMAL_JUMP = 30
local BOOST_JUMP = 30

local function setJumpPower(jump)
    local h = player.Character and player.Character:FindFirstChildOfClass('Humanoid')
    if h then
        h.JumpPower = jump
        h.UseJumpPower = true
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

local function switchGravityJump()
    gravityLow = not gravityLow
    Workspace.Gravity = gravityLow and REDUCED_GRAV or NORMAL_GRAV
    setJumpPower(gravityLow and BOOST_JUMP or NORMAL_JUMP)
    enableInfiniteJump(gravityLow)
    
    saveSettings()
end

-- FLY TO BASE
local flyActive = false
local flyConn

local function startFlyToBase()
    if flyActive then
        if flyConn then
            flyConn:Disconnect()
            flyConn = nil
        end
        flyActive = false
        showNotification("Fly to Base Stopped", false)
        return
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

    local destPart = findMyDeliveryPart()
    if not destPart then
        showNotification("No base found!", false)
        return
    end

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass('Humanoid')
    local hrp = char and char:FindFirstChild('HumanoidRootPart')
    if not (hum and hrp) then
        showNotification("Character not found!", false)
        return
    end

    flyActive = true
    showNotification("Flying to base...", true)

    flyConn = RunService.Heartbeat:Connect(function()
        if not flyActive or not hrp or not hrp.Parent then
            if flyConn then
                flyConn:Disconnect()
                flyConn = nil
            end
            return
        end

        local currentPos = hrp.Position
        local targetPos = destPart.Position
        local direction = (targetPos - currentPos).Unit
        
        hrp.Velocity = direction * 50
        
        if (currentPos - targetPos).Magnitude < 10 then
            if flyConn then
                flyConn:Disconnect()
                flyConn = nil
            end
            flyActive = false
            hrp.Velocity = Vector3.new(0, 0, 0)
            showNotification("Arrived at base!", true)
        end
    end)
end

-- ESP BASE
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

    for _, plot in pairs(plots:GetChildren()) do
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

local baseEspLoop
local function toggleBaseESP()
    espBaseActive = not espBaseActive
    
    if baseEspLoop then
        baseEspLoop:Disconnect()
        baseEspLoop = nil
    end
    
    if espBaseActive then
        updateBaseESP()
        baseEspLoop = RunService.Heartbeat:Connect(function()
            if not espBaseActive then
                baseEspLoop:Disconnect()
                baseEspLoop = nil
                return
            end
            wait(2)
            updateBaseESP()
        end)
        showNotification("Base ESP Enabled", true)
    else
        clearBaseESP()
        showNotification("Base ESP Disabled", false)
    end
    saveSettings()
end

-- ESP BEST
local bestEspObjects = {}

local function clearBestESP()
    for _, obj in pairs(bestEspObjects) do
        pcall(function()
            obj:Destroy()
        end)
    end
    bestEspObjects = {}
end

local function updateBestESP()
    if not espBestActive then return end
    
    clearBestESP()
    
    local plots = Workspace:FindFirstChild('Plots')
    if not plots then return end

    for _, plot in ipairs(plots:GetChildren()) do
        for _, desc in ipairs(plot:GetDescendants()) do
            if desc:IsA('TextLabel') and desc.Name == 'Rarity' and desc.Parent and desc.Parent:FindFirstChild('DisplayName') then
                local parentModel = desc.Parent.Parent
                local rarity = desc.Text
                local displayName = desc.Parent.DisplayName.Text

                if espBestActive then
                    local genLabel = desc.Parent:FindFirstChild('Generation')
                    if genLabel and genLabel:IsA('TextLabel') then
                        local billboard = Instance.new('BillboardGui')
                        billboard.Name = 'Best_ESP'
                        billboard.Size = UDim2.new(0, 200, 0, 50)
                        billboard.StudsOffset = Vector3.new(0, 4, 0)
                        billboard.AlwaysOnTop = true
                        billboard.Parent = parentModel
                        
                        local nameLabel = Instance.new('TextLabel')
                        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                        nameLabel.Position = UDim2.new(0, 0, 0, 0)
                        nameLabel.BackgroundTransparency = 1
                        nameLabel.Text = displayName
                        nameLabel.TextColor3 = Color3.fromRGB(255, 0, 60)
                        nameLabel.Font = Enum.Font.GothamSemibold
                        nameLabel.TextSize = 16
                        nameLabel.TextStrokeTransparency = 0.07
                        nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                        nameLabel.Parent = billboard
                        
                        local moneyLabel = Instance.new('TextLabel')
                        moneyLabel.Size = UDim2.new(1, 0, 0.5, 0)
                        moneyLabel.Position = UDim2.new(0, 0, 0.5, 0)
                        moneyLabel.BackgroundTransparency = 1
                        moneyLabel.Text = genLabel.Text
                        moneyLabel.TextColor3 = Color3.fromRGB(0, 240, 60)
                        moneyLabel.Font = Enum.Font.GothamSemibold
                        moneyLabel.TextSize = 14
                        moneyLabel.TextStrokeTransparency = 0.17
                        moneyLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                        moneyLabel.Parent = billboard

                        table.insert(bestEspObjects, billboard)
                    end
                end
            end
        end
    end
end

local bestEspLoop
local function toggleBestESP()
    espBestActive = not espBestActive
    
    if bestEspLoop then
        bestEspLoop:Disconnect()
        bestEspLoop = nil
    end
    
    if espBestActive then
        updateBestESP()
        bestEspLoop = RunService.Heartbeat:Connect(function()
            if not espBestActive then
                bestEspLoop:Disconnect()
                bestEspLoop = nil
                return
            end
            wait(2)
            updateBestESP()
        end)
        showNotification("Best ESP Enabled", true)
    else
        clearBestESP()
        showNotification("Best ESP Disabled", false)
    end
    saveSettings()
end

-- PLAYER ESP
local playerEspBoxes = {}

local function clearPlayerESP()
    for plr, objs in pairs(playerEspBoxes) do
        if objs.box then
            pcall(function()
                objs.box:Destroy()
            end)
        end
        if objs.text then
            pcall(function()
                objs.text:Destroy()
            end)
        end
    end
    playerEspBoxes = {}
end

local function updatePlayerESP()
    if not playerEspActive then return end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local hrp = plr.Character:FindFirstChild('HumanoidRootPart')
            if hrp then
                if not playerEspBoxes[plr] then
                    playerEspBoxes[plr] = {}
                    
                    local highlight = Instance.new('Highlight')
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = plr.Character
                    playerEspBoxes[plr].box = highlight

                    local billboard = Instance.new('BillboardGui')
                    billboard.Adornee = hrp
                    billboard.Size = UDim2.new(0, 200, 0, 30)
                    billboard.StudsOffset = Vector3.new(0, 4, 0)
                    billboard.AlwaysOnTop = true
                    
                    local label = Instance.new('TextLabel', billboard)
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    label.TextStrokeTransparency = 0
                    label.Text = plr.Name
                    label.Font = Enum.Font.GothamBold
                    label.TextSize = 14
                    
                    playerEspBoxes[plr].text = billboard
                    billboard.Parent = hrp
                end
            end
        else
            if playerEspBoxes[plr] then
                if playerEspBoxes[plr].box then
                    pcall(function()
                        playerEspBoxes[plr].box:Destroy()
                    end)
                end
                if playerEspBoxes[plr].text then
                    pcall(function()
                        playerEspBoxes[plr].text:Destroy()
                    end)
                end
                playerEspBoxes[plr] = nil
            end
        end
    end
end

local playerEspLoop
local function togglePlayerESP()
    playerEspActive = not playerEspActive
    
    if playerEspLoop then
        playerEspLoop:Disconnect()
        playerEspLoop = nil
    end
    
    if playerEspActive then
        updatePlayerESP()
        playerEspLoop = RunService.Heartbeat:Connect(function()
            if not playerEspActive then
                playerEspLoop:Disconnect()
                playerEspLoop = nil
                return
            end
            updatePlayerESP()
        end)
        showNotification("Player ESP Enabled", true)
    else
        clearPlayerESP()
        showNotification("Player ESP Disabled", false)
    end
    saveSettings()
end

Players.PlayerRemoving:Connect(function(plr)
    local objs = playerEspBoxes[plr]
    if objs then
        if objs.box then
            pcall(function()
                objs.box:Destroy()
            end)
        end
        if objs.text then
            pcall(function()
                objs.text:Destroy()
            end)
        end
        playerEspBoxes[plr] = nil
    end
end)

-- STEAL FLOOR
local function toggleStealFloor()
    stealFloorActive = not stealFloorActive
    if stealFloorActive then
        showNotification("Steal Floor Enabled", true)
    else
        showNotification("Steal Floor Disabled", false)
    end
    saveSettings()
end

-- DEYSNC SYSTEM
local function executeAdvancedDesync()
    antiHitActive = not antiHitActive
    if antiHitActive then
        showNotification("Desync activated successfully!", true)
    else
        showNotification("Desync deactivated", false)
    end
    saveSettings()
end

-- Steal Floor Butonu
local stealFloorGui = Instance.new("ScreenGui")
stealFloorGui.Name = "StealFloorButton"
stealFloorGui.ResetOnSpawn = false
stealFloorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
stealFloorGui.Parent = CoreGui

local stealFloorButton = Instance.new("TextButton")
stealFloorButton.Name = "StealFloor"
stealFloorButton.Size = UDim2.new(0, 120, 0, 50)
stealFloorButton.Position = UDim2.new(0, 10, 1, -60)
stealFloorButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
stealFloorButton.BackgroundTransparency = 0.4
stealFloorButton.Text = "🏗️ Steal Floor"
stealFloorButton.TextColor3 = Color3.fromRGB(0, 0, 0)
stealFloorButton.TextSize = 14
stealFloorButton.Font = Enum.Font.GothamBold
stealFloorButton.TextWrapped = true
stealFloorButton.Draggable = true
stealFloorButton.Parent = stealFloorGui

local stealFloorCorner = Instance.new("UICorner")
stealFloorCorner.CornerRadius = UDim.new(0, 12)
stealFloorCorner.Parent = stealFloorButton

local stealFloorStroke = Instance.new("UIStroke")
stealFloorStroke.Color = Color3.fromRGB(255, 200, 200)
stealFloorStroke.Thickness = 2
stealFloorStroke.Transparency = 0.3
stealFloorStroke.Parent = stealFloorButton

stealFloorButton.MouseButton1Click:Connect(function()
    toggleStealFloor()
    if stealFloorActive then
        stealFloorButton.BackgroundColor3 = Color3.fromRGB(60, 220, 100)
        stealFloorButton.Text = "✅ Steal Floor"
    else
        stealFloorButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        stealFloorButton.Text = "🏗️ Steal Floor"
    end
end)

-- Deysnc Button
local desyncScreenGui = Instance.new("ScreenGui")
desyncScreenGui.Name = "QuantumDesyncButton"
desyncScreenGui.ResetOnSpawn = false
desyncScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
desyncScreenGui.Parent = CoreGui

local desyncButton = Instance.new("TextButton")
desyncButton.Name = "Deysnc"
desyncButton.Size = UDim2.new(0, 120, 0, 50)
desyncButton.Position = UDim2.new(1, -130, 0, 10)
desyncButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
desyncButton.BackgroundTransparency = 0.4
desyncButton.Text = "Deysnc"
desyncButton.TextColor3 = Color3.fromRGB(0, 0, 0)
desyncButton.TextSize = 14
desyncButton.Font = Enum.Font.GothamBold
desyncButton.TextWrapped = true
desyncButton.Draggable = true
desyncButton.Parent = desyncScreenGui

local desyncCorner = Instance.new("UICorner")
desyncCorner.CornerRadius = UDim.new(0, 12)
desyncCorner.Parent = desyncButton

local desyncStroke = Instance.new("UIStroke")
desyncStroke.Color = Color3.fromRGB(255, 200, 200)
desyncStroke.Thickness = 2
desyncStroke.Transparency = 0.3
desyncStroke.Parent = desyncButton

desyncButton.MouseButton1Click:Connect(function()
    executeAdvancedDesync()
    if antiHitActive then
        desyncButton.BackgroundColor3 = Color3.fromRGB(60, 220, 100)
        desyncButton.Text = "Active"
    else
        desyncButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        desyncButton.Text = "Deysnc"
    end
end)

-- MAIN GUI TASARIMI
local playerGui = player:WaitForChild('PlayerGui')

-- Clean old GUIs
local old = playerGui:FindFirstChild('VortexHelper')
if old then
    old:Destroy()
end

-- V Logo Button
local logoGui = Instance.new("ScreenGui")
logoGui.Name = "VortexLogo"
logoGui.ResetOnSpawn = false
logoGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
logoGui.Parent = playerGui

local logoButton = Instance.new("TextButton")
logoButton.Name = "VLogo"
logoButton.Size = UDim2.new(0, 35, 0, 35)
logoButton.Position = UDim2.new(0, 10, 0, 10)
logoButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
logoButton.BackgroundTransparency = 0.2
logoButton.Text = "V"
logoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
logoButton.TextSize = 16
logoButton.Font = Enum.Font.GothamBlack
logoButton.AutoButtonColor = false
logoButton.Draggable = true
logoButton.Parent = logoGui

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(1, 0)
logoCorner.Parent = logoButton

local logoStroke = Instance.new("UIStroke")
logoStroke.Color = Color3.fromRGB(200, 230, 255)
logoStroke.Thickness = 1.5
logoStroke.Parent = logoButton

-- Main GUI
local gui = Instance.new('ScreenGui')
gui.Name = 'VortexHelper'
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- Main Frame - TASARIM GÜNCELLENDİ
local mainFrame = Instance.new('Frame')
mainFrame.Size = UDim2.new(0, 150, 0, 160)
mainFrame.Position = UDim2.new(0.5, -75, 0.5, -80)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = gui

local mainCorner = Instance.new('UICorner', mainFrame)
mainCorner.CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new('UIStroke', mainFrame)
mainStroke.Thickness = 2
mainStroke.Color = Color3.fromRGB(100, 150, 255)
mainStroke.Transparency = 0.2

-- Header with Tabs
local header = Instance.new('Frame')
header.Size = UDim2.new(1, 0, 0, 25)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
header.BackgroundTransparency = 0.1
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

-- Tab Buttons - TASARIM GÜNCELLENDİ
local tab1Btn = Instance.new('TextButton')
tab1Btn.Name = 'Tab1'
tab1Btn.Size = UDim2.new(0.5, -2, 1, 0)
tab1Btn.Position = UDim2.new(0, 0, 0, 0)
tab1Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
tab1Btn.Text = "MAIN"
tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
tab1Btn.TextSize = 10
tab1Btn.Font = Enum.Font.GothamBold
tab1Btn.AutoButtonColor = false
tab1Btn.Parent = header

local tab1Corner = Instance.new("UICorner")
tab1Corner.CornerRadius = UDim.new(0, 8)
tab1Corner.Parent = tab1Btn

local tab2Btn = Instance.new('TextButton')
tab2Btn.Name = 'Tab2'
tab2Btn.Size = UDim2.new(0.5, -2, 1, 0)
tab2Btn.Position = UDim2.new(0.5, 0, 0, 0)
tab2Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
tab2Btn.Text = "VISUAL"
tab2Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
tab2Btn.TextSize = 10
tab2Btn.Font = Enum.Font.GothamBold
tab2Btn.AutoButtonColor = false
tab2Btn.Parent = header

local tab2Corner = Instance.new("UICorner")
tab2Corner.CornerRadius = UDim.new(0, 8)
tab2Corner.Parent = tab2Btn

-- Content Areas - BOŞLUKLAR KAPATILDI
local contentTab1 = Instance.new('Frame')
contentTab1.Name = 'Tab1Content'
contentTab1.Size = UDim2.new(1, -8, 1, -30)
contentTab1.Position = UDim2.new(0, 4, 0, 26)
contentTab1.BackgroundTransparency = 1
contentTab1.Visible = true
contentTab1.Parent = mainFrame

local contentTab2 = Instance.new('Frame')
contentTab2.Name = 'Tab2Content'
contentTab2.Size = UDim2.new(1, -8, 1, -30)
contentTab2.Position = UDim2.new(0, 4, 0, 26)
contentTab2.BackgroundTransparency = 1
contentTab2.Visible = false
contentTab2.Parent = mainFrame

-- Button Creation Function - RENK SİSTEMİ EKLENDİ
local function createButton(parent, text, yPos, callback, isActive)
    local btn = Instance.new('TextButton', parent)
    btn.Size = UDim2.new(0.95, 0, 0, 22)
    btn.Position = UDim2.new(0.025, 0, 0, yPos)
    btn.BackgroundColor3 = isActive and Color3.fromRGB(60, 220, 100) or Color3.fromRGB(220, 60, 60)
    btn.Text = text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 9
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    
    local btnCorner = Instance.new('UICorner', btn)
    btnCorner.CornerRadius = UDim.new(0, 6)
    
    local btnStroke = Instance.new('UIStroke', btn)
    btnStroke.Color = Color3.fromRGB(255, 255, 255)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.3
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- V Logo click event
local mainFrameVisible = false
logoButton.MouseButton1Click:Connect(function()
    mainFrameVisible = not mainFrameVisible
    mainFrame.Visible = mainFrameVisible
end)

-- Logo hover effect
logoButton.MouseEnter:Connect(function()
    TweenService:Create(logoButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.1,
        Size = UDim2.new(0, 37, 0, 37)
    }):Play()
end)

logoButton.MouseLeave:Connect(function()
    TweenService:Create(logoButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.2,
        Size = UDim2.new(0, 35, 0, 35)
    }):Play()
end)

-- Tab switching function
local currentTab = 1

local function switchTab(tabNumber)
    currentTab = tabNumber
    
    contentTab1.Visible = false
    contentTab2.Visible = false
    
    tab1Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    tab2Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    
    tab1Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tab2Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    
    if tabNumber == 1 then
        contentTab1.Visible = true
        tab1Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        contentTab2.Visible = true
        tab2Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        tab2Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

-- Tab button events
tab1Btn.MouseButton1Click:Connect(function() switchTab(1) end)
tab2Btn.MouseButton1Click:Connect(function() switchTab(2) end)

-- Load settings
local settings = loadSettings()

-- Apply settings
if settings.infJump ~= nil then gravityLow = settings.infJump end
if settings.espBase ~= nil then espBaseActive = settings.espBase end
if settings.espBest ~= nil then espBestActive = settings.espBest end
if settings.desync ~= nil then antiHitActive = settings.desync end
if settings.fpsDevourer ~= nil then fpsDevourerActive = settings.fpsDevourer end
if settings.playerESP ~= nil then playerEspActive = settings.playerESP end
if settings.stealFloor ~= nil then stealFloorActive = settings.stealFloor end

-- Create buttons for Tab 1 (Main) - RENK SİSTEMİ AKTİF
local yPos = 5
local fpsBtn = createButton(contentTab1, fpsDevourerActive and '✅ FPS' or '🎯 FPS', yPos, toggleFPSDevourer, fpsDevourerActive)
yPos = yPos + 25
local jumpBtn = createButton(contentTab1, gravityLow and '✅ Jump' or '🦘 Jump', yPos, switchGravityJump, gravityLow)
yPos = yPos + 25
createButton(contentTab1, '🚀 Fly Base', yPos, startFlyToBase, false)

-- Create buttons for Tab 2 (Visual) - RENK SİSTEMİ AKTİF
yPos = 5
local baseBtn = createButton(contentTab2, espBaseActive and '✅ Base' or '🏠 Base', yPos, toggleBaseESP, espBaseActive)
yPos = yPos + 25
local bestBtn = createButton(contentTab2, espBestActive and '✅ Best' or '🔥 Best', yPos, toggleBestESP, espBestActive)
yPos = yPos + 25
local playerBtn = createButton(contentTab2, playerEspActive and '✅ Player' or '👥 Player', yPos, togglePlayerESP, playerEspActive)

-- Button update functions
local function updateButtonColors()
    fpsBtn.BackgroundColor3 = fpsDevourerActive and Color3.fromRGB(60, 220, 100) or Color3.fromRGB(220, 60, 60)
    fpsBtn.Text = fpsDevourerActive and '✅ FPS' or '🎯 FPS'
    
    jumpBtn.BackgroundColor3 = gravityLow and Color3.fromRGB(60, 220, 100) or Color3.fromRGB(220, 60, 60)
    jumpBtn.Text = gravityLow and '✅ Jump' or '🦘 Jump'
    
    baseBtn.BackgroundColor3 = espBaseActive and Color3.fromRGB(60, 220, 100) or Color3.fromRGB(220, 60, 60)
    baseBtn.Text = espBaseActive and '✅ Base' or '🏠 Base'
    
    bestBtn.BackgroundColor3 = espBestActive and Color3.fromRGB(60, 220, 100) or Color3.fromRGB(220, 60, 60)
    bestBtn.Text = espBestActive and '✅ Best' or '🔥 Best'
    
    playerBtn.BackgroundColor3 = playerEspActive and Color3.fromRGB(60, 220, 100) or Color3.fromRGB(220, 60, 60)
    playerBtn.Text = playerEspActive and '✅ Player' or '👥 Player'
    
    -- Update external buttons
    if stealFloorActive then
        stealFloorButton.BackgroundColor3 = Color3.fromRGB(60, 220, 100)
        stealFloorButton.Text = "✅ Steal Floor"
    else
        stealFloorButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        stealFloorButton.Text = "🏗️ Steal Floor"
    end
    
    if antiHitActive then
        desyncButton.BackgroundColor3 = Color3.fromRGB(60, 220, 100)
        desyncButton.Text = "Active"
    else
        desyncButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        desyncButton.Text = "Deysnc"
    end
end

-- Override toggle functions to update buttons
local originalToggleFPS = toggleFPSDevourer
toggleFPSDevourer = function()
    originalToggleFPS()
    updateButtonColors()
end

local originalToggleJump = switchGravityJump
switchGravityJump = function()
    originalToggleJump()
    updateButtonColors()
end

local originalToggleBase = toggleBaseESP
toggleBaseESP = function()
    originalToggleBase()
    updateButtonColors()
end

local originalToggleBest = toggleBestESP
toggleBestESP = function()
    originalToggleBest()
    updateButtonColors()
end

local originalTogglePlayer = togglePlayerESP
togglePlayerESP = function()
    originalTogglePlayer()
    updateButtonColors()
end

local originalToggleSteal = toggleStealFloor
toggleStealFloor = function()
    originalToggleSteal()
    updateButtonColors()
end

local originalToggleDesync = executeAdvancedDesync
executeAdvancedDesync = function()
    originalToggleDesync()
    updateButtonColors()
end

-- Drag functionality for main frame
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

-- Enable features on start if saved
if fpsDevourerActive then
    enableFPSDevourer()
end

if gravityLow then
    switchGravityJump()
end

-- Update button colors on start
updateButtonColors()

-- Startup notification
showNotification("Script Loaded!", true)

print("🎯 Script Loaded!")
print("✅ Tüm özellikler hazır!")
