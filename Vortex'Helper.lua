-- Vortex's Helper - Premium Version
-- Features: Inf Jump, FLY TO BASE, FPS Devourer, ESP Base, ESP Best, Deysnc

local Players = game:GetService('Players')
local UserInputService = game:GetService('UserInputService')
local Workspace = game:GetService('Workspace')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')
local CoreGui = game:GetService('CoreGui')
local player = Players.LocalPlayer

-- Safe wait for PlayerGui
local playerGui = player:WaitForChild("PlayerGui")

-- Error handling function
local function safeCall(func, errorMessage)
    local success, result = pcall(func)
    if not success then
        warn("Vortex Helper Error: " .. errorMessage)
        return nil
    end
    return result
end

-- Notification System
local function showNotification(message, isSuccess)
    safeCall(function()
        local notificationGui = Instance.new("ScreenGui")
        notificationGui.Name = "VortexNotify"
        notificationGui.ResetOnSpawn = false
        notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        notificationGui.Parent = CoreGui
        
        local notification = Instance.new("Frame")
        notification.Size = UDim2.new(0, 200, 0, 40)
        notification.Position = UDim2.new(0.5, -100, 0.15, 0)
        notification.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        notification.BackgroundTransparency = 0
        notification.BorderSizePixel = 0
        notification.ZIndex = 1000
        notification.Parent = notificationGui
        
        local notifCorner = Instance.new("UICorner")
        notifCorner.CornerRadius = UDim.new(0, 6)
        notifCorner.Parent = notification
        
        local notifStroke = Instance.new("UIStroke")
        notifStroke.Color = isSuccess and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
        notifStroke.Thickness = 1
        notifStroke.Parent = notification
        
        local notifText = Instance.new("TextLabel")
        notifText.Size = UDim2.new(1, -10, 1, -10)
        notifText.Position = UDim2.new(0, 5, 0, 5)
        notifText.BackgroundTransparency = 1
        notifText.Text = message
        notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
        notifText.TextSize = 12
        notifText.Font = Enum.Font.Gotham
        notifText.TextWrapped = true
        notifText.ZIndex = 1001
        notifText.Parent = notification
        
        notification.Position = UDim2.new(0.5, -100, 0.1, 0)
        local tweenIn = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -100, 0.15, 0)
        })
        tweenIn:Play()

        tweenIn.Completed:Connect(function()
            wait(1)
            
            if notification and notification.Parent then
                local tweenOut = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                    Position = UDim2.new(0.5, -100, 0.1, 0),
                    BackgroundTransparency = 1
                })
                
                notifText.TextTransparency = 1
                tweenOut:Play()
                
                tweenOut.Completed:Connect(function()
                    if notificationGui and notificationGui.Parent then
                        notificationGui:Destroy()
                    end
                end)
            end
        end)
    end, "Notification error")
end

----------------------------------------------------------------
-- FPS DEVOURER
----------------------------------------------------------------
local function enableFPSDevourer()
    safeCall(function()
        if setfpscap then
            setfpscap(999)
        end
    end, "FPS Cap error")
    
    safeCall(function()
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 100000
        lighting.Brightness = 2
    end, "Lighting error")
    
    showNotification("FPS Devourer Active!", true)
end

----------------------------------------------------------------
-- INF JUMP / JUMP BOOST (30 POWER)
----------------------------------------------------------------
local NORMAL_GRAV = 196.2
local REDUCED_GRAV = 50
local NORMAL_JUMP = 30
local BOOST_JUMP = 30
local BOOST_SPEED = 32

local gravityLow = false
local infiniteJumpConn

local function setJumpPower(jump)
    safeCall(function()
        local char = player.Character
        if char then
            local h = char:FindFirstChildOfClass('Humanoid')
            if h then
                h.JumpPower = jump
                h.UseJumpPower = true
            end
        end
    end, "SetJumpPower error")
end

