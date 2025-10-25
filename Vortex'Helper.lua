-- Vortex Steal Tools - Edição Completa
-- Integração: Desync Body, Ice Block, Speed Booster, 3rd Floor, Kill, Kick
-- Data da modificação: 2025
-- Design otimizado e compacto

----------------------------------------------------------------
-- SERVICES
----------------------------------------------------------------
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UserInputService = game:GetService('UserInputService')
local Workspace = game:GetService('Workspace')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')
local player = Players.LocalPlayer
local playerGui = player:WaitForChild('PlayerGui')

----------------------------------------------------------------
-- LIMPA GUI ANTIGA
----------------------------------------------------------------
do
    local old = playerGui:FindFirstChild('VortexStealTools')
    if old then
        pcall(function()
            old:Destroy()
        end)
    end
end

----------------------------------------------------------------
-- CRIAR SCREEN GUI
----------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VortexStealTools"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Botão flutuante principal
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 45, 0, 45)
toggleButton.Position = UDim2.new(0, 20, 0.5, -22.5)
toggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
toggleButton.BackgroundTransparency = 0.1
toggleButton.Text = "V"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 18
toggleButton.TextColor3 = Color3.fromRGB(100, 200, 255)
toggleButton.Active = true
toggleButton.Draggable = true
toggleButton.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = toggleButton

local buttonGlow = Instance.new("UIStroke")
buttonGlow.Color = Color3.fromRGB(100, 150, 255)
buttonGlow.Thickness = 2
buttonGlow.Transparency = 0.3
buttonGlow.Parent = toggleButton

-- Frame principal (design compacto)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 140, 0, 220)
mainFrame.Position = UDim2.new(0.5, -70, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(80, 120, 255)
frameStroke.Thickness = 2
frameStroke.Transparency = 0.2
frameStroke.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 28)
header.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "VORTEX TOOLS"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
titleLabel.Parent = header

-- Container de botões
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, -10, 1, -35)
buttonContainer.Position = UDim2.new(0, 5, 0, 32)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainFrame

-- Layout
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 4)
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = buttonContainer

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    mainFrame.Size = UDim2.new(0, 140, 0, layout.AbsoluteContentSize.Y + 40)
end)

----------------------------------------------------------------
-- FUNÇÃO PARA CRIAR BOTÕES
----------------------------------------------------------------
local function createButton(name)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 26)
    button.Text = name
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    button.AutoButtonColor = false
    button.ZIndex = 2
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(80, 100, 200)
    buttonStroke.Thickness = 1
    buttonStroke.Transparency = 0.4
    buttonStroke.Parent = button
    
    -- Efeitos hover
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 90)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}):Play()
    end)
    
    button.Parent = buttonContainer
    return button
end

-- Criar botões
local iceButton = createButton("🧊 ICE BLOCK")
local speedButton = createButton("⚡ SPEED BOOSTER") 
local floorButton = createButton("🏗️ 3RD FLOOR")
local desyncButton = createButton("🌀 DESYNC")
local killButton = createButton("💀 KILL")
local kickButton = createButton("🚪 KICK")

----------------------------------------------------------------
-- TOGGLE UI
----------------------------------------------------------------
local uiVisible = false
toggleButton.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    mainFrame.Visible = uiVisible
    
    if uiVisible then
        toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    end
end)

----------------------------------------------------------------
-- ICE BLOCK (Antigo Teleguiado)
----------------------------------------------------------------
do
    local RunService = game:GetService("RunService")
    local iceOn = false
    local iceConn

    iceButton.MouseButton1Click:Connect(function()
        local char = player.Character or player.CharacterAdded:Wait()
        local hum = char:FindFirstChildOfClass("Humanoid")
        iceOn = not iceOn
        
        if iceOn then
            iceButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
            iceButton.Text = "🧊 ICE [ON]"
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                iceConn = RunService.RenderStepped:Connect(function()
                    if iceOn and hrp then
                        hrp.Velocity = workspace.CurrentCamera.CFrame.LookVector * 25
                    end
                end)
            end
        else
            if iceConn then 
                iceConn:Disconnect() 
                iceConn = nil 
            end
            if hum then 
                hum:ChangeState(Enum.HumanoidStateType.GettingUp) 
            end
            iceButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            iceButton.Text = "🧊 ICE BLOCK"
        end
    end)
