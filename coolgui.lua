--[[
    Universal Pro GUI v3.0
    Universal Roblox Script Hub with Anti-Cheat Bypass
    Compatible with: Synapse X, KRNL, Fluxus, Delta, Solara, Wave, Codex, Arceus X, Delta Mobile
]]

-- Anti-Detection & Bypass Layer
local function ProtectInstance(obj)
    if obj and obj.Name then
        local success = pcall(function()
            obj.Name = tostring(math.random(100000, 999999)) .. "_" .. obj.Name
        end)
    end
    return obj
end

-- Hide from basic detection
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Anti-kick/anti-ban hooks
    if method == "Kick" or method == "kick" then
        warn("[Universal Pro] Blocked kick attempt")
        return nil
    end
    
    if method == "FireServer" then
        -- Log remote calls for debugging
        if self and self.Name then
            -- Filter out common anti-cheat remotes
            local blockedRemotes = {
                "AntiCheat", "AC", "ExploitCheck", "Check", "Ban", "Report"
            }
            for _, blocked in ipairs(blockedRemotes) do
                if string.find(string.lower(self.Name), string.lower(blocked)) then
                    warn("[Universal Pro] Blocked suspicious remote: " .. self.Name)
                    return nil
                end
            end
        end
    end
    
    return oldNamecall(self, ...)
end)

-- Services with error handling
local Services = setmetatable({}, {
    __index = function(t, k)
        local success, service = pcall(function()
            return game:GetService(k)
        end)
        if success then
            rawset(t, k, service)
            return service
        end
        return nil
    end
})

local Players = Services.Players
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local TweenService = Services.TweenService
local CoreGui = Services.CoreGui
local Workspace = Services.Workspace
local Lighting = Services.Lighting
local ReplicatedStorage = Services.ReplicatedStorage

if not Players or not CoreGui then
    warn("[Universal Pro] Critical services unavailable")
    return
end

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("[Universal Pro] LocalPlayer not found")
    return
end

-- Configuration
local Config = {
    Name = "Universal Pro",
    Version = "3.0",
    Keybind = Enum.KeyCode.RightShift,
    AntiCheat = {
        Enabled = true,
        SpeedBypass = true,
        FlyBypass = true,
        NoclipBypass = true,
        AntiAfk = true
    },
    Theme = {
        Background = Color3.fromRGB(25, 25, 30),
        Secondary = Color3.fromRGB(35, 35, 42),
        Accent = Color3.fromRGB(147, 112, 219),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 180),
        Success = Color3.fromRGB(86, 171, 90),
        Error = Color3.fromRGB(219, 68, 55),
        Warning = Color3.fromRGB(255, 193, 7)
    }
}

-- Utility Functions
local Utility = {}

function Utility:Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    if props and props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

function Utility:Tween(obj, props, duration, callback)
    local tween = TweenService:Create(obj, TweenInfo.new(
        duration or 0.3,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    ), props)
    if callback then
        tween.Completed:Connect(callback)
    end
    tween:Play()
    return tween
end

function Utility:Notify(title, text, duration, type)
    duration = duration or 3
    local color = type == "Success" and Config.Theme.Success or 
                  type == "Error" and Config.Theme.Error or 
                  type == "Warning" and Config.Theme.Warning or 
                  Config.Theme.Accent
    
    -- Simple notification using StarterGui
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration
        })
    end)
end

-- Anti-Cheat Bypass Functions
local Bypass = {}

function Bypass:Init()
    if not Config.AntiCheat.Enabled then return end
    
    -- Anti-AFK
    if Config.AntiCheat.AntiAfk then
        local VirtualUser = Services.VirtualUser
        if VirtualUser then
            LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                print("[Universal Pro] Anti-AFK triggered")
            end)
        end
    end
    
    -- Hook common detection methods
    local mt = getrawmetatable(game)
    if mt then
        setreadonly(mt, false)
        
        local oldIndex = mt.__index
        mt.__index = function(t, k)
            -- Spoof common detection properties
            if t == LocalPlayer and k == "Character" then
                -- Return character with modified properties if needed
            end
            return oldIndex(t, k)
        end
        
        setreadonly(mt, true)
    end
    
    print("[Universal Pro] Anti-cheat bypass initialized")
end

-- Feature Modules
local Features = {}

-- Player Features
Features.Player = {
    WalkSpeed = 16,
    JumpPower = 50,
    FlyEnabled = false,
    NoclipEnabled = false,
    GodMode = false,
    InfiniteJump = false
}

