-- SETTINGS
local AutoTrigger = true -- true = always on, false = hold right-click to trigger
local RequireToolEquipped = true -- only fire if holding a gun/tool
local Cooldown = 0.05 -- seconds between clicks
local TargetParts = { "Head", "UpperTorso", "Torso" }

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- VARS
local CanShoot = true
local TriggerHeld = false

-- INPUT (Right click to hold trigger)
UserInputService.InputBegan:Connect(function(input, gpe)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		TriggerHeld = true
	end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		TriggerHeld = false
	end
end)

-- UTILITY: Is mouse over valid player part?
local function isOnValidTarget()
	local target = Mouse.Target
	if not target or not target.Parent then return false end

	local model = target:FindFirstAncestorOfClass("Model")
	local player = Players:GetPlayerFromCharacter(model)
	if not player or player == LocalPlayer then return false end

	for _, part in pairs(TargetParts) do
		if target.Name == part then
			return true
		end
	end

	return false
end

-- FIRE FUNCTION
local function fireClick()
	mouse1press()
	task.wait(0.025)
	mouse1release()
end

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
	if not CanShoot then return end
	if not AutoTrigger and not TriggerHeld then return end

	if isOnValidTarget() then
		if RequireToolEquipped then
			local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
			if not tool then return end
		end

		CanShoot = false
		fireClick()
		task.delay(Cooldown, function()
			CanShoot = true
		end)
	end
end)
