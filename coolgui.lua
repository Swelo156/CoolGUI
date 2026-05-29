-- CoolGUI v4.1 - Focused on UI, ESP & Fly
print("✅ CoolGUI v4.1 Loaded")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    Fly = false,
    FlySpeed = 75,
    ESP = true,
    Speed = true,
    WalkSpeed = 140,
}

-- Notification
StarterGui:SetCore("SendNotification", {
    Title = "CoolGUI v4.1",
    Text = "Press RightShift to open menu",
    Duration = 8
})

-- UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CoolGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 480)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 60)
Title.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Title.Text = "COOLGUI v4.1"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local function CreateToggle(name, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -40, 0, 55)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = MainFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "  " .. name
    label.TextColor3 = Color3.new(1,1,1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextScaled = true
    label.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.3, 0, 0.75, 0)
    button.Position = UDim2.new(0.67, 0, 0.12, 0)
    button.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    button.Text = defaultValue and "ON" or "OFF"
    button.TextColor3 = Color3.new(1,1,1)
    button.Font = Enum.Font.GothamBold
    button.TextScaled = true
    button.Parent = frame

    button.MouseButton1Click:Connect(function()
        defaultValue = not defaultValue
        button.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        button.Text = defaultValue and "ON" or "OFF"
        callback(defaultValue)
    end)
end

-- Toggles
CreateToggle("Fly", Settings.Fly, function(v) Settings.Fly = v end)
CreateToggle("ESP", Settings.ESP, function(v) Settings.ESP = v end)
CreateToggle("Speed", Settings.Speed, function(v) Settings.Speed = v end)

-- Keybind
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Fly Logic
RunService.RenderStepped:Connect(function()
    if not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")

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
local ESPTable = {}

local function CreateESP(plr)
    if plr == LocalPlayer then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Transparency = 1

    ESPTable[plr] = box

    RunService.RenderStepped:Connect(function()
        if Settings.ESP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)

            if onScreen then
                local size = 2200 / (Camera.CFrame.Position - root.Position).Magnitude
                box.Size = Vector2.new(size, size * 2.2)
                box.Position = Vector2.new(pos.X - size/2, pos.Y - size)
                box.Visible = true
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end)
end

-- Add existing players
for _, plr in ipairs(Players:GetPlayers()) do
    CreateESP(plr)
end
Players.PlayerAdded:Connect(CreateESP)

print("✅ UI + ESP + Fly ready. Press RightShift")
