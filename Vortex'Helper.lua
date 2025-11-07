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

-- Notification System (Sadece script başlangıcında)
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

----------------------------------------------------------------
-- FPS DEVOURER (YENİ KOD)
----------------------------------------------------------------
local fpsDevourerActive = false

local function enableFPSDevourer()
    fpsDevourerActive = true
    
    -- FPS cap artırma
    pcall(function()
        if setfpscap then
            setfpscap(999)
        end
    end)
    
    -- Grafik optimizasyonları
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Part") or obj:IsA("UnionOperation") or obj:IsA("MeshPart") then
            pcall(function()
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
            end)
        end
    end
    
    -- Lighting optimizasyonları
    local lighting = game:GetService("Lighting")
    pcall(function()
        lighting.GlobalShadows = false
        lighting.FogEnd = 100000
        lighting.Brightness = 2
    end)
    
    -- Görsel efektleri kapat
    for _, effect in pairs(Workspace:GetDescendants()) do
        if effect:IsA("ParticleEmitter") or effect:IsA("Fire") or effect:IsA("Smoke") or effect:IsA("Sparkles") then
            effect.Enabled = false
        end
    end
    
    -- Karakter için optimizasyon
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
end

local function disableFPSDevourer()
    fpsDevourerActive = false
    
    -- FPS cap sıfırlama
    pcall(function()
        if setfpscap then
            setfpscap(60)
        end
    end)
    
    -- Lighting sıfırlama
    local lighting = game:GetService("Lighting")
    pcall(function()
        lighting.GlobalShadows = true
        lighting.Brightness = 1
    end)
    
    saveSettings()
end

local function toggleFPSDevourer()
    if fpsDevourerActive then
        disableFPSDevourer()
    else
        enableFPSDevourer()
    end
end

----------------------------------------------------------------
-- INF JUMP / JUMP BOOST (YENİ KOD)
----------------------------------------------------------------
local NORMAL_GRAV = 196.2
local REDUCED_GRAV = 40
local NORMAL_JUMP = 30
local BOOST_JUMP = 50

local gravityLow = false
local infiniteJumpConn

local function setJumpPower(jump)
    local h = player.Character and player.Character:FindFirstChildOfClass('Humanoid')
    if h then
        h.JumpPower = jump
        h.UseJumpPower = true
    end
end

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
    
    saveSettings()
end

-- Orijinal Vortex Helper kodunun geri kalanı aynı kalacak...
-- FLY TO BASE kısmı
local flyActive = false
local flyConn
local flyAtt, flyLV
local flyCharRemovingConn
local destTouchedConn
local destPartRef
local flyRestoreOldGravity, flyRestoreOldJumpPower

local FLY_GRAV = 20
local FLY_JUMP = 7
local FLY_STOPDIST = 7
local FLY_XZ_SPEED = 22
local FLY_Y_BASE = -1.0
local FLY_Y_MAX = -2.2
local FLY_TIME_STEP = 1.5

local function clearFlyConnections()
    if flyConn then
        pcall(function()
            flyConn:Disconnect()
        end)
        flyConn = nil
    end
    if flyCharRemovingConn then
        pcall(function()
            flyCharRemovingConn:Disconnect()
        end)
        flyCharRemovingConn = nil
    end
    if destTouchedConn then
        pcall(function()
            destTouchedConn:Disconnect()
        end)
        destTouchedConn = nil
    end
end

local function destroyFlyBodies()
    if flyLV then
        pcall(function()
            flyLV:Destroy()
        end)
        flyLV = nil
    end
    if flyAtt then
        pcall(function()
            flyAtt:Destroy()
        end)
        flyAtt = nil
    end
    destPartRef = nil
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
    else
        Workspace.Gravity = flyRestoreOldGravity or NORMAL_GRAV
        pcall(function()
            if hum and flyRestoreOldJumpPower then
                hum.JumpPower = flyRestoreOldJumpPower
            end
        end)
    end
end

local function cleanupFly()
    clearFlyConnections()
    destroyFlyBodies()
    restoreSourceAndPhysics()
    flyActive = false
end

local function finishFly(success)
    cleanupFly()
end

