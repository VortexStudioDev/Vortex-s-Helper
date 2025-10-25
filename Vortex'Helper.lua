-- Vortex Steal Tools - Ultimate Edition
-- Tüm özellikler birleştirilmiş: ESP, Desync, Ice Block, Speed, 3rd Floor, Kill, Kick
-- Optimized for performance

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Clean previous GUI
do
    local old = playerGui:FindFirstChild("VortexStealTools")
    if old then
        old:Destroy()
    end
end

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VortexStealTools"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Floating toggle button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 20, 0.5, -25)
toggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
toggleButton.BackgroundTransparency = 0.1
toggleButton.Text = "V"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 20
toggleButton.TextColor3 = Color3.fromRGB(100, 180, 255)
toggleButton.Active = true
toggleButton.Draggable = true
toggleButton.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = toggleButton

local buttonGlow = Instance.new("UIStroke")
buttonGlow.Color = Color3.fromRGB(100, 150, 255)
buttonGlow.Thickness = 2
buttonGlow.Transparency = 0.2
buttonGlow.Parent = toggleButton

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(80, 120, 255)
frameStroke.Thickness = 2
frameStroke.Transparency = 0.1
frameStroke.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "VORTEX STEAL TOOLS"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
titleLabel.Parent = header

-- Tab System
local tabs = {"MAIN", "ESP", "COMBAT"}
local currentTab = "MAIN"

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 30)
tabContainer.Position = UDim2.new(0, 10, 0, 40)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 5)
tabLayout.Parent = tabContainer

-- Button container
local buttonContainer = Instance.new("ScrollingFrame")
buttonContainer.Size = UDim2.new(1, -10, 1, -80)
buttonContainer.Position = UDim2.new(0, 5, 0, 75)
buttonContainer.BackgroundTransparency = 1
buttonContainer.BorderSizePixel = 0
buttonContainer.ScrollBarThickness = 4
buttonContainer.Parent = mainFrame

local buttonLayout = Instance.new("UIListLayout")
buttonLayout.Padding = UDim.new(0, 8)
buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
buttonLayout.Parent = buttonContainer

buttonLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    buttonContainer.CanvasSize = UDim2.new(0, 0, 0, buttonLayout.AbsoluteContentSize.Y)
end)

-- Create tab buttons
local tabButtons = {}
for _, tabName in ipairs(tabs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.3, 0, 1, 0)
    tabBtn.Text = tabName
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.TextSize = 12
    tabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabBtn.Parent = tabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabBtn
    
    tabBtn.MouseButton1Click:Connect(function()
        currentTab = tabName
        updateTabDisplay()
    end)
    
    tabButtons[tabName] = tabBtn
end

-- Button creation function
local function createButton(name, sizeY)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, sizeY or 32)
    button.Text = name
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    button.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(80, 100, 200)
    buttonStroke.Thickness = 1
    buttonStroke.Transparency = 0.3
    buttonStroke.Parent = button
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 90)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}):Play()
    end)
    
    return button
end

-- ESP System
local espConfig = {
    enabledPlayer = false,
    enabledBest = false,
    enabledSecret = false,
    enabledBase = false
}

local espBoxes = {}

-- Clear ESP functions
local function clearAllBestSecret()
    local plotsFolder = Workspace:FindFirstChild("Plots")
    if not plotsFolder then return end
    
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        for _, inst in ipairs(plot:GetDescendants()) do
            if inst:IsA("BillboardGui") and (inst.Name == "Best_ESP" or inst.Name == "Secret_ESP") then
                pcall(function() inst:Destroy() end)
            end
        end
    end
end

local function clearPlayerESP()
    for plr, objs in pairs(espBoxes) do
        if objs.box then pcall(function() objs.box:Destroy() end) end
        if objs.text then pcall(function() objs.text:Destroy() end) end
    end
    espBoxes = {}
end

