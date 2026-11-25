-- ============================================
-- THROW A SPEAR FOR FISH
-- Training + Upgrade (100s) + Auto Farm (Throw+Store+TP) + Anti-AFK
-- + GUI Anti-Hide (Cinematic)
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

-- ===== WAIT REMOTES =====
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
if not Remotes then
    warn("[SpearFish] Remotes folder tidak ditemukan!")
    return
end

local PullUpTap = Remotes:WaitForChild("PullUpTap", 30)
local UpgradePullUp = Remotes:WaitForChild("UpgradePullUp", 30)
local Throw = Remotes:WaitForChild("Throw", 30)
local HeldAction = Remotes:WaitForChild("HeldAction", 30)

if not PullUpTap or not UpgradePullUp or not Throw or not HeldAction then
    warn("[SpearFish] Salah satu remote tidak ditemukan!")
    return
end

-- ===== LOW FX (boost performa) =====
pcall(function()
    player:SetAttribute("Setting_LowFx", true)
    _G.LowFx = true
end)

-- ===== ANTI AFK (backend) =====
task.spawn(function()
    while true do
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        task.wait(60)
    end
end)

-- ===== STATE =====
local autoTraining = false
local autoUpgrade = false
local autoThrow = false
local autoStore = false
local autoTP = false

local trainingLoop = nil
local upgradeLoop = nil
local throwLoop = nil
local storeLoop = nil
local tpLoop = nil
local tpIndex = 1

-- ===== SETTINGS =====
local TRAINING_DELAY = 0.1
local UPGRADE_DELAY = 100
local THROW_DELAY = 0.2
local THROW_POWER = 0.8943486253265291
local STORE_DELAY = 0.2
local TP_POSITIONS = {
    Vector3.new(10, 8, -27),
    Vector3.new(12, 7, -13),
}
local TP_DELAY = 0.01

-- ===== AUTO TRAINING =====
local function StartAutoTraining()
    if trainingLoop then return end
    autoTraining = true
    trainingLoop = task.spawn(function()
        while autoTraining do
            pcall(function() PullUpTap:FireServer() end)
            pcall(function() PullUpTap:FireServer("bubble") end)
            task.wait(TRAINING_DELAY)
        end
        trainingLoop = nil
    end)
end

local function StopAutoTraining()
    autoTraining = false
    trainingLoop = nil
end

-- ===== AUTO UPGRADE PULL (100s) =====
local function StartAutoUpgrade()
    if upgradeLoop then return end
    autoUpgrade = true
    upgradeLoop = task.spawn(function()
        while autoUpgrade do
            pcall(function() UpgradePullUp:InvokeServer() end)
            local elapsed = 0
            while autoUpgrade and elapsed < UPGRADE_DELAY do
                task.wait(0.5)
                elapsed = elapsed + 0.5
            end
        end
        upgradeLoop = nil
    end)
end

local function StopAutoUpgrade()
    autoUpgrade = false
    upgradeLoop = nil
end

-- ===== AUTO FARM (Throw + Store + TP) =====
local function StartAutoFarm()
    if not throwLoop then
        autoThrow = true
        throwLoop = task.spawn(function()
            while autoThrow do
                pcall(function()
                    Throw:InvokeServer(THROW_POWER)
                end)
                task.wait(THROW_DELAY)
            end
            throwLoop = nil
        end)
    end

    if not storeLoop then
        autoStore = true
        storeLoop = task.spawn(function()
            while autoStore do
                pcall(function()
                    HeldAction:InvokeServer("store")
                end)
                task.wait(STORE_DELAY)
            end
            storeLoop = nil
        end)
    end

    if not tpLoop then
        autoTP = true
        tpIndex = 1
        tpLoop = task.spawn(function()
            while autoTP do
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local pos = TP_POSITIONS[tpIndex]
                    pcall(function()
                        hrp.CFrame = CFrame.new(pos)
                    end)
                    tpIndex = tpIndex % #TP_POSITIONS + 1
                end
                task.wait(TP_DELAY)
            end
            tpLoop = nil
        end)
    end
end

local function StopAutoFarm()
    autoThrow = false
    autoStore = false
    autoTP = false
    throwLoop = nil
    storeLoop = nil
    tpLoop = nil
end

-- ===== GUI =====
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("SpearFish_Auto")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpearFish_Auto"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 🔥 ANTI-HIDE: set attribute Cinematic biar tidak disembunyikan HudVisibility
pcall(function()
    screenGui:SetAttribute("Cinematic", true)
end)

screenGui.Parent = playerGui

-- Bubble
local bubble = Instance.new("TextButton")
bubble.Size = UDim2.new(0, 55, 0, 55)
bubble.Position = UDim2.new(0, 20, 0.5, -27)
bubble.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
bubble.Text = "S"
bubble.TextColor3 = Color3.fromRGB(255, 255, 255)
bubble.TextScaled = true
bubble.Font = Enum.Font.FredokaOne
bubble.BorderSizePixel = 0
bubble.Visible = false
bubble.ZIndex = 200
bubble.Parent = screenGui

local bc = Instance.new("UICorner", bubble)
bc.CornerRadius = UDim.new(1, 0)

-- Main
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 240, 0, 200)
Main.Position = UDim2.new(0.5, -120, 0.5, -100)
Main.BackgroundColor3 = Color3.fromRGB(25, 22, 40)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(255, 180, 0)
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true
Main.ZIndex = 100
Main.Parent = screenGui

