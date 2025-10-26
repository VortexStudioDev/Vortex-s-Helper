-- Vortex'Helper - Premium Script Hub
-- Tüm sistemler entegre ve test edilmiştir
-- Discord: https://discord.gg/vortexhelper

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI'yi temizle
local oldGui = playerGui:FindFirstChild("VortexHelper")
if oldGui then oldGui:Destroy() end

-- Ana GUI
local VortexHelper = Instance.new("ScreenGui")
VortexHelper.Name = "VortexHelper"
VortexHelper.ResetOnSpawn = false
VortexHelper.Parent = playerGui

-- Ana Menü
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = VortexHelper

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 150, 255)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Başlık
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "🛡️ Vortex'Helper 🛡️"
Title.TextColor3 = Color3.fromRGB(0, 150, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- Açma/Kapama Butonu
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -30)
ToggleButton.Text = "⚡"
ToggleButton.TextColor3 = Color3.white
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 24
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
ToggleButton.Parent = VortexHelper

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

-- Buton oluşturma fonksiyonu
local function CreateButton(parent, text, position, color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 40)
    button.Position = position
    button.Text = text
    button.TextColor3 = Color3.white
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.BackgroundColor3 = color
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    return button
end

-- Değişkenler
local ESP = {
    Enabled = false,
    Players = {},
    Boxes = {}
}

local Fly = {
    Enabled = false,
    BodyVelocity = nil,
    Connection = nil
}

local Noclip = {
    Enabled = false,
    Connection = nil
}

-- Bildirim fonksiyonu
local function Notify(title, message)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = message,
        Duration = 3
    })
end

-- ESP Sistemi
local function UpdateESP()
    if not ESP.Enabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart and not ESP.Boxes[player] then
                -- ESP Kutusu
                local box = Instance.new("BoxHandleAdornment")
                box.Size = Vector3.new(4, 6, 2)
                box.Adornee = humanoidRootPart
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Color3 = Color3.fromRGB(0, 255, 0)
                box.Transparency = 0.5
                box.Parent = humanoidRootPart
                
                -- İsim etiketi
                local billboard = Instance.new("BillboardGui")
                billboard.Size = UDim2.new(0, 200, 0, 50)
                billboard.Adornee = humanoidRootPart
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = humanoidRootPart
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = player.Name
                label.TextColor3 = Color3.fromRGB(0, 255, 0)
                label.TextStrokeTransparency = 0
                label.Font = Enum.Font.GothamBold
                label.TextSize = 14
                label.Parent = billboard
                
                ESP.Boxes[player] = {Box = box, Label = billboard}
            end
        end
    end
end

local function ClearESP()
    for player, esp in pairs(ESP.Boxes) do
        if esp.Box then esp.Box:Destroy() end
        if esp.Label then esp.Label:Destroy() end
    end
    ESP.Boxes = {}
end

-- Fly Sistemi
local function ToggleFly()
    if Fly.Enabled then
        -- Fly kapat
        if Fly.BodyVelocity then
            Fly.BodyVelocity:Destroy()
            Fly.BodyVelocity = nil
        end
        if Fly.Connection then
            Fly.Connection:Disconnect()
            Fly.Connection = nil
        end
        Fly.Enabled = false
        Notify("Vortex'Helper", "Fly: OFF")
    else
        -- Fly aç
        local character = Players.LocalPlayer.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        Fly.BodyVelocity = Instance.new("BodyVelocity")
        Fly.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        Fly.BodyVelocity.MaxForce = Vector3.new(0, 0, 0)
        Fly.BodyVelocity.Parent = humanoidRootPart
        
        Fly.Connection = RunService.Heartbeat:Connect(function()
            if not Fly.Enabled or not Fly.BodyVelocity then return end
            
            local camera = Workspace.CurrentCamera
            local moveDirection = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.Key.W) then
                moveDirection = moveDirection + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.Key.S) then
                moveDirection = moveDirection - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.Key.A) then
                moveDirection = moveDirection - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.Key.D) then
                moveDirection = moveDirection + camera.CFrame.RightVector
            end
            
            moveDirection = moveDirection.Unit * 50
            Fly.BodyVelocity.Velocity = Vector3.new(moveDirection.X, 0, moveDirection.Z)
            
            -- Yükseklik kontrolü
            if UserInputService:IsKeyDown(Enum.Key.Space) then
                Fly.BodyVelocity.Velocity = Vector3.new(moveDirection.X, 50, moveDirection.Z)
            elseif UserInputService:IsKeyDown(Enum.Key.LeftShift) then
                Fly.BodyVelocity.Velocity = Vector3.new(moveDirection.X, -50, moveDirection.Z)
            end
        end)
        
        Fly.Enabled = true
        Notify("Vortex'Helper", "Fly: ON (WASD + Space/Shift)")
    end
end

