-- Modified by panamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- === НАСТРОЙКИ ===
local AIMBOT_KEY = Enum.KeyCode.Q      
local CLOSE_GUI_KEY = Enum.KeyCode.N    

local config = {
    aimbotEnabled = false,
    aimSmoothness = 0.1,
    fovRadius = 70,
    
    wallCheckAimbot = true,
    teamCheck = true
}

-- === СОЗДАНИЕ ГРАФИЧЕСКОГО ИНТЕРФЕЙСА (GUI) ===
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
screenGui.Enabled = true

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 250)  -- Уменьшил высоту, так как убрал кнопки
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.Parent = screenGui

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 40, 0, 20)
minimizeButton.Position = UDim2.new(1, -45, 0, 5)
minimizeButton.Text = "_"
minimizeButton.TextColor3 = Color3.fromRGB(255,255,255)
minimizeButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
minimizeButton.Parent = frame

local minimized = false
minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, child in pairs(frame:GetChildren()) do
        if child ~= minimizeButton then
            child.Visible = not minimized
        end
    end
    frame.Size = minimized and UDim2.new(0, 40, 0, 20) or UDim2.new(0, 250, 0, 250)
end)

local function createButton(name, positionY)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 30)
    button.Position = UDim2.new(0, 5, 0, positionY)
    button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = name
    button.Parent = frame
    return button
end

-- ТОЛЬКО НУЖНЫЕ КНОПКИ
local aimbotButton = createButton("Aimbot: OFF (Q)", 30)
local teamCheckButton = createButton("Team Check: ON", 65)
local closeButton = createButton("Close GUI (N)", 100)

aimbotButton.MouseButton1Click:Connect(function()
    config.aimbotEnabled = not config.aimbotEnabled
    aimbotButton.Text = config.aimbotEnabled and "Aimbot: ON (Q)" or "Aimbot: OFF (Q)"
    fovCircle.Color = config.aimbotEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

teamCheckButton.MouseButton1Click:Connect(function()
    config.teamCheck = not config.teamCheck
    teamCheckButton.Text = config.teamCheck and "Team Check: ON" or "Team Check: OFF"
end)

closeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

-- === СЛАЙДЕР FOV ===
local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(1, -10, 0, 20)
sliderLabel.Position = UDim2.new(0, 5, 0, 135)  -- Сдвинул выше
sliderLabel.BackgroundTransparency = 1
sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
sliderLabel.Text = "FOV: "..config.fovRadius
sliderLabel.Parent = frame

local slider = Instance.new("Frame")
slider.Size = UDim2.new(1, -10, 0, 20)
slider.Position = UDim2.new(0, 5, 0, 155)
slider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
slider.Parent = frame

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 10, 1, 0)
knob.Position = UDim2.new(config.fovRadius/500, 0, 0, 0)
knob.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
knob.Parent = slider

local dragging = false
local function updateFOV(inputPositionX)
    local mouseX = math.clamp(inputPositionX - slider.AbsolutePosition.X, 0, slider.AbsoluteSize.X)
    config.fovRadius = math.floor((mouseX / slider.AbsoluteSize.X) * 500)
    sliderLabel.Text = "FOV: "..config.fovRadius
    knob.Position = UDim2.new(mouseX / slider.AbsoluteSize.X, 0, 0, 0)
end
local function connectSliderInput(inputType)
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == inputType then
            dragging = true
            updateFOV(input.Position.X)
        end
    end)
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == inputType then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == inputType then
            updateFOV(input.Position.X)
        end
    end)
end

connectSliderInput(Enum.UserInputType.MouseButton1)
connectSliderInput(Enum.UserInputType.Touch)

-- === СЛАЙДЕР СКОРОСТИ АИМА ===
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -10, 0, 20)
speedLabel.Position = UDim2.new(0, 5, 0, 180)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Text = "Aimbot Speed: "..config.aimSmoothness
speedLabel.Parent = frame

local speedSlider = Instance.new("Frame")
speedSlider.Size = UDim2.new(1, -10, 0, 20)
speedSlider.Position = UDim2.new(0, 5, 0, 200)
speedSlider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
speedSlider.Parent = frame

local speedKnob = Instance.new("Frame")
speedKnob.Size = UDim2.new(0, 10, 1, 0)
speedKnob.Position = UDim2.new(config.aimSmoothness, 0, 0, 0)
speedKnob.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
speedKnob.Parent = speedSlider

