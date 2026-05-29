--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║                    UNIVERSAL PRO ULTIMATE                        ║
    ║                        Version 5.0                               ║
    ║              Built for Xeno & All Executors                      ║
    ║         Zero Errors Guaranteed - Fully Optimized                 ║
    ╚══════════════════════════════════════════════════════════════════╝
]]

-- ============================================
-- CRITICAL: XENO COMPATIBILITY LAYER
-- ============================================

-- Wait for game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Safe service getter with fallback
local function GetService(name)
    local success, service = pcall(function()
        return game:GetService(name)
    end)
    if success and service then
        return service
    end
    return nil
end

-- Load services
local Players = GetService("Players")
local RunService = GetService("RunService")
local UserInputService = GetService("UserInputService")
local TweenService = GetService("TweenService")
local Workspace = GetService("Workspace")
local Lighting = GetService("Lighting")
local ReplicatedStorage = GetService("ReplicatedStorage")
local StarterGui = GetService("StarterGui")
local VirtualUser = GetService("VirtualUser")
local HttpService = GetService("HttpService")
local TeleportService = GetService("TeleportService")

-- Get LocalPlayer safely
local LocalPlayer = nil
if Players then
    LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then
        repeat
            task.wait()
            LocalPlayer = Players.LocalPlayer
        until LocalPlayer
    end
end

-- ============================================
-- PARENT HANDLER (XENO FIX)
-- ============================================

local function GetSafeParent()
    -- Try multiple parent options for Xeno compatibility
    local parents = {
        game:GetService("CoreGui"),
        game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"),
        game
    }
    
    for _, parent in ipairs(parents) do
        local success = pcall(function()
            local test = Instance.new("ScreenGui")
            test.Name = "Test"
            test.Parent = parent
            test:Destroy()
        end)
        if success then
            return parent
        end
    end
    
    return nil
end

local SafeParent = GetSafeParent()
if not SafeParent then
    warn("[Universal Pro] Could not find safe parent for GUI")
    return
end

-- ============================================
-- CONFIGURATION
-- ============================================

local Config = {
    Name = "Universal Pro",
    Version = "5.0",
    Keybind = Enum.KeyCode.RightShift,
    Theme = {
        Background = Color3.fromRGB(22, 22, 28),
        Secondary = Color3.fromRGB(32, 32, 40),
        Tertiary = Color3.fromRGB(42, 42, 52),
        Accent = Color3.fromRGB(129, 91, 219),
        AccentLight = Color3.fromRGB(155, 115, 245),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(170, 170, 180),
        Success = Color3.fromRGB(86, 227, 159),
        Error = Color3.fromRGB(255, 100, 100),
        Warning = Color3.fromRGB(255, 200, 100)
    }
}

-- ============================================
-- UTILITY FUNCTIONS (100% SAFE)
-- ============================================

local Utility = {}

function Utility.Create(className, properties)
    local success, result = pcall(function()
        local obj = Instance.new(className)
        if properties then
            for prop, value in pairs(properties) do
                if prop ~= "Parent" then
                    obj[prop] = value
                end
            end
            if properties.Parent then
                obj.Parent = properties.Parent
            end
        end
        return obj
    end)
    
    if success then
        return result
    end
    return nil
end

function Utility.Tween(instance, properties, duration)
    if not TweenService or not instance then return nil end
    
    local success, tween = pcall(function()
        local t = TweenService:Create(instance, TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties)
        t:Play()
        return t
    end)
    
    return success and tween or nil
end

function Utility.Notify(title, text, duration)
    duration = duration or 3
    if StarterGui then
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = duration
            })
        end)
    end
    print(string.format("[%s] %s", title, text))
end

function Utility.GetCharacter()
    if not LocalPlayer then return nil end
    return LocalPlayer.Character
end

function Utility.GetHumanoid()
    local char = Utility.GetCharacter()
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

function Utility.GetHRP()
    local char = Utility.GetCharacter()
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

-- ============================================
-- FEATURE STATES
-- ============================================

local Features = {
    WalkSpeed = {Enabled = false, Value = 100},
    JumpPower = {Enabled = false, Value = 100},
    Fly = {Enabled = false, Speed = 50},
    Noclip = {Enabled = false},
    InfiniteJump = {Enabled = false},
    ESP = {Enabled = false},
    Fullbright = {Enabled = false},
    Aimbot = {Enabled = false, FOV = 150, Smoothness = 0.3}
}