local function startFlyToBase()
    if flyActive then
        finishFly(false)
        return
    end

    local destPart = findMyDeliveryPart()
    if not destPart then
        return
    end

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass('Humanoid')
    local hrp = char and char:FindFirstChild('HumanoidRootPart')
    if not (hum and hrp) then
        return
    end

    flyRestoreOldGravity = Workspace.Gravity
    flyRestoreOldJumpPower = hum.JumpPower

    enableInfiniteJump(false)

    Workspace.Gravity = FLY_GRAV
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

    destPartRef = destPart

    local reached = false
    local lastYUpdate = 0

    do
        local pos = hrp.Position
        local destPos = destPart.Position
        local distXZ = (Vector3.new(destPos.X, pos.Y, destPos.Z) - pos).Magnitude
        local yVel = flyGetDescent(distXZ)
        local dirXZ = Vector3.new(destPos.X - pos.X, 0, destPos.Z - pos.Z)
        if dirXZ.Magnitude > 0 then
            dirXZ = dirXZ.Unit
        else
            dirXZ = Vector3.new()
        end
        flyLV.VectorVelocity = Vector3.new(dirXZ.X * FLY_XZ_SPEED, yVel, dirXZ.Z * FLY_XZ_SPEED)
        lastYUpdate = tick()
    end

    destTouchedConn = destPart.Touched:Connect(function(hit)
        if not flyActive then
            return
        end
        local ch = player.Character
        if ch and hit and hit:IsDescendantOf(ch) then
            reached = true
            finishFly(true)
        end
    end)

    if flyConn then
        flyConn:Disconnect()
        flyConn = nil
    end
    flyConn = RunService.Heartbeat:Connect(function()
        if not flyActive then
            cleanupFly()
            return
        end

        if not (hrp and hrp.Parent and hum and hum.Parent) then
            finishFly(false)
            return
        end

        local pos = hrp.Position
        local destPos = destPart.Position
        local distXZ = (Vector3.new(destPos.X, pos.Y, destPos.Z) - pos).Magnitude

        if distXZ < FLY_STOPDIST and not reached then
            reached = true
            finishFly(true)
            return
        end

        if tick() - lastYUpdate >= FLY_TIME_STEP then
            local yVel = flyGetDescent(distXZ)
            local dirXZ = Vector3.new(destPos.X - pos.X, 0, destPos.Z - pos.Z)
            if dirXZ.Magnitude > 0 then
                dirXZ = dirXZ.Unit
            else
                dirXZ = Vector3.new()
            end
            flyLV.VectorVelocity = Vector3.new(
                dirXZ.X * FLY_XZ_SPEED,
                yVel,
                dirXZ.Z * FLY_XZ_SPEED
            )
            lastYUpdate = tick()
        end
    end)

    if flyCharRemovingConn then
        flyCharRemovingConn:Disconnect()
        flyCharRemovingConn = nil
    end
    flyCharRemovingConn = player.CharacterRemoving:Connect(function()
        if flyActive then
            finishFly(false)
        else
            cleanupFly()
        end
    end)
end

-- ESP BASE kısmı (orijinal Vortex kodu)
local espBaseActive = false
local baseEspObjects = {}

local function clearBaseESP()
    for _, obj in pairs(baseEspObjects) do
        pcall(function()
            obj:Destroy()
        end)
    end
    baseEspObjects = {}
end

local function updateBaseESP()
    if not espBaseActive then return end
    
    clearBaseESP()
    
    local plots = Workspace:FindFirstChild('Plots')
    if not plots then return end

    local myPlotName
    for _, plot in pairs(plots:GetChildren()) do
        local plotSign = plot:FindFirstChild('PlotSign')
        if plotSign and plotSign:FindFirstChild('YourBase') and plotSign.YourBase.Enabled then
            myPlotName = plot.Name
            break
        end
    end

    if not myPlotName then return end

    for _, plot in pairs(plots:GetChildren()) do
        if plot.Name ~= myPlotName then
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
end

local baseEspLoop
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
    else
        clearBaseESP()
    end
    saveSettings()
end

-- ESP BEST kısmı (orijinal Vortex kodu)
local espBestActive = false
local bestEspObjects = {}

local function clearBestESP()
    for _, obj in pairs(bestEspObjects) do
        pcall(function()
            obj:Destroy()
        end)
    end
    bestEspObjects = {}
end

