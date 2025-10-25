-- Vortex's Helper - Ultimate Edition
-- Tüm özellikler entegre: Kill, Kick, Ice Block, 3rd Floor, Desync, Fly, Inf Jump, ESP
-- Logo: V | Marka: Vortex's Helper | Desync süresi: 1 saniye

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- CONFIG SISTEMI
local CONFIG_DIR = 'VortexHelper'
local CONFIG_FILE = CONFIG_DIR .. '/config.json'
local defaultConfig = { 
    espBest = false, 
    espSecret = false, 
    espBase = false,
    speedBoost = false,
    infJump = false,
    iceBlock = false,
    thirdFloor = false
}
local currentConfig = {}
local HttpService = game:GetService('HttpService')

local function safeDecode(str)
    local ok, res = pcall(function() return HttpService:JSONDecode(str) end)
    return ok and res or nil
end

local function safeEncode(tbl)
    local ok, res = pcall(function() return HttpService:JSONEncode(tbl) end)
    return ok and res or '{}'
end

local function ensureDir()
    if isfolder and not isfolder(CONFIG_DIR) then
        pcall(function() makefolder(CONFIG_DIR) end)
    end
end

local function loadConfig()
    for k, v in pairs(defaultConfig) do currentConfig[k] = v end
    if not (isfile and readfile and isfile(CONFIG_FILE)) then return end
    local ok, data = pcall(function() return readfile(CONFIG_FILE) end)
    if ok and data and #data > 0 then
        local decoded = safeDecode(data)
        if decoded then
            for k, v in pairs(defaultConfig) do
                if decoded[k] ~= nil then currentConfig[k] = decoded[k] end
            end
        end
    end
end

local function saveConfig()
    if not writefile then return end
    ensureDir()
    local json = safeEncode(currentConfig)
    pcall(function() writefile(CONFIG_FILE, json) end)
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
toggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
toggleButton.BackgroundTransparency = 0.2
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
glow.Transparency = 0.7
glow.Parent = toggleButton

-- ANA MENU
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 350)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
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
titleLabel.Text = "VORTEX'S HELPER"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextColor3 = Color3.fromRGB(100, 100, 255)
titleLabel.Parent = header

-- SCROLL FRAME
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -40)
scrollFrame.Position = UDim2.new(0, 5, 0, 35)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = scrollFrame

-- STATUS LABEL
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 20)
statusLabel.Position = UDim2.new(0.05, 0, 1, -25)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextColor3 = Color3.fromRGB(100, 100, 255)
statusLabel.TextSize = 11
statusLabel.Text = "Vortex Helper - Ready"
statusLabel.Parent = mainFrame

-- BUTON OLUŞTURMA
local function createButton(name, color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 30)
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
    
    button.Parent = scrollFrame
    return button
end

-- BUTONLARI OLUŞTUR
local killButton = createButton("💀 KILL", Color3.fromRGB(255, 60, 60))
local kickButton = createButton("🚪 KICK", Color3.fromRGB(255, 100, 60))
local iceButton = createButton("🧊 ICE BLOCK", Color3.fromRGB(60, 150, 255))
local floorButton = createButton("🏗️ 3RD FLOOR", Color3.fromRGB(255, 180, 60))
local speedButton = createButton("⚡ SPEED BOOST", Color3.fromRGB(60, 200, 100))
local desyncButton = createButton("🌀 DESYNC BODY", Color3.fromRGB(255, 120, 120))
local infJumpButton = createButton("🦘 INF JUMP", Color3.fromRGB(120, 255, 120))
local flyButton = createButton("🚀 FLY TO BASE", Color3.fromRGB(255, 120, 120))
local espBestButton = createButton("🔥 ESP BEST", Color3.fromRGB(45, 45, 65))
local espBaseButton = createButton("🏠 ESP BASE", Color3.fromRGB(45, 45, 65))
local espPlayerButton = createButton("👥 ESP PLAYER", Color3.fromRGB(45, 45, 65))

-- DEĞİŞKENLER
local iceOn = false
local iceConn
local platform, platformConn
local speedConn
local speedActive = false
local desyncActive = false
local antiHitRunning = false
local infJumpActive = false
local infJumpConn
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
            statusLabel.Text = "Character killed"
        end
    end
end)

-- KICK BUTONU
kickButton.MouseButton1Click:Connect(function()
    LocalPlayer:Kick("Vortex's Helper - Kicked by User")
end)

-- ICE BLOCK (AÇ/KAPA)
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
        iceButton.Text = "🧊 ICE [ON]"
        statusLabel.Text = "Ice Block: ON"
        currentConfig.iceBlock = true
    else
        if iceConn then 
            iceConn:Disconnect() 
            iceConn = nil 
        end
        iceButton.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
        iceButton.Text = "🧊 ICE BLOCK"
        statusLabel.Text = "Ice Block: OFF"
        currentConfig.iceBlock = false
    end
    saveConfig()
