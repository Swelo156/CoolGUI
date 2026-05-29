-- CoolGUI Simple Test v6
print("✅ CoolGUI Test v6 Loaded")

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "CoolGUI",
    Text = "Script loaded! Press RightShift",
    Duration = 10
})

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local FlyEnabled = false

-- Simple UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.Visible = false
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Title.Text = "COOLGUI"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Parent = Frame

local FlyButton = Instance.new("TextButton")
FlyButton.Size = UDim2.new(0.8, 0, 0, 50)
FlyButton.Position = UDim2.new(0.1, 0, 0.4, 0)
FlyButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
FlyButton.Text = "Fly: OFF"
FlyButton.TextColor3 = Color3.new(1,1,1)
FlyButton.TextScaled = true
FlyButton.Parent = Frame

FlyButton.MouseButton1Click:Connect(function()
    FlyEnabled = not FlyEnabled
    FlyButton.Text = "Fly: " .. (FlyEnabled and "ON" or "OFF")
    FlyButton.BackgroundColor3 = FlyEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

-- RightShift to open menu
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        Frame.Visible = not Frame.Visible
    end
end)

-- Fly
RunService.RenderStepped:Connect(function()
    if FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        local move = Vector3.new()
        local cam = workspace.CurrentCamera.CFrame

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.RightVector end

        root.Velocity = move * 70
    end
end)

print("✅ Press RightShift to open menu")
