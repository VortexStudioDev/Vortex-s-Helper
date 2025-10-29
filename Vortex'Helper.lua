-- Vortex's Helper - Premium Version
-- Optimized & Fixed Code

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UserInputService = game:GetService('UserInputService')
local Workspace = game:GetService('Workspace')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')
local CoreGui = game:GetService('CoreGui')
local HttpService = game:GetService('HttpService')
local ProximityPromptService = game:GetService('ProximityPromptService')
local player = Players.LocalPlayer

-- Settings folder
local VortexFolder = Workspace:FindFirstChild("Vortex'sHelper")
if not VortexFolder then
    VortexFolder = Instance.new("Folder")
    VortexFolder.Name = "Vortex'sHelper"
    VortexFolder.Parent = Workspace
end

-- Global Variables
local gravityLow = false
local fpsDevourerActive = false
local espBaseActive = false
local espBestActive = false
local playerEspActive = false
local stealFloorActive = false
local antiHitActive = false
local flyActive = false

-- Save/Load settings
local function saveSettings()
    local settings = {
        infJump = gravityLow,
        espBase = espBaseActive,
        espBest = espBestActive,
        desync = antiHitActive,
        fpsDevourer = fpsDevourerActive,
        playerESP = playerEspActive,
        stealFloor = stealFloorActive
    }
    
    local success, result = pcall(function()
        local json = HttpService:JSONEncode(settings)
        VortexFolder:SetAttribute("Settings", json)
    end)
    
    return success
end

local function loadSettings()
    local saved = VortexFolder:GetAttribute("Settings")
    if saved then
        local success, settings = pcall(function()
            return HttpService:JSONDecode(saved)
        end)
        
        if success and settings then
            return settings
        end
    end
    return {}
end

-- Notification System
local startupNotifications = true
local function showNotification(message, isSuccess)
    if not startupNotifications then return end
    
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "VortexNotify"
    notificationGui.ResetOnSpawn = false
    notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notificationGui.Parent = CoreGui
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 220, 0, 50)
    notification.Position = UDim2.new(0.5, -110, 0.15, 0)
    notification.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    notification.BackgroundTransparency = 0
    notification.BorderSizePixel = 0
    notification.ZIndex = 1000
    notification.ClipsDescendants = true
    notification.Parent = notificationGui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notification
    
    local notifStroke = Instance.new("UIStroke")
    notifStroke.Color = isSuccess and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    notifStroke.Thickness = 2
    notifStroke.Parent = notification
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 40, 1, 0)
    icon.Position = UDim2.new(0, 0, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = isSuccess and "✅" or "❌"
    icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    icon.TextSize = 18
    icon.Font = Enum.Font.GothamBold
    icon.ZIndex = 1001
    icon.Parent = notification
    
    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(1, -45, 1, -10)
    notifText.Position = UDim2.new(0, 40, 0, 5)
    notifText.BackgroundTransparency = 1
    notifText.Text = message
    notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifText.TextSize = 12
    notifText.Font = Enum.Font.Gotham
    notifText.TextXAlignment = Enum.TextXAlignment.Left
    notifText.TextYAlignment = Enum.TextYAlignment.Top
    notifText.TextWrapped = true
    notifText.ZIndex = 1001
    notifText.Parent = notification
    
    notification.Position = UDim2.new(0.5, -110, 0.1, 0)
    local tweenIn = TweenService:Create(notification, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -110, 0.15, 0)
    })
    tweenIn:Play()

    tweenIn.Completed:Connect(function()
        wait(1.2)
        
        if notification and notification.Parent then
            local tweenOut = TweenService:Create(notification, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -110, 0.1, 0),
                BackgroundTransparency = 1
            })
            
            for _, child in pairs(notification:GetChildren()) do
                if child:IsA("TextLabel") then
                    child.TextTransparency = 1
                end
            end
            
            tweenOut:Play()
            
            tweenOut.Completed:Connect(function()
                if notificationGui and notificationGui.Parent then
                    notificationGui:Destroy()
                end
            end)
        end
    end)
end

-- FPS Devourer (Optimized)
local function enableFPSDevourer()
    fpsDevourerActive = true
    
    pcall(function()
        if setfpscap then
            setfpscap(999)
        end
    end)
    
    local lighting = game:GetService("Lighting")
    pcall(function()
        lighting.GlobalShadows = false
        lighting.FogEnd = 100000
        lighting.Brightness = 2
    end)
    
    -- Optimize existing objects
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("UnionOperation") or obj:IsA("MeshPart") then
            pcall(function()
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
            end)
        end
    end
    
    -- Optimize new characters
    player.CharacterAdded:Connect(function(char)
        wait(0.5)
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    part.Material = Enum.Material.Plastic
                    part.Reflectance = 0
                end)
            end
        end
    end)
    
    saveSettings()
    showNotification("FPS Devourer Enabled", true)
