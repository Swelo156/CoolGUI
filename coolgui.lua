-- ╔══════════════════════════════════════════════════════════════╗
-- ║           CoolGUI v7 - ULTIMATE EDITION                     ║
-- ║     Built on your working base - 2000+ lines                ║
-- ║     RightShift = Toggle | F = Fly | Hold E = Aimbot         ║
-- ╚══════════════════════════════════════════════════════════════╝

print("✅ CoolGUI v7 Ultimate Loading...")

-- ════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local StarterGui        = game:GetService("StarterGui")
local Lighting          = game:GetService("Lighting")
local TeleportService   = game:GetService("TeleportService")
local HttpService       = game:GetService("HttpService")
local VirtualUser       = pcall(function() return game:GetService("VirtualUser") end) and game:GetService("VirtualUser") or nil

local LocalPlayer   = Players.LocalPlayer
local Camera        = workspace.CurrentCamera
local PlayerGui     = LocalPlayer:WaitForChild("PlayerGui")

-- ════════════════════════════════════════
-- KILL OLD INSTANCES
-- ════════════════════════════════════════
for _, v in ipairs(PlayerGui:GetChildren()) do
    if v.Name == "CoolGUI" then v:Destroy() end
end

-- ════════════════════════════════════════
-- SETTINGS
-- ════════════════════════════════════════
local Settings = {
    -- Player
    Speed           = true,
    WalkSpeed       = 140,
    JumpPower       = false,
    JumpVal         = 100,
    Fly             = false,
    FlySpeed        = 75,
    Noclip          = false,
    InfJump         = false,
    Ghost           = false,
    Freeze          = false,
    Spin            = false,
    SpinSpeed       = 8,
    BigHead         = false,
    BigHeadScale    = 5,
    AntiVoid        = false,
    LowGrav         = false,
    GravVal         = 60,
    -- Visual
    ESP             = true,
    Fullbright      = false,
    NoFog           = false,
    Crosshair       = false,
    FPSBoost        = false,
    -- Combat
    Aimbot          = false,
    AimbotFOV       = 200,
    AimbotSmooth    = 3,
    HitboxExp       = false,
    HitboxSize      = 8,
    TriggerBot      = false,
    -- Fun
    Jerk            = false,
    Fling           = false,
    -- Bypass
    AntiKick        = true,
    AntiAFK         = true,
    RemoteFilter    = true,
    AntiTP          = false,
    -- Misc
    ChatSpam        = false,
    ChatMsg         = "hi",
    ChatDelay       = 3,
    CopyWalk        = false,
    CopyTarget      = "",
    TimeChange      = false,
    TimeVal         = 14,
}

-- ════════════════════════════════════════
-- THEME
-- ════════════════════════════════════════
local T = {
    BG1     = Color3.fromRGB(18, 18, 28),
    BG2     = Color3.fromRGB(25, 25, 40),
    BG3     = Color3.fromRGB(30, 30, 45),
    BG4     = Color3.fromRGB(38, 38, 55),
    ACC     = Color3.fromRGB(0, 170, 255),
    ACCD    = Color3.fromRGB(0, 120, 200),
    ACCL    = Color3.fromRGB(80, 200, 255),
    GRN     = Color3.fromRGB(0, 170, 100),
    RED     = Color3.fromRGB(220, 50, 50),
    YLW     = Color3.fromRGB(220, 185, 50),
    PNK     = Color3.fromRGB(220, 80, 180),
    TXT     = Color3.fromRGB(255, 255, 255),
    TXTG    = Color3.fromRGB(160, 160, 180),
    BDR     = Color3.fromRGB(50, 50, 70),
}

-- ════════════════════════════════════════
-- HELPERS
-- ════════════════════════════════════════
local function Char()   return LocalPlayer.Character end
local function Hum()    local c=Char() return c and c:FindFirstChildOfClass("Humanoid") end
local function HRP()    local c=Char() return c and c:FindFirstChild("HumanoidRootPart") end
local function Head()   local c=Char() return c and c:FindFirstChild("Head") end

local function Notify(title, msg, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title, Text = msg, Duration = dur or 3
        })
    end)
end

local function Tw(obj, goals, t, style)
    if not obj then return end
    pcall(function()
        TweenService:Create(obj, TweenInfo.new(t or 0.25, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), goals):Play()
    end)
end

local function MakeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = parent
    return c
end