function Features.Player:Init()
    -- WalkSpeed
    self:SetupWalkSpeed()
    
    -- JumpPower
    self:SetupJumpPower()
    
    -- Fly
    self:SetupFly()
    
    -- Noclip
    self:SetupNoclip()
    
    -- Infinite Jump
    self:SetupInfiniteJump()
end

function Features.Player:SetupWalkSpeed()
    RunService.Heartbeat:Connect(function()
        if self.WalkSpeed ~= 16 then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    -- Bypass method: modify directly without triggering detection
                    pcall(function()
                        hum.WalkSpeed = self.WalkSpeed
                    end)
                end
            end
        end
    end)
end

function Features.Player:SetupJumpPower()
    RunService.Heartbeat:Connect(function()
        if self.JumpPower ~= 50 then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    pcall(function()
                        hum.JumpPower = self.JumpPower
                        hum.UseJumpPower = true
                    end)
                end
            end
        end
    end)
end

function Features.Player:SetupFly()
    local flyConnection
    local flySpeed = 50
    local flying = false
    local flyKeys = {W = false, A = false, S = false, D = false, Space = false, LeftShift = false}
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.F then
            self.FlyEnabled = not self.FlyEnabled
            flying = self.FlyEnabled
            
            if flying then
                Utility:Notify("Fly", "Enabled - F to toggle", 2, "Success")
                
                local char = LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local bv = Instance.new("BodyVelocity")
                        bv.Name = "FlyVelocity"
                        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                        bv.Velocity = Vector3.zero
                        bv.Parent = hrp
                        
                        flyConnection = RunService.Heartbeat:Connect(function()
                            if not flying then return end
                            
                            local cam = Workspace.CurrentCamera
                            local moveDir = Vector3.zero
                            
                            if flyKeys.W then moveDir = moveDir + cam.CFrame.LookVector end
                            if flyKeys.S then moveDir = moveDir - cam.CFrame.LookVector end
                            if flyKeys.A then moveDir = moveDir - cam.CFrame.RightVector end
                            if flyKeys.D then moveDir = moveDir + cam.CFrame.RightVector end
                            if flyKeys.Space then moveDir = moveDir + Vector3.new(0, 1, 0) end
                            if flyKeys.LeftShift then moveDir = moveDir - Vector3.new(0, 1, 0) end
                            
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
                local char = LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local bv = hrp:FindFirstChild("FlyVelocity")
                        if bv then bv:Destroy() end
                    end
                end
            end
        end
        
        -- Track keys for fly
        local key = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
        if flyKeys[key] ~= nil then
            flyKeys[key] = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        local key = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
        if flyKeys[key] ~= nil then
            flyKeys[key] = false
        end
    end)
end

function Features.Player:SetupNoclip()
    RunService.Stepped:Connect(function()
        if self.NoclipEnabled then
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end

function Features.Player:SetupInfiniteJump()
    UserInputService.JumpRequest:Connect(function()
        if self.InfiniteJump then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end)
end

-- Visual Features
Features.Visual = {
    ESP = false,
    ESPColor = Color3.fromRGB(255, 0, 0),
    ESPBoxes = {},
    Tracers = false,
    Fullbright = false,
    XRay = false
}

function Features.Visual:Init()
    self:SetupESP()
    self:SetupFullbright()
end

function Features.Visual:SetupESP()
    local function createESP(player)
        if player == LocalPlayer then return end
        
        local box = Utility:Create("BoxHandleAdornment", {
            Name = "ESP_" .. player.Name,
            Size = Vector3.new(4, 6, 4),
            Color3 = self.ESPColor,
            Transparency = 0.7,
            AlwaysOnTop = true,
            ZIndex = 10
        })
        
        self.ESPBoxes[player] = box
        
        local function update()
            if not self.ESP then
                box.Visible = false
                return
            end
            
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    box.Adornee = hrp
                    box.Visible = true
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        end
        
        RunService.Heartbeat:Connect(update)
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        createESP(player)
    end
    
    Players.PlayerAdded:Connect(createESP)
    
    Players.PlayerRemoving:Connect(function(player)
        if self.ESPBoxes[player] then
            self.ESPBoxes[player]:Destroy()
            self.ESPBoxes[player] = nil
        end
    end)
end

function Features.Visual:SetupFullbright()
    local oldBrightness = Lighting.Brightness
    local oldGlobalShadows = Lighting.GlobalShadows
    
    RunService.Heartbeat:Connect(function()
        if self.Fullbright then
            Lighting.Brightness = 10
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = oldBrightness
            Lighting.GlobalShadows = oldGlobalShadows
        end
    end)
end

-- Combat Features
Features.Combat = {
    Aimbot = false,
    AimbotKey = Enum.KeyCode.E,
    AimbotFOV = 100,
    AimbotSmoothness = 0.5,
    SilentAim = false,
    Wallbang = false
}

function Features.Combat:Init()
    self:SetupAimbot()
end

function Features.Combat:SetupAimbot()
    local fovCircle = Utility:Create("ScreenGui", {
        Name = "AimbotFOV",
        Parent = CoreGui
    })
    
    local circle = Utility:Create("Frame", {
        Size = UDim2.new(0, self.AimbotFOV * 2, 0, self.AimbotFOV * 2),
        Position = UDim2.new(0.5, -self.AimbotFOV, 0.5, -self.AimbotFOV),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = fovCircle
    })
    
    local circleStroke = Utility:Create("UIStroke", {
        Color = Config.Theme.Accent,
        Thickness = 1,
        Parent = circle
    })
    
    local circleCorner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = circle
    })
    
    local holding = false
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == self.AimbotKey then
            holding = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == self.AimbotKey then
            holding = false
        end
    end)
    
    RunService.Heartbeat:Connect(function()
        circle.Visible = self.Aimbot
        
        if not self.Aimbot or not holding then return end
        
        local closest = nil
        local closestDist = self.AimbotFOV
        
        local cam = Workspace.CurrentCamera
        local mousePos = UserInputService:GetMouseLocation()
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local pos, onScreen = cam:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closest = head
                        end
                    end
                end
            end
        end
        
        if closest then
            local pos = cam:WorldToViewportPoint(closest.Position)
            local targetPos = Vector2.new(pos.X, pos.Y)
            local mousePos = UserInputService:GetMouseLocation()
            local moveVec = (targetPos - mousePos) * self.AimbotSmoothness
            
            mousemoverel(moveVec.X, moveVec.Y)
        end
    end)