end

local function disableFPSDevourer()
    fpsDevourerActive = false
    
    pcall(function()
        if setfpscap then
            setfpscap(60)
        end
    end)
    
    local lighting = game:GetService("Lighting")
    pcall(function()
        lighting.GlobalShadows = true
        lighting.Brightness = 1
    end)
    
    saveSettings()
    showNotification("FPS Devourer Disabled", false)
end

local function toggleFPSDevourer()
    if fpsDevourerActive then
        disableFPSDevourer()
    else
        enableFPSDevourer()
    end
end

-- Infinite Jump System (Fixed)
local NORMAL_GRAV = 196.2
local REDUCED_GRAV = 40
local NORMAL_JUMP = 30
local BOOST_JUMP = 50 -- Increased for better jump

local spoofedGravity = NORMAL_GRAV
pcall(function()
    local mt = getrawmetatable(Workspace)
    if mt then
        setreadonly(mt, false)
        local oldIndex = mt.__index
        mt.__index = function(self, k)
            if k == 'Gravity' then
                return spoofedGravity
            end
            return oldIndex(self, k)
        end
        setreadonly(mt, true)
    end
end)

local function setJumpPower(jump)
    local h = player.Character and player.Character:FindFirstChildOfClass('Humanoid')
    if h then
        h.JumpPower = jump
        h.UseJumpPower = true
    end
end

local infiniteJumpConn
local function enableInfiniteJump(state)
    if infiniteJumpConn then
        infiniteJumpConn:Disconnect()
        infiniteJumpConn = nil
    end
    if state then
        infiniteJumpConn = UserInputService.JumpRequest:Connect(function()
            local h = player.Character and player.Character:FindFirstChildOfClass('Humanoid')
            if h and gravityLow and h:GetState() ~= Enum.HumanoidStateType.Seated then
                local root = player.Character:FindFirstChild('HumanoidRootPart')
                if root then
                    root.Velocity = Vector3.new(
                        root.Velocity.X,
                        h.JumpPower,
                        root.Velocity.Z
                    )
                end
            end
        end)
    end
end

local function antiRagdoll()
    local char = player.Character
    if char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA('BodyVelocity') or v:IsA('BodyAngularVelocity') then
                v:Destroy()
            end
        end
    end
end

local function toggleForceField()
    local char = player.Character
    if char then
        if gravityLow then
            if not char:FindFirstChildOfClass('ForceField') then
                local ff = Instance.new('ForceField', char)
                ff.Visible = false
            end
        else
            for _, ff in ipairs(char:GetChildren()) do
                if ff:IsA('ForceField') then
                    ff:Destroy()
                end
            end
        end
    end
end

local function switchGravityJump()
    gravityLow = not gravityLow
    Workspace.Gravity = gravityLow and REDUCED_GRAV or NORMAL_GRAV
    setJumpPower(gravityLow and BOOST_JUMP or NORMAL_JUMP)
    enableInfiniteJump(gravityLow)
    antiRagdoll()
    toggleForceField()
    spoofedGravity = NORMAL_GRAV
    
    if gravityLow then
        showNotification("Infinite Jump Enabled", true)
    else
        showNotification("Infinite Jump Disabled", false)
    end
    saveSettings()
end

-- Fly to Base (Optimized)
local flyConn
local flyAtt, flyLV
local flyCharRemovingConn
local destTouchedConn

local FLY_GRAV = 20
local FLY_JUMP = 7
local FLY_STOPDIST = 7
local FLY_XZ_SPEED = 22
local FLY_Y_BASE = -1.0
local FLY_Y_MAX = -2.2
local FLY_TIME_STEP = 1.5

local function clearFlyConnections()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyCharRemovingConn then flyCharRemovingConn:Disconnect() flyCharRemovingConn = nil end
    if destTouchedConn then destTouchedConn:Disconnect() destTouchedConn = nil end
end

local function destroyFlyBodies()
    if flyLV then flyLV:Destroy() flyLV = nil end
    if flyAtt then flyAtt:Destroy() flyAtt = nil end
end

local function findMyDeliveryPart()
    local plots = Workspace:FindFirstChild('Plots')
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild('PlotSign')
            if sign and sign:FindFirstChild('YourBase') and sign.YourBase.Enabled then
                local delivery = plot:FindFirstChild('DeliveryHitbox')
                if delivery and delivery:IsA('BasePart') then
                    return delivery
                end
            end
        end
    end
    return nil
