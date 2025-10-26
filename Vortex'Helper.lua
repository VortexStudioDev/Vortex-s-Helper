-- Vortex's Helper - Ultimate Edition
-- 3 Sekmeli Sistem: Combat, Movement, Visuals
-- Tüm özellikler entegre ve düzeltilmiş

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- NOTIFICATION SISTEMI
local function showNotification(message, duration)
    duration = duration or 3 -- Varsayılan 3 saniye
    
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "VortexNotificationGUI"
    notificationGui.ResetOnSpawn = false
    notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notificationGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local notification = Instance.new("Frame")
    notification.Name = "VortexNotification"
    notification.Size = UDim2.new(0, 280, 0, 70)
    notification.Position = UDim2.new(0.5, -140, 0.3, 0)
    notification.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    notification.BackgroundTransparency = 0
    notification.BorderSizePixel = 0
    notification.ZIndex = 1000
    notification.ClipsDescendants = true
    notification.Parent = notificationGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 100, 255)
    stroke.Thickness = 2
    stroke.Parent = notification

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = UDim2.new(0, 0, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "VORTEX HELPER"
    title.TextColor3 = Color3.fromRGB(100, 100, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = notification

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, 0, 0, 30)
    messageLabel.Position = UDim2.new(0, 0, 0, 30)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 12
    messageLabel.Parent = notification

    -- Timer sadece 1.5 saniyeden uzun bildirimlerde
    if duration > 1.5 then
        local timerLabel = Instance.new("TextLabel")
        timerLabel.Size = UDim2.new(1, 0, 0, 15)
        timerLabel.Position = UDim2.new(0, 0, 0, 55)
        timerLabel.BackgroundTransparency = 1
        timerLabel.Text = tostring(duration)
        timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        timerLabel.Font = Enum.Font.GothamBold
        timerLabel.TextSize = 12
        timerLabel.Parent = notification

        spawn(function()
            for i = duration, 1, -1 do
                timerLabel.Text = tostring(i)
                wait(1)
            end
            notificationGui:Destroy()
        end)
    else
        spawn(function()
            wait(duration)
            notificationGui:Destroy()
        end)
    end

    return notificationGui
end

-- ANA GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VortexHelper"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- FLOATING V BUTONU
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 20, 0.5, -25)
toggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
toggleButton.BackgroundTransparency = 0.1
toggleButton.Text = "V"
toggleButton.TextColor3 = Color3.fromRGB(100, 100, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 20
toggleButton.Active = true
toggleButton.Draggable = true
toggleButton.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = toggleButton

local glow = Instance.new("UIStroke")
glow.Color = Color3.fromRGB(100, 100, 255)
glow.Thickness = 2
glow.Transparency = 0.5
glow.Parent = toggleButton

-- ANA MENU
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 250)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(80, 80, 255)
frameStroke.Thickness = 2
frameStroke.Transparency = 0.3
frameStroke.Parent = mainFrame

-- HEADER
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "VORTEX HELPER"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextColor3 = Color3.fromRGB(100, 100, 255)
titleLabel.Parent = header

-- SEKMELER
local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(1, 0, 0, 30)
tabsFrame.Position = UDim2.new(0, 0, 0, 30)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = mainFrame

local tabsLayout = Instance.new("UIListLayout")
tabsLayout.FillDirection = Enum.FillDirection.Horizontal
tabsLayout.Parent = tabsFrame

-- SEKME BUTONLARI
local combatTab = Instance.new("TextButton")
combatTab.Size = UDim2.new(0.33, 0, 1, 0)
combatTab.Text = "Combat"
combatTab.Font = Enum.Font.Gotham
combatTab.TextSize = 11
combatTab.TextColor3 = Color3.fromRGB(255, 255, 255)
combatTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
combatTab.AutoButtonColor = false
combatTab.Parent = tabsFrame

local movementTab = Instance.new("TextButton")
movementTab.Size = UDim2.new(0.34, 0, 1, 0)
movementTab.Text = "Movement"
movementTab.Font = Enum.Font.Gotham
movementTab.TextSize = 11
movementTab.TextColor3 = Color3.fromRGB(255, 255, 255)
movementTab.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
movementTab.AutoButtonColor = false
movementTab.Parent = tabsFrame

local visualsTab = Instance.new("TextButton")
visualsTab.Size = UDim2.new(0.33, 0, 1, 0)
visualsTab.Text = "Visuals"
visualsTab.Font = Enum.Font.Gotham
visualsTab.TextSize = 11
visualsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
visualsTab.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
visualsTab.AutoButtonColor = false
visualsTab.Parent = tabsFrame