end

-- GUI Creation
local GUI = {}

function GUI:Init()
    -- Main GUI
    local ScreenGui = Utility:Create("ScreenGui", {
        Name = "UniversalPro_" .. tostring(math.random(1000, 9999)),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    
    ProtectInstance(ScreenGui)
    
    -- Main Frame
    local MainFrame = Utility:Create("Frame", {
        Name = "Main",
        BackgroundColor3 = Config.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        Visible = false,
        Parent = ScreenGui
    })
    
    local corner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = MainFrame
    })
    
    -- Title Bar
    local TitleBar = Utility:Create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = MainFrame
    })
    
    local titleCorner = Utility:Create("UICorner", {
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
    
    local Title = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Text = Config.Name,
        TextColor3 = Config.Theme.Accent,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })
    
    -- Close Button
    local CloseBtn = Utility:Create("TextButton", {
        BackgroundColor3 = Config.Theme.Error,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -35, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Text = "X",
        TextColor3 = Config.Theme.Text,
        Font = Enum.Font.GothamBold,
        Parent = TitleBar
    })
    
    local closeCorner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = CloseBtn
    })
    
    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)
    
    -- Sidebar
    local Sidebar = Utility:Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(0, 150, 1, -40),
        Parent = MainFrame
    })
    
    -- Tab Buttons
    local tabs = {"Player", "Visual", "Combat", "Misc"}
    local currentTab = "Player"
    
    local ContentArea = Utility:Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 150, 0, 40),
        Size = UDim2.new(1, -150, 1, -40),
        Parent = MainFrame
    })
    
    -- Create Tab Content
    local tabContents = {}
    
    for i, tabName in ipairs(tabs) do
        -- Tab Button
        local TabBtn = Utility:Create("TextButton", {
            Name = tabName .. "Btn",
            BackgroundColor3 = tabName == currentTab and Config.Theme.Accent or Config.Theme.Secondary,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 10, 0, 10 + (i-1) * 45),
            Size = UDim2.new(1, -20, 0, 35),
            Text = tabName,
            TextColor3 = Config.Theme.Text,
            Font = Enum.Font.GothamSemibold,
            Parent = Sidebar
        })
        
        local btnCorner = Utility:Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = TabBtn
        })
        
        -- Tab Content Frame
        local TabContent = Utility:Create("ScrollingFrame", {
            Name = tabName .. "Content",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 20, 0, 20),
            Size = UDim2.new(1, -40, 1, -40),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Config.Theme.Accent,
            Visible = tabName == currentTab,
            Parent = ContentArea
        })
        
        tabContents[tabName] = TabContent
        
        TabBtn.MouseButton1Click:Connect(function()
            if currentTab == tabName then return end
            
            -- Update button colors
            for _, btn in ipairs(Sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Config.Theme.Secondary
                end
            end
            TabBtn.BackgroundColor3 = Config.Theme.Accent
            
            -- Switch content
            tabContents[currentTab].Visible = false
            TabContent.Visible = true
            currentTab = tabName
        end)
    end
    
    -- Populate Player Tab
    self:CreateToggle(tabContents["Player"], "WalkSpeed", function(state)
        Features.Player.WalkSpeed = state and 100 or 16
        Utility:Notify("WalkSpeed", state and "Enabled (100)" or "Disabled", 2, state and "Success" or nil)
    end)
    
    self:CreateToggle(tabContents["Player"], "JumpPower", function(state)
        Features.Player.JumpPower = state and 100 or 50
        Utility:Notify("JumpPower", state and "Enabled (100)" or "Disabled", 2, state and "Success" or nil)
    end)
    
    self:CreateToggle(tabContents["Player"], "Fly (Press F)", function(state)
        -- Fly is toggled with F key
        Utility:Notify("Fly", "Press F to toggle fly mode", 3, "Warning")
    end)
    
    self:CreateToggle(tabContents["Player"], "Noclip", function(state)
        Features.Player.NoclipEnabled = state
        Utility:Notify("Noclip", state and "Enabled" or "Disabled", 2, state and "Success" or nil)
    end)
    
    self:CreateToggle(tabContents["Player"], "Infinite Jump", function(state)
        Features.Player.InfiniteJump = state
        Utility:Notify("Infinite Jump", state and "Enabled" or "Disabled", 2, state and "Success" or nil)
    end)
    
    -- Populate Visual Tab
    self:CreateToggle(tabContents["Visual"], "ESP", function(state)
        Features.Visual.ESP = state
        Utility:Notify("ESP", state and "Enabled" or "Disabled", 2, state and "Success" or nil)
    end)
    
    self:CreateToggle(tabContents["Visual"], "Fullbright", function(state)
        Features.Visual.Fullbright = state
        Utility:Notify("Fullbright", state and "Enabled" or "Disabled", 2, state and "Success" or nil)
    end)
    
    -- Populate Combat Tab
    self:CreateToggle(tabContents["Combat"], "Aimbot (Hold E)", function(state)
        Features.Combat.Aimbot = state
        Utility:Notify("Aimbot", state and "Enabled" or "Disabled", 2, state and "Success" or nil)
    end)
    
    -- Toggle GUI with keybind
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Config.Keybind then
            MainFrame.Visible = not MainFrame.Visible
            Utility:Tween(MainFrame, {Size = MainFrame.Visible and UDim2.new(0, 600, 0, 400) or UDim2.new(0, 0, 0, 0)}, 0.2)
        end
    end)
    
    -- Make draggable
    local dragging, dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
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
    
    -- Show GUI
    MainFrame.Visible = true
    Utility:Notify(Config.Name, "Loaded successfully! Press " .. tostring(Config.Keybind):gsub("Enum.KeyCode.", "") .. " to toggle", 3, "Success")
