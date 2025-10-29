-- Vortex's Helper - Premium Version
-- Features: Inf Jump, FLY TO BASE, FPS Devourer, ESP Base, ESP Best, Deysnc

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UserInputService = game:GetService('UserInputService')
local Workspace = game:GetService('Workspace')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')
local CoreGui = game:GetService('CoreGui')
local HttpService = game:GetService('HttpService')
local player = Players.LocalPlayer

-- Wait for PlayerGui safely
local playerGui
local success, err = pcall(function()
    playerGui = player:WaitForChild('PlayerGui')
end)
if not success then
    playerGui = CoreGui
end

-- Initialize variables
local gravityLow = false
local espBaseActive = false
local espBestActive = false
local antiHitActive = false

-- Settings folder
local VortexFolder = Workspace:FindFirstChild("Vortex'sHelper")
if not VortexFolder then
    VortexFolder = Instance.new("Folder")
    VortexFolder.Name = "Vortex'sHelper"
    VortexFolder.Parent = Workspace
end

-- Save/Load settings
local function saveSettings()
    local settings = {
        infJump = gravityLow,
        espBase = espBaseActive,
        espBest = espBestActive,
        desync = antiHitActive
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

-- Safe Notification System
local function showNotification(message, isSuccess)
    local success, err = pcall(function()
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
    end)
    
    if not success then
        warn("Notification Error: " .. tostring(err))
    end
end

----------------------------------------------------------------
-- FPS DEVOURER
----------------------------------------------------------------
local function enableFPSDevourer()
    pcall(function()
        if setfpscap then
            setfpscap(999)
        end
    end)
    
    pcall(function()
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 100000
        lighting.Brightness = 2
    end)
    
    showNotification("FPS Devourer Active!", true)
end

----------------------------------------------------------------
-- INF JUMP / JUMP BOOST (30 POWER)
----------------------------------------------------------------
local NORMAL_GRAV = 196.2
local REDUCED_GRAV = 40
local NORMAL_JUMP = 30
local BOOST_JUMP = 30

local gravityLow = false
local infiniteJumpConn

local function setJumpPower(jump)
    pcall(function()
        local char = player.Character
        if char then
            local h = char:FindFirstChildOfClass('Humanoid')
            if h then
                h.JumpPower = jump
                h.UseJumpPower = true
            end
        end
    end)
end

local function enableInfiniteJump(state)
    if infiniteJumpConn then
        infiniteJumpConn:Disconnect()
        infiniteJumpConn = nil
    end
    
    if state then
        infiniteJumpConn = UserInputService.JumpRequest:Connect(function()
            pcall(function()
                local char = player.Character
                if char and gravityLow then
                    local h = char:FindFirstChildOfClass('Humanoid')
                    local root = char:FindFirstChild('HumanoidRootPart')
                    
                    if h and root and h:GetState() ~= Enum.HumanoidStateType.Seated then
                        root.Velocity = Vector3.new(
                            root.Velocity.X,
                            h.JumpPower,
                            root.Velocity.Z
                        )
                    end
                end
            end)
        end)
    end
end

local function switchGravityJump()
    gravityLow = not gravityLow
    
    pcall(function()
        Workspace.Gravity = gravityLow and REDUCED_GRAV or NORMAL_GRAV
        setJumpPower(gravityLow and BOOST_JUMP or NORMAL_JUMP)
        enableInfiniteJump(gravityLow)
    end)
    
    saveSettings()
    
    if gravityLow then
        showNotification("Inf Jump Active! (30 Power)", true)
    else
        showNotification("Inf Jump Disabled", false)
    end
end

----------------------------------------------------------------
-- FLY TO BASE
----------------------------------------------------------------
local flyActive = false
local flyConn

local function findMyDeliveryPart()
    return pcall(function()
        local plots = Workspace:FindFirstChild('Plots')
        if plots then
            for _, plot in ipairs(plots:GetChildren()) do
                local sign = plot:FindFirstChild('PlotSign')
                if sign then
                    local yourBase = sign:FindFirstChild('YourBase')
                    if yourBase and yourBase.Enabled then
                        local delivery = plot:FindFirstChild('DeliveryHitbox')
                        if delivery and delivery:IsA('BasePart') then
                            return delivery
                        end
                    end
                end
            end
        end
        return nil
    end)
end

local function startFlyToBase()
    if flyActive then return end

    local destPart = findMyDeliveryPart()
    if not destPart then
        showNotification("Base Not Found!", false)
        return
    end

    local char = player.Character
    if not char then
        showNotification("No Character!", false)
        return
    end

    local hrp = char:FindFirstChild('HumanoidRootPart')
    local hum = char:FindFirstChildOfClass('Humanoid')
    if not (hrp and hum) then
        showNotification("Character not ready!", false)
        return
    end

    flyActive = true
    showNotification("Flying to Base...", true)

    pcall(function()
        if flyConn then
            flyConn:Disconnect()
        end
        
        flyConn = RunService.Heartbeat:Connect(function()
            if not flyActive or not char or not hrp or not hrp.Parent then
                if flyConn then
                    flyConn:Disconnect()
                    flyConn = nil
                end
                flyActive = false
                return
            end

            local pos = hrp.Position
            local destPos = destPart.Position
            local direction = (destPos - pos).Unit
            
            hrp.Velocity = direction * 50

            -- Auto stop when close
            local distance = (pos - destPos).Magnitude
            if distance < 10 then
                showNotification("Reached Base!", true)
                if flyConn then
                    flyConn:Disconnect()
                    flyConn = nil
                end
                flyActive = false
            end
        end)
    end)
end

----------------------------------------------------------------
-- ESP BASE
----------------------------------------------------------------
local espBaseActive = false
local baseEspObjects = {}

local function clearBaseESP()
    pcall(function()
        for _, obj in pairs(baseEspObjects) do
            pcall(function()
                obj:Destroy()
            end)
        end
        baseEspObjects = {}
    end)
end

local function updateBaseESP()
    if not espBaseActive then return end
    
    clearBaseESP()
    
    pcall(function()
        local plots = Workspace:FindFirstChild('Plots')
        if not plots then return end

        for _, plot in pairs(plots:GetChildren()) do
            local purchases = plot:FindFirstChild('Purchases')
            if purchases then
                local pb = purchases:FindFirstChild('PlotBlock')
                if pb then
                    local main = pb:FindFirstChild('Main')
                    if main then
                        local billboard = Instance.new('BillboardGui')
                        billboard.Name = 'Base_ESP'
                        billboard.Size = UDim2.new(0, 100, 0, 30)
                        billboard.StudsOffset = Vector3.new(0, 3, 0)
                        billboard.AlwaysOnTop = true
                        billboard.Parent = main

                        local label = Instance.new('TextLabel')
                        label.Text = "BASE"
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.TextColor3 = Color3.fromRGB(255, 0, 0)
                        label.Font = Enum.Font.Arcade
                        label.TextSize = 14
                        label.Parent = billboard

                        table.insert(baseEspObjects, billboard)
                    end
                end
            end
        end
    end)
end

local function toggleBaseESP()
    espBaseActive = not espBaseActive
    if espBaseActive then
        showNotification("Base ESP Active!", true)
        updateBaseESP()
    else
        showNotification("Base ESP Disabled", false)
        clearBaseESP()
    end
    saveSettings()
end

----------------------------------------------------------------
-- ESP BEST
----------------------------------------------------------------
local espBestActive = false
local bestEspObjects = {}

local function clearBestESP()
    pcall(function()
        for _, obj in pairs(bestEspObjects) do
            pcall(function()
                obj:Destroy()
            end)
        end
        bestEspObjects = {}
    end)
end

local function toggleBestESP()
    espBestActive = not espBestActive
    if espBestActive then
        showNotification("Best ESP Active!", true)
    else
        showNotification("Best ESP Disabled", false)
        clearBestESP()
    end
    saveSettings()
end

----------------------------------------------------------------
-- DEYSNC SYSTEM
----------------------------------------------------------------
local antiHitActive = false

local function executeAdvancedDesync()
    if antiHitActive then return end
    
    antiHitActive = true
    showNotification("Desync Active!", true)
    
    pcall(function()
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            end
        end
    end)
    
    saveSettings()
end

local function deactivateAdvancedDesync()
    if not antiHitActive then return end
    
    antiHitActive = false
    showNotification("Desync Disabled", false)
    
    pcall(function()
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            end
        end
    end)
    
    saveSettings()
end

-- Deysnc Button
local desyncButton
local function createDeysncButton()
    pcall(function()
        local desyncScreenGui = Instance.new("ScreenGui")
        desyncScreenGui.Name = "QuantumDesyncButton"
        desyncScreenGui.ResetOnSpawn = false
        desyncScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        desyncScreenGui.Parent = CoreGui

        desyncButton = Instance.new("TextButton")
        desyncButton.Name = "Deysnc"
        desyncButton.Size = UDim2.new(0, 120, 0, 50)
        desyncButton.Position = UDim2.new(1, -130, 0, 10)
        desyncButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
        desyncButton.BackgroundTransparency = 0.4
        desyncButton.Text = "Deysnc"
        desyncButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        desyncButton.TextSize = 14
        desyncButton.Font = Enum.Font.GothamBold
        desyncButton.TextWrapped = true
        desyncButton.Draggable = true
        desyncButton.Parent = desyncScreenGui

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 12)
        buttonCorner.Parent = desyncButton

        desyncButton.MouseButton1Click:Connect(function()
            if antiHitActive then
                deactivateAdvancedDesync()
                desyncButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
                desyncButton.Text = "Deysnc"
            else
                executeAdvancedDesync()
                desyncButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                desyncButton.Text = "Active"
            end
        end)
    end)
