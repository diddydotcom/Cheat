-- // SETTINGS
local settings = {
    showBoxes = true,
    showNames = true,
    showDistance = true,
    colorByTeam = false,
    customColor = Color3.fromRGB(0, 255, 0),
    textureEnabled = false,
    updateRate = 0.05
}

-- // SERVICES
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera

-- // ESP VARIABLES
local drawings = {}
local updateConnection -- will hold the RenderStepped connection

-- // UTILITY FUNCTIONS
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

-- // CREATE ESP
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

-- // UPDATE ESP
local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not drawings[player] then
                createESP(player)
            end

            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local color = getColor(player)
            local dist = getDistance(hrp.Position)

            local box = drawings[player].Box
            local nameText = drawings[player].Name
            local distanceText = drawings[player].Distance

            if onScreen then
                local scale = 1 / (hrp.Position - Camera.CFrame.Position).Magnitude * 100
                local boxSize = Vector2.new(30 * scale, 60 * scale)

                if settings.showBoxes then
                    box.Position = Vector2.new(screenPos.X - boxSize.X / 2, screenPos.Y - boxSize.Y / 2)
                    box.Size = boxSize
                    box.Color = color
                    box.Visible = true
                else
                    box.Visible = false
                end

                if settings.showNames then
                    nameText.Text = player.Name
                    nameText.Position = Vector2.new(screenPos.X, screenPos.Y - boxSize.Y / 2 - 15)
                    nameText.Color = color
                    nameText.Visible = true
                else
                    nameText.Visible = false
                end

                if settings.showDistance then
                    distanceText.Text = "[" .. tostring(dist) .. "m]"
                    distanceText.Position = Vector2.new(screenPos.X, screenPos.Y + boxSize.Y / 2 + 5)
                    distanceText.Color = color
                    distanceText.Visible = true
                else
                    distanceText.Visible = false
                end

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

-- // CLEANUP ON PLAYER LEAVE
Players.PlayerRemoving:Connect(function(player)
    if drawings[player] then
        for _, obj in pairs(drawings[player]) do
            if typeof(obj) == "Drawing" then
                obj:Remove()
            end
        end
        drawings[player] = nil
    end
end)

-- // UNLOAD FUNCTION
getgenv().ESPUnload = function()
    if updateConnection then
        updateConnection:Disconnect()
        updateConnection = nil
    end

    for _, d in pairs(drawings) do
        for _, obj in pairs(d) do
            if typeof(obj) == "Drawing" then
                obj:Remove()
            end
        end
    end
    drawings = {}
    print("✅ ESP completely unloaded.")
end

-- // START THE LOOP
updateConnection = RunService.RenderStepped:Connect(updateESP)

print("✅ ESP Loaded with full unload support")