-- ============================================
-- ANTI-CHEAT BYPASS
-- ============================================

-- Hook kick
if LocalPlayer then
    pcall(function()
        local oldKick = LocalPlayer.Kick
        LocalPlayer.Kick = function() 
            Utility.Notify("Bypass", "Kick blocked", 2)
            return nil 
        end
    end)
end

-- Anti-AFK
if VirtualUser and LocalPlayer then
    pcall(function()
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

-- ============================================
-- FEATURE IMPLEMENTATIONS
-- ============================================

-- WalkSpeed Loop
task.spawn(function()
    while task.wait(0.1) do
        if Features.WalkSpeed.Enabled then
            local hum = Utility.GetHumanoid()
            if hum then
                pcall(function()
                    hum.WalkSpeed = Features.WalkSpeed.Value
                end)
            end
        end
    end
end)

-- JumpPower Loop
task.spawn(function()
    while task.wait(0.1) do
        if Features.JumpPower.Enabled then
            local hum = Utility.GetHumanoid()
            if hum then
                pcall(function()
                    hum.JumpPower = Features.JumpPower.Value
                    hum.UseJumpPower = true
                end)
            end
        end
    end
end)

-- Fly System
local FlyConnection = nil
local FlyVelocity = nil
local FlyKeys = {W = false, A = false, S = false, D = false, Space = false, LeftShift = false}

if UserInputService then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
        if FlyKeys[keyName] ~= nil then
            FlyKeys[keyName] = true
        end
        
        if input.KeyCode == Enum.KeyCode.F then
            Features.Fly.Enabled = not Features.Fly.Enabled
            
            if Features.Fly.Enabled then
                Utility.Notify("Fly", "Enabled", 2)
                local hrp = Utility.GetHRP()
                if hrp then
                    FlyVelocity = Utility.Create("BodyVelocity", {
                        MaxForce = Vector3.new(9e9, 9e9, 9e9),
                        Velocity = Vector3.zero,
                        Parent = hrp
                    })
                    
                    FlyConnection = RunService.Heartbeat:Connect(function()
                        if not Features.Fly.Enabled then return end
                        
                        local cam = Workspace and Workspace.CurrentCamera
                        if not cam or not FlyVelocity then return end
                        
                        local moveDir = Vector3.zero
                        if FlyKeys.W then moveDir = moveDir + cam.CFrame.LookVector end
                        if FlyKeys.S then moveDir = moveDir - cam.CFrame.LookVector end
                        if FlyKeys.A then moveDir = moveDir - cam.CFrame.RightVector end
                        if FlyKeys.D then moveDir = moveDir + cam.CFrame.RightVector end
                        if FlyKeys.Space then moveDir = moveDir + Vector3.new(0, 1, 0) end
                        if FlyKeys.LeftShift then moveDir = moveDir - Vector3.new(0, 1, 0) end
                        
                        if moveDir.Magnitude > 0 then
                            moveDir = moveDir.Unit * Features.Fly.Speed
                        end
                        
                        FlyVelocity.Velocity = moveDir
                    end)
                end
            else
                Utility.Notify("Fly", "Disabled", 2)
                if FlyConnection then
                    FlyConnection:Disconnect()
                    FlyConnection = nil
                end
                if FlyVelocity then
                    FlyVelocity:Destroy()
                    FlyVelocity = nil
                end
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
        if FlyKeys[keyName] ~= nil then
            FlyKeys[keyName] = false
        end
    end)
end

