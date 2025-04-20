-- Da Hood ESP by ChatGPT (2025 Edition)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ⚙️ Settings
local settings = {
    showBoxes = true,
    showNames = true,
    showDistance = true,
    colorByTeam = false,
    customColor = Color3.fromRGB(0, 255, 0),
    textureEnabled = false,
    updateRate = 0.05
}

-- 🧠 Utility Functions
local function getDistance(pos)
    return (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and
        math.floor((LocalPlayer.Character.HumanoidRootPart.Position - pos).Magnitude) or 0
end

local function getColor(player)
    if settings.colorByTeam and player.Team then
        return player.TeamColor.Color
    else
        return settings.customColor
    end
end

-- 🧩 ESP Container
local drawings = {}

local function clearESP()
    -- Clear ESP drawings from memory
    for _, d in pairs(drawings) do
        for _, obj in pairs(d) do
            if typeof(obj) == "Instance" or typeof(obj) == "table" then
                pcall(function() obj:Remove() end)
            elseif typeof(obj) == "Drawing" then
                obj:Remove()
            end
        end
    end
    drawings = {} -- Reset the ESP container
end

local function createESP(player)
    if player == LocalPlayer then return end
    local box = Drawing.new("Square")
    local nameText = Drawing.new("Text")
    local distanceText = Drawing.new("Text")

    box.Thickness = 1
    box.Transparency = 1
    box.Filled = false

    nameText.Size = 13
    nameText.Center = true
    nameText.Outline = true

    distanceText.Size = 13
    distanceText.Center = true
    distanceText.Outline = true

    drawings[player] = {Box = box, Name = nameText, Distance = distanceText}
end

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not drawings[player] then
                createESP(player)
            end

            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")

            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
            local color = getColor(player)
            local dist = getDistance(hrp.Position)

            local box = drawings[player].Box
            local nameText = drawings[player].Name
            local distanceText = drawings[player].Distance

            if onScreen then
                local scale = 1 / (hrp.Position - workspace.CurrentCamera.CFrame.Position).Magnitude * 100
                local boxSize = Vector2.new(30 * scale, 60 * scale)

                -- 📦 Box
                if settings.showBoxes then
                    box.Position = Vector2.new(screenPos.X - boxSize.X / 2, screenPos.Y - boxSize.Y / 2)
                    box.Size = boxSize
                    box.Color = color
                    box.Visible = true
                else
                    box.Visible = false
                end

                -- 🧍 Name
                if settings.showNames then
                    nameText.Text = player.Name
                    nameText.Position = Vector2.new(screenPos.X, screenPos.Y - boxSize.Y / 2 - 15)
                    nameText.Color = color
                    nameText.Visible = true
                else
                    nameText.Visible = false
                end

                -- 📏 Distance
                if settings.showDistance then
                    distanceText.Text = "[" .. tostring(dist) .. "m]"
                    distanceText.Position = Vector2.new(screenPos.X, screenPos.Y + boxSize.Y / 2 + 5)
                    distanceText.Color = color
                    distanceText.Visible = true
                else
                    distanceText.Visible = false
                end

                -- 🎨 Texturing (Optional visual effects)
                if settings.textureEnabled and char:FindFirstChildOfClass("Humanoid") then
                    for _, part in pairs(char:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Color = color
                        end
                    end
                end
            else
                box.Visible = false
                nameText.Visible = false
                distanceText.Visible = false
            end
        elseif drawings[player] then
            for _, obj in pairs(drawings[player]) do
                obj.Visible = false
            end
        end
    end
end

-- 🌀 ESP Loop
RunService.RenderStepped:Connect(function()
    updateESP()
end)

-- 🧼 Clean up on leave
Players.PlayerRemoving:Connect(function(player)
    if drawings[player] then
        for _, obj in pairs(drawings[player]) do
            obj:Remove()
        end
        drawings[player] = nil
    end
end)

-- ESP Toggle Handler (to clear when toggled off)
local ESPEnabled = false
local function toggleESP()
    ESPEnabled = not ESPEnabled
    if ESPEnabled then
        print("✅ ESP Loaded")
        -- Optionally, start drawing and checking
        RunService.RenderStepped:Connect(updateESP)
    else
        print("❌ ESP Unloaded")
        clearESP() -- Completely clear all ESP drawings and reset
    end
end

-- Example of how you might use it with a GUI or key press toggle:
-- toggleESP() -- Call this function when you want to toggle the ESP on/off.
