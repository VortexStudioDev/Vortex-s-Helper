local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Blacklist with only one user: "gametesterbrow"
local blacklistNames = {
    "gametesterbrow"
}
local blacklist = {}
for _, name in ipairs(blacklistNames) do
    blacklist[string.lower(name)] = true
end

-- Auto Laser System
local autoLazerEnabled = false
local autoLazerThread = nil

local function getLazerRemote()
    local remote = nil
    pcall(function()
        if ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Net") then
            remote = ReplicatedStorage.Packages.Net:FindFirstChild("RE/UseItem") or ReplicatedStorage.Packages.Net:FindFirstChild("RE"):FindFirstChild("UseItem")
        end
        if not remote then
            remote = ReplicatedStorage:FindFirstChild("RE/UseItem") or ReplicatedStorage:FindFirstChild("UseItem")
        end
    end)
    return remote
end

local function isValidTarget(player)
    if not player or not player.Character or player == Players.LocalPlayer then return false end
    local name = player.Name and string.lower(player.Name) or ""
    if blacklist[name] then return false end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return false end
    if humanoid.Health <= 0 then return false end
    return true
end

local function findNearestAllowed()
    if not Players.LocalPlayer.Character or not Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = Players.LocalPlayer.Character.HumanoidRootPart.Position
    local nearest = nil
    local nearestDist = math.huge
    for _, pl in ipairs(Players:GetPlayers()) do
        if isValidTarget(pl) then
            local targetHRP = pl.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local d = (Vector3.new(targetHRP.Position.X, 0, targetHRP.Position.Z) - Vector3.new(myPos.X, 0, myPos.Z)).Magnitude
                if d < nearestDist then
                    nearestDist = d
                    nearest = pl
                end
            end
        end
    end
    return nearest
end

local function safeFire(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
    local remote = getLazerRemote()
    local args = {
        [1] = targetHRP.Position,
        [2] = targetHRP
    }
    if remote and remote.FireServer then
        pcall(function()
            remote:FireServer(unpack(args))
        end)
    end
end

local function autoLazerWorker()
    while autoLazerEnabled do
        local target = findNearestAllowed()
        if target then
            safeFire(target)
        end
        local t0 = tick()
        while tick() - t0 < 0.6 do
            if not autoLazerEnabled then break end
            RunService.Heartbeat:Wait()
        end
    end
end

local function toggleAutoLazer()
    autoLazerEnabled = not autoLazerEnabled
    autoLazerButton.Text = autoLazerEnabled and "AUTO LAZER: ON" or "AUTO LAZER: OFF"
    
    if autoLazerEnabled then
        if autoLazerThread then
            task.cancel(autoLazerThread)
        end
        autoLazerThread = task.spawn(autoLazerWorker)
    else
        if autoLazerThread then
            task.cancel(autoLazerThread)
            autoLazerThread = nil
        end
    end
end

-- GUI Setup for Testing
local gui = Instance.new("ScreenGui")
gui.Name = "TestGui"
gui.ResetOnSpawn = false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 180, 0, 100)
frame.Position = UDim2.new(0.5, -90, 0.5, -50)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Active = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", frame)
title.Text = "TEST AUTO LAZER"
title.Size = UDim2.new(1, 0, 0, 16)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 12

local autoLazerButton = Instance.new("TextButton", frame)
autoLazerButton.Text = "AUTO LAZER: OFF"
autoLazerButton.Size = UDim2.new(0.8, 0, 0, 25)
autoLazerButton.Position = UDim2.new(0.1, 0, 0.2, 0)
autoLazerButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
autoLazerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoLazerButton.Font = Enum.Font.GothamBold
autoLazerButton.TextSize = 14
Instance.new("UICorner", autoLazerButton).CornerRadius = UDim.new(0, 6)

autoLazerButton.MouseButton1Click:Connect(function()
    toggleAutoLazer()
end)
