local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ImlexusHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local notification = Instance.new("Frame")
notification.Size = UDim2.new(0, 300, 0, 50)
notification.Position = UDim2.new(0.5, -150, 0, -60)
notification.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
notification.BorderSizePixel = 0
notification.Parent = screenGui

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 8)
notifCorner.Parent = notification

local notifText = Instance.new("TextLabel")
notifText.Size = UDim2.new(1, 0, 1, 0)
notifText.BackgroundTransparency = 1
notifText.Text = "Deobfuscator Bugged the gui alot lol"
notifText.TextColor3 = Color3.fromRGB(255, 200, 50)
notifText.TextSize = 14
notifText.Font = Enum.Font.Gotham
notifText.Parent = notification

TweenService:Create(notification, TweenInfo.new(0.4), {Position = UDim2.new(0.5, -150, 0, 15)}):Play()
task.wait(3.5)
TweenService:Create(notification, TweenInfo.new(0.4), {Position = UDim2.new(0.5, -150, 0, -60)}):Play()
task.wait(0.5)
notification:Destroy()

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 240)
mainFrame.Position = UDim2.new(1, -220, 0.5, -120)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

local icon = Instance.new("Frame")
icon.Size = UDim2.new(0, 15, 0, 15)
icon.Position = UDim2.new(0, 10, 0.5, -7.5)
icon.BackgroundColor3 = Color3.fromRGB(255, 180, 50)
icon.BorderSizePixel = 0
icon.Parent = header

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(1, 0)
iconCorner.Parent = icon

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 35, 0, 0)
title.BackgroundTransparency = 1
title.Text = "IMLEXUS HUB"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(1, -32, 0.5, -12.5)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 16
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = header

local buttonsContainer = Instance.new("Frame")
buttonsContainer.Size = UDim2.new(1, -20, 1, -55)
buttonsContainer.Position = UDim2.new(0, 10, 0, 50)
buttonsContainer.BackgroundTransparency = 1
buttonsContainer.Parent = mainFrame

local buttonLayout = Instance.new("UIListLayout")
buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
buttonLayout.Padding = UDim.new(0, 8)
buttonLayout.Parent = buttonsContainer

local function createButton(name, layoutOrder)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 50)
    button.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.LayoutOrder = layoutOrder
    button.Parent = buttonsContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    return button
end

local mobileDesyncBtn = createButton("Mobile Desync", 1)
local flyBtn = createButton("Fly", 2)
local speedBoostBtn = createButton("Speed Booster", 3)

local flyEnabled = false
local bodyVelocity = nil
local bodyGyro = nil

local LocalPlayer = Players.LocalPlayer
local desyncActive = false

local function enableMobileDesync()
    local success, error = pcall(function()
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

local function disableMobileDesync()
    pcall(function()
        if setfflag then setfflag("WorldStepMax", "-1") end
    end)
end

mobileDesyncBtn.MouseButton1Click:Connect(function()
    desyncActive = not desyncActive
    if desyncActive then
        local success = enableMobileDesync()
        if success then
            mobileDesyncBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 0)
        else
            desyncActive=false
            mobileDesyncBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        end
    else
        disableMobileDesync()
        mobileDesyncBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    desyncActive=false
    mobileDesyncBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
end)

flyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    if flyEnabled then
        flyBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
        bodyVelocity.Parent = humanoidRootPart
        
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.CFrame = humanoidRootPart.CFrame
        bodyGyro.Parent = humanoidRootPart
        
    else
        flyBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
        
        if bodyGyro then
            bodyGyro:Destroy()
            bodyGyro = nil
        end
    end
end)

speedBoostBtn.MouseButton1Click:Connect(function()
end)

local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 200, 0, 40)}):Play()
        buttonsContainer.Visible = false
        minimizeBtn.Text = "+"
    else
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 200, 0, 240)}):Play()
        buttonsContainer.Visible = true
        minimizeBtn.Text = "—"
    end
end)

local dragging = false
local dragInput, mousePos, framePos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        mainFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)