end

----------------------------------------------------------------
-- SPEED BOOSTER
----------------------------------------------------------------
do
    local RunService = game:GetService("RunService")
    local speedConn
    local baseSpeed = 27
    local active = false

    local function GetCharacter()
        local Char = player.Character or player.CharacterAdded:Wait()
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
                    inputDirection.X * baseSpeed,
                    HRP.AssemblyLinearVelocity.Y,
                    inputDirection.Z * baseSpeed
                )
            else
                HRP.AssemblyLinearVelocity = Vector3.new(0, HRP.AssemblyLinearVelocity.Y, 0)
            end
        end)
    end

    local function stopSpeedControl()
        if speedConn then 
            speedConn:Disconnect() 
            speedConn = nil 
        end
        local Char, HRP = GetCharacter()
        if HRP then 
            HRP.AssemblyLinearVelocity = Vector3.new(0, HRP.AssemblyLinearVelocity.Y, 0) 
        end
    end

    speedButton.MouseButton1Click:Connect(function()
        active = not active
        if active then
            startSpeedControl()
            speedButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            speedButton.Text = "⚡ SPEED [ON]"
        else
            stopSpeedControl()
            speedButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            speedButton.Text = "⚡ SPEED BOOSTER"
        end
    end)
end

----------------------------------------------------------------
-- 3RD FLOOR
----------------------------------------------------------------
do
    local runService = game:GetService("RunService")
    local platform, connection
    local active, isRising = false, false
    local RISE_SPEED = 15

    local function destroyPlatform()
        if platform then 
            platform:Destroy() 
            platform = nil 
        end
        active = false 
        isRising = false
        if connection then 
            connection:Disconnect() 
            connection = nil 
        end
        floorButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        floorButton.Text = "🏗️ 3RD FLOOR"
    end

    local function canRise()
        if not platform then return false end
        local origin = platform.Position + Vector3.new(0, platform.Size.Y/2, 0)
        local direction = Vector3.new(0, 2, 0)
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {platform, player.Character}
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
                platform.Material = Enum.Material.Neon
                platform.Color = Color3.fromRGB(255, 200, 0)
                platform.Position = root.Position - Vector3.new(0, root.Size.Y/2 + platform.Size.Y/2, 0)
                platform.Parent = workspace

                isRising = true
                connection = runService.Heartbeat:Connect(function(dt)
                    if platform and active then
                        local cur = platform.Position
                        local newXZ = Vector3.new(root.Position.X, cur.Y, root.Position.Z)
                        if isRising and canRise() then
                            platform.Position = newXZ + Vector3.new(0, dt * RISE_SPEED, 0)
                        else
                            isRising = false
                            platform.Position = newXZ
                        end
                    end
                end)
                floorButton.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
                floorButton.Text = "🏗️ 3RD FLOOR [ON]"
            else
                destroyPlatform()
            end
        end)
        character:WaitForChild("Humanoid").Died:Connect(destroyPlatform)
    end

    if player.Character then 
        setup3rdFloor(player.Character) 
    end
    player.CharacterAdded:Connect(setup3rdFloor)
end

----------------------------------------------------------------
-- DESYNC BODY (Anti-Hit)
----------------------------------------------------------------
local antiHitActive = false
local clonerActive = false
local desyncActive = false
local cloneListenerConn
local antiHitRunning = false

local function safeDisconnectConn(conn)
    if conn and typeof(conn) == "RBXScriptConnection" then
        pcall(function()
            conn:Disconnect()
        end)
    end
end

local function trySetFlag()
    pcall(function()
        if setfflag then
            setfflag("WorldStepMax", "-99999999999999")
        end
    end)
end

local function resetFlag()
    pcall(function()
        if setfflag then
            setfflag("WorldStepMax", "1")
        end
    end)
end

local function activateDesync()
    if desyncActive then return end
    desyncActive = true
    trySetFlag()
end

local function deactivateDesync()
    if not desyncActive then return end
    desyncActive = false
    resetFlag()
end

