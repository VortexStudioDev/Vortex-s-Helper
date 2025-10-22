local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")
local usedServerIds = {}
local statusLabel = nil
local currentTab = 1

local function createStatusDisplay()
    statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "VortexStatus"
    statusLabel.Size = UDim2.new(0, 240, 0, 20)
    statusLabel.Position = UDim2.new(0.5, -120, 0.02, 0)
    statusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    statusLabel.BackgroundTransparency = 0.3
    statusLabel.BorderSizePixel = 0
    statusLabel.Text = "Status: Ready | Tab 1"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextSize = 11
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextStrokeTransparency = 0.8
    statusLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    statusLabel.ZIndex = 100
    statusLabel.Parent = CoreGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = statusLabel
    
    return statusLabel
end

local function showNotification(message, isSuccess)
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "NotificationGUI"
    notificationGui.ResetOnSpawn = false
    notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notificationGui.Parent = CoreGui
    
    local notification = Instance.new("Frame")
    notification.Name = "VortexNotification"
    notification.Size = UDim2.new(0, 280, 0, 70)
    notification.Position = UDim2.new(0.5, -140, 0.3, 0)
    notification.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    notification.BackgroundTransparency = 0
    notification.BorderSizePixel = 0
    notification.ZIndex = 1000
    notification.ClipsDescendants = true
    notification.Parent = notificationGui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 10)
    notifCorner.Parent = notification
    
    local notifStroke = Instance.new("UIStroke")
    notifStroke.Color = isSuccess and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    notifStroke.Thickness = 3
    notifStroke.Parent = notification
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 50, 1, 0)
    icon.Position = UDim2.new(0, 0, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = isSuccess and "✅" or "❌"
    icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    icon.TextSize = 24
    icon.Font = Enum.Font.GothamBold
    icon.ZIndex = 1001
    icon.Parent = notification
    
    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(1, -60, 1, -10)
    notifText.Position = UDim2.new(0, 55, 0, 5)
    notifText.BackgroundTransparency = 1
    notifText.Text = message
    notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifText.TextSize = 14
    notifText.Font = Enum.Font.GothamBold
    notifText.TextStrokeTransparency = 0.8
    notifText.TextXAlignment = Enum.TextXAlignment.Left
    notifText.TextYAlignment = Enum.TextYAlignment.Top
    notifText.TextWrapped = true
    notifText.ZIndex = 1001
    notifText.Parent = notification
    
    notification.MouseEnter:Connect(function()
        notification.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    end)
    
    notification.MouseLeave:Connect(function()
        notification.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    end)
    
    notification.Position = UDim2.new(0.5, -140, 0.2, 0)
    local tweenIn = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -140, 0.3, 0)
    })
    tweenIn:Play()

    tweenIn.Completed:Connect(function()
        wait(1.5)
        
        if notification and notification.Parent then
            local tweenOut = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -140, 0.2, 0),
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

local function updateStatusDisplay(message, isSuccess)
    if not statusLabel or not statusLabel.Parent then return end
    
    local color = isSuccess and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    local bgColor = isSuccess and Color3.fromRGB(0, 50, 0) or Color3.fromRGB(50, 0, 0)
    
    statusLabel.Text = "Status: " .. message .. " | Tab " .. currentTab
    statusLabel.TextColor3 = color
    statusLabel.BackgroundColor3 = bgColor
    
    spawn(function()
        wait(0.1)
        if statusLabel and statusLabel.Parent then
            statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            statusLabel.Text = "Status: Ready | Tab " .. currentTab
            statusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        end
    end)
end

