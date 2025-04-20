-- // CONFIG
local Settings = {
    Prediction = 0.155,
    FOV = 150,
    AimKey = Enum.KeyCode.Q,
    Aiming = false,
}

-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

-- // VARS
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local Target = nil

-- // GUI
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "CamlockUI"

-- FOV Circle
local fovCircle = Instance.new("Frame", screenGui)
fovCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
fovCircle.Position = UDim2.new(0, Mouse.X - Settings.FOV, 0, Mouse.Y - Settings.FOV)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 0

local fovUI = Instance.new("UIStroke", fovCircle)
fovUI.Thickness = 1
fovUI.Color = Color3.new(1, 1, 1)

-- // SLIDERS
local function makeSlider(name, min, max, default, callback)
    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 200, 0, 25)
    frame.Position = UDim2.new(0, 20, 0, name == "Prediction" and 80 or 50)
    frame.BackgroundTransparency = 0.3
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Name = name

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1

    local slider = Instance.new("TextBox", frame)
    slider.Size = UDim2.new(0.6, 0, 1, 0)
    slider.Position = UDim2.new(0.4, 0, 0, 0)
    slider.Text = tostring(default)
    slider.TextColor3 = Color3.new(1, 1, 1)
    slider.BackgroundTransparency = 1
    slider.ClearTextOnFocus = false

    slider.FocusLost:Connect(function()
        local value = tonumber(slider.Text)
        if value then
            value = math.clamp(value, min, max)
            callback(value)
        end
    end)
end

makeSlider("FOV", 50, 400, Settings.FOV, function(val)
    Settings.FOV = val
    fovCircle.Size = UDim2.new(0, val * 2, 0, val * 2)
end)

makeSlider("Prediction", 0.05, 0.35, Settings.Prediction, function(val)
    Settings.Prediction = val
end)

-- // FUNCTIONS
local function getClosestPlayer()
    local closest, dist = nil, Settings.FOV
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).magnitude
                if mag < dist then
                    dist = mag
                    closest = plr
                end
            end
        end
    end
    return closest
end

-- // INPUT
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Settings.AimKey then
        Settings.Aiming = not Settings.Aiming
        if Settings.Aiming then
            Target = getClosestPlayer()
        else
            Target = nil
        end
    end
end)

-- // AIM LOOP
RunService.RenderStepped:Connect(function()
    -- Update FOV circle position
    fovCircle.Position = UDim2.new(0, Mouse.X - Settings.FOV, 0, Mouse.Y - Settings.FOV)

    if Settings.Aiming and Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Target.Character.HumanoidRootPart
        local predictedPos = hrp.Position + (hrp.Velocity * Settings.Prediction)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
    end
end)