-- CONTENT FRAME
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -10, 1, -70)
contentFrame.Position = UDim2.new(0, 5, 0, 65)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 5)
contentLayout.FillDirection = Enum.FillDirection.Vertical
contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
contentLayout.Parent = contentFrame

-- BUTON OLUŞTURMA
local function createButton(name, color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 28)
    button.Text = name
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = color or Color3.fromRGB(40, 40, 60)
    button.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(80, 80, 255)
    buttonStroke.Thickness = 1
    buttonStroke.Parent = button
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = color or Color3.fromRGB(40, 40, 60)}):Play()
    end)
    
    return button
end

-- COMBAT SEKME İÇERİĞİ
local combatContent = Instance.new("Frame")
combatContent.Size = UDim2.new(1, 0, 1, 0)
combatContent.BackgroundTransparency = 1
combatContent.Visible = true
combatContent.Parent = contentFrame

local combatLayout = Instance.new("UIListLayout")
combatLayout.Padding = UDim.new(0, 5)
combatLayout.FillDirection = Enum.FillDirection.Vertical
combatLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
combatLayout.Parent = combatContent

local killButton = createButton("💀 Kill", Color3.fromRGB(255, 60, 60))
killButton.Parent = combatContent

local kickButton = createButton("🚪 Kick", Color3.fromRGB(255, 100, 60))
kickButton.Parent = combatContent

local iceButton = createButton("🧊 Ice Block", Color3.fromRGB(60, 150, 255))
iceButton.Parent = combatContent

local antiHitButton = createButton("🛡️ Vortex Anti-Hit", Color3.fromRGB(255, 120, 120))
antiHitButton.Parent = combatContent

-- MOVEMENT SEKME İÇERİĞİ
local movementContent = Instance.new("Frame")
movementContent.Size = UDim2.new(1, 0, 1, 0)
movementContent.BackgroundTransparency = 1
movementContent.Visible = false
movementContent.Parent = contentFrame

local movementLayout = Instance.new("UIListLayout")
movementLayout.Padding = UDim.new(0, 5)
movementLayout.FillDirection = Enum.FillDirection.Vertical
movementLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
movementLayout.Parent = movementContent

local speedButton = createButton("⚡ Speed Boost", Color3.fromRGB(60, 200, 100))
speedButton.Parent = movementContent

local infJumpButton = createButton("🦘 Inf Jump", Color3.fromRGB(120, 255, 120))
infJumpButton.Parent = movementContent

local flyButton = createButton("🚀 Fly To Base", Color3.fromRGB(255, 120, 120))
flyButton.Parent = movementContent

local floorButton = createButton("🏗️ 3rd Floor", Color3.fromRGB(255, 180, 60))
floorButton.Parent = movementContent

-- VISUALS SEKME İÇERİĞİ
local visualsContent = Instance.new("Frame")
visualsContent.Size = UDim2.new(1, 0, 1, 0)
visualsContent.BackgroundTransparency = 1
visualsContent.Visible = false
visualsContent.Parent = contentFrame

local visualsLayout = Instance.new("UIListLayout")
visualsLayout.Padding = UDim.new(0, 5)
visualsLayout.FillDirection = Enum.FillDirection.Vertical
visualsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
visualsLayout.Parent = visualsContent

local espBestButton = createButton("🔥 Chered Hub ESP Best", Color3.fromRGB(45, 45, 65))
espBestButton.Parent = visualsContent

local espBaseButton = createButton("🏠 Chered Hub ESP Base", Color3.fromRGB(45, 45, 65))
espBaseButton.Parent = visualsContent

local espPlayerButton = createButton("👥 Chered Hub ESP Player", Color3.fromRGB(45, 45, 65))
espPlayerButton.Parent = visualsContent

-- DEĞİŞKENLER
local iceOn = false
local iceConn
local platform, platformConn
local speedConn
local speedActive = false
local antiHitActive = false
local antiHitRunning = false
local infJumpActive = false
local flyActive = false
local flyConn
local espConfig = {
    enabledBest = false,
    enabledBase = false,
    enabledPlayer = false,
}
local espBoxes = {}

-- KILL BUTONU
killButton.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
            -- Kill bildirimi yok
        end
    end
end)

-- KICK BUTONU
kickButton.MouseButton1Click:Connect(function()
    LocalPlayer:Kick("Vortex's Helper - Kicked by User")
end)