local function MakeStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or T.BDR
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function MakeLabel(parent, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamSemibold
    l.TextColor3 = T.TXT
    l.TextScaled = false
    l.TextSize = 14
    for k,v in pairs(props or {}) do
        pcall(function() l[k]=v end)
    end
    l.Parent = parent
    return l
end

-- ════════════════════════════════════════
-- ANTI-CHEAT BYPASS
-- ════════════════════════════════════════
pcall(function()
    LocalPlayer.Kick = function()
        Notify("Bypass", "Kick blocked!", 2)
    end
end)

if VirtualUser then
    pcall(function()
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

if hookmetamethod then
    pcall(function()
        local oldNC
        oldNC = hookmetamethod(game, "__namecall", function(self, ...)
            local m = getnamecallmethod()
            if Settings.AntiKick and (m == "Kick" or m == "kick") then
                Notify("Bypass", "Kick Blocked!", 2)
                return
            end
            if Settings.RemoteFilter and (m == "FireServer" or m == "InvokeServer") then
                local n = string.lower(tostring(self and self.Name or ""))
                local bad = {"anticheat","ac_","exploit","ban","kick","detect","report","flag","cheat"}
                for _, b in ipairs(bad) do
                    if string.find(n, b) then
                        Notify("Bypass", "Remote blocked: " .. tostring(self.Name), 2)
                        return
                    end
                end
            end
            return oldNC(self, ...)
        end)
    end)
end

-- Anti-Teleport
local lastSafePos = nil
RunService.Heartbeat:Connect(function()
    if Settings.AntiTP then
        local h = HRP()
        if h then
            if lastSafePos and (h.Position - lastSafePos).Magnitude > 200 then
                pcall(function() h.CFrame = CFrame.new(lastSafePos) end)
                Notify("Bypass", "Teleport Blocked!", 2)
            end
            lastSafePos = h.Position
        end
    end
end)

-- ════════════════════════════════════════
-- FLY SYSTEM
-- ════════════════════════════════════════
local FlyVel, FlyConn = nil, nil
local FlyKeys = {W=false,A=false,S=false,D=false,Space=false,LeftControl=false}

local function StartFly()
    local h = HRP()
    if not h then return end
    FlyVel = Instance.new("BodyVelocity")
    FlyVel.MaxForce = Vector3.new(9e9,9e9,9e9)
    FlyVel.Velocity = Vector3.zero
    FlyVel.Parent = h
    local hm = Hum()
    if hm then pcall(function() hm.PlatformStand = true end) end
    FlyConn = RunService.Heartbeat:Connect(function()
        if not Settings.Fly then return end
        local cam = Camera
        if not cam or not FlyVel then return end
        local m = Vector3.zero
        if FlyKeys.W     then m = m + cam.CFrame.LookVector end
        if FlyKeys.S     then m = m - cam.CFrame.LookVector end
        if FlyKeys.A     then m = m - cam.CFrame.RightVector end
        if FlyKeys.D     then m = m + cam.CFrame.RightVector end
        if FlyKeys.Space then m = m + Vector3.new(0,1,0) end
        if FlyKeys.LeftControl then m = m - Vector3.new(0,1,0) end
        if m.Magnitude > 0 then m = m.Unit * Settings.FlySpeed end
        FlyVel.Velocity = m
    end)
end

local function StopFly()
    if FlyConn then FlyConn:Disconnect() FlyConn = nil end
    pcall(function()
        if FlyVel then FlyVel:Destroy() FlyVel = nil end
        local hm = Hum()
        if hm then hm.PlatformStand = false end
    end)
end

-- ════════════════════════════════════════
-- JERK SYSTEM
-- ════════════════════════════════════════
local jerkRunning = false
local function RunJerk()
    if jerkRunning then return end
    jerkRunning = true
    task.spawn(function()
        while Settings.Jerk do
            local h = HRP()
            if h then
                pcall(function()
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
                    bv.Velocity = Vector3.new(
                        math.random(-250,250),
                        math.random(-80,250),
                        math.random(-250,250)
                    )
                    bv.Parent = h
                    task.wait(0.055)
                    bv:Destroy()

                    local ba = Instance.new("BodyAngularVelocity")
                    ba.MaxTorque = Vector3.new(9e9,9e9,9e9)
                    ba.AngularVelocity = Vector3.new(
                        math.random(-30,30),
                        math.random(-30,30),
                        math.random(-30,30)
                    )
                    ba.Parent = h
                    task.wait(0.055)
                    ba:Destroy()
                end)
            end
            task.wait(0.08)
        end
        jerkRunning = false
    end)
end

-- ════════════════════════════════════════
-- FLING SYSTEM
-- ════════════════════════════════════════
local flingRunning = false
local function RunFling()
    if flingRunning then return end
    flingRunning = true
    task.spawn(function()
        while Settings.Fling do
            local h = HRP()
            if h then
                pcall(function()
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
                    bv.Velocity = Vector3.new(
                        math.random(-400,400),
                        math.random(150,400),
                        math.random(-400,400)
                    )
                    bv.Parent = h
                    task.wait(0.15)
                    bv:Destroy()
                end)
            end
            task.wait(0.4)
        end
        flingRunning = false
    end)
end

-- ════════════════════════════════════════
-- FEATURE LOOPS
-- ════════════════════════════════════════

-- Main RunService loop
RunService.RenderStepped:Connect(function()
    local hm = Hum()
    local h  = HRP()
    local hd = Head()

    -- Speed
    if hm and Settings.Speed then
        pcall(function() hm.WalkSpeed = Settings.WalkSpeed end)
    end

    -- JumpPower
    if hm and Settings.JumpPower then
        pcall(function()
            hm.JumpPower = Settings.JumpVal
            hm.UseJumpPower = true
        end)
    end

    -- Spin
    if h and Settings.Spin then
        pcall(function()
            h.CFrame = h.CFrame * CFrame.Angles(0, math.rad(Settings.SpinSpeed), 0)
        end)
    end

    -- BigHead
    if hd and Settings.BigHead then
        pcall(function()
            hd.Size = Vector3.new(Settings.BigHeadScale, Settings.BigHeadScale, Settings.BigHeadScale)
        end)
    end

    -- Gravity
    if Settings.LowGrav then
        pcall(function() workspace.Gravity = Settings.GravVal end)
    end

    -- Time
    if Settings.TimeChange then
        pcall(function() Lighting.ClockTime = Settings.TimeVal end)
    end

    -- Fullbright
    if Settings.Fullbright then
        pcall(function()
            Lighting.Brightness = 10
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 1e9
        end)
    end

    -- No Fog
    if Settings.NoFog and not Settings.Fullbright then
        pcall(function() Lighting.FogEnd = 1e9 end)
    end

    -- Anti Void
    if h and Settings.AntiVoid and h.Position.Y < -150 then
        pcall(function() h.CFrame = CFrame.new(h.Position.X, 10, h.Position.Z) end)
    end

    -- Jerk / Fling triggers
    if Settings.Jerk  then RunJerk() end
    if Settings.Fling then RunFling() end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if Settings.Noclip then
        local c = Char()
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then
                    pcall(function() p.CanCollide = false end)
                end
            end
        end
    end
end)

-- Ghost
RunService.Heartbeat:Connect(function()
    if Settings.Ghost then
        local c = Char()
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then
                    pcall(function() p.CanCollide = false p.Transparency = 0.6 end)
                end
            end
        end
    end
end)

-- Freeze
RunService.Heartbeat:Connect(function()
    local h = HRP()
    if not h then return end
    if Settings.Freeze then
        pcall(function() h.Anchored = true end)
    elseif h.Anchored then
        pcall(function() h.Anchored = false end)
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump then
        local hm = Hum()
        if hm then pcall(function() hm:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    end
end)

-- FPS Boost
RunService.Heartbeat:Connect(function()
    if Settings.FPSBoost then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                pcall(function() v.Enabled = false end)
            end
        end
    end
end)

-- Hitbox Expander
RunService.Heartbeat:Connect(function()
    if Settings.HitboxExp then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hr = p.Character:FindFirstChild("HumanoidRootPart")
                if hr then
                    pcall(function()
                        hr.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                    end)
                end
            end
        end
    end
end)

-- TriggerBot
RunService.Heartbeat:Connect(function()
    if not Settings.TriggerBot then return end
    local ray = Camera:ViewportPointToRay(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local res = workspace:Raycast(ray.Origin, ray.Direction * 1000)
    if res and res.Instance then
        local mdl = res.Instance:FindFirstAncestorOfClass("Model")
        if mdl then
            local pl = Players:GetPlayerFromCharacter(mdl)
            if pl and pl ~= LocalPlayer then
                if mouse1press then mouse1press() task.wait(0.05) mouse1release() end
            end
        end
    end
end)

-- Copy Walk
RunService.Heartbeat:Connect(function()
    if Settings.CopyWalk and Settings.CopyTarget ~= "" then
        local t = Players:FindFirstChild(Settings.CopyTarget)
        if t and t.Character then
            local th = t.Character:FindFirstChild("HumanoidRootPart")
            local mh = HRP()
            if th and mh then pcall(function() mh.CFrame = th.CFrame * CFrame.new(3,0,0) end) end
        end
    end
end)

-- Chat Spam
task.spawn(function()
    while true do
        task.wait(math.max(Settings.ChatDelay, 1))
        if Settings.ChatSpam then
            pcall(function()
                local tcs = game:GetService("TextChatService")
                if tcs and tcs.TextChannels then
                    local ch = tcs.TextChannels:FindFirstChild("RBXGeneral")
                    if ch then ch:SendAsync(Settings.ChatMsg) end
                end
            end)
        end
    end
end)

-- Aimbot
RunService.Heartbeat:Connect(function()
    if not Settings.Aimbot then return end
    if not UserInputService:IsKeyDown(Enum.KeyCode.E) then return end
    local mp = UserInputService:GetMouseLocation()
    local best, bd = nil, Settings.AimbotFOV
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local c = p.Character if not c then continue end
        local hd = c:FindFirstChild("Head") if not hd then continue end
        local pos, on = Camera:WorldToViewportPoint(hd.Position)
        if not on then continue end
        local d = (Vector2.new(pos.X,pos.Y)-mp).Magnitude
        if d < bd then bd=d best=hd end
    end
    if best and mousemoverel then
        local pos = Camera:WorldToViewportPoint(best.Position)
        local diff = Vector2.new(pos.X,pos.Y)-mp
        local s = Settings.AimbotSmooth / 10
        mousemoverel(diff.X*s, diff.Y*s)
    end
end)

-- Character respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Settings.Fly then StopFly() task.wait(0.3) StartFly() end
end)

-- ════════════════════════════════════════
-- ESP (Drawing API - your working version)
-- ════════════════════════════════════════
local ESP = {}
local ESPNames = {}
local ESPHealthBars = {}
local ESPLines = {}

local function AddESP(plr)
    if plr == LocalPlayer then return end

    -- Box
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Color = Color3.fromRGB(0, 170, 255)
    box.Transparency = 1
    box.Visible = false
    ESP[plr] = box

    -- Name
    local name = Drawing.new("Text")
    name.Size = 14
    name.Center = true
    name.Outline = true
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Visible = false
    name.Text = plr.Name
    ESPNames[plr] = name

    -- Health bar
    local hbar = Drawing.new("Line")
    hbar.Thickness = 3
    hbar.Color = Color3.fromRGB(0, 255, 100)
    hbar.Visible = false
    ESPHealthBars[plr] = hbar

    -- Tracer line
    local line = Drawing.new("Line")
    line.Thickness = 1
    line.Color = Color3.fromRGB(255, 50, 50)
    line.Visible = false
    ESPLines[plr] = line
end

for _, plr in ipairs(Players:GetPlayers()) do AddESP(plr) end
Players.PlayerAdded:Connect(AddESP)

Players.PlayerRemoving:Connect(function(plr)
    if ESP[plr] then ESP[plr]:Remove() ESP[plr]=nil end
    if ESPNames[plr] then ESPNames[plr]:Remove() ESPNames[plr]=nil end
    if ESPHealthBars[plr] then ESPHealthBars[plr]:Remove() ESPHealthBars[plr]=nil end
    if ESPLines[plr] then ESPLines[plr]:Remove() ESPLines[plr]=nil end
end)

RunService.RenderStepped:Connect(function()
    for plr, box in pairs(ESP) do
        if Settings.ESP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local dist = (Camera.CFrame.Position - root.Position).Magnitude
                local size = 1800 / dist

                -- Box
                box.Size = Vector2.new(size, size * 2.2)
                box.Position = Vector2.new(pos.X - size/2, pos.Y - size * 1.1)
                box.Visible = true

                -- Name
                if ESPNames[plr] then
                    ESPNames[plr].Position = Vector2.new(pos.X, pos.Y - size * 1.1 - 18)
                    ESPNames[plr].Text = plr.Name .. " [" .. math.floor(dist) .. "]"
                    ESPNames[plr].Visible = true
                end

                -- Health bar
                if ESPHealthBars[plr] then
                    local hm = plr.Character:FindFirstChildOfClass("Humanoid")
                    if hm then
                        local hp = hm.Health / hm.MaxHealth
                        local barH = size * 2.2
                        local startY = pos.Y - size * 1.1
                        local hColor
                        if hp > 0.6 then
                            hColor = Color3.fromRGB(0, 255, 100)
                        elseif hp > 0.3 then
                            hColor = Color3.fromRGB(255, 200, 0)
                        else
                            hColor = Color3.fromRGB(255, 50, 50)
                        end
                        ESPHealthBars[plr].From = Vector2.new(pos.X - size/2 - 6, startY + barH * (1-hp))
                        ESPHealthBars[plr].To   = Vector2.new(pos.X - size/2 - 6, startY + barH)
                        ESPHealthBars[plr].Color = hColor
                        ESPHealthBars[plr].Visible = true
                    end
                end

                -- Tracer
                if ESPLines[plr] then
                    ESPLines[plr].From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    ESPLines[plr].To   = Vector2.new(pos.X, pos.Y)
                    ESPLines[plr].Visible = true
                end
            else
                box.Visible = false
                if ESPNames[plr] then ESPNames[plr].Visible = false end
                if ESPHealthBars[plr] then ESPHealthBars[plr].Visible = false end
                if ESPLines[plr] then ESPLines[plr].Visible = false end
            end
        else
            box.Visible = false
            if ESPNames[plr] then ESPNames[plr].Visible = false end
            if ESPHealthBars[plr] then ESPHealthBars[plr].Visible = false end
            if ESPLines[plr] then ESPLines[plr].Visible = false end
        end
    end
end)

-- Crosshair (Drawing API)
local CHLine1 = Drawing.new("Line")
CHLine1.Thickness = 2
CHLine1.Color = Color3.fromRGB(255,255,255)
CHLine1.Visible = false

local CHLine2 = Drawing.new("Line")
CHLine2.Thickness = 2
CHLine2.Color = Color3.fromRGB(255,255,255)
CHLine2.Visible = false

local CHCircle = Drawing.new("Circle")
CHCircle.Thickness = 1
CHCircle.Filled = false
CHCircle.Color = Color3.fromRGB(255,255,255)
CHCircle.Radius = 60
CHCircle.Visible = false

RunService.RenderStepped:Connect(function()
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2
    CHLine1.From = Vector2.new(cx, cy - 14)
    CHLine1.To   = Vector2.new(cx, cy + 14)
    CHLine2.From = Vector2.new(cx - 14, cy)
    CHLine2.To   = Vector2.new(cx + 14, cy)
    CHCircle.Position = Vector2.new(cx, cy)
    CHLine1.Visible = Settings.Crosshair
    CHLine2.Visible = Settings.Crosshair
    CHCircle.Visible = Settings.Crosshair and Settings.Aimbot
    if CHCircle.Visible then
        CHCircle.Radius = Settings.AimbotFOV
    end
end)

-- ════════════════════════════════════════
-- INPUT HANDLER
-- ════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    local k = tostring(input.KeyCode):gsub("Enum.KeyCode.","")
    if ({W=true,A=true,S=true,D=true,Space=true,LeftControl=true})[k] then
        FlyKeys[k] = true
    end

    -- F = Fly toggle
    if input.KeyCode == Enum.KeyCode.F then
        Settings.Fly = not Settings.Fly
        if Settings.Fly then StartFly() else StopFly() end
        Notify("Fly", Settings.Fly and "ON" or "OFF", 2)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local k = tostring(input.KeyCode):gsub("Enum.KeyCode.","")
    if ({W=true,A=true,S=true,D=true,Space=true,LeftControl=true})[k] then
        FlyKeys[k] = false
    end
end)

-- ════════════════════════════════════════
-- GUI BUILDER
-- ════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CoolGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

-- ── Main Frame ───────────────────────────────────────────────
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 700, 0, 520)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -260)
MainFrame.BackgroundColor3 = T.BG1
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
MakeCorner(MainFrame, 16)
MakeStroke(MainFrame, T.BDR, 1)

