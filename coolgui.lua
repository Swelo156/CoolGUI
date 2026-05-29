-- CoolGUI v5 - Admin Style Cheat
print("✅ CoolGUI v5 Admin Cheat Loaded")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    Fly = false,
    FlySpeed = 80,
    Speed = true,
    WalkSpeed = 140,
    JumpPower = 250,
    Godmode = false,
    ESP = true,
    KillAura = false,
    Fling = false,
}

-- Notification
StarterGui:SetCore("SendNotification", {
    Title = "CoolGUI v5",
    Text = "Press RightShift to open Admin Menu",
    Duration = 8
})

-- =============== UI ===============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CoolGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 520)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
Title.Text = "COOLGUI ADMIN v5"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local function CreateButton(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 45)
    btn.Position = UDim2.new(0, 10, 0, 0)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local yOffset = 60

-- Toggles
local function CreateToggle(name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.Position = UDim2.new(0, 10, 0, yOffset)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.Parent = MainFrame
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "  " .. name
    label.TextColor3 = Color3.new(1,1,1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextScaled = true
    label.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.35, 0, 0.7, 0)
    toggleBtn.Position = UDim2.new(0.62, 0, 0.15, 0)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextScaled = true
    toggleBtn.Parent = frame
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

    toggleBtn.MouseButton1Click:Connect(function()
        default = not default
        toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        toggleBtn.Text = default and "ON" or "OFF"
        callback(default)
    end)
    
    yOffset += 55
end

CreateToggle("Speed", true, function(v) Settings.Speed = v end)
CreateToggle("Fly", false, function(v) Settings.Fly = v end)
CreateToggle("Godmode", false, function(v) Settings.Godmode = v end)
CreateToggle("ESP", true, function(v) Settings.ESP = v end)
CreateToggle("Kill Aura", false, function(v) Settings.KillAura = v end)
CreateToggle("Fling Mode", false, function(v) Settings.Fling = v end)

-- Quick Actions
yOffset += 10
CreateButton("Kill Nearest", Color3.fromRGB(140, 0, 0), function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") then
            p.Character.Humanoid.Health = 0
            break
        end
    end
end)

CreateButton("Fling Nearest", Color3.fromRGB(180, 100, 0), function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(math.random(-100,100), 80, math.random(-100,100))
            bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            bv.Parent = p.Character.HumanoidRootPart
            game:GetService("Debris"):AddItem(bv, 0.5)
            break
        end
    end
end)

-- Keybind
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    if not LocalPlayer.Character then return end
    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if hum then
        if Settings.Speed then
            hum.WalkSpeed = Settings.WalkSpeed
            hum.JumpPower = Settings.JumpPower
        end
        if Settings.Godmode then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
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

print("✅ RightShift to open menu")
