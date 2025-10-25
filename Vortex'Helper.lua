-- Vortex's Helper - Ultimate Edition
-- 3 Sekmeli Sistem: Combat, Movement, Visuals
-- Chered Hub Desync Sistemi Entegre

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- NOTIFICATION SISTEMI
local function notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Vortex Helper",
            Text = text or "",
            Duration = dur or 3
        })
    end)
end

-- ANA GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VortexHelper"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- FLOATING V BUTONU
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 45, 0, 45)
toggleButton.Position = UDim2.new(0, 20, 0.5, -22)
toggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
toggleButton.BackgroundTransparency = 0.1
toggleButton.Text = "V"
toggleButton.TextColor3 = Color3.fromRGB(100, 100, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 18
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
mainFrame.Size = UDim2.new(0, 180, 0, 220)
mainFrame.Position = UDim2.new(0.5, -90, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(80, 80, 255)
frameStroke.Thickness = 2
frameStroke.Transparency = 0.3
frameStroke.Parent = mainFrame

-- HEADER
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 25)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "VORTEX HELPER"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 12
titleLabel.TextColor3 = Color3.fromRGB(100, 100, 255)
titleLabel.Parent = header

-- SEKMELER
local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(1, 0, 0, 25)
tabsFrame.Position = UDim2.new(0, 0, 0, 25)
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
combatTab.TextSize = 10
combatTab.TextColor3 = Color3.fromRGB(255, 255, 255)
combatTab.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
combatTab.AutoButtonColor = false
combatTab.Parent = tabsFrame

local movementTab = Instance.new("TextButton")
movementTab.Size = UDim2.new(0.34, 0, 1, 0)
movementTab.Text = "Movement"
movementTab.Font = Enum.Font.Gotham
movementTab.TextSize = 10
movementTab.TextColor3 = Color3.fromRGB(255, 255, 255)
movementTab.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
movementTab.AutoButtonColor = false
movementTab.Parent = tabsFrame

local visualsTab = Instance.new("TextButton")
visualsTab.Size = UDim2.new(0.33, 0, 1, 0)
visualsTab.Text = "Visuals"
visualsTab.Font = Enum.Font.Gotham
visualsTab.TextSize = 10
visualsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
visualsTab.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
visualsTab.AutoButtonColor = false
visualsTab.Parent = tabsFrame

-- CONTENT FRAME
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -10, 1, -60)
contentFrame.Position = UDim2.new(0, 5, 0, 55)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 4)
contentLayout.FillDirection = Enum.FillDirection.Vertical
contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
contentLayout.Parent = contentFrame

-- BUTON OLUŞTURMA
local function createButton(name, color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 26)
    button.Text = name
    button.Font = Enum.Font.Gotham
    button.TextSize = 11
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = color or Color3.fromRGB(40, 40, 60)
    button.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
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
combatLayout.Padding = UDim.new(0, 4)
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
movementLayout.Padding = UDim.new(0, 4)
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
visualsLayout.Padding = UDim.new(0, 4)
visualsLayout.FillDirection = Enum.FillDirection.Vertical
visualsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
visualsLayout.Parent = visualsContent

local espBestButton = createButton("🔥 ESP Best", Color3.fromRGB(45, 45, 65))
espBestButton.Parent = visualsContent

local espBaseButton = createButton("🏠 ESP Base", Color3.fromRGB(45, 45, 65))
espBaseButton.Parent = visualsContent

local espPlayerButton = createButton("👥 ESP Player", Color3.fromRGB(45, 45, 65))
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
            notify("Vortex Helper", "Character killed", 2)
        end
    end
end)

-- KICK BUTONU
kickButton.MouseButton1Click:Connect(function()
    LocalPlayer:Kick("Vortex's Helper - Kicked by User")
end)

-- ICE BLOCK (ORIJINAL SISTEM)
iceButton.MouseButton1Click:Connect(function()
    iceOn = not iceOn
    
    if iceOn then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                iceConn = RunService.Heartbeat:Connect(function()
                    if iceOn and hrp then
                        hrp.Velocity = Vector3.new(0, 0, 0)
                    end
                end)
            end
        end
        iceButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        iceButton.Text = "🧊 Ice [ON]"
        notify("Vortex Helper", "Ice Block: ON", 2)
    else
        if iceConn then iceConn:Disconnect() iceConn = nil end
        iceButton.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
        iceButton.Text = "🧊 Ice Block"
        notify("Vortex Helper", "Ice Block: OFF", 2)
    end
end)

