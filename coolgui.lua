-- CoolGUI Nuke v3 - you_arecool
print("✅ CoolGUI Nuke v3 LOADED")

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "CoolGUI",
    Text = "v3 Loaded | F = Fly | You are NOT cool",
    Duration = 6
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Settings = {
    Fly = false,
    FlySpeed = 80,
    WalkSpeed = 150,
    JumpPower = 250,
    SilentAim = true,
    AimFOV = 160,
    ESP = true
}

-- Fullbright
Lighting.Brightness = 3
Lighting.ClockTime = 14
Lighting.FogEnd = 100000

-- Speed & Jump
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
        LocalPlayer.Character.Humanoid.JumpPower = Settings.JumpPower
    end
end)

-- Fly
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        Settings.Fly = not Settings.Fly
        print("🛫 Fly:", Settings.Fly and "ON" or "OFF")
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local cam = Camera.CFrame
        local move = Vector3.new()

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.RightVector end

        hrp.Velocity = move * Settings.FlySpeed
    end
end)

print("CoolGUI v3 ready. Press F for Fly.")
