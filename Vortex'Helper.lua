-- Vortex UI Enhanced v2.0
-- Optimized for performance, security and maintainability

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")

-- Configuration
local CONFIG = {
    VORTEX_FOLDER = "VortexHelper",
    USED_SERVERS_FILE = "used_servers.json",
    MAX_SERVER_HISTORY = 100,
    SCAN_LIMIT = 100,
    VERSION = "2.0",
    UI_SIZE = UDim2.new(0, 160, 0, 150), -- Slightly larger for better usability
    STATUS_DISPLAY_DURATION = 3
}

-- Cache frequently used objects
local player = Players.LocalPlayer
local usedServerIds = {}
local statusLabel = nil
local currentTab = 1
local uiElements = {}

-- Utility functions
local function safeCall(func, errorMessage, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("❌ " .. errorMessage .. ": " .. tostring(result))
        return nil
    end
    return result
end

local function countTable(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

-- File system operations
local function ensureFolderExists()
    return safeCall(function()
        if not isfolder(CONFIG.VORTEX_FOLDER) then
            makefolder(CONFIG.VORTEX_FOLDER)
        end
        return true
    end, "Folder creation failed")
end

local function loadUsedServers()
    ensureFolderExists()
    
    return safeCall(function()
        local filePath = CONFIG.VORTEX_FOLDER .. "/" .. CONFIG.USED_SERVERS_FILE
        
        if not isfile(filePath) then
            writefile(filePath, "{}")
            return {}
        end
        
        local fileContent = readfile(filePath)
        local decoded = HttpService:JSONDecode(fileContent)
        
        -- Clean old entries (older than 24 hours)
        local cleaned = {}
        local currentTime = os.time()
        local dayInSeconds = 24 * 60 * 60
        
        for serverId, timestamp in pairs(decoded) do
            if currentTime - timestamp < dayInSeconds then
                cleaned[serverId] = timestamp
            end
        end
        
        return cleaned
    end, "Failed to load server history")
end

local function saveUsedServers()
    ensureFolderExists()
    
    -- Limit history size
    if countTable(usedServerIds) > CONFIG.MAX_SERVER_HISTORY then
        local sorted = {}
        for serverId, timestamp in pairs(usedServerIds) do
            table.insert(sorted, {id = serverId, time = timestamp})
        end
        
        table.sort(sorted, function(a, b) return a.time > b.time end)
        
        local newHistory = {}
        for i = 1, math.min(CONFIG.MAX_SERVER_HISTORY, #sorted) do
            newHistory[sorted[i].id] = sorted[i].time
        end
        
        usedServerIds = newHistory
    end
    
    safeCall(function()
        writefile(CONFIG.VORTEX_FOLDER .. "/" .. CONFIG.USED_SERVERS_FILE, 
                 HttpService:JSONEncode(usedServerIds))
    end, "Failed to save server history")
end

-- Initialize data
usedServerIds = loadUsedServers() or {}

-- UI Creation Utilities
local function createElement(className, properties)
    local element = Instance.new(className)
    
    for property, value in pairs(properties) do
        if property ~= "Parent" then
            element[property] = value
        end
    end
    
    if properties.Parent then
        element.Parent = properties.Parent
    end
    
    return element
end

local function createCorner(parent, radius)
    local corner = createElement("UICorner", {
        CornerRadius = UDim.new(0, radius or 4),
        Parent = parent
    })
    return corner
end

local function createStroke(parent, color, thickness)
    local stroke = createElement("UIStroke", {
        Color = color or Color3.fromRGB(255, 255, 255),
        Thickness = thickness or 1,
        Parent = parent
    })
    return stroke
end

-- Status Display
local function createStatusDisplay()
    statusLabel = createElement("TextLabel", {
        Name = "VortexStatus",
        Size = UDim2.new(0, 260, 0, 22),
        Position = UDim2.new(0.5, -130, 0.02, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Text = "Status: Ready | Tab 1",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextStrokeTransparency = 0.8,
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 100,
        Parent = CoreGui
    })
    
    createCorner(statusLabel, 6)
    return statusLabel
end

-- Notification System
local function showNotification(message, isSuccess)
    local notificationGui = createElement("ScreenGui", {
        Name = "NotificationGUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    
    local notification = createElement("Frame", {
        Name = "VortexNotification",
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(0.5, -150, 0.2, 0),
        BackgroundColor3 = Color3.fromRGB(15, 15, 20),
        BorderSizePixel = 0,
        ZIndex = 1000,
        ClipsDescendants = true,
        Parent = notificationGui
    })
    
    createCorner(notification, 10)
    createStroke(notification, isSuccess and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50), 3)
    
    local icon = createElement("TextLabel", {
        Size = UDim2.new(0, 50, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = isSuccess and "✅" or "❌",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 26,
        Font = Enum.Font.GothamBold,
        ZIndex = 1001,
        Parent = notification
    })
    
    local notifText = createElement("TextLabel", {
        Size = UDim2.new(1, -60, 1, -10),
        Position = UDim2.new(0, 55, 0, 5),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextStrokeTransparency = 0.8,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        ZIndex = 1001,
        Parent = notification
    })
    
    -- Animation
    local tweenIn = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -150, 0.3, 0)
    })
    tweenIn:Play()

    tweenIn.Completed:Connect(function()
        wait(CONFIG.STATUS_DISPLAY_DURATION)
        
        if notification and notification.Parent then
            local tweenOut = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -150, 0.2, 0),
                BackgroundTransparency = 1
            })
            
            for _, child in pairs(notification:GetChildren()) do
                if child:IsA("TextLabel") then
                    child.TextTransparency = 1
                end
            end
            
            tweenOut:Play()
            tweenOut.Completed:Connect(function()
                notificationGui:Destroy()
            end)
        end
    end)
