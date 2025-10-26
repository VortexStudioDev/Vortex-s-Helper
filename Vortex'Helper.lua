-- LocalScript
local player = game.Players.LocalPlayer
local screenGui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui") -- Ekran GUI'si
local antiHitRunning = false
local antiHitActive = false
local btnDesync

-- Buton oluşturma
btnDesync = Instance.new("TextButton")
btnDesync.Parent = screenGui
btnDesync.Size = UDim2.new(0, 200, 0, 50)
btnDesync.Position = UDim2.new(0.5, -100, 0.8, 0) -- Butonun ekranın ortasında olması
btnDesync.Text = "🛡️ DESYNC BODY"
btnDesync.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
btnDesync.TextColor3 = Color3.fromRGB(255, 255, 255)
btnDesync.TextSize = 20
btnDesync.Font = Enum.Font.GothamBold

-- Butona tıklanma işlevi
btnDesync.MouseButton1Click:Connect(function()
    if antiHitRunning or antiHitActive then
        deactivateAntiHit()
    else
        executeAntiHit()
    end
end)

-- Anti-hit fonksiyonu
local function executeAntiHit()
    if antiHitRunning then
        return
    end
    antiHitRunning = true

    if typeof(updateDesyncButton) == 'function' then
        pcall(updateDesyncButton)
    end

    activateDesync()
    task.wait(0.1)
    activateClonerDesync(function()
        deactivateDesync()
        antiHitRunning = false
        antiHitActive = true
        showNotification('Anti-Hit activated! 🛡️', Color3.fromRGB(0, 255, 0), 3)
        if typeof(updateDesyncButton) == 'function' then
            pcall(updateDesyncButton)
        end
    end)
end

-- Anti-hit devre dışı bırakma fonksiyonu
local function deactivateAntiHit()
    if antiHitRunning then
        if cloneListenerConn then
            cloneListenerConn:Disconnect()
            cloneListenerConn = nil
        end
        antiHitRunning = false
    end

    deactivateClonerDesync()
    deactivateDesync()
    antiHitActive = false

    if player.Character then
        removeInvulnerable(player.Character)
    end

    local possibleClone = Workspace:FindFirstChild(tostring(player.UserId) .. '_Clone')
    if possibleClone then
        pcall(function()
            removeInvulnerable(possibleClone)
            possibleClone:Destroy()
        end)
    end

    -- Temizleme işlemi
    for model, _ in pairs(desyncHighlights) do
        removeDesyncHighlight(model)
    end

    showNotification('Anti-Hit deactivated. ❌', Color3.fromRGB(255, 120, 120), 2)
    if typeof(updateDesyncButton) == 'function' then
        pcall(updateDesyncButton)
    end
end

-- Buton güncellemeleri
local function updateDesyncButton()
    if antiHitRunning then
        btnDesync.BackgroundColor3 = Color3.fromRGB(255, 220, 60)
        btnDesync.Text = '⏳ DESYNC ACTIVE'
    elseif antiHitActive then
        btnDesync.BackgroundColor3 = Color3.fromRGB(120, 255, 120)
        btnDesync.Text = '✅ DESYNC ON'
    else
        btnDesync.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
        btnDesync.Text = '🛡️ DESYNC BODY'
    end
end