-- Shadow image
local shadowImg = Instance.new("ImageLabel")
shadowImg.BackgroundTransparency = 1
shadowImg.Image = "rbxassetid://5554236805"
shadowImg.ImageColor3 = Color3.new(0,0,0)
shadowImg.ImageTransparency = 0.5
shadowImg.Position = UDim2.new(0,-20,0,-20)
shadowImg.Size = UDim2.new(1,40,1,40)
shadowImg.ZIndex = 0
shadowImg.Parent = MainFrame

-- ── Title Bar ────────────────────────────────────────────────
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 58)
TitleBar.BackgroundColor3 = T.BG2
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
MakeCorner(TitleBar, 16)

-- Fix bottom corners of title
local titleFix = Instance.new("Frame")
titleFix.BackgroundColor3 = T.BG2
titleFix.BorderSizePixel = 0
titleFix.Position = UDim2.new(0,0,0.5,0)
titleFix.Size = UDim2.new(1,0,0.5,0)
titleFix.Parent = TitleBar

-- Accent line under title
local accentLine = Instance.new("Frame")
accentLine.BackgroundColor3 = T.ACC
accentLine.BorderSizePixel = 0
accentLine.Position = UDim2.new(0,0,1,-2)
accentLine.Size = UDim2.new(1,0,0,2)
accentLine.Parent = TitleBar

