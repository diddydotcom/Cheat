-- // SETTINGS
local Settings = {
    Prediction = 0.135, -- adjust this for ping
    FOV = 150,
    AimPartPriority = {"Head", "UpperTorso", "LowerTorso", "LeftLeg", "RightLeg"},
    SilentAimEnabled = true
}

-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- // GUI Setup
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "SilentAimUI"

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

-- // FOV Circle Follow
RunService.RenderStepped:Connect(function()
    fovCircle.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)
    fovCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
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