local function smartServerHop()
    updateStatusDisplay("Finding server...", true)
    
    local gameId = game.PlaceId
    local currentJobId = game.JobId
    
    usedServerIds[currentJobId] = true
    
    local success, result = pcall(function()
        local response = game:HttpGet("https://games.roblox.com/v1/games/" .. gameId .. "/servers/Public?sortOrder=Desc&limit=100")
        return HttpService:JSONDecode(response)
    end)
    
    if not success then
        TeleportService:Teleport(gameId, player)
        return
    end
    
    if result and result.data then
        local availableServers = {}
        
        for _, server in pairs(result.data) do
            if server.id ~= currentJobId and not usedServerIds[server.id] then
                local playerCount = server.playing or 0
                local maxPlayers = server.maxPlayers or 50
                
                if playerCount >= 5 and playerCount <= (maxPlayers - 3) then
                    table.insert(availableServers, server.id)
                end
            end
        end
        
        if #availableServers == 0 then
            usedServerIds = {}
            for _, server in pairs(result.data) do
                if server.id ~= currentJobId then
                    local playerCount = server.playing or 0
                    local maxPlayers = server.maxPlayers or 50
                    if playerCount >= 3 and playerCount <= (maxPlayers - 2) then
                        table.insert(availableServers, server.id)
                    end
                end
            end
        end
        
        if #availableServers > 0 then
            local randomIndex = math.random(1, #availableServers)
            local targetServer = availableServers[randomIndex]
            
            usedServerIds[targetServer] = true
            TeleportService:TeleportToPlaceInstance(gameId, targetServer, player)
            return
        end
    end
    
    TeleportService:Teleport(gameId, player)
end

local function rejoinGame()
    updateStatusDisplay("Rejoining...", true)
    TeleportService:Teleport(game.PlaceId, player)
end

local function resetCharacter()
    updateStatusDisplay("Resetting character...", true)
    
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
        else
            character:BreakJoints()
        end
    else
        player.CharacterAdded:Wait()
        wait(0.1)
        local newCharacter = player.Character
        if newCharacter then
            local humanoid = newCharacter:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = 0
            else
                newCharacter:BreakJoints()
            end
        end
    end
end

local function joinByJobId(jobId)
    if jobId and jobId ~= "" then
        updateStatusDisplay("Joining server...", true)
        local success, error = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, player)
        end)
        
        if not success then
            showNotification("❌ Invalid Job ID or server full", false)
            updateStatusDisplay("Join failed", false)
        end
    else
        showNotification("❌ Please enter a Job ID", false)
    end
end

local function getSystemInfo()
    local info = {}
    
    local gameName = "Steal-a-Brainrot"
    table.insert(info, "🎮 " .. gameName)
    table.insert(info, "📍 ID: " .. tostring(game.PlaceId))
    
    table.insert(info, "🆔 Job: " .. string.sub(game.JobId, 1, 8) .. "...")
    
    local playerCount = #Players:GetPlayers()
    local maxPlayers = game.Players.MaxPlayers
    table.insert(info, "👥 " .. playerCount .. "/" .. maxPlayers)
    
    table.insert(info, "📡 ONLINE")
    
    table.insert(info, "⚡ v1.5")
    
    return info
end

local function copyToClipboard(text)
    local success = pcall(function()
        setclipboard(tostring(text))
    end)
    
    if success then
        showNotification("📋 Job ID successfully copied!", true)
    else
        showNotification("❌ Failed to copy Job ID", false)
    end
    
    return success
end

local logoButton = Instance.new("TextButton")
logoButton.Name = "VortexLogo"
logoButton.Size = UDim2.new(0, 30, 0, 30)
logoButton.Position = UDim2.new(0, 10, 0, 10)
logoButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
logoButton.Text = "V"
logoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
logoButton.TextSize = 14
logoButton.Font = Enum.Font.GothamBlack
logoButton.AutoButtonColor = false
logoButton.ZIndex = 100
logoButton.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = logoButton

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(200, 230, 255)
stroke.Thickness = 1.8
stroke.Parent = logoButton

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 140, 0, 110)
mainFrame.Position = UDim2.new(0.5, -70, 0.5, -55)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.ZIndex = 50

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(60, 140, 200)
frameStroke.Thickness = 2
frameStroke.Parent = mainFrame

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 20)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
header.BackgroundTransparency = 0.2
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header

local tab1Btn = Instance.new("TextButton")
tab1Btn.Name = "Tab1"
tab1Btn.Size = UDim2.new(0, 20, 0, 16)
tab1Btn.Position = UDim2.new(0, 5, 0, 2)
tab1Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
tab1Btn.Text = "1"
tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
tab1Btn.TextSize = 10
tab1Btn.Font = Enum.Font.GothamBold
tab1Btn.AutoButtonColor = false
tab1Btn.ZIndex = 51
tab1Btn.Parent = header

local tab1Corner = Instance.new("UICorner")
tab1Corner.CornerRadius = UDim.new(0, 4)
tab1Corner.Parent = tab1Btn

local tab2Btn = Instance.new("TextButton")
tab2Btn.Name = "Tab2"
tab2Btn.Size = UDim2.new(0, 20, 0, 16)
tab2Btn.Position = UDim2.new(0, 28, 0, 2)
tab2Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
tab2Btn.Text = "2"
tab2Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
tab2Btn.TextSize = 10
tab2Btn.Font = Enum.Font.GothamBold
tab2Btn.AutoButtonColor = false
tab2Btn.ZIndex = 51
tab2Btn.Parent = header

