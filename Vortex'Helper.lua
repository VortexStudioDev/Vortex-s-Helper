--[[
    Vortex'Helper - Premium Script Hub
    Tüm Hakları Saklıdır © 2024
    Discord: https://discord.gg/vortexhelper
    Version: 2.0 Simple
--]]

----------------------------------------------------------------
-- SERVICES & VARIABLES
----------------------------------------------------------------
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera

----------------------------------------------------------------
-- UTILITY FUNCTIONS
----------------------------------------------------------------
local function getHumanoid()
    local c = player.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getHRP()
    local c = player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Vortex'Helper",
            Text = text or "",
            Duration = duration or 3
        })
    end
end

local function round(num, decimalPlaces)
    local mult = 10^(decimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

----------------------------------------------------------------
-- FLY SYSTEM
----------------------------------------------------------------
local Fly = {
    enabled = false,
    bodyVelocity = nil,
    connection = nil,
    speed = 50
}

local function toggleFly()
    if Fly.enabled then
        -- Fly deactivate
        if Fly.bodyVelocity then
            Fly.bodyVelocity:Destroy()
            Fly.bodyVelocity = nil
        end
        if Fly.connection then
            Fly.connection:Disconnect()
            Fly.connection = nil
        end
        Fly.enabled = false
        notify("Fly System", "Fly: OFF 🚫")
    else
        -- Fly activate
        local character = player.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        Fly.bodyVelocity = Instance.new("BodyVelocity")
        Fly.bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        Fly.bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
        Fly.bodyVelocity.Parent = humanoidRootPart
        
        Fly.connection = RunService.Heartbeat:Connect(function()
            if not Fly.enabled or not Fly.bodyVelocity then return end
            
            local moveDirection = Vector3.new(0, 0, 0)
            
            -- Forward/Backward
            if UserInputService:IsKeyDown(Enum.Key.W) then
                moveDirection = moveDirection + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.Key.S) then
                moveDirection = moveDirection - camera.CFrame.LookVector
            end
            
            -- Left/Right
            if UserInputService:IsKeyDown(Enum.Key.A) then
                moveDirection = moveDirection - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.Key.D) then
                moveDirection = moveDirection + camera.CFrame.RightVector
            end
            
            -- Normalize and apply speed
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit * Fly.speed
            end
            
            -- Up/Down
            if UserInputService:IsKeyDown(Enum.Key.Space) then
                moveDirection = moveDirection + Vector3.new(0, Fly.speed, 0)
            end
            if UserInputService:IsKeyDown(Enum.Key.LeftShift) then
                moveDirection = moveDirection + Vector3.new(0, -Fly.speed, 0)
            end
            
            Fly.bodyVelocity.Velocity = moveDirection
        end)
        
        Fly.enabled = true
        notify("Fly System", "Fly: ON ✈️\nWASD + Space/Shift")
    end
end

----------------------------------------------------------------
-- NO CLIP SYSTEM
----------------------------------------------------------------
local Noclip = {
    enabled = false,
    connection = nil
}

local function toggleNoclip()
    if Noclip.enabled then
        if Noclip.connection then
            Noclip.connection:Disconnect()
            Noclip.connection = nil
        end
        Noclip.enabled = false
        notify("Noclip System", "Noclip: OFF 🚫")
    else
        Noclip.connection = RunService.Stepped:Connect(function()
            if not Noclip.enabled then return end
            
            local character = player.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
        
        Noclip.enabled = true
        notify("Noclip System", "Noclip: ON 👻")
    end
end

----------------------------------------------------------------
-- SPEED & JUMP SYSTEM
----------------------------------------------------------------
local currentWalkSpeed = 16
local currentJumpPower = 50

local function setSpeed(speed)
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = speed
        currentWalkSpeed = speed
        notify("Movement", "Speed: " .. speed .. " 🏃‍♂️")
    end
end

local function setJumpPower(power)
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.JumpPower = power
        currentJumpPower = power
        notify("Movement", "Jump Power: " .. power .. " 🦘")
    end
end

----------------------------------------------------------------
-- INFINITE JUMP SYSTEM
----------------------------------------------------------------
local InfiniteJump = {
    enabled = false,
    connection = nil
}

local function toggleInfiniteJump()
    if InfiniteJump.enabled then
        if InfiniteJump.connection then
            InfiniteJump.connection:Disconnect()
            InfiniteJump.connection = nil
        end
        InfiniteJump.enabled = false
        notify("Jump System", "Infinite Jump: OFF 🚫")
    else
        InfiniteJump.connection = UserInputService.JumpRequest:Connect(function()
            if InfiniteJump.enabled then
                local humanoid = getHumanoid()
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
        InfiniteJump.enabled = true
        notify("Jump System", "Infinite Jump: ON ♾️")
    end
end

----------------------------------------------------------------
-- GUI CREATION
----------------------------------------------------------------
local VortexHelper = Instance.new("ScreenGui")
VortexHelper.Name = "VortexHelper"
VortexHelper.ResetOnSpawn = false
VortexHelper.Parent = playerGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = VortexHelper

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 150, 255)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Vortex'Helper 🛡️"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextYAlignment = Enum.TextYAlignment.Center
Title.Parent = MainFrame

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -30, 0, 10)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.white
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Position = UDim2.new(0, 20, 0, 20)
ToggleButton.Text = "⚡"
ToggleButton.TextColor3 = Color3.white
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 25
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
ToggleButton.Parent = VortexHelper

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(0, 200, 255)
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleButton

