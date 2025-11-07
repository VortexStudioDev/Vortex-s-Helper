_G.jrtofrt = true

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local uiScale = 0.75

-- UI Creation Function
local function createKurdHubUI()
    local buttonLabels = {
        "120 FPS No Lag 🚀",
        "Infinite Jump 🦘", 
        "Auto Laser Steal 🎯",
        "Base ESP 🏠"
    }
    
    local buttonCount = #buttonLabels
    local buttonHeight = math.floor(50 * uiScale)
    local padding = math.floor(10 * uiScale)
    local headerHeight = math.floor(50 * uiScale)
    local cornerRadius = math.floor(18 * uiScale)
    local columns = 2
    local rows = math.ceil(buttonCount / columns)
    local buttonWidth = math.floor(180 * uiScale)
    local totalWidth = buttonWidth * columns + padding * (columns + 1)
    local totalHeight = headerHeight + rows * buttonHeight + (rows - 1) * padding + cornerRadius
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    screenGui.Name = "KurdHubMini"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, totalWidth, 0, totalHeight)
    mainFrame.Position = UDim2.new(0.5, -totalWidth // 2, 0.5, -totalHeight // 2)
    mainFrame.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    
    local mainCorner = Instance.new("UICorner", mainFrame)
    mainCorner.CornerRadius = UDim.new(0, math.floor(16 * uiScale))
    
    -- Header Frame
    local headerFrame = Instance.new("Frame", mainFrame)
    headerFrame.Size = UDim2.new(1, 0, 0, headerHeight)
    headerFrame.Position = UDim2.new(0, 0, 0, 0)
    headerFrame.BackgroundTransparency = 1
    
    -- Title
    local title = Instance.new("TextLabel", headerFrame)
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "Kurd Hub Mini"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 36 * uiScale
    title.TextColor3 = Color3.fromRGB(22, 22, 22)
    title.TextXAlignment = Enum.TextXAlignment.Center
    
    -- Create Buttons
    local buttons = {}
    
    for index, label in ipairs(buttonLabels) do
        local row = math.ceil(index / columns) - 1
        local col = (index - 1) % columns
        local xPos = padding + col * (buttonWidth + padding)
        local yPos = headerHeight + padding + row * (buttonHeight + padding)
        
        local buttonContainer = Instance.new("Frame", mainFrame)
        buttonContainer.Size = UDim2.new(0, buttonWidth, 0, buttonHeight)
        buttonContainer.Position = UDim2.new(0, xPos, 0, yPos)
        buttonContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        buttonContainer.BorderSizePixel = 0
        
        local containerCorner = Instance.new("UICorner", buttonContainer)
        containerCorner.CornerRadius = UDim.new(0, math.floor(16 * uiScale))
        
        local button = Instance.new("TextButton", buttonContainer)
        button.Size = UDim2.new(1, -math.floor(4 * uiScale), 1, -math.floor(4 * uiScale))
        button.Position = UDim2.new(0, math.floor(2 * uiScale), 0, math.floor(2 * uiScale))
        button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        button.Text = label
        button.Font = Enum.Font.GothamBlack
        button.TextSize = 20 * uiScale
        button.TextColor3 = Color3.fromRGB(26, 26, 26)
        button.BorderSizePixel = 0
        button.AutoButtonColor = true
        button.TextWrapped = true
        
        local buttonCorner = Instance.new("UICorner", button)
        buttonCorner.CornerRadius = UDim.new(0, math.floor(12 * uiScale))
        
        button.MouseEnter:Connect(function()
            if button.BackgroundColor3 ~= Color3.fromRGB(0, 255, 0) then
                button.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
            end
        end)
        
        button.MouseLeave:Connect(function()
            if button.BackgroundColor3 ~= Color3.fromRGB(0, 255, 0) then
                button.BackgroundColor3 = Color3.new(1, 1, 1)
            end
        end)
        
        buttons[index] = button
    end
    
    -- Dragging functionality
    local dragging, dragInput, dragStart, startPos
    
    headerFrame.InputBegan:Connect(function(input)
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
    
    headerFrame.InputChanged:Connect(function(input)
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
    
    return buttons
end

-- Create UI
local Buttons = createKurdHubUI()

-- ===========================
-- FEATURE 1: 120 FPS NO LAG
-- ===========================
local fpsEnabled = false

Buttons[1].MouseButton1Click:Connect(function()
    fpsEnabled = not fpsEnabled
    
    if fpsEnabled then
        -- FPS optimize edici ayarlar
        settings().Rendering.QualityLevel = 1
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
        
        -- Görsel efektleri kapat
        for _, effect in pairs(Workspace:GetDescendants()) do
            if effect:IsA("ParticleEmitter") or effect:IsA("Fire") or effect:IsA("Smoke") or effect:IsA("Sparkles") then
                effect.Enabled = false
            end
        end
        
        -- Grafikleri basitleştir
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("Part") then
                part.Material = Enum.Material.Plastic
                if part:FindFirstChildOfClass("Decal") then
                    part:FindFirstChildOfClass("Decal"):Destroy()
                end
            end
        end
        
        -- Lighting ayarları
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 100000
        lighting.Brightness = 2
        
        Buttons[1].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        Buttons[1].Text = "✅ 120 FPS Active"
        
        StarterGui:SetCore("SendNotification", {
            Title = "Kurd Hub",
            Text = "120 FPS Mode Activated",
            Duration = 3
        })
    else
        Buttons[1].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Buttons[1].Text = "120 FPS No Lag 🚀"
        
        StarterGui:SetCore("SendNotification", {
            Title = "Kurd Hub",
            Text = "120 FPS Mode Deactivated",
            Duration = 3
        })
    end
end)

-- ===========================
-- FEATURE 2: INFINITE JUMP
-- ===========================
local infiniteJumpEnabled = true
local jumpRequestConnection

local function doJump()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if humanoid and humanoid.Health > 0 and rootPart then
        rootPart.Velocity = Vector3.new(rootPart.Velocity.X, 50, rootPart.Velocity.Z)
    end
end

local function setupJumpRequest()
    if jumpRequestConnection then
        jumpRequestConnection:Disconnect()
        jumpRequestConnection = nil
    end
    
    jumpRequestConnection = UserInputService.JumpRequest:Connect(function()
        if infiniteJumpEnabled then
            doJump()
        end
    end)
end

local function initializeJumpForCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    setupJumpRequest()
    
    character.ChildAdded:Connect(function(child)
        if child:IsA("Humanoid") then
            setupJumpRequest()
        end
    end)
end

Buttons[2].MouseButton1Click:Connect(function()
    infiniteJumpEnabled = not infiniteJumpEnabled
    
    if infiniteJumpEnabled then
        Buttons[2].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        Buttons[2].Text = "✅ Infinite Jump"
        setupJumpRequest()
        
        StarterGui:SetCore("SendNotification", {
            Title = "Kurd Hub",
            Text = "Infinite Jump Activated",
            Duration = 3
        })
    else
        Buttons[2].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Buttons[2].Text = "Infinite Jump 🦘"
        
        StarterGui:SetCore("SendNotification", {
            Title = "Kurd Hub",
            Text = "Infinite Jump Deactivated",
            Duration = 3
        })
    end
end)

-- Başlangıçta aktif
setupJumpRequest()
Buttons[2].BackgroundColor3 = Color3.fromRGB(0, 255, 0)

LocalPlayer.CharacterAdded:Connect(function(character)
    initializeJumpForCharacter(character)
end)

if LocalPlayer.Character then
    initializeJumpForCharacter(LocalPlayer.Character)
end

-- ===========================
-- FEATURE 3: AUTO LASER STEAL
-- ===========================
local autoStealEnabled = false
local stealConnection
local promptConnections = {}

local function disconnectAllPrompts()
    for _, connection in ipairs(promptConnections) do
        connection:Disconnect()
    end
    promptConnections = {}
end

local function onPromptShown(prompt)
    if autoStealEnabled and prompt then
        local actionText = string.lower(prompt.ActionText)
        if string.find(actionText, "steal") or string.find(actionText, "brain") then
            fireproximityprompt(prompt)
        end
    end
end

local function findLaserTool()
    local character = LocalPlayer.Character
    if character then
        return character:FindFirstChild("Laser Cape") or LocalPlayer.Backpack:FindFirstChild("Laser Cape")
    end
    return nil
end

local function useLaserOnNearest()
    local character = LocalPlayer.Character
    if not character then return end
    
    local laserTool = findLaserTool()
    if not laserTool then return end
    
    local nearestPlayer = nil
    local nearestDistance = math.huge
    local localRoot = character:FindFirstChild("HumanoidRootPart")
    
    if not localRoot then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local distance = (localRoot.Position - targetRoot.Position).Magnitude
                if distance < nearestDistance and distance < 100 then
                    nearestDistance = distance
                    nearestPlayer = player
                end
            end
        end
    end
    
    if nearestPlayer and nearestPlayer.Character then
        local targetPart = nearestPlayer.Character:FindFirstChild("UpperTorso") or 
                         nearestPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetPart then
            -- Equip laser tool
            laserTool.Parent = character
            
            -- Use laser (game-specific implementation)
            pcall(function()
                -- Try different remote event names
                local remotes = {
                    "UseLaser",
                    "LaserCape",
                    "UseItem",
                    "RE/UseItem"
                }
                
                for _, remoteName in ipairs(remotes) do
                    local remote = ReplicatedStorage:FindFirstChild(remoteName)
                    if remote then
                        remote:FireServer(targetPart.Position)
                        break
                    end
                end
            end)
        end
    end
end

local function enableAutoSteal()
    disconnectAllPrompts()
    
    -- Mevcut promptları kontrol et
    for _, prompt in pairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local actionText = string.lower(prompt.ActionText)
            if string.find(actionText, "steal") or string.find(actionText, "brain") then
                fireproximityprompt(prompt)
            end
        end
    end
    
    -- Yeni promptları dinle
    table.insert(promptConnections, ProximityPromptService.PromptShown:Connect(onPromptShown))
    
    -- Laser auto-use
    if stealConnection then
        stealConnection:Disconnect()
    end
    
    stealConnection = RunService.Heartbeat:Connect(function()
        if not autoStealEnabled then return end
        
        -- Auto steal prompts
        for _, prompt in pairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                local actionText = string.lower(prompt.ActionText)
                if string.find(actionText, "steal") or string.find(actionText, "brain") then
                    fireproximityprompt(prompt)
                end
            end
        end
        
        -- Auto laser
        useLaserOnNearest()
    end)
end

local function disableAutoSteal()
    disconnectAllPrompts()
    if stealConnection then
        stealConnection:Disconnect()
        stealConnection = nil
    end
end

Buttons[3].MouseButton1Click:Connect(function()
    autoStealEnabled = not autoStealEnabled
    
    if autoStealEnabled then
        Buttons[3].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        Buttons[3].Text = "✅ Auto Steal Active"
        enableAutoSteal()
        
        StarterGui:SetCore("SendNotification", {
            Title = "Kurd Hub",
            Text = "Auto Laser Steal Activated",
            Duration = 3
        })
    else
        Buttons[3].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Buttons[3].Text = "Auto Laser Steal 🎯"
        disableAutoSteal()
        
        StarterGui:SetCore("SendNotification", {
            Title = "Kurd Hub",
            Text = "Auto Laser Steal Deactivated",
            Duration = 3
        })
    end
end)

-- ===========================
-- FEATURE 4: BASE ESP
-- ===========================
local baseESPEnabled = false
local baseESPFolder = Instance.new("Folder")
baseESPFolder.Name = "BaseESP"
baseESPFolder.Parent = game.CoreGui

local function findPlots()
    local plots = {}
    
    -- Check Workspace for plots
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name:find("Plot") or obj.Name:find("Base") then
            table.insert(plots, obj)
        end
    end
    
    -- Check Plots folder if exists
    if Workspace:FindFirstChild("Plots") then
        for _, plot in pairs(Workspace.Plots:GetChildren()) do
            table.insert(plots, plot)
        end
    end
    
    -- Check for purchase systems
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:FindFirstChild("Purchases") then
            table.insert(plots, obj)
        end
    end
    
    return plots
end

local function createBaseESP()
    -- Clear existing ESP
    for _, child in pairs(baseESPFolder:GetChildren()) do
        child:Destroy()
    end
    
    local plots = findPlots()
    
    for _, plot in pairs(plots) do
        local mainPart = nil
        
        -- Find main part
        if plot:IsA("Model") then
            mainPart = plot:FindFirstChild("Main") or plot:FindFirstChild("Base") or plot:FindFirstChild("Plot")
            if not mainPart then
                -- Find any large part
                for _, part in pairs(plot:GetChildren()) do
                    if part:IsA("Part") and part.Size.Magnitude > 5 then
                        mainPart = part
                        break
                    end
                end
            end
        elseif plot:IsA("Part") then
            mainPart = plot
        end
        
        if mainPart and not baseESPFolder:FindFirstChild(plot.Name .. "_ESP") then
            -- Create highlight
            local highlight = Instance.new("Highlight")
            highlight.Name = plot.Name .. "_ESP"
            highlight.Adornee = mainPart
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
            highlight.FillTransparency = 0.7
            highlight.OutlineTransparency = 0
            highlight.Parent = baseESPFolder
            
            -- Create billboard
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "BaseLabel"
            billboard.Adornee = mainPart
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 5, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = baseESPFolder
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = "🏠 " .. plot.Name
            label.TextColor3 = Color3.fromRGB(255, 255, 0)
            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            label.TextStrokeTransparency = 0
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.Parent = billboard
        end
    end
end

local function removeBaseESP()
    for _, child in pairs(baseESPFolder:GetChildren()) do
        child:Destroy()
    end
end

Buttons[4].MouseButton1Click:Connect(function()
    baseESPEnabled = not baseESPEnabled
    
    if baseESPEnabled then
        Buttons[4].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        Buttons[4].Text = "✅ Base ESP Active"
        createBaseESP()
        
        -- Continuous update
        coroutine.wrap(function()
            while baseESPEnabled do
                createBaseESP()
                wait(5)
            end
        end)()
        
        StarterGui:SetCore("SendNotification", {
            Title = "Kurd Hub",
            Text = "Base ESP Activated",
            Duration = 3
        })
    else
        Buttons[4].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Buttons[4].Text = "Base ESP 🏠"
        removeBaseESP()
        
        StarterGui:SetCore("SendNotification", {
            Title = "Kurd Hub",
            Text = "Base ESP Deactivated",
            Duration = 3
        })
    end
end)

warn("🎯 Kurd Hub Mini Yüklendi! 4 özellik aktif ve çalışıyor.")
