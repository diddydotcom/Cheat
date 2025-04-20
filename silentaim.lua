-- // SETTINGS
local Settings = {
    FOV = 150,
    Prediction = 0.135,
    SilentAimEnabled = false,
    AimKey = Enum.KeyCode.E, -- toggle key
}

-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- // INTERNALS
local Connections = {}
local Target = nil

-- // FOV Circle GUI
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

-- // Closest Player Function
local function getClosestPlayerInFOV()
    local closest = nil
    local shortest = Settings.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, visible = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if visible then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if dist <= shortest then
                    shortest = dist
                    closest = player
                end
            end
        end
    end

    return closest
end

-- // Silent Aim Hook
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if method == "FireServer" and tostring(self) == "MainEvent" and Settings.SilentAimEnabled and Target then
        if Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
            local predictedPos = Target.Character.HumanoidRootPart.Position + (Target.Character.HumanoidRootPart.Velocity * Settings.Prediction)
            args[2] = predictedPos
            return oldNamecall(self, unpack(args))
        end
    end

    return oldNamecall(self, ...)
end)

-- // Toggle & Render
table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Settings.AimKey then
        Settings.SilentAimEnabled = not Settings.SilentAimEnabled
        Target = Settings.SilentAimEnabled and getClosestPlayerInFOV() or nil
    end
end))

table.insert(Connections, RunService.RenderStepped:Connect(function()
    fovCircle.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)
    fovCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)

    if Settings.SilentAimEnabled then
        Target = getClosestPlayerInFOV()
    end
end))

-- // Cleanup Function
getgenv().UnloadSilentAim = function()
    for _, conn in pairs(Connections) do
        if conn.Disconnect then conn:Disconnect() end
    end
    if screenGui then screenGui:Destroy() end
    Settings = nil
    Target = nil
    getgenv().UnloadSilentAim = nil
end
