-- Vortex's Helper - Ultimate Edition
-- Tüm özellikler entegre: Kill, Kick, Ice Block, 3rd Floor, Speed, Desync, ESP, Fly, Inf Jump
-- Logo: V | Marka: Vortex's Helper

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- CONFIG SISTEMI
local CONFIG_DIR = 'VortexHelper'
local CONFIG_FILE = CONFIG_DIR .. '/config.json'
local defaultConfig = { espBest = false, espSecret = false, espBase = false }
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

local saveDebounce = false
local function saveConfig()
    if not writefile then return end
    if saveDebounce then return end
    saveDebounce = true
    task.delay(0.35, function() saveDebounce = false end)
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
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 20
toggleButton.TextColor3 = Color3.fromRGB(100, 100, 255)
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
mainFrame.Size = UDim2.new(0, 220, 0, 300)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -150)
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

-- BUTON CONTAINER
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, -10, 1, -40)
buttonContainer.Position = UDim2.new(0, 5, 0, 35)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.Parent = buttonContainer

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
    
    button.Parent = buttonContainer
    return button
end

-- TEMEL BUTONLAR
local killButton = createButton("💀 KILL", Color3.fromRGB(255, 60, 60))
local kickButton = createButton("🚪 KICK", Color3.fromRGB(255, 100, 60))
local iceButton = createButton("🧊 ICE BLOCK", Color3.fromRGB(60, 150, 255))
local floorButton = createButton("🏗️ 3RD FLOOR", Color3.fromRGB(255, 180, 60))

-- ESP BUTONLARI
local espBestButton = createButton("🔥 ESP BEST", Color3.fromRGB(45, 45, 65))
local espSecretButton = createButton("💎 ESP SECRET", Color3.fromRGB(45, 45, 65))
local espBaseButton = createButton("🏠 ESP BASE", Color3.fromRGB(45, 45, 65))
local espPlayerButton = createButton("👥 ESP PLAYER", Color3.fromRGB(45, 45, 65))

-- TOOLS BUTONLARI
local speedButton = createButton("⚡ SPEED BOOST", Color3.fromRGB(60, 200, 100))
local desyncButton = createButton("🌀 DESYNC BODY", Color3.fromRGB(255, 120, 120))
local infJumpButton = createButton("🦘 INF JUMP", Color3.fromRGB(120, 255, 120))
local flyButton = createButton("🚀 FLY TO BASE", Color3.fromRGB(255, 120, 120))

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

-- ICE BLOCK
do
    local iceOn = false
    local iceConn

    iceButton.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum = char:FindFirstChildOfClass("Humanoid")
        iceOn = not iceOn
        
        if iceOn then
            iceButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
            iceButton.Text = "🧊 ICE [ON]"
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                iceConn = RunService.RenderStepped:Connect(function()
                    if iceOn and hrp then
                        hrp.Velocity = Vector3.new(0, 0, 0)
                    end
                end)
            end
            statusLabel.Text = "Ice Block: ON"
        else
            if iceConn then iceConn:Disconnect() iceConn = nil end
            iceButton.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
            iceButton.Text = "🧊 ICE BLOCK"
            statusLabel.Text = "Ice Block: OFF"
        end
    end)
end

-- 3RD FLOOR
do
    local platform, connection
    local active = false
    local RISE_SPEED = 15

    local function destroyPlatform()
        if platform then platform:Destroy() platform = nil end
        active = false
        if connection then connection:Disconnect() connection = nil end
        floorButton.BackgroundColor3 = Color3.fromRGB(255, 180, 60)
        floorButton.Text = "🏗️ 3RD FLOOR"
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

    local function setup3rdFloor(character)
        local root = character:WaitForChild("HumanoidRootPart")
        
        floorButton.MouseButton1Click:Connect(function()
            active = not active
            if active then
                platform = Instance.new("Part")
                platform.Size = Vector3.new(6, 0.5, 6)
                platform.Anchored = true
                platform.CanCollide = true
                platform.Transparency = 0.3
                platform.Material = Enum.Material.Plastic
                platform.Color = Color3.fromRGB(255, 200, 0)
                platform.Position = root.Position - Vector3.new(0, root.Size.Y/2 + platform.Size.Y/2, 0)
                platform.Parent = workspace

                connection = RunService.Heartbeat:Connect(function(dt)
                    if platform and active then
                        local cur = platform.Position
                        local newXZ = Vector3.new(root.Position.X, cur.Y, root.Position.Z)
                        if canRise() then
                            platform.Position = newXZ + Vector3.new(0, dt * RISE_SPEED, 0)
                        else
                            platform.Position = newXZ
                        end
                    end
                end)
                
                floorButton.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
                floorButton.Text = "🏗️ 3RD FLOOR [ON]"
                statusLabel.Text = "3rd Floor: ON"
            else
                destroyPlatform()
                statusLabel.Text = "3rd Floor: OFF"
            end
        end)
        
        character:WaitForChild("Humanoid").Died:Connect(destroyPlatform)
    end

    if LocalPlayer.Character then setup3rdFloor(LocalPlayer.Character) end
    LocalPlayer.CharacterAdded:Connect(setup3rdFloor)