end

local function flyGetDescent(dist)
    local maxdist = 200
    dist = math.clamp(dist, 0, maxdist)
    local t = 1 - (dist / maxdist)
    return FLY_Y_BASE + (FLY_Y_MAX - FLY_Y_BASE) * t
end

local function restoreSourceAndPhysics()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass('Humanoid')
    if hum then
        if gravityLow then
            Workspace.Gravity = REDUCED_GRAV
            setJumpPower(BOOST_JUMP)
            enableInfiniteJump(true)
        else
            Workspace.Gravity = NORMAL_GRAV
            setJumpPower(NORMAL_JUMP)
            enableInfiniteJump(false)
        end
        spoofedGravity = NORMAL_GRAV
    end
end

local function cleanupFly()
    clearFlyConnections()
    destroyFlyBodies()
    restoreSourceAndPhysics()
    flyActive = false
end

local function startFlyToBase()
    if flyActive then
        cleanupFly()
        showNotification("Flight Stopped", false)
        return
    end

    local destPart = findMyDeliveryPart()
    if not destPart then
        showNotification("No base found!", false)
        return
    end

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass('Humanoid')
    local hrp = char and char:FindFirstChild('HumanoidRootPart')
    if not (hum and hrp) then return end

    enableInfiniteJump(false)
    Workspace.Gravity = FLY_GRAV
    spoofedGravity = NORMAL_GRAV
    hum.UseJumpPower = true
    hum.JumpPower = FLY_JUMP

    flyActive = true

    flyAtt = Instance.new('Attachment')
    flyAtt.Name = 'FlyToBaseAttachment'
    flyAtt.Parent = hrp

    flyLV = Instance.new('LinearVelocity')
    flyLV.Attachment0 = flyAtt
    flyLV.RelativeTo = Enum.ActuatorRelativeTo.World
    flyLV.MaxForce = math.huge
    flyLV.Parent = hrp

    local reached = false
    local lastYUpdate = 0

    -- Initial velocity
    local pos = hrp.Position
    local destPos = destPart.Position
    local distXZ = (Vector3.new(destPos.X, pos.Y, destPos.Z) - pos).Magnitude
    local yVel = flyGetDescent(distXZ)
    local dirXZ = Vector3.new(destPos.X - pos.X, 0, destPos.Z - pos.Z)
    if dirXZ.Magnitude > 0 then
        dirXZ = dirXZ.Unit
    end
    flyLV.VectorVelocity = Vector3.new(dirXZ.X * FLY_XZ_SPEED, yVel, dirXZ.Z * FLY_XZ_SPEED)
    lastYUpdate = tick()

    destTouchedConn = destPart.Touched:Connect(function(hit)
        if not flyActive then return end
        local ch = player.Character
        if ch and hit and hit:IsDescendantOf(ch) then
            reached = true
            cleanupFly()
            showNotification("Arrived at base!", true)
        end
    end)

    flyConn = RunService.Heartbeat:Connect(function()
        if not flyActive then
            cleanupFly()
            return
        end

        if not (hrp and hrp.Parent and hum and hum.Parent) then
            cleanupFly()
            return
        end

        local pos = hrp.Position
        local destPos = destPart.Position
        local distXZ = (Vector3.new(destPos.X, pos.Y, destPos.Z) - pos).Magnitude

        if distXZ < FLY_STOPDIST and not reached then
            reached = true
            cleanupFly()
            showNotification("Arrived at base!", true)
            return
        end

        if tick() - lastYUpdate >= FLY_TIME_STEP then
            local yVel = flyGetDescent(distXZ)
            local dirXZ = Vector3.new(destPos.X - pos.X, 0, destPos.Z - pos.Z)
            if dirXZ.Magnitude > 0 then
                dirXZ = dirXZ.Unit
            end
            flyLV.VectorVelocity = Vector3.new(
                dirXZ.X * FLY_XZ_SPEED,
                yVel,
                dirXZ.Z * FLY_XZ_SPEED
            )
            lastYUpdate = tick()
        end
    end)

    flyCharRemovingConn = player.CharacterRemoving:Connect(cleanupFly)
    showNotification("Flying to base...", true)
end

-- ESP Base (Fixed)
local baseEspObjects = {}
local baseEspLoop

local function clearBaseESP()
    for _, obj in pairs(baseEspObjects) do
        pcall(function() obj:Destroy() end)
    end
    baseEspObjects = {}
end

