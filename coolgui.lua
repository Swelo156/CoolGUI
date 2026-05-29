--[[
    CoolGUI Pro v2.0
    Enhanced Roblox Script Hub
    Features: Modern UI, Universal Compatibility, Optimized Performance
    Compatible with: Synapse X, KRNL, Fluxus, Delta, Solara, Wave, and most executors
]]

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Configuration
local Config = {
    Name = "CoolGUI Pro",
    Version = "2.0",
    Theme = {
        Primary = Color3.fromRGB(30, 30, 35),
        Secondary = Color3.fromRGB(45, 45, 55),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentHover = Color3.fromRGB(108, 121, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 180),
        Success = Color3.fromRGB(67, 181, 129),
        Error = Color3.fromRGB(240, 71, 71),
        Warning = Color3.fromRGB(250, 166, 26),
        Border = Color3.fromRGB(60, 60, 70)
    },
    Animation = {
        Speed = 0.3,
        Easing = Enum.EasingStyle.Quart,
        Direction = Enum.EasingDirection.Out
    },
    Keybind = Enum.KeyCode.RightShift
}

-- Utility Functions
local Utility = {}

function Utility:Create(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties or {}) do
        if property ~= "Parent" then
            instance[property] = value
        end
    end
    if properties and properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utility:Tween(instance, properties, duration, callback)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(
            duration or Config.Animation.Speed,
            Config.Animation.Easing,
            Config.Animation.Direction
        ),
        properties
    )
    if callback then
        tween.Completed:Connect(callback)
    end
    tween:Play()
    return tween
end

function Utility:MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Utility:Ripple(button, x, y)
    local ripple = Utility:Create("Frame", {
        Name = "Ripple",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        Position = UDim2.new(0, x - button.AbsolutePosition.X, 0, y - button.AbsolutePosition.Y),
        Size = UDim2.new(0, 0, 0, 0),
        Parent = button
    })
    
    local corner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = ripple
    })
    
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    
    Utility:Tween(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        Position = UDim2.new(0, x - button.AbsolutePosition.X - maxSize/2, 0, y - button.AbsolutePosition.Y - maxSize/2),
        BackgroundTransparency = 1
    }, 0.5, function()
        ripple:Destroy()
    end)
end

function Utility:Notify(title, text, duration, type)
    duration = duration or 3
    type = type or "Info"
    
    local notification = Utility:Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = Config.Theme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 20, 0, 20),
        Size = UDim2.new(0, 300, 0, 80),
        Parent = CoreGui:FindFirstChild("CoolGUIPro") or CoreGui
    })
    
    local corner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = notification
    })
    
    local stroke = Utility:Create("UIStroke", {
        Color = type == "Success" and Config.Theme.Success or type == "Error" and Config.Theme.Error or Config.Theme.Accent,
        Thickness = 2,
        Parent = notification
    })
    
    local titleLabel = Utility:Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(0, 15, 0, 10),
        Size = UDim2.new(1, -30, 0, 20),
        Text = title,
        TextColor3 = type == "Success" and Config.Theme.Success or type == "Error" and Config.Theme.Error or Config.Theme.Accent,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notification
    })
    
    local textLabel = Utility:Create("TextLabel", {
        Name = "Text",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0, 15, 0, 35),
        Size = UDim2.new(1, -30, 0, 35),
        Text = text,
        TextColor3 = Config.Theme.Text,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notification
    })
    
    Utility:Tween(notification, {Position = UDim2.new(1, -320, 0, 20)}, 0.3)
    
    task.delay(duration, function()
        Utility:Tween(notification, {Position = UDim2.new(1, 20, 0, 20)}, 0.3, function()
            notification:Destroy()
        end)
    end)
end

-- GUI Creation
local CoolGUI = {}