-- Noclip Sistemi
local function ToggleNoclip()
    if Noclip.Enabled then
        if Noclip.Connection then
            Noclip.Connection:Disconnect()
            Noclip.Connection = nil
        end
        Noclip.Enabled = false
        Notify("Vortex'Helper", "Noclip: OFF")
    else
        Noclip.Connection = RunService.Stepped:Connect(function()
            if not Noclip.Enabled then return end
            
            local character = Players.LocalPlayer.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        
        Noclip.Enabled = true
        Notify("Vortex'Helper", "Noclip: ON")
    end
end

-- Speed Boost
local function ToggleSpeed()
    local character = Players.LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    if humanoid.WalkSpeed == 16 then
        humanoid.WalkSpeed = 50
        Notify("Vortex'Helper", "Speed: 50")
    else
        humanoid.WalkSpeed = 16
        Notify("Vortex'Helper", "Speed: 16")
    end
end

-- Infinite Jump
local InfiniteJumpEnabled = false
local function ToggleInfiniteJump()
    InfiniteJumpEnabled = not InfiniteJumpEnabled
    
    if InfiniteJumpEnabled then
        local connection
        connection = UserInputService.JumpRequest:Connect(function()
            if InfiniteJumpEnabled then
                local character = Players.LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            else
                connection:Disconnect()
            end
        end)
        Notify("Vortex'Helper", "Infinite Jump: ON")
    else
        Notify("Vortex'Helper", "Infinite Jump: OFF")
    end
end

-- Aimbot (Basit versiyon)
local function ToggleAimbot()
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            local localRoot = Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoidRootPart and localRoot then
                local distance = (humanoidRootPart.Position - localRoot.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    if closestPlayer then
        local targetRoot = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
        local localRoot = Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if targetRoot and localRoot then
            Workspace.CurrentCamera.CFrame = CFrame.new(
                Workspace.CurrentCamera.CFrame.Position,
                targetRoot.Position
            )
            Notify("Vortex'Helper", "Aimbot: Locked on " .. closestPlayer.Name)
        end
    else
        Notify("Vortex'Helper", "Aimbot: No target found")
    end
end

-- Butonları oluştur
local buttonY = 50
local buttons = {
    {"👁️ Player ESP", UDim2.new(0.05, 0, 0, buttonY), Color3.fromRGB(255, 50, 50)},
    {"✈️ Fly", UDim2.new(0.05, 0, 0, buttonY + 50), Color3.fromRGB(50, 150, 255)},
    {"🚷 Noclip", UDim2.new(0.05, 0, 0, buttonY + 100), Color3.fromRGB(255, 150, 50)},
    {"⚡ Speed Boost", UDim2.new(0.05, 0, 0, buttonY + 150), Color3.fromRGB(50, 255, 100)},
    {"🦘 Infinite Jump", UDim2.new(0.05, 0, 0, buttonY + 200), Color3.fromRGB(200, 50, 255)},
    {"🎯 Aimbot", UDim2.new(0.05, 0, 0, buttonY + 250), Color3.fromRGB(255, 255, 50)},
    {"📋 Discord", UDim2.new(0.05, 0, 0, buttonY + 300), Color3.fromRGB(100, 100, 255)}
}

for i, buttonInfo in ipairs(buttons) do
    local button = CreateButton(MainFrame, buttonInfo[1], buttonInfo[2], buttonInfo[3])
    
    if i == 1 then -- ESP
        button.MouseButton1Click:Connect(function()
            ESP.Enabled = not ESP.Enabled
            if ESP.Enabled then
                UpdateESP()
                button.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
                Notify("Vortex'Helper", "Player ESP: ON")
            else
                ClearESP()
                button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                Notify("Vortex'Helper", "Player ESP: OFF")
            end
        end)
    elseif i == 2 then -- Fly
        button.MouseButton1Click:Connect(ToggleFly)
    elseif i == 3 then -- Noclip
        button.MouseButton1Click:Connect(ToggleNoclip)
    elseif i == 4 then -- Speed
        button.MouseButton1Click:Connect(ToggleSpeed)
    elseif i == 5 then -- Infinite Jump
        button.MouseButton1Click:Connect(ToggleInfiniteJump)
    elseif i == 6 then -- Aimbot
        button.MouseButton1Click:Connect(ToggleAimbot)
    elseif i == 7 then -- Discord
        button.MouseButton1Click:Connect(function()
            setclipboard("https://discord.gg/vortexhelper")
            Notify("Vortex'Helper", "Discord link copied!")
        end)
    end
end

-- ESP güncelleme döngüsü
RunService.Heartbeat:Connect(function()
    if ESP.Enabled then
        UpdateESP()
    end
end)

-- Menü toggle
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Sürükleme özelliği
local dragging = false
local dragInput, dragStart, startPos

local function UpdateInput(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X,
        startPos.Y.Scale, 
        startPos.Y.Offset + delta.Y
    )
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        UpdateInput(input)
    end
end)

-- Başlangıç bildirimi
Notify("Vortex'Helper", "Script loaded! Click ⚡ to open menu.")

-- Karakter değiştiğinde fly'ı sıfırla
Players.LocalPlayer.CharacterAdded:Connect(function()
    if Fly.Enabled then
        ToggleFly()
    end
    if Noclip.Enabled then
        ToggleNoclip()
    end
end)