local function enableInfiniteJump(state)
    safeCall(function()
        if infiniteJumpConn then
            infiniteJumpConn:Disconnect()
            infiniteJumpConn = nil
        end
        
        if state then
            infiniteJumpConn = UserInputService.JumpRequest:Connect(function()
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
        end
    end, "InfiniteJump error")
end

local function switchGravityJump()
    gravityLow = not gravityLow
    
    safeCall(function()
        Workspace.Gravity = gravityLow and REDUCED_GRAV or NORMAL_GRAV
        setJumpPower(gravityLow and BOOST_JUMP or NORMAL_JUMP)
        enableInfiniteJump(gravityLow)
    end, "Gravity switch error")
    
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
    return safeCall(function()
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
    end, "Find delivery part error")
end

local function cleanupFly()
    safeCall(function()
        if flyConn then
            flyConn:Disconnect()
            flyConn = nil
        end
        flyActive = false
    end, "Cleanup fly error")
end

local function startFlyToBase()
    if flyActive then
        cleanupFly()
        return
    end

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

    safeCall(function()
        flyConn = RunService.Heartbeat:Connect(function()
            if not flyActive or not char or not hrp or not hrp.Parent then
                cleanupFly()
                return
            end

            local pos = hrp.Position
            local destPos = destPart.Position
            local direction = (destPos - pos).Unit
            
            hrp.Velocity = direction * 50
        end)
    end, "Fly connection error")

    -- Auto stop when close to destination
    safeCall(function()
        local stopConn
        stopConn = RunService.Heartbeat:Connect(function()
            if not flyActive or not char or not hrp then
                if stopConn then
                    stopConn:Disconnect()
                end
                return
            end

            local pos = hrp.Position
            local destPos = destPart.Position
            local distance = (pos - destPos).Magnitude

            if distance < 10 then
                showNotification("Reached Base!", true)
                cleanupFly()
                if stopConn then
                    stopConn:Disconnect()
                end
            end
        end)
    end, "Fly stop connection error")
end

----------------------------------------------------------------
-- ESP BASE
----------------------------------------------------------------
local espBaseActive = false
local baseEspObjects = {}

local function clearBaseESP()
    safeCall(function()
        for _, obj in pairs(baseEspObjects) do
            pcall(function()
                obj:Destroy()
            end)
        end
        baseEspObjects = {}
    end, "Clear ESP error")
end

local function updateBaseESP()
    if not espBaseActive then return end
    
    clearBaseESP()
    
    safeCall(function()
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
    end, "Update ESP error")
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
end

----------------------------------------------------------------
-- DEYSNC SYSTEM (SIMPLIFIED)
----------------------------------------------------------------
local antiHitActive = false
local desyncButton

local function executeAdvancedDesync()
    if antiHitActive then return end
    
    antiHitActive = true
    showNotification("Desync Active!", true)
    
    safeCall(function()
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                -- Simple invulnerability
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            end
        end
    end, "Desync activation error")
end

local function deactivateAdvancedDesync()
    if not antiHitActive then return end
    
    antiHitActive = false
    showNotification("Desync Disabled", false)
    
    safeCall(function()
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            end
        end
    end, "Desync deactivation error")
end

-- Deysnc Button
local function createDeysncButton()
    safeCall(function()
        local desyncScreenGui = Instance.new("ScreenGui")
        desyncScreenGui.Name = "QuantumDesyncButton"
        desyncScreenGui.ResetOnSpawn = false
        desyncScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        desyncScreenGui.Parent = CoreGui

        desyncButton = Instance.new("TextButton")
        desyncButton.Name = "Deysnc"
        desyncButton.Size = UDim2.new(0, 100, 0, 40)
        desyncButton.Position = UDim2.new(1, -110, 0, 10)
        desyncButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
        desyncButton.BackgroundTransparency = 0.4
        desyncButton.Text = "Deysnc"
        desyncButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        desyncButton.TextSize = 12
        desyncButton.Font = Enum.Font.GothamBold
        desyncButton.TextWrapped = true
        desyncButton.Draggable = true
        desyncButton.Parent = desyncScreenGui

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
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
    end, "Deysnc button creation error")
end

----------------------------------------------------------------
-- MAIN GUI
----------------------------------------------------------------
local mainGui
local mainFrame

local function createMainGUI()
    safeCall(function()
        -- Clean old GUIs
        local old = playerGui:FindFirstChild('VortexHelper')
        if old then
            old:Destroy()
        end

        -- Main GUI
        mainGui = Instance.new('ScreenGui')
        mainGui.Name = 'VortexHelper'
        mainGui.ResetOnSpawn = false
        mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        mainGui.Parent = playerGui

        -- Main Frame
        mainFrame = Instance.new('Frame')
        mainFrame.Size = UDim2.new(0, 200, 0, 250)
        mainFrame.Position = UDim2.new(0.5, -100, 0.5, -125)
        mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
        mainFrame.BackgroundTransparency = 0.05
        mainFrame.BorderSizePixel = 0
        mainFrame.Visible = false
        mainFrame.Parent = mainGui

        local corner = Instance.new('UICorner', mainFrame)
        corner.CornerRadius = UDim.new(0, 8)

        local stroke = Instance.new('UIStroke', mainFrame)
        stroke.Thickness = 1.5
        stroke.Color = Color3.fromRGB(100, 150, 255)
        stroke.Transparency = 0.2

        -- Header
        local header = Instance.new('Frame')
        header.Size = UDim2.new(1, 0, 0, 25)
        header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        header.BackgroundTransparency = 0.1
        header.BorderSizePixel = 0
        header.Parent = mainFrame

        local headerCorner = Instance.new("UICorner")
        headerCorner.CornerRadius = UDim.new(0, 8)
        headerCorner.Parent = header

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
        local function createButton(parent, text, yPos, callback, isActive)
            local btn = Instance.new('TextButton', parent)
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
                safeCall(callback, "Button callback error")
            end)
            return btn
        end

        -- Create buttons
        local yPos = 5
        createButton(content, '🎯 FPS Devourer', yPos, enableFPSDevourer, false)
        yPos = yPos + 35
        createButton(content, gravityLow and '✅ Inf Jump ON' or '🦘 Inf Jump', yPos, switchGravityJump, gravityLow)
        yPos = yPos + 35
        createButton(content, '🚀 Fly to Base', yPos, startFlyToBase, false)
        yPos = yPos + 35
        createButton(content, espBaseActive and '✅ Base ESP ON' or '🏠 Base ESP', yPos, toggleBaseESP, espBaseActive)
        yPos = yPos + 35
        createButton(content, '🔄 Reset Char', yPos, function()
            local char = player.Character
            if char then
                char:BreakJoints()
                showNotification("Character Reset", true)
            end
        end, false)

        -- Drag functionality
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

    end, "Main GUI creation error")
end

-- V Logo
local function createVLogo()
    safeCall(function()
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

    end, "V Logo creation error")
end

-- Initialize everything
safeCall(function()
    createMainGUI()
    createVLogo()
    createDeysncButton()
    enableFPSDevourer()
    showNotification("Vortex's Helper Loaded!", true)
    
    print("🎯 Vortex's Helper Successfully Loaded!")
    print("✅ All systems initialized")
    print("🦘 Inf Jump Ready (30 Power)")
    print("🚀 Fly to Base Ready")
    print("🏠 ESP Base Ready")
    print("🌀 Deysnc System Ready")
    
end, "Initialization error")

-- Safe character reset
player.CharacterAdded:Connect(function()
    safeCall(function()
        wait(0.5)
        if desyncButton and antiHitActive then
            desyncButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
            desyncButton.Text = "Deysnc"
            antiHitActive = false
        end
    end, "Character reset handler error")
end)