local tab2Corner = Instance.new("UICorner")
tab2Corner.CornerRadius = UDim.new(0, 4)
tab2Corner.Parent = tab2Btn

local tab3Btn = Instance.new("TextButton")
tab3Btn.Name = "Tab3"
tab3Btn.Size = UDim2.new(0, 20, 0, 16)
tab3Btn.Position = UDim2.new(0, 51, 0, 2)
tab3Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
tab3Btn.Text = "3"
tab3Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
tab3Btn.TextSize = 10
tab3Btn.Font = Enum.Font.GothamBold
tab3Btn.AutoButtonColor = false
tab3Btn.ZIndex = 51
tab3Btn.Parent = header

local tab3Corner = Instance.new("UICorner")
tab3Corner.CornerRadius = UDim.new(0, 4)
tab3Corner.Parent = tab3Btn

local powerBy = Instance.new("TextLabel")
powerBy.Size = UDim2.new(0, 60, 1, 0)
powerBy.Position = UDim2.new(0, 74, 0, 0)
powerBy.BackgroundTransparency = 1
powerBy.Text = "Vortex'Helper"
powerBy.TextColor3 = Color3.fromRGB(255, 255, 255)
powerBy.TextSize = 7
powerBy.Font = Enum.Font.GothamBold
powerBy.TextXAlignment = Enum.TextXAlignment.Left
powerBy.TextYAlignment = Enum.TextYAlignment.Center
powerBy.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 16, 0, 16)
closeBtn.Position = UDim2.new(1, -20, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 12
closeBtn.Font = Enum.Font.GothamBold
closeBtn.AutoButtonColor = false
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeBtn

local contentTab1 = Instance.new("Frame")
contentTab1.Name = "Tab1Content"
contentTab1.Size = UDim2.new(1, -8, 1, -25)
contentTab1.Position = UDim2.new(0, 4, 0, 21)
contentTab1.BackgroundTransparency = 1
contentTab1.Visible = true
contentTab1.Parent = mainFrame

local contentTab2 = Instance.new("Frame")
contentTab2.Name = "Tab2Content"
contentTab2.Size = UDim2.new(1, -8, 1, -25)
contentTab2.Position = UDim2.new(0, 4, 0, 21)
contentTab2.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
contentTab2.BackgroundTransparency = 0.2
contentTab2.Visible = false
contentTab2.Parent = mainFrame

local tab2Corner = Instance.new("UICorner")
tab2Corner.CornerRadius = UDim.new(0, 6)
tab2Corner.Parent = contentTab2

local tab2Stroke = Instance.new("UIStroke")
tab2Stroke.Color = Color3.fromRGB(0, 255, 0)
tab2Stroke.Thickness = 1.5
tab2Stroke.Parent = contentTab2

local contentTab3 = Instance.new("Frame")
contentTab3.Name = "Tab3Content"
contentTab3.Size = UDim2.new(1, -8, 1, -25)
contentTab3.Position = UDim2.new(0, 4, 0, 21)
contentTab3.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
contentTab3.BackgroundTransparency = 0.2
contentTab3.Visible = false
contentTab3.Parent = mainFrame

local tab3Corner = Instance.new("UICorner")
tab3Corner.CornerRadius = UDim.new(0, 6)
tab3Corner.Parent = contentTab3

local tab3Stroke = Instance.new("UIStroke")
tab3Stroke.Color = Color3.fromRGB(255, 200, 0)
tab3Stroke.Thickness = 1.5
tab3Stroke.Parent = contentTab3

local joinerTitle = Instance.new("TextLabel")
joinerTitle.Size = UDim2.new(1, 0, 0, 16)
joinerTitle.Position = UDim2.new(0, 0, 0, 4)
joinerTitle.BackgroundTransparency = 1
joinerTitle.Text = "🔗 Job ID Joiner"
joinerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
joinerTitle.TextSize = 10
joinerTitle.Font = Enum.Font.GothamBold
joinerTitle.TextYAlignment = Enum.TextYAlignment.Center
joinerTitle.Parent = contentTab3

local jobIdInput = Instance.new("TextBox")
jobIdInput.Name = "JobIdInput"
jobIdInput.Size = UDim2.new(1, -6, 0, 22)
jobIdInput.Position = UDim2.new(0, 3, 0, 22)
jobIdInput.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
jobIdInput.BackgroundTransparency = 0.1
jobIdInput.Text = ""
jobIdInput.PlaceholderText = "Paste Job ID..."
jobIdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
jobIdInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
jobIdInput.TextSize = 9
jobIdInput.Font = Enum.Font.Gotham
jobIdInput.ClearTextOnFocus = false
jobIdInput.TextWrapped = true
jobIdInput.TextYAlignment = Enum.TextYAlignment.Center
jobIdInput.Parent = contentTab3

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 4)
inputCorner.Parent = jobIdInput

