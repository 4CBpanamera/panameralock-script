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
    aimSmoothness = 1, -- Всегда максимум
    fovRadius = 70,
    
    wallCheckAimbot = true,
    teamCheck = true,
    targetList = {}
}

-- === СОЗДАНИЕ ГРАФИЧЕСКОГО ИНТЕРФЕЙСА (GUI) ===
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
screenGui.Enabled = true

-- Главное окно с фоном
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 260)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BackgroundTransparency = 0.4
frame.Parent = screenGui

-- Фиолетовая обводка
local border = Instance.new("Frame")
border.Size = UDim2.new(1, 4, 1, 4)
border.Position = UDim2.new(0, -2, 0, -2)
border.BackgroundTransparency = 1
border.BorderSizePixel = 2
border.BorderColor3 = Color3.fromRGB(148, 0, 211)
border.Parent = frame

-- Фон с картинкой
local imageLabel = Instance.new("ImageLabel")
imageLabel.Size = UDim2.new(1, 0, 1, 0)
imageLabel.Position = UDim2.new(0, 0, 0, 0)
imageLabel.BackgroundTransparency = 1
imageLabel.Image = "rbxassetid://464093673"
imageLabel.ImageTransparency = 0.7
imageLabel.Parent = frame

-- Темный оверлей
local overlay = Instance.new("Frame")
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.Position = UDim2.new(0, 0, 0, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.5
overlay.Parent = frame

-- Кнопка минимизации
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 40, 0, 20)
minimizeButton.Position = UDim2.new(1, -45, 0, 5)
minimizeButton.Text = "_"
minimizeButton.TextColor3 = Color3.fromRGB(255,255,255)
minimizeButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
minimizeButton.ZIndex = 2
minimizeButton.Parent = frame

local minimized = false
minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, child in pairs(frame:GetChildren()) do
        if child ~= minimizeButton then
            child.Visible = not minimized
        end
    end
    frame.Size = minimized and UDim2.new(0, 40, 0, 20) or UDim2.new(0, 250, 0, 260)
end)

local function createButton(name, positionY)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 30)
    button.Position = UDim2.new(0, 5, 0, positionY)
    button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = name
    button.ZIndex = 2
    button.Parent = frame
    return button
end

-- КНОПКИ
local aimbotButton = createButton("Aimbot: OFF (Q)", 30)
local teamCheckButton = createButton("Team Check: ON", 65)
local closeButton = createButton("Close GUI (N)", 100)
local targetListButton = createButton("Target List (Click to open)", 135)

aimbotButton.MouseButton1Click:Connect(function()
    config.aimbotEnabled = not config.aimbotEnabled
    aimbotButton.Text = config.aimbotEnabled and "Aimbot: ON (Q)" or "Aimbot: OFF (Q)"
    fovCircle.Color = config.aimbotEnabled and Color3.fromRGB(148, 0, 211) or Color3.fromRGB(148, 0, 211) -- Всегда фиолетовый
end)

teamCheckButton.MouseButton1Click:Connect(function()
    config.teamCheck = not config.teamCheck
    teamCheckButton.Text = config.teamCheck and "Team Check: ON" or "Team Check: OFF"
end)

closeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

-- === ВЫПАДАЮЩИЙ СПИСОК ИГРОКОВ ===
local targetListFrame = Instance.new("Frame")
targetListFrame.Size = UDim2.new(0, 200, 0, 200)
targetListFrame.Position = UDim2.new(0, 260, 0, 0)
targetListFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
targetListFrame.BackgroundTransparency = 0.1
targetListFrame.Visible = false
targetListFrame.ZIndex = 3
targetListFrame.Parent = frame

local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1, 0, 1, 0)
playerList.Position = UDim2.new(0, 0, 0, 0)
playerList.BackgroundTransparency = 1
playerList.ZIndex = 3
playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
playerList.Parent = targetListFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 2)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = playerList

local function updatePlayerList()
    for _, child in pairs(playerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local players = Players:GetPlayers()
    local canvasHeight = 0
    
    for _, player in pairs(players) do
        if player ~= LocalPlayer then
            local playerButton = Instance.new("TextButton")
            playerButton.Size = UDim2.new(1, -10, 0, 25)
            playerButton.Position = UDim2.new(0, 5, 0, canvasHeight)
            playerButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerButton.TextSize = 14
            playerButton.ZIndex = 4
            
            local isTarget = false
            for _, target in pairs(config.targetList) do
                if target == player then
                    isTarget = true
                    break
                end
            end
            
            playerButton.Text = player.Name .. (isTarget and " ✅" or " ❌")
            playerButton.BackgroundColor3 = isTarget and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 30, 30)
            
            playerButton.MouseButton1Click:Connect(function()
                local found = false
                for i, target in pairs(config.targetList) do
                    if target == player then
                        table.remove(config.targetList, i)
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(config.targetList, player)
                end
                updatePlayerList()
            end)
            
            playerButton.Parent = playerList
            canvasHeight = canvasHeight + 27
        end
    end
    
    playerList.CanvasSize = UDim2.new(0, 0, 0, canvasHeight + 5)