-- Colored dot logo
local logoDot = Instance.new("Frame")
logoDot.BackgroundColor3 = T.ACC
logoDot.BorderSizePixel = 0
logoDot.Position = UDim2.new(0,16,0.5,-12)
logoDot.Size = UDim2.new(0,24,0,24)
logoDot.Parent = TitleBar
MakeCorner(logoDot, 6)

-- Title label
local TitleLabel = Instance.new("TextLabel")
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.Position = UDim2.new(0,48,0,0)
TitleLabel.Size = UDim2.new(0,200,1,0)
TitleLabel.Text = "COOLGUI"
TitleLabel.TextColor3 = T.TXT
TitleLabel.TextSize = 24
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Version badge
local verBG = Instance.new("Frame")
verBG.BackgroundColor3 = T.ACCD
verBG.BorderSizePixel = 0
verBG.Position = UDim2.new(0,248,0.5,-12)
verBG.Size = UDim2.new(0,44,0,24)
verBG.Parent = TitleBar
MakeCorner(verBG, 5)

local verLabel = Instance.new("TextLabel")
verLabel.BackgroundTransparency = 1
verLabel.Font = Enum.Font.GothamBold
verLabel.Size = UDim2.new(1,0,1,0)
verLabel.Text = "v7.0"
verLabel.TextColor3 = T.TXT
verLabel.TextSize = 12
verLabel.Parent = verBG

-- Hint label
local hintLabel = Instance.new("TextLabel")
hintLabel.BackgroundTransparency = 1
hintLabel.Font = Enum.Font.Gotham
hintLabel.Position = UDim2.new(0,302,0,0)
hintLabel.Size = UDim2.new(0,220,1,0)
hintLabel.Text = "RShift = Toggle  •  F = Fly  •  E = Aim"
hintLabel.TextColor3 = T.TXTG
hintLabel.TextSize = 12
hintLabel.TextXAlignment = Enum.TextXAlignment.Left
hintLabel.Parent = TitleBar

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.BackgroundColor3 = T.RED
CloseBtn.BorderSizePixel = 0
CloseBtn.Position = UDim2.new(1,-44,0.5,-14)
CloseBtn.Size = UDim2.new(0,28,0,28)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = T.TXT
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TitleBar
MakeCorner(CloseBtn, 7)

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.BackgroundColor3 = T.YLW
MinBtn.BorderSizePixel = 0
MinBtn.Position = UDim2.new(1,-80,0.5,-14)
MinBtn.Size = UDim2.new(0,28,0,28)
MinBtn.Text = "—"
MinBtn.TextColor3 = T.BG1
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.Parent = TitleBar
MakeCorner(MinBtn, 7)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Tw(MainFrame, {Size = minimized and UDim2.new(0,700,0,58) or UDim2.new(0,700,0,520)}, 0.3)
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- ── Drag ─────────────────────────────────────────────────────
local dragging, dragStart, startPos = false, nil, nil
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ── Sidebar ───────────────────────────────────────────────────
local Sidebar = Instance.new("Frame")
Sidebar.BackgroundColor3 = T.BG2
Sidebar.BorderSizePixel = 0
Sidebar.Position = UDim2.new(0,0,0,58)
Sidebar.Size = UDim2.new(0,165,1,-58)
Sidebar.Parent = MainFrame
MakeCorner(Sidebar, 16)

local sidebarFix = Instance.new("Frame")
sidebarFix.BackgroundColor3 = T.BG2
sidebarFix.BorderSizePixel = 0
sidebarFix.Position = UDim2.new(1,-16,0,0)
sidebarFix.Size = UDim2.new(0,16,1,0)
sidebarFix.Parent = Sidebar

local sidebarBorder = Instance.new("Frame")
sidebarBorder.BackgroundColor3 = T.BDR
sidebarBorder.BorderSizePixel = 0
sidebarBorder.Position = UDim2.new(1,-1,0,0)
sidebarBorder.Size = UDim2.new(0,1,1,0)
sidebarBorder.Parent = Sidebar

-- Player card
local playerCard = Instance.new("Frame")
playerCard.BackgroundColor3 = T.BG3
playerCard.BorderSizePixel = 0
playerCard.Position = UDim2.new(0,10,0,10)
playerCard.Size = UDim2.new(1,-20,0,52)
playerCard.Parent = Sidebar
MakeCorner(playerCard, 8)

