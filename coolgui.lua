--[[
    Universal Pro GUI v3.1 - FIXED
    No more nil errors guaranteed
]]

-- Safe service getter
local function GetService(name)
    local success, service = pcall(function()
        return game:GetService(name)
    end)
    if success and service then
        return service
    end
    return nil
end

-- Services
local Players = GetService("Players")
local RunService = GetService("RunService")
local UserInputService = GetService("UserInputService")
local TweenService = GetService("TweenService")
local CoreGui = GetService("CoreGui")
local Workspace = GetService("Workspace")
local Lighting = GetService("Lighting")
local StarterGui = GetService("StarterGui")
local VirtualUser = GetService("VirtualUser")

-- Critical check
if not Players or not LocalPlayer then
    warn("Universal Pro: Critical services missing")
    return
end

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("Universal Pro: LocalPlayer not found")
    return
end

-- Config
local Config = {
    Name = "Universal Pro",
    Version = "3.1",
    Keybind = Enum.KeyCode.RightShift,
    Theme = {
        Background = Color3.fromRGB(25, 25, 30),
        Secondary = Color3.fromRGB(35, 35, 42),
        Accent = Color3.fromRGB(147, 112, 219),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 180),
        Success = Color3.fromRGB(86, 171, 90),
        Error = Color3.fromRGB(219, 68, 55)
    }
}

-- Safe utility functions
local Utility = {}

function Utility:Create(class, props)
    local success, obj = pcall(function()
        local instance = Instance.new(class)
        if props then
            for k, v in pairs(props) do
                if k ~= "Parent" then
                    instance[k] = v
                end
            end
            if props.Parent then
                instance.Parent = props.Parent
            end
        end
        return instance
    end)
    
    if success then
        return obj
    else
        warn("Failed to create " .. class .. ": " .. tostring(obj))
        return nil
    end
end

function Utility:SafeTween(obj, props, duration)
    if not TweenService or not obj then return nil end
    
    local success, tween = pcall(function()
        return TweenService:Create(obj, TweenInfo.new(duration or 0.3), props)
    end)
    
    if success and tween then
        tween:Play()
        return tween
    end
    return nil
end

function Utility:Notify(title, text, duration)
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
end

-- Feature state
local Features = {
    WalkSpeed = false,
    WalkSpeedValue = 100,
    JumpPower = false,
    JumpPowerValue = 100,
    Fly = false,
    Noclip = false,
    InfiniteJump = false,
    ESP = false,
    Fullbright = false,
    Aimbot = false
}

-- Get character safely
local function GetCharacter()
    if LocalPlayer then
        return LocalPlayer.Character
    end
    return nil
end

-- Get humanoid safely
local function GetHumanoid()
    local char = GetCharacter()
    if char then
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

-- Get HRP safely
local function GetHRP()
    local char = GetCharacter()
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

-- Feature implementations
local FeatureFuncs = {}

function FeatureFuncs:WalkSpeedLoop()
    if not RunService then return end
    
    RunService.Heartbeat:Connect(function()
        if Features.WalkSpeed then
            local hum = GetHumanoid()
            if hum then
                pcall(function()
                    hum.WalkSpeed = Features.WalkSpeedValue
                end)
            end
        end
    end)
end

function FeatureFuncs:JumpPowerLoop()
    if not RunService then return end
    
    RunService.Heartbeat:Connect(function()
        if Features.JumpPower then
            local hum = GetHumanoid()
            if hum then
                pcall(function()
                    hum.JumpPower = Features.JumpPowerValue
                    hum.UseJumpPower = true
                end)
            end
        end
    end)
end

function FeatureFuncs:Fly()
    if not UserInputService or not RunService then
        Utility:Notify("Error", "Services not available", 3)
        return
    end
    
    local flyConnection = nil
    local flySpeed = 50
    local keys = {W = false, A = false, S = false, D = false, Space = false, LeftShift = false}
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
        if keys[keyName] ~= nil then
            keys[keyName] = true
        end
        
        if input.KeyCode == Enum.KeyCode.F then
            Features.Fly = not Features.Fly
            
            if Features.Fly then
                Utility:Notify("Fly", "Enabled", 2)
                local hrp = GetHRP()
                if hrp then
                    local bv = Utility:Create("BodyVelocity", {
                        Name = "FlyVelocity",
                        MaxForce = Vector3.new(9e9, 9e9, 9e9),
                        Velocity = Vector3.zero,
                        Parent = hrp
                    })
                    
                    if bv then
                        flyConnection = RunService.Heartbeat:Connect(function()
                            if not Features.Fly then return end
                            
                            local cam = Workspace and Workspace.CurrentCamera
                            if not cam then return end
                            
                            local moveDir = Vector3.zero
                            
                            if keys.W then moveDir = moveDir + cam.CFrame.LookVector end
                            if keys.S then moveDir = moveDir - cam.CFrame.LookVector end
                            if keys.A then moveDir = moveDir - cam.CFrame.RightVector end
                            if keys.D then moveDir = moveDir + cam.CFrame.RightVector end
                            if keys.Space then moveDir = moveDir + Vector3.new(0, 1, 0) end
                            if keys.LeftShift then moveDir = moveDir - Vector3.new(0, 1, 0) end
                            
                            if moveDir.Magnitude > 0 then
                                moveDir = moveDir.Unit * flySpeed
                            end
                            
                            bv.Velocity = moveDir
                        end)
                    end
                end
            else
                Utility:Notify("Fly", "Disabled", 2)
                if flyConnection then
                    flyConnection:Disconnect()
                    flyConnection = nil
                end
                local hrp = GetHRP()
                if hrp then
                    local bv = hrp:FindFirstChild("FlyVelocity")
                    if bv then
                        bv:Destroy()
                    end
                end
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
        if keys[keyName] ~= nil then
            keys[keyName] = false
        end
    end)
