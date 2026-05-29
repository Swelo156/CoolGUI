-- Universal Pro Xeno Edition v1.0
-- Absolute minimum, guaranteed to work

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

-- Features
local WalkSpeedEnabled = false
local WalkSpeedValue = 100
local JumpPowerEnabled = false
local JumpPowerValue = 100
local FlyEnabled = false
local FlySpeed = 50
local NoclipEnabled = false
local InfiniteJumpEnabled = false
local FullbrightEnabled = false

-- GUI Parent (Xeno safe)
local Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalPro"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Parent

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.5, -250, 0.5, -175)
Main.Size = UDim2.new(0, 500, 0, 350)
Main.Visible = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

-- Title
local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Position = UDim2.new(0, 15, 0, 10)
Title.Size = UDim2.new(1, -30, 0, 30)
Title.Text = "Universal Pro Xeno"
Title.TextColor3 = Color3.fromRGB(129, 91, 219)
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

-- Close Button
local Close = Instance.new("TextButton")
Close.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
Close.BorderSizePixel = 0
Close.Position = UDim2.new(1, -35, 0, 10)
Close.Size = UDim2.new(0, 25, 0, 25)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.Parent = Main

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = Close

Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Container
local Container = Instance.new("ScrollingFrame")
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.Position = UDim2.new(0, 15, 0, 50)
Container.Size = UDim2.new(1, -30, 1, -65)
Container.ScrollBarThickness = 4
Container.CanvasSize = UDim2.new(0, 0, 0, 400)
Container.Parent = Main

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0, 10)
List.Parent = Container

-- Toggle Function
local function CreateToggle(name, callback)
    local Frame = Instance.new("Frame")
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Frame.BorderSizePixel = 0
    Frame.Size = UDim2.new(1, 0, 0, 45)
    Frame.Parent = Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Switch = Instance.new("Frame")
    Switch.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Switch.BorderSizePixel = 0
    Switch.Position = UDim2.new(1, -50, 0.5, -10)
    Switch.Size = UDim2.new(0, 40, 0, 20)
    Switch.Parent = Frame
    
    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch
    
    local Knob = Instance.new("Frame")
    Knob.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    Knob.BorderSizePixel = 0
    Knob.Position = UDim2.new(0, 2, 0.5, -8)
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Parent = Switch
    
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob
    
    local Enabled = false
    
    local Click = Instance.new("TextButton")
    Click.BackgroundTransparency = 1
    Click.Size = UDim2.new(1, 0, 1, 0)
    Click.Text = ""
    Click.Parent = Frame
    
    Click.MouseButton1Click:Connect(function()
        Enabled = not Enabled
        
        if Enabled then
            Knob.Position = UDim2.new(1, -18, 0.5, -8)
            Knob.BackgroundColor3 = Color3.fromRGB(86, 227, 159)
            Switch.BackgroundColor3 = Color3.fromRGB(86, 227, 159)
        else
            Knob.Position = UDim2.new(0, 2, 0.5, -8)
            Knob.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
            Switch.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        end
        
        callback(Enabled)
    end)
end

