-- CoolGUI v6 - Working UI + Fly + ESP + More
print("✅ CoolGUI v6 Loaded Successfully")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    Fly = false,
    FlySpeed = 75,
    Speed = true,
    WalkSpeed = 140,
    ESP = true,
}

-- Notification
StarterGui:SetCore("SendNotification", {
    Title = "CoolGUI v6",
    Text = "Loaded! Press RightShift for menu",
    Duration = 8
})

-- UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CoolGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 420)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 55)
Title.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Title.Text = "COOLGUI v6"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

local y = 70

local function CreateToggle(name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -30, 0, 50)
    frame.Position = UDim2.new(0, 15, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.Parent = MainFrame
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "   " .. name
    label.TextColor3 = Color3.new(1,1,1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextScaled = true
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.3, 0, 0.75, 0)
    btn.Position = UDim2.new(0.67, 0, 0.12, 0)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        default = not default
        btn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        btn.Text = default and "ON" or "OFF"
        callback(default)
    end)

    y = y + 60
end

CreateToggle("Speed Hack", true, function(v) Settings.Speed = v end)
CreateToggle("Fly", false, function(v) Settings.Fly = v end)
CreateToggle("ESP", true, function(v) Settings.ESP = v end)

-- Keybind
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Main Loop (Speed + Fly)
RunService.RenderStepped:Connect(function()
    if not LocalPlayer.Character then return end
    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if hum and Settings.Speed then
        hum.WalkSpeed = Settings.WalkSpeed
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

-- ESP
local ESP = {}
local function AddESP(plr)
    if plr == LocalPlayer then return end
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Color = Color3.fromRGB(255, 50, 50)
    box.Transparency = 1

    ESP[plr] = box
end

for _, plr in ipairs(Players:GetPlayers()) do AddESP(plr) end
Players.PlayerAdded:Connect(AddESP)

RunService.RenderStepped:Connect(function()
    for plr, box in pairs(ESP) do
        if Settings.ESP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local size = 2000 / (Camera.CFrame.Position - root.Position).Magnitude
                box.Size = Vector2.new(size, size * 2)
                box.Position = Vector2.new(pos.X - size/2, pos.Y - size)
                box.Visible = true
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end
end)

print("✅ RightShift = Menu | Good luck in CoolGUI")