local function parseMoneyPerSec(text)
    if not text then
        return 0
    end
    local mult = 1
    local numberStr = text:match('[%d%.]+')
    if not numberStr then
        return 0
    end
    if text:find('K') then
        mult = 1_000
    elseif text:find('M') then
        mult = 1_000_000
    elseif text:find('B') then
        mult = 1_000_000_000
    elseif text:find('T') then
        mult = 1_000_000_000_000
    elseif text:find('Q') then
        mult = 1_000_000_000_000_000
    end
    local number = tonumber(numberStr)
    return number and number * mult or 0
end

local function updateBestESP()
    if not espBestActive then return end
    
    clearBestESP()
    
    local plots = Workspace:FindFirstChild('Plots')
    if not plots then return end

    local myPlotName
    for _, plot in ipairs(plots:GetChildren()) do
        local plotSign = plot:FindFirstChild('PlotSign')
        if plotSign and plotSign:FindFirstChild('YourBase') and plotSign.YourBase.Enabled then
            myPlotName = plot.Name
            break
        end
    end

    local bestPetInfo = nil

    for _, plot in ipairs(plots:GetChildren()) do
        if plot.Name ~= myPlotName then
            for _, desc in ipairs(plot:GetDescendants()) do
                if desc:IsA('TextLabel') and desc.Name == 'Rarity' and desc.Parent and desc.Parent:FindFirstChild('DisplayName') then
                    local parentModel = desc.Parent.Parent
                    local rarity = desc.Text
                    local displayName = desc.Parent.DisplayName.Text

                    if espBestActive then
                        local genLabel = desc.Parent:FindFirstChild('Generation')
                        if genLabel and genLabel:IsA('TextLabel') then
                            local mps = parseMoneyPerSec(genLabel.Text)
                            if not bestPetInfo or mps > bestPetInfo.mps then
                                bestPetInfo = {
                                    petName = displayName,
                                    genText = genLabel.Text,
                                    mps = mps,
                                    model = parentModel,
                                }
                            end
                        end
                    end
                end
            end
        end
    end

    if espBestActive then
        for _, plot in ipairs(plots:GetChildren()) do
            for _, inst in ipairs(plot:GetDescendants()) do
                if inst:IsA('BillboardGui') and inst.Name == 'Best_ESP' then
                    pcall(function()
                        inst:Destroy()
                    end)
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
end

local bestEspLoop
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
    else
        clearBestESP()
    end
    saveSettings()
end

-- PLAYER ESP kısmı (orijinal Vortex kodu)
local playerEspActive = false
local playerEspBoxes = {}

local function clearPlayerESP()
    for plr, objs in pairs(playerEspBoxes) do
        if objs.box then
            pcall(function()
                objs.box:Destroy()
            end)
        end
        if objs.text then
            pcall(function()
                objs.text:Destroy()
            end)
        end
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
                if playerEspBoxes[plr].box then
                    playerEspBoxes[plr].box.Adornee = hrp
                end
                if playerEspBoxes[plr].text then
                    playerEspBoxes[plr].text.Adornee = hrp
                end
            end
        else
            if playerEspBoxes[plr] then
                if playerEspBoxes[plr].box then
                    pcall(function()
                        playerEspBoxes[plr].box:Destroy()
                    end)
                end
                if playerEspBoxes[plr].text then
                    pcall(function()
                        playerEspBoxes[plr].text:Destroy()
                    end)
                end
                playerEspBoxes[plr] = nil
            end
        end
    end
end

local playerEspLoop
local function togglePlayerESP()
    playerEspActive = not playerEspActive
    
    if playerEspLoop then
        playerEspLoop:Disconnect()
        playerEspLoop = nil
    end
    
    if playerEspActive then
        updatePlayerESP()
        playerEspLoop = RunService.Heartbeat:Connect(function()
            if not playerEspActive then
                playerEspLoop:Disconnect()
                playerEspLoop = nil
                return
            end
            updatePlayerESP()
        end)
    else
        clearPlayerESP()
    end
    saveSettings()
end

Players.PlayerRemoving:Connect(function(plr)
    local objs = playerEspBoxes[plr]
    if objs then
        if objs.box then
            pcall(function()
                objs.box:Destroy()
            end)
        end
        if objs.text then
            pcall(function()
                objs.text:Destroy()
            end)
        end
        playerEspBoxes[plr] = nil
    end
end)

-- STEAL FLOOR kısmı (orijinal Vortex kodu)
local stealFloorActive = false
local sfFloatSpeed = 24
local sfAttachment, sfAlignPosition, sfAlignOrientation, sfLinearVelocity
local sfHeartbeatConn, sfPromptConn, sfDiedConn, sfCharAddedConn
local sfOriginalProps = {}

