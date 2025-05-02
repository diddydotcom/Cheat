local a = true
local b = Enum.KeyCode.H
local c = game:GetService("Players").LocalPlayer:GetMouse()
local d = game:GetService("RunService")
local e = game:GetService("Players")
local f = game:GetService("UserInputService")

d.RenderStepped:Connect(function()
    local g = c.Target
    if g and g.Parent then
        local h = g.Parent:FindFirstChildOfClass("Humanoid")
        local i = e:GetPlayerFromCharacter(g.Parent)
        if h and h.Health > 0 and i and i.Team ~= e.LocalPlayer.Team and a then
            mouse1press()
            repeat
                d.RenderStepped:Wait()
            until not g.Parent:FindFirstChildOfClass("Humanoid")
            mouse1release()
        end
    end
end)

f.InputBegan:Connect(function(j, k)
    if j.KeyCode == b then
        a = not a
        local l = Instance.new("Hint", game.CoreGui)
        l.Text = "Toggled: " .. tostring(a)
        wait(1.5)
        l:Destroy()
    end
end)
