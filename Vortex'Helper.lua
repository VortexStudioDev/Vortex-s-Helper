-- Vortex Helper - Simple ESP
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ESP değişkenleri
local ESP = {
    Enabled = false,
    Boxes = {}
}

-- Basit bildirim
local function Notify(msg)
    print("[Vortex] " .. msg)
end

-- Player ESP oluştur
local function CreateESP(targetPlayer)
    if ESP.Boxes[targetPlayer] then return end
    
    local character = targetPlayer.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- ESP Kutusu
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 6, 2)
    box.Adornee = humanoidRootPart
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Color3 = Color3.new(0, 1, 0)
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
    label.Text = targetPlayer.Name
    label.TextColor3 = Color3.new(0, 1, 0)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = billboard
    
    ESP.Boxes[targetPlayer] = {
        Box = box,
        Tag = billboard
    }
end

-- ESP'yi temizle
local function ClearESP()
    for targetPlayer, espData in pairs(ESP.Boxes) do
        if espData.Box then espData.Box:Destroy() end
        if espData.Tag then espData.Tag:Destroy() end
    end
    ESP.Boxes = {}
end

-- ESP'yi güncelle
local function UpdateESP()
    if not ESP.Enabled then return end
    
    for targetPlayer, espData in pairs(ESP.Boxes) do
        if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if espData.Box then espData.Box:Destroy() end
            if espData.Tag then espData.Tag:Destroy() end
            ESP.Boxes[targetPlayer] = nil
        end
    end
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player then
            CreateESP(targetPlayer)
        end
    end
end

-- ESP'yi aç/kapa
local function ToggleESP()
    ESP.Enabled = not ESP.Enabled
    if ESP.Enabled then
        Notify("ESP: ON")
        UpdateESP()
    else
        Notify("ESP: OFF")
        ClearESP()
    end
end

-- Komut ekle
game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
    Text = "[Vortex] ESP loaded! Type /esp to toggle",
    Color = Color3.new(0, 1, 1),
    Font = Enum.Font.GothamBold
})

-- Chat komutu
player.Chatted:Connect(function(message)
    if message:lower() == "/esp" then
        ToggleESP()
    end
end)

-- Sürekli güncelle
RunService.Heartbeat:Connect(UpdateESP)

Notify("Vortex ESP System Ready!")
