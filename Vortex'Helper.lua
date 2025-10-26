-- Basit Desync Buton GUI
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI'yi oluştur
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DesyncButtonGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Desync butonu
local desyncButton = Instance.new("TextButton")
desyncButton.Name = "DesyncButton"
desyncButton.Size = UDim2.new(0, 200, 0, 60)
desyncButton.Position = UDim2.new(0, 20, 0, 20)
desyncButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
desyncButton.Text = "🛡️ DESYNC AÇ"
desyncButton.TextColor3 = Color3.fromRGB(255, 255, 255)
desyncButton.Font = Enum.Font.GothamBold
desyncButton.TextSize = 18
desyncButton.BorderSizePixel = 0
desyncButton.Parent = screenGui

-- Köşe yuvarlaklığı
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = desyncButton

-- Desync değişkenleri
local antiHitActive = false
local antiHitRunning = false

-- Desync fonksiyonları
local function notify(title, text)
    game.StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 3
    })
end

local function makeInvulnerable(model)
    if not model then return end
    
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum.MaxHealth = 1e9
            hum.Health = 1e9
        end)
        
        if not model:FindFirstChildOfClass("ForceField") then
            local ff = Instance.new("ForceField")
            ff.Visible = false
            ff.Parent = model
        end
    end
end

local function removeInvulnerable(model)
    if not model then return end
    
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum.MaxHealth = 100
            hum.Health = 100
        end)
    end
    
    for _, ff in ipairs(model:GetChildren()) do
        if ff:IsA("ForceField") then
            ff:Destroy()
        end
    end
end

-- Desync aktif etme
local function activateDesync()
    if antiHitRunning then return end
    antiHitRunning = true
    
    local character = player.Character
    if not character then
        notify("HATA", "Karakter bulunamadı!")
        antiHitRunning = false
        return
    end
    
    -- Karakteri koruma altına al
    makeInvulnerable(character)
    
    -- Klon oluşturma (Quantum Cloner benzeri)
    local cloneName = tostring(player.UserId) .. "_Clone"
    local existingClone = workspace:FindFirstChild(cloneName)
    if existingClone then
        existingClone:Destroy()
    end
    
    -- Basit klon oluşturma
    local clone = character:Clone()
    clone.Name = cloneName
    clone.Parent = workspace
    
    -- Klonu da koruma altına al
    makeInvulnerable(clone)
    
    -- Klonun pozisyonunu ayarla
    local hrp = clone:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = character:FindFirstChild("HumanoidRootPart").CFrame * CFrame.new(5, 0, 0)
    end
    
    antiHitActive = true
    antiHitRunning = false
    
    notify("DESYNC", "Desync aktif! 🛡️")
    desyncButton.Text = "✅ DESYNC AÇIK"
    desyncButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
end

-- Desync kapatma
local function deactivateDesync()
    local character = player.Character
    if character then
        removeInvulnerable(character)
    end
    
    -- Klonu temizle
    local cloneName = tostring(player.UserId) .. "_Clone"
    local existingClone = workspace:FindFirstChild(cloneName)
    if existingClone then
        removeInvulnerable(existingClone)
        existingClone:Destroy()
    end
    
    antiHitActive = false
    
    notify("DESYNC", "Desync kapatıldı! ❌")
    desyncButton.Text = "🛡️ DESYNC AÇ"
    desyncButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
end

-- Buton tıklama eventi
desyncButton.MouseButton1Click:Connect(function()
    if antiHitRunning then return end
    
    if antiHitActive then
        deactivateDesync()
    else
        activateDesync()
    end
end)

-- Karakter değiştiğinde temizlik
player.CharacterAdded:Connect(function(character)
    if antiHitActive then
        task.wait(1)
        makeInvulnerable(character)
    end
end)

player.CharacterRemoving:Connect(function(character)
    removeInvulnerable(character)
end)

-- Buton hover efektleri
desyncButton.MouseEnter:Connect(function()
    if not antiHitActive then
        desyncButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

desyncButton.MouseLeave:Connect(function()
    if not antiHitActive then
        desyncButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

print("Desync butonu yüklendi! Ekranın sol üst köşesinde görünecek.")
