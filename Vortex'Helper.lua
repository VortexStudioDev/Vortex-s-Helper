--// Rtx Hub GUI (Clean + Compact + Carpet Speedboost + Mobile Desync)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

--// Vars
local baseSpeed = 30
local carpetSpeed = 300
local carpetUpSpeed = 60
local speedActive = false
local carpetActive = false
local desyncActive = false
local spaceDown = false
local speedConn, carpetConn

--// ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RtxHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

--// Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 180, 0, 210) -- slightly taller
MainFrame.Position = UDim2.new(0.5, -90, 0.5, -105)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 15)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Transparency = 0.4

--// Title
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 32)
Title.BackgroundTransparency = 1
Title.Text = "RTX HUB"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true

--// Create Button Function
local function createButton(text, yPos)
	local button = Instance.new("TextButton")
	button.Parent = MainFrame
	button.Size = UDim2.new(1, -30, 0, 40)
	button.Position = UDim2.new(0, 15, 0, yPos)
	button.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.GothamBold
	button.TextScaled = true
	button.BorderSizePixel = 0
	button.AutoButtonColor = false

	local BtnCorner = Instance.new("UICorner", button)
	BtnCorner.CornerRadius = UDim.new(0, 12)

	local BtnStroke = Instance.new("UIStroke", button)
	BtnStroke.Thickness = 1.4
	BtnStroke.Color = Color3.fromRGB(255, 255, 255)
	BtnStroke.Transparency = 0.6

	return button
end

--// Buttons
local SpeedButton = createButton("SPEEDBOOST", 45)
local CarpetButton = createButton("CARPET SPEEDBOOST", 100)
local DesyncButton = createButton("MOBILE DESYNC", 155)

--// Functions
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

--// Normal Speedboost
local function startSpeed()
	if speedConn then return end
	speedConn = RunService.Heartbeat:Connect(function()
		local Char, HRP, Hum = GetCharacter()
		if not Char or not HRP or not Hum then return end
		local inputDir = getMovementInput()
		if inputDir.Magnitude > 0 then
			HRP.AssemblyLinearVelocity = Vector3.new(
				inputDir.X * baseSpeed,
				HRP.AssemblyLinearVelocity.Y,
				inputDir.Z * baseSpeed
			)
		end
	end)
end

local function stopSpeed()
	if speedConn then speedConn:Disconnect() speedConn = nil end
end

--// Carpet Speedboost
local function startCarpet()
	if carpetConn then return end
	carpetConn = RunService.Heartbeat:Connect(function()
		local Char = LocalPlayer.Character
		if not Char then return end
		local carpet = Char:FindFirstChildWhichIsA("Part") or workspace:FindFirstChild("FlyingCarpet")
		if carpet and carpet:IsA("BasePart") then
			local Hum = Char:FindFirstChildOfClass("Humanoid")
			if Hum then
				local moveDir = Hum.MoveDirection
				local vel = moveDir * carpetSpeed
				if spaceDown then
					vel = vel + Vector3.new(0, carpetUpSpeed, 0)
				end
				carpet.Velocity = vel
			end
		end
	end)
end

local function stopCarpet()
	if carpetConn then carpetConn:Disconnect() carpetConn = nil end
end

--// Mobile Desync
local function enableMobileDesync()
	local success, err = pcall(function()
		local backpack = LocalPlayer:WaitForChild("Backpack")
		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local humanoid = character:WaitForChild("Humanoid")

		local packages = ReplicatedStorage:WaitForChild("Packages", 5)
		if not packages then return end
		local netFolder = packages:WaitForChild("Net", 5)
		if not netFolder then return end
		local useItemRemote = netFolder:WaitForChild("RE/UseItem", 5)
		local teleportRemote = netFolder:WaitForChild("RE/QuantumCloner/OnTeleport", 5)
		if not useItemRemote or not teleportRemote then return end

		local toolNames = {"Quantum Cloner", "Brainrot", "brainrot"}
		local tool
		for _, name in ipairs(toolNames) do
			tool = backpack:FindFirstChild(name) or character:FindFirstChild(name)
			if tool then break end
		end
		if not tool then
			for _, item in ipairs(backpack:GetChildren()) do
				if item:IsA("Tool") then tool=item break end
			end
		end

		if tool and tool.Parent==backpack then
			humanoid:EquipTool(tool)
			task.wait(0.2)
		end

		if setfflag then setfflag("WorldStepMax", "-9999999999") end
		task.wait(0.1)
		useItemRemote:FireServer()
		task.wait(1)
		teleportRemote:FireServer()
		task.wait(2)
		if setfflag then setfflag("WorldStepMax", "-1") end
	end)
	if not success then warn(err) end
end

local function disableMobileDesync()
	pcall(function()
		if setfflag then setfflag("WorldStepMax", "-1") end
	end)
end

--// Toggles
SpeedButton.MouseButton1Click:Connect(function()
	speedActive = not speedActive
	if speedActive then
		startSpeed()
		SpeedButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
	else
		stopSpeed()
		SpeedButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	end
end)

CarpetButton.MouseButton1Click:Connect(function()
	carpetActive = not carpetActive
	if carpetActive then
		startCarpet()
		CarpetButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
	else
		stopCarpet()
		CarpetButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	end
end)

DesyncButton.MouseButton1Click:Connect(function()
	desyncActive = not desyncActive
	if desyncActive then
		enableMobileDesync()
		DesyncButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
	else
		disableMobileDesync()
		DesyncButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	end
end)

--// Spacebar
UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
		spaceDown = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
		spaceDown = false
	end
end)
