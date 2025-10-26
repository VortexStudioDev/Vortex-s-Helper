-- Temiz Desync Butonu
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI oluştur
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DesyncGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Desync butonu
local desyncButton = Instance.new("TextButton")
desyncButton.Name = "DesyncButton"
desyncButton.Size = UDim2.new(0, 160, 0, 40)
desyncButton.Position = UDim2.new(0, 20, 0, 20)
desyncButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
desyncButton.Text = "🛡️ DESYNC KAPALI"
desyncButton.TextColor3 = Color3.fromRGB(255, 255, 255)
desyncButton.Font = Enum.Font.GothamBold
desyncButton.TextSize = 12
desyncButton.BorderSizePixel = 0
desyncButton.Parent = screenGui

-- Buton stil
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = desyncButton

-- Desync durumu
local desyncActive = false

-- Bildirim fonksiyonu
local function notify(message)
    game.StarterGui:SetCore("SendNotification", {
        Title = "DESYNC",
        Text = message,
        Duration = 3
    })
end

-- Basit ölümsüzlük
local function makeInvulnerable(char)
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        -- ForceField ekle
        if not char:FindFirstChildOfClass("ForceField") then
            local ff = Instance.new("ForceField")
            ff.Visible = false
            ff.Parent = char
        end
        
        -- Health ayarla
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    end
end

-- Ölümsüzlüğü kaldır
local function removeInvulnerable(char)
    if not char then return end
    
    -- ForceField'leri kaldır
    for _, child in pairs(char:GetChildren()) do
        if child:IsA("ForceField") then
            child:Destroy()
        end
    end
    
    -- Health'i sıfırla
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.MaxHealth = 100
        humanoid.Health = 100
    end
end

-- Klon oluştur
local function createClone()
    local character = player.Character
    if not character then return nil end
    
    -- Karakteri klonla
    local clone = character:Clone()
    clone.Name = player.Name .. "_Clone"
    
    -- Klonu workspace'e ekle
    clone.Parent = workspace
    
    -- Klonun pozisyonunu ayarla
    local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(5, 0, 0)
    end
    
    return clone
end

-- Desync'i başlat
local function startDesync()
    if desyncActive then return end
    
    desyncActive = true
    desyncButton.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
    desyncButton.Text = "✅ DESYNC AÇIK"
    
    local character = player.Character
    if character then
        -- Karakteri koru
        makeInvulnerable(character)
        
        -- Klon oluştur ve koru
        local clone = createClone()
        if clone then
            makeInvulnerable(clone)
        end
        
        notify("Desync aktif! 🛡️")
    else
        notify("Karakter bulunamadı!")
    end
end

-- Desync'i durdur
local function stopDesync()
    if not desyncActive then return end
    
    desyncActive = false
    desyncButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    desyncButton.Text = "🛡️ DESYNC KAPALI"
    
    local character = player.Character
    if character then
        -- Karakter korumasını kaldır
        removeInvulnerable(character)
    end
    
    -- Klonu bul ve sil
    local cloneName = player.Name .. "_Clone"
    local clone = workspace:FindFirstChild(cloneName)
    if clone then
        clone:Destroy()
    end
    
    notify("Desync kapatıldı! ❌")
end

-- Buton tıklama
desyncButton.MouseButton1Click:Connect(function()
    if desyncActive then
        stopDesync()
    else
        startDesync()
    end
end)

-- Karakter değişince
player.CharacterAdded:Connect(function(character)
    if desyncActive then
        wait(1) -- Karakterin yüklenmesini bekle
        makeInvulnerable(character)
    end
end)

-- Oyun'dan çıkınca temizlik
game:GetService("UserInputService").WindowFocused:Connect(function()
    if not desyncActive then return end
    
    local character = player.Character
    if character then
        makeInvulnerable(character)
    end
end)

print("Desync butonu hazır! Sol üst köşede.")
