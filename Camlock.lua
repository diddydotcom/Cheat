-- // SETTINGS
local prediction = 0.165 -- Tweak this depending on ping
local aimKey = Enum.KeyCode.Q -- Camlock toggle key

-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- // VARIABLES
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local Aiming = false
local Target = nil

-- // FUNCTIONS
function getClosestToMouse()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).magnitude

            if dist < shortestDistance then
                closestPlayer = player
                shortestDistance = dist
            end
        end
    end

    return closestPlayer
end

-- // INPUT
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == aimKey then
        Aiming = not Aiming
        Target = getClosestToMouse()
    end
end)

-- // AIM LOOP
RunService.RenderStepped:Connect(function()
    if Aiming and Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Target.Character.HumanoidRootPart
        local predictedPosition = hrp.Position + (hrp.Velocity * prediction)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPosition)
    end
end)