-- ICE BLOCK (KAMERA YÖNÜNDE HAREKET)
iceButton.MouseButton1Click:Connect(function()
    iceOn = not iceOn
    
    if iceOn then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                iceConn = RunService.Heartbeat:Connect(function()
                    if iceOn and hrp then
                        hrp.Velocity = workspace.CurrentCamera.CFrame.LookVector * 25
                    end
                end)
            end
        end
        iceButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        iceButton.Text = "🧊 Ice [ON]"
        showNotification("Ice Block: ON - Camera direction movement", 1)
    else
        if iceConn then iceConn:Disconnect() iceConn = nil end
        iceButton.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
        iceButton.Text = "🧊 Ice Block"
        showNotification("Ice Block: OFF", 1)
    end
end)

-- VORTEX ANTI-HIT (CHERED HUB DESYNC SISTEMI)
antiHitButton.MouseButton1Click:Connect(function()
    if antiHitRunning then
        return
    end
    
    antiHitRunning = true
    antiHitButton.BackgroundColor3 = Color3.fromRGB(255, 220, 60)
    antiHitButton.Text = "🛡️ Anti-Hit [ACTIVE]"
    
    -- Hemen bildirim göster
    showNotification("Vortex Anti-Hit activating...", 2)
    
    -- CHERED HUB DESYNC SISTEMI
    local function enableMobileDesync()
        local success = pcall(function()
            local backpack = LocalPlayer:WaitForChild("Backpack")
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")
            
            local packages = ReplicatedStorage:WaitForChild("Packages", 5)
            if not packages then return false end
            
            local netFolder = packages:WaitForChild("Net", 5)
            if not netFolder then return false end
            
            local useItemRemote = netFolder:WaitForChild("RE/UseItem", 5)
            local teleportRemote = netFolder:WaitForChild("RE/QuantumCloner/OnTeleport", 5)
            if not useItemRemote or not teleportRemote then return false end

            -- Tool bul
            local toolNames = {"Quantum Cloner", "Brainrot", "brainrot"}
            local tool
            for _, toolName in ipairs(toolNames) do
                tool = backpack:FindFirstChild(toolName) or character:FindFirstChild(toolName)
                if tool then break end
            end
            if not tool then
                for _, item in ipairs(backpack:GetChildren()) do
                    if item:IsA("Tool") then tool=item break end
                end
            end

            if tool and tool.Parent==backpack then
                humanoid:EquipTool(tool)
                task.wait(0.5)
            end

            if setfflag then setfflag("WorldStepMax", "-9999999999") end
            task.wait(0.2)
            useItemRemote:FireServer()
            task.wait(1)
            teleportRemote:FireServer()
            task.wait(2)
            if setfflag then setfflag("WorldStepMax", "-1") end
            return true
        end)
        return success
    end

    task.spawn(function()
        local success = enableMobileDesync()
        antiHitRunning = false
        
        if success then
            antiHitActive = true
            antiHitButton.BackgroundColor3 = Color3.fromRGB(120, 255, 120)
            antiHitButton.Text = "🛡️ Anti-Hit [ON]"
        else
            antiHitActive = false
            antiHitButton.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
            antiHitButton.Text = "🛡️ Vortex Anti-Hit"
        end
    end)
end)

-- SPEED BOOST
local function stopSpeedControl()
    if speedConn then speedConn:Disconnect() speedConn = nil end
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
        end
    end
end

speedButton.MouseButton1Click:Connect(function()
    speedActive = not speedActive
    
    if speedActive then
        speedConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if hrp and humanoid then
                    local moveDirection = humanoid.MoveDirection
                    if moveDirection.Magnitude > 0.1 then
                        hrp.AssemblyLinearVelocity = Vector3.new(
                            moveDirection.X * 27,
                            hrp.AssemblyLinearVelocity.Y,
                            moveDirection.Z * 27
                        )
                    else
                        hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                    end
                end
            end
        end)
        speedButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        speedButton.Text = "⚡ Speed [ON]"
        showNotification("Speed Boost: Aktif", 1)
    else
        stopSpeedControl()
        speedButton.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
        speedButton.Text = "⚡ Speed Boost"
        showNotification("Speed Boost: Kapalı", 1)
    end
end)

-- INF JUMP (%1 DAHA KISALTILMIŞ)
infJumpButton.MouseButton1Click:Connect(function()
    infJumpActive = not infJumpActive
    
    if infJumpActive then
        workspace.Gravity = 40
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = 49.5 -- %1 daha kısa
            humanoid.UseJumpPower = true
        end
        
        infJumpButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        infJumpButton.Text = "🦘 Inf Jump [ON]"
        showNotification("Inf Jump: Aktif", 1)
    else
        workspace.Gravity = 196.2
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = 50
        end
        
        infJumpButton.BackgroundColor3 = Color3.fromRGB(120, 255, 120)
        infJumpButton.Text = "🦘 Inf Jump"
        showNotification("Inf Jump: Kapalı", 1)
    end
end)