local function sfSafeDisconnect(conn)
    if conn and typeof(conn) == "RBXScriptConnection" then
        pcall(function()
            conn:Disconnect()
        end)
    end
end

local function sfSetPlotsTransparency(active)
    local plots = Workspace:FindFirstChild('Plots')
    if not plots then return end

    if active then
        sfOriginalProps = {}
        for _, plot in ipairs(plots:GetChildren()) do
            local containers = {
                plot:FindFirstChild('Decorations'),
                plot:FindFirstChild('AnimalPodiums'),
            }
            for _, container in ipairs(containers) do
                if container then
                    for _, obj in ipairs(container:GetDescendants()) do
                        if obj:IsA('BasePart') then
                            sfOriginalProps[obj] = {
                                Transparency = obj.Transparency,
                                Material = obj.Material,
                            }
                            obj.Transparency = 0.7
                        end
                    end
                end
            end
        end
    else
        for part, props in pairs(sfOriginalProps) do
            if part and part.Parent then
                part.Transparency = props.Transparency
                part.Material = props.Material
            end
        end
        sfOriginalProps = {}
    end
end

local function sfDestroyBodies()
    if sfLinearVelocity then
        pcall(function() sfLinearVelocity:Destroy() end)
    end
    if sfAlignPosition then
        pcall(function() sfAlignPosition:Destroy() end)
    end
    if sfAlignOrientation then
        pcall(function() sfAlignOrientation:Destroy() end)
    end
    if sfAttachment then
        pcall(function() sfAttachment:Destroy() end)
    end
    sfLinearVelocity, sfAlignPosition, sfAlignOrientation, sfAttachment = nil, nil, nil, nil
end

local function sfCreateBodies(rootPart)
    sfDestroyBodies()
    if not rootPart then return end

    sfAttachment = Instance.new('Attachment')
    sfAttachment.Name = 'StealFloor_Attachment'
    sfAttachment.Parent = rootPart

    sfAlignPosition = Instance.new('AlignPosition')
    sfAlignPosition.Name = 'StealFloor_AlignPosition'
    sfAlignPosition.Attachment0 = sfAttachment
    sfAlignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
    sfAlignPosition.Position = rootPart.Position
    sfAlignPosition.MaxForce = 500000
    sfAlignPosition.Responsiveness = 200
    sfAlignPosition.ApplyAtCenterOfMass = true
    sfAlignPosition.ForceLimitMode = Enum.ForceLimitMode.PerAxis
    sfAlignPosition.MaxAxesForce = Vector3.new(math.huge, 0, math.huge)
    sfAlignPosition.Parent = rootPart

    sfAlignOrientation = Instance.new('AlignOrientation')
    sfAlignOrientation.Name = 'StealFloor_AlignOrientation'
    sfAlignOrientation.Attachment0 = sfAttachment
    sfAlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    sfAlignOrientation.CFrame = rootPart.CFrame
    sfAlignOrientation.MaxTorque = 500000
    sfAlignOrientation.Responsiveness = 200
    sfAlignOrientation.Parent = rootPart

    sfLinearVelocity = Instance.new('LinearVelocity')
    sfLinearVelocity.Name = 'StealFloor_LinearVelocity'
    sfLinearVelocity.Attachment0 = sfAttachment
    sfLinearVelocity.MaxForce = 500000
    sfLinearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
    sfLinearVelocity.MaxAxesForce = Vector3.new(0, math.huge, 0)
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
    sfSetPlotsTransparency(true)

    sfSafeDisconnect(sfHeartbeatConn)
    sfHeartbeatConn = RunService.Heartbeat:Connect(function()
        if not stealFloorActive or not sfLinearVelocity then return end
        local h = player.Character and player.Character:FindFirstChildOfClass('Humanoid')
        if not (h and h.Health > 0) then
            toggleStealFloor()
            return
        end
        sfLinearVelocity.VectorVelocity = Vector3.new(0, sfFloatSpeed, 0)
    end)

    sfSafeDisconnect(sfPromptConn)
    sfPromptConn = ProximityPromptService.PromptTriggered:Connect(function(prompt, who)
        if who == player then
            local act = (prompt.ActionText or ''):lower()
            if string.find(act, 'steal') then
                sfTeleportToGround()
            end
        end
    end)

    sfSafeDisconnect(sfDiedConn)
    if hum then
        sfDiedConn = hum.Died:Connect(function()
            toggleStealFloor()
        end)
    end
