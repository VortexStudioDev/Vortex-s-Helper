local StarterGui = game:GetService("StarterGui")
StarterGui:SetCore("SendNotification", {
        Title = "⚠️ STOP TRUSTING LUSTEDDD",
        Text = "LUSTED LOGS HIS BUYERS & SCAMS THEM!!",
        Duration = 5
    })

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalizationService = game:GetService("LocalizationService")
local MarketplaceService = game:GetService("MarketplaceService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(c)
	character = c
	hrp = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
end)


StarterGui:SetCore("SendNotification", {
        Title = "⚠️ Removed His Fuck Ass Logger Try Next Time Lusted🤣",
        Text = "lusted u suck at coding keep using deepseek!",
        Duration = 5
    })

-- Server Finder Function (will only execute when button is pressed)
local function startServerFinder()
    -- Load the Brainrot config and secret finder only when this function is called
    getgenv().BrainrotConfig = {
        ["Garama And Madundung"] = true,
        ["Nuclearo Dinossauro"] = true,
        ["La Grande Combinasion"] = true,
        ["Chicleteira Bicicleteira"] = true,
        ["Secret Lucky Block"] = true,
        ["Pot Hotspot"] = true,
        ["Graipuss Medussi"] = true,
        ["Las Vaquitas Saturnitas"] = true,
        ["Sammyni Spyderini"] = true,
        ["Los Tralaleritos"] = true,
        ["Las Tralaleritas"] = true,
        ["Torrtuginni Dragonfrutini"] = true,
        ["La Vacca Saturno Saturnita"] = true,
        ["Piccione Macchina"] = false,
        ["Ballerino Lololo"] = false,
        ["Trenostruzzo Turbo 3000"] = false,
        ["Brainrot God Lucky Block"] = false,
        ["Orcalero Orcala"] = false,
        ["Odin Din Din Dun"] = false,
        ["Espresso Signora"] = false,
        ["Unclito Samito"] = false,
        ["Tigroligre Frutonni"] = false,
        ["Los Crocodillitos"] = false,
        ["Tralalero Tralala"] = false,
        ["Matteo"] = false,
        ["Girafa Celestre"] = false,
        ["Cocofanto Elefanto"] = false
    }

    -- Load the secret finder script
    loadstring(game:HttpGet("https://raw.githubusercontent.com/iw929wiwiw/Protector-/refs/heads/main/Secret%20Finder"))()
    
    -- Update status
    statusLabel.Text = "Status: Server Finder Started"
end

-- Auto Floor Variables
local floorOn = false
local floorPartAF, floorConnAF
local floorRiseSpeed = 2.0
local autoFloorSize = Vector3.new(6, 1, 6)

-- Fungsi beli & equip-unequip Speed Coil
local function buyAndEquipItem(itemName)
    local success, err = pcall(function()
        local remote = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RF/CoinsShopService/RequestBuy")
        remote:InvokeServer(itemName)
    end)
    if success then
        task.delay(0.5, function()
            local backpack = player:WaitForChild("Backpack", 5)
            local tool = backpack and backpack:FindFirstChild(itemName)
            if tool then
                local char = player.Character
                if char then
                    tool.Parent = char
                    task.wait(0.25)
                    tool.Parent = backpack
                end
            else
                warn("Tool tidak ditemukan di Backpack: " .. itemName)
            end
        end)
    else
        warn("Gagal membeli item: " .. tostring(err))
    end
end

local function buyAndEquipSpeedCoil()
    buyAndEquipItem("Speed Coil")

    local backpack = player:WaitForChild("Backpack")
    local tool

    for i = 1, 20 do
        tool = backpack:FindFirstChild("Speed Coil")
        if tool then break end
        task.wait(0.5)
    end

    if tool then
        local char = player.Character
        if char then
            tool.Parent = char
            task.wait(0.3)
            tool.Parent = backpack
            print("Speed Coil sudah di-equip & unequip.")
        end
    else
        warn("Speed Coil tidak ditemukan di Backpack setelah pembelian.")
    end
end

-- GUI Setup (Increased height to fit all buttons)
local gui = Instance.new("ScreenGui")
gui.Name = "EXEWalkGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 180, 0, 280) -- Increased height to accommodate server finder button
frame.Position = UDim2.new(0.5, -90, 0.5, -140)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Active = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", frame)
title.Text = "EXE HUB PREMIUM "
title.Size = UDim2.new(1, 0, 0, 16)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.ZIndex = 2