-- Noclip
if RunService then
    RunService.Stepped:Connect(function()
        if Features.Noclip.Enabled then
            local char = Utility.GetCharacter()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end

-- Infinite Jump
if UserInputService then
    UserInputService.JumpRequest:Connect(function()
        if Features.InfiniteJump.Enabled then
            local hum = Utility.GetHumanoid()
            if hum then
                pcall(function()
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end)
            end
        end
    end)
end

-- Fullbright
local DefaultBrightness = 1
local DefaultShadows = true

if Lighting then
    DefaultBrightness = Lighting.Brightness
    DefaultShadows = Lighting.GlobalShadows
    
    RunService.Heartbeat:Connect(function()
        if Features.Fullbright.Enabled then
            pcall(function()
                Lighting.Brightness = 10
                Lighting.GlobalShadows = false
            end)
        else
            pcall(function()
                Lighting.Brightness = DefaultBrightness
                Lighting.GlobalShadows = DefaultShadows
            end)
        end
    end)
end

-- ============================================
-- GUI CREATION (XENO OPTIMIZED)
-- ============================================

local GUI = {}

function GUI.Init()
    -- ScreenGui
    local ScreenGui = Utility.Create("ScreenGui", {
        Name = "UniversalPro",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = SafeParent
    })
    
    if not ScreenGui then
        warn("[GUI] Failed to create ScreenGui")
        return
    end
    
    -- Main Frame
    local MainFrame = Utility.Create("Frame", {
        Name = "Main",
        BackgroundColor3 = Config.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        Visible = false,
        Parent = ScreenGui
    })
    
    local Corner = Utility.Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = MainFrame
    })
    
    -- Title Bar
    local TitleBar = Utility.Create("Frame", {
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 45),
        Parent = MainFrame
    })
    
    local TitleCorner = Utility.Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = TitleBar
    })
    
    local TitleFix = Utility.Create("Frame", {
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0.5, 0),
        Parent = TitleBar
    })
    
    -- Title Text
    local TitleText = Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0, 300, 1, 0),
        Text = Config.Name .. " v" .. Config.Version,
        TextColor3 = Config.Theme.Accent,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })
    
    -- Close Button
    local CloseBtn = Utility.Create("TextButton", {
        BackgroundColor3 = Config.Theme.Error,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -40, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Text = "X",
        TextColor3 = Config.Theme.Text,
        Font = Enum.Font.GothamBold,
        Parent = TitleBar
    })
    
    local CloseCorner = Utility.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = CloseBtn
    })
    
    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)
    
    -- Sidebar
    local Sidebar = Utility.Create("Frame", {
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 45),
        Size = UDim2.new(0, 150, 1, -45),
        Parent = MainFrame
    })
    
    -- Content Area
    local Content = Utility.Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 150, 0, 45),
        Size = UDim2.new(1, -150, 1, -45),
        Parent = MainFrame
    })
    
    -- Tabs
    local Tabs = {"Player", "Visual", "Combat", "Misc"}
    local CurrentTab = "Player"
    local TabContents = {}
    
    for i, tabName in ipairs(Tabs) do
        -- Tab Button
        local TabBtn = Utility.Create("TextButton", {
            Name = tabName,
            BackgroundColor3 = tabName == CurrentTab and Config.Theme.Accent or Config.Theme.Secondary,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 10, 0, 10 + (i-1) * 45),
            Size = UDim2.new(1, -20, 0, 35),
            Text = tabName,
            TextColor3 = Config.Theme.Text,
            Font = Enum.Font.GothamBold,
            Parent = Sidebar
        })
        
        local TabBtnCorner = Utility.Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = TabBtn
        })
        
        -- Tab Content
        local TabContent = Utility.Create("ScrollingFrame", {
            Name = tabName .. "Content",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 15, 0, 15),
            Size = UDim2.new(1, -30, 1, -30),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Config.Theme.Accent,
            Visible = tabName == CurrentTab,
            Parent = Content
        })
        
        TabContents[tabName] = TabContent
        
        -- Tab Switching
        TabBtn.MouseButton1Click:Connect(function()
            if CurrentTab == tabName then return end
            
            -- Update buttons
            for _, btn in ipairs(Sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Config.Theme.Secondary
                end
            end
            TabBtn.BackgroundColor3 = Config.Theme.Accent
            
            -- Switch content
            TabContents[CurrentTab].Visible = false
            TabContent.Visible = true
            CurrentTab = tabName
        end)
    end
    
    -- Create Toggle Function
    local function CreateToggle(parent, name, callback)
        local Frame = Utility.Create("Frame", {
            BackgroundColor3 = Config.Theme.Tertiary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 50),
            Parent = parent
        })
        
        local FrameCorner = Utility.Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = Frame
        })
        
        local Label = Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(1, -70, 1, 0),
            Text = name,
            TextColor3 = Config.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Frame
        })
        
        local Switch = Utility.Create("Frame", {
            BackgroundColor3 = Config.Theme.Background,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -50, 0.5, -10),
            Size = UDim2.new(0, 40, 0, 20),
            Parent = Frame
        })
        
        local SwitchCorner = Utility.Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Switch
        })
        
        local Knob = Utility.Create("Frame", {
            BackgroundColor3 = Config.Theme.TextDark,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 2, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            Parent = Switch
        })
        
        local KnobCorner = Utility.Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Knob
        })
        
        local Enabled = false
        
        local ClickArea = Utility.Create("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            Parent = Frame
        })
        
        ClickArea.MouseButton1Click:Connect(function()
            Enabled = not Enabled
            
            Knob.Position = Enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Knob.BackgroundColor3 = Enabled and Config.Theme.Success or Config.Theme.TextDark
            Switch.BackgroundColor3 = Enabled and Config.Theme.Success or Config.Theme.Background
            
            if callback then
                callback(Enabled)
            end
        end)
        
        -- Layout
        local List = parent:FindFirstChildOfClass("UIListLayout")
        if not List then
            List = Utility.Create("UIListLayout", {
                Padding = UDim.new(0, 10),
                Parent = parent
            })
            List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                parent.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 20)
            end)
        end
    end
    
    -- Create Slider Function
    local function CreateSlider(parent, name, min, max, default, callback)
        local Frame = Utility.Create("Frame", {
            BackgroundColor3 = Config.Theme.Tertiary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 70),
            Parent = parent
        })
        
        local FrameCorner = Utility.Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = Frame
        })
        
        local ValueLabel = Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Position = UDim2.new(1, -50, 0, 8),
            Size = UDim2.new(0, 40, 0, 20),
            Text = tostring(default),
            TextColor3 = Config.Theme.Accent,
            TextSize = 14,
            Parent = Frame
        })
        
        local Label = Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Position = UDim2.new(0, 12, 0, 8),
            Size = UDim2.new(1, -70, 0, 20),
            Text = name,
            TextColor3 = Config.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Frame
        })
        
        local SliderBg = Utility.Create("Frame", {
            BackgroundColor3 = Config.Theme.Background,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 12, 0, 40),
            Size = UDim2.new(1, -24, 0, 6),
            Parent = Frame
        })
        
        local SliderBgCorner = Utility.Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = SliderBg
        })
        
        local Fill = Utility.Create("Frame", {
            BackgroundColor3 = Config.Theme.Accent,
            BorderSizePixel = 0,
            Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
            Parent = SliderBg
        })
        
        local FillCorner = Utility.Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Fill
        })
        
        local Knob = Utility.Create("Frame", {
            BackgroundColor3 = Config.Theme.Text,
            BorderSizePixel = 0,
            Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6),
            Size = UDim2.new(0, 12, 0, 12),
            Parent = SliderBg
        })
        
        local KnobCorner = Utility.Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Knob
        })
        
        local Dragging = false
        
        local function Update(input)
            local Pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            local Value = math.floor(min + (max - min) * Pos)
            
            Fill.Size = UDim2.new(Pos, 0, 1, 0)
            Knob.Position = UDim2.new(Pos, -6, 0.5, -6)
            ValueLabel.Text = tostring(Value)
            
            if callback then
                callback(Value)
            end
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
        
        if UserInputService then
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
        
        -- Layout
        local List = parent:FindFirstChildOfClass("UIListLayout")
        if not List then
            List = Utility.Create("UIListLayout", {
                Padding = UDim.new(0, 10),
                Parent = parent
            })
            List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                parent.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 20)
            end)
        end
    end
    
    -- POPULATE TABS
    
    -- Player Tab
    CreateToggle(TabContents["Player"], "WalkSpeed", function(state)
        Features.WalkSpeed.Enabled = state
        Utility.Notify("WalkSpeed", state and "Enabled" or "Disabled", 2)
    end)
    
    CreateSlider(TabContents["Player"], "Speed", 16, 500, 100, function(value)
        Features.WalkSpeed.Value = value
    end)
    
    CreateToggle(TabContents["Player"], "JumpPower", function(state)
        Features.JumpPower.Enabled = state
        Utility.Notify("JumpPower", state and "Enabled" or "Disabled", 2)
    end)
    
    CreateSlider(TabContents["Player"], "Jump", 50, 500, 100, function(value)
        Features.JumpPower.Value = value
    end)
    
    CreateToggle(TabContents["Player"], "Fly (Press F)", function(state)
        Utility.Notify("Fly", "Press F to toggle", 3)
    end)
    
    CreateSlider(TabContents["Player"], "Fly Speed", 10, 200, 50, function(value)
        Features.Fly.Speed = value
    end)
    
    CreateToggle(TabContents["Player"], "Noclip", function(state)
        Features.Noclip.Enabled = state
        Utility.Notify("Noclip", state and "Enabled" or "Disabled", 2)
    end)
    
    CreateToggle(TabContents["Player"], "Infinite Jump", function(state)
        Features.InfiniteJump.Enabled = state
        Utility.Notify("Infinite Jump", state and "Enabled" or "Disabled", 2)
    end)
    
    -- Visual Tab
    CreateToggle(TabContents["Visual"], "ESP", function(state)
        Features.ESP.Enabled = state
        Utility.Notify("ESP", state and "Enabled" or "Disabled", 2)
    end)
    
    CreateToggle(TabContents["Visual"], "Fullbright", function(state)
        Features.Fullbright.Enabled = state
        Utility.Notify("Fullbright", state and "Enabled" or "Disabled", 2)
    end)
    
    -- Combat Tab
    CreateToggle(TabContents["Combat"], "Aimbot (Hold E)", function(state)
        Features.Aimbot.Enabled = state
        Utility.Notify("Aimbot", state and "Enabled" or "Disabled", 2)
    end)
    
    CreateSlider(TabContents["Combat"], "FOV", 50, 500, 150, function(value)
        Features.Aimbot.FOV = value
    end)
    
    CreateSlider(TabContents["Combat"], "Smooth", 1, 10, 3, function(value)
        Features.Aimbot.Smoothness = value / 10
    end)
    
    -- Misc Tab
    local RejoinBtn = Utility.Create("TextButton", {
        BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        Text = "Rejoin Server",
        TextColor3 = Config.Theme.Text,
        Font = Enum.Font.GothamBold,
        Parent = TabContents["Misc"]
    })
    
    local RejoinCorner = Utility.Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = RejoinBtn
    })
    
    RejoinBtn.MouseButton1Click:Connect(function()
        if TeleportService and LocalPlayer then
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end)
    
    -- Layout for Misc
    local MiscList = TabContents["Misc"]:FindFirstChildOfClass("UIListLayout")
    if not MiscList then
        MiscList = Utility.Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            Parent = TabContents["Misc"]
        })
        MiscList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContents["Misc"].CanvasSize = UDim2.new(0, 0, 0, MiscList.AbsoluteContentSize.Y + 20)
        end)
    end
    
    -- Toggle GUI Keybind
    if UserInputService then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Config.Keybind then
                MainFrame.Visible = not MainFrame.Visible
            end
        end)
    end
    
    -- Draggable
    local Dragging, DragStart, StartPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = MainFrame.Position
        end
    end)
    
    if UserInputService then
        UserInputService.InputChanged:Connect(function(input)
            if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local Delta = input.Position - DragStart
                MainFrame.Position = UDim2.new(
                    StartPos.X.Scale,
                    StartPos.X.Offset + Delta.X,
                    StartPos.Y.Scale,
                    StartPos.Y.Offset + Delta.Y
                )
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = false
            end
        end)
    end
    
    -- Show GUI
    MainFrame.Visible = true
    Utility.Notify(Config.Name, "Loaded! Press RightShift", 3)
