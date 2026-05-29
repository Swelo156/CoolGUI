-- CoolGUI Nuke v2.1
print("✅ CoolGUI Nuke v2.1 LOADED - You are NOT cool")

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "CoolGUI",
    Text = "Nuke Loaded! Press F for Fly | Silent Aim + ESP Active",
    Duration = 8
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local FlyEnabled = false
local FlySpeed = 70

-- Fly
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        FlyEnabled = not FlyEnabled
        print("🛫 Fly:", FlyEnabled and "ENABLED" or "DISABLED")
    end
end)

RunService.RenderStepped:Connect(function()
    if FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local cam = Camera.CFrame
        local move = Vector3.new()

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.RightVector end

        hrp.Velocity = move * FlySpeed
    end
end)

-- Speed
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 150
    end
end)

print("Press F to toggle Fly")