end

local function updateStatusDisplay(message, isSuccess)
    if not statusLabel or not statusLabel.Parent then return end
    
    local color = isSuccess and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    
    statusLabel.Text = "Status: " .. message .. " | Tab " .. currentTab
    statusLabel.TextColor3 = color
    
    delay(0.1, function()
        if statusLabel and statusLabel.Parent then
            statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            statusLabel.Text = "Status: Ready | Tab " .. currentTab
        end
    end)
end

-- Scanning Effect
local function showScanningEffect()
    local scanningGui = createElement("ScreenGui", {
        Name = "ScanningEffect",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    
    local scanningFrame = createElement("Frame", {
        Size = UDim2.new(0, 320, 0, 120),
        Position = UDim2.new(0.5, -160, 0.4, -60),
        BackgroundColor3 = Color3.fromRGB(10, 10, 20),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 999,
        Parent = scanningGui
    })
    
    createCorner(scanningFrame, 12)
    createStroke(scanningFrame, Color3.fromRGB(0, 150, 255), 2)
    
    local scanText = createElement("TextLabel", {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 15),
        BackgroundTransparency = 1,
        Text = "🔍 SCANNING SERVERS",
        TextColor3 = Color3.fromRGB(0, 200, 255),
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        ZIndex = 1000,
        Parent = scanningFrame
    })
    
    local dots = createElement("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        ZIndex = 1000,
        Parent = scanningFrame
    })
    
    local progressBar = createElement("Frame", {
        Size = UDim2.new(0, 0, 0, 8),
        Position = UDim2.new(0, 10, 0, 80),
        BackgroundColor3 = Color3.fromRGB(0, 150, 255),
        BorderSizePixel = 0,
        ZIndex = 1000,
        Parent = scanningFrame
    })
    
    createCorner(progressBar, 3)
    
    -- Animations
    spawn(function()
        local dotCount = 0
        while scanningFrame and scanningFrame.Parent do
            dotCount = (dotCount % 4) + 1
            dots.Text = string.rep(".", dotCount)
            wait(0.3)
        end
    end)
    
    spawn(function()
        local progressTween = TweenService:Create(progressBar, TweenInfo.new(2, Enum.EasingStyle.Linear), {
            Size = UDim2.new(1, -20, 0, 8)
        })
        progressTween:Play()
        
        progressTween.Completed:Wait()
        
        if scanningGui and scanningGui.Parent then
            local fadeTween = TweenService:Create(scanningFrame, TweenInfo.new(0.5), {
                BackgroundTransparency = 1
            })
            
            for _, child in pairs(scanningFrame:GetChildren()) do
                if child:IsA("TextLabel") then
                    child.TextTransparency = 1
                elseif child:IsA("Frame") then
                    child.BackgroundTransparency = 1
                end
            end
            
            scanningFrame.UIStroke.Transparency = 1
            fadeTween:Play()
            fadeTween.Completed:Wait()
            scanningGui:Destroy()
        end
    end)
    
    return scanningGui