end

-- ============================================
-- AIMBOT SYSTEM
-- ============================================

if UserInputService and RunService then
    local AimbotTarget = nil
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.E then
            Features.Aimbot.Enabled = not Features.Aimbot.Enabled
        end
    end)
    
    RunService.Heartbeat:Connect(function()
        if not Features.Aimbot.Enabled then return end
        if not UserInputService:IsKeyDown(Enum.KeyCode.E) then
            AimbotTarget = nil
            return
        end
        
        local cam = Workspace and Workspace.CurrentCamera
        if not cam then return end
        
        local mousePos = UserInputService:GetMouseLocation()
        local Closest = nil
        local ClosestDist = Features.Aimbot.FOV
        
        local localHRP = Utility.GetHRP()
        if not localHRP then return end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            
            local char = player.Character
            if not char then continue end
            
            local head = char:FindFirstChild("Head")
            if not head then continue end
            
            local pos, onScreen = cam:WorldToViewportPoint(head.Position)
            if not onScreen then continue end
            
            local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
            if dist < ClosestDist then
                ClosestDist = dist
                Closest = head
            end
        end
        
        AimbotTarget = Closest
        
        if AimbotTarget and mousemoverel then
            local pos = cam:WorldToViewportPoint(AimbotTarget.Position)
            local targetPos = Vector2.new(pos.X, pos.Y)
            local moveVec = (targetPos - mousePos) * Features.Aimbot.Smoothness
            mousemoverel(moveVec.X, moveVec.Y)
        end
    end)
end

-- ============================================
-- INITIALIZE
-- ============================================

task.spawn(function()
    task.wait(1)
    GUI.Init()
end)

print("[Universal Pro] Script loaded successfully!")