end

-- SPEED BOOSTER
do
    local speedConn
    local baseSpeed = 27
    local active = false

    local function GetCharacter()
        local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local HRP = Char:WaitForChild("HumanoidRootPart")
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        return Char, HRP, Hum
    end

    local function getMovementInput()
        local Char, HRP, Hum = GetCharacter()
        if not Char or not HRP or not Hum then return Vector3.new(0,0,0) end
        local moveVector = Hum.MoveDirection
        if moveVector.Magnitude > 0.1 then
            return Vector3.new(moveVector.X, 0, moveVector.Z).Unit
        end
        return Vector3.new(0,0,0)
    end

    local function startSpeedControl()
        if speedConn then return end
        speedConn = RunService.Heartbeat:Connect(function()
            local Char, HRP, Hum = GetCharacter()
            if not Char or not HRP or not Hum then return end
            local inputDirection = getMovementInput()
            if inputDirection.Magnitude > 0 then
                HRP.AssemblyLinearVelocity = Vector3.new(
                    inputDirection.X*baseSpeed,
                    HRP.AssemblyLinearVelocity.Y,
                    inputDirection.Z*baseSpeed
                )
            else
                HRP.AssemblyLinearVelocity = Vector3.new(0, HRP.AssemblyLinearVelocity.Y, 0)
            end
        end)
    end

    local function stopSpeedControl()
        if speedConn then speedConn:Disconnect() speedConn = nil end
        local Char, HRP = GetCharacter()
        if HRP then HRP.AssemblyLinearVelocity = Vector3.new(0, HRP.AssemblyLinearVelocity.Y, 0) end
    end

    speedButton.MouseButton1Click:Connect(function()
        active = not active
        if active then
            startSpeedControl()
            speedButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            speedButton.Text = "⚡ SPEED [ON]"
            statusLabel.Text = "Speed Boost: ON"
        else
            stopSpeedControl()
            speedButton.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
            speedButton.Text = "⚡ SPEED BOOST"
            statusLabel.Text = "Speed Boost: OFF"
        end
    end)
end