end

local function sfDisable()
    if not stealFloorActive then
        sfSetPlotsTransparency(false)
        sfDestroyBodies()
        sfSafeDisconnect(sfHeartbeatConn)
        sfSafeDisconnect(sfPromptConn)
        sfSafeDisconnect(sfDiedConn)
        sfHeartbeatConn, sfPromptConn, sfDiedConn = nil, nil, nil
        return
    end
    stealFloorActive = false
    sfSetPlotsTransparency(false)
    sfDestroyBodies()
    sfSafeDisconnect(sfHeartbeatConn)
    sfSafeDisconnect(sfPromptConn)
    sfSafeDisconnect(sfDiedConn)
    sfHeartbeatConn, sfPromptConn, sfDiedConn = nil, nil, nil
end

local function toggleStealFloor()
    if not stealFloorActive then
        sfEnable()
    else
        sfDisable()
    end
    saveSettings()
end

sfSafeDisconnect(sfCharAddedConn)
sfCharAddedConn = player.CharacterAdded:Connect(function(ch)
    task.wait(0.1)
    sfDisable()
end)

-- Steal Floor Butonu (Sol Alt Köşe)
local stealFloorGui = Instance.new("ScreenGui")
stealFloorGui.Name = "StealFloorButton"
stealFloorGui.ResetOnSpawn = false
stealFloorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
stealFloorGui.Parent = CoreGui

local stealFloorButton = Instance.new("TextButton")
stealFloorButton.Name = "StealFloor"
stealFloorButton.Size = UDim2.new(0, 120, 0, 50)
stealFloorButton.Position = UDim2.new(0, 10, 1, -60) -- Sol Alt Köşe
stealFloorButton.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
stealFloorButton.BackgroundTransparency = 0.4
stealFloorButton.Text = "🏗️ Steal Floor"
stealFloorButton.TextColor3 = Color3.fromRGB(0, 0, 0)
stealFloorButton.TextSize = 14
stealFloorButton.Font = Enum.Font.GothamBold
stealFloorButton.TextWrapped = true
stealFloorButton.Draggable = true
stealFloorButton.Parent = stealFloorGui

local stealFloorCorner = Instance.new("UICorner")
stealFloorCorner.CornerRadius = UDim.new(0, 12)
stealFloorCorner.Parent = stealFloorButton

local stealFloorStroke = Instance.new("UIStroke")
stealFloorStroke.Color = Color3.fromRGB(255, 200, 200)
stealFloorStroke.Thickness = 2
stealFloorStroke.Transparency = 0.3
stealFloorStroke.Parent = stealFloorButton

stealFloorButton.MouseEnter:Connect(function()
    TweenService:Create(stealFloorButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.2,
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
end)

stealFloorButton.MouseLeave:Connect(function()
    TweenService:Create(stealFloorButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.4,
        TextColor3 = Color3.fromRGB(0, 0, 0)
    }):Play()
end)

stealFloorButton.MouseButton1Click:Connect(function()
    toggleStealFloor()
    if stealFloorActive then
        TweenService:Create(stealFloorButton, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(120, 255, 120)
        }):Play()
        stealFloorButton.Text = "✅ Steal Floor"
    else
        TweenService:Create(stealFloorButton, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(255, 120, 120)
        }):Play()
        stealFloorButton.Text = "🏗️ Steal Floor"
    end
end)

-- DEYSNC SYSTEM kısmı (orijinal Vortex kodu)
local antiHitActive = false
local clonerActive = false
local desyncRunning = false
local cloneListenerConn
local antiHitRunning = false
local lockdownRunning = false
local lockdownConn = nil
local invHealthConns = {}
local desyncHighlights = {}
local characterHighlights = {}

local function safeDisconnectConn(conn)
    if conn and typeof(conn) == "RBXScriptConnection" then
        pcall(function()
            conn:Disconnect()
        end)
    end
end

local function addCharacterHighlight(character)
    if not character or characterHighlights[character] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "DesyncCharacterHighlight"
    highlight.FillColor = Color3.fromRGB(0, 255, 100)
    highlight.OutlineColor = Color3.fromRGB(0, 200, 80)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    
    characterHighlights[character] = highlight