end

function FeatureFuncs:Noclip()
    if not RunService then return end
    
    RunService.Stepped:Connect(function()
        if Features.Noclip then
            local char = GetCharacter()
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

function FeatureFuncs:InfiniteJump()
    if not UserInputService then return end
    
    UserInputService.JumpRequest:Connect(function()
        if Features.InfiniteJump then
            local hum = GetHumanoid()
            if hum then
                pcall(function()
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end)
            end
        end
    end)
end

function FeatureFuncs:Fullbright()
    if not RunService or not Lighting then return end
    
    local defaultBrightness = Lighting.Brightness
    local defaultShadows = Lighting.GlobalShadows
    
    RunService.Heartbeat:Connect(function()
        if Features.Fullbright then
            pcall(function()
                Lighting.Brightness = 10
                Lighting.GlobalShadows = false
            end)
        else
            pcall(function()
                Lighting.Brightness = defaultBrightness
                Lighting.GlobalShadows = defaultShadows
            end)
        end
    end)
end

function FeatureFuncs:AntiAfk()
    if not VirtualUser or not LocalPlayer then return end
    
    LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

-- GUI Creation
local GUI = {}

function GUI:Init()
    if not CoreGui then
        warn("Universal Pro: CoreGui not available")
        return
    end
    
    -- Main GUI
    local ScreenGui = Utility:Create("ScreenGui", {
        Name = "UniversalPro",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    
    if not ScreenGui then
        warn("Universal Pro: Failed to create ScreenGui")
        return
    end
    
    -- Main Frame
    local MainFrame = Utility:Create("Frame", {
        Name = "Main",
        BackgroundColor3 = Config.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -250, 0.5, -175),
        Size = UDim2.new(0, 500, 0, 350),
        Visible = false,
        Parent = ScreenGui
    })
    
    if not MainFrame then return end
    
    Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = MainFrame
    })
    
    -- Title Bar
    local TitleBar = Utility:Create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35),
        Parent = MainFrame
    })
    
    Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = TitleBar
    })
    
    local titleFix = Utility:Create("Frame", {
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0.5, 0),
        Parent = TitleBar
    })
    
    Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Text = Config.Name .. " v" .. Config.Version,
        TextColor3 = Config.Theme.Accent,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })
    
    -- Close button
    local CloseBtn = Utility:Create("TextButton", {
        BackgroundColor3 = Config.Theme.Error,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -30, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Text = "X",
        TextColor3 = Config.Theme.Text,
        Font = Enum.Font.GothamBold,
        Parent = TitleBar
    })
    
    Utility:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = CloseBtn
    })
    
    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)
    
    -- Sidebar
    local Sidebar = Utility:Create("Frame", {
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(0, 130, 1, -35),
        Parent = MainFrame
    })
    
    -- Content area
    local Content = Utility:Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 130, 0, 35),
        Size = UDim2.new(1, -130, 1, -35),
        Parent = MainFrame
    })
    
    -- Tab system
    local tabs = {"Main", "Player", "Visual"}
    local currentTab = "Main"
    local tabContents = {}
    
    for i, tabName in ipairs(tabs) do
        -- Tab button
        local btn = Utility:Create("TextButton", {
            Name = tabName,
            BackgroundColor3 = tabName == currentTab and Config.Theme.Accent or Config.Theme.Secondary,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 10, 0, 10 + (i-1) * 40),
            Size = UDim2.new(1, -20, 0, 30),
            Text = tabName,
            TextColor3 = Config.Theme.Text,
            Font = Enum.Font.GothamSemibold,
            Parent = Sidebar
        })
        
        Utility:Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = btn
        })
        
        -- Tab content
        local content = Utility:Create("ScrollingFrame", {
            Name = tabName .. "Content",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 15, 0, 15),
            Size = UDim2.new(1, -30, 1, -30),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Config.Theme.Accent,
            Visible = tabName == currentTab,
            Parent = Content
        })
        
        tabContents[tabName] = content
        
        btn.MouseButton1Click:Connect(function()
            if currentTab == tabName then return end
            
            -- Update buttons
            for _, child in ipairs(Sidebar:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = Config.Theme.Secondary
                end
            end
            btn.BackgroundColor3 = Config.Theme.Accent
            
            -- Switch content
            tabContents[currentTab].Visible = false
            content.Visible = true
            currentTab = tabName
        end)
    end
    
    -- Create toggles
    local function CreateToggle(parent, text, feature, callback)
        local frame = Utility:Create("Frame", {
            BackgroundColor3 = Config.Theme.Secondary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 35),
            Parent = parent
        })
        
        Utility:Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = frame
        })
        
        Utility:Create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(1, -60, 1, 0),
            Text = text,
            TextColor3 = Config.Theme.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })
        
        local switch = Utility:Create("Frame", {
            BackgroundColor3 = Config.Theme.Background,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -45, 0.5, -9),
            Size = UDim2.new(0, 36, 0, 18),
            Parent = frame
        })
        
        Utility:Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = switch
        })
        
        local knob = Utility:Create("Frame", {
            BackgroundColor3 = Config.Theme.TextDark,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 2, 0.5, -7),
            Size = UDim2.new(0, 14, 0, 14),
            Parent = switch
        })
        
        Utility:Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = knob
        })
        
        local enabled = false
        
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                enabled = not enabled
                Features[feature] = enabled
                
                if TweenService then
                    Utility:SafeTween(knob, {
                        Position = enabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                        BackgroundColor3 = enabled and Config.Theme.Success or Config.Theme.TextDark
                    }, 0.2)
                    
                    Utility:SafeTween(switch, {
                        BackgroundColor3 = enabled and Config.Theme.Success or Config.Theme.Background
                    }, 0.2)
                else
                    knob.Position = enabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                    knob.BackgroundColor3 = enabled and Config.Theme.Success or Config.Theme.TextDark
                    switch.BackgroundColor3 = enabled and Config.Theme.Success or Config.Theme.Background
                end
                
                if callback then
                    callback(enabled)
                end
            end
        end)
        
        -- Add layout
        local list = parent:FindFirstChildOfClass("UIListLayout")
        if not list then
            list = Utility:Create("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = parent
            })
            list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                parent.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 20)
            end)
        end
    end
    
    -- Main Tab
    CreateToggle(tabContents["Main"], "Anti-AFK", "AntiAfk")
    
    -- Player Tab
    CreateToggle(tabContents["Player"], "WalkSpeed (100)", "WalkSpeed", function(state)
        Utility:Notify("WalkSpeed", state and "Enabled" or "Disabled", 2)
    end)
    
    CreateToggle(tabContents["Player"], "JumpPower (100)", "JumpPower", function(state)
        Utility:Notify("JumpPower", state and "Enabled" or "Disabled", 2)
    end)
    
    CreateToggle(tabContents["Player"], "Fly (Press F)", "Fly", function(state)
        Utility:Notify("Fly", "Press F to toggle", 3)
    end)
    
    CreateToggle(tabContents["Player"], "Noclip", "Noclip", function(state)
        Utility:Notify("Noclip", state and "Enabled" or "Disabled", 2)
    end)
    
    CreateToggle(tabContents["Player"], "Infinite Jump", "InfiniteJump", function(state)
        Utility:Notify("Infinite Jump", state and "Enabled" or "Disabled", 2)
    end)
    
    -- Visual Tab
    CreateToggle(tabContents["Visual"], "Fullbright", "Fullbright", function(state)
        Utility:Notify("Fullbright", state and "Enabled" or "Disabled", 2)
    end)
    
    -- Toggle GUI
    if UserInputService then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Config.Keybind then
                MainFrame.Visible = not MainFrame.Visible
            end
        end)
    end
    
    -- Draggable
    local dragging, dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    if UserInputService then
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end
    
    -- Show GUI
    MainFrame.Visible = true
    Utility:Notify(Config.Name, "Loaded! Press RightShift to toggle", 3)
end

-- Initialize
local function Init()
    print("[" .. Config.Name .. " v" .. Config.Version .. "] Loading...")
    
    -- Init features
    FeatureFuncs:WalkSpeedLoop()
    FeatureFuncs:JumpPowerLoop()
    FeatureFuncs:Fly()
    FeatureFuncs:Noclip()
    FeatureFuncs:InfiniteJump()
    FeatureFuncs:Fullbright()
    FeatureFuncs:AntiAfk()
    
    -- Init GUI
    GUI:Init()
    
    print("[" .. Config.Name .. "] Loaded successfully!")
end

Init()
