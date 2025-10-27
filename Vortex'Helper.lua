-- Servisler
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Oyuncu
local LocalPlayer = Players.LocalPlayer

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SilentHub"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Ana Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 130)
Frame.Position = UDim2.new(0.75, 0, 0.05, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 0, 50)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 16)
FrameCorner.Parent = Frame

local Shadow = Instance.new("UIStroke")
Shadow.Thickness = 2
Shadow.Color = Color3.fromRGB(150, 0, 255)
Shadow.Transparency = 0.5
Shadow.Parent = Frame

-- Başlık
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(60, 0, 120)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Text = "SilentHub"
Title.Parent = Frame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 16)
TitleCorner.Parent = Title

-- Buton
local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0.9, 0, 0.5, 0)
Button.Position = UDim2.new(0.05, 0, 0.45, 0)
Button.BackgroundColor3 = Color3.fromRGB(120, 0, 220)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Font = Enum.Font.GothamBold
Button.TextScaled = true
Button.Text = "TELEPORT PLAYER"
Button.Parent = Frame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 12)
ButtonCorner.Parent = Button

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Thickness = 2
ButtonStroke.Color = Color3.fromRGB(180, 0, 255)
ButtonStroke.Transparency = 0.3
ButtonStroke.Parent = Button

-- Değişkenler
local toggled = false
local teleportLoop

-- En yakın oyuncuyu bulma fonksiyonu
local function getNearestPlayer()
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	
	local closest, distance = nil, math.huge
	
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local part = player.Character.HumanoidRootPart
			local mag = (part.Position - hrp.Position).Magnitude
			if mag < distance then
				distance = mag
				closest = player
			end
		end
	end
	
	return closest
end

-- Teleport döngüsünü başlatma
local function startTeleportLoop()
	local target = getNearestPlayer()
	if not target or not target.Character then return end
	
	local hrp = target.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	if teleportLoop then 
		teleportLoop:Disconnect() 
	end
	
	local above = true
	teleportLoop = RunService.Heartbeat:Connect(function()
		if target.Character and hrp then
			if above then
				hrp.CFrame = hrp.CFrame + Vector3.new(0, 20, 0)
			else
				hrp.CFrame = hrp.CFrame + Vector3.new(0, -20, 0)
			end
			above = not above
		end
		task.wait(0.5)
	end)
end

-- Teleport döngüsünü durdurma
local function stopTeleportLoop()
	if teleportLoop then
		teleportLoop:Disconnect()
		teleportLoop = nil
	end
end

-- Buton animasyonu
local function animateButton(active)
	local onColor = Color3.fromRGB(180, 0, 255)
	local offColor = Color3.fromRGB(120, 0, 220)
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	
	if active then
		Button.Text = "STOP"
		TweenService:Create(Button, tweenInfo, {BackgroundColor3 = onColor}):Play()
	else
		Button.Text = "TELEPORT PLAYER"
		TweenService:Create(Button, tweenInfo, {BackgroundColor3 = offColor}):Play()
	end
end

-- Buton tıklama olayı
Button.MouseButton1Click:Connect(function()
	toggled = not toggled
	animateButton(toggled)
	
	if toggled then
		startTeleportLoop()
	else
		stopTeleportLoop()
	end
end)