-- Slider Function
local function CreateSlider(name, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Frame.BorderSizePixel = 0
    Frame.Size = UDim2.new(1, 0, 0, 65)
    Frame.Parent = Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Position = UDim2.new(0, 12, 0, 8)
    Label.Size = UDim2.new(1, -60, 0, 20)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Position = UDim2.new(1, -50, 0, 8)
    ValueLabel.Size = UDim2.new(0, 40, 0, 20)
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(129, 91, 219)
    ValueLabel.TextSize = 14
    ValueLabel.Parent = Frame
    
    local SliderBg = Instance.new("Frame")
    SliderBg.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    SliderBg.BorderSizePixel = 0
    SliderBg.Position = UDim2.new(0, 12, 0, 38)
    SliderBg.Size = UDim2.new(1, -24, 0, 6)
    SliderBg.Parent = Frame
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(1, 0)
    SliderCorner.Parent = SliderBg
    
    local Fill = Instance.new("Frame")
    Fill.BackgroundColor3 = Color3.fromRGB(129, 91, 219)
    Fill.BorderSizePixel = 0
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.Parent = SliderBg
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill
    
    local Knob = Instance.new("Frame")
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    Knob.Size = UDim2.new(0, 12, 0, 12)
    Knob.Parent = SliderBg
    
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob
    
    local Dragging = false
    
    local function Update(input)
        local Pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
        local Val = math.floor(min + (max - min) * Pos)
        
        Fill.Size = UDim2.new(Pos, 0, 1, 0)
        Knob.Position = UDim2.new(Pos, -6, 0.5, -6)
        ValueLabel.Text = tostring(Val)
        
        callback(Val)
    end
    
    Knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
        end
    end)
    
    SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            Update(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            Update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
end

-- Create Features
CreateToggle("WalkSpeed", function(state)
    WalkSpeedEnabled = state
end)

CreateSlider("Speed", 16, 500, 100, function(val)
    WalkSpeedValue = val
end)

CreateToggle("JumpPower", function(state)
    JumpPowerEnabled = state
end)

CreateSlider("Jump", 50, 500, 100, function(val)
    JumpPowerValue = val
end)

CreateToggle("Fly (F to toggle)", function(state)
    -- Fly uses F key
end)

CreateSlider("Fly Speed", 10, 200, 50, function(val)
    FlySpeed = val
end)

CreateToggle("Noclip", function(state)
    NoclipEnabled = state
end)

CreateToggle("Infinite Jump", function(state)
    InfiniteJumpEnabled = state
end)

CreateToggle("Fullbright", function(state)
    FullbrightEnabled = state
end)

-- Feature Loops
RunService.Heartbeat:Connect(function()
    -- WalkSpeed
    if WalkSpeedEnabled then
        pcall(function()
            LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeedValue
        end)
    end
    
    -- JumpPower
    if JumpPowerEnabled then
        pcall(function()
            LocalPlayer.Character.Humanoid.JumpPower = JumpPowerValue
            LocalPlayer.Character.Humanoid.UseJumpPower = true
        end)
    end
    
    -- Noclip
    if NoclipEnabled then
        pcall(function()
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end
    
    -- Fullbright
    if FullbrightEnabled then
        pcall(function()
            Lighting.Brightness = 10
            Lighting.GlobalShadows = false
        end)
    else
        pcall(function()
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
        end)
    end
end)

-- Fly System
local FlyVelocity = nil
local FlyConnection = nil
local Keys = {W = false, A = false, S = false, D = false, Space = false, LeftShift = false}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local key = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
    if Keys[key] ~= nil then
        Keys[key] = true
    end
    
    if input.KeyCode == Enum.KeyCode.F then
        FlyEnabled = not FlyEnabled
        
        if FlyEnabled then
            pcall(function()
                FlyVelocity = Instance.new("BodyVelocity")
                FlyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                FlyVelocity.Velocity = Vector3.zero
                FlyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
                
                FlyConnection = RunService.Heartbeat:Connect(function()
                    if not FlyEnabled then return end
                    
                    local cam = workspace.CurrentCamera
                    local move = Vector3.zero
                    
                    if Keys.W then move = move + cam.CFrame.LookVector end
                    if Keys.S then move = move - cam.CFrame.LookVector end
                    if Keys.A then move = move - cam.CFrame.RightVector end
                    if Keys.D then move = move + cam.CFrame.RightVector end
                    if Keys.Space then move = move + Vector3.new(0, 1, 0) end
                    if Keys.LeftShift then move = move - Vector3.new(0, 1, 0) end
                    
                    if move.Magnitude > 0 then
                        move = move.Unit * FlySpeed
                    end
                    
                    FlyVelocity.Velocity = move
                end)
            end)
        else
            pcall(function()
                if FlyConnection then
                    FlyConnection:Disconnect()
                    FlyConnection = nil
                end
                if FlyVelocity then
                    FlyVelocity:Destroy()
                    FlyVelocity = nil
                end
            end)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local key = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
    if Keys[key] ~= nil then
        Keys[key] = false
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        pcall(function()
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end)

-- Character Respawn Handler
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HRP = char:WaitForChild("HumanoidRootPart")
    
    -- Re-apply fly if enabled
    if FlyEnabled then
        task.wait(0.5)
        pcall(function()
            FlyVelocity = Instance.new("BodyVelocity")
            FlyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            FlyVelocity.Velocity = Vector3.zero
            FlyVelocity.Parent = HRP
        end)
    end
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    pcall(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end)
end)

-- Notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Universal Pro",
    Text = "Loaded! GUI is visible",
    Duration = 3
})

print("Universal Pro Xeno - Loaded!")
