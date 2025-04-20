-- // SETTINGS
local Settings = {
    Prediction = 0.155,
    FOV = 150,
    Aiming = false,
    AimKey = Enum.KeyCode.Q,
}

-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local Target = nil

-- // GUI SETUP
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "CamlockUI"

-- FOV Circle (using UICorner for perfect circle)
local fovCircle = Instance.new("Frame", screenGui)
fovCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
fovCircle.BackgroundColor3 = Color3.new(1, 1, 1)
fovCircle.BackgroundTransparency = 0.85
fovCircle.BorderSizePixel = 0
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)

local corner = Instance.new("UICorner", fovCircle)
corner.CornerRadius = UDim.new(1, 0) -- makes it a circle

-- // SLIDER GENERATOR
local function createSlider(name, min, max, default, posY, callback)
    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 200, 0, 25)
    frame.Position = UDim2.new(0, 20, 0, posY)
    frame.BackgroundTransparency = 0.2
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1

    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(0.6, 0, 1, 0)
    input.Position = UDim2.new(0.4, 0, 0, 0)
    input.Text = tostring(default)
    input.TextColor3 = Color3.new(1, 1, 1)
    input.BackgroundTransparency = 1
    input.ClearTextOnFocus = false

    input.FocusLost:Connect(function()
        local val = tonumber(input.Text)
        if val then
            val = math.clamp(val, min, max)
            callback(val)
        end
    end)
end

-- // Sliders
createSlider("FOV", 50, 400, Settings.FOV, 50, function(val)
    Settings.FOV = val
    fovCircle.Size = UDim2.new(0, val * 2, 0, val * 2)
end)

createSlider("Prediction", 0.05, 0.35, Settings.Prediction, 80, function(val)
    Settings.Prediction = val
end)

-- // Get Closest in FOV
local function getClosestPlayerInFOV()
    local closestPlayer = nil
    local shortestDistance = Settings.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if dist <= Settings.FOV and dist < shortestDistance then
                    shortestDistance = dist
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

-- // Toggle Aiming
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Settings.AimKey then
        Settings.Aiming = not Settings.Aiming
        Target = Settings.Aiming and getClosestPlayerInFOV() or nil
    end
end)

-- // Aim + FOV Position Update
RunService.RenderStepped:Connect(function()
    fovCircle.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)
    fovCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)

    if Settings.Aiming and Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Target.Character.HumanoidRootPart
        local predicted = hrp.Position + (hrp.Velocity * Settings.Prediction)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, predicted)
    end
end)
