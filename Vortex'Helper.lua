-- Servisler
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- VORTEX BİLDİRİM SİSTEMİ
local function showNotification(message, isSuccess)
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "VortexNotify"
    notificationGui.ResetOnSpawn = false
    notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notificationGui.Parent = CoreGui
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 300, 0, 70)
    notification.Position = UDim2.new(0.5, -150, 0.15, 0)
    notification.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    notification.BackgroundTransparency = 0
    notification.BorderSizePixel = 0
    notification.ZIndex = 1000
    notification.ClipsDescendants = true
    notification.Parent = notificationGui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notification
    
    local notifStroke = Instance.new("UIStroke")
    notifStroke.Color = isSuccess and Color3.fromRGB(0, 255, 157) or Color3.fromRGB(255, 50, 50)
    notifStroke.Thickness = 2
    notifStroke.Parent = notification

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 40, 0, 40)
    icon.Position = UDim2.new(0, 15, 0.5, -20)
    icon.BackgroundTransparency = 1
    icon.Text = isSuccess and "✓" or "✗"
    icon.TextColor3 = isSuccess and Color3.fromRGB(0, 255, 157) or Color3.fromRGB(255, 50, 50)
    icon.TextSize = 20
    icon.Font = Enum.Font.GothamBold
    icon.ZIndex = 1001
    icon.Parent = notification

    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(1, -70, 1, -10)
    notifText.Position = UDim2.new(0, 60, 0, 5)
    notifText.BackgroundTransparency = 1
    notifText.Text = message
    notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifText.TextSize = 14
    notifText.Font = Enum.Font.GothamBold
    notifText.TextXAlignment = Enum.TextXAlignment.Left
    notifText.TextYAlignment = Enum.TextYAlignment.Top
    notifText.TextWrapped = true
    notifText.ZIndex = 1001
    notifText.Parent = notification

    -- Animasyon
    notification.Position = UDim2.new(0.5, -150, 0.1, 0)
    notification.BackgroundTransparency = 1
    notifText.TextTransparency = 1
    icon.TextTransparency = 1
    
    local tweenIn = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -150, 0.15, 0),
        BackgroundTransparency = 0
    })
    
    local textTweenIn = TweenService:Create(notifText, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        TextTransparency = 0
    })
    
    local iconTweenIn = TweenService:Create(icon, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        TextTransparency = 0
    })
    
    tweenIn:Play()
    textTweenIn:Play()
    iconTweenIn:Play()

    -- Otomatik kapanma
    tweenIn.Completed:Connect(function()
        task.wait(3)
        
        local tweenOut = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -150, 0.1, 0),
            BackgroundTransparency = 1
        })
        
        local textTweenOut = TweenService:Create(notifText, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            TextTransparency = 1
        })
        
        local iconTweenOut = TweenService:Create(icon, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            TextTransparency = 1
        })
        
        tweenOut:Play()
        textTweenOut:Play()
        iconTweenOut:Play()
        
        tweenOut.Completed:Connect(function()
            notificationGui:Destroy()
        end)
    end)
end

-- YEŞİL KARAKTER GÖSTERGESİ
local characterHighlights = {}

local function addCharacterHighlight(character)
    if not character or characterHighlights[character] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "VortexCharacterHighlight"
    highlight.FillColor = Color3.fromRGB(0, 255, 157)
    highlight.OutlineColor = Color3.fromRGB(0, 200, 120)
    highlight.FillTransparency = 0.4
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

-- VORTEX GUI (SENİN TASARIMIN GİBİ)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ScriptVerseDesyncUnPatchedForever"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 140)
mainFrame.Position = UDim2.new(0.5, 0, 0.15, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -10, 0, 25)
titleLabel.Position = UDim2.new(0, 5, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ScriptVerseDesyncUnPatchedForever"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 12
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.TextScaled = true
titleLabel.Parent = mainFrame

local desyncActive = false

-- SENİN BUTON TASARIMIN GİBİ
local stateButton = Instance.new("TextButton")
stateButton.Name = "StateButton"
stateButton.Size = UDim2.new(0, 240, 0, 80)
stateButton.Position = UDim2.new(0.5, 0, 0, 50)
stateButton.AnchorPoint = Vector2.new(0.5, 0)
stateButton.BackgroundColor3 = Color3.fromRGB(150, 100, 220)
stateButton.BorderSizePixel = 0
stateButton.Font = Enum.Font.GothamBold
stateButton.TextSize = 32
stateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stateButton.Text = "State: OFF"
stateButton.Parent = mainFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 10)
buttonCorner.Parent = stateButton