-- VORTEX ANTI-HIT (CHERED HUB DESYNC SISTEMI)
antiHitButton.MouseButton1Click:Connect(function()
    if antiHitRunning then
        notify("Vortex Helper", "Anti-Hit running...", 2)
        return
    end
    
    antiHitRunning = true
    antiHitButton.BackgroundColor3 = Color3.fromRGB(255, 220, 60)
    antiHitButton.Text = "🛡️ Anti-Hit [ACTIVE]"
    
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
            local tool
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") then 
                    tool = item 
                    break 
                end
            end

            if tool and tool.Parent == backpack then
                humanoid:EquipTool(tool)
                task.wait(0.2)
            end

            if setfflag then setfflag("WorldStepMax", "-9999999999") end
            task.wait(0.1)
            useItemRemote:FireServer()
            task.wait(0.5)
            teleportRemote:FireServer()
            task.wait(0.4)
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
            notify("Vortex Anti-Hit", "Anti-Hit activated! 🛡️", 3)
        else
            antiHitActive = false
            antiHitButton.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
            antiHitButton.Text = "🛡️ Vortex Anti-Hit"
            notify("Vortex Helper", "Anti-Hit failed", 2)
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
        notify("Vortex Helper", "Speed Boost: ON", 2)
    else
        stopSpeedControl()
        speedButton.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
        speedButton.Text = "⚡ Speed Boost"
        notify("Vortex Helper", "Speed Boost: OFF", 2)
    end
end)

-- INF JUMP
infJumpButton.MouseButton1Click:Connect(function()
    infJumpActive = not infJumpActive
    
    if infJumpActive then
        workspace.Gravity = 40
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = 52.5
            humanoid.UseJumpPower = true
        end
        
        infJumpButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        infJumpButton.Text = "🦘 Inf Jump [ON]"
        notify("Vortex Helper", "Inf Jump: ON (+5%)", 2)
    else
        workspace.Gravity = 196.2
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = 50
        end
        
        infJumpButton.BackgroundColor3 = Color3.fromRGB(120, 255, 120)
        infJumpButton.Text = "🦘 Inf Jump"
        notify("Vortex Helper", "Inf Jump: OFF", 2)
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
        notify("Vortex Helper", "Fly: OFF", 2)
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
        notify("Vortex Helper", "Base not found", 2)
        return
    end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    flyActive = true
    flyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    flyButton.Text = "🚀 Flying..."
    notify("Vortex Helper", "Flying to base...", 2)

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
            notify("Vortex Helper", "Reached base!", 2)
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
        notify("Vortex Helper", "3rd Floor: OFF", 2)
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
    notify("Vortex Helper", "3rd Floor: ON", 2)
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Died:Connect(destroyPlatform)
    end
end)

-- ESP SISTEMI
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
                box.Color3 = Color3.fromRGB(255, 0, 60)
                box.Parent = hrp

                local billboard = Instance.new("BillboardGui")
                billboard.Adornee = hrp
                billboard.Size = UDim2.new(0, 200, 0, 30)
                billboard.StudsOffset = Vector3.new(0, 4, 0)
                billboard.AlwaysOnTop = true
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.fromRGB(255, 0, 60)
                label.TextStrokeTransparency = 0
                label.Text = plr.Name
                label.Font = Enum.Font.GothamBold
                label.TextSize = 14
                label.Parent = billboard
                
                billboard.Parent = hrp
                
                espBoxes[plr] = {box = box, text = billboard}
            end
        end
    end
end

-- ESP BEST
espBestButton.MouseButton1Click:Connect(function()
    espConfig.enabledBest = not espConfig.enabledBest
    
    if espConfig.enabledBest then
        espBestButton.BackgroundColor3 = Color3.fromRGB(60, 220, 120)
        espBestButton.Text = "🔥 ESP Best [ON]"
        notify("Vortex Helper", "ESP Best: ON", 2)
    else
        espBestButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        espBestButton.Text = "🔥 ESP Best"
        notify("Vortex Helper", "ESP Best: OFF", 2)
    end
end)

-- ESP BASE
espBaseButton.MouseButton1Click:Connect(function()
    espConfig.enabledBase = not espConfig.enabledBase
    
    if espConfig.enabledBase then
        espBaseButton.BackgroundColor3 = Color3.fromRGB(120, 220, 255)
        espBaseButton.Text = "🏠 ESP Base [ON]"
        notify("Vortex Helper", "ESP Base: ON", 2)
    else
        espBaseButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        espBaseButton.Text = "🏠 ESP Base"
        notify("Vortex Helper", "ESP Base: OFF", 2)
    end
end)

-- ESP PLAYER
espPlayerButton.MouseButton1Click:Connect(function()
    espConfig.enabledPlayer = not espConfig.enabledPlayer
    
    if espConfig.enabledPlayer then
        espPlayerButton.BackgroundColor3 = Color3.fromRGB(255, 170, 120)
        espPlayerButton.Text = "👥 ESP Player [ON]"
        notify("Vortex Helper", "ESP Player: ON", 2)
        updatePlayerESP()
    else
        espPlayerButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        espPlayerButton.Text = "👥 ESP Player"
        notify("Vortex Helper", "ESP Player: OFF", 2)
        clearPlayerESP()
    end
end)

-- YENI OYUNCU ESP
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
        notify("Vortex Helper", "Menu opened", 2)
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        notify("Vortex Helper", "Menu closed", 2)
    end
end)

-- AUTO CONTENT SIZE
contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    mainFrame.Size = UDim2.new(0, 180, 0, math.min(220, contentLayout.AbsoluteContentSize.Y + 70))
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

notify("Vortex Helper", "Script activated! ✨", 5)