end

-- Core Functions
local function clearServerHistory()
    usedServerIds = {}
    saveUsedServers()
    showNotification("🗑️ Server history cleared!", true)
    updateStatusDisplay("History cleared", true)
end

local function smartServerHop()
    updateStatusDisplay("Finding new server...", true)
    local scanningEffect = showScanningEffect()
    
    local gameId = game.PlaceId
    local currentJobId = game.JobId
    
    -- Save current server
    usedServerIds[currentJobId] = os.time()
    saveUsedServers()
    
    local serverData = safeCall(function()
        local response = game:HttpGet("https://games.roblox.com/v1/games/" .. gameId .. "/servers/Public?sortOrder=Asc&limit=" .. CONFIG.SCAN_LIMIT)
        return HttpService:JSONDecode(response)
    end, "Failed to fetch server list")
    
    if not serverData then
        if scanningEffect then scanningEffect:Destroy() end
        showNotification("🌐 API Error - Using fallback", false)
        wait(1)
        TeleportService:Teleport(gameId)
        return
    end
    
    if serverData and serverData.data then
        local availableServers = {}
        
        for _, server in pairs(serverData.data) do
            if server.id ~= currentJobId and not usedServerIds[server.id] then
                local playerCount = server.playing or 0
                local maxPlayers = server.maxPlayers or 50
                
                if playerCount >= 1 and playerCount <= (maxPlayers - 2) then
                    table.insert(availableServers, {
                        id = server.id,
                        players = playerCount
                    })
                end
            end
        end
        
        if #availableServers > 0 then
            -- Prioritize servers with medium population
            table.sort(availableServers, function(a, b)
                return math.abs(a.players - 20) < math.abs(b.players - 20)
            end)
            
            local targetServer = availableServers[1]
            
            if scanningEffect then scanningEffect:Destroy() end
            showNotification("🚀 Joining server (" .. targetServer.players .. " players)", true)
            
            usedServerIds[targetServer.id] = os.time()
            saveUsedServers()
            
            wait(1)
            
            local teleportSuccess = safeCall(function()
                TeleportService:TeleportToPlaceInstance(gameId, targetServer.id)
            end, "Teleport failed")
            
            if not teleportSuccess then
                showNotification("❌ Teleport failed - Rejoining", false)
                wait(1)
                TeleportService:Teleport(gameId)
            end
        else
            if scanningEffect then scanningEffect:Destroy() end
            showNotification("🔄 No new servers - Clearing history", true)
            usedServerIds = {}
            saveUsedServers()
            wait(1)
            TeleportService:Teleport(gameId)
        end
    else
        if scanningEffect then scanningEffect:Destroy() end
        showNotification("🌐 Server list issue - Rejoining", true)
        wait(1)
        TeleportService:Teleport(gameId)
    end
end

local function rejoinGame()
    updateStatusDisplay("Rejoining...", true)
    TeleportService:Teleport(game.PlaceId)
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
    if jobId and jobId:match("^[%w-]+$") and #jobId > 5 then
        updateStatusDisplay("Joining server...", true)
        
        local success = safeCall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId)
        end, "Join by Job ID failed")
        
        if not success then
            showNotification("❌ Invalid Job ID or server full", false)
            updateStatusDisplay("Join failed", false)
        end
    else
        showNotification("❌ Please enter a valid Job ID", false)
    end