end

local function removeCharacterHighlight(character)
    local highlight = characterHighlights[character]
    if highlight then
        pcall(function() 
            highlight:Destroy() 
        end)
        characterHighlights[character] = nil
    end
end

local function removeAllHighlights()
    for character, highlight in pairs(characterHighlights) do
        pcall(function()
            highlight:Destroy()
        end)
    end
    characterHighlights = {}
end

local function addDesyncHighlight(model)
    if not model or desyncHighlights[model] then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "DesyncHighlight"
    highlight.FillColor = Color3.fromRGB(0, 255, 100)
    highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = model
    desyncHighlights[model] = highlight
end

local function removeDesyncHighlight(model)
    local hl = desyncHighlights[model]
    if hl then
        pcall(function() hl:Destroy() end)
        desyncHighlights[model] = nil
    end
end

local function makeInvulnerable(model)
    if not model or not model.Parent then return end
    
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local maxHealth = 1e9
    pcall(function()
        hum.MaxHealth = maxHealth
        hum.Health = maxHealth
    end)

    if invHealthConns[model] then
        safeDisconnectConn(invHealthConns[model])
        invHealthConns[model] = nil
    end
    
    invHealthConns[model] = hum.HealthChanged:Connect(function()
        pcall(function()
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end)
    end)

    if not model:FindFirstChildOfClass("ForceField") then
        local ff = Instance.new("ForceField")
        ff.Visible = false
        ff.Parent = model
    end

    addDesyncHighlight(model)
    addCharacterHighlight(model)

    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    end)
end

local function removeInvulnerable(model)
    if not model then return end
    
    if invHealthConns[model] then
        safeDisconnectConn(invHealthConns[model])
        invHealthConns[model] = nil
    end
    
    for _, ff in ipairs(model:GetChildren()) do
        if ff:IsA("ForceField") then
            pcall(function() ff:Destroy() end)
        end
    end
    
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
            local safeMax = 100
            hum.MaxHealth = safeMax
            if hum.Health > safeMax then hum.Health = safeMax end
        end)
    end
    
    removeDesyncHighlight(model)
    removeCharacterHighlight(model)
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

local function performDesyncLockdown(duration, onComplete)
    if lockdownRunning then
        if onComplete then pcall(onComplete) end
        return
    end
    lockdownRunning = true

    local char = player.Character
    if not char then
        lockdownRunning = false
        if onComplete then pcall(onComplete) end
        return
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then
        lockdownRunning = false
        if onComplete then pcall(onComplete) end
        return
    end

    local savedWalk = hum.WalkSpeed
    local savedJump = hum.JumpPower
    local savedUseJumpPower = hum.UseJumpPower

    hum.WalkSpeed = 0
    hum.JumpPower = 0
    hum.UseJumpPower = true
    hum.PlatformStand = true

    local fixedCFrame = hrp.CFrame

    if lockdownConn then
        lockdownConn:Disconnect()
        lockdownConn = nil
    end

    local lastCFrameTime = 0
    local CFRAME_UPDATE_INTERVAL = 0.15
    lockdownConn = RunService.Heartbeat:Connect(function()
        if not hrp or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        local now = tick()
        pcall(function()
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
            if (now - lastCFrameTime) >= CFRAME_UPDATE_INTERVAL then
                hrp.CFrame = fixedCFrame
                lastCFrameTime = now
            end
        end)
    end)

    task.delay(duration, function()
        if lockdownConn then
            lockdownConn:Disconnect()
            lockdownConn = nil
        end

        if hum and hum.Parent then
            pcall(function()
                hum.WalkSpeed = savedWalk or 16
                hum.JumpPower = savedJump or 50
                hum.UseJumpPower = savedUseJumpPower or true
                hum.PlatformStand = false
            end)
        end

        lockdownRunning = false
        if onComplete then pcall(onComplete) end
    end)
end