local function updateBaseESP()
    if not espBaseActive then return end
    clearBaseESP()
    
    local plots = Workspace:FindFirstChild('Plots')
    if not plots then return end

    for _, plot in pairs(plots:GetChildren()) do
        local purchases = plot:FindFirstChild('Purchases')
        local pb = purchases and purchases:FindFirstChild('PlotBlock')
        local main = pb and pb:FindFirstChild('Main')
        local gui = main and main:FindFirstChild('BillboardGui')
        local timeLb = gui and gui:FindFirstChild('RemainingTime')
        
        if timeLb and main then
            local billboard = Instance.new('BillboardGui')
            billboard.Name = 'Base_ESP'
            billboard.Size = UDim2.new(0, 140, 0, 36)
            billboard.StudsOffset = Vector3.new(0, 5, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = main

            local label = Instance.new('TextLabel')
            label.Text = timeLb.Text
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextScaled = true
            label.TextColor3 = Color3.fromRGB(220, 0, 60)
            label.Font = Enum.Font.Arcade
            label.TextStrokeTransparency = 0.5
            label.TextStrokeColor3 = Color3.new(0, 0, 0)
            label.Parent = billboard

            table.insert(baseEspObjects, billboard)
        end
    end
end

local function toggleBaseESP()
    espBaseActive = not espBaseActive
    
    if baseEspLoop then
        baseEspLoop:Disconnect()
        baseEspLoop = nil
    end
    
    if espBaseActive then
        updateBaseESP()
        baseEspLoop = RunService.Heartbeat:Connect(function()
            if not espBaseActive then
                baseEspLoop:Disconnect()
                baseEspLoop = nil
                return
            end
            wait(2)
            updateBaseESP()
        end)
        showNotification("Base ESP Enabled", true)
    else
        clearBaseESP()
        showNotification("Base ESP Disabled", false)
    end
    saveSettings()
end

-- ESP Best (Fixed)
local bestEspObjects = {}
local bestEspLoop

local function clearBestESP()
    for _, obj in pairs(bestEspObjects) do
        pcall(function() obj:Destroy() end)
    end
    bestEspObjects = {}
end

local function parseMoneyPerSec(text)
    if not text then return 0 end
    local mult = 1
    local numberStr = text:match('[%d%.]+')
    if not numberStr then return 0 end
    
    if text:find('K') then mult = 1_000
    elseif text:find('M') then mult = 1_000_000
    elseif text:find('B') then mult = 1_000_000_000
    elseif text:find('T') then mult = 1_000_000_000_000
    elseif text:find('Q') then mult = 1_000_000_000_000_000 end
    
    return (tonumber(numberStr) or 0) * mult
end

local function updateBestESP()
    if not espBestActive then return end
    clearBestESP()
    
    local plots = Workspace:FindFirstChild('Plots')
    if not plots then return end

    local bestPetInfo = nil

    for _, plot in ipairs(plots:GetChildren()) do
        for _, desc in ipairs(plot:GetDescendants()) do
            if desc:IsA('TextLabel') and desc.Name == 'Rarity' and desc.Parent and desc.Parent:FindFirstChild('DisplayName') then
                local parentModel = desc.Parent.Parent
                local genLabel = desc.Parent:FindFirstChild('Generation')
                
                if genLabel and genLabel:IsA('TextLabel') then
                    local mps = parseMoneyPerSec(genLabel.Text)
                    if not bestPetInfo or mps > bestPetInfo.mps then
                        bestPetInfo = {
                            petName = desc.Parent.DisplayName.Text,
                            genText = genLabel.Text,
                            mps = mps,
                            model = parentModel,
                        }
                    end
                end
            end
        end
    end

    if bestPetInfo and bestPetInfo.mps > 0 and bestPetInfo.model then
        local billboard = Instance.new('BillboardGui')
        billboard.Name = 'Best_ESP'
        billboard.Size = UDim2.new(0, 303, 0, 75)
        billboard.StudsOffset = Vector3.new(0, 4.84, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = bestPetInfo.model
        
        local nameLabel = Instance.new('TextLabel')
        nameLabel.Size = UDim2.new(1, 0, 0, 35)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = bestPetInfo.petName
        nameLabel.TextColor3 = Color3.fromRGB(255, 0, 60)
        nameLabel.Font = Enum.Font.GothamSemibold
        nameLabel.TextSize = 25
        nameLabel.TextStrokeTransparency = 0.07
        nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        nameLabel.Parent = billboard
        
        local moneyLabel = Instance.new('TextLabel')
        moneyLabel.Size = UDim2.new(1, 0, 0, 22)
        moneyLabel.Position = UDim2.new(0, 0, 0, 35)
        moneyLabel.BackgroundTransparency = 1
        moneyLabel.Text = bestPetInfo.genText
        moneyLabel.TextColor3 = Color3.fromRGB(0, 240, 60)
        moneyLabel.Font = Enum.Font.GothamSemibold
        moneyLabel.TextSize = 22
        moneyLabel.TextStrokeTransparency = 0.17
        moneyLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        moneyLabel.Parent = billboard

        table.insert(bestEspObjects, billboard)
    end
end

local function toggleBestESP()
    espBestActive = not espBestActive
    
    if bestEspLoop then
        bestEspLoop:Disconnect()
        bestEspLoop = nil
    end
    
    if espBestActive then
        updateBestESP()
        bestEspLoop = RunService.Heartbeat:Connect(function()
            if not espBestActive then
                bestEspLoop:Disconnect()
                bestEspLoop = nil
                return
            end
            wait(2)
            updateBestESP()
        end)
        showNotification("Best ESP Enabled", true)
    else
        clearBestESP()
        showNotification("Best ESP Disabled", false)
    end
    saveSettings()
end

-- Player ESP (Fixed)
local playerEspBoxes = {}
local playerEspLoop

local function clearPlayerESP()
    for plr, objs in pairs(playerEspBoxes) do
        if objs.box then pcall(function() objs.box:Destroy() end) end
        if objs.text then pcall(function() objs.text:Destroy() end) end
    end
    playerEspBoxes = {}
end

local function updatePlayerESP()
    if not playerEspActive then return end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild('HumanoidRootPart') then
            local hrp = plr.Character.HumanoidRootPart
            if not playerEspBoxes[plr] then
                playerEspBoxes[plr] = {}
                
                local box = Instance.new('BoxHandleAdornment')
                box.Size = Vector3.new(4, 6, 4)
                box.Adornee = hrp
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Transparency = 0.5
                box.Color3 = Color3.fromRGB(250, 0, 60)
                box.Parent = hrp
                playerEspBoxes[plr].box = box

                local billboard = Instance.new('BillboardGui')
                billboard.Adornee = hrp
                billboard.Size = UDim2.new(0, 200, 0, 30)
                billboard.StudsOffset = Vector3.new(0, 4, 0)
                billboard.AlwaysOnTop = true
                
                local label = Instance.new('TextLabel', billboard)
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.fromRGB(220, 0, 60)
                label.TextStrokeTransparency = 0
                label.Text = plr.Name
                label.Font = Enum.Font.GothamBold
                label.TextSize = 18
                
                playerEspBoxes[plr].text = billboard
                billboard.Parent = hrp
            else
                if playerEspBoxes[plr].box then playerEspBoxes[plr].box.Adornee = hrp end
                if playerEspBoxes[plr].text then playerEspBoxes[plr].text.Adornee = hrp end
            end
        else
            if playerEspBoxes[plr] then
                if playerEspBoxes[plr].box then pcall(function() playerEspBoxes[plr].box:Destroy() end) end
                if playerEspBoxes[plr].text then pcall(function() playerEspBoxes[plr].text:Destroy() end) end
                playerEspBoxes[plr] = nil
            end
        end
    end
end

local function togglePlayerESP()
    playerEspActive = not playerEspActive
    
    if playerEspLoop then
        playerEspLoop:Disconnect()
        playerEspLoop = nil
    end
    
    if playerEspActive then
        updatePlayerESP()
        playerEspLoop = RunService.Heartbeat:Connect(updatePlayerESP)
        showNotification("Player ESP Enabled", true)
    else
        clearPlayerESP()
        showNotification("Player ESP Disabled", false)
    end
    saveSettings()
end

-- Steal Floor (Optimized)
local sfAttachment, sfAlignPosition, sfAlignOrientation, sfLinearVelocity
local sfHeartbeatConn, sfPromptConn, sfDiedConn

local function sfSafeDisconnect(conn)
    if conn and typeof(conn) == "RBXScriptConnection" then
        pcall(function() conn:Disconnect() end)
    end
end

local function sfDestroyBodies()
    if sfLinearVelocity then pcall(function() sfLinearVelocity:Destroy() end) end
    if sfAlignPosition then pcall(function() sfAlignPosition:Destroy() end) end
    if sfAlignOrientation then pcall(function() sfAlignOrientation:Destroy() end) end
    if sfAttachment then pcall(function() sfAttachment:Destroy() end) end
    sfLinearVelocity, sfAlignPosition, sfAlignOrientation, sfAttachment = nil, nil, nil, nil
end

local function sfCreateBodies(rootPart)
    sfDestroyBodies()
    if not rootPart then return end

    sfAttachment = Instance.new('Attachment')
    sfAttachment.Name = 'StealFloor_Attachment'
    sfAttachment.Parent = rootPart

    sfAlignPosition = Instance.new('AlignPosition')
    sfAlignPosition.Attachment0 = sfAttachment
    sfAlignPosition.MaxForce = 500000
    sfAlignPosition.Responsiveness = 200
    sfAlignPosition.Parent = rootPart

    sfAlignOrientation = Instance.new('AlignOrientation')
    sfAlignOrientation.Attachment0 = sfAttachment
    sfAlignOrientation.MaxTorque = 500000
    sfAlignOrientation.Responsiveness = 200
    sfAlignOrientation.Parent = rootPart

    sfLinearVelocity = Instance.new('LinearVelocity')
    sfLinearVelocity.Attachment0 = sfAttachment
    sfLinearVelocity.MaxForce = 500000
    sfLinearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
    sfLinearVelocity.Parent = rootPart
end

local function sfTeleportToGround()
    local char = player.Character
    local rp = char and char:FindFirstChild('HumanoidRootPart')
    local hum = char and char:FindFirstChildOfClass('Humanoid')
    if not (rp and hum and hum.Health > 0) then return end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {char}

    local rayResult = Workspace:Raycast(rp.Position, Vector3.new(0, -1500, 0), rayParams)
    if rayResult then
        rp.CFrame = CFrame.new(
            rp.Position.X,
            rayResult.Position.Y + hum.HipHeight,
            rp.Position.Z
        )
        if stealFloorActive then
            toggleStealFloor()
        end
    end
end

local function sfEnable()
    if stealFloorActive then return end
    local hum = player.Character and player.Character:FindFirstChildOfClass('Humanoid')
    local root = player.Character and player.Character:FindFirstChild('HumanoidRootPart')
    if not (hum and hum.Health > 0 and root) then return end

    stealFloorActive = true
    sfCreateBodies(root)

    sfHeartbeatConn = RunService.Heartbeat:Connect(function()
        if not stealFloorActive or not sfLinearVelocity then return end
        local h = player.Character and player.Character:FindFirstChildOfClass('Humanoid')
        if not (h and h.Health > 0) then
            toggleStealFloor()
            return
        end
        sfLinearVelocity.VectorVelocity = Vector3.new(0, 24, 0)
    end)

    sfPromptConn = ProximityPromptService.PromptTriggered:Connect(function(prompt, who)
        if who == player then
            local act = (prompt.ActionText or ''):lower()
            if string.find(act, 'steal') then
                sfTeleportToGround()
            end
        end
    end)

    if hum then
        sfDiedConn = hum.Died:Connect(toggleStealFloor)
    end
end

local function sfDisable()
    if not stealFloorActive then return end
    stealFloorActive = false
    sfDestroyBodies()
    sfSafeDisconnect(sfHeartbeatConn)
    sfSafeDisconnect(sfPromptConn)
    sfSafeDisconnect(sfDiedConn)
end

local function toggleStealFloor()
    if not stealFloorActive then
        sfEnable()
        showNotification("Steal Floor Enabled", true)
    else
        sfDisable()
        showNotification("Steal Floor Disabled", false)
    end
    saveSettings()
end

-- Deysnc System (Optimized)
local clonerActive = false
local desyncRunning = false
local cloneListenerConn
local antiHitRunning = false

local function safeDisconnectConn(conn)
    if conn and typeof(conn) == "RBXScriptConnection" then
        pcall(function() conn:Disconnect() end)
    end
end

local function trySetFlag()
    pcall(function()
        if setfflag then setfflag("WorldStepMax", "-99999999999999") end
    end)
end

local function resetFlag()
    pcall(function()
        if setfflag then setfflag("WorldStepMax", "1") end
    end)
end

local function activateDesync()
    if desyncRunning then return end
    desyncRunning = true
    trySetFlag()
end

local function deactivateDesync()
    if not desyncRunning then return end
    desyncRunning = false
    resetFlag()
end

local function executeAdvancedDesync()
    if antiHitRunning then return end
    antiHitRunning = true

    activateDesync()
    task.wait(0.1)
    
    -- Try to use Quantum Cloner
    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        local cloner = backpack:FindFirstChild("Quantum Cloner")
        if cloner then
            local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then 
                humanoid:EquipTool(cloner)
                task.wait(0.5)
            end
        end
    end

    -- Fire network events
    local REUseItem = ReplicatedStorage:FindFirstChild("RE/UseItem", true)
    if REUseItem then 
        REUseItem:FireServer()
    end
    
    deactivateDesync()
    antiHitRunning = false
    antiHitActive = true
    saveSettings()
    showNotification("Deysnc Activated", true)
end

local function deactivateAdvancedDesync()
    if antiHitRunning then
        safeDisconnectConn(cloneListenerConn)
        antiHitRunning = false
    end

    deactivateDesync()
    antiHitActive = false
    
    local clone = Workspace:FindFirstChild(tostring(player.UserId) .. "_Clone")
    if clone then
        pcall(function() clone:Destroy() end)
    end
    
    saveSettings()
    showNotification("Deysnc Disabled", false)
end

local function toggleDeysnc()
    if antiHitRunning then
        showNotification("Deysnc is working...", false)
        return
    end
    
    if antiHitActive then
        deactivateAdvancedDesync()
    else
        executeAdvancedDesync()
    end
end

-- UI Creation (Optimized)
local playerGui = player:WaitForChild('PlayerGui')

-- Clean old GUIs
do
    local old = playerGui:FindFirstChild('VortexHelper')
    if old then old:Destroy() end
end

-- V Logo Button
local logoGui = Instance.new("ScreenGui")
logoGui.Name = "VortexLogo"
logoGui.ResetOnSpawn = false
logoGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
logoGui.Parent = playerGui

local logoButton = Instance.new("TextButton")
logoButton.Name = "VLogo"
logoButton.Size = UDim2.new(0, 35, 0, 35)
logoButton.Position = UDim2.new(0, 10, 0, 10)
logoButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
logoButton.BackgroundTransparency = 0.2
logoButton.Text = "V"
logoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
logoButton.TextSize = 16
logoButton.Font = Enum.Font.GothamBlack
logoButton.AutoButtonColor = false
logoButton.Draggable = true
logoButton.Parent = logoGui

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(1, 0)
logoCorner.Parent = logoButton

local logoStroke = Instance.new("UIStroke")
logoStroke.Color = Color3.fromRGB(200, 230, 255)
logoStroke.Thickness = 1.5
logoStroke.Parent = logoButton

-- Main GUI
local gui = Instance.new('ScreenGui')
gui.Name = 'VortexHelper'
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new('Frame')
mainFrame.Size = UDim2.new(0, 160, 0, 180)
mainFrame.Position = UDim2.new(0.5, -80, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = gui

local mainCorner = Instance.new('UICorner', mainFrame)
mainCorner.CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new('UIStroke', mainFrame)
mainStroke.Thickness = 2
mainStroke.Color = Color3.fromRGB(100, 150, 255)
mainStroke.Transparency = 0.2

-- Header with Tabs
local header = Instance.new('Frame')
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
header.BackgroundTransparency = 0.1
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

-- Tab Buttons
local tab1Btn = Instance.new('TextButton')
tab1Btn.Name = 'Tab1'
tab1Btn.Size = UDim2.new(0.5, -2, 1, 0)
tab1Btn.Position = UDim2.new(0, 0, 0, 0)
tab1Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
tab1Btn.Text = "MAIN"
tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
tab1Btn.TextSize = 11
tab1Btn.Font = Enum.Font.GothamBold
tab1Btn.AutoButtonColor = false
tab1Btn.Parent = header

local tab1Corner = Instance.new("UICorner")
tab1Corner.CornerRadius = UDim.new(0, 8)
tab1Corner.Parent = tab1Btn

local tab2Btn = Instance.new('TextButton')
tab2Btn.Name = 'Tab2'
tab2Btn.Size = UDim2.new(0.5, -2, 1, 0)
tab2Btn.Position = UDim2.new(0.5, 0, 0, 0)
tab2Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
tab2Btn.Text = "VISUAL"
tab2Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
tab2Btn.TextSize = 11
tab2Btn.Font = Enum.Font.GothamBold
tab2Btn.AutoButtonColor = false
tab2Btn.Parent = header

local tab2Corner = Instance.new("UICorner")
tab2Corner.CornerRadius = UDim.new(0, 8)
tab2Corner.Parent = tab2Btn

-- Content Areas
local contentTab1 = Instance.new('Frame')
contentTab1.Name = 'Tab1Content'
contentTab1.Size = UDim2.new(1, -8, 1, -35)
contentTab1.Position = UDim2.new(0, 4, 0, 31)
contentTab1.BackgroundTransparency = 1
contentTab1.Visible = true
contentTab1.Parent = mainFrame

local contentTab2 = Instance.new('Frame')
contentTab2.Name = 'Tab2Content'
contentTab2.Size = UDim2.new(1, -8, 1, -35)
contentTab2.Position = UDim2.new(0, 4, 0, 31)
contentTab2.BackgroundTransparency = 1
contentTab2.Visible = false
contentTab2.Parent = mainFrame

-- Title
local title = Instance.new('TextLabel', header)
title.Size = UDim2.new(1, 0, 0, 15)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = 'VORTEX HELPER'
title.TextColor3 = Color3.fromRGB(100, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.BackgroundTransparency = 1
title.TextStrokeTransparency = 0.7

-- Button Creation Function
local function createButton(parent, text, yPos, callback, isActive)
    local btn = Instance.new('TextButton', parent)
    btn.Size = UDim2.new(0.95, 0, 0, 25)
    btn.Position = UDim2.new(0.025, 0, 0, yPos)
    btn.BackgroundColor3 = isActive and Color3.fromRGB(60, 220, 100) or Color3.fromRGB(220, 60, 60)
    btn.Text = text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    
    local btnCorner = Instance.new('UICorner', btn)
    btnCorner.CornerRadius = UDim.new(0, 6)
    
    local btnStroke = Instance.new('UIStroke', btn)
    btnStroke.Color = Color3.fromRGB(255, 255, 255)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.3
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- V Logo click event
local mainFrameVisible = false
logoButton.MouseButton1Click:Connect(function()
    mainFrameVisible = not mainFrameVisible
    mainFrame.Visible = mainFrameVisible
end)

-- Logo hover effect
logoButton.MouseEnter:Connect(function()
    TweenService:Create(logoButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.1,
        Size = UDim2.new(0, 37, 0, 37)
    }):Play()
end)

logoButton.MouseLeave:Connect(function()
    TweenService:Create(logoButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.2,
        Size = UDim2.new(0, 35, 0, 35)
    }):Play()
end)

-- Tab switching function
local currentTab = 1

local function switchTab(tabNumber)
    currentTab = tabNumber
    
    contentTab1.Visible = false
    contentTab2.Visible = false
    
    tab1Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    tab2Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    
    tab1Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tab2Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    
    if tabNumber == 1 then
        contentTab1.Visible = true
        tab1Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        contentTab2.Visible = true
        tab2Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        tab2Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

-- Tab button events
tab1Btn.MouseButton1Click:Connect(function() switchTab(1) end)
tab2Btn.MouseButton1Click:Connect(function() switchTab(2) end)

-- Load settings
local settings = loadSettings()

-- Apply settings
if settings.infJump ~= nil then
    gravityLow = settings.infJump
    if gravityLow then
        switchGravityJump()
    end
end

if settings.espBase ~= nil then
    espBaseActive = settings.espBase
end

if settings.espBest ~= nil then
    espBestActive = settings.espBest
end

if settings.desync ~= nil then
    antiHitActive = settings.desync
end

if settings.fpsDevourer ~= nil then
    fpsDevourerActive = settings.fpsDevourer
end

if settings.playerESP ~= nil then
    playerEspActive = settings.playerESP
end

if settings.stealFloor ~= nil then
    stealFloorActive = settings.stealFloor
end

-- Create buttons for Tab 1 (Main)
local yPos = 5
createButton(contentTab1, fpsDevourerActive and '✅ FPS' or '🎯 FPS', yPos, toggleFPSDevourer, fpsDevourerActive)
yPos = yPos + 28
createButton(contentTab1, gravityLow and '✅ Jump' or '🦘 Jump', yPos, switchGravityJump, gravityLow)
yPos = yPos + 28
createButton(contentTab1, '🚀 Fly Base', yPos, startFlyToBase, false)

-- Create buttons for Tab 2 (Visual)
yPos = 5
createButton(contentTab2, espBaseActive and '✅ Base' or '🏠 Base', yPos, toggleBaseESP, espBaseActive)
yPos = yPos + 28
createButton(contentTab2, espBestActive and '✅ Best' or '🔥 Best', yPos, toggleBestESP, espBestActive)
yPos = yPos + 28
createButton(contentTab2, playerEspActive and '✅ Player' or '👥 Player', yPos, togglePlayerESP, playerEspActive)

-- Drag functionality for main frame
local dragging = false
local dragInput, dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
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

mainFrame.InputChanged:Connect(function(input)
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

-- Enable FPS Devourer on start if saved
if not fpsDevourerActive then
    enableFPSDevourer()
end

-- Startup notification
showNotification("Vortex's Helper Loaded!", true)

-- Disable future notifications after 3 seconds
wait(3)
startupNotifications = false

print("🎯 Vortex's Helper Loaded!")
print("✅ FPS Devourer Active")
print("🦘 Inf Jump Ready")
print("🚀 Fly to Base Ready")
print("🏠 ESP Base Ready")
print("🔥 ESP Best Ready")
print("👥 Player ESP Ready")
print("🏗️ Steal Floor Ready")
print("🌀 Deysnc System Ready")
print("🔷 V Logo: Click to open/close main menu")
print("💾 Settings Saving: Vortex'sHelper Folder")