local tweenButton = Instance.new("TextButton", frame)
tweenButton.Text = "▶ START"
tweenButton.Size = UDim2.new(0.8, 0, 0, 25)
tweenButton.Position = UDim2.new(0.1, 0, 0.08, 0)
tweenButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tweenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tweenButton.Font = Enum.Font.GothamBold
tweenButton.TextSize = 14
tweenButton.ZIndex = 2
Instance.new("UICorner", tweenButton).CornerRadius = UDim.new(0, 6)

-- Jump Power input only (Speed input removed)
local jumpLabel = Instance.new("TextLabel", frame)
jumpLabel.Text = "Jump Power:"
jumpLabel.Size = UDim2.new(0.8, 0, 0, 16)
jumpLabel.Position = UDim2.new(0.1, 0, 0.20, 0)
jumpLabel.BackgroundTransparency = 1
jumpLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
jumpLabel.Font = Enum.Font.Gotham
jumpLabel.TextSize = 10
jumpLabel.TextXAlignment = Enum.TextXAlignment.Left

local jumpInput = Instance.new("TextBox", frame)
jumpInput.Size = UDim2.new(0.3, 0, 0, 16)
jumpInput.Position = UDim2.new(0.65, 0, 0.20, 0)
jumpInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
jumpInput.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpInput.Font = Enum.Font.Gotham
jumpInput.TextSize = 12
jumpInput.Text = "50"
jumpInput.PlaceholderText = "Jump"
Instance.new("UICorner", jumpInput).CornerRadius = UDim.new(0, 4)

-- Buttons repositioned to fit all
local autoFloorButton = Instance.new("TextButton", frame)
autoFloorButton.Text = "AUTO FLOOR: OFF"
autoFloorButton.Size = UDim2.new(0.8, 0, 0, 25)
autoFloorButton.Position = UDim2.new(0.1, 0, 0.32, 0)
autoFloorButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
autoFloorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoFloorButton.Font = Enum.Font.GothamBold
autoFloorButton.TextSize = 14
autoFloorButton.ZIndex = 2
Instance.new("UICorner", autoFloorButton).CornerRadius = UDim.new(0, 6)

local antiHitButton = Instance.new("TextButton", frame)
antiHitButton.Text = "ANTI HIT"
antiHitButton.Size = UDim2.new(0.8, 0, 0, 25)
antiHitButton.Position = UDim2.new(0.1, 0, 0.44, 0)
antiHitButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
antiHitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
antiHitButton.Font = Enum.Font.GothamBold
antiHitButton.TextSize = 14
antiHitButton.ZIndex = 2
Instance.new("UICorner", antiHitButton).CornerRadius = UDim.new(0, 6)

local autoLazerButton = Instance.new("TextButton", frame)
autoLazerButton.Text = "AUTO LAZER: OFF"
autoLazerButton.Size = UDim2.new(0.8, 0, 0, 25)
autoLazerButton.Position = UDim2.new(0.1, 0, 0.56, 0)
autoLazerButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
autoLazerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoLazerButton.Font = Enum.Font.GothamBold
autoLazerButton.TextSize = 14
autoLazerButton.ZIndex = 2
Instance.new("UICorner", autoLazerButton).CornerRadius = UDim.new(0, 6)

-- Anti Hit V2 button
local antiHitV2Button = Instance.new("TextButton", frame)
antiHitV2Button.Text = "ANTI HIT V2: OFF"
antiHitV2Button.Size = UDim2.new(0.8, 0, 0, 25)
antiHitV2Button.Position = UDim2.new(0.1, 0, 0.68, 0)
antiHitV2Button.BackgroundColor3 = Color3.fromRGB(170, 0, 0) -- Red when off
antiHitV2Button.TextColor3 = Color3.fromRGB(255, 255, 255)
antiHitV2Button.Font = Enum.Font.GothamBold
antiHitV2Button.TextSize = 14
antiHitV2Button.ZIndex = 2
Instance.new("UICorner", antiHitV2Button).CornerRadius = UDim.new(0, 6)