-- Player ESP
local function updatePlayerESP()
    if not espConfig.enabledPlayer then return end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            if not espBoxes[plr] then
                espBoxes[plr] = {}
                
                -- Box
                local box = Instance.new("BoxHandleAdornment")
                box.Size = Vector3.new(4, 6, 4)
                box.Adornee = hrp
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Transparency = 0.5
                box.Color3 = Color3.fromRGB(255, 50, 50)
                box.Parent = hrp
                espBoxes[plr].box = box
                
                -- Name tag
                local billboard = Instance.new("BillboardGui")
                billboard.Adornee = hrp
                billboard.Size = UDim2.new(0, 200, 0, 30)
                billboard.StudsOffset = Vector3.new(0, 4, 0)
                billboard.AlwaysOnTop = true
                
                local label = Instance.new("TextLabel", billboard)
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.fromRGB(255, 50, 50)
                label.TextStrokeTransparency = 0
                label.Text = plr.Name
                label.Font = Enum.Font.GothamBold
                label.TextSize = 14
                
                espBoxes[plr].text = billboard
                billboard.Parent = hrp
            else
                if espBoxes[plr].box then espBoxes[plr].box.Adornee = hrp end
                if espBoxes[plr].text then espBoxes[plr].text.Adornee = hrp end
            end
        else
            if espBoxes[plr] then
                if espBoxes[plr].box then pcall(function() espBoxes[plr].box:Destroy() end) end
                if espBoxes[plr].text then pcall(function() espBoxes[plr].text:Destroy() end) end
                espBoxes[plr] = nil
            end
        end
    end
end

-- Best/Secret ESP
local function parseMoneyPerSec(text)
    if not text then return 0 end
    local mult = 1
    local numberStr = text:match("[%d%.]+")
    if not numberStr then return 0 end
    
    if text:find("K") then mult = 1_000
    elseif text:find("M") then mult = 1_000_000
    elseif text:find("B") then mult = 1_000_000_000
    elseif text:find("T") then mult = 1_000_000_000_000 end
    
    local number = tonumber(numberStr)
    return number and number * mult or 0
end