local mc = Instance.new("UICorner", Main)
mc.CornerRadius = UDim.new(0, 10)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
Header.BorderSizePixel = 0
Header.ZIndex = 101
Header.Parent = Main

local hc = Instance.new("UICorner", Header)
hc.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "THROW A SPEAR FOR FISH"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.FredokaOne
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 102
Title.Parent = Header

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 26, 0, 26)
MinBtn.Position = UDim2.new(1, -60, 0, 4)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 55, 80)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.BorderSizePixel = 0
MinBtn.ZIndex = 103
MinBtn.Parent = Header

local minc = Instance.new("UICorner", MinBtn)
minc.CornerRadius = UDim.new(0, 5)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -32, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 103
CloseBtn.Parent = Header

local cc = Instance.new("UICorner", CloseBtn)
cc.CornerRadius = UDim.new(0, 5)

-- ===== TOGGLE CREATOR =====
local function CreateToggle(name, yPos, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 42)
    frame.Position = UDim2.new(0, 8, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(35, 30, 55)
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(60, 55, 80)
    frame.ZIndex = 101
    frame.Parent = Main

    local fc = Instance.new("UICorner", frame)
    fc.CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -90, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.Font = Enum.Font.FredokaOne
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 102
    label.Parent = frame

    local switchBg = Instance.new("TextButton")
    switchBg.Size = UDim2.new(0, 60, 0, 26)
    switchBg.Position = UDim2.new(1, -70, 0.5, -13)
    switchBg.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
    switchBg.BorderSizePixel = 2
    switchBg.BorderColor3 = Color3.fromRGB(150, 150, 160)
    switchBg.Text = ""
    switchBg.AutoButtonColor = false
    switchBg.ZIndex = 105
    switchBg.Parent = frame

    local sc = Instance.new("UICorner", switchBg)
    sc.CornerRadius = UDim.new(0, 13)

    local offLabel = Instance.new("TextLabel")
    offLabel.Size = UDim2.new(0, 24, 1, 0)
    offLabel.Position = UDim2.new(0, 4, 0, 0)
    offLabel.BackgroundTransparency = 1
    offLabel.Text = "OFF"
    offLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    offLabel.Font = Enum.Font.FredokaOne
    offLabel.TextSize = 8
    offLabel.ZIndex = 106
    offLabel.Parent = switchBg

    local onLabel = Instance.new("TextLabel")
    onLabel.Size = UDim2.new(0, 24, 1, 0)
    onLabel.Position = UDim2.new(1, -28, 0, 0)
    onLabel.BackgroundTransparency = 1
    onLabel.Text = "ON"
    onLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    onLabel.Font = Enum.Font.FredokaOne
    onLabel.TextSize = 8
    onLabel.ZIndex = 106
    onLabel.Parent = switchBg

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = UDim2.new(0, 2, 0.5, -11)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Text = ""
    knob.AutoButtonColor = false
    knob.ZIndex = 110
    knob.Parent = switchBg

    local kc = Instance.new("UICorner", knob)
    kc.CornerRadius = UDim.new(1, 0)

    local state = false

    local function UpdateVisual(isOn)
        local targetPos = isOn and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
        TweenService:Create(knob, TweenInfo.new(0.15), {Position = targetPos}):Play()

        if isOn then
            switchBg.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
            switchBg.BorderColor3 = Color3.fromRGB(255, 180, 0)
            offLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
            onLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            switchBg.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
            switchBg.BorderColor3 = Color3.fromRGB(150, 150, 160)
            offLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            onLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
        end
    end

    local function DoToggle()
        state = not state
        UpdateVisual(state)
        if callback then
            pcall(callback, state)
        end
    end

    knob.MouseButton1Click:Connect(DoToggle)
    switchBg.MouseButton1Click:Connect(DoToggle)

    UpdateVisual(false)
end

CreateToggle("AUTO TRAINING", 42, function(on)
    if on then StartAutoTraining() else StopAutoTraining() end
end)

CreateToggle("AUTO UPGRADE PULL", 90, function(on)
    if on then StartAutoUpgrade() else StopAutoUpgrade() end
end)

CreateToggle("AUTO FARM", 138, function(on)
    if on then StartAutoFarm() else StopAutoFarm() end
end)

-- ===== MINIMIZE =====
local function ToggleMinimize()
    Main.Visible = not Main.Visible
    bubble.Visible = not Main.Visible
end

MinBtn.MouseButton1Click:Connect(ToggleMinimize)
bubble.MouseButton1Click:Connect(ToggleMinimize)

CloseBtn.MouseButton1Click:Connect(function()
    StopAutoTraining()
    StopAutoUpgrade()
    StopAutoFarm()
    screenGui:Destroy()
end)

-- Bubble drag
local isDragging = false
local dragStart = Vector2.new()
local bubbleStartPos = UDim2.new()

bubble.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
        dragStart = input.Position
        bubbleStartPos = bubble.Position
    end
end)

bubble.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        if (input.Position - dragStart).Magnitude > 15 then
            isDragging = true
            local delta = input.Position - dragStart
            local screenSize = workspace.CurrentCamera.ViewportSize
            local newX = math.clamp(bubbleStartPos.X.Offset + delta.X, 0, screenSize.X - 55)
            local newY = math.clamp(bubbleStartPos.Y.Offset + delta.Y, 0, screenSize.Y - 55)
            bubble.Position = UDim2.new(0, newX, 0, newY)
        end
    end
end)

bubble.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

print("[SpearFish] Loaded OK - Training + Upgrade(100s) + AutoFarm(Throw+Store+TP) + AntiAFK + LowFx + Anti-Hide")