end

----------------------------------------------------------------
-- MAIN GUI
----------------------------------------------------------------
local mainFrame
local function createMainGUI()
    pcall(function()
        -- Clean old GUIs
        local old = playerGui:FindFirstChild('VortexHelper')
        if old then
            old:Destroy()
        end

        -- Main GUI
        local gui = Instance.new('ScreenGui')
        gui.Name = 'VortexHelper'
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = playerGui

        -- Main Frame
        mainFrame = Instance.new('Frame')
        mainFrame.Size = UDim2.new(0, 200, 0, 250)
        mainFrame.Position = UDim2.new(0.5, -100, 0.5, -125)
        mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
        mainFrame.BackgroundTransparency = 0.05
        mainFrame.BorderSizePixel = 0
        mainFrame.Visible = false
        mainFrame.Parent = gui

        local corner = Instance.new('UICorner', mainFrame)
        corner.CornerRadius = UDim.new(0, 8)

        local stroke = Instance.new('UIStroke', mainFrame)
        stroke.Thickness = 1.5
        stroke.Color = Color3.fromRGB(100, 150, 255)
        stroke.Transparency = 0.2

        -- Header with Tabs
        local header = Instance.new('Frame')
        header.Size = UDim2.new(1, 0, 0, 25)
        header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        header.BackgroundTransparency = 0.1
        header.BorderSizePixel = 0
        header.Parent = mainFrame

        -- Title
        local title = Instance.new('TextLabel', header)
        title.Size = UDim2.new(1, 0, 1, 0)
        title.Text = 'Vortex Helper'
        title.TextColor3 = Color3.fromRGB(100, 200, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 12
        title.BackgroundTransparency = 1

        -- Content Area
        local content = Instance.new('Frame')
        content.Name = 'Content'
        content.Size = UDim2.new(1, -8, 1, -30)
        content.Position = UDim2.new(0, 4, 0, 26)
        content.BackgroundTransparency = 1
        content.Parent = mainFrame

        -- Button Creation Function
        local function createButton(text, yPos, callback, isActive)
            local btn = Instance.new('TextButton', content)
            btn.Size = UDim2.new(0.9, 0, 0, 30)
            btn.Position = UDim2.new(0.05, 0, 0, yPos)
            btn.BackgroundColor3 = isActive and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
            btn.Text = text
            btn.Font = Enum.Font.GothamSemibold
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.TextSize = 11
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false
            
            local btnCorner = Instance.new('UICorner', btn)
            btnCorner.CornerRadius = UDim.new(0, 6)
            
            btn.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
            
            return btn
        end

        -- Create buttons
        local yPos = 5
        createButton('🎯 FPS Devourer', yPos, enableFPSDevourer, false)
        yPos = yPos + 35
        createButton(gravityLow and '✅ Inf Jump ON' or '🦘 Inf Jump', yPos, switchGravityJump, gravityLow)
        yPos = yPos + 35
        createButton('🚀 Fly to Base', yPos, startFlyToBase, false)
        yPos = yPos + 35
        createButton(espBaseActive and '✅ Base ESP ON' or '🏠 Base ESP', yPos, toggleBaseESP, espBaseActive)
        yPos = yPos + 35
        createButton(espBestActive and '✅ Best ESP ON' or '🔥 Best ESP', yPos, toggleBestESP, espBestActive)

        -- Drag functionality
        local dragging = false
        local dragInput, dragStart, startPos

        mainFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
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
    end)
end

-- V Logo
local function createVLogo()
    pcall(function()
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

        -- Toggle main GUI
        logoButton.MouseButton1Click:Connect(function()
            if mainFrame then
                mainFrame.Visible = not mainFrame.Visible
                if mainFrame.Visible then
                    showNotification("Vortex Helper Opened", true)
                else
                    showNotification("Vortex Helper Closed", false)
                end
            end
        end)
    end)
end

-- Initialize everything
local function initialize()
    -- Load settings first
    local settings = loadSettings()
    
    -- Apply settings
    if settings.infJump ~= nil then
        gravityLow = settings.infJump
    end
    
    if settings.espBase ~= nil then
        espBaseActive = settings.espBase
    end
    
    if settings.espBest ~= nil then
        espBestActive = settings.espBest
    end
    
    if settings.desync ~= nil then
        antiHitActive = settings.desync
    end

    -- Create GUIs
    createMainGUI()
    createVLogo()
    createDeysncButton()
    
    -- Apply Inf Jump if active
    if gravityLow then
        pcall(function()
            Workspace.Gravity = REDUCED_GRAV
            setJumpPower(BOOST_JUMP)
            enableInfiniteJump(true)
        end)
    end
    
    -- Update Deysnc button if active
    if antiHitActive and desyncButton then
        desyncButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        desyncButton.Text = "Active"
    end

    enableFPSDevourer()
    showNotification("Vortex's Helper Loaded!", true)
    
    print("🎯 Vortex's Helper Successfully Loaded!")
    print("✅ All systems initialized")
end

-- Safe character reset
player.CharacterAdded:Connect(function()
    wait(0.5)
    if desyncButton and antiHitActive then
        desyncButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
        desyncButton.Text = "Deysnc"
        antiHitActive = false
    end
end)

-- Start the script
initialize()
