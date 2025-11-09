-- Rtx Helper GUI - Cleaned & Fixed
-- Generated with UnveilR → now readable and working
-- discord.gg/threaded

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Remove old GUI if exists
local oldGui = CoreGui:FindFirstChild("RtxHelper")
if oldGui then oldGui:Destroy() end

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RtxHelper"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 180, 0, 130)
MainFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- UI Styling
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = MainFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "Rtx Helper"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

-- SpeedBoost Button
local SpeedBoostBtn = Instance.new("TextButton")
SpeedBoostBtn.Name = "SpeedBoost"
SpeedBoostBtn.Size = UDim2.new(0.8, 0, 0, 35)
SpeedBoostBtn.Position = UDim2.new(0.1, 0, 0.3, 0)
SpeedBoostBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SpeedBoostBtn.Text = "Speedboost"
SpeedBoostBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
SpeedBoostBtn.Font = Enum.Font.GothamBold
SpeedBoostBtn.TextSize = 15
SpeedBoostBtn.Parent = MainFrame

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 8)
SpeedCorner.Parent = SpeedBoostBtn

-- Noclone Desync Button
local NocloneBtn = Instance.new("TextButton")
NocloneBtn.Name = "NocloneDesync"
NocloneBtn.Size = UDim2.new(0.8, 0, 0, 35)
NocloneBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
NocloneBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
NocloneBtn.Text = "Noclone Desync"
NocloneBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
NocloneBtn.Font = Enum.Font.GothamBold
NocloneBtn.TextSize = 15
NocloneBtn.Parent = MainFrame

local NocloneCorner = Instance.new("UICorner")
NocloneCorner.CornerRadius = UDim.new(0, 8)
NocloneCorner.Parent = NocloneBtn

-- Notification Function
local function notify(text)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 200, 0, 40)
    notif.Position = UDim2.new(1, -210, 1, -60)
    notif.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notif.BorderSizePixel = 0
    notif.BackgroundTransparency = 1
    notif.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notif

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.6
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Parent = notif

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 15
    label.Parent = notif

    -- Fade in
    TweenService:Create(notif, TweenInfo.new(0.3), {BackgroundTransparency = 0.15}):Play()
    TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 0}):Play()

    task.wait(1)

    -- Fade out
    local tween1 = TweenService:Create(notif, TweenInfo.new(0.3), {BackgroundTransparency = 1})
    local tween2 = TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 1})
    tween1:Play()
    tween2:Play()
    tween1.Completed:Wait()
    notif:Destroy()
end

-- SpeedBoost Logic
local speedBoostActive = false
local speedConnection

SpeedBoostBtn.MouseButton1Click:Connect(function()
    speedBoostActive = not speedBoostActive

    if speedBoostActive then
        SpeedBoostBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        SpeedBoostBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        notify("Speedboost toggled ON!")

        speedConnection = RunService.Heartbeat:Connect(function()
            local character = LocalPlayer.Character
            if not character then return end
            local root = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not root or not humanoid then return end

            -- Only boost if moving
            if humanoid.MoveDirection.Magnitude > 0 then
                root.Velocity = root.Velocity + (root.CFrame.LookVector * 50) -- Adjust speed here
            end
        end)
    else
        SpeedBoostBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SpeedBoostBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        notify("Speedboost toggled OFF!")
        if speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end
    end
end)

-- Noclone Desync (EXPERIMENTAL)
NocloneBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        NocloneBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        NocloneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        NocloneBtn.Text = "Noclone Desync (Active)"
        notify("Noclone Desync activated!")

        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            -- Freeze physics briefly to cause desync
            setfflag("WorldStepMax", "-9999999")
            task.wait(0.1)
            setfflag("WorldStepMax", "-1")
        end

        task.wait(0.5)

        -- Reset button
        NocloneBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        NocloneBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        NocloneBtn.Text = "Noclone Desync"
    end)
end)
