-- Rtx Hub GUI (Compact + Set Base + Instant Steal + Minimize) -- LocalScript
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local savedBaseLocation = nil

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RtxHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10,10,13)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -130)
MainFrame.Size = UDim2.new(0, 220, 0, 200) -- increased height
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = false
MainFrame.ZIndex = 10

-- Rounded corners
local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0,18)

-- White outline
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Thickness = 3
UIStroke.Color = Color3.fromRGB(255,255,255)

-- Inner frame
local InnerFrame = Instance.new("Frame", MainFrame)
InnerFrame.BackgroundColor3 = Color3.fromRGB(16,16,20)
InnerFrame.Position = UDim2.new(0,4,0,4)
InnerFrame.Size = UDim2.new(1,-8,1,-8)
InnerFrame.BorderSizePixel = 0
InnerFrame.ZIndex = 11

local InnerCorner = Instance.new("UICorner", InnerFrame)
InnerCorner.CornerRadius = UDim.new(0,15)

-- Title bar
local TitleBar = Instance.new("Frame", InnerFrame)
TitleBar.BackgroundTransparency = 1
TitleBar.Size = UDim2.new(1,0,0,50)
TitleBar.ZIndex = 12

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0,12,0,10)
TitleLabel.Size = UDim2.new(1,-100,0,20)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "Rtx Hub"
TitleLabel.TextColor3 = Color3.fromRGB(255,255,255)
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 13

-- Minimize button
local MinimizeButton = Instance.new("TextButton", TitleBar)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(35,35,42)
MinimizeButton.Position = UDim2.new(1, -36, 0, 16)
MinimizeButton.Size = UDim2.new(0,26,0,26)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "—"
MinimizeButton.TextColor3 = Color3.fromRGB(255,255,255)
MinimizeButton.TextSize = 22
MinimizeButton.ZIndex = 13
MinimizeButton.AutoButtonColor = false
MinimizeButton.BorderSizePixel = 0

local MinCorner = Instance.new("UICorner", MinimizeButton)
MinCorner.CornerRadius = UDim.new(0,8)

local MinStroke = Instance.new("UIStroke", MinimizeButton)
MinStroke.Color = Color3.fromRGB(255,255,255)
MinStroke.Thickness = 1
MinStroke.Transparency = 0.8

-- Divider
local Divider = Instance.new("Frame", InnerFrame)
Divider.BackgroundColor3 = Color3.fromRGB(255,255,255)
Divider.BackgroundTransparency = 0.9
Divider.BorderSizePixel = 0
Divider.Position = UDim2.new(0,18,0,50)
Divider.Size = UDim2.new(1,-36,0,1)
Divider.ZIndex = 12

-- Content frame
local ContentFrame = Instance.new("Frame", InnerFrame)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0,0,0,58)
ContentFrame.Size = UDim2.new(1,0,1,-58)
ContentFrame.ZIndex = 12

-- Button creator
local function createButton(parent, text, emoji, yPos)
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.BackgroundColor3 = Color3.fromRGB(22,22,28)
    button.Position = UDim2.new(0,18,0,yPos)
    button.Size = UDim2.new(1,-36,0,48)
    button.Font = Enum.Font.GothamBold
    button.Text = ""
    button.AutoButtonColor = false
    button.BorderSizePixel = 0
    button.ZIndex = 13

    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(0,12)

    local stroke = Instance.new("UIStroke", button)
    stroke.Color = Color3.fromRGB(255,255,255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.88

    local iconFrame = Instance.new("Frame", button)
    iconFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
    iconFrame.Position = UDim2.new(0,12,0.5,-16)
    iconFrame.Size = UDim2.new(0,32,0,32)
    iconFrame.ZIndex = 14
    local iconCorner = Instance.new("UICorner", iconFrame)
    iconCorner.CornerRadius = UDim.new(0,9)
    local iconStroke = Instance.new("UIStroke", iconFrame)
    iconStroke.Color = Color3.fromRGB(255,255,255)
    iconStroke.Thickness = 2
    iconStroke.Transparency = 0.5
    local iconText = Instance.new("TextLabel", iconFrame)
    iconText.BackgroundTransparency = 1
    iconText.Size = UDim2.new(1,0,1,0)
    iconText.Font = Enum.Font.GothamBold
    iconText.Text = emoji
    iconText.TextSize = 18
    iconText.ZIndex = 15

    local label = Instance.new("TextLabel", button)
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0,54,0,0)
    label.Size = UDim2.new(1,-64,1,0)
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 14

    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(30,30,38)
        stroke.Transparency = 0.6
        iconStroke.Transparency = 0.2
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(22,22,28)
        stroke.Transparency = 0.88
        iconStroke.Transparency = 0.5
    end)

    return button, label
end

-- Set Base Button
local SetBaseButton, SetBaseLabel = createButton(ContentFrame, "SET BASE", "📍", 8)
SetBaseButton.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        savedBaseLocation = hrp.CFrame
        SetBaseLabel.Text = "✓ BASE SAVED"
        SetBaseLabel.TextColor3 = Color3.fromRGB(100,255,150)
        task.wait(1)
        SetBaseLabel.Text = "SET BASE"
        SetBaseLabel.TextColor3 = Color3.fromRGB(255,255,255)
    end
end)

-- Instant Steal Button
local InstantButton, InstantLabel = createButton(ContentFrame, "INSTANT STEAL", "⚡", 64)
InstantButton.MouseButton1Click:Connect(function()
    if not savedBaseLocation then
        InstantLabel.Text = "⚠ NO BASE"
        InstantLabel.TextColor3 = Color3.fromRGB(200,80,80)
        task.wait(1)
        InstantLabel.Text = "INSTANT STEAL"
        InstantLabel.TextColor3 = Color3.fromRGB(255,255,255)
        return
    end

    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        -- Teleport outside map first
        hrp.CFrame = CFrame.new(0,-500,0)
        task.wait(0.1)
        -- Then teleport to saved base
        hrp.CFrame = savedBaseLocation
        InstantLabel.Text = "✓ TELEPORTED"
        InstantLabel.TextColor3 = Color3.fromRGB(100,255,150)
        task.wait(0.9)
        InstantLabel.Text = "INSTANT STEAL"
        InstantLabel.TextColor3 = Color3.fromRGB(255,255,255)
    end
end)

-- Minimize logic
local minimized = false
local normalSize = MainFrame.Size
local minimizedSize = UDim2.new(normalSize.X.Scale, normalSize.X.Offset, 0, 54)
local tweenInfo = TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(ContentFrame, tweenInfo, {Size = UDim2.new(1,0,0,0)}):Play()
        TweenService:Create(MainFrame, tweenInfo, {Size = minimizedSize}):Play()
        MinimizeButton.Text = "▴"
    else
        TweenService:Create(ContentFrame, tweenInfo, {Size = UDim2.new(1,0,1,-58)}):Play()
        TweenService:Create(MainFrame, tweenInfo, {Size = normalSize}):Play()
        MinimizeButton.Text = "—"
    end
end)