end

local function getSystemInfo()
    local info = {}
    
    local gameInfo = safeCall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end, "Failed to get game info")
    
    table.insert(info, "🎮 " .. (gameInfo and gameInfo.Name or "Unknown Game"))
    table.insert(info, "📍 ID: " .. game.PlaceId)
    table.insert(info, "🆔 Job: " .. string.sub(game.JobId, 1, 8) .. "...")
    
    local playerCount = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    table.insert(info, "👥 " .. playerCount .. "/" .. maxPlayers)
    table.insert(info, "📡 ONLINE")
    table.insert(info, "⚡ v" .. CONFIG.VERSION)
    table.insert(info, "💾 History: " .. countTable(usedServerIds))
    table.insert(info, "🔍 VortexScan System v2")
    
    return table.concat(info, "\n")
end

local function copyToClipboard(text)
    local success = safeCall(function()
        setclipboard(tostring(text))
    end, "Copy to clipboard failed")
    
    if success then
        showNotification("📋 Job ID copied!", true)
    else
        showNotification("❌ Failed to copy", false)
    end
    
    return success
end

-- UI Creation (Optimized)
local function createMainUI()
    local screenGui = createElement("ScreenGui", {
        Name = "VortexUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    
    uiElements.screenGui = screenGui

    -- Logo Button
    local logoButton = createElement("TextButton", {
        Name = "VortexLogo",
        Size = UDim2.new(0, 35, 0, 35),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Color3.fromRGB(0, 120, 255),
        Text = "V",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        Font = Enum.Font.GothamBlack,
        AutoButtonColor = false,
        ZIndex = 100,
        Draggable = true,
        Parent = screenGui
    })
    
    createCorner(logoButton, 1)
    createStroke(logoButton, Color3.fromRGB(200, 230, 255), 2)
    
    -- Main Frame
    local mainFrame = createElement("Frame", {
        Name = "MainFrame",
        Size = CONFIG.UI_SIZE,
        Position = UDim2.new(0.5, -CONFIG.UI_SIZE.X.Offset/2, 0.5, -CONFIG.UI_SIZE.Y.Offset/2),
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Active = true,
        Draggable = true,
        Visible = false,
        ZIndex = 50,
        Parent = screenGui
    })
    
    createCorner(mainFrame, 8)
    createStroke(mainFrame, Color3.fromRGB(60, 140, 200), 2)
    
    -- Header
    local header = createElement("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = Color3.fromRGB(35, 35, 40),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Parent = mainFrame
    })
    
    createCorner(header, 8)
    
    -- Tab buttons
    local tabs = {
        {id = 1, text = "1", color = Color3.fromRGB(0, 120, 255)},
        {id = 2, text = "2", color = Color3.fromRGB(60, 60, 70)},
        {id = 3, text = "3", color = Color3.fromRGB(60, 60, 70)}
    }
    
    for i, tab in ipairs(tabs) do
        local tabBtn = createElement("TextButton", {
            Name = "Tab" .. tab.id,
            Size = UDim2.new(0, 22, 0, 18),
            Position = UDim2.new(0, 5 + (i-1)*25, 0, 3),
            BackgroundColor3 = tab.color,
            Text = tab.text,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false,
            ZIndex = 51,
            Parent = header
        })
        
        createCorner(tabBtn, 4)
        uiElements["tab" .. tab.id] = tabBtn
    end
    
    -- Close button
    local closeBtn = createElement("TextButton", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, -22, 0, 3),
        BackgroundColor3 = Color3.fromRGB(200, 60, 60),
        Text = "×",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Parent = header
    })
    
    createCorner(closeBtn, 4)
    uiElements.closeBtn = closeBtn
    
    -- Content frames
    local contentFrames = {}
    for i = 1, 3 do
        local contentFrame = createElement("Frame", {
            Name = "Tab" .. i .. "Content",
            Size = UDim2.new(1, -8, 1, -30),
            Position = UDim2.new(0, 4, 0, 26),
            BackgroundTransparency = i == 1 and 1 or 0.2,
            BackgroundColor3 = Color3.fromRGB(15, 15, 20),
            Visible = i == 1,
            Parent = mainFrame
        })
        
        if i > 1 then
            createCorner(contentFrame, 6)
            createStroke(contentFrame, i == 2 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 200, 0), 1.5)
        end
        
        contentFrames[i] = contentFrame
        uiElements["contentTab" .. i] = contentFrame
    end
    
    -- Tab 1: Main buttons
    local mainButtons = {
        {text = "🚪 KICK", color = Color3.fromRGB(200, 60, 60), func = function()
            updateStatusDisplay("Kicking...", true)
            player:Kick("Vortex Security")
        end},
        {text = "🔄 HOP", color = Color3.fromRGB(60, 140, 200), func = smartServerHop},
        {text = "🔁 REJN", color = Color3.fromRGB(80, 160, 80), func = rejoinGame},
        {text = "🔄 REST", color = Color3.fromRGB(160, 120, 60), func = resetCharacter},
        {text = "🗑️ CLEAR", color = Color3.fromRGB(120, 80, 160), func = clearServerHistory}
    }
    
    for i, btnConfig in ipairs(mainButtons) do
        local button = createElement("TextButton", {
            Size = UDim2.new(1, 0, 0, 24),
            Position = UDim2.new(0, 0, 0, (i-1) * 26),
            BackgroundColor3 = btnConfig.color,
            Text = btnConfig.text,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 9,
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = contentFrames[1]
        })
        
        createCorner(button, 5)
        createStroke(button, Color3.fromRGB(255, 255, 255), 0.8)
        
        -- Hover effects
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = Color3.new(
                math.min(btnConfig.color.R + 0.1, 1),
                math.min(btnConfig.color.G + 0.1, 1),
                math.min(btnConfig.color.B + 0.1, 1)
            )
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = btnConfig.color
        end)
        
        button.MouseButton1Click:Connect(btnConfig.func)
    end
    
    -- Tab 2: System Info
    local systemInfoLabel = createElement("TextLabel", {
        Name = "SystemInfo",
        Size = UDim2.new(1, -6, 1, -25),
        Position = UDim2.new(0, 3, 0, 3),
        BackgroundTransparency = 1,
        Text = "Loading system info...",
        TextColor3 = Color3.fromRGB(0, 255, 0),
        TextSize = 8,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = contentFrames[2]
    })
    
    uiElements.systemInfoLabel = systemInfoLabel
    
    -- Copy Job ID button
    local copyJobIdBtn = createElement("TextButton", {
        Name = "CopyJobId",
        Size = UDim2.new(1, -6, 0, 18),
        Position = UDim2.new(0, 3, 1, -21),
        BackgroundColor3 = Color3.fromRGB(0, 100, 200),
        Text = "📋 Copy JobID",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 8,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        TextYAlignment = Enum.TextYAlignment.Center,
        Visible = false,
        Parent = contentFrames[2]
    })
    
    createCorner(copyJobIdBtn, 4)
    createStroke(copyJobIdBtn, Color3.fromRGB(200, 200, 200), 1)
    uiElements.copyJobIdBtn = copyJobIdBtn
    
    -- Tab 3: Job ID Joiner
    createElement("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 4),
        BackgroundTransparency = 1,
        Text = "🔗 Job ID Joiner",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = contentFrames[3]
    })
    
    local jobIdInput = createElement("TextBox", {
        Name = "JobIdInput",
        Size = UDim2.new(1, -6, 0, 24),
        Position = UDim2.new(0, 3, 0, 24),
        BackgroundColor3 = Color3.fromRGB(30, 30, 35),
        BackgroundTransparency = 0.1,
        Text = "",
        PlaceholderText = "Paste Job ID...",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 10,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = contentFrames[3]
    })
    
    createCorner(jobIdInput, 4)
    createStroke(jobIdInput, Color3.fromRGB(100, 100, 100), 1)
    uiElements.jobIdInput = jobIdInput
    
    local joinButton = createElement("TextButton", {
        Name = "JoinButton",
        Size = UDim2.new(1, -6, 0, 24),
        Position = UDim2.new(0, 3, 0, 52),
        BackgroundColor3 = Color3.fromRGB(0, 150, 80),
        Text = "🚀 JOIN",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = contentFrames[3]
    })
    
    createCorner(joinButton, 4)
    createStroke(joinButton, Color3.fromRGB(200, 200, 200), 1)
    uiElements.joinButton = joinButton
    
    createElement("TextLabel", {
        Size = UDim2.new(1, -6, 0, 30),
        Position = UDim2.new(0, 3, 0, 80),
        BackgroundTransparency = 1,
        Text = "Enter valid Job ID to join specific server",
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextSize = 9,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = contentFrames[3]
    })
    
    -- UI Interactions
    local frameOpen = false
    
    logoButton.MouseButton1Click:Connect(function()
        frameOpen = not frameOpen
        mainFrame.Visible = frameOpen
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        frameOpen = false
        mainFrame.Visible = false
    end)
    
    -- Tab switching
    local function switchTab(tabNumber)
        currentTab = tabNumber
        
        for i = 1, 3 do
            contentFrames[i].Visible = i == tabNumber
            uiElements["tab" .. i].BackgroundColor3 = i == tabNumber and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(60, 60, 70)
        end
        
        uiElements.copyJobIdBtn.Visible = tabNumber == 2
        
        if tabNumber == 2 then
            systemInfoLabel.Text = getSystemInfo()
        end
        
        updateStatusDisplay("Tab " .. tabNumber, true)
    end
    
    for i = 1, 3 do
        uiElements["tab" .. i].MouseButton1Click:Connect(function()
            switchTab(i)
        end)
    end
    
    -- Other interactions
    uiElements.joinButton.MouseButton1Click:Connect(function()
        joinByJobId(jobIdInput.Text)
    end)
    
    uiElements.copyJobIdBtn.MouseButton1Click:Connect(function()
        copyToClipboard(game.JobId)
    end)
    
    -- Hover effects
    logoButton.MouseEnter:Connect(function()
        logoButton.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    end)
    
    logoButton.MouseLeave:Connect(function()
        logoButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    end)
    
    closeBtn.MouseEnter:Connect(function()
        closeBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
    end)
    
    closeBtn.MouseLeave:Connect(function()
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    end)
    
    joinButton.MouseEnter:Connect(function()
        joinButton.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    end)
    
    joinButton.MouseLeave:Connect(function()
        joinButton.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    end)
    
    uiElements.copyJobIdBtn.MouseEnter:Connect(function()
        uiElements.copyJobIdBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    end)
    
    uiElements.copyJobIdBtn.MouseLeave:Connect(function()
        uiElements.copyJobIdBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    end)
    
    jobIdInput.Focused:Connect(function()
        jobIdInput.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        jobIdInput.UIStroke.Color = Color3.fromRGB(0, 150, 255)
    end)
    
    jobIdInput.FocusLost:Connect(function()
        jobIdInput.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        jobIdInput.UIStroke.Color = Color3.fromRGB(100, 100, 100)
    end)
    
    return screenGui
end

-- Initialize
local function initialize()
    createStatusDisplay()
    createMainUI()
    
    print("✅ Vortex UI Enhanced v" .. CONFIG.VERSION .. " Loaded!")
    print("📁 Folder: " .. CONFIG.VORTEX_FOLDER)
    print("💾 Tracking " .. countTable(usedServerIds) .. " servers")
    print("🔍 Scanning System: ACTIVE")
    print("📜 © 2025 VortexTeamDev™")
    
    updateStatusDisplay("System Ready", true)
    
    delay(2, function()
        showNotification("🚀 Vortex UI Ready! (" .. countTable(usedServerIds) .. " servers in history)", true)
    end)
end

-- Start the script
initialize()