local function activateClonerDesync(callback)
    if clonerActive then
        if callback then callback() end
        return
    end
    clonerActive = true

    local Backpack = player:FindFirstChildOfClass("Backpack")
    local function equipQuantumCloner()
        if not Backpack then return end
        local tool = Backpack:FindFirstChild("Quantum Cloner")
        if tool then
            local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then 
                humanoid:EquipTool(tool)
                task.wait(0.5)
            end
        end
    end
    equipQuantumCloner()

    local REUseItem = ReplicatedStorage.Packages.Net:FindFirstChild("RE/UseItem")
    if REUseItem then 
        REUseItem:FireServer()
    end
    
    local REQuantumClonerOnTeleport = ReplicatedStorage.Packages.Net:FindFirstChild("RE/QuantumCloner/OnTeleport")
    if REQuantumClonerOnTeleport then 
        REQuantumClonerOnTeleport:FireServer()
    end

    local cloneName = tostring(player.UserId) .. "_Clone"
    cloneListenerConn = Workspace.ChildAdded:Connect(function(obj)
        if obj.Name == cloneName and obj:IsA("Model") then
            pcall(function() makeInvulnerable(obj) end)
            local origChar = player.Character
            if origChar then pcall(function() makeInvulnerable(origChar) end) end
            
            if cloneListenerConn then
                cloneListenerConn:Disconnect()
                cloneListenerConn = nil
            end

            performDesyncLockdown(1.6, function()
                if callback then pcall(callback) end
            end)
        end
    end)

    task.delay(5, function()
        if cloneListenerConn then
            cloneListenerConn:Disconnect()
            cloneListenerConn = nil
        end
        clonerActive = false
    end)
end

local function deactivateClonerDesync()
    if not clonerActive then
        local existingClone = Workspace:FindFirstChild(tostring(player.UserId) .. "_Clone")
        if existingClone then
            pcall(function()
                removeInvulnerable(existingClone)
                existingClone:Destroy()
            end)
        end
        clonerActive = false
        return
    end

    clonerActive = false
    local char = player.Character
    if char then removeInvulnerable(char) end
    
    local clone = Workspace:FindFirstChild(tostring(player.UserId) .. "_Clone")
    if clone then
        removeInvulnerable(clone)
        pcall(function() clone:Destroy() end)
    end

    if cloneListenerConn then
        cloneListenerConn:Disconnect()
        cloneListenerConn = nil
    end
end

local function executeAdvancedDesync()
    if antiHitRunning then 
        return 
    end
    antiHitRunning = true

    activateDesync()
    task.wait(0.1)
    activateClonerDesync(function()
        deactivateDesync()
        antiHitRunning = false
        antiHitActive = true
        saveSettings()
    end)
end

local function deactivateAdvancedDesync()
    if antiHitRunning then
        if cloneListenerConn then
            cloneListenerConn:Disconnect()
            cloneListenerConn = nil
        end
        antiHitRunning = false
    end

    deactivateClonerDesync()
    deactivateDesync()
    antiHitActive = false

    if player.Character then removeInvulnerable(player.Character) end

    local possibleClone = Workspace:FindFirstChild(tostring(player.UserId) .. "_Clone")
    if possibleClone then
        pcall(function()
            removeInvulnerable(possibleClone)
            possibleClone:Destroy()
        end)
    end

    for model, _ in pairs(desyncHighlights) do
        removeDesyncHighlight(model)
    end
    
    removeAllHighlights()
    
    saveSettings()
end

-- Deysnc Button (Sağ Üst Köşe)
local desyncScreenGui = Instance.new("ScreenGui")
desyncScreenGui.Name = "QuantumDesyncButton"
desyncScreenGui.ResetOnSpawn = false
desyncScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
desyncScreenGui.Parent = CoreGui

local desyncButton = Instance.new("TextButton")
desyncButton.Name = "Deysnc"
desyncButton.Size = UDim2.new(0, 120, 0, 50)
desyncButton.Position = UDim2.new(1, -130, 0, 10) -- Sağ Üst Köşe
desyncButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
desyncButton.BackgroundTransparency = 0.4
desyncButton.Text = "Deysnc"
desyncButton.TextColor3 = Color3.fromRGB(0, 0, 0)
desyncButton.TextSize = 14
desyncButton.Font = Enum.Font.GothamBold
desyncButton.TextWrapped = true
desyncButton.Draggable = true
desyncButton.Parent = desyncScreenGui

local desyncCorner = Instance.new("UICorner")
desyncCorner.CornerRadius = UDim.new(0, 12)
desyncCorner.Parent = desyncButton

local desyncStroke = Instance.new("UIStroke")
desyncStroke.Color = Color3.fromRGB(200, 230, 255)
desyncStroke.Thickness = 2
desyncStroke.Transparency = 0.3
desyncStroke.Parent = desyncButton