end

targetListButton.MouseButton1Click:Connect(function()
    targetListFrame.Visible = not targetListFrame.Visible
    if targetListFrame.Visible then
        updatePlayerList()
    end
end)

Players.PlayerAdded:Connect(function()
    if targetListFrame.Visible then
        updatePlayerList()
    end
end)

Players.PlayerRemoving:Connect(function(player)
    for i, target in pairs(config.targetList) do
        if target == player then
            table.remove(config.targetList, i)
            break
        end
    end
    if targetListFrame.Visible then
        updatePlayerList()
    end
end)

-- === СЛАЙДЕР FOV (максимум 120) ===
local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(1, -10, 0, 20)
sliderLabel.Position = UDim2.new(0, 5, 0, 170)
sliderLabel.BackgroundTransparency = 1
sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
sliderLabel.Text = "FOV: "..config.fovRadius
sliderLabel.ZIndex = 2
sliderLabel.Parent = frame

local slider = Instance.new("Frame")
slider.Size = UDim2.new(1, -10, 0, 20)
slider.Position = UDim2.new(0, 5, 0, 190)
slider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
slider.ZIndex = 2
slider.Parent = frame

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 10, 1, 0)
knob.Position = UDim2.new(config.fovRadius/120, 0, 0, 0) -- 120 максимум
knob.BackgroundColor3 = Color3.fromRGB(148, 0, 211)
knob.ZIndex = 3
knob.Parent = slider

local dragging = false
local function updateFOV(inputPositionX)
    local mouseX = math.clamp(inputPositionX - slider.AbsolutePosition.X, 0, slider.AbsoluteSize.X)
    config.fovRadius = math.floor((mouseX / slider.AbsoluteSize.X) * 120) -- Максимум 120
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

-- === ТЕКСТ ВНИЗУ ===
local creditText = Instance.new("TextLabel")
creditText.Size = UDim2.new(1, 0, 0, 20)
creditText.Position = UDim2.new(0, 0, 1, -20)
creditText.BackgroundTransparency = 1
creditText.Text = "by panamera XD"
creditText.TextColor3 = Color3.new(1, 1, 1)
creditText.TextScaled = true
creditText.ZIndex = 2
creditText.Parent = frame

-- === СОЗДАНИЕ КРУГА FOV (фиолетовый) ===
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = true
fovCircle.Transparency = 0.3
fovCircle.Color = Color3.fromRGB(148, 0, 211) -- Фиолетовый
fovCircle.Thickness = 2
fovCircle.Radius = config.fovRadius
fovCircle.Filled = false

-- === ФУНКЦИЯ ПОИСКА БЛИЖАЙШЕГО ИГРОКА ===
local function getNearestPlayer()
    local closestPlayer = nil
    local closestMagnitude = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            
            local isInTargetList = false
            if #config.targetList > 0 then
                for _, target in pairs(config.targetList) do
                    if target == player then
                        isInTargetList = true
                        break
                    end
                end
                if not isInTargetList then
                    continue
                end
            end
            
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

-- === ФУНКЦИЯ ПРОВЕРКИ СТЕН ===
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
    
    if input.KeyCode == AIMBOT_KEY then
        config.aimbotEnabled = not config.aimbotEnabled
        aimbotButton.Text = config.aimbotEnabled and "Aimbot: ON (Q)" or "Aimbot: OFF (Q)"
        fovCircle.Color = Color3.fromRGB(148, 0, 211) -- Всегда фиолетовый
        print("Aimbot toggled to:", config.aimbotEnabled)
    end
    
    if input.KeyCode == CLOSE_GUI_KEY then
        screenGui.Enabled = not screenGui.Enabled
        fovCircle.Visible = screenGui.Enabled
        print("GUI toggled to:", screenGui.Enabled)
    end
end

UserInputService.InputBegan:Connect(onInputBegan)

-- === ГЛАВНЫЙ ЦИКЛ ===
RunService.RenderStepped:Connect(function()
    local target = getNearestPlayer()
    
    if fovCircle.Visible then
        local viewportSize = Camera.ViewportSize
        fovCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
        fovCircle.Radius = config.fovRadius
    end

    -- Аимбот с максимальной скоростью (1)
    if config.aimbotEnabled and target and target.Character and target.Character:FindFirstChild("Head") then
        if canHit(target) then
            local headPos = target.Character.Head.Position
            local camCFrame = Camera.CFrame
            local direction = (headPos - camCFrame.Position).Unit
            Camera.CFrame = CFrame.new(camCFrame.Position, camCFrame.Position + direction) -- Мгновенное наведение
        end
    end
end)