local inputStroke = Instance.new("UIStroke")
inputStroke.Color = Color3.fromRGB(100, 100, 100)
inputStroke.Thickness = 1
inputStroke.Parent = jobIdInput

local joinButton = Instance.new("TextButton")
joinButton.Name = "JoinButton"
joinButton.Size = UDim2.new(1, -6, 0, 22)
joinButton.Position = UDim2.new(0, 3, 0, 48)
joinButton.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
joinButton.Text = "🚀 JOIN"
joinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
joinButton.TextSize = 10
joinButton.Font = Enum.Font.GothamBold
joinButton.AutoButtonColor = false
joinButton.TextYAlignment = Enum.TextYAlignment.Center
joinButton.Parent = contentTab3

local joinCorner = Instance.new("UICorner")
joinCorner.CornerRadius = UDim.new(0, 4)
joinCorner.Parent = joinButton

local joinStroke = Instance.new("UIStroke")
joinStroke.Color = Color3.fromRGB(200, 200, 200)
joinStroke.Thickness = 1
joinStroke.Parent = joinButton

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -6, 0, 28)
infoText.Position = UDim2.new(0, 3, 0, 74)
infoText.BackgroundTransparency = 1
infoText.Text = "Enter Job ID to join server"
infoText.TextColor3 = Color3.fromRGB(220, 220, 220)
infoText.TextSize = 8
infoText.Font = Enum.Font.Gotham
infoText.TextWrapped = true
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.Parent = contentTab3

local systemInfoLabel = Instance.new("TextLabel")
systemInfoLabel.Name = "SystemInfo"
systemInfoLabel.Size = UDim2.new(1, -6, 1, -20)
systemInfoLabel.Position = UDim2.new(0, 3, 0, 3)
systemInfoLabel.BackgroundTransparency = 1
systemInfoLabel.Text = "Loading"
systemInfoLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
systemInfoLabel.TextSize = 7
systemInfoLabel.Font = Enum.Font.Code
systemInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
systemInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
systemInfoLabel.TextWrapped = true
systemInfoLabel.Parent = contentTab2

local copyJobIdBtn = Instance.new("TextButton")
copyJobIdBtn.Name = "CopyJobId"
copyJobIdBtn.Size = UDim2.new(1, -6, 0, 16)
copyJobIdBtn.Position = UDim2.new(0, 3, 1, -19)
copyJobIdBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
copyJobIdBtn.Text = "📋 Copy JobID"
copyJobIdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyJobIdBtn.TextSize = 7
copyJobIdBtn.Font = Enum.Font.GothamBold
copyJobIdBtn.AutoButtonColor = false
copyJobIdBtn.TextYAlignment = Enum.TextYAlignment.Center
copyJobIdBtn.Visible = false
copyJobIdBtn.Parent = contentTab2

local copyBtnCorner = Instance.new("UICorner")
copyBtnCorner.CornerRadius = UDim.new(0, 4)
copyBtnCorner.Parent = copyJobIdBtn

local copyBtnStroke = Instance.new("UIStroke")
copyBtnStroke.Color = Color3.fromRGB(200, 200, 200)
copyBtnStroke.Thickness = 1
copyBtnStroke.Parent = copyJobIdBtn

local buttons = {
    {text = "🚪 KICK", color = Color3.fromRGB(200, 60, 60), pos = 0, size = 22, func = function()
        updateStatusDisplay("Kicking...", true)
        player:Kick("Vortex Security")
    end},
    {text = "🔄 HOP", color = Color3.fromRGB(60, 140, 200), pos = 25, size = 22, func = smartServerHop},
    {text = "🔁 REJN", color = Color3.fromRGB(80, 160, 80), pos = 50, size = 22, width = 0.5, xpos = 0, func = rejoinGame},
    {text = "🔄 REST", color = Color3.fromRGB(160, 120, 60), pos = 50, size = 22, width = 0.5, xpos = 0.5, func = resetCharacter}
}

