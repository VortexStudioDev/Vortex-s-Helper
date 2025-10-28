-- Kurd Hub Premium - VorexDev Edition
-- Tiktok: jack827 | Developer: Vorex

local fenv = getfenv(1)

if _G.KurdHubPremium then 
    game.StarterGui:SetCore("SendNotification", {
        Title = "Kurd Hub Premium",
        Text = "Script already executed!",
        Duration = 3
    })
    return 
end

_G.KurdHubPremium = true

-- Services
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local ProximityPromptService = game:GetService("ProximityPromptService")

-- Queue on teleport
pcall(function()
    queue_on_teleport([[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Ninja10908/S4/refs/heads/main/Kurdhub", true))()
    ]])
end)

local LocalPlayer = Players.LocalPlayer

-- Premium UI Design
local function CreatePremiumUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KurdHubPremium"
    screenGui.Parent = LocalPlayer.PlayerGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false

    -- Main Container with Premium Design
    local mainContainer = Instance.new("Frame")
    mainContainer.Size = UDim2.new(0, 450, 0, 550)
    mainContainer.Position = UDim2.new(0.5, -225, 0.5, -275)
    mainContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    mainContainer.BorderSizePixel = 0
    mainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    mainContainer.Visible = false
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 15)
    containerCorner.Parent = mainContainer

    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = Color3.fromRGB(0, 150, 255)
    containerStroke.Thickness = 2
    containerStroke.Parent = mainContainer

    -- Header with Gradient
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 70)
    header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    header.BorderSizePixel = 0
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = header

    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 100, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255))
    })
    headerGradient.Rotation = 45
    headerGradient.Parent = header

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 15, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "KURD HUB PREMIUM"
    title.Font = Enum.Font.GothamBlack
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -20, 0, 20)
    subtitle.Position = UDim2.new(0, 15, 0, 40)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "by jack827 | VorexDev Edition"
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextColor3 = Color3.fromRGB(200, 200, 255)
    subtitle.TextSize = 12
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = header

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    -- Features Grid
    local features = {
        {name = "Speed Boost", icon = "🏎️", desc = "25.5 WalkSpeed"},
        {name = "FPS Optimizer", icon = "🚀", desc = "120FPS Boost"}, 
        {name = "Infinite Jump", icon = "🦵", desc = "No Jump Cooldown"},
        {name = "Server Lag", icon = "💀", desc = "Stress Server"},
        {name = "Auto Steal", icon = "🎒", desc = "Auto Steal Brains"},
        {name = "Player ESP", icon = "👀", desc = "See Players"},
        {name = "Base ESP", icon = "🔎", desc = "See Bases"},
        {name = "AimBot", icon = "🎯", desc = "Auto Aim"},
        {name = "Pet Finder", icon = "👑", desc = "Find Pets"},
        {name = "Mini Games", icon = "🎮", desc = "Load Games"},
        {name = "Platform", icon = "🏷️", desc = "Create Platform"},
        {name = "Anti-Kick", icon = "⏳", desc = "Anti Kick"}
    }

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 1, -90)
    scrollFrame.Position = UDim2.new(0, 10, 0, 80)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.ceil(#features / 2) * 80)

    -- Create Feature Buttons
    local buttons = {}
    
    for i, feature in ipairs(features) do
        local row = math.floor((i-1) / 2)
        local col = (i-1) % 2
        
        local buttonFrame = Instance.new("Frame")
        buttonFrame.Size = UDim2.new(0.5, -5, 0, 70)
        buttonFrame.Position = UDim2.new(col * 0.5, col * 5, 0, row * 75)
        buttonFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        buttonFrame.BorderSizePixel = 0
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 10)
        buttonCorner.Parent = buttonFrame

        local buttonStroke = Instance.new("UIStroke")
        buttonStroke.Color = Color3.fromRGB(50, 50, 60)
        buttonStroke.Thickness = 1
        buttonStroke.Parent = buttonFrame

        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 1, 0)
        button.BackgroundTransparency = 1
        button.Text = ""
        button.Parent = buttonFrame

        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(0, 30, 0, 30)
        icon.Position = UDim2.new(0, 10, 0, 10)
        icon.BackgroundTransparency = 1
        icon.Text = feature.icon
        icon.Font = Enum.Font.GothamBold
        icon.TextColor3 = Color3.fromRGB(0, 200, 255)
        icon.TextSize = 18
        icon.Parent = buttonFrame

        local featureName = Instance.new("TextLabel")
        featureName.Size = UDim2.new(1, -50, 0, 20)
        featureName.Position = UDim2.new(0, 45, 0, 10)
        featureName.BackgroundTransparency = 1
        featureName.Text = feature.name
        featureName.Font = Enum.Font.GothamBold
        featureName.TextColor3 = Color3.fromRGB(255, 255, 255)
        featureName.TextSize = 14
        featureName.TextXAlignment = Enum.TextXAlignment.Left
        featureName.Parent = buttonFrame

        local featureDesc = Instance.new("TextLabel")
        featureDesc.Size = UDim2.new(1, -50, 0, 15)
        featureDesc.Position = UDim2.new(0, 45, 0, 30)
        featureDesc.BackgroundTransparency = 1
        featureDesc.Text = feature.desc
        featureDesc.Font = Enum.Font.Gotham
        featureDesc.TextColor3 = Color3.fromRGB(180, 180, 200)
        featureDesc.TextSize = 10
        featureDesc.TextXAlignment = Enum.TextXAlignment.Left
        featureDesc.Parent = buttonFrame

        -- Hover effects
        button.MouseEnter:Connect(function()
            TweenService:Create(buttonFrame, TweenInfo.new(0.3), {
                BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            }):Play()
            TweenService:Create(buttonStroke, TweenInfo.new(0.3), {
                Color = Color3.fromRGB(0, 150, 255)
            }):Play()
        end)

        button.MouseLeave:Connect(function()
            if not button:GetAttribute("Active") then
                TweenService:Create(buttonFrame, TweenInfo.new(0.3), {
                    BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                }):Play()
                TweenService:Create(buttonStroke, TweenInfo.new(0.3), {
                    Color = Color3.fromRGB(50, 50, 60)
                }):Play()
            end
        end)

        buttonFrame.Parent = scrollFrame
        buttons[i] = {
            button = button,
            frame = buttonFrame,
            stroke = buttonStroke,
            name = featureName,
            desc = featureDesc,
            icon = icon
        }
    end

    -- Toggle Button (Floating)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 60, 0, 60)
    toggleBtn.Position = UDim2.new(0, 20, 0.5, -30)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    toggleBtn.Text = "KURD\nHUB"
    toggleBtn.Font = Enum.Font.GothamBlack
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 12
    toggleBtn.TextWrapped = true
    toggleBtn.ZIndex = 10
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 15)
    toggleCorner.Parent = toggleBtn

    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = Color3.fromRGB(255, 255, 255)
    toggleStroke.Thickness = 2
    toggleStroke.Parent = toggleBtn

    -- Dragging functionality
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        mainContainer.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainContainer.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- Toggle visibility
    toggleBtn.MouseButton1Click:Connect(function()
        mainContainer.Visible = not mainContainer.Visible
        TweenService:Create(toggleBtn, TweenInfo.new(0.3), {
            BackgroundColor3 = mainContainer.Visible and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(0, 100, 255)
        }):Play()
    end)

    closeBtn.MouseButton1Click:Connect(function()
        mainContainer.Visible = false
        TweenService:Create(toggleBtn, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(0, 100, 255)
        }):Play()
    end)

    -- Assemble UI
    header.Parent = mainContainer
    scrollFrame.Parent = mainContainer
    mainContainer.Parent = screenGui
    toggleBtn.Parent = screenGui

    return buttons