local function updateBestSecret()
    local plotsFolder = Workspace:FindFirstChild("Plots")
    if not plotsFolder then
        clearAllBestSecret()
        return
    end
    
    if not (espConfig.enabledBest or espConfig.enabledSecret) then
        clearAllBestSecret()
        return
    end

    local myPlotName
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local plotSign = plot:FindFirstChild("PlotSign")
        if plotSign and plotSign:FindFirstChild("YourBase") and plotSign.YourBase.Enabled then
            myPlotName = plot.Name
            break
        end
    end

    local bestPetInfo
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        if plot.Name ~= myPlotName then
            for _, desc in ipairs(plot:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Name == "Rarity" and desc.Parent and desc.Parent:FindFirstChild("DisplayName") then
                    local parentModel = desc.Parent.Parent
                    local rarity = desc.Text
                    local displayName = desc.Parent.DisplayName.Text

                    -- Secret ESP
                    if rarity == "Secret" and espConfig.enabledSecret then
                        if not parentModel:FindFirstChild("Secret_ESP") then
                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = "Secret_ESP"
                            billboard.Size = UDim2.new(0, 200, 0, 50)
                            billboard.StudsOffset = Vector3.new(0, 3, 0)
                            billboard.AlwaysOnTop = true
                            billboard.Parent = parentModel
                            
                            local label = Instance.new("TextLabel")
                            label.Text = "💎 " .. displayName
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.TextScaled = true
                            label.Font = Enum.Font.GothamBold
                            label.TextColor3 = Color3.fromRGB(255, 50, 150)
                            label.TextStrokeColor3 = Color3.new(0, 0, 0)
                            label.TextStrokeTransparency = 0.2
                            label.Parent = billboard
                        end
                    else
                        if parentModel:FindFirstChild("Secret_ESP") then
                            parentModel.Secret_ESP:Destroy()
                        end
                    end

                    -- Best ESP
                    if espConfig.enabledBest then
                        local genLabel = desc.Parent:FindFirstChild("Generation")
                        if genLabel and genLabel:IsA("TextLabel") then
                            local mps = parseMoneyPerSec(genLabel.Text)
                            if not bestPetInfo or mps > bestPetInfo.mps then
                                bestPetInfo = {
                                    petName = displayName,
                                    genText = genLabel.Text,
                                    mps = mps,
                                    model = parentModel
                                }
                            end
                        end
                    end
                end
            end
        end
    end

    -- Create Best ESP
    if espConfig.enabledBest then
        for _, plot in ipairs(plotsFolder:GetChildren()) do
            for _, inst in ipairs(plot:GetDescendants()) do
                if inst:IsA("BillboardGui") and inst.Name == "Best_ESP" then
                    pcall(function() inst:Destroy() end)
                end
            end
        end
        
        if bestPetInfo and bestPetInfo.mps > 0 and bestPetInfo.model then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "Best_ESP"
            billboard.Size = UDim2.new(0, 250, 0, 60)
            billboard.StudsOffset = Vector3.new(0, 4, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = bestPetInfo.model
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 0, 30)
            nameLabel.Position = UDim2.new(0, 0, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = "🔥 " .. bestPetInfo.petName
            nameLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 16
            nameLabel.TextStrokeTransparency = 0.1
            nameLabel.Parent = billboard
            
            local moneyLabel = Instance.new("TextLabel")
            moneyLabel.Size = UDim2.new(1, 0, 0, 25)
            moneyLabel.Position = UDim2.new(0, 0, 0, 30)
            moneyLabel.BackgroundTransparency = 1
            moneyLabel.Text = bestPetInfo.genText
            moneyLabel.TextColor3 = Color3.fromRGB(50, 255, 100)
            moneyLabel.Font = Enum.Font.GothamBold
            moneyLabel.TextSize = 14
            moneyLabel.TextStrokeTransparency = 0.2
            moneyLabel.Parent = billboard
        end
    end
end

-- ESP Update Loop
task.spawn(function()
    while true do
        task.wait(1)
        if espConfig.enabledPlayer then pcall(updatePlayerESP) end
        if espConfig.enabledBest or espConfig.enabledSecret then pcall(updateBestSecret) end
    end
end)

-- Base ESP
local function updateBaseESP()
    local plotsFolder = Workspace:FindFirstChild("Plots")
    if not plotsFolder then return end

    local myPlotName
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local plotSign = plot:FindFirstChild("PlotSign")
        if plotSign and plotSign:FindFirstChild("YourBase") and plotSign.YourBase.Enabled then
            myPlotName = plot.Name
            break
        end
    end

    if not espConfig.enabledBase or not myPlotName then return end

    for _, plot in ipairs(plotsFolder:GetChildren()) do
        if plot.Name ~= myPlotName then
            local purchases = plot:FindFirstChild("Purchases")
            local pb = purchases and purchases:FindFirstChild("PlotBlock")
            local main = pb and pb:FindFirstChild("Main")
            
            if main and not main:FindFirstChild("Base_ESP") then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "Base_ESP"
                billboard.Size = UDim2.new(0, 120, 0, 30)
                billboard.StudsOffset = Vector3.new(0, 5, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = main
                
                local label = Instance.new("TextLabel")
                label.Text = "🏠 BASE"
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextScaled = true
                label.TextColor3 = Color3.fromRGB(100, 200, 255)
                label.Font = Enum.Font.GothamBold
                label.TextStrokeTransparency = 0.3
                label.Parent = billboard
            elseif main and not espConfig.enabledBase then
                if main:FindFirstChild("Base_ESP") then
                    main.Base_ESP:Destroy()
                end
            end
        end
    end
end

-- Buttons storage
local buttons = {}

-- Create main buttons
buttons.iceButton = createButton("🧊 ICE BLOCK", 32)
buttons.speedButton = createButton("⚡ SPEED BOOSTER", 32)
buttons.floorButton = createButton("🏗️ 3RD FLOOR", 32)
buttons.desyncButton = createButton("🌀 DESYNC BODY", 32)
buttons.killButton = createButton("💀 KILL", 32)
buttons.kickButton = createButton("🚪 KICK", 32)

-- Create ESP buttons
buttons.espPlayer = createButton("👥 PLAYER ESP", 28)
buttons.espBest = createButton("🔥 BEST PET ESP", 28)
buttons.espSecret = createButton("💎 SECRET PET ESP", 28)
buttons.espBase = createButton("🏠 BASE ESP", 28)

-- Create combat buttons
buttons.aimbot = createButton("🎯 AIMBOT", 32)

-- Function to update tab display
function updateTabDisplay()
    -- Clear container
    for _, child in ipairs(buttonContainer:GetChildren()) do
        if child:IsA("TextButton") then
            child.Parent = nil
        end
    end
    
    -- Update tab buttons appearance
    for tabName, btn in pairs(tabButtons) do
        if tabName == currentTab then
            btn.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
    
    -- Add buttons for current tab
    if currentTab == "MAIN" then
        buttons.iceButton.Parent = buttonContainer
        buttons.speedButton.Parent = buttonContainer
        buttons.floorButton.Parent = buttonContainer
        buttons.desyncButton.Parent = buttonContainer
        buttons.killButton.Parent = buttonContainer
        buttons.kickButton.Parent = buttonContainer
    elseif currentTab == "ESP" then
        buttons.espPlayer.Parent = buttonContainer
        buttons.espBest.Parent = buttonContainer
        buttons.espSecret.Parent = buttonContainer
        buttons.espBase.Parent = buttonContainer
    elseif currentTab == "COMBAT" then
        buttons.aimbot.Parent = buttonContainer
    end
end

-- Initialize tabs
updateTabDisplay()

-- ICE BLOCK
buttons.iceButton.MouseButton1Click:Connect(function()
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if not buttons.iceButton:GetAttribute("Active") then
        buttons.iceButton:SetAttribute("Active", true)
        buttons.iceButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
        buttons.iceButton.Text = "🧊 ICE [ON]"
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local conn
            conn = RunService.RenderStepped:Connect(function()
                if buttons.iceButton:GetAttribute("Active") and hrp then
                    hrp.Velocity = workspace.CurrentCamera.CFrame.LookVector * 25
                else
                    conn:Disconnect()
                end
            end)
        end
    else
        buttons.iceButton:SetAttribute("Active", false)
        buttons.iceButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        buttons.iceButton.Text = "🧊 ICE BLOCK"
        if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end
end)

-- SPEED BOOSTER
buttons.speedButton.MouseButton1Click:Connect(function()
    if not buttons.speedButton:GetAttribute("Active") then
        buttons.speedButton:SetAttribute("Active", true)
        buttons.speedButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        buttons.speedButton.Text = "⚡ SPEED [ON]"
        
        local speedConn
        speedConn = RunService.Heartbeat:Connect(function()
            if not buttons.speedButton:GetAttribute("Active") then
                speedConn:Disconnect()
                return
            end
            
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hrp and hum then
                    local moveDir = hum.MoveDirection
                    if moveDir.Magnitude > 0 then
                        hrp.AssemblyLinearVelocity = Vector3.new(
                            moveDir.X * 27,
                            hrp.AssemblyLinearVelocity.Y,
                            moveDir.Z * 27
                        )
                    end
                end
            end
        end)
    else
        buttons.speedButton:SetAttribute("Active", false)
        buttons.speedButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        buttons.speedButton.Text = "⚡ SPEED BOOSTER"
    end
end)

-- 3RD FLOOR
buttons.floorButton.MouseButton1Click:Connect(function()
    local char = player.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if not buttons.floorButton:GetAttribute("Platform") then
        -- Create platform
        local platform = Instance.new("Part")
        platform.Size = Vector3.new(8, 1, 8)
        platform.Anchored = true
        platform.CanCollide = true
        platform.Transparency = 0.3
        platform.Material = Enum.Material.Neon
        platform.Color = Color3.fromRGB(255, 200, 0)
        platform.Position = root.Position - Vector3.new(0, 3, 0)
        platform.Parent = Workspace
        
        buttons.floorButton:SetAttribute("Platform", platform)
        buttons.floorButton.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
        buttons.floorButton.Text = "🏗️ 3RD FLOOR [ON]"
        
        -- Platform movement
        local conn
        conn = RunService.Heartbeat:Connect(function()
            local platform = buttons.floorButton:GetAttribute("Platform")
            if not platform or not buttons.floorButton:GetAttribute("Platform") then
                conn:Disconnect()
                return
            end
            
            if char and root then
                platform.Position = Vector3.new(root.Position.X, platform.Position.Y, root.Position.Z)
            end
        end)
    else
        local platform = buttons.floorButton:GetAttribute("Platform")
        if platform then platform:Destroy() end
        buttons.floorButton:SetAttribute("Platform", nil)
        buttons.floorButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        buttons.floorButton.Text = "🏗️ 3RD FLOOR"
    end
end)

-- DESYNC BODY
buttons.desyncButton.MouseButton1Click:Connect(function()
    if not buttons.desyncButton:GetAttribute("Active") then
        buttons.desyncButton:SetAttribute("Active", true)
        buttons.desyncButton.BackgroundColor3 = Color3.fromRGB(120, 255, 120)
        buttons.desyncButton.Text = "🌀 DESYNC [ON]"
        
        -- Desync logic
        local Backpack = player:FindFirstChildOfClass("Backpack")
        local function equipQuantumCloner()
            if not Backpack then return end
            local tool = Backpack:FindFirstChild("Quantum Cloner") or Backpack:FindFirstChild("Brainrot")
            if tool then
                local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid:EquipTool(tool) end
            end
        end
        
        equipQuantumCloner()
        task.wait(0.5)
        
        local REUseItem = ReplicatedStorage.Packages.Net:FindFirstChild("RE/UseItem")
        if REUseItem then REUseItem:FireServer() end
        
        local REQuantumClonerOnTeleport = ReplicatedStorage.Packages.Net:FindFirstChild("RE/QuantumCloner/OnTeleport")
        if REQuantumClonerOnTeleport then REQuantumClonerOnTeleport:FireServer() end
        
    else
        buttons.desyncButton:SetAttribute("Active", false)
        buttons.desyncButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        buttons.desyncButton.Text = "🌀 DESYNC BODY"
        
        -- Cleanup clone
        local clone = Workspace:FindFirstChild(tostring(player.UserId) .. "_Clone")
        if clone then clone:Destroy() end
    end
end)

-- KILL
buttons.killButton.MouseButton1Click:Connect(function()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end
end)

-- KICK
buttons.kickButton.MouseButton1Click:Connect(function()
    player:Kick("Vortex Steal Tools - Kicked by User")
end)

-- ESP PLAYER
buttons.espPlayer.MouseButton1Click:Connect(function()
    espConfig.enabledPlayer = not espConfig.enabledPlayer
    buttons.espPlayer.BackgroundColor3 = espConfig.enabledPlayer and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(40, 40, 60)
    buttons.espPlayer.Text = espConfig.enabledPlayer and "👥 PLAYER ESP [ON]" or "👥 PLAYER ESP"
    
    if not espConfig.enabledPlayer then
        clearPlayerESP()
    end
end)

-- ESP BEST
buttons.espBest.MouseButton1Click:Connect(function()
    espConfig.enabledBest = not espConfig.enabledBest
    buttons.espBest.BackgroundColor3 = espConfig.enabledBest and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(40, 40, 60)
    buttons.espBest.Text = espConfig.enabledBest and "🔥 BEST ESP [ON]" or "🔥 BEST PET ESP"
    
    if not espConfig.enabledBest then
        clearAllBestSecret()
    end
end)

-- ESP SECRET
buttons.espSecret.MouseButton1Click:Connect(function()
    espConfig.enabledSecret = not espConfig.enabledSecret
    buttons.espSecret.BackgroundColor3 = espConfig.enabledSecret and Color3.fromRGB(255, 50, 150) or Color3.fromRGB(40, 40, 60)
    buttons.espSecret.Text = espConfig.enabledSecret and "💎 SECRET ESP [ON]" or "💎 SECRET PET ESP"
    
    if not espConfig.enabledSecret then
        clearAllBestSecret()
    end
end)

-- ESP BASE
buttons.espBase.MouseButton1Click:Connect(function()
    espConfig.enabledBase = not espConfig.enabledBase
    buttons.espBase.BackgroundColor3 = espConfig.enabledBase and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(40, 40, 60)
    buttons.espBase.Text = espConfig.enabledBase and "🏠 BASE ESP [ON]" or "🏠 BASE ESP"
    
    if espConfig.enabledBase then
        updateBaseESP()
    end
end)

-- AIMBOT
buttons.aimbot.MouseButton1Click:Connect(function()
    local function getClosestPlayer()
        local myChar = player.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return nil end
        
        local closest, closestDist = nil, math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = plr.Character.HumanoidRootPart
                local dist = (hrp.Position - myHRP.Position).Magnitude
                if dist < closestDist then
                    closest, closestDist = plr, dist
                end
            end
        end
        return closest
    end

    local target = getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetHRP = target.Character.HumanoidRootPart
        
        -- Web slinger aimbot
        local Backpack = player:FindFirstChildOfClass("Backpack")
        if Backpack and Backpack:FindFirstChild("Web Slinger") then
            player.Character.Humanoid:EquipTool(Backpack["Web Slinger"])
        end
        
        local REUseItem = ReplicatedStorage.Packages.Net:FindFirstChild("RE/UseItem")
        if REUseItem then
            REUseItem:FireServer(targetHRP.Position, targetHRP)
        end
        
        buttons.aimbot.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        buttons.aimbot.Text = "🎯 LOCKED ON"
        task.wait(1)
        buttons.aimbot.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        buttons.aimbot.Text = "🎯 AIMBOT"
    end
end)

-- Toggle UI
toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    toggleButton.BackgroundColor3 = mainFrame.Visible and Color3.fromRGB(30, 30, 50) or Color3.fromRGB(25, 25, 35)
end)

-- Drag function
local function makeDraggable(obj)
    local dragging = false
    local dragStart, startPos
    
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
        end
    end)
    
    obj.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    obj.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

makeDraggable(mainFrame)
makeDraggable(toggleButton)

-- Initial notification
task.spawn(function()
    task.wait(1)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Vortex Steal Tools",
        Text = "Ultimate Edition Loaded!",
        Duration = 5
    })
end)

print("Vortex Steal Tools - Ultimate Edition loaded successfully!")