for _, btnConfig in ipairs(buttons) do
    local button = Instance.new("TextButton")
    
    if btnConfig.width then
        button.Size = UDim2.new(btnConfig.width, -2, 0, btnConfig.size)
        button.Position = UDim2.new(btnConfig.xpos, 1, 0, btnConfig.pos)
    else
        button.Size = UDim2.new(1, 0, 0, btnConfig.size)
        button.Position = UDim2.new(0, 0, 0, btnConfig.pos)
    end
    
    button.BackgroundColor3 = btnConfig.color
    button.Text = btnConfig.text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 8
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.TextYAlignment = Enum.TextYAlignment.Center
    button.Parent = contentTab1

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = button

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(255, 255, 255)
    btnStroke.Transparency = 0.8
    btnStroke.Thickness = 1
    btnStroke.Parent = button

    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(
            math.min(btnConfig.color.R * 255 + 20, 255),
            math.min(btnConfig.color.G * 255 + 20, 255), 
            math.min(btnConfig.color.B * 255 + 20, 255)
        )
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = btnConfig.color
    end)

    button.MouseButton1Click:Connect(function()
        btnConfig.func()
    end)
end

local function switchTab(tabNumber)
    currentTab = tabNumber
    
    if tabNumber == 1 then
        contentTab1.Visible = true
        contentTab2.Visible = false
        contentTab3.Visible = false
        copyJobIdBtn.Visible = false
        tab1Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tab2Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        tab2Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        tab3Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        tab3Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        updateStatusDisplay("Main Tab", true)
    elseif tabNumber == 2 then
        contentTab1.Visible = false
        contentTab2.Visible = true
        contentTab3.Visible = false
        copyJobIdBtn.Visible = true
        tab1Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        tab1Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        tab2Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        tab2Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tab3Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        tab3Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        updateStatusDisplay("System Info", true)
        
        systemInfoLabel.Text = "Loading"
        wait(5)
        
        local info = getSystemInfo()
        systemInfoLabel.Text = table.concat(info, "\n")
    else
        contentTab1.Visible = false
        contentTab2.Visible = false
        contentTab3.Visible = true
        copyJobIdBtn.Visible = false
        tab1Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        tab1Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        tab2Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        tab2Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        tab3Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        tab3Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        updateStatusDisplay("Job ID Joiner", true)
    end
end

tab1Btn.MouseButton1Click:Connect(function()
    switchTab(1)
end)

tab2Btn.MouseButton1Click:Connect(function()
    switchTab(2)
end)

tab3Btn.MouseButton1Click:Connect(function()
    switchTab(3)
end)

joinButton.MouseButton1Click:Connect(function()
    local jobId = jobIdInput.Text
    joinByJobId(jobId)
end)

joinButton.MouseEnter:Connect(function()
    joinButton.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
end)

joinButton.MouseLeave:Connect(function()
    joinButton.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
end)

jobIdInput.Focused:Connect(function()
    jobIdInput.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    jobIdInput.UIStroke.Color = Color3.fromRGB(0, 150, 255)
end)

jobIdInput.FocusLost:Connect(function()
    jobIdInput.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    jobIdInput.UIStroke.Color = Color3.fromRGB(100, 100, 100)
end)

copyJobIdBtn.MouseButton1Click:Connect(function()
    copyToClipboard(game.JobId)
end)

copyJobIdBtn.MouseEnter:Connect(function()
    copyJobIdBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
end)

copyJobIdBtn.MouseLeave:Connect(function()
    copyJobIdBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
end)

spawn(function()
    while true do
        if currentTab == 2 and systemInfoLabel.Parent then
            local info = getSystemInfo()
            if systemInfoLabel.Text == "Loading" then
                systemInfoLabel.Text = table.concat(info, "\n")
            end
        end
        wait(5)
    end
end)

closeBtn.MouseEnter:Connect(function()
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
end)

closeBtn.MouseLeave:Connect(function()
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
end)

logoButton.MouseEnter:Connect(function()
    logoButton.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
end)

logoButton.MouseLeave:Connect(function()
    logoButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
end)

local frameOpen = false

logoButton.MouseButton1Click:Connect(function()
    frameOpen = not frameOpen
    mainFrame.Visible = frameOpen
end)

closeBtn.MouseButton1Click:Connect(function()
    frameOpen = false
    mainFrame.Visible = false
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VortexUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

createStatusDisplay()

logoButton.Parent = screenGui
mainFrame.Parent = screenGui

print("✅ Vortex UI Loaded!")
print("⚙️ Version 1.5 Updated")
print("📜 © 2025-2030 VortexTeamDev™ License")

updateStatusDisplay("System Ready", true)

delay(1, function()
    showNotification("🚀 Vortex UI Ready!", true)
end)