local function activateClonerDesync(callback)
    if clonerActive then
        if callback then callback() end
        return
    end
    clonerActive = true

    local Backpack = player:FindFirstChildOfClass("Backpack")
    local function equipQuantumCloner()
        if not Backpack then return end
        local tool = Backpack:FindFirstChild("Quantum Cloner")
        if tool then
            local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:EquipTool(tool)
            end
        end
    end
    equipQuantumCloner()

    local REUseItem = ReplicatedStorage.Packages.Net:FindFirstChild("RE/UseItem")
    if REUseItem then
        REUseItem:FireServer()
    end
    
    local REQuantumClonerOnTeleport = ReplicatedStorage.Packages.Net:FindFirstChild("RE/QuantumCloner/OnTeleport")
    if REQuantumClonerOnTeleport then
        REQuantumClonerOnTeleport:FireServer()
    end

    local cloneName = tostring(player.UserId) .. "_Clone"
    cloneListenerConn = Workspace.ChildAdded:Connect(function(obj)
        if obj.Name == cloneName and obj:IsA("Model") then
            if cloneListenerConn then
                cloneListenerConn:Disconnect()
            end
            cloneListenerConn = nil

            task.wait(1.6)
            if callback then
                pcall(callback)
            end
        end
    end)
end

local function deactivateClonerDesync()
    if not clonerActive then
        local existingClone = Workspace:FindFirstChild(tostring(player.UserId) .. "_Clone")
        if existingClone then
            pcall(function()
                existingClone:Destroy()
            end)
        end
        clonerActive = false
        return
    end

    clonerActive = false
    local clone = Workspace:FindFirstChild(tostring(player.UserId) .. "_Clone")
    if clone then
        pcall(function()
            clone:Destroy()
        end)
    end

    if cloneListenerConn then
        cloneListenerConn:Disconnect()
        cloneListenerConn = nil
    end
end

local function executeAntiHit()
    if antiHitRunning then return end
    antiHitRunning = true

    activateDesync()
    task.wait(0.1)
    activateClonerDesync(function()
        deactivateDesync()
        antiHitRunning = false
        antiHitActive = true
        desyncButton.BackgroundColor3 = Color3.fromRGB(120, 255, 120)
        desyncButton.Text = "🌀 DESYNC [ON]"
    end)
end

local function deactivateAntiHit()
    if antiHitRunning then
        if cloneListenerConn then
            cloneListenerConn:Disconnect()
            cloneListenerConn = nil
        end
        antiHitRunning = false
    end

    deactivateClonerDesync()
    deactivateDesync()
    antiHitActive = false

    local possibleClone = Workspace:FindFirstChild(tostring(player.UserId) .. "_Clone")
    if possibleClone then
        pcall(function()
            possibleClone:Destroy()
        end)
    end

    desyncButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    desyncButton.Text = "🌀 DESYNC"
end

desyncButton.MouseButton1Click:Connect(function()
    if antiHitRunning then return end
    
    if antiHitActive then
        deactivateAntiHit()
    else
        executeAntiHit()
    end
end)

player.CharacterAdded:Connect(function()
    task.delay(0.3, function()
        local clone = Workspace:FindFirstChild(tostring(player.UserId) .. "_Clone")
        if clone then
            pcall(function()
                clone:Destroy()
            end)
        end
    end)
end)

----------------------------------------------------------------
-- KILL BUTTON
----------------------------------------------------------------
killButton.MouseButton1Click:Connect(function()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end
end)

----------------------------------------------------------------
-- KICK BUTTON  
----------------------------------------------------------------
kickButton.MouseButton1Click:Connect(function()
    player:Kick("Vortex Steal Tools - Kicked by User")
end)

----------------------------------------------------------------
-- DRAG FUNCTION
----------------------------------------------------------------
local function makeDraggable(obj)
    local dragging = false
    local dragStart, startPos
    
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - dragStart
                obj.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
end

makeDraggable(mainFrame)
makeDraggable(toggleButton)

----------------------------------------------------------------
-- NOTIFICAÇÃO INICIAL
----------------------------------------------------------------
task.spawn(function()
    task.wait(1)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Vortex Steal Tools",
        Text = "Interface carregada com sucesso!",
        Duration = 5
    })
end)

print("Vortex Steal Tools carregado com sucesso!")