-- DESYNC BODY
do
    local desyncActive = false
    local antiHitActive = false
    local antiHitRunning = false

    local function enableMobileDesync()
        local success, error = pcall(function()
            local backpack = LocalPlayer:WaitForChild("Backpack")
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")
            
            local packages = ReplicatedStorage:WaitForChild("Packages", 5)
            if not packages then warn("❌ Packages not found") return false end
            
            local netFolder = packages:WaitForChild("Net", 5)
            if not netFolder then warn("❌ Net folder not found") return false end
            
            local useItemRemote = netFolder:WaitForChild("RE/UseItem", 5)
            local teleportRemote = netFolder:WaitForChild("RE/QuantumCloner/OnTeleport", 5)
            if not useItemRemote or not teleportRemote then warn("❌ Remotes not found") return false end

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

    desyncButton.MouseButton1Click:Connect(function()
        if antiHitRunning then
            statusLabel.Text = "Desync running..."
            return
        end
        
        if antiHitActive then
            antiHitActive = false
            desyncButton.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
            desyncButton.Text = "🌀 DESYNC BODY"
            statusLabel.Text = "Desync: OFF"
        else
            antiHitRunning = true
            desyncButton.BackgroundColor3 = Color3.fromRGB(255, 220, 60)
            desyncButton.Text = "🌀 DESYNC [ACTIVE]"
            statusLabel.Text = "Desync activating..."
            
            local success = enableMobileDesync()
            if success then
                antiHitActive = true
                desyncButton.BackgroundColor3 = Color3.fromRGB(120, 255, 120)
                desyncButton.Text = "🌀 DESYNC [ON]"
                statusLabel.Text = "Desync: ON"
            else
                antiHitActive = false
                desyncButton.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
                desyncButton.Text = "🌀 DESYNC BODY"
                statusLabel.Text = "Desync failed"
            end
            antiHitRunning = false
        end
    end)
end

-- INF JUMP
do
    local NORMAL_GRAV = 196.2
    local REDUCED_GRAV = 40
    local NORMAL_JUMP = 50
    local BOOST_JUMP = 52.5 -- %5 daha fazla
    local sourceActive = false

    local function setJumpPower(jump)
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then
            h.JumpPower = jump
            h.UseJumpPower = true
        end
    end

    infJumpButton.MouseButton1Click:Connect(function()
        sourceActive = not sourceActive
        
        if sourceActive then
            workspace.Gravity = REDUCED_GRAV
            setJumpPower(BOOST_JUMP)
            infJumpButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            infJumpButton.Text = "🦘 INF JUMP [ON]"
            statusLabel.Text = "Inf Jump: ON (+5%)"
        else
            workspace.Gravity = NORMAL_GRAV
            setJumpPower(NORMAL_JUMP)
            infJumpButton.BackgroundColor3 = Color3.fromRGB(120, 255, 120)
            infJumpButton.Text = "🦘 INF JUMP"
            statusLabel.Text = "Inf Jump: OFF"
        end
    end)
end

-- FLY TO BASE
do
    local flyActive = false
    local flyConn

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

    flyButton.MouseButton1Click:Connect(function()
        if flyActive then
            if flyConn then flyConn:Disconnect() flyConn = nil end
            flyActive = false
            flyButton.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
            flyButton.Text = "🚀 FLY TO BASE"
            statusLabel.Text = "Fly: OFF"
            return
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
                if flyConn then flyConn:Disconnect() flyConn = nil end
                return
            end

            local destPos = destPart.Position
            local currentPos = hrp.Position
            local direction = (destPos - currentPos).Unit
            
            hrp.Velocity = direction * 50
        end)
    end)
end

-- ESP SISTEMI
local espConfig = {
    enabledBest = false,
    enabledSecret = false,
    enabledBase = false,
    enabledPlayer = false,
}

local espBoxes = {}
local plotCache = {}

local function clearAllBestSecret()
    local plotsFolder = workspace:FindFirstChild("Plots")
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
        clearAllBestSecret()
    end
end)

-- ESP SECRET
espSecretButton.MouseButton1Click:Connect(function()
    espConfig.enabledSecret = not espConfig.enabledSecret
    currentConfig.espSecret = espConfig.enabledSecret
    saveConfig()
    
    if espConfig.enabledSecret then
        espSecretButton.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
        espSecretButton.Text = "💎 ESP SECRET [ON]"
        statusLabel.Text = "ESP Secret: ON"
    else
        espSecretButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        espSecretButton.Text = "💎 ESP SECRET"
        statusLabel.Text = "ESP Secret: OFF"
        clearAllBestSecret()
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

-- ESP PLAYER
espPlayerButton.MouseButton1Click:Connect(function()
    espConfig.enabledPlayer = not espConfig.enabledPlayer
    
    if espConfig.enabledPlayer then
        espPlayerButton.BackgroundColor3 = Color3.fromRGB(255, 170, 120)
        espPlayerButton.Text = "👥 ESP PLAYER [ON]"
        statusLabel.Text = "ESP Player: ON"
    else
        espPlayerButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        espPlayerButton.Text = "👥 ESP PLAYER"
        statusLabel.Text = "ESP Player: OFF"
        clearPlayerESP()
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

-- AUTO SIZE
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    mainFrame.Size = UDim2.new(0, 220, 0, math.max(300, layout.AbsoluteContentSize.Y + 50))
end)

-- CONFIG YUKLE
loadConfig()
espConfig.enabledBest = currentConfig.espBest
espConfig.enabledSecret = currentConfig.espSecret
espConfig.enabledBase = currentConfig.espBase

-- BUTON DURUMLARINI GUNCELLE
if espConfig.enabledBest then
    espBestButton.BackgroundColor3 = Color3.fromRGB(60, 220, 120)
    espBestButton.Text = "🔥 ESP BEST [ON]"
end

if espConfig.enabledSecret then
    espSecretButton.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
    espSecretButton.Text = "💎 ESP SECRET [ON]"
end

if espConfig.enabledBase then
    espBaseButton.BackgroundColor3 = Color3.fromRGB(120, 220, 255)
    espBaseButton.Text = "🏠 ESP BASE [ON]"
end

statusLabel.Text = "Vortex Helper - Ready"