MakeLabel(playerCard, {
    Position=UDim2.new(0,10,0,6),
    Size=UDim2.new(1,-20,0,20),
    Text=LocalPlayer.Name,
    Font=Enum.Font.GothamBold,
    TextSize=13,
    TextXAlignment=Enum.TextXAlignment.Left,
    TextTruncate=Enum.TextTruncate.AtEnd
})
MakeLabel(playerCard, {
    Position=UDim2.new(0,10,0,27),
    Size=UDim2.new(1,-20,0,16),
    Text="ID: "..LocalPlayer.UserId,
    TextColor3=T.TXTG,
    TextSize=11,
    TextXAlignment=Enum.TextXAlignment.Left
})

-- Tab button list
local TabList = Instance.new("Frame")
TabList.BackgroundTransparency = 1
TabList.Position = UDim2.new(0,10,0,72)
TabList.Size = UDim2.new(1,-20,1,-82)
TabList.Parent = Sidebar

local tabListLayout = Instance.new("UIListLayout")
tabListLayout.Padding = UDim.new(0,5)
tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabListLayout.Parent = TabList

-- Content area
local ContentArea = Instance.new("Frame")
ContentArea.BackgroundTransparency = 1
ContentArea.Position = UDim2.new(0,165,0,58)
ContentArea.Size = UDim2.new(1,-165,1,-58)
ContentArea.Parent = MainFrame

-- ════════════════════════════════════════
-- TAB SYSTEM
-- ════════════════════════════════════════
local Tabs = {}
local ActiveTab = nil

local function MakeTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.BackgroundColor3 = T.BG2
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(1,0,0,38)
    btn.Text = ""
    btn.Parent = TabList
    MakeCorner(btn, 7)

    local iconLabel = Instance.new("TextLabel")
    iconLabel.BackgroundTransparency = 1
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Position = UDim2.new(0,10,0,0)
    iconLabel.Size = UDim2.new(0,26,1,0)
    iconLabel.Text = icon
    iconLabel.TextColor3 = T.TXTG
    iconLabel.TextSize = 15
    iconLabel.Parent = btn

    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Position = UDim2.new(0,38,0,0)
    nameLabel.Size = UDim2.new(1,-48,1,0)
    nameLabel.Text = name
    nameLabel.TextColor3 = T.TXTG
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = btn

    local indicator = Instance.new("Frame")
    indicator.BackgroundColor3 = T.ACC
    indicator.BorderSizePixel = 0
    indicator.Position = UDim2.new(0,0,0.2,0)
    indicator.Size = UDim2.new(0,3,0.6,0)
    indicator.Visible = false
    indicator.Parent = btn
    MakeCorner(indicator, 2)

    -- Scroll content
    local scroll = Instance.new("ScrollingFrame")
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.Position = UDim2.new(0,14,0,10)
    scroll.Size = UDim2.new(1,-28,1,-20)
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = T.ACC
    scroll.Visible = false
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.Parent = ContentArea

    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.Padding = UDim.new(0,10)
    scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    scrollLayout.Parent = scroll

    scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0,0,0,scrollLayout.AbsoluteContentSize.Y + 20)
    end)

    Tabs[name] = {B=btn, C=scroll, I=indicator, NL=nameLabel}

    btn.MouseButton1Click:Connect(function()
        if ActiveTab == name then return end
        if ActiveTab and Tabs[ActiveTab] then
            Tw(Tabs[ActiveTab].B, {BackgroundColor3=T.BG2}, 0.15)
            Tabs[ActiveTab].NL.TextColor3 = T.TXTG
            Tabs[ActiveTab].I.Visible = false
            Tabs[ActiveTab].C.Visible = false
        end
        ActiveTab = name
        Tw(btn, {BackgroundColor3=T.BG3}, 0.15)
        nameLabel.TextColor3 = T.ACCL
        indicator.Visible = true
        scroll.Visible = true
    end)

    return Tabs[name]
end

-- ════════════════════════════════════════
-- COMPONENT BUILDERS
-- ════════════════════════════════════════
local function SectionLabel(parent, text)
    local f = Instance.new("Frame")
    f.BackgroundTransparency = 1
    f.Size = UDim2.new(1,0,0,22)
    f.Parent = parent

    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.Size = UDim2.new(1,0,1,0)
    l.Text = "  " .. text:upper()
    l.TextColor3 = T.ACC
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local line = Instance.new("Frame")
    line.BackgroundColor3 = T.BDR
    line.BorderSizePixel = 0
    line.Position = UDim2.new(0,0,1,-1)
    line.Size = UDim2.new(1,0,0,1)
    line.Parent = f
    return f
end

local function CreateToggle(parent, name, desc, settingKey, callback)
    local h = desc and 60 or 48
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = T.BG3
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1,0,0,h)
    frame.Parent = parent
    MakeCorner(frame, 10)
    MakeStroke(frame, T.BDR, 1)

    local nameL = Instance.new("TextLabel")
    nameL.BackgroundTransparency = 1
    nameL.Font = Enum.Font.GothamBold
    nameL.Position = UDim2.new(0,13,0,desc and 8 or 0)
    nameL.Size = UDim2.new(1,-68,0,22)
    nameL.Text = name
    nameL.TextColor3 = T.TXT
    nameL.TextSize = 14
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.Parent = frame

    if desc then
        local descL = Instance.new("TextLabel")
        descL.BackgroundTransparency = 1
        descL.Font = Enum.Font.Gotham
        descL.Position = UDim2.new(0,13,0,30)
        descL.Size = UDim2.new(1,-68,0,18)
        descL.Text = desc
        descL.TextColor3 = T.TXTG
        descL.TextSize = 11
        descL.TextXAlignment = Enum.TextXAlignment.Left
        descL.Parent = frame
    end

    local switchBG = Instance.new("Frame")
    switchBG.BackgroundColor3 = T.BG1
    switchBG.BorderSizePixel = 0
    switchBG.Position = UDim2.new(1,-56,0.5,-13)
    switchBG.Size = UDim2.new(0,44,0,26)
    switchBG.Parent = frame
    MakeCorner(switchBG, 13)
    MakeStroke(switchBG, T.BDR, 1)

    local knob = Instance.new("Frame")
    knob.BackgroundColor3 = T.TXTG
    knob.BorderSizePixel = 0
    knob.Position = UDim2.new(0,3,0.5,-10)
    knob.Size = UDim2.new(0,20,0,20)
    knob.Parent = switchBG
    MakeCorner(knob, 10)

    local state = settingKey and Settings[settingKey] or false

    local function SetState(s)
        state = s
        if settingKey then Settings[settingKey] = s end
        Tw(knob, {
            Position = s and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10),
            BackgroundColor3 = s and T.GRN or T.TXTG
        }, 0.2)
        Tw(switchBG, {BackgroundColor3 = s and Color3.fromRGB(0,100,60) or T.BG1}, 0.2)
        if callback then callback(s) end
    end

    if state then SetState(true) end

    local clickBtn = Instance.new("TextButton")
    clickBtn.BackgroundTransparency = 1
    clickBtn.Size = UDim2.new(1,0,1,0)
    clickBtn.Text = ""
    clickBtn.Parent = frame

    clickBtn.MouseButton1Click:Connect(function()
        SetState(not state)
    end)

    clickBtn.MouseEnter:Connect(function() Tw(frame,{BackgroundColor3=T.BG4},0.1) end)
    clickBtn.MouseLeave:Connect(function() Tw(frame,{BackgroundColor3=T.BG3},0.1) end)

    return frame, SetState