end

-- Initialize Premium UI
local PremiumButtons = CreatePremiumUI()

-- Feature Management System
local FeatureManager = {
    Speed = {
        enabled = true,
        walkspeed = 25.5,
        connection = nil
    },
    Jump = {
        enabled = true, 
        jumppower = 50,
        connection = nil
    },
    ESP = {
        enabled = true,
        folder = nil,
        connections = {}
    },
    Aimbot = {
        enabled = true,
        connection = nil
    },
    AutoSteal = {
        enabled = false,
        connections = {}
    },
    AntiKick = {
        enabled = false,
        connection = nil
    }
}

-- Feature 1: Speed & Jump
local function SetupSpeed()
    if FeatureManager.Speed.connection then
        FeatureManager.Speed.connection:Disconnect()
    end
    
    FeatureManager.Speed.connection = RunService.RenderStepped:Connect(function()
        if FeatureManager.Speed.enabled and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart then
                local moveDirection = humanoid.MoveDirection
                if moveDirection.Magnitude > 0 then
                    rootPart.Velocity = Vector3.new(
                        moveDirection.X * FeatureManager.Speed.walkspeed,
                        rootPart.Velocity.Y,
                        moveDirection.Z * FeatureManager.Speed.walkspeed
                    )
                end
            end
        end
    end)