desyncButton.MouseEnter:Connect(function()
    TweenService:Create(desyncButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.2,
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
end)

desyncButton.MouseLeave:Connect(function()
    TweenService:Create(desyncButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.4,
        TextColor3 = Color3.fromRGB(0, 0, 0)
    }):Play()
end)

desyncButton.MouseButton1Click:Connect(function()
    if antiHitRunning then
        TweenService:Create(desyncButton, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        }):Play()
        desyncButton.Text = "Working..."
        return
    end
    
    if antiHitActive then
        deactivateAdvancedDesync()
        TweenService:Create(desyncButton, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(0, 100, 255)
        }):Play()
        desyncButton.Text = "Deysnc"
    else
        executeAdvancedDesync()
        TweenService:Create(desyncButton, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        }):Play()
        desyncButton.Text = "Active"
    end
end)

-- Deysnc reset
player.CharacterAdded:Connect(function()
    task.delay(0.3, function()
        antiHitActive = false
        antiHitRunning = false
        clonerActive = false
        desyncRunning = false
        lockdownRunning = false
        
        TweenService:Create(desyncButton, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(0, 100, 255)
        }):Play()
        desyncButton.Text = "Deysnc"
        
        local clone = Workspace:FindFirstChild(tostring(player.UserId) .. "_Clone")
        if clone then
            pcall(function()
                removeInvulnerable(clone)
                clone:Destroy()
            end)
        end
        
        removeAllHighlights()
    end)
end)

-- V LOGO AND MAIN GUI DESIGN - %50 KÜÇÜLTÜLMÜŞ
local playerGui = player:WaitForChild('PlayerGui')

-- Clean old GUIs
do
    local old = playerGui:FindFirstChild('VortexHelper')
    if old then
        pcall(function()
            old:Destroy()
        end)
    end
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

-- Main Frame - %50 KÜÇÜLTÜLMÜŞ
local mainFrame = Instance.new('Frame')
mainFrame.Size = UDim2.new(0, 160, 0, 180) -- %50 küçültüldü
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

-- Tab Buttons - UI Corner EKLENDİ
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

-- Button Creation Function - Optimize Edilmiş
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
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.1
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0
        }):Play()
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
end

if settings.espBase ~= nil then
    espBaseActive = settings.espBase
    if espBaseActive then
        toggleBaseESP()
    end
end

if settings.espBest ~= nil then
    espBestActive = settings.espBest
    if espBestActive then
        toggleBestESP()
    end
end

if settings.desync ~= nil then
    antiHitActive = settings.desync
    if antiHitActive then
        desyncButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        desyncButton.Text = "Active"
    end
end

if settings.fpsDevourer ~= nil then
    fpsDevourerActive = settings.fpsDevourer
    if fpsDevourerActive then
        enableFPSDevourer()
    end
end

if settings.playerESP ~= nil then
    playerEspActive = settings.playerESP
    if playerEspActive then
        togglePlayerESP()
    end
end

if settings.stealFloor ~= nil then
    stealFloorActive = settings.stealFloor
    if stealFloorActive then
        stealFloorButton.BackgroundColor3 = Color3.fromRGB(120, 255, 120)
        stealFloorButton.Text = "✅ Steal Floor"
    end
end

-- Create buttons for Tab 1 (Main) - Optimize Edilmiş
local yPos = 5
createButton(contentTab1, fpsDevourerActive and '✅ FPS' or '🎯 FPS', yPos, toggleFPSDevourer, fpsDevourerActive)
yPos = yPos + 28
createButton(contentTab1, gravityLow and '✅ Jump' or '🦘 Jump', yPos, switchGravityJump, gravityLow)
yPos = yPos + 28
createButton(contentTab1, '🚀 Fly Base', yPos, startFlyToBase, false)

-- Create buttons for Tab 2 (Visual) - Optimize Edilmiş
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
print("🦘 Inf Jump Ready (50 Power)")
print("🚀 Fly to Base Ready")
print("🏠 ESP Base Ready")
print("🔥 ESP Best Ready")
print("👥 Player ESP Ready")
print("🏗️ Steal Floor Ready (Sol Alt Köşe)")
print("🌀 Deysnc System Ready (Sağ Üst Köşe)")
print("🔷 V Logo: Click to open/close main menu")
print("💾 Settings Saving: Vortex'sHelper Folder")