end

local function CreateSlider(parent, name, min, max, default, settingKey, callback)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = T.BG3
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1,0,0,78)
    frame.Parent = parent
    MakeCorner(frame, 10)
    MakeStroke(frame, T.BDR, 1)

    local valueL = Instance.new("TextLabel")
    valueL.BackgroundTransparency = 1
    valueL.Font = Enum.Font.GothamBold
    valueL.Position = UDim2.new(1,-55,0,9)
    valueL.Size = UDim2.new(0,45,0,20)
    valueL.Text = tostring(default)
    valueL.TextColor3 = T.ACCL
    valueL.TextSize = 14
    valueL.Parent = frame

    local nameL = Instance.new("TextLabel")
    nameL.BackgroundTransparency = 1
    nameL.Font = Enum.Font.GothamBold
    nameL.Position = UDim2.new(0,13,0,9)
    nameL.Size = UDim2.new(1,-80,0,20)
    nameL.Text = name
    nameL.TextColor3 = T.TXT
    nameL.TextSize = 14
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.Parent = frame

    local track = Instance.new("Frame")
    track.BackgroundColor3 = T.BG1
    track.BorderSizePixel = 0
    track.Position = UDim2.new(0,13,0,43)
    track.Size = UDim2.new(1,-26,0,8)
    track.Parent = frame
    MakeCorner(track, 4)
    MakeStroke(track, T.BDR, 1)

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = T.ACC
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    fill.Parent = track
    MakeCorner(fill, 4)

    local sknob = Instance.new("Frame")
    sknob.BackgroundColor3 = T.TXT
    sknob.BorderSizePixel = 0
    sknob.Position = UDim2.new((default-min)/(max-min),-7,0.5,-7)
    sknob.Size = UDim2.new(0,14,0,14)
    sknob.Parent = track
    MakeCorner(sknob, 7)
    MakeStroke(sknob, T.ACC, 2)

    -- Min/Max
    local function mkMinMax(txt, pos)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency=1 l.Font=Enum.Font.Gotham
        l.Position=pos l.Size=UDim2.new(0,40,0,14)
        l.Text=txt l.TextColor3=Color3.fromRGB(80,80,100) l.TextSize=10
        l.Parent=frame
    end
    mkMinMax(tostring(min), UDim2.new(0,13,0,56))
    mkMinMax(tostring(max), UDim2.new(1,-53,0,56))

    local isDragging = false

    local function Update(x)
        local pos = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max-min) * pos)
        fill.Size = UDim2.new(pos,0,1,0)
        sknob.Position = UDim2.new(pos,-7,0.5,-7)
        valueL.Text = tostring(val)
        if settingKey then Settings[settingKey] = val end
        if callback then callback(val) end
    end

    sknob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = true end
    end)
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            Update(i.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if isDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            Update(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end
    end)

    return frame
end

local function CreateButton(parent, name, desc, color, callback)
    local h = desc and 58 or 44
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = color or T.ACC
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(1,0,0,h)
    btn.Text = ""
    btn.Parent = parent
    MakeCorner(btn, 10)

    local nameL = Instance.new("TextLabel")
    nameL.BackgroundTransparency = 1
    nameL.Font = Enum.Font.GothamBold
    nameL.Position = UDim2.new(0,13,0,desc and 9 or 0)
    nameL.Size = UDim2.new(1,-26,0,26)
    nameL.Text = name
    nameL.TextColor3 = T.TXT
    nameL.TextSize = 14
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.Parent = btn

    if desc then
        local descL = Instance.new("TextLabel")
        descL.BackgroundTransparency = 1
        descL.Font = Enum.Font.Gotham
        descL.Position = UDim2.new(0,13,0,32)
        descL.Size = UDim2.new(1,-26,0,18)
        descL.Text = desc
        descL.TextColor3 = Color3.fromRGB(220,220,220)
        descL.TextSize = 11
        descL.TextXAlignment = Enum.TextXAlignment.Left
        descL.Parent = btn
    end

    local og = color or T.ACC
    btn.MouseEnter:Connect(function() Tw(btn,{BackgroundColor3=T.ACCL},0.1) end)
    btn.MouseLeave:Connect(function() Tw(btn,{BackgroundColor3=og},0.1) end)
    btn.MouseButton1Click:Connect(function()
        Tw(btn,{BackgroundColor3=T.ACCD},0.08)
        task.delay(0.15,function() Tw(btn,{BackgroundColor3=og},0.1) end)
        if callback then callback() end
    end)
    return btn
end

local function CreateTextInput(parent, name, placeholder, callback)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = T.BG3
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1,0,0,70)
    frame.Parent = parent
    MakeCorner(frame, 10)
    MakeStroke(frame, T.BDR, 1)

    MakeLabel(frame, {
        Position=UDim2.new(0,13,0,9),
        Size=UDim2.new(1,-26,0,20),
        Text=name, TextSize=14, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left
    })

    local box = Instance.new("TextBox")
    box.BackgroundColor3 = T.BG1
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    box.Font = Enum.Font.Gotham
    box.PlaceholderColor3 = Color3.fromRGB(80,80,100)
    box.PlaceholderText = placeholder or "..."
    box.Position = UDim2.new(0,13,0,36)
    box.Size = UDim2.new(1,-26,0,26)
    box.Text = ""
    box.TextColor3 = T.TXT
    box.TextSize = 13
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.Parent = frame
    MakeCorner(box, 5)
    MakeStroke(box, T.BDR, 1)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0,7)
    pad.Parent = box

    box.FocusLost:Connect(function()
        if callback then callback(box.Text) end
    end)

    return frame, box
end

-- ════════════════════════════════════════
-- BUILD TABS
-- ════════════════════════════════════════