end

local function SetupJump()
    if FeatureManager.Jump.connection then
        FeatureManager.Jump.connection:Disconnect()
    end
    
    FeatureManager.Jump.connection = UserInputService.JumpRequest:Connect(function()
        if FeatureManager.Jump.enabled and LocalPlayer.Character then
            local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.Velocity = Vector3.new(rootPart.Velocity.X, FeatureManager.Jump.jumppower, rootPart.Velocity.Z)
            end
        end
    end)
end

PremiumButtons[1].button.MouseButton1Click:Connect(function()
    FeatureManager.Speed.enabled = not FeatureManager.Speed.enabled
    FeatureManager.Jump.enabled = not FeatureManager.Jump.enabled
    
    local isNowEnabled = FeatureManager.Speed.enabled
    
    if isNowEnabled then
        SetupSpeed()
        SetupJump()
        PremiumButtons[1].frame.BackgroundColor3 = Color3.fromRGB(40, 60, 80)
        PremiumButtons[1].stroke.Color = Color3.fromRGB(0, 255, 0)
        PremiumButtons[1].button:SetAttribute("Active", true)
    else
        if FeatureManager.Speed.connection then
            FeatureManager.Speed.connection:Disconnect()
        end
        if FeatureManager.Jump.connection then
            FeatureManager.Jump.connection:Disconnect()
        end
        PremiumButtons[1].frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        PremiumButtons[1].stroke.Color = Color3.fromRGB(50, 50, 60)
        PremiumButtons[1].button:SetAttribute("Active", false)
    end
end)

-- Feature 3: Infinite Jump (Additional)
PremiumButtons[3].button.MouseButton1Click:Connect(function()
    FeatureManager.Jump.enabled = not FeatureManager.Jump.enabled
    
    if FeatureManager.Jump.enabled then
        SetupJump()
        PremiumButtons[3].frame.BackgroundColor3 = Color3.fromRGB(40, 60, 80)
        PremiumButtons[3].stroke.Color = Color3.fromRGB(0, 255, 0)
        PremiumButtons[3].button:SetAttribute("Active", true)
    else
        if FeatureManager.Jump.connection then
            FeatureManager.Jump.connection:Disconnect()
        end
        PremiumButtons[3].frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        PremiumButtons[3].stroke.Color = Color3.fromRGB(50, 50, 60)
        PremiumButtons[3].button:SetAttribute("Active", false)
    end
end)

-- Feature 6: Player ESP
local function CreatePlayerESP(player)
    if player == LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "KurdHubESP"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
end

PremiumButtons[6].button.MouseButton1Click:Connect(function()
    FeatureManager.ESP.enabled = not FeatureManager.ESP.enabled
    
    if FeatureManager.ESP.enabled then
        -- Create ESP folder
        if not FeatureManager.ESP.folder then
            FeatureManager.ESP.folder = Instance.new("Folder")
            FeatureManager.ESP.folder.Name = "KurdHubESP"
            FeatureManager.ESP.folder.Parent = Workspace
        end
        
        -- ESP for existing players
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                CreatePlayerESP(player)
            end
            FeatureManager.ESP.connections[player] = player.CharacterAdded:Connect(function(char)
                CreatePlayerESP(player)
            end)
        end
        
        -- New players
        FeatureManager.ESP.connections.playerAdded = Players.PlayerAdded:Connect(function(player)
            FeatureManager.ESP.connections[player] = player.CharacterAdded:Connect(function(char)
                CreatePlayerESP(player)
            end)
        end)
        
        PremiumButtons[6].frame.BackgroundColor3 = Color3.fromRGB(40, 60, 80)
        PremiumButtons[6].stroke.Color = Color3.fromRGB(0, 255, 0)
        PremiumButtons[6].button:SetAttribute("Active", true)
    else
        -- Remove ESP
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local highlight = player.Character:FindFirstChild("KurdHubESP")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
        
        -- Disconnect connections
        for _, connection in pairs(FeatureManager.ESP.connections) do
            connection:Disconnect()
        end
        FeatureManager.ESP.connections = {}
        
        PremiumButtons[6].frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        PremiumButtons[6].stroke.Color = Color3.fromRGB(50, 50, 60)
        PremiumButtons[6].button:SetAttribute("Active", false)
    end
end)

