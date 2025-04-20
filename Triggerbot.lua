-- // SETTINGS
local Settings = {
    TriggerKey = Enum.UserInputType.MouseButton2, -- Hold Right Click to activate (optional)
    AutoTrigger = true, -- If false, only works while holding TriggerKey
    Cooldown = 0.1, -- Delay between shots
    TargetParts = { "Head", "UpperTorso", "Torso" }, -- Hit parts
    RequireToolEquipped = true, -- Only trigger when holding tool (like a gun)
    TeamCheck = false, -- Ignore players on the same team
}

-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- // VARS
local CanShoot = true
local HoldingTrigger = false

-- // INPUT HANDLING
UserInputService.InputBegan:Connect(function(input, gpe)
    if input.UserInputType == Settings.TriggerKey then
        HoldingTrigger = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if input.UserInputType == Settings.TriggerKey then
        HoldingTrigger = false
    end
end)

-- // FUNCTION: Is valid target under mouse?
local function isValidTarget(target)
    if not target or not target.Parent then return false end
    local player = Players:GetPlayerFromCharacter(target.Parent)
    if not player or player == LocalPlayer then return false end

    if Settings.TeamCheck and player.Team == LocalPlayer.Team then return false end

    for _, partName in pairs(Settings.TargetParts) do
        if target.Name == partName then
            return true
        end
    end

    return false
end

-- // FUNCTION: Fire click
local function triggerShot()
    mouse1press()
    task.wait(0.05)
    mouse1release()
end

-- // LOOP
RunService.RenderStepped:Connect(function()
    if not Settings.AutoTrigger and not HoldingTrigger then return end
    if not CanShoot then return end

    local target = Mouse.Target
    if isValidTarget(target) then
        if Settings.RequireToolEquipped then
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if not tool then return end
        end

        CanShoot = false
        triggerShot()
        task.delay(Settings.Cooldown, function()
            CanShoot = true
        end)
    end
end)