-- FLY TO BASE
local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    flyActive = false
    flyButton.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
    flyButton.Text = "🚀 Fly To Base"
end

flyButton.MouseButton1Click:Connect(function()
    if flyActive then
        stopFly()
        showNotification("Fly: Kapalı", 1.5)
        return
    end

    local function findMyDeliveryPart()
        local plots = workspace:FindFirstChild("Plots")
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

    local destPart = findMyDeliveryPart()
    if not destPart then
        showNotification("Base not found", 1.5)
        return
    end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    flyActive = true
    flyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    flyButton.Text = "🚀 Flying..."
    showNotification("Flying to base...", 1.5)

    flyConn = RunService.Heartbeat:Connect(function()
        if not flyActive or not hrp or not hrp.Parent then
            stopFly()
            return
        end

        local destPos = destPart.Position
        local currentPos = hrp.Position
        local direction = (destPos - currentPos).Unit
        
        hrp.Velocity = direction * 50
        
        if (destPos - currentPos).Magnitude < 10 then
            stopFly()
            showNotification("Reached base!", 1.5)
        end
    end)
end)

-- 3RD FLOOR
local function destroyPlatform()
    if platform then platform:Destroy() platform = nil end
    if platformConn then platformConn:Disconnect() platformConn = nil end
    floorButton.BackgroundColor3 = Color3.fromRGB(255, 180, 60)
    floorButton.Text = "🏗️ 3rd Floor"
end