-- PLAYER TAB
local PT = MakeTab("Player","👤")
SectionLabel(PT.C,"Movement")
CreateToggle(PT.C,"Speed Hack","Override walk speed","Speed")
CreateSlider(PT.C,"WalkSpeed",16,500,140,"WalkSpeed")
CreateToggle(PT.C,"Jump Power","Override jump height","JumpPower")
CreateSlider(PT.C,"Jump Value",50,500,100,"JumpVal")
CreateToggle(PT.C,"Infinite Jump","Jump again in mid-air","InfJump")
CreateToggle(PT.C,"Fly  [Press F]","WASD+Space+LCtrl to fly",nil)
CreateSlider(PT.C,"Fly Speed",30,250,75,"FlySpeed",function(v) Settings.FlySpeed=v end)
CreateToggle(PT.C,"Noclip","Walk through everything","Noclip")
SectionLabel(PT.C,"Character")
CreateToggle(PT.C,"Ghost Mode","Transparent + no collision","Ghost",function(s)
    if not s then
        local c = Char()
        if c then
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then pcall(function() p.Transparency=0 end) end
            end
        end
    end
end)
CreateToggle(PT.C,"Spin","Rotate your character","Spin")
CreateSlider(PT.C,"Spin Speed",1,50,8,"SpinSpeed")
CreateToggle(PT.C,"Big Head","Giant head","BigHead")
CreateSlider(PT.C,"Head Scale",2,25,5,"BigHeadScale")
CreateToggle(PT.C,"Freeze","Anchor in place","Freeze")
CreateToggle(PT.C,"Anti Void","Catch void falls","AntiVoid")
SectionLabel(PT.C,"Physics")
CreateToggle(PT.C,"Low Gravity","Reduce workspace gravity","LowGrav",function(s)
    if not s then pcall(function() workspace.Gravity = 196.2 end) end
end)
CreateSlider(PT.C,"Gravity Value",1,196,60,"GravVal",function(v) if Settings.LowGrav then workspace.Gravity=v end end)

-- VISUAL TAB
local VT = MakeTab("Visual","👁")
SectionLabel(VT.C,"ESP Options")
CreateToggle(VT.C,"ESP","Player boxes, names, health","ESP")
SectionLabel(VT.C,"World")
CreateToggle(VT.C,"Fullbright","Remove darkness & fog","Fullbright",function(s)
    if not s then
        pcall(function()
            Lighting.Brightness=1
            Lighting.GlobalShadows=true
        end)
    end
end)
CreateToggle(VT.C,"No Fog","Remove fog only","NoFog",function(s)
    if not s then pcall(function() Lighting.FogEnd=1000 end) end
end)
CreateToggle(VT.C,"FPS Boost","Disable particles & effects","FPSBoost")
CreateToggle(VT.C,"Crosshair","Custom crosshair + FOV circle","Crosshair")
SectionLabel(VT.C,"Time")
CreateToggle(VT.C,"Custom Time","Override time of day","TimeChange")
CreateSlider(VT.C,"Time of Day",0,24,14,"TimeVal",function(v) if Settings.TimeChange then Lighting.ClockTime=v end end)

-- COMBAT TAB
local CT = MakeTab("Combat","⚔")
SectionLabel(CT.C,"Aimbot")
CreateToggle(CT.C,"Aimbot  [Hold E]","Lock aim onto nearest player","Aimbot",function(s)
    Notify("Aimbot",s and "Hold E to activate" or "OFF",2)
end)
CreateSlider(CT.C,"Aimbot FOV",30,600,200,"AimbotFOV")
CreateSlider(CT.C,"Smoothness (x10)",1,10,3,"AimbotSmooth")
SectionLabel(CT.C,"Other")
CreateToggle(CT.C,"Hitbox Expander","Expand all enemy hitboxes","HitboxExp")
CreateSlider(CT.C,"Hitbox Size",4,40,8,"HitboxSize")
CreateToggle(CT.C,"TriggerBot","Auto shoot crosshair on enemy","TriggerBot")