-- Button Creation Function
local function CreateButton(parent, text, position, color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 40)
    button.Position = position
    button.Text = text
    button.TextColor3 = Color3.white
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.BackgroundColor3 = color
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    return button
end

-- Create Buttons
local buttons = {}
local buttonY = 60

buttons.fly = CreateButton(MainFrame, "✈️ Fly", UDim2.new(0.05, 0, 0, buttonY), Color3.fromRGB(50, 150, 255))
buttons.noclip = CreateButton(MainFrame, "🚷 Noclip", UDim2.new(0.05, 0, 0, buttonY + 50), Color3.fromRGB(255, 150, 50))
buttons.speed = CreateButton(MainFrame, "⚡ Speed: 16", UDim2.new(0.05, 0, 0, buttonY + 100), Color3.fromRGB(50, 255, 100))
buttons.jump = CreateButton(MainFrame, "🦘 Jump Power: 50", UDim2.new(0.05, 0, 0, buttonY + 150), Color3.fromRGB(200, 50, 255))
buttons.infiniteJump = CreateButton(MainFrame, "♾️ Infinite Jump", UDim2.new(0.05, 0, 0, buttonY + 200), Color3.fromRGB(150, 50, 200))
buttons.discord = CreateButton(MainFrame, "📋 Discord", UDim2.new(0.05, 0, 0, buttonY + 250), Color3.fromRGB(100, 100, 255))

----------------------------------------------------------------
-- BUTTON FUNCTIONALITIES
----------------------------------------------------------------
buttons.fly.MouseButton1Click:Connect(function()
    toggleFly()
    buttons.fly.BackgroundColor3 = Fly.enabled and Color3.fromRGB(50, 255, 150) or Color3.fromRGB(50, 150, 255)
end)

buttons.noclip.MouseButton1Click:Connect(function()
    toggleNoclip()
    buttons.noclip.BackgroundColor3 = Noclip.enabled and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(255, 150, 50)
end)

buttons.speed.MouseButton1Click:Connect(function()
    local newSpeed = currentWalkSpeed == 16 and 50 or 16
    setSpeed(newSpeed)
    buttons.speed.Text = "⚡ Speed: " .. newSpeed
end)

buttons.jump.MouseButton1Click:Connect(function()
    local newPower = currentJumpPower == 50 and 100 or 50
    setJumpPower(newPower)
    buttons.jump.Text = "🦘 Jump Power: " .. newPower
end)

buttons.infiniteJump.MouseButton1Click:Connect(function()
    toggleInfiniteJump()
    buttons.infiniteJump.BackgroundColor3 = InfiniteJump.enabled and Color3.fromRGB(200, 50, 255) or Color3.fromRGB(150, 50, 200)
end)

buttons.discord.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://discord.gg/vortexhelper")
        notify("Discord", "Discord link copied! 📋")
    else
        notify("Discord", "Discord: https://discord.gg/vortexhelper")
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

----------------------------------------------------------------
-- DRAG SYSTEM
----------------------------------------------------------------
local dragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

----------------------------------------------------------------
-- INITIALIZATION
----------------------------------------------------------------
-- Toggle Menu
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Set initial speeds
spawn(function()
    wait(2)
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = currentWalkSpeed
        humanoid.JumpPower = currentJumpPower
    end
end)

-- Initial notification
notify("Vortex'Helper", "Script loaded successfully! 🚀\nClick ⚡ to open menu.", 5)

-- Cleanup on character change
player.CharacterAdded:Connect(function(character)
    wait(1)
    if Fly.enabled then
        toggleFly()
    end
    if Noclip.enabled then
        toggleNoclip()
    end
    
    -- Reapply speeds
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = currentWalkSpeed
        humanoid.JumpPower = currentJumpPower
    end
end)

-- Anti-AFK
local VirtualInputManager = game:GetService("VirtualInputManager")
local antiAfkConnection

antiAfkConnection = Players.LocalPlayer.Idled:Connect(function()
    VirtualInputManager:SendKeyEvent(true, "W", false, game)
    wait(0.1)
    VirtualInputManager:SendKeyEvent(false, "W", false, game)
end)

notify("Vortex'Helper", "Anti-AFK enabled! 💤")

----------------------------------------------------------------
-- END OF SCRIPT
-- Simple & Working Version
----------------------------------------------------------------