end)

-- 3RD FLOOR (AÇ/KAPA)
local function destroyPlatform()
    if platform then 
        platform:Destroy() 
        platform = nil 
    end
    if platformConn then 
        platformConn:Disconnect() 
        platformConn = nil 
    end
    floorButton.BackgroundColor3 = Color3.fromRGB(255, 180, 60)
    floorButton.Text = "🏗️ 3RD FLOOR"
    currentConfig.thirdFloor = false
    saveConfig()
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
        statusLabel.Text = "3rd Floor: OFF"
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
    floorButton.Text = "🏗️ 3RD FLOOR [ON]"
    statusLabel.Text = "3rd Floor: ON"
    currentConfig.thirdFloor = true
    saveConfig()
    
    -- Character ölünce platformu kaldır
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Died:Connect(destroyPlatform)
    end
end)

-- SPEED BOOST (AÇ/KAPA)
local function stopSpeedControl()
    if speedConn then 
        speedConn:Disconnect() 
        speedConn = nil 
    end
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
        speedButton.Text = "⚡ SPEED [ON]"
        statusLabel.Text = "Speed Boost: ON"
        currentConfig.speedBoost = true
    else
        stopSpeedControl()
        speedButton.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
        speedButton.Text = "⚡ SPEED BOOST"
        statusLabel.Text = "Speed Boost: OFF"
        currentConfig.speedBoost = false
    end
    saveConfig()
end)

-- DESYNC BODY (1 SANIYELIK)
desyncButton.MouseButton1Click:Connect(function()
    if antiHitRunning then
        statusLabel.Text = "Desync running..."
        return
    end
    
    antiHitRunning = true
    desyncButton.BackgroundColor3 = Color3.fromRGB(255, 220, 60)
    desyncButton.Text = "🌀 DESYNC [ACTIVE]"
    statusLabel.Text = "Desync activating..."
    
    -- 1 SANIYELIK DESYNC
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
            task.wait(0.5) -- Süreyi kısalttım
            teleportRemote:FireServer()
            task.wait(0.4) -- Toplam ~1 saniye
            if setfflag then setfflag("WorldStepMax", "-1") end
            return true
        end)
        return success
    end

    task.spawn(function()
        local success = enableMobileDesync()
        antiHitRunning = false
        
        if success then
            desyncButton.BackgroundColor3 = Color3.fromRGB(120, 255, 120)
            desyncButton.Text = "🌀 DESYNC [ON]"
            statusLabel.Text = "Desync: Activated (1s)"
            
            -- 2 saniye sonra butonu resetle
            task.wait(2)
            desyncButton.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
            desyncButton.Text = "🌀 DESYNC BODY"
        else
            desyncButton.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
            desyncButton.Text = "🌀 DESYNC BODY"
            statusLabel.Text = "Desync failed"
        end
    end)
end)

-- INF JUMP (AÇ/KAPA - %5 DAHA FAZLA)
infJumpButton.MouseButton1Click:Connect(function()
    infJumpActive = not infJumpActive
    
    if infJumpActive then
        workspace.Gravity = 40
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = 52.5 -- %5 daha fazla
            humanoid.UseJumpPower = true
        end
        
        infJumpButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        infJumpButton.Text = "🦘 INF JUMP [ON]"
        statusLabel.Text = "Inf Jump: ON (+5%)"
        currentConfig.infJump = true
    else
        workspace.Gravity = 196.2
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = 50
        end
        
        infJumpButton.BackgroundColor3 = Color3.fromRGB(120, 255, 120)
        infJumpButton.Text = "🦘 INF JUMP"
        statusLabel.Text = "Inf Jump: OFF"
        currentConfig.infJump = false
    end
    saveConfig()
end)

-- FLY TO BASE (AÇ/KAPA)
local function stopFly()
    if flyConn then 
        flyConn:Disconnect() 
        flyConn = nil 
    end
    flyActive = false
    flyButton.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
    flyButton.Text = "🚀 FLY TO BASE"
end