-- FUN TAB
local FunT = MakeTab("Fun","🎮")
SectionLabel(FunT.C,"Chaos Mode")
CreateToggle(FunT.C,"JERK 💀","Violently spasm and glitch","Jerk",function(s)
    Notify("Jerk",s and "💀 ACTIVATED" or "OFF",2)
end)
CreateToggle(FunT.C,"Fling","Launch in random directions","Fling",function(s)
    Notify("Fling",s and "ON" or "OFF",2)
end)
SectionLabel(FunT.C,"One-Click Actions")
CreateButton(FunT.C,"🚀 Launch Into Sky","Blast yourself upward",T.ACC,function()
    local h = HRP()
    if not h then return end
    pcall(function()
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(0,9e9,0)
        bv.Velocity = Vector3.new(0,600,0)
        bv.Parent = h
        task.delay(0.3, function() pcall(function() bv:Destroy() end) end)
    end)
end)
CreateButton(FunT.C,"🎯 Teleport To Random Player","Jump to a random person",T.ACC,function()
    local pl = {}
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(pl,p) end
    end
    if #pl == 0 then Notify("TP","No other players!",2) return end
    local t = pl[math.random(1,#pl)]
    if t.Character then
        local th = t.Character:FindFirstChild("HumanoidRootPart")
        local mh = HRP()
        if th and mh then
            pcall(function() mh.CFrame = th.CFrame * CFrame.new(3,0,0) end)
            Notify("TP","→ "..t.Name, 2)
        end
    end
end)
CreateButton(FunT.C,"💥 Explode At Feet","Spawn explosion",T.RED,function()
    local h = HRP()
    if not h then return end
    pcall(function()
        local e = Instance.new("Explosion")
        e.Position = h.Position
        e.BlastRadius = 25
        e.BlastPressure = 4e5
        e.DestroyJointRadiusPercent = 0
        e.Parent = workspace
    end)
end)
CreateButton(FunT.C,"⚡ Speed Burst (2s)","500 speed for 2 seconds",T.GRN,function()
    local old = Settings.WalkSpeed
    Settings.WalkSpeed = 500
    Settings.Speed = true
    task.delay(2, function()
        Settings.WalkSpeed = old
    end)
    Notify("Speed Burst","2 seconds!",2)
end)
CreateButton(FunT.C,"🌀 Spin Fling (3s)","Spin + fling combo",Color3.fromRGB(150,50,220),function()
    Settings.Spin = true
    Settings.Fling = true
    Notify("SpinFling","3 second chaos!",2)
    task.delay(3, function()
        Settings.Spin = false
        Settings.Fling = false
    end)
end)
CreateButton(FunT.C,"📡 Fake Disconnect","Troll fake DC screen",T.YLW,function()
    local g = Instance.new("ScreenGui")
    g.Name = "FakeDC"
    g.ResetOnSpawn = false
    g.DisplayOrder = 9999
    g.Parent = PlayerGui
    local l = Instance.new("TextLabel")
    l.BackgroundColor3 = Color3.new(0,0,0)
    l.BackgroundTransparency = 0.15
    l.Size = UDim2.new(1,0,1,0)
    l.Text = "Roblox\n\nAttempting to reconnect...\n\nError Code: 277"
    l.TextColor3 = Color3.new(1,1,1)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 30
    l.Parent = g
    task.delay(4, function() pcall(function() g:Destroy() end) end)
end)

-- MISC TAB
local MT = MakeTab("Misc","⚙")
SectionLabel(MT.C,"Chat")
CreateToggle(MT.C,"Chat Spammer","Send message repeatedly","ChatSpam")
CreateTextInput(MT.C,"Spam Message","Type here...",function(v) Settings.ChatMsg = v end)
CreateSlider(MT.C,"Spam Delay (s)",1,30,3,"ChatDelay")
SectionLabel(MT.C,"Server")
CreateButton(MT.C,"🔄 Rejoin","Reconnect to this server",T.ACC,function()
    pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    Notify("Rejoin","Rejoining...",2)
end)
CreateButton(MT.C,"🌐 Server Hop","Find a different server",T.ACCD,function()
    task.spawn(function()
        pcall(function()
            local data = game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?limit=100"):format(game.PlaceId))
            local json = HttpService:JSONDecode(data)
            for _, s in ipairs(json.data or {}) do
                if s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                    return
                end
            end
            Notify("Server Hop","No servers found",2)
        end)
    end)
    Notify("Server Hop","Searching...",2)
end)
CreateButton(MT.C,"🖨 Print Game Info","Print IDs to output",T.BG3,function()
    print("PlaceId: "..game.PlaceId)
    print("JobId: "..game.JobId)
    print("PlaceName: "..game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
    Notify("Game Info","Printed to output!",2)
end)
SectionLabel(MT.C,"Follow")
CreateTextInput(MT.C,"Copy Walk Target","Enter player name...",function(v) Settings.CopyTarget = v end)
CreateToggle(MT.C,"Copy Walk","Mirror target player movement","CopyWalk")

-- BYPASS TAB
local BT = MakeTab("Bypass","🛡")
SectionLabel(BT.C,"Active Protection")
CreateToggle(BT.C,"Anti Kick","Block all kick attempts","AntiKick")
CreateToggle(BT.C,"Anti Teleport","Block forced TPs > 200 studs","AntiTP")
CreateToggle(BT.C,"Remote Filter","Block AC remote events","RemoteFilter")
CreateToggle(BT.C,"Anti AFK","Never idle-kicked","AntiAFK")
SectionLabel(BT.C,"Debug Tools")
CreateButton(BT.C,"📋 Print All Remotes","Dump remotes to output",T.BG4,function()
    print("=== REMOTE EVENTS ===")
    for _,v in ipairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            print(v:GetFullName())
        end
    end
    Notify("Remotes","Printed!",2)
end)
CreateButton(BT.C,"📋 Print All Scripts","Dump scripts to output",T.BG4,function()
    print("=== SCRIPTS ===")
    for _,v in ipairs(game:GetDescendants()) do
        if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
            print(v:GetFullName())
        end
    end
    Notify("Scripts","Printed!",2)
end)

-- PLAYERS TAB
local PLT = MakeTab("Players","👥")

local function RefreshPlayers()
    for _,v in ipairs(PLT.C:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end

    SectionLabel(PLT.C,"Online ("..#Players:GetPlayers()..")")

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end

        local pf = Instance.new("Frame")
        pf.Name = "PLR_"..p.Name
        pf.BackgroundColor3 = T.BG3
        pf.BorderSizePixel = 0
        pf.Size = UDim2.new(1,0,0,54)
        pf.Parent = PLT.C
        MakeCorner(pf, 9)
        MakeStroke(pf, T.BDR, 1)

        MakeLabel(pf,{
            Position=UDim2.new(0,12,0,7),
            Size=UDim2.new(1,-130,0,20),
            Text=p.Name, Font=Enum.Font.GothamBold, TextSize=13,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextTruncate=Enum.TextTruncate.AtEnd
        })
        MakeLabel(pf,{
            Position=UDim2.new(0,12,0,28),
            Size=UDim2.new(1,-130,0,16),
            Text="ID: "..p.UserId, TextColor3=T.TXTG, TextSize=11,
            TextXAlignment=Enum.TextXAlignment.Left
        })

        -- TP button
        local tb = Instance.new("TextButton")
        tb.BackgroundColor3 = T.ACC
        tb.BorderSizePixel = 0
        tb.Position = UDim2.new(1,-114,0.5,-14)
        tb.Size = UDim2.new(0,50,0,28)
        tb.Text = "TP"
        tb.TextColor3 = T.TXT
        tb.Font = Enum.Font.GothamBold
        tb.TextSize = 13
        tb.Parent = pf
        MakeCorner(tb, 6)

        -- Spectate button
        local sb = Instance.new("TextButton")
        sb.BackgroundColor3 = T.ACCD
        sb.BorderSizePixel = 0
        sb.Position = UDim2.new(1,-58,0.5,-14)
        sb.Size = UDim2.new(0,50,0,28)
        sb.Text = "Spec"
        sb.TextColor3 = T.TXT
        sb.Font = Enum.Font.GothamBold
        sb.TextSize = 12
        sb.Parent = pf
        MakeCorner(sb, 6)

        tb.MouseButton1Click:Connect(function()
            if p.Character then
                local th = p.Character:FindFirstChild("HumanoidRootPart")
                local mh = HRP()
                if th and mh then
                    pcall(function() mh.CFrame = th.CFrame * CFrame.new(3,0,0) end)
                    Notify("TP","→ "..p.Name, 2)
                end
            end
        end)

        sb.MouseButton1Click:Connect(function()
            if p.Character then
                pcall(function()
                    workspace.CurrentCamera.CameraSubject = p.Character:FindFirstChildOfClass("Humanoid")
                end)
                Notify("Spectate", p.Name, 2)
            end
        end)
    end
end

RefreshPlayers()
Players.PlayerAdded:Connect(function() task.wait(0.5) RefreshPlayers() end)
Players.PlayerRemoving:Connect(function() task.wait(0.5) RefreshPlayers() end)
CreateButton(PLT.C,"🔄 Refresh List",nil,T.BG4,RefreshPlayers)

-- ════════════════════════════════════════
-- ACTIVATE FIRST TAB
-- ════════════════════════════════════════
Tabs["Player"].B:MouseButton1Click()

-- ════════════════════════════════════════
-- KEYBIND - RIGHT SHIFT
-- ════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then
            MainFrame.Size = UDim2.new(0,0,0,0)
            Tw(MainFrame, {Size=UDim2.new(0,700,0,520)}, 0.35)
        end
    end
end)

-- ════════════════════════════════════════
-- OPEN GUI + NOTIFICATION
-- ════════════════════════════════════════
task.wait(0.5)
MainFrame.Visible = true
MainFrame.Size = UDim2.new(0,0,0,0)
Tw(MainFrame, {Size=UDim2.new(0,700,0,520)}, 0.4)

Notify("CoolGUI v7","✅ Loaded! RightShift = Open/Close",5)

print("╔═════════════════════════════╗")
print("║    CoolGUI v7 LOADED ✅     ║")
print("║  RightShift = Toggle GUI    ║")
print("║  F          = Fly On/Off    ║")
print("║  Hold E     = Aimbot        ║")
print("╚═════════════════════════════╝")