-- SÜRÜKLEME SİSTEMİ
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

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
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- VORTEX DESYNC SİSTEMİ
local function enableVortexDesync()
    local success, error = pcall(function()
        local backpack = LocalPlayer:WaitForChild("Backpack")
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        
        local packages = ReplicatedStorage:WaitForChild("Packages", 5)
        if not packages then 
            showNotification("Paketler bulunamadı", false)
            return false 
        end
        
        local netFolder = packages:WaitForChild("Net", 5)
        if not netFolder then 
            showNotification("Net klasörü bulunamadı", false)
            return false 
        end
        
        local useItemRemote = netFolder:WaitForChild("RE/UseItem", 5)
        local teleportRemote = netFolder:WaitForChild("RE/QuantumCloner/OnTeleport", 5)
        if not useItemRemote or not teleportRemote then 
            showNotification("Remote'lar bulunamadı", false)
            return false 
        end

        -- Tool bul
        local toolNames = {"Quantum Cloner", "Brainrot", "brainrot"}
        local tool
        for _, toolName in ipairs(toolNames) do
            tool = backpack:FindFirstChild(toolName) or character:FindFirstChild(toolName)
            if tool then break end
        end
        if not tool then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") then 
                    tool = item 
                    break 
                end
            end
        end

        -- Tool equip
        if tool and tool.Parent == backpack then
            humanoid:EquipTool(tool)
            task.wait(0.5)
        end

        -- Desync aktivasyonu
        if setfflag then 
            setfflag("WorldStepMax", "-9999999999") 
        end
        
        task.wait(0.2)
        useItemRemote:FireServer()
        showNotification("Quantum Cloner aktifleştiriliyor...", false)
        
        task.wait(1)
        teleportRemote:FireServer()
        
        task.wait(2)
        if setfflag then 
            setfflag("WorldStepMax", "-1") 
        end
        
        -- Karakter highlight ekle
        addCharacterHighlight(character)
        
        -- Clone'u da kontrol et ve highlight ekle
        local cloneName = tostring(LocalPlayer.UserId) .. "_Clone"
        local clone = workspace:FindFirstChild(cloneName)
        if clone then
            addCharacterHighlight(clone)
        end
        
        showNotification("Vortex Desync aktif!", true)
        return true
    end)
    
    if not success then
        showNotification("Hata: " .. tostring(error), false)
        return false
    end
    return success
end

local function disableVortexDesync()
    pcall(function()
        if setfflag then 
            setfflag("WorldStepMax", "-1") 
        end
        
        -- Tüm highlight'ları kaldır
        removeAllHighlights()
        
        -- Clone'u temizle
        local cloneName = tostring(LocalPlayer.UserId) .. "_Clone"
        local clone = workspace:FindFirstChild(cloneName)
        if clone then
            pcall(function() 
                clone:Destroy() 
            end)
        end
        
        showNotification("Vortex Desync kapatıldı", false)
    end)
end

-- BUTON TIKLAMA (SENİNKİ GİBİ)
stateButton.MouseButton1Click:Connect(function()
    desyncActive = not desyncActive
    
    if desyncActive then
        local success = enableVortexDesync()
        if success then
            stateButton.Text = "State: ON"
            stateButton.BackgroundColor3 = Color3.fromRGB(200, 200, 0)
        else
            desyncActive = false
            stateButton.Text = "State: OFF"
            stateButton.BackgroundColor3 = Color3.fromRGB(150, 100, 220)
        end
    else
        disableVortexDesync()
        stateButton.Text = "State: OFF"
        stateButton.BackgroundColor3 = Color3.fromRGB(150, 100, 220)
    end
end)

-- BUTON HOVER EFEKTLERİ (SENİNKİ GİBİ)
stateButton.MouseEnter:Connect(function()
    stateButton.BackgroundColor3 = stateButton.BackgroundColor3:Lerp(Color3.fromRGB(255, 255, 255), 0.12)
end)

stateButton.MouseLeave:Connect(function()
    if desyncActive then
        stateButton.BackgroundColor3 = Color3.fromRGB(200, 200, 0)
    else
        stateButton.BackgroundColor3 = Color3.fromRGB(150, 100, 220)
    end
end)

-- KARAKTER DEĞİŞİMİNDE RESET
LocalPlayer.CharacterAdded:Connect(function()
    desyncActive = false
    stateButton.Text = "State: OFF"
    stateButton.BackgroundColor3 = Color3.fromRGB(150, 100, 220)
    
    -- Tüm highlight'ları temizle
    removeAllHighlights()
end)

-- OYUN BAŞLANGICINDA MESAJ
task.wait(2)
showNotification("Vortex Desync sistemi yüklendi!", true)

print("✅ VORTEX DESYNC SİSTEMİ AKTİF!")
