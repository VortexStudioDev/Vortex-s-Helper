-- Modern Buton Screen GUI
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Ana GUI'yi oluştur
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernButtonGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Ana container
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 350, 0, 450)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Köşe yuvarlaklığı
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = mainFrame

-- Gölge efekti
local shadow = Instance.new("UIStroke")
shadow.Color = Color3.fromRGB(80, 120, 255)
shadow.Thickness = 3
shadow.Transparency = 0.3
shadow.Parent = mainFrame

-- Gradient arkaplan
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 40)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 30, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 35))
})
gradient.Rotation = 45
gradient.Parent = mainFrame

-- Başlık
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 60)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🚀 DENEYİM MENÜSÜ"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextStrokeTransparency = 0.8
title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
title.Parent = mainFrame

-- Açıklama
local description = Instance.new("TextLabel")
description.Name = "Description"
description.Size = UDim2.new(0.9, 0, 0, 40)
description.Position = UDim2.new(0.05, 0, 0, 60)
description.BackgroundTransparency = 1
description.Text = "Aşağıdaki butonları kullanarak çeşitli işlemleri gerçekleştirebilirsiniz"
description.TextColor3 = Color3.fromRGB(200, 200, 200)
description.Font = Enum.Font.Gotham
description.TextSize = 14
description.TextWrapped = true
description.Parent = mainFrame

-- Buton container
local buttonContainer = Instance.new("Frame")
buttonContainer.Name = "ButtonContainer"
buttonContainer.Size = UDim2.new(0.9, 0, 0, 300)
buttonContainer.Position = UDim2.new(0.05, 0, 0, 110)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainFrame

-- Butonları oluşturma fonksiyonu
local function createButton(name, text, position, color, icon)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, 0, 0, 50)
    button.Position = position
    button.BackgroundColor3 = color
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = buttonContainer
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = button
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(255, 255, 255)
    buttonStroke.Thickness = 2
    buttonStroke.Transparency = 0.5
    buttonStroke.Parent = button
    
    local buttonGradient = Instance.new("UIGradient")
    buttonGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color),
        ColorSequenceKeypoint.new(1, Color3.new(color.R * 0.7, color.G * 0.7, color.B * 0.7))
    })
    buttonGradient.Rotation = 90
    buttonGradient.Parent = button
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name = "Icon"
    iconLabel.Size = UDim2.new(0, 40, 1, 0)
    iconLabel.Position = UDim2.new(0, 10, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 20
    iconLabel.TextXAlignment = Enum.TextXAlignment.Left
    iconLabel.Parent = button
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Text"
    textLabel.Size = UDim2.new(1, -60, 1, 0)
    textLabel.Position = UDim2.new(0, 50, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Font = Enum.Font.GothamSemibold
    textLabel.TextSize = 16
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = button
    
    -- Hover efekti
    button.MouseEnter:Connect(function()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(button, tweenInfo, {BackgroundTransparency = 0.1})
        tween:Play()
        
        buttonStroke.Transparency = 0.2
    end)
    
    button.MouseLeave:Connect(function()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(button, tweenInfo, {BackgroundTransparency = 0})
        tween:Play()
        
        buttonStroke.Transparency = 0.5
    end)
    
    -- Click efekti
    button.MouseButton1Down:Connect(function()
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(button, tweenInfo, {Size = UDim2.new(0.95, 0, 0, 48)})
        tween:Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(button, tweenInfo, {Size = UDim2.new(1, 0, 0, 50)})
        tween:Play()
    end)
    
    return button
end

-- Butonları oluştur
local buttons = {
    {
        name = "SpeedBoost",
        text = "HIZ ARTTIRICI",
        position = UDim2.new(0, 0, 0, 0),
        color = Color3.fromRGB(65, 105, 225),
        icon = "⚡"
    },
    {
        name = "JumpBoost", 
        text = "ZIPLAMA GÜCÜ",
        position = UDim2.new(0, 0, 0, 60),
        color = Color3.fromRGB(50, 205, 50),
        icon = "🦘"
    },
    {
        name = "Fly",
        text = "UÇMA MODU",
        position = UDim2.new(0, 0, 0, 120),
        color = Color3.fromRGB(255, 140, 0),
        icon = "🚀"
    },
    {
        name = "GodMode",
        text = "ÖLÜMSÜZLÜK",
        position = UDim2.new(0, 0, 0, 180),
        color = Color3.fromRGB(220, 20, 60),
        icon = "🛡️"
    },
    {
        name = "Teleport",
        text = "IŞINLANMA",
        position = UDim2.new(0, 0, 0, 240),
        color = Color3.fromRGB(138, 43, 226),
        icon = "💫"
    }
}

local createdButtons = {}

for i, buttonInfo in ipairs(buttons) do
    local button = createButton(
        buttonInfo.name,
        buttonInfo.text,
        buttonInfo.position,
        buttonInfo.color,
        buttonInfo.icon
    )
    createdButtons[buttonInfo.name] = button
end

-- Buton fonksiyonları
createdButtons.SpeedBoost.MouseButton1Click:Connect(function()
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 50
        game.StarterGui:SetCore("SendNotification", {
            Title = "⚡ HIZ ARTTIRICI",
            Text = "Hız 50'ye ayarlandı!",
            Duration = 3
        })
    end
end)

createdButtons.JumpBoost.MouseButton1Click:Connect(function()
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpPower = 100
        game.StarterGui:SetCore("SendNotification", {
            Title = "🦘 ZIPLAMA GÜCÜ", 
            Text = "Zıplama gücü 100'e ayarlandı!",
            Duration = 3
        })
    end
end)

createdButtons.Fly.MouseButton1Click:Connect(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "🚀 UÇMA MODU",
        Text = "Uçma modu aktif edildi!",
        Duration = 3
    })
    -- Buraya uçma scripti eklenebilir
end)

createdButtons.GodMode.MouseButton1Click:Connect(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "🛡️ ÖLÜMSÜZLÜK",
        Text = "Ölümsüzlük modu aktif!",
        Duration = 3
    })
    -- Buraya ölümsüzlük scripti eklenebilir
end)

createdButtons.Teleport.MouseButton1Click:Connect(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "💫 IŞINLANMA",
        Text = "Işınlanma modu hazır!",
        Duration = 3
    })
    -- Buraya ışınlanma scripti eklenebilir
end)

-- Kapatma butonu
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -50, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 20)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Drag özelliği
local dragging = false
local dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Animasyonlu gradient
task.spawn(function()
    while screenGui.Parent do
        wait(0.1)
        gradient.Rotation = gradient.Rotation + 1
    end
end)

-- Açılış animasyonu
mainFrame.Position = UDim2.new(0.5, -175, 0, -450)
local openTween = TweenService:Create(mainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -175, 0.5, -225)
})
openTween:Play()

print("🚀 Modern Buton GUI başarıyla yüklendi!")
