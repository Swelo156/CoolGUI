-- CoolGUI v4 - With UI Menu
-- you_arecool on top

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Settings
local Settings = {
    Speed = true,
    WalkSpeed = 150,
    JumpPower = 250,
    Fly = false,
    FlySpeed = 80,
    SilentAim = true,
    KillAura = false,
    Fling = false,
    ESP = true,
}

print("✅ CoolGUI v4 Loaded with UI")

StarterGui:SetCore("SendNotification", {
    Title = "CoolGUI v4",
    Text = "Press RightShift to open menu",
    Duration = 8
})

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CoolGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Title.Text = "COOLGUI v4 - you_arecool"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Function to create toggle
local function CreateToggle(name, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 50)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ToggleFrame.Position = UDim2.new(0, 10, 0, 60 + (#MainFrame:GetChildren() * 55))
    ToggleFrame.Parent = MainFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.new(1,1,1)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
    Label.TextScaled = true
    Label.Parent = ToggleFrame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.25, 0, 0.7, 0)
    Button.Position = UDim2.new(0.72, 0, 0.15, 0)
    Button.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    Button.Text = default and "ON" or "OFF"
    Button.TextColor3 = Color3.new(1,1,1)
    Button.Font = Enum.Font.GothamBold
    Button.Parent = ToggleFrame

    Button.MouseButton1Click:Connect(function()
        default = not default
        Button.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        Button.Text = default and "ON" or "OFF"
        callback(default)
    end)
end

-- Create Toggles
CreateToggle("Speed Hack", Settings.Speed, function(state) Settings.Speed = state end)
CreateToggle("Fly", Settings.Fly, function(state) Settings.Fly = state end)
CreateToggle("Silent Aim", Settings.SilentAim, function(state) Settings.SilentAim = state end)
CreateToggle("Kill Aura", Settings.KillAura, function(state) Settings.KillAura = state end)
CreateToggle("Fling Mode", Settings.Fling, function(state) Settings.Fling = state end)
CreateToggle("ESP", Settings.ESP, function(state) Settings.ESP = state end)

-- Keybind (RightShift to open/close)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    if not LocalPlayer.Character then return end
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if humanoid then
        if Settings.Speed then
            humanoid.WalkSpeed = Settings.WalkSpeed
            humanoid.JumpPower = Settings.JumpPower
        end
    end

    if Settings.Fly and root then
        local move = Vector3.new()
        local cam = Camera.CFrame

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.RightVector end

        root.Velocity = move * Settings.FlySpeed
    end
end)

print("✅ Menu ready. Press RightShift to open.")