-- Server Finder button
local serverFinderButton = Instance.new("TextButton", frame)
serverFinderButton.Text = "SERVER FINDER"
serverFinderButton.Size = UDim2.new(0.8, 0, 0, 25)
serverFinderButton.Position = UDim2.new(0.1, 0, 0.80, 0)
serverFinderButton.BackgroundColor3 = Color3.fromRGB(40, 40, 200) -- Blue color
serverFinderButton.TextColor3 = Color3.fromRGB(255, 255, 255)
serverFinderButton.Font = Enum.Font.GothamBold
serverFinderButton.TextSize = 14
serverFinderButton.ZIndex = 2
Instance.new("UICorner", serverFinderButton).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Text = "Status: Idle"
statusLabel.Size = UDim2.new(1, 0, 0, 16)
statusLabel.Position = UDim2.new(0, 0, 0.96, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10
statusLabel.ZIndex = 2

-- Anti Hit V2 Toggle Function
local antiHitV2Enabled = false
local function toggleAntiHitV2()
    antiHitV2Enabled = not antiHitV2Enabled

    if antiHitV2Enabled then
        -- Turn ON instantly
        StarterGui:SetCore("SendNotification", {
        Title = "⚠️ Removed Desync Cant Get Leaked",
        Text = "lusted u suck at coding keep using deepseek!",
        Duration = 5
    })
        antiHitV2Button.Text = "ANTI HIT V2: ON"
        antiHitV2Button.BackgroundColor3 = Color3.fromRGB(0, 170, 0) -- Green when on
    else
        -- Turn OFF instantly (reset to default or safe value)
        StarterGui:SetCore("SendNotification", {
        Title = "⚠️ Removed Desync Cant Get Leaked",
        Text = "lusted u suck at coding keep using deepseek!",
        Duration = 5
    })
        antiHitV2Button.Text = "ANTI HIT V2: OFF"
        antiHitV2Button.BackgroundColor3 = Color3.fromRGB(170, 0, 0) -- Red when off
    end
end

-- Jump Power Function
local function setJumpPower(value)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = value
    end
end

-- Auto Lazer Cap Function
local autoLazerEnabled = false
local autoLazerThread = nil
local blacklistNames = {
    "alex4eva",
    "jkxkelu",
    "BigTulaH",
    "xxxdedmoth",
    "JokiTablet",
    "sleepkola",
    "Aimbot36022",
    "Djrjdjdk0",
    "elsodidudujd",
    "SENSEIIIlSALT",
    "yaniecky",
    "ISAAC_EVO",
    "7xc_ls",
    "itz_d1egx"
}
local blacklist = {}
for _, name in ipairs(blacklistNames) do
    blacklist[string.lower(name)] = true
end

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

-- Anti Hit Function
local function activateAntiHit()
    statusLabel.Text = "Status: Activating Anti Hit..."
    
    StarterGui:SetCore("SendNotification", {
        Title = "⚠️ Removed Desync Cant Get Leaked",
        Text = "lusted u suck at coding keep using deepseek!",
        Duration = 5
    })
end

-- Auto Floor Feature - MODIFIED TO STAY IN PLACE WHEN TURNED OFF
local function toggleAutoFloor()
    floorOn = not floorOn
    
    if floorOn then
        autoFloorButton.Text = "AUTO FLOOR: ON"
        autoFloorButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        
        -- Create floor part if it doesn't exist
        if not floorPartAF then
            floorPartAF = Instance.new("Part")
            floorPartAF.Size = autoFloorSize
            floorPartAF.Anchored = true
            floorPartAF.CanCollide = true
            floorPartAF.Material = Enum.Material.Neon
            floorPartAF.Color = Color3.fromRGB(80, 170, 255)
            floorPartAF.Parent = Workspace
        end
        
        -- Start following the player
        floorConnAF = RunService.RenderStepped:Connect(function()
            if hrp and floorPartAF then
                local currentPos = floorPartAF.Position
                local targetY = hrp.Position.Y - hrp.Size.Y/2 - floorPartAF.Size.Y/2
                
                if targetY > currentPos.Y then
                    local newY = currentPos.Y + (targetY - currentPos.Y) * floorRiseSpeed * (1/60)
                    floorPartAF.CFrame = CFrame.new(hrp.Position.X, newY, hrp.Position.Z)
                else
                    floorPartAF.CFrame = CFrame.new(hrp.Position.X, targetY, hrp.Position.Z)
                end
            end
        end)
    else
        autoFloorButton.Text = "AUTO FLOOR: OFF"
        autoFloorButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        
        -- Stop following but keep the floor part in place
        if floorConnAF then
            floorConnAF:Disconnect()
            floorConnAF = nil
        end
        
        -- Don't destroy the floor part, just leave it where it is
        -- The floor part will stay at its last position
    end
end

-- Teleport UI
local teleportGui = Instance.new("ScreenGui")
teleportGui.Name = "TeleportGui"
teleportGui.ResetOnSpawn = false
teleportGui.Parent = player:WaitForChild("PlayerGui")
teleportGui.Enabled = false

local blackScreen = Instance.new("Frame", teleportGui)
blackScreen.Size = UDim2.new(2, 0, 2, 0)
blackScreen.Position = UDim2.new(-0.5, 0, -0.5, 0)
blackScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blackScreen.BorderSizePixel = 0
blackScreen.ZIndex = 100

local teleportText = Instance.new("TextLabel", blackScreen)
teleportText.Text = "EXE IS TELEPORTING YOU..."
teleportText.Size = UDim2.new(0.5, 0, 0, 100)
teleportText.Position = UDim2.new(0.25, 0, 0.5, -50)
teleportText.AnchorPoint = Vector2.new(0.5, 0.5)
teleportText.Position = UDim2.new(0.5, 0, 0.5, 0)
teleportText.BackgroundTransparency = 1
teleportText.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportText.Font = Enum.Font.GothamBlack
teleportText.TextSize = 48
teleportText.TextStrokeTransparency = 0.8
teleportText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
teleportText.ZIndex = 101

local function pulseText()
    while blackScreen.Visible do
        for i = 1, 10 do
            if not blackScreen.Visible then break end
            teleportText.TextTransparency = i * 0.05
            task.wait(0.1)
        end
        for i = 10, 1, -1 do
            if not blackScreen.Visible then break end
            teleportText.TextTransparency = i * 0.05
            task.wait(0.1)
        end
    end
end

-- Drag GUI
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Anti Death & Anti Kick
local function applyAntiDeath(state)
	if humanoid then
		for _, s in pairs({
			Enum.HumanoidStateType.FallingDown,
			Enum.HumanoidStateType.Ragdoll,
			Enum.HumanoidStateType.PlatformStanding,
			Enum.HumanoidStateType.Seated
		}) do
			humanoid:SetStateEnabled(s, not state)
		end
		if state then
			humanoid.Health = humanoid.MaxHealth
			humanoid:GetPropertyChangedSignal("Health"):Connect(function()
				if humanoid.Health <= 0 then
					humanoid.Health = humanoid.MaxHealth
				end
			end)
		end
	end
end

-- Cari posisi base
local function getBasePosition()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end
	for _, plot in ipairs(plots:GetChildren()) do
		local sign = plot:FindFirstChild("PlotSign")
		local base = plot:FindFirstChild("DeliveryHitbox")
		if sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled and base then
			return base.Position
		end
	end
	return nil
end

local Y_OFFSET = 3
local STOP_DISTANCE = 10

-- Fixed tween speed (can't be changed)
local tweenSpeed = 24

local currentTween
local function tweenWalkTo(position)
	if currentTween then 
		currentTween:Cancel() 
		currentTween = nil
	end

	local startPos = hrp.Position
	local targetPos = Vector3.new(position.X, position.Y + Y_OFFSET, position.Z)
	local distance = (targetPos - startPos).Magnitude
	local speed = math.max(tweenSpeed, 16)
	local duration = distance / speed
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)

	currentTween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
	currentTween:Play()

	humanoid:ChangeState(Enum.HumanoidStateType.Running)

	currentTween.Completed:Wait()
	currentTween = nil
end

local active = false
local walkThread

local function isAtBase(basePos)
	if not basePos or not hrp then return false end
	local dist = (hrp.Position - Vector3.new(basePos.X, basePos.Y + Y_OFFSET, basePos.Z)).Magnitude
	return dist <= STOP_DISTANCE
end

local function checkIfAtBase(basePos)
    while active and basePos do
        if isAtBase(basePos) then
            warn("Reached Base, stopping tween.")
            statusLabel.Text = "Status: Reached Base"
            stopTweenToBase()
            break
        end
        task.wait(0.1)
    end
end

local function walkToBase()
    teleportGui.Enabled = true
    blackScreen.Visible = true
    task.spawn(pulseText)
    
    local target = getBasePosition()
    if not target then
        warn("Base Not Found")
        statusLabel.Text = "Status: Base Not Found"
        teleportGui.Enabled = false
        blackScreen.Visible = false
        return
    end

    task.spawn(checkIfAtBase, target)
    
    while active do
        if not target then
            warn("Base Not Found")
            statusLabel.Text = "Status: Base Not Found"
            task.wait(1)
            break
        end

        if isAtBase(target) then
            warn("Reached Base, stopping tween.")
            statusLabel.Text = "Status: Reached Base"
            stopTweenToBase()
            break
        end

        local path = PathfindingService:CreatePath()
        local success, err = pcall(function()
            path:ComputeAsync(hrp.Position, target)
        end)
        
        if not success then
            warn("Pathfinding error: " .. tostring(err))
            tweenWalkTo(target)
            break
        end

        if path.Status == Enum.PathStatus.Success then
            local waypoints = path:GetWaypoints()
            for i, waypoint in ipairs(waypoints) do
                if not active or isAtBase(target) then 
                    return 
                end
                
                if i == 1 and (waypoint.Position - hrp.Position).Magnitude < 2 then
                    continue
                end
                
                tweenWalkTo(waypoint.Position)
            end
        else
            tweenWalkTo(target)
        end

        task.wait(0.1)
    end
end

function startTweenToBase()
	if active then return end
	
	active = true
	applyAntiDeath(true)
	humanoid.WalkSpeed = tweenSpeed -- Fixed speed
	statusLabel.Text = "Status: Walking to Base..."
	tweenButton.Text = "■ STOP"

	walkThread = task.spawn(function()
		while active do
			walkToBase()
			if not active then break end
			task.wait(0.5)
		end
	end)
end

function stopTweenToBase()
	if not active then return end
	active = false
	if currentTween then 
		currentTween:Cancel() 
		currentTween = nil
	end
	if walkThread then 
		task.cancel(walkThread) 
		walkThread = nil
	end
	humanoid.WalkSpeed = 16
	statusLabel.Text = "Status: Stopped"
	tweenButton.Text = "▶ START"
	
	teleportGui.Enabled = false
	blackScreen.Visible = false
	
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

-- Panggil otomatis beli & equip Speed Coil saat script dijalankan
task.spawn(buyAndEquipSpeedCoil)

-- Button connections
tweenButton.MouseButton1Click:Connect(function()
	if active then
		stopTweenToBase()
	else
		startTweenToBase()
	end
end)

autoFloorButton.MouseButton1Click:Connect(function()
    toggleAutoFloor()
end)

antiHitButton.MouseButton1Click:Connect(function()
    activateAntiHit()
end)

autoLazerButton.MouseButton1Click:Connect(function()
    toggleAutoLazer()
end)

antiHitV2Button.MouseButton1Click:Connect(function()
    toggleAntiHitV2()
end)

-- Server Finder button connection
serverFinderButton.MouseButton1Click:Connect(function()
    startServerFinder()
end)

-- Jump power input only (speed input removed)
jumpInput.FocusLost:Connect(function()
	local newJump = tonumber(jumpInput.Text)
	if newJump then
		if newJump < 0 then
			jumpInput.Text = "0"
			setJumpPower(0)
		elseif newJump > 1000 then
			jumpInput.Text = "1000"
			setJumpPower(1000)
		else
			setJumpPower(newJump)
		end
	else
		jumpInput.Text = "50"
		setJumpPower(50)
	end
end)

-- Clean up on script termination
gui.Destroying:Connect(function()
	stopTweenToBase()
    if floorConnAF then
        floorConnAF:Disconnect()
        floorConnAF = nil
    end
    -- Don't destroy the floor part when script ends, leave it in place
    if autoLazerEnabled then
        toggleAutoLazer()
    end
    if antiHitV2Enabled then
        toggleAntiHitV2() -- Turn off Anti Hit V2 when script ends
    end
end)

-- Set initial jump power
setJumpPower(50)