local speedDragging = false
local function updateSpeed(inputPositionX)
    local mouseX = math.clamp(inputPositionX - speedSlider.AbsolutePosition.X, 0, speedSlider.AbsoluteSize.X)
    config.aimSmoothness = math.clamp(mouseX / speedSlider.AbsoluteSize.X, 0.01, 1)
    speedLabel.Text = "Aimbot Speed: "..string.format("%.2f", config.aimSmoothness)
    speedKnob.Position = UDim2.new(mouseX / speedSlider.AbsoluteSize.X, 0, 0, 0)
end

speedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        speedDragging = true
        updateSpeed(input.Position.X)
    end
end)
speedSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        speedDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if speedDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSpeed(input.Position.X)
    end
end)

-- === ТЕКСТ ВНИЗУ ===
local creditText = Instance.new("TextLabel")
creditText.Size = UDim2.new(1, 0, 0, 20)
creditText.Position = UDim2.new(0, 0, 1, -20)
creditText.BackgroundTransparency = 1
creditText.Text = "by panamera XD"
creditText.TextColor3 = Color3.new(1, 1, 1)
creditText.TextScaled = true
creditText.Parent = frame

-- === СОЗДАНИЕ КРУГА FOV ===
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = true  -- Будет виден только когда меню открыто
fovCircle.Transparency = 0.5
fovCircle.Color = Color3.fromRGB(255, 0, 0)  -- Красный когда выключен
fovCircle.Thickness = 2
fovCircle.Radius = config.fovRadius
fovCircle.Filled = false

-- === ФУНКЦИЯ ПОИСКА БЛИЖАЙШЕГО ИГРОКА ===
local function getNearestPlayer()
    local closestPlayer = nil
    local closestMagnitude = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if not config.teamCheck or (LocalPlayer.Team ~= player.Team) then
                local headPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
                if onScreen then
                    local mousePos = Camera.ViewportSize / 2
local magnitude = (Vector2.new(headPos.X, headPos.Y) - mousePos).Magnitude
                    if magnitude < closestMagnitude and magnitude < config.fovRadius then
                        closestMagnitude = magnitude
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- === ФУНКЦИЯ ПРОВЕРКИ СТЕН (ВСЕГДА ВКЛЮЧЕНА) ===
local function canHit(target)
    local origin = Camera.CFrame.Position
    local direction = target.Character.Head.Position - origin
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    local rayResult = workspace:Raycast(origin, direction, rayParams)
    return rayResult and rayResult.Instance and rayResult.Instance:IsDescendantOf(target.Character)
end

-- === БИНДЫ НА КЛАВИШИ ===
local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end
    
    -- Бинд на Q (вкл/выкл аима) - БЫЛО T, СТАЛО Q
    if input.KeyCode == AIMBOT_KEY then
        config.aimbotEnabled = not config.aimbotEnabled
        aimbotButton.Text = config.aimbotEnabled and "Aimbot: ON (Q)" or "Aimbot: OFF (Q)"
        fovCircle.Color = config.aimbotEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        print("Aimbot toggled to:", config.aimbotEnabled)
    end
    
    -- Бинд на N (закрыть/открыть GUI) + скрыть/показать FOV круг
    if input.KeyCode == CLOSE_GUI_KEY then
        screenGui.Enabled = not screenGui.Enabled
        -- FOV круг виден ТОЛЬКО когда меню открыто
        fovCircle.Visible = screenGui.Enabled
        print("GUI toggled to:", screenGui.Enabled)
    end
end

UserInputService.InputBegan:Connect(onInputBegan)

-- === ГЛАВНЫЙ ЦИКЛ ===
RunService.RenderStepped:Connect(function()
    local target = getNearestPlayer()
    
    -- Рисуем круг по центру (только если меню открыто)
    if fovCircle.Visible then
        local viewportSize = Camera.ViewportSize
        fovCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
        fovCircle.Radius = config.fovRadius
    end

    -- Аимбот (автоматический) с ВСЕГДА ВКЛЮЧЕННЫМ WallCheck
    if config.aimbotEnabled and target and target.Character and target.Character:FindFirstChild("Head") then
        if canHit(target) then  -- WallCheck всегда true
            local headPos = target.Character.Head.Position
            local camCFrame = Camera.CFrame
            local direction = (headPos - camCFrame.Position).Unit
            Camera.CFrame = camCFrame:Lerp(CFrame.new(camCFrame.Position, camCFrame.Position + direction), config.aimSmoothness)
        end
    end
end)


print("🎯 Q - вкл/выкл аим")
print("📱 N - открыть/закрыть меню (и FOV круг)")
print("👤 ymolishenni")
