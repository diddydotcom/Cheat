-- // SETTINGS
local Settings = {
    Prediction = 0.135, -- adjust this for ping
    FOV = 150,  -- Initial FOV
    FOVMin = 50,  -- Minimum FOV size
    FOVMax = 200,  -- Maximum FOV size
    FOVRainbow = false,  -- Toggle rainbow FOV effect
    AimPartPriority = {"Head", "UpperTorso", "LowerTorso", "LeftLeg", "RightLeg"},
    SilentAimEnabled = true
}

-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

-- // GUI Setup
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "SilentAimUI"

-- FOV Circle
local fovCircle = Instance.new("Frame", screenGui)
fovCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
fovCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fovCircle.BackgroundTransparency = 0.85
fovCircle.BorderSizePixel = 0
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)

local corner = Instance.new("UICorner", fovCircle)
corner.CornerRadius = UDim.new(1, 0)

-- // Get Closest Valid Body Part In FOV
local function getClosestTarget()
    local closest = nil
    local shortest = Settings.FOV
    local targetPart = nil

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            for _, partName in ipairs(Settings.AimPartPriority) do
                local part = player.Character:FindFirstChild(partName)
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                        if dist < shortest then
                            closest = player
                            targetPart = part
                            shortest = dist
                        end
                    end
                end
            end
        end
    end

    return closest, targetPart
end

-- // FOV Circle Follow with FOV Slider
RunService.RenderStepped:Connect(function()
    fovCircle.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)
    fovCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)

    -- Rainbow FOV Effect
    if Settings.FOVRainbow then
        local hue = tick() % 5 / 5  -- Changes color over time
        fovCircle.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
    else
        fovCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  -- Default color (White)
    end
end)

-- // Silent Aim Hook
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if method == "FireServer" and tostring(self) == "MainEvent" and Settings.SilentAimEnabled then
        local target, part = getClosestTarget()
        if target and part then
            local predicted = part.Position + (part.Velocity * Settings.Prediction)
            args[2] = predicted
            return oldNamecall(self, unpack(args))
        end
    end

    return oldNamecall(self, ...)
end)

-- // Main Menu: FOV Slider
local fovSlider = Instance.new("Slider", screenGui)  -- Assuming you are using a GUI system to adjust FOV
fovSlider.MinValue = Settings.FOVMin
fovSlider.MaxValue = Settings.FOVMax
fovSlider.Value = Settings.FOV
fovSlider.OnValueChanged:Connect(function(newValue)
    Settings.FOV = newValue  -- Adjusts FOV based on slider value
end)

-- // Main Menu: Rainbow Toggle
local rainbowToggle = Instance.new("TextButton", screenGui)  -- Assuming this is a button to toggle rainbow effect
rainbowToggle.Text = "Toggle Rainbow FOV"
rainbowToggle.Position = UDim2.new(0, 0, 0, 50)  -- Adjust this position as needed
rainbowToggle.Size = UDim2.new(0, 200, 0, 50)
rainbowToggle.MouseButton1Click:Connect(function()
    Settings.FOVRainbow = not Settings.FOVRainbow
    rainbowToggle.Text = Settings.FOVRainbow and "Rainbow FOV: ON" or "Rainbow FOV: OFF"
end)

-- // Silent Aim GUI Controls (Optional)
local silentAimToggle = Instance.new("TextButton", screenGui)  -- Toggle to enable/disable Silent Aim
silentAimToggle.Text = "Toggle Silent Aim"
silentAimToggle.Position = UDim2.new(0, 0, 0, 100)
silentAimToggle.Size = UDim2.new(0, 200, 0, 50)
silentAimToggle.MouseButton1Click:Connect(function()
    Settings.SilentAimEnabled = not Settings.SilentAimEnabled
    silentAimToggle.Text = Settings.SilentAimEnabled and "Silent Aim: ON" or "Silent Aim: OFF"
end)