flyButton.MouseButton1Click:Connect(function()
    if flyActive then
        stopFly()
        statusLabel.Text = "Fly: OFF"
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
        statusLabel.Text = "Base not found"
        return
    end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    flyActive = true
    flyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    flyButton.Text = "🚀 FLYING..."
    statusLabel.Text = "Flying to base..."

    flyConn = RunService.Heartbeat:Connect(function()
        if not flyActive or not hrp or not hrp.Parent then
            stopFly()
            return
        end

        local destPos = destPart.Position
        local currentPos = hrp.Position
        local direction = (destPos - currentPos).Unit
        
        hrp.Velocity = direction * 50
        
        -- Base'e ulaştıysa dur
        if (destPos - currentPos).Magnitude < 10 then
            stopFly()
            statusLabel.Text = "Reached base!"
        end
    end)
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
                -- ESP Kutusu
                local box = Instance.new("BoxHandleAdornment")
                box.Size = Vector3.new(4, 6, 4)
                box.Adornee = hrp
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Transparency = 0.5
                box.Color3 = Color3.fromRGB(255, 0, 60)
                box.Parent = hrp

                -- İsim etiketi
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
    currentConfig.espBest = espConfig.enabledBest
    saveConfig()
    
    if espConfig.enabledBest then
        espBestButton.BackgroundColor3 = Color3.fromRGB(60, 220, 120)
        espBestButton.Text = "🔥 ESP BEST [ON]"
        statusLabel.Text = "ESP Best: ON"
    else
        espBestButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        espBestButton.Text = "🔥 ESP BEST"
        statusLabel.Text = "ESP Best: OFF"
    end
end)

-- ESP BASE
espBaseButton.MouseButton1Click:Connect(function()
    espConfig.enabledBase = not espConfig.enabledBase
    currentConfig.espBase = espConfig.enabledBase
    saveConfig()
    
    if espConfig.enabledBase then
        espBaseButton.BackgroundColor3 = Color3.fromRGB(120, 220, 255)
        espBaseButton.Text = "🏠 ESP BASE [ON]"
        statusLabel.Text = "ESP Base: ON"
    else
        espBaseButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        espBaseButton.Text = "🏠 ESP BASE"
        statusLabel.Text = "ESP Base: OFF"
    end
end)

-- ESP PLAYER (YENI OYUNCULARDA CALISIR)
espPlayerButton.MouseButton1Click:Connect(function()
    espConfig.enabledPlayer = not espConfig.enabledPlayer
    
    if espConfig.enabledPlayer then
        espPlayerButton.BackgroundColor3 = Color3.fromRGB(255, 170, 120)
        espPlayerButton.Text = "👥 ESP PLAYER [ON]"
        statusLabel.Text = "ESP Player: ON"
        updatePlayerESP()
    else
        espPlayerButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        espPlayerButton.Text = "👥 ESP PLAYER"
        statusLabel.Text = "ESP Player: OFF"
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

-- UI TOGGLE
local uiVisible = false
toggleButton.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    mainFrame.Visible = uiVisible
    
    if uiVisible then
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "Vortex Helper - Menu Open"
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        statusLabel.Text = "Vortex Helper - Menu Closed"
    end
end)

-- AUTO SCROLL SIZE
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    mainFrame.Size = UDim2.new(0, 220, 0, math.min(350, layout.AbsoluteContentSize.Y + 60))
end)

-- CONFIG YUKLE VE AYARLARI UYGULA
loadConfig()

-- Ice Block
if currentConfig.iceBlock then
    iceOn = true
    iceButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    iceButton.Text = "🧊 ICE [ON]"
end

-- 3rd Floor
if currentConfig.thirdFloor then
    task.spawn(function()
        task.wait(1)
        floorButton:MouseButton1Click()
    end)
end

-- Speed Boost
if currentConfig.speedBoost then
    speedActive = true
    speedButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    speedButton.Text = "⚡ SPEED [ON]"
    task.spawn(function()
        task.wait(0.5)
        speedButton:MouseButton1Click()
    end)
end

-- Inf Jump
if currentConfig.infJump then
    infJumpActive = true
    infJumpButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    infJumpButton.Text = "🦘 INF JUMP [ON]"
    task.spawn(function()
        task.wait(0.5)
        infJumpButton:MouseButton1Click()
    end)
end

-- ESP Best
if currentConfig.espBest then
    espConfig.enabledBest = true
    espBestButton.BackgroundColor3 = Color3.fromRGB(60, 220, 120)
    espBestButton.Text = "🔥 ESP BEST [ON]"
end

-- ESP Base
if currentConfig.espBase then
    espConfig.enabledBase = true
    espBaseButton.BackgroundColor3 = Color3.fromRGB(120, 220, 255)
    espBaseButton.Text = "🏠 ESP BASE [ON]"
end

statusLabel.Text = "Vortex Helper - Ready"

-- TEMIZLIK
LocalPlayer.CharacterAdded:Connect(function()
    if iceConn then 
        iceConn:Disconnect() 
        iceConn = nil 
    end
    iceOn = false
    iceButton.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
    iceButton.Text = "🧊 ICE BLOCK"
    
    stopSpeedControl()
    speedActive = false
    speedButton.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
    speedButton.Text = "⚡ SPEED BOOST"
    
    stopFly()
    
    if infJumpActive then
        task.wait(1)
        infJumpButton:MouseButton1Click()
    end
end)