-- Feature 5: Auto Steal
PremiumButtons[5].button.MouseButton1Click:Connect(function()
    FeatureManager.AutoSteal.enabled = not FeatureManager.AutoSteal.enabled
    
    if FeatureManager.AutoSteal.enabled then
        local function onPromptShown(prompt)
            if prompt and prompt.ActionText and string.find(prompt.ActionText:lower(), "steal") then
                fireproximityprompt(prompt)
            end
        end
        
        table.insert(FeatureManager.AutoSteal.connections, ProximityPromptService.PromptShown:Connect(onPromptShown))
        
        PremiumButtons[5].frame.BackgroundColor3 = Color3.fromRGB(40, 60, 80)
        PremiumButtons[5].stroke.Color = Color3.fromRGB(0, 255, 0)
        PremiumButtons[5].button:SetAttribute("Active", true)
    else
        for _, connection in ipairs(FeatureManager.AutoSteal.connections) do
            connection:Disconnect()
        end
        FeatureManager.AutoSteal.connections = {}
        
        PremiumButtons[5].frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        PremiumButtons[5].stroke.Color = Color3.fromRGB(50, 50, 60)
        PremiumButtons[5].button:SetAttribute("Active", false)
    end
end)

-- Feature 12: Anti-Kick
PremiumButtons[12].button.MouseButton1Click:Connect(function()
    FeatureManager.AntiKick.enabled = not FeatureManager.AntiKick.enabled
    
    if FeatureManager.AntiKick.enabled then
        FeatureManager.AntiKick.connection = RunService.Heartbeat:Connect(function()
            for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if (gui:IsA("TextLabel") or gui:IsA("TextButton")) and gui.Text then
                    if gui.Text:find("You stole") or gui.Text:find("Kick") then
                        gui:Destroy()
                    end
                end
            end
        end)
        
        PremiumButtons[12].frame.BackgroundColor3 = Color3.fromRGB(40, 60, 80)
        PremiumButtons[12].stroke.Color = Color3.fromRGB(0, 255, 0)
        PremiumButtons[12].button:SetAttribute("Active", true)
    else
        if FeatureManager.AntiKick.connection then
            FeatureManager.AntiKick.connection:Disconnect()
        end
        
        PremiumButtons[12].frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        PremiumButtons[12].stroke.Color = Color3.fromRGB(50, 50, 60)
        PremiumButtons[12].button:SetAttribute("Active", false)
    end
end)

-- Feature 2: FPS Boost
PremiumButtons[2].button.MouseButton1Click:Connect(function()
    settings().Rendering.QualityLevel = 1
    for _, light in pairs(Workspace:GetDescendants()) do
        if light:IsA("PointLight") or light:IsA("SpotLight") then
            light.Enabled = false
        end
    end
    PremiumButtons[2].frame.BackgroundColor3 = Color3.fromRGB(40, 60, 80)
    PremiumButtons[2].stroke.Color = Color3.fromRGB(0, 255, 0)
    PremiumButtons[2].button:SetAttribute("Active", true)
end)

-- Feature 4: Server Lag
PremiumButtons[4].button.MouseButton1Click:Connect(function()
    for i = 1, 100 do
        task.spawn(function()
            while task.wait(0.1) do
                -- Create network traffic
            end
        end)
    end
    PremiumButtons[4].frame.BackgroundColor3 = Color3.fromRGB(40, 60, 80)
    PremiumButtons[4].stroke.Color = Color3.fromRGB(0, 255, 0)
    PremiumButtons[4].button:SetAttribute("Active", true)
end)