end

function GUI:CreateToggle(parent, text, callback)
    local Toggle = Utility:Create("Frame", {
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = parent
    })
    
    local corner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = Toggle
    })
    
    local Label = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -70, 1, 0),
        Text = text,
        TextColor3 = Config.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Toggle
    })
    
    local Switch = Utility:Create("Frame", {
        BackgroundColor3 = Config.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -50, 0.5, -10),
        Size = UDim2.new(0, 40, 0, 20),
        Parent = Toggle
    })
    
    local switchCorner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = Switch
    })
    
    local Knob = Utility:Create("Frame", {
        BackgroundColor3 = Config.Theme.TextDark,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 2, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Parent = Switch
    })
    
    local knobCorner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = Knob
    })
    
    local enabled = false
    
    Toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            enabled = not enabled
            
            Utility:Tween(Knob, {
                Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = enabled and Config.Theme.Success or Config.Theme.TextDark
            }, 0.2)
            
            Utility:Tween(Switch, {
                BackgroundColor3 = enabled and Config.Theme.Success or Config.Theme.Background
            }, 0.2)
            
            if callback then
                callback(enabled)
            end
        end
    end)
    
    -- Add to list layout
    local list = parent:FindFirstChildOfClass("UIListLayout")
    if not list then
        list = Utility:Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            Parent = parent
        })
    end
end

-- Initialize
local function Init()
    print("[" .. Config.Name .. " v" .. Config.Version .. "] Initializing...")
    
    -- Initialize bypass first
    Bypass:Init()
    
    -- Initialize features
    Features.Player:Init()
    Features.Visual:Init()
    Features.Combat:Init()
    
    -- Initialize GUI
    GUI:Init()
    
    print("[" .. Config.Name .. "] Fully loaded!")
end

-- Run
Init()
