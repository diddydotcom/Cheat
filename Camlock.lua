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

-- // VARS
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local Target = nil

-- // FOV CIRCLE (Drawing API)
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Thickness = 1.5
FOV_Circle.NumSides = 64
FOV_Circle.Radius = Settings.FOV
FOV_Circle.Filled = false
FOV_Circle.Color = Color3.fromRGB(255, 255, 255)
FOV_Circle.Transparency = 0.75

-- // GET CLOSET PLAYER IN FOV
local function getClosestInFOV()
    local closestPlayer = nil
    local shortestDistance = Settings.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if dist <= Settings.FOV and dist < shortestDistance then
                    shortestDistance = dist
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

-- // TOGGLE INPUT
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Settings.AimKey then
        Settings.Aiming = not Settings.Aiming
        if Settings.Aiming then
            Target = getClosestInFOV()
        else
            Target = nil
        end
    end
end)

-- // RENDER LOOP
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle Position
    FOV_Circle.Position = Vector2.new(Mouse.X, Mouse.Y)
    FOV_Circle.Radius = Settings.FOV
    FOV_Circle.Visible = true

    -- Aim if active
    if Settings.Aiming and Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Target.Character.HumanoidRootPart
        local predictedPos = hrp.Position + (hrp.Velocity * Settings.Prediction)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
    end
end)