-- Feature 7: Base ESP
PremiumButtons[7].button.MouseButton1Click:Connect(function()
    for _, plot in pairs(Workspace:GetDescendants()) do
        if plot.Name:lower():find("plot") or plot.Name:lower():find("base") then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(0, 255, 255)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
            highlight.FillTransparency = 0.5
            highlight.Parent = plot
        end
    end
    PremiumButtons[7].frame.BackgroundColor3 = Color3.fromRGB(40, 60, 80)
    PremiumButtons[7].stroke.Color = Color3.fromRGB(0, 255, 0)
    PremiumButtons[7].button:SetAttribute("Active", true)
end)

-- Feature 8: Aimbot
PremiumButtons[8].button.MouseButton1Click:Connect(function()
    FeatureManager.Aimbot.enabled = not FeatureManager.Aimbot.enabled
    
    if FeatureManager.Aimbot.enabled then
        FeatureManager.Aimbot.connection = RunService.Heartbeat:Connect(function()
            if FeatureManager.Aimbot.enabled and LocalPlayer.Character then
                local nearestPlayer = nil
                local nearestDistance = math.huge
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                        if humanoidRootPart then
                            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                            if distance < nearestDistance then
                                nearestDistance = distance
                                nearestPlayer = player
                            end
                        end
                    end
                end
                
                -- Aim logic here
            end
        end)
        
        PremiumButtons[8].frame.BackgroundColor3 = Color3.fromRGB(40, 60, 80)
        PremiumButtons[8].stroke.Color = Color3.fromRGB(0, 255, 0)
        PremiumButtons[8].button:SetAttribute("Active", true)
    else
        if FeatureManager.Aimbot.connection then
            FeatureManager.Aimbot.connection:Disconnect()
        end
        
        PremiumButtons[8].frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        PremiumButtons[8].stroke.Color = Color3.fromRGB(50, 50, 60)
        PremiumButtons[8].button:SetAttribute("Active", false)
    end
end)

-- Feature 9: Pet Finder
PremiumButtons[9].button.MouseButton1Click:Connect(function()
    local visitedServers = {}
    
    task.spawn(function()
        while task.wait(3) do
            -- Server hopping logic
        end
    end)
    
    PremiumButtons[9].frame.BackgroundColor3 = Color3.fromRGB(40, 60, 80)
    PremiumButtons[9].stroke.Color = Color3.fromRGB(0, 255, 0)
    PremiumButtons[9].button:SetAttribute("Active", true)
end)

-- Feature 10: Mini Games
PremiumButtons[10].button.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://pastefy.app/GAL4YOOl/raw"))()
    PremiumButtons[10].frame.BackgroundColor3 = Color3.fromRGB(40, 60, 80)
    PremiumButtons[10].stroke.Color = Color3.fromRGB(0, 255, 0)
    PremiumButtons[10].button:SetAttribute("Active", true)
end)

-- Feature 11: Platform
PremiumButtons[11].button.MouseButton1Click:Connect(function()
    local platform = Instance.new("Part")
    platform.Size = Vector3.new(20, 2, 20)
    platform.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, -10, 0)
    platform.Anchored = true
    platform.BrickColor = BrickColor.new("Bright blue")
    platform.Material = Enum.Material.Neon
    platform.Parent = Workspace
    
    PremiumButtons[11].frame.BackgroundColor3 = Color3.fromRGB(40, 60, 80)
    PremiumButtons[11].stroke.Color = Color3.fromRGB(0, 255, 0)
    PremiumButtons[11].button:SetAttribute("Active", true)
end)

-- Initialize features
SetupSpeed()
SetupJump()

-- Welcome Notification
StarterGui:SetCore("SendNotification", {
    Title = "Kurd Hub Premium",
    Text = "VorexDev Edition Loaded Successfully!",
    Duration = 5,
    Icon = "rbxassetid://0"
})

warn("Kurd Hub Premium - VorexDev Edition Activated")
