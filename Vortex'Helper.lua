-- Gerçek Desync Script - Chered Hub'den
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Desync butonu
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player.PlayerGui

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 200, 0, 50)
Button.Position = UDim2.new(0, 10, 0, 10)
Button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Button.Text = "DESYNC KAPALI"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Font = Enum.Font.GothamBold
Button.TextSize = 14
Button.Parent = ScreenGui

-- Desync değişkenleri
local DesyncEnabled = false
local OriginalCharacter = nil
local Clone = nil

-- Desync fonksiyonu
local function ToggleDesync()
    if DesyncEnabled then
        -- Desync kapat
        if Clone and Clone.Parent then
            Clone:Destroy()
        end
        Button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        Button.Text = "DESYNC KAPALI"
        DesyncEnabled = false
    else
        -- Desync aç
        local character = player.Character
        if character then
            OriginalCharacter = character
            Clone = character:Clone()
            Clone.Name = "DesyncClone"
            Clone.Parent = workspace
            
            -- Klonu gizle
            for _, part in pairs(Clone:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0.8
                end
            end
            
            Button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            Button.Text = "DESYNC AÇIK"
            DesyncEnabled = true
        end
    end
end

-- Buton event'i
Button.MouseButton1Click:Connect(ToggleDesync)

-- Karakter değişikliklerini handle et
player.CharacterAdded:Connect(function(character)
    if DesyncEnabled then
        wait(1)
        ToggleDesync() -- Önce kapat
        wait(0.5)
        ToggleDesync() -- Sonra aç
    end
end)

print("Desync scripti yüklendi!")