function CoolGUI:Init()
    -- Main GUI Container
    local ScreenGui = Utility:Create("ScreenGui", {
        Name = "CoolGUIPro",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    
    -- Blur Effect
    local blur = Utility:Create("BlurEffect", {
        Size = 0,
        Parent = Lighting
    })
    
    -- Main Frame
    local MainFrame = Utility:Create("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = Config.Theme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -400, 0.5, -250),
        Size = UDim2.new(0, 800, 0, 500),
        Parent = ScreenGui
    })
    
    local mainCorner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = MainFrame
    })
    
    local mainStroke = Utility:Create("UIStroke", {
        Color = Config.Theme.Border,
        Thickness = 1,
        Parent = MainFrame
    })
    
    -- Shadow
    local shadow = Utility:Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.6,
        Position = UDim2.new(0, -15, 0, -15),
        Size = UDim2.new(1, 30, 1, 30),
        ZIndex = 0,
        Parent = MainFrame
    })
    
    -- Title Bar
    local TitleBar = Utility:Create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 50),
        Parent = MainFrame
    })
    
    local titleCorner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = TitleBar
    })
    
    local titleFix = Utility:Create("Frame", {
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0.5, 0),
        Parent = TitleBar
    })
    
    -- Logo & Title
    local Logo = Utility:Create("TextLabel", {
        Name = "Logo",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBlack,
        Position = UDim2.new(0, 20, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Text = Config.Name,
        TextColor3 = Config.Theme.Accent,
        TextSize = 24,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })
    
    local Version = Utility:Create("TextLabel", {
        Name = "Version",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0, 165, 0, 0),
        Size = UDim2.new(0, 50, 1, 0),
        Text = "v" .. Config.Version,
        TextColor3 = Config.Theme.TextDark,
        TextSize = 14,
        Parent = TitleBar
    })
    
    -- Close & Minimize Buttons
    local CloseButton = Utility:Create("TextButton", {
        Name = "Close",
        BackgroundColor3 = Config.Theme.Error,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -45, 0.5, -12),
        Size = UDim2.new(0, 24, 0, 24),
        Text = "",
        Parent = TitleBar
    })
    
    local closeCorner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = CloseButton
    })
    
    local MinimizeButton = Utility:Create("TextButton", {
        Name = "Minimize",
        BackgroundColor3 = Config.Theme.Warning,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -80, 0.5, -12),
        Size = UDim2.new(0, 24, 0, 24),
        Text = "",
        Parent = TitleBar
    })
    
    local minimizeCorner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = MinimizeButton
    })
    
    -- Sidebar
    local Sidebar = Utility:Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(0, 200, 1, -50),
        Parent = MainFrame
    })
    
    local sidebarCorner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 0),
        Parent = Sidebar
    })
    
    local sidebarFix = Utility:Create("Frame", {
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -20, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),
        Parent = Sidebar
    })
    
    -- Tab Container
    local TabContainer = Utility:Create("ScrollingFrame", {
        Name = "TabContainer",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(1, -20, 1, -20),
        ScrollBarThickness = 0,
        ScrollingEnabled = false,
        Parent = Sidebar
    })
    
    local tabList = Utility:Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabContainer
    })
    
    -- Content Area
    local ContentArea = Utility:Create("Frame", {
        Name = "ContentArea",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 200, 0, 50),
        Size = UDim2.new(1, -200, 1, -50),
        Parent = MainFrame
    })
    
    -- Tab Management
    local Tabs = {}
    local CurrentTab = nil
    
    function CoolGUI:CreateTab(name, icon)
        local Tab = {}
        
        -- Tab Button
        local TabButton = Utility:Create("TextButton", {
            Name = name .. "Tab",
            BackgroundColor3 = Config.Theme.Primary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 40),
            Text = "",
            Parent = TabContainer
        })
        
        local buttonCorner = Utility:Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = TabButton
        })
        
        local TabIcon = Utility:Create("ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Image = icon or "",
            Position = UDim2.new(0, 12, 0.5, -10),
            Size = UDim2.new(0, 20, 0, 20),
            Parent = TabButton
        })
        
        local TabText = Utility:Create("TextLabel", {
            Name = "Text",
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Position = UDim2.new(0, 42, 0, 0),
            Size = UDim2.new(1, -52, 1, 0),
            Text = name,
            TextColor3 = Config.Theme.TextDark,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabButton
        })
        
        -- Tab Content
        local TabContent = Utility:Create("ScrollingFrame", {
            Name = name .. "Content",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 20, 0, 20),
            Size = UDim2.new(1, -40, 1, -40),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Config.Theme.Accent,
            Visible = false,
            Parent = ContentArea
        })
        
        local contentList = Utility:Create("UIListLayout", {
            Padding = UDim.new(0, 12),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabContent
        })
        
        contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 20)
        end)
        
        -- Tab Switching
        TabButton.MouseButton1Click:Connect(function()
            if CurrentTab == Tab then return end
            
            -- Deselect current
            if CurrentTab then
                Utility:Tween(CurrentTab.Button, {BackgroundColor3 = Config.Theme.Primary}, 0.2)
                CurrentTab.Text.TextColor3 = Config.Theme.TextDark
                CurrentTab.Content.Visible = false
            end
            
            -- Select
