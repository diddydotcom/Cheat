-- // SETTINGS
local Settings = {
    TriggerKey = Enum.UserInputType.MouseButton2, -- Right-click to activate (optional)
    AutoTrigger = true, -- If false, only works while holding TriggerKey
    Cooldown = 0.1, -- Delay between shots (adjust for faster shooting)
    TargetParts = { "Head", "UpperTorso", "Torso" }, -- Valid hit parts
    RequireToolEquipped = true, -- Only trigger when holding tool (like a gun)
    TeamCheck = true, -- Ignore players on the same team
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

-- // INPUT HANDLING (For Mouse Button2)
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

-- // FUNCTION: Check if the target is valid
local function isValidTarget(target)
    if not target or not target.Parent then return false end
    local player = Players:GetPlayerFromCharacter(target.Parent)
    
    -- Ensure it's a valid player and not the LocalPlayer
    if not player or player == LocalPlayer then return false end
    
    -- Team check (ignore team members)
    if Settings.TeamCheck and player.Team == LocalPlayer.Team then return false end

    -- Check if the part is a valid target (head, torso, etc.)
    for _, partName in pairs(Settings.TargetParts) do
        if target.Name == partName then
            return true
        end
    end

    return false
end

-- // FUNCTION: Simulate a mouse click to trigger shooting
local function triggerShot()
    -- Simulating a left-click with mouse1press
    mouse1press()
    task.wait(0.05)
    mouse1release()
end

-- // LOOP: Runs continuously while the game is active
RunService.RenderStepped:Connect(function()
    -- Only work if AutoTrigger is true or the right mouse button is held down
    if not Settings.AutoTrigger and not HoldingTrigger then return end
    if not CanShoot then return end

    -- Check the target under the mouse
    local target = Mouse.Target
    if isValidTarget(target) then
        -- Check if the player is holding a tool (like a gun)
        if Settings.RequireToolEquipped then
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if not tool then return end
        end

        -- Trigger the shot
        CanShoot = false
        triggerShot()
        task.delay(Settings.Cooldown, function()
            CanShoot = true
        end)
    end
end)