local function canRise()
    if not platform then return false end
    local origin = platform.Position + Vector3.new(0, platform.Size.Y/2, 0)
    local direction = Vector3.new(0, 2, 0)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {platform, LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    return not workspace:Raycast(origin, direction, rayParams)
end

floorButton.MouseButton1Click:Connect(function()
    if platform then
        destroyPlatform()
        showNotification("3rd Floor: Kapalı", 1)
        return
    end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    platform = Instance.new("Part")
    platform.Size = Vector3.new(6, 0.5, 6)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 0.3
    platform.Material = Enum.Material.Plastic
    platform.Color = Color3.fromRGB(255, 200, 0)
    platform.Position = root.Position - Vector3.new(0, root.Size.Y/2 + platform.Size.Y/2, 0)
    platform.Parent = workspace

    platformConn = RunService.Heartbeat:Connect(function(dt)
        if platform and root and root.Parent then
            local cur = platform.Position
            local newXZ = Vector3.new(root.Position.X, cur.Y, root.Position.Z)
            if canRise() then
                platform.Position = newXZ + Vector3.new(0, dt * 15, 0)
            else
                platform.Position = newXZ
            end
        end
    end)
    
    floorButton.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
    floorButton.Text = "🏗️ 3rd Floor [ON]"
    showNotification("3rd Floor: Aktif", 1)
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Died:Connect(destroyPlatform)
    end
end)

-- ESP SISTEMI (CHERED HUB SISTEMI - DÜZGÜN ÇALIŞAN)
local function clearAllBestSecret()
    local plotsFolder = Workspace:FindFirstChild("Plots")
    if not plotsFolder then return end
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        for _, inst in ipairs(plot:GetDescendants()) do
            if inst:IsA("BillboardGui") and (inst.Name == "Best_ESP" or inst.Name == "Secret_ESP") then
                pcall(function() inst:Destroy() end)
            end
        end
    end
end

local function clearPlayerESP()
    for plr, objs in pairs(espBoxes) do
        if objs.box then pcall(function() objs.box:Destroy() end) end
        if objs.text then pcall(function() objs.text:Destroy() end) end
    end
    espBoxes = {}
end

local function updatePlayerESP()
    if not espConfig.enabledPlayer then return end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp and not espBoxes[plr] then
                local box = Instance.new("BoxHandleAdornment")
                box.Size = Vector3.new(4, 6, 4)
                box.Adornee = hrp
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Transparency = 0.5
                box.Color3 = Color3.fromRGB(250, 0, 60)
                box.Parent = hrp

                local billboard = Instance.new("BillboardGui")
                billboard.Adornee = hrp
                billboard.Size = UDim2.new(0, 200, 0, 30)
                billboard.StudsOffset = Vector3.new(0, 4, 0)
                billboard.AlwaysOnTop = true
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.fromRGB(220, 0, 60)
                label.TextStrokeTransparency = 0
                label.Text = plr.Name
                label.Font = Enum.Font.GothamBold
                label.TextSize = 18
                label.Parent = billboard
                
                billboard.Parent = hrp
                
                espBoxes[plr] = {box = box, text = billboard}
            end
        end
    end
end

-- ESP BEST (CHERED HUB SISTEMI)
espBestButton.MouseButton1Click:Connect(function()
    espConfig.enabledBest = not espConfig.enabledBest
    
    if espConfig.enabledBest then
        espBestButton.BackgroundColor3 = Color3.fromRGB(60, 220, 120)
        espBestButton.Text = "🔥 Chered Hub ESP Best [ON]"
        showNotification("Chered Hub ESP Best: Aktif", 1)
    else
        espBestButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        espBestButton.Text = "🔥 Chered Hub ESP Best"
        showNotification("Chered Hub ESP Best: Kapalı", 1)
        clearAllBestSecret()
    end
end)

-- ESP BASE (CHERED HUB SISTEMI)
espBaseButton.MouseButton1Click:Connect(function()
    espConfig.enabledBase = not espConfig.enabledBase
    
    if espConfig.enabledBase then
        espBaseButton.BackgroundColor3 = Color3.fromRGB(120, 220, 255)
        espBaseButton.Text = "🏠 Chered Hub ESP Base [ON]"
        showNotification("Chered Hub ESP Base: Aktif", 1)
    else
        espBaseButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        espBaseButton.Text = "🏠 Chered Hub ESP Base"
        showNotification("Chered Hub ESP Base: Kapalı", 1)
    end
end)

-- ESP PLAYER (CHERED HUB SISTEMI - YENI OYUNCULARDA CALISIR)
espPlayerButton.MouseButton1Click:Connect(function()
    espConfig.enabledPlayer = not espConfig.enabledPlayer
    
    if espConfig.enabledPlayer then
        espPlayerButton.BackgroundColor3 = Color3.fromRGB(255, 170, 120)
        espPlayerButton.Text = "👥 Chered Hub ESP Player [ON]"
        showNotification("Chered Hub ESP Player: Aktif", 1)
        updatePlayerESP()
    else
        espPlayerButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        espPlayerButton.Text = "👥 Chered Hub ESP Player"
        showNotification("Chered Hub ESP Player: Kapalı", 1)
        clearPlayerESP()
    end
end)

-- YENI OYUNCU ESP FIX
Players.PlayerAdded:Connect(function(plr)
    if espConfig.enabledPlayer then
        plr.CharacterAdded:Connect(function()
            task.wait(1)
            updatePlayerESP()
        end)
    end
end)

-- SEKME DEĞİŞTİRME
local function switchTab(selectedTab)
    combatContent.Visible = (selectedTab == combatTab)
    movementContent.Visible = (selectedTab == movementTab)
    visualsContent.Visible = (selectedTab == visualsTab)
    
    combatTab.BackgroundColor3 = (selectedTab == combatTab) and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 60)
    movementTab.BackgroundColor3 = (selectedTab == movementTab) and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 60)
    visualsTab.BackgroundColor3 = (selectedTab == visualsTab) and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 60)
end

combatTab.MouseButton1Click:Connect(function() switchTab(combatTab) end)
movementTab.MouseButton1Click:Connect(function() switchTab(movementTab) end)
visualsTab.MouseButton1Click:Connect(function() switchTab(visualsTab) end)

-- UI TOGGLE
local uiVisible = false
toggleButton.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    mainFrame.Visible = uiVisible
    
    if uiVisible then
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    end
end)

-- AUTO CONTENT SIZE
contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    mainFrame.Size = UDim2.new(0, 200, 0, math.min(250, contentLayout.AbsoluteContentSize.Y + 80))
end)

-- TEMIZLIK
LocalPlayer.CharacterAdded:Connect(function()
    if iceConn then iceConn:Disconnect() iceConn = nil end
    iceOn = false
    iceButton.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
    iceButton.Text = "🧊 Ice Block"
    
    stopSpeedControl()
    speedActive = false
    speedButton.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
    speedButton.Text = "⚡ Speed Boost"
    
    stopFly()
    
    if infJumpActive then
        task.wait(1)
        workspace.Gravity = 196.2
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = 50
        end
        infJumpActive = false
        infJumpButton.BackgroundColor3 = Color3.fromRGB(120, 255, 120)
        infJumpButton.Text = "🦘 Inf Jump"
    end
end)

-- SCRIPT BASLANGICI
showNotification("Vortex Helper Activated! ✨", 3)
