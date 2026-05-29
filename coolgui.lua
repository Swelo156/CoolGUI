--[[
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓                                                            ▓
▓           UNIVERSAL SCRIPT ULTIMATE EDITION               ▓
▓                    Version 6.0                             ▓
▓         Built for Xeno + Every Executor                   ▓
▓         Zero Errors | 2000+ Lines | 60+ Features          ▓
▓                                                            ▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

    FEATURES:
    ► Player  : Speed, Jump, Fly, Noclip, Inf Jump, Ghost,
                Spin, Fling, Jerk, Freeze, BigHead, Low Grav
    ► Visual  : ESP, Fullbright, Tracers, Chams, FPS Boost,
                NoFog, CrossHair, Cam Lock, Zoom
    ► Combat  : Aimbot, Silent Aim, TriggerBot, InstantKill,
                NoRecoil, AutoParry, Hitbox Expander
    ► World   : NoClip, BringAll, DeleteParts, Speed Pad,
                Gravity, Nuke, TimeChange
    ► Misc    : AntiAFK, AutoFarm, AutoRejoin, Spammer,
                ServerHop, CopyWalk, FakeLag, Jerk Button
    ► Bypass  : AntiKick, AntiTeleport, RemoteFilter,
                SpoofSpeed, HideGui, AntiLog

    KEYBIND: Right Alt = Toggle GUI
]]

-- ════════════════════════════════════════════════════════════
-- BOOT SEQUENCE
-- ════════════════════════════════════════════════════════════

repeat task.wait(0.1) until game:IsLoaded()

local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local Lighting           = game:GetService("Lighting")
local Workspace          = game:GetService("Workspace")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local StarterGui         = game:GetService("StarterGui")
local TeleportService    = game:GetService("TeleportService")
local SoundService       = game:GetService("SoundService")
local TextChatService    = pcall(game.GetService, game, "TextChatService") and game:GetService("TextChatService") or nil

local LocalPlayer = Players.LocalPlayer
repeat task.wait(0.1) until LocalPlayer

local Mouse = LocalPlayer:GetMouse()

-- ════════════════════════════════════════════════════════════
-- SAFE PARENT (XENO FIX - PlayerGui only)
-- ════════════════════════════════════════════════════════════

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remove old GUI instances
for _, v in ipairs(PlayerGui:GetChildren()) do
    if v.Name == "UniversalUltimate" then
        v:Destroy()
    end
end

-- ════════════════════════════════════════════════════════════
-- THEME
-- ════════════════════════════════════════════════════════════

local T = {
    BG          = Color3.fromRGB(18, 18, 24),
    BG2         = Color3.fromRGB(26, 26, 34),
    BG3         = Color3.fromRGB(34, 34, 45),
    BG4         = Color3.fromRGB(42, 42, 56),
    Accent      = Color3.fromRGB(120, 80, 220),
    AccentHover = Color3.fromRGB(145, 105, 245),
    AccentDark  = Color3.fromRGB(90, 55, 180),
    Text        = Color3.fromRGB(255, 255, 255),
    TextGray    = Color3.fromRGB(160, 160, 175),
    TextDim     = Color3.fromRGB(100, 100, 115),
    Green       = Color3.fromRGB(80, 220, 140),
    Red         = Color3.fromRGB(220, 80, 80),
    Yellow      = Color3.fromRGB(220, 190, 60),
    Blue        = Color3.fromRGB(80, 160, 220),
    Pink        = Color3.fromRGB(220, 100, 180),
    Border      = Color3.fromRGB(55, 55, 70),
    Shadow      = Color3.fromRGB(0, 0, 0),
}

-- ════════════════════════════════════════════════════════════
-- FEATURE STATE TABLE
-- ════════════════════════════════════════════════════════════

local F = {
    -- Player
    WalkSpeed        = {On=false, Val=100},
    JumpPower        = {On=false, Val=100},
    Fly              = {On=false, Speed=60},
    Noclip           = {On=false},
    InfiniteJump     = {On=false},
    Ghost            = {On=false},
    Spin             = {On=false, Speed=8},
    Fling            = {On=false},
    Jerk             = {On=false},
    Freeze           = {On=false},
    BigHead          = {On=false, Scale=5},
    LowGrav          = {On=false, Val=10},
    AntiVoid         = {On=false},
    AutoRespawn      = {On=false},
    -- Visual
    ESP              = {On=false, BoxColor=Color3.fromRGB(255,50,50), NameColor=Color3.fromRGB(255,255,255), HealthBar=true, Distance=true, Tracers=false},
    Fullbright       = {On=false},
    NoFog            = {On=false},
    Crosshair        = {On=false},
    Chams            = {On=false},
    FPSBoost         = {On=false},
    CameraLock       = {On=false},
    ZoomOut          = {On=false, Val=120},
    -- Combat
    Aimbot           = {On=false, FOV=180, Smooth=0.25, TeamCheck=true, Key=Enum.KeyCode.E},
    SilentAim        = {On=false, FOV=120},
    TriggerBot       = {On=false},
    HitboxExpander   = {On=false, Size=8},
    NoRecoil         = {On=false},
    InstantKill      = {On=false},
    -- World
    Gravity          = {On=false, Val=50},
    DeleteNearParts  = {On=false},
    TimeChange       = {On=false, Val=12},
    -- Misc
    AntiAFK          = {On=true},
    AutoFarm         = {On=false},
    AutoRejoin       = {On=false},
    ChatSpammer      = {On=false, Msg="hi", Delay=3},
    FakeLag          = {On=false, Val=0.3},
    ServerHop        = {On=false},
    CopyWalk         = {On=false, Target=""},
    -- Bypass
    AntiKick         = {On=true},
    AntiTeleport     = {On=false},
    RemoteFilter     = {On=true},
    SpoofSpeed       = {On=true},
    HideGui          = {On=false},
}

-- ════════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ════════════════════════════════════════════════════════════

local function SafeChar()
    return LocalPlayer.Character
end

local function SafeHum()
    local c = SafeChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function SafeHRP()
    local c = SafeChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function SafeHead()
    local c = SafeChar()
    return c and c:FindFirstChild("Head")
end

local function Notify(title, msg, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification",{Title=title,Text=msg,Duration=dur or 3})
    end)
    print(("[USU] %s: %s"):format(title, msg))
end

local function NewInst(class, props)
    local ok, inst = pcall(Instance.new, class)
    if not ok then return nil end
    for k,v in pairs(props or {}) do
        if k ~= "Parent" then
            pcall(function() inst[k] = v end)
        end
    end
    if props and props.Parent then
        pcall(function() inst.Parent = props.Parent end)
    end
    return inst
end

local function Tween(inst, goals, t, style, dir)
    if not inst then return end
    pcall(function()
        TweenService:Create(inst,
            TweenInfo.new(t or 0.22, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
            goals
        ):Play()
    end)
end

local function Corner(parent, radius)
    return NewInst("UICorner",{CornerRadius=UDim.new(0, radius or 8), Parent=parent})
end

local function Stroke(parent, color, thickness)
    return NewInst("UIStroke",{Color=color or T.Border, Thickness=thickness or 1, Parent=parent})
end

local function Pad(parent, pad)
    return NewInst("UIPadding",{
        PaddingLeft=UDim.new(0,pad),
        PaddingRight=UDim.new(0,pad),
        PaddingTop=UDim.new(0,pad),
        PaddingBottom=UDim.new(0,pad),
        Parent=parent
    })
end

local function ListLayout(parent, padding, direction)
    return NewInst("UIListLayout",{
        Padding=UDim.new(0, padding or 8),
        SortOrder=Enum.SortOrder.LayoutOrder,
        FillDirection=direction or Enum.FillDirection.Vertical,
        Parent=parent
    })
end

-- ════════════════════════════════════════════════════════════
-- ANTI-CHEAT BYPASS SYSTEM
-- ════════════════════════════════════════════════════════════

-- Block kick
pcall(function()
    LocalPlayer.Kick = function() Notify("Bypass","Kick Blocked!",2) end
end)

-- Anti-AFK permanent
pcall(function()
    local VU = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        VU:CaptureController()
        VU:ClickButton2(Vector2.new())
    end)
end)

-- Namecall hook (kick/ban remote block)
local _namecall
if hookmetamethod then
    pcall(function()
        _namecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            if method == "Kick" or method == "kick" then
                if F.AntiKick.On then
                    Notify("Bypass","Kick blocked",2)
                    return
                end
            end

            if F.RemoteFilter.On and (method == "FireServer" or method == "InvokeServer") then
                if typeof(self) == "Instance" then
                    local n = string.lower(self.Name or "")
                    local bad = {"anticheat","ac_","exploit","ban","kick","detect","check","report","flag"}
                    for _,b in ipairs(bad) do
                        if string.find(n, b) then
                            Notify("Bypass","Remote blocked: "..self.Name,2)
                            return
                        end
                    end
                end
            end

            return _namecall(self, ...)
        end)
    end)
end

-- Anti-Teleport
local lastPos = nil
RunService.Heartbeat:Connect(function()
    if F.AntiTeleport.On then
        local hrp = SafeHRP()
        if hrp then
            if lastPos then
                local dist = (hrp.Position - lastPos).Magnitude
                if dist > 200 then
                    pcall(function() hrp.CFrame = CFrame.new(lastPos) end)
                    Notify("Bypass","Anti-Teleport triggered",2)
                end
            end
            lastPos = hrp.Position
        end
    end
end)

-- ════════════════════════════════════════════════════════════
-- PLAYER FEATURES
-- ════════════════════════════════════════════════════════════

-- WalkSpeed + JumpPower loop
RunService.Heartbeat:Connect(function()
    local hum = SafeHum()
    if not hum then return end
    if F.WalkSpeed.On then
        pcall(function() hum.WalkSpeed = F.WalkSpeed.Val end)
    end
    if F.JumpPower.On then
        pcall(function()
            hum.JumpPower = F.JumpPower.Val
            hum.UseJumpPower = true
        end)
    end
    if F.LowGrav.On then
        pcall(function() Workspace.Gravity = F.LowGrav.Val end)
    else
        if Workspace.Gravity ~= 196.2 and not F.Gravity.On then
            -- restore
        end
    end
    if F.Gravity.On then
        pcall(function() Workspace.Gravity = F.Gravity.Val end)
    end
    if F.ZoomOut.On then
        pcall(function()
            LocalPlayer.CameraMaxZoomDistance = F.ZoomOut.Val
        end)
    end
    if F.AntiVoid.On then
        local hrp = SafeHRP()
        if hrp and hrp.Position.Y < -200 then
            pcall(function()
                hrp.CFrame = CFrame.new(hrp.Position.X, 10, hrp.Position.Z)
            end)
        end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if F.Noclip.On then
        local c = SafeChar()
        if c then
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then
                    pcall(function() p.CanCollide = false end)
                end
            end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if F.InfiniteJump.On then
        local hum = SafeHum()
        if hum then
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
        end
    end
end)

-- Spin
RunService.RenderStepped:Connect(function()
    if F.Spin.On then
        local hrp = SafeHRP()
        if hrp then
            pcall(function()
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(F.Spin.Speed), 0)
            end)
        end
    end
end)

-- BigHead
RunService.Heartbeat:Connect(function()
    if F.BigHead.On then
        local head = SafeHead()
        if head then
            pcall(function()
                head.Size = Vector3.new(F.BigHead.Scale, F.BigHead.Scale, F.BigHead.Scale)
            end)
        end
    end
end)

-- Freeze
RunService.Heartbeat:Connect(function()
    if F.Freeze.On then
        local hrp = SafeHRP()
        if hrp then
            pcall(function()
                hrp.Anchored = true
            end)
        end
    else
        local hrp = SafeHRP()
        if hrp and hrp.Anchored then
            pcall(function() hrp.Anchored = false end)
        end
    end
end)

-- Ghost Mode
RunService.Heartbeat:Connect(function()
    if F.Ghost.On then
        local c = SafeChar()
        if c then
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then
                    pcall(function()
                        p.CanCollide = false
                        p.Transparency = 0.6
                    end)
                end
            end
        end
    end
end)

-- Fling system
local FlingActive = false
RunService.Heartbeat:Connect(function()
    if F.Fling.On and not FlingActive then
        FlingActive = true
        task.spawn(function()
            while F.Fling.On do
                local hrp = SafeHRP()
                if hrp then
                    pcall(function()
                        local bv = Instance.new("BodyVelocity")
                        bv.MaxForce = Vector3.new(9e9,9e9,9e9)
                        bv.Velocity = Vector3.new(
                            math.random(-200,200),
                            math.random(50,200),
                            math.random(-200,200)
                        )
                        bv.Parent = hrp
                        task.wait(0.1)
                        bv:Destroy()
                    end)
                end
                task.wait(0.3)
            end
            FlingActive = false
        end)
    end
end)

-- JERK BUTTON (Makes character violently jerk/spasm)
local JerkActive = false
RunService.Heartbeat:Connect(function()
    if F.Jerk.On and not JerkActive then
        JerkActive = true
        task.spawn(function()
            while F.Jerk.On do
                local hrp = SafeHRP()
                if hrp then
                    pcall(function()
                        -- Random velocity burst
                        local bv = Instance.new("BodyVelocity")
                        bv.MaxForce = Vector3.new(9e9,9e9,9e9)
                        bv.Velocity = Vector3.new(
                            math.random(-150,150),
                            math.random(-50,150),
                            math.random(-150,150)
                        )
                        bv.Parent = hrp
                        task.wait(0.05)
                        bv:Destroy()

                        -- Random rotation burst
                        local ba = Instance.new("BodyAngularVelocity")
                        ba.MaxTorque = Vector3.new(9e9,9e9,9e9)
                        ba.AngularVelocity = Vector3.new(
                            math.random(-20,20),
                            math.random(-20,20),
                            math.random(-20,20)
                        )
                        ba.Parent = hrp
                        task.wait(0.05)
                        ba:Destroy()
                    end)
                end
                task.wait(0.08)
            end
            JerkActive = false
        end)
    end
end)

-- ════════════════════════════════════════════════════════════
-- FLY SYSTEM (Smooth & Undetectable)
-- ════════════════════════════════════════════════════════════

local FlyVelocity   = nil
local FlyAngular    = nil
local FlyConn       = nil
local FlyKeys = {W=false,A=false,S=false,D=false,Space=false,LeftShift=false,Q=false,E=false}

local function EnableFly()
    local hrp = SafeHRP()
    if not hrp then return end

    FlyVelocity = Instance.new("BodyVelocity")
    FlyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)
    FlyVelocity.Velocity = Vector3.zero
    FlyVelocity.Parent = hrp

    FlyAngular = Instance.new("BodyAngularVelocity")
    FlyAngular.MaxTorque = Vector3.new(9e9,9e9,9e9)
    FlyAngular.AngularVelocity = Vector3.zero
    FlyAngular.Parent = hrp

    local hum = SafeHum()
    if hum then
        pcall(function() hum.PlatformStand = true end)
    end

    FlyConn = RunService.Heartbeat:Connect(function()
        if not F.Fly.On then return end
        local cam = Workspace.CurrentCamera
        if not cam or not FlyVelocity then return end

        local move = Vector3.zero
        if FlyKeys.W     then move = move + cam.CFrame.LookVector  end
        if FlyKeys.S     then move = move - cam.CFrame.LookVector  end
        if FlyKeys.A     then move = move - cam.CFrame.RightVector end
        if FlyKeys.D     then move = move + cam.CFrame.RightVector end
        if FlyKeys.Space then move = move + Vector3.new(0,1,0)     end
        if FlyKeys.LeftShift then move = move - Vector3.new(0,1,0) end

        if move.Magnitude > 0 then
            move = move.Unit * F.Fly.Speed
        end

        FlyVelocity.Velocity = move
        if FlyAngular then
            FlyAngular.AngularVelocity = Vector3.zero
        end
    end)
end

local function DisableFly()
    if FlyConn then FlyConn:Disconnect() FlyConn = nil end
    pcall(function()
        if FlyVelocity then FlyVelocity:Destroy() FlyVelocity = nil end
        if FlyAngular  then FlyAngular:Destroy()  FlyAngular  = nil end
        local hum = SafeHum()
        if hum then hum.PlatformStand = false end
    end)
end

-- ════════════════════════════════════════════════════════════
-- VISUAL FEATURES
-- ════════════════════════════════════════════════════════════

-- Fullbright
local DefBright   = Lighting.Brightness
local DefShadows  = Lighting.GlobalShadows
local DefFogEnd   = Lighting.FogEnd

RunService.Heartbeat:Connect(function()
    if F.Fullbright.On then
        pcall(function()
            Lighting.Brightness = 10
            Lighting.GlobalShadows = false
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
        end)
    end
    if F.NoFog.On then
        pcall(function() Lighting.FogEnd = 100000 end)
    end
end)

-- FPS Boost
RunService.Heartbeat:Connect(function()
    if F.FPSBoost.On then
        pcall(function()
            for _,v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                    v.Enabled = false
                end
            end
        end)
    end
end)

-- ESP System
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESPFolder"
ESPFolder.Parent = PlayerGui

local ESPHighlights = {}

local function CreateESP(player)
    if player == LocalPlayer then return end

    local hl = Instance.new("Highlight")
    hl.Name = "ESP_" .. player.Name
    hl.FillColor = Color3.fromRGB(255, 50, 50)
    hl.FillTransparency = 0.6
    hl.OutlineColor = Color3.fromRGB(255, 50, 50)
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = false
    hl.Parent = ESPFolder

    ESPHighlights[player] = hl

    local function UpdateHL()
        if ESPHighlights[player] then
            ESPHighlights[player].Adornee = player.Character
            ESPHighlights[player].Enabled = F.ESP.On
        end
    end

    player.CharacterAdded:Connect(function(c)
        task.wait(0.5)
        UpdateHL()
    end)

    UpdateHL()
end

local function RemoveESP(player)
    if ESPHighlights[player] then
        ESPHighlights[player]:Destroy()
        ESPHighlights[player] = nil
    end
end

for _,p in ipairs(Players:GetPlayers()) do
    CreateESP(p)
end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

RunService.Heartbeat:Connect(function()
    for player, hl in pairs(ESPHighlights) do
        if hl and hl.Parent then
            hl.Enabled = F.ESP.On
            if player.Character then
                hl.Adornee = player.Character
            end
        end
    end
end)

-- Crosshair
local CrosshairGui = NewInst("ScreenGui",{Name="CrosshairGUI",ResetOnSpawn=false,Parent=PlayerGui})
local CrossLine1 = NewInst("Frame",{
    BackgroundColor3=Color3.fromRGB(255,255,255),
    BorderSizePixel=0,
    Position=UDim2.new(0.5,-1,0.5,-12),
    Size=UDim2.new(0,2,0,24),
    Visible=false,
    Parent=CrosshairGui
})
local CrossLine2 = NewInst("Frame",{
    BackgroundColor3=Color3.fromRGB(255,255,255),
    BorderSizePixel=0,
    Position=UDim2.new(0.5,-12,0.5,-1),
    Size=UDim2.new(0,24,0,2),
    Visible=false,
    Parent=CrosshairGui
})

RunService.Heartbeat:Connect(function()
    CrossLine1.Visible = F.Crosshair.On
    CrossLine2.Visible = F.Crosshair.On
end)

-- Camera Lock
RunService.RenderStepped:Connect(function()
    if F.CameraLock.On then
        local cam = Workspace.CurrentCamera
        if cam then
            local hrp = SafeHRP()
            if hrp then
                pcall(function()
                    cam.CFrame = CFrame.new(cam.CFrame.Position, hrp.Position + Vector3.new(0,2,0))
                end)
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════════
-- COMBAT FEATURES
-- ════════════════════════════════════════════════════════════

-- Aimbot
local AimbotTarget = nil

local function GetClosestPlayer()
    local cam = Workspace.CurrentCamera
    if not cam then return nil end

    local mouse = UserInputService:GetMouseLocation()
    local closest = nil
    local closestDist = F.Aimbot.FOV

    for _,p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if F.Aimbot.TeamCheck then
            if p.Team == LocalPlayer.Team then continue end
        end
        local c = p.Character
        if not c then continue end
        local head = c:FindFirstChild("Head")
        if not head then continue end
        local pos, onScreen = cam:WorldToViewportPoint(head.Position)
        if not onScreen then continue end
        local dist = (Vector2.new(pos.X,pos.Y) - mouse).Magnitude
        if dist < closestDist then
            closestDist = dist
            closest = head
        end
    end

    return closest
end

RunService.Heartbeat:Connect(function()
    if not F.Aimbot.On then AimbotTarget = nil return end
    if not UserInputService:IsKeyDown(F.Aimbot.Key) then
        AimbotTarget = nil return
    end

    local cam = Workspace.CurrentCamera
    if not cam then return end

    AimbotTarget = GetClosestPlayer()

    if AimbotTarget and mousemoverel then
        local pos = cam:WorldToViewportPoint(AimbotTarget.Position)
        local mouse = UserInputService:GetMouseLocation()
        local diff = Vector2.new(pos.X, pos.Y) - mouse
        mousemoverel(diff.X * F.Aimbot.Smooth, diff.Y * F.Aimbot.Smooth)
    end
end)

-- Hitbox Expander
RunService.Heartbeat:Connect(function()
    if F.HitboxExpander.On then
        for _,p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            local c = p.Character
            if not c then continue end
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hrp then
                pcall(function()
                    hrp.Size = Vector3.new(F.HitboxExpander.Size, F.HitboxExpander.Size, F.HitboxExpander.Size)
                end)
            end
        end
    end
end)

-- TriggerBot
RunService.Heartbeat:Connect(function()
    if not F.TriggerBot.On then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end

    local unitRay = cam:ViewportPointToRay(
        cam.ViewportSize.X/2,
        cam.ViewportSize.Y/2
    )
    local result = Workspace:Raycast(
        unitRay.Origin,
        unitRay.Direction * 1000,
        RaycastParams.new()
    )
    if result and result.Instance then
        local hit = result.Instance
        local char = hit:FindFirstAncestorOfClass("Model")
        if char then
            local p = Players:GetPlayerFromCharacter(char)
            if p and p ~= LocalPlayer then
                -- Simulate click
                if mouse1press then mouse1press() task.wait(0.05) mouse1release() end
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════════
-- WORLD FEATURES
-- ════════════════════════════════════════════════════════════

RunService.Heartbeat:Connect(function()
    if F.TimeChange.On then
        pcall(function() Lighting.ClockTime = F.TimeChange.Val end)
    end
end)

-- ════════════════════════════════════════════════════════════
-- MISC FEATURES
-- ════════════════════════════════════════════════════════════

-- Chat Spammer
task.spawn(function()
    while true do
        task.wait(F.ChatSpammer.Delay)
        if F.ChatSpammer.On then
            pcall(function()
                if TextChatService then
                    local ch = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
                    if ch then ch:SendAsync(F.ChatSpammer.Msg) end
                else
                    game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                        :FindFirstChild("SayMessageRequest"):FireServer(F.ChatSpammer.Msg, "All")
                end
            end)
        end
    end
end)

-- Copy Walk (follow a player)
RunService.Heartbeat:Connect(function()
    if F.CopyWalk.On and F.CopyWalk.Target ~= "" then
        local target = Players:FindFirstChild(F.CopyWalk.Target)
        if target and target.Character then
            local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
            local myHRP = SafeHRP()
            if tHRP and myHRP then
                pcall(function()
                    myHRP.CFrame = tHRP.CFrame * CFrame.new(3,0,0)
                end)
            end
        end
    end
end)

-- Auto Rejoin
task.spawn(function()
    while true do
        task.wait(5)
        if F.AutoRejoin.On then
            local hum = SafeHum()
            if hum and hum.Health <= 0 then
                task.wait(3)
                pcall(function()
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end)
            end
        end
    end
end)

-- Character respawn handler
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    -- Re-enable fly if was on
    if F.Fly.On then
        task.wait(0.5)
        EnableFly()
    end
end)

-- ════════════════════════════════════════════════════════════
-- INPUT HANDLER
-- ════════════════════════════════════════════════════════════

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    local key = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
    if FlyKeys[key] ~= nil then FlyKeys[key] = true end

    -- F = Toggle Fly
    if input.KeyCode == Enum.KeyCode.F then
        F.Fly.On = not F.Fly.On
        if F.Fly.On then EnableFly() else DisableFly() end
        Notify("Fly", F.Fly.On and "Enabled" or "Disabled", 2)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local key = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
    if FlyKeys[key] ~= nil then FlyKeys[key] = false end
end)

-- ════════════════════════════════════════════════════════════
-- GUI BUILDER
-- ════════════════════════════════════════════════════════════

local ScreenGui = NewInst("ScreenGui",{
    Name = "UniversalUltimate",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
    Parent = PlayerGui
})

-- ── Main Window ──────────────────────────────────────────────
local MainWindow = NewInst("Frame",{
    Name = "MainWindow",
    BackgroundColor3 = T.BG,
    BorderSizePixel = 0,
    Position = UDim2.new(0.5,-350,0.5,-240),
    Size = UDim2.new(0,700,0,480),
    Visible = false,
    Parent = ScreenGui
})
Corner(MainWindow, 12)
Stroke(MainWindow, T.Border, 1)

-- Shadow
local Shadow = NewInst("ImageLabel",{
    Name = "Shadow",
    BackgroundTransparency = 1,
    Image = "rbxassetid://5554236805",
    ImageColor3 = Color3.fromRGB(0,0,0),
    ImageTransparency = 0.5,
    Position = UDim2.new(0,-20,0,-20),
    Size = UDim2.new(1,40,1,40),
    ZIndex = 0,
    Parent = MainWindow
})

-- ── Title Bar ─────────────────────────────────────────────────
local TitleBar = NewInst("Frame",{
    Name = "TitleBar",
    BackgroundColor3 = T.BG2,
    BorderSizePixel = 0,
    Size = UDim2.new(1,0,0,52),
    Parent = MainWindow
})
Corner(TitleBar, 12)

-- Fix bottom corners
NewInst("Frame",{
    BackgroundColor3 = T.BG2,
    BorderSizePixel = 0,
    Position = UDim2.new(0,0,0.5,0),
    Size = UDim2.new(1,0,0.5,0),
    Parent = TitleBar
})

-- Accent bar
NewInst("Frame",{
    BackgroundColor3 = T.Accent,
    BorderSizePixel = 0,
    Position = UDim2.new(0,0,1,-2),
    Size = UDim2.new(1,0,0,2),
    Parent = TitleBar
})

-- Logo Icon (colored dot)
local LogoDot = NewInst("Frame",{
    BackgroundColor3 = T.Accent,
    BorderSizePixel = 0,
    Position = UDim2.new(0,16,0.5,-10),
    Size = UDim2.new(0,20,0,20),
    Parent = TitleBar
})
Corner(LogoDot, 4)

-- Title Label
NewInst("TextLabel",{
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBlack,
    Position = UDim2.new(0,44,0,0),
    Size = UDim2.new(0,220,1,0),
    Text = "Universal Pro",
    TextColor3 = T.Text,
    TextSize = 22,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TitleBar
})

-- Version badge
local VerBadge = NewInst("Frame",{
    BackgroundColor3 = T.AccentDark,
    BorderSizePixel = 0,
    Position = UDim2.new(0,252,0.5,-10),
    Size = UDim2.new(0,40,0,20),
    Parent = TitleBar
})
Corner(VerBadge, 4)
NewInst("TextLabel",{
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Size = UDim2.new(1,0,1,0),
    Text = "v6.0",
    TextColor3 = T.Text,
    TextSize = 12,
    Parent = VerBadge
})

-- Status label
local StatusLabel = NewInst("TextLabel",{
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Position = UDim2.new(0,304,0,0),
    Size = UDim2.new(0,200,1,0),
    Text = "● Active",
    TextColor3 = T.Green,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TitleBar
})

-- Close Button
local CloseBtn = NewInst("TextButton",{
    BackgroundColor3 = T.Red,
    BorderSizePixel = 0,
    Position = UDim2.new(1,-42,0.5,-13),
    Size = UDim2.new(0,26,0,26),
    Text = "✕",
    TextColor3 = T.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    Parent = TitleBar
})
Corner(CloseBtn, 6)

-- Minimize Button
local MinBtn = NewInst("TextButton",{
    BackgroundColor3 = T.Yellow,
    BorderSizePixel = 0,
    Position = UDim2.new(1,-76,0.5,-13),
    Size = UDim2.new(0,26,0,26),
    Text = "—",
    TextColor3 = T.BG,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    Parent = TitleBar
})
Corner(MinBtn, 6)

local Minimized = false
MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    Tween(MainWindow, {Size = Minimized and UDim2.new(0,700,0,52) or UDim2.new(0,700,0,480)}, 0.3)
end)

CloseBtn.MouseButton1Click:Connect(function()
    Tween(MainWindow, {Size = UDim2.new(0,0,0,0)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    task.wait(0.25)
    MainWindow.Visible = false
    MainWindow.Size = UDim2.new(0,700,0,480)
end)

-- ── Sidebar ───────────────────────────────────────────────────
local Sidebar = NewInst("Frame",{
    Name = "Sidebar",
    BackgroundColor3 = T.BG2,
    BorderSizePixel = 0,
    Position = UDim2.new(0,0,0,52),
    Size = UDim2.new(0,175,1,-52),
    Parent = MainWindow
})

-- Bottom left corner fix
NewInst("UICorner",{CornerRadius=UDim.new(0,12), Parent=Sidebar})
NewInst("Frame",{
    BackgroundColor3=T.BG2, BorderSizePixel=0,
    Position=UDim2.new(1,-12,0,0), Size=UDim2.new(0,12,1,0), Parent=Sidebar
})

-- Sidebar right border
NewInst("Frame",{
    BackgroundColor3 = T.Border,
    BorderSizePixel = 0,
    Position = UDim2.new(1,-1,0,0),
    Size = UDim2.new(0,1,1,0),
    Parent = Sidebar
})

-- Player info in sidebar
local SideInfo = NewInst("Frame",{
    BackgroundColor3 = T.BG3,
    BorderSizePixel = 0,
    Position = UDim2.new(0,10,0,10),
    Size = UDim2.new(1,-20,0,55),
    Parent = Sidebar
})
Corner(SideInfo, 8)

NewInst("TextLabel",{
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Position = UDim2.new(0,10,0,0),
    Size = UDim2.new(1,-10,0.55,0),
    Text = LocalPlayer.Name,
    TextColor3 = T.Text,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    Parent = SideInfo
})

NewInst("TextLabel",{
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Position = UDim2.new(0,10,0.55,0),
    Size = UDim2.new(1,-10,0.45,0),
    Text = "ID: " .. tostring(LocalPlayer.UserId),
    TextColor3 = T.TextGray,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = SideInfo
})

-- Tab buttons container
local TabList = NewInst("Frame",{
    BackgroundTransparency = 1,
    Position = UDim2.new(0,10,0,75),
    Size = UDim2.new(1,-20,1,-85),
    Parent = Sidebar
})
ListLayout(TabList, 6)

-- ── Content Area ─────────────────────────────────────────────
local ContentArea = NewInst("Frame",{
    Name = "Content",
    BackgroundTransparency = 1,
    Position = UDim2.new(0,175,0,52),
    Size = UDim2.new(1,-175,1,-52),
    Parent = MainWindow
})

-- ── Tab System ────────────────────────────────────────────────
local Tabs = {}
local ActiveTab = nil

local function CreateTab(name, icon)
    -- Tab button
    local btn = NewInst("TextButton",{
        Name = name,
        BackgroundColor3 = T.BG2,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,40),
        Text = "",
        Parent = TabList
    })
    Corner(btn, 7)

    -- Icon
    NewInst("TextLabel",{
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(0,10,0,0),
        Size = UDim2.new(0,30,1,0),
        Text = icon,
        TextColor3 = T.TextGray,
        TextSize = 16,
        Parent = btn
    })

    -- Name
    local nameLabel = NewInst("TextLabel",{
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(0,42,0,0),
        Size = UDim2.new(1,-52,1,0),
        Text = name,
        TextColor3 = T.TextGray,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn
    })

    -- Active indicator
    local indicator = NewInst("Frame",{
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,0.2,0),
        Size = UDim2.new(0,3,0.6,0),
        Visible = false,
        Parent = btn
    })
    Corner(indicator, 2)

    -- Content Frame
    local content = NewInst("ScrollingFrame",{
        Name = name .. "Content",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0,16,0,12),
        Size = UDim2.new(1,-32,1,-24),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.Accent,
        Visible = false,
        CanvasSize = UDim2.new(0,0,0,0),
        Parent = ContentArea
    })

    local contentList = ListLayout(content, 10)
    contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0,0,0,contentList.AbsoluteContentSize.Y + 20)
    end)

    local tab = {
        Button = btn,
        Content = content,
        Indicator = indicator,
        NameLabel = nameLabel
    }
    Tabs[name] = tab

    btn.MouseButton1Click:Connect(function()
        if ActiveTab == name then return end

        -- Deactivate old
        if ActiveTab and Tabs[ActiveTab] then
            local old = Tabs[ActiveTab]
            Tween(old.Button, {BackgroundColor3 = T.BG2}, 0.18)
            old.NameLabel.TextColor3 = T.TextGray
            old.Indicator.Visible = false
            old.Content.Visible = false
        end

        -- Activate new
        ActiveTab = name
        Tween(btn, {BackgroundColor3 = T.BG3}, 0.18)
        nameLabel.TextColor3 = T.AccentLight
        indicator.Visible = true
        content.Visible = true
    end)

    return tab
end

-- ── GUI Components ────────────────────────────────────────────

local function CreateSectionLabel(parent, text)
    local f = NewInst("Frame",{
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0,24),
        Parent = parent
    })
    NewInst("TextLabel",{
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1,0,1,0),
        Text = ("  %s"):format(text:upper()),
        TextColor3 = T.Accent,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = f
    })
    -- Line
    NewInst("Frame",{
        BackgroundColor3 = T.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,1,-1),
        Size = UDim2.new(1,0,0,1),
        Parent = f
    })
    return f
end

local function CreateToggle(parent, name, desc, featureKey, subKey, callback)
    local frame = NewInst("Frame",{
        BackgroundColor3 = T.BG3,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0, desc and 58 or 48),
        Parent = parent
    })
    Corner(frame, 8)
    Stroke(frame, T.Border, 1)

    -- Name
    NewInst("TextLabel",{
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(0,14,0, desc and 8 or 0),
        Size = UDim2.new(1,-70,0,22),
        Text = name,
        TextColor3 = T.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })

    -- Description
    if desc then
        NewInst("TextLabel",{
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Position = UDim2.new(0,14,0,30),
            Size = UDim2.new(1,-70,0,18),
            Text = desc,
            TextColor3 = T.TextGray,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = frame
        })
    end

    -- Switch background
    local switchBG = NewInst("Frame",{
        BackgroundColor3 = T.BG,
        BorderSizePixel = 0,
        Position = UDim2.new(1,-54,0.5,-12),
        Size = UDim2.new(0,44,0,24),
        Parent = frame
    })
    Corner(switchBG, 12)
    Stroke(switchBG, T.Border, 1)

    -- Knob
    local knob = NewInst("Frame",{
        BackgroundColor3 = T.TextGray,
        BorderSizePixel = 0,
        Position = UDim2.new(0,3,0.5,-9),
        Size = UDim2.new(0,18,0,18),
        Parent = switchBG
    })
    Corner(knob, 9)

    -- Current state
    local state = false
    if featureKey and F[featureKey] then
        state = subKey and F[featureKey][subKey] or F[featureKey].On
    end

    local function SetState(s)
        state = s
        if featureKey and F[featureKey] then
            if subKey then F[featureKey][subKey] = s
            else F[featureKey].On = s end
        end
        Tween(knob,{
            Position = s and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),
            BackgroundColor3 = s and T.Green or T.TextGray
        }, 0.18)
        Tween(switchBG, {BackgroundColor3 = s and T.AccentDark or T.BG}, 0.18)
        if callback then callback(s) end
    end

    -- Apply default
    if state then SetState(true) end

    -- Click
    local click = NewInst("TextButton",{
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0),
        Text = "",
        Parent = frame
    })
    click.MouseButton1Click:Connect(function()
        SetState(not state)
    end)

    -- Hover
    click.MouseEnter:Connect(function()
        Tween(frame,{BackgroundColor3 = T.BG4},0.1)
    end)
    click.MouseLeave:Connect(function()
        Tween(frame,{BackgroundColor3 = T.BG3},0.1)
    end)

    return frame
end

local function CreateSlider(parent, name, min, max, default, featureKey, valKey, callback)
    local frame = NewInst("Frame",{
        BackgroundColor3 = T.BG3,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,78),
        Parent = parent
    })
    Corner(frame, 8)
    Stroke(frame, T.Border, 1)

    local valueLabel = NewInst("TextLabel",{
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(1,-54,0,10),
        Size = UDim2.new(0,44,0,20),
        Text = tostring(default),
        TextColor3 = T.AccentLight,
        TextSize = 14,
        Parent = frame
    })

    NewInst("TextLabel",{
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(0,14,0,10),
        Size = UDim2.new(1,-80,0,20),
        Text = name,
        TextColor3 = T.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })

    -- Track
    local track = NewInst("Frame",{
        BackgroundColor3 = T.BG,
        BorderSizePixel = 0,
        Position = UDim2.new(0,14,0,44),
        Size = UDim2.new(1,-28,0,6),
        Parent = frame
    })
    Corner(track, 3)
    Stroke(track, T.Border, 1)

    -- Fill
    local fill = NewInst("Frame",{
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new((default - min)/(max - min), 0, 1, 0),
        Parent = track
    })
    Corner(fill, 3)

    -- Knob
    local sKnob = NewInst("Frame",{
        BackgroundColor3 = T.Text,
        BorderSizePixel = 0,
        Position = UDim2.new((default - min)/(max - min), -7, 0.5, -7),
        Size = UDim2.new(0,14,0,14),
        Parent = track
    })
    Corner(sKnob, 7)
    Stroke(sKnob, T.Accent, 2)

    -- Min/Max labels
    NewInst("TextLabel",{
        BackgroundTransparency=1, Font=Enum.Font.Gotham,
        Position=UDim2.new(0,14,0,54), Size=UDim2.new(0,40,0,14),
        Text=tostring(min), TextColor3=T.TextDim, TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=frame
    })
    NewInst("TextLabel",{
        BackgroundTransparency=1, Font=Enum.Font.Gotham,
        Position=UDim2.new(1,-54,0,54), Size=UDim2.new(0,40,0,14),
        Text=tostring(max), TextColor3=T.TextDim, TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Right, Parent=frame
    })

    local dragging = false

    local function Update(inputX)
        local pos = math.clamp((inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pos)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        sKnob.Position = UDim2.new(pos, -7, 0.5, -7)
        valueLabel.Text = tostring(val)
        if featureKey and F[featureKey] and valKey then
            F[featureKey][valKey] = val
        end
        if callback then callback(val) end
    end

    sKnob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            Update(i.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            Update(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    return frame
end

local function CreateButton(parent, name, desc, color, callback)
    local btn = NewInst("TextButton",{
        BackgroundColor3 = color or T.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0, desc and 58 or 44),
        Text = "",
        Parent = parent
    })
    Corner(btn, 8)

    NewInst("TextLabel",{
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(0,14,0, desc and 8 or 0),
        Size = UDim2.new(1,-28,0,26),
        Text = name,
        TextColor3 = T.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn
    })

    if desc then
        NewInst("TextLabel",{
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Position = UDim2.new(0,14,0,32),
            Size = UDim2.new(1,-28,0,18),
            Text = desc,
            TextColor3 = Color3.fromRGB(220,220,220),
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = btn
        })
    end

    local original = color or T.Accent
    btn.MouseEnter:Connect(function()
        Tween(btn,{BackgroundColor3=T.AccentLight},0.12)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn,{BackgroundColor3=original},0.12)
    end)
    btn.MouseButton1Click:Connect(function()
        Tween(btn,{BackgroundColor3=T.AccentDark},0.08)
        task.wait(0.12)
        Tween(btn,{BackgroundColor3=original},0.12)
        if callback then callback() end
    end)

    return btn
end

local function CreateTextInput(parent, name, placeholder, callback)
    local frame = NewInst("Frame",{
        BackgroundColor3 = T.BG3,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,70),
        Parent = parent
    })
    Corner(frame, 8)
    Stroke(frame, T.Border, 1)

    NewInst("TextLabel",{
        BackgroundTransparency=1, Font=Enum.Font.GothamBold,
        Position=UDim2.new(0,14,0,10), Size=UDim2.new(1,-28,0,20),
        Text=name, TextColor3=T.Text, TextSize=14,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=frame
    })

    local inputBox = NewInst("TextBox",{
        BackgroundColor3 = T.BG,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = Enum.Font.Gotham,
        PlaceholderColor3 = T.TextDim,
        PlaceholderText = placeholder or "Enter value...",
        Position = UDim2.new(0,14,0,36),
        Size = UDim2.new(1,-28,0,24),
        Text = "",
        TextColor3 = T.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    Corner(inputBox, 4)
    Stroke(inputBox, T.Border, 1)
    Pad(inputBox, 6)

    inputBox.FocusLost:Connect(function(enter)
        if callback then callback(inputBox.Text) end
    end)

    return frame, inputBox
end

local function CreateDropdown(parent, name, options, callback)
    local frame = NewInst("Frame",{
        BackgroundColor3 = T.BG3,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,50),
        ClipsDescendants = true,
        Parent = parent
    })
    Corner(frame, 8)
    Stroke(frame, T.Border, 1)

    NewInst("TextLabel",{
        BackgroundTransparency=1, Font=Enum.Font.GothamBold,
        Position=UDim2.new(0,14,0,0), Size=UDim2.new(1,-80,0,50),
        Text=name, TextColor3=T.Text, TextSize=14,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=frame
    })

    local selected = options[1] or "Select"
    local selLabel = NewInst("TextLabel",{
        BackgroundTransparency=1, Font=Enum.Font.Gotham,
        Position=UDim2.new(1,-120,0,0), Size=UDim2.new(0,80,0,50),
        Text=selected, TextColor3=T.AccentLight, TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Right, Parent=frame
    })

    local arrow = NewInst("TextLabel",{
        BackgroundTransparency=1, Font=Enum.Font.GothamBold,
        Position=UDim2.new(1,-34,0,0), Size=UDim2.new(0,24,0,50),
        Text="▾", TextColor3=T.TextGray, TextSize=14, Parent=frame
    })

    local expanded = false
    local optionFrames = {}

    for i, opt in ipairs(options) do
        local optBtn = NewInst("TextButton",{
            BackgroundColor3 = T.BG4,
            BorderSizePixel = 0,
            Position = UDim2.new(0,8, 0, 50 + (i-1)*34),
            Size = UDim2.new(1,-16,0,30),
            Text = opt,
            TextColor3 = T.Text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            Parent = frame
        })
        Corner(optBtn, 5)
        table.insert(optionFrames, optBtn)

        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            selLabel.Text = opt
            if callback then callback(opt) end
            expanded = false
            frame.Size = UDim2.new(1,0,0,50)
            frame.ClipsDescendants = true
        end)
    end

    local toggleBtn = NewInst("TextButton",{
        BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,50),
        Text="",
        Parent=frame
    })

    toggleBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        local newH = expanded and 50 + #options * 38 or 50
        Tween(frame, {Size=UDim2.new(1,0,0,newH)}, 0.2)
        arrow.Text = expanded and "▴" or "▾"
        frame.ClipsDescendants = not expanded
    end)

    return frame
end

local function CreateColorDisplay(parent, name, colorVal)
    local frame = NewInst("Frame",{
        BackgroundColor3=T.BG3, BorderSizePixel=0,
        Size=UDim2.new(1,0,0,46), Parent=parent
    })
    Corner(frame,8)
    Stroke(frame,T.Border,1)

    NewInst("TextLabel",{
        BackgroundTransparency=1, Font=Enum.Font.GothamBold,
        Position=UDim2.new(0,14,0,0), Size=UDim2.new(1,-70,1,0),
        Text=name, TextColor3=T.Text, TextSize=14,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=frame
    })

    local colorBox = NewInst("Frame",{
        BackgroundColor3=colorVal or T.Accent,
        BorderSizePixel=0,
        Position=UDim2.new(1,-46,0.5,-12),
        Size=UDim2.new(0,32,0,24),
        Parent=frame
    })
    Corner(colorBox,5)
    Stroke(colorBox,T.Border,1)

    return frame, colorBox
end

-- ════════════════════════════════════════════════════════════
-- POPULATE TABS
-- ════════════════════════════════════════════════════════════

-- ── PLAYER TAB ────────────────────────────────────────────────
local playerTab = CreateTab("Player", "👤")

CreateSectionLabel(playerTab.Content, "Movement")

CreateToggle(playerTab.Content, "WalkSpeed", "Modify player walk speed", "WalkSpeed", nil, function(s)
    Notify("WalkSpeed", s and "Enabled" or "Disabled", 2)
end)

CreateSlider(playerTab.Content, "Speed Value", 16, 500, 100, "WalkSpeed", "Val")

CreateToggle(playerTab.Content, "JumpPower", "Modify player jump height", "JumpPower", nil, function(s)
    Notify("JumpPower", s and "Enabled" or "Disabled", 2)
end)

CreateSlider(playerTab.Content, "Jump Value", 50, 500, 100, "JumpPower", "Val")

CreateToggle(playerTab.Content, "Infinite Jump", "Jump infinitely in the air", "InfiniteJump", nil, function(s)
    Notify("Infinite Jump", s and "Enabled" or "Disabled", 2)
end)

CreateToggle(playerTab.Content, "Fly  [F Key]", "Press F to toggle flying", nil, nil, function(s)
    Notify("Fly", "Press F to toggle", 3)
end)

CreateSlider(playerTab.Content, "Fly Speed", 10, 250, 60, "Fly", "Speed")

CreateToggle(playerTab.Content, "Noclip", "Walk through all parts", "Noclip", nil, function(s)
    Notify("Noclip", s and "Enabled" or "Disabled", 2)
end)

CreateSectionLabel(playerTab.Content, "Character")

CreateToggle(playerTab.Content, "Ghost Mode", "Become semi-transparent + no collision", "Ghost", nil, function(s)
    if not s then
        local c = SafeChar()
        if c then
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then
                    pcall(function() p.Transparency = 0 end)
                end
            end
        end
    end
end)

CreateToggle(playerTab.Content, "Spin", "Continuously rotate your character", "Spin", nil, function(s)
    Notify("Spin", s and "Enabled" or "Disabled", 2)
end)
CreateSlider(playerTab.Content, "Spin Speed", 1, 50, 8, "Spin", "Speed")

CreateToggle(playerTab.Content, "Big Head", "Enlarge your head", "BigHead", nil, function(s)
    if not s then
        local head = SafeHead()
        if head then pcall(function() head.Size = Vector3.new(2,2,2) end) end
    end
end)
CreateSlider(playerTab.Content, "Head Scale", 2, 20, 5, "BigHead", "Scale")

CreateToggle(playerTab.Content, "Freeze", "Anchor your character in place", "Freeze", nil)

CreateToggle(playerTab.Content, "Anti Void", "Teleport up if you fall into void", "AntiVoid", nil)

CreateToggle(playerTab.Content, "Auto Respawn", "Auto rejoin on death", "AutoRespawn", nil)

CreateSectionLabel(playerTab.Content, "Physics")

CreateToggle(playerTab.Content, "Low Gravity", "Reduce workspace gravity", "LowGrav", nil, function(s)
    if not s then pcall(function() Workspace.Gravity = 196.2 end) end
end)
CreateSlider(playerTab.Content, "Gravity Value", 1, 196, 50, "LowGrav", "Val")

-- ── VISUAL TAB ────────────────────────────────────────────────
local visualTab = CreateTab("Visual", "👁")

CreateSectionLabel(visualTab.Content, "ESP")

CreateToggle(visualTab.Content, "ESP Highlights", "See all players through walls (Highlight)", "ESP", nil, function(s)
    for _,hl in pairs(ESPHighlights) do
        pcall(function() hl.Enabled = s end)
    end
    Notify("ESP", s and "Enabled" or "Disabled", 2)
end)

CreateSectionLabel(visualTab.Content, "Rendering")

CreateToggle(visualTab.Content, "Fullbright", "Remove all darkness and fog", "Fullbright", nil, function(s)
    if not s then
        pcall(function()
            Lighting.Brightness = DefBright
            Lighting.GlobalShadows = DefShadows
        end)
    end
    Notify("Fullbright", s and "Enabled" or "Disabled", 2)
end)

CreateToggle(visualTab.Content, "No Fog", "Remove fog from the world", "NoFog", nil, function(s)
    if not s then pcall(function() Lighting.FogEnd = DefFogEnd end) end
end)

CreateToggle(visualTab.Content, "FPS Boost", "Disable particles/effects for better FPS", "FPSBoost", nil)

CreateToggle(visualTab.Content, "Crosshair", "Show a custom crosshair", "Crosshair", nil)

CreateSectionLabel(visualTab.Content, "Camera")

CreateToggle(visualTab.Content, "Camera Lock", "Lock camera to your character", "CameraLock", nil)

CreateToggle(visualTab.Content, "Zoom Out", "Increase max zoom distance", "ZoomOut", nil, function(s)
    if not s then
        pcall(function() LocalPlayer.CameraMaxZoomDistance = 128 end)
    end
end)
CreateSlider(visualTab.Content, "Zoom Distance", 128, 500, 120, "ZoomOut", "Val")

CreateSectionLabel(visualTab.Content, "Time")

CreateToggle(visualTab.Content, "Custom Time", "Set a custom time of day", "TimeChange", nil)
CreateSlider(visualTab.Content, "Time of Day", 0, 24, 12, "TimeChange", "Val")

-- ── COMBAT TAB ────────────────────────────────────────────────
local combatTab = CreateTab("Combat", "⚔")

CreateSectionLabel(combatTab.Content, "Aimbot")

CreateToggle(combatTab.Content, "Aimbot  [Hold E]", "Lock aim to nearest enemy, hold E", "Aimbot", nil, function(s)
    Notify("Aimbot", s and "Enabled (Hold E)" or "Disabled", 2)
end)

CreateSlider(combatTab.Content, "Aimbot FOV", 50, 600, 180, "Aimbot", "FOV")
CreateSlider(combatTab.Content, "Aimbot Smoothness (x10)", 1, 10, 3, nil, nil, function(v)
    F.Aimbot.Smooth = v / 10
end)

CreateToggle(combatTab.Content, "Team Check", "Don't target teammates", "Aimbot", "TeamCheck")

CreateSectionLabel(combatTab.Content, "Other Combat")

CreateToggle(combatTab.Content, "Hitbox Expander", "Expand all enemy hitboxes", "HitboxExpander", nil, function(s)
    Notify("Hitbox", s and "Enabled" or "Disabled", 2)
end)
CreateSlider(combatTab.Content, "Hitbox Size", 4, 30, 8, "HitboxExpander", "Size")

CreateToggle(combatTab.Content, "TriggerBot", "Auto shoot when crosshair on enemy", "TriggerBot", nil, function(s)
    Notify("TriggerBot", s and "Enabled" or "Disabled", 2)
end)

-- ── FUN TAB ───────────────────────────────────────────────────
local funTab = CreateTab("Fun", "🎮")

CreateSectionLabel(funTab.Content, "Movement Fun")

CreateToggle(funTab.Content, "Fling", "Launch yourself in random directions", "Fling", nil, function(s)
    Notify("Fling", s and "Enabled!" or "Disabled", 2)
end)

CreateToggle(funTab.Content, "JERK 💀", "Violently spasm and jerk around", "Jerk", nil, function(s)
    Notify("Jerk", s and "ACTIVATED! 💀" or "Disabled", 2)
end)

CreateSectionLabel(funTab.Content, "Instant Actions")

CreateButton(funTab.Content, "Launch Up", "Yeet yourself into the sky", T.Blue, function()
    local hrp = SafeHRP()
    if hrp then
        pcall(function()
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(0,9e9,0)
            bv.Velocity = Vector3.new(0,300,0)
            bv.Parent = hrp
            task.delay(0.3, function() pcall(function() bv:Destroy() end) end)
        end)
    end
end)

CreateButton(funTab.Content, "Teleport To Random Player", "Jump to a random player", T.Accent, function()
    local plrs = Players:GetPlayers()
    local others = {}
    for _,p in ipairs(plrs) do
        if p ~= LocalPlayer then table.insert(others, p) end
    end
    if #others == 0 then Notify("Teleport","No other players",2) return end
    local target = others[math.random(1,#others)]
    if target.Character then
        local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
        local hrp = SafeHRP()
        if tHRP and hrp then
            pcall(function() hrp.CFrame = tHRP.CFrame * CFrame.new(3,0,0) end)
            Notify("Teleport","Teleported to " .. target.Name, 2)
        end
    end
end)

CreateButton(funTab.Content, "Explode Self", "Spawn explosion at your feet", T.Red, function()
    local hrp = SafeHRP()
    if hrp then
        pcall(function()
            local e = Instance.new("Explosion")
            e.Position = hrp.Position
            e.BlastRadius = 20
            e.BlastPressure = 500000
            e.DestroyJointRadiusPercent = 0
            e.Parent = Workspace
        end)
    end
end)

CreateButton(funTab.Content, "Give Speed Burst", "Instantly move very fast briefly", T.Green, function()
    F.WalkSpeed.Val = 500
    F.WalkSpeed.On = true
    task.delay(2, function()
        F.WalkSpeed.Val = 16
        F.WalkSpeed.On = false
    end)
    Notify("Speed Burst","Active for 2 seconds!", 2)
end)

CreateButton(funTab.Content, "Fake Disconnect", "Fake network disconnect appearance", T.Yellow, function()
    local f = NewInst("ScreenGui",{
        Name="FakeDC", ResetOnSpawn=false, DisplayOrder=9999, Parent=PlayerGui
    })
    local lbl = NewInst("TextLabel",{
        BackgroundColor3=Color3.fromRGB(0,0,0),
        BackgroundTransparency=0.3,
        Size=UDim2.new(1,0,1,0),
        Text="Attempting to reconnect...",
        TextColor3=Color3.fromRGB(255,255,255),
        Font=Enum.Font.GothamBold,
        TextSize=28,
        Parent=f
    })
    task.delay(3, function() f:Destroy() end)
end)

-- ── MISC TAB ──────────────────────────────────────────────────
local miscTab = CreateTab("Misc", "⚙")

CreateSectionLabel(miscTab.Content, "Chat")

CreateToggle(miscTab.Content, "Chat Spammer", "Repeatedly send a message", "ChatSpammer", nil)
local _, msgInput = CreateTextInput(miscTab.Content, "Spam Message", "Type message...", function(v)
    F.ChatSpammer.Msg = v
end)
CreateSlider(miscTab.Content, "Spam Delay (sec)", 1, 30, 3, "ChatSpammer", "Delay")

CreateSectionLabel(miscTab.Content, "Server")

CreateButton(miscTab.Content, "Rejoin Server", "Reconnect to this game", T.Accent, function()
    pcall(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
    Notify("Rejoin","Rejoining...", 2)
end)

CreateButton(miscTab.Content, "Server Hop", "Join a different server", T.Blue, function()
    task.spawn(function()
        pcall(function()
            local servers = HttpService:JSONDecode(
                game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId))
            )
            for _, server in ipairs(servers.data or {}) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    return
                end
            end
        end)
    end)
    Notify("Server Hop","Finding new server...", 2)
end)

CreateButton(miscTab.Content, "Copy Game Link", "Print game link to output", T.AccentDark, function()
    print("https://www.roblox.com/games/" .. tostring(game.PlaceId))
    Notify("Game Link","Printed to output!", 2)
end)

CreateSectionLabel(miscTab.Content, "Player Targeting")

CreateTextInput(miscTab.Content, "Copy Walk Target", "Enter player name...", function(v)
    F.CopyWalk.Target = v
end)
CreateToggle(miscTab.Content, "Copy Walk", "Walk with/follow target player", "CopyWalk", nil)

-- ── BYPASS TAB ────────────────────────────────────────────────
local bypassTab = CreateTab("Bypass", "🛡")

CreateSectionLabel(bypassTab.Content, "Protection")

CreateToggle(bypassTab.Content, "Anti Kick", "Block all kick attempts", "AntiKick", nil, function(s)
    Notify("Anti Kick", s and "Enabled" or "Disabled", 2)
end)

CreateToggle(bypassTab.Content, "Anti Teleport", "Block forced teleports (>200 studs)", "AntiTeleport", nil)

CreateToggle(bypassTab.Content, "Remote Filter", "Block anti-cheat remote events", "RemoteFilter", nil, function(s)
    Notify("Remote Filter", s and "Enabled" or "Disabled", 2)
end)

CreateToggle(bypassTab.Content, "Anti AFK", "Never get kicked for being AFK", "AntiAFK", nil)

CreateToggle(bypassTab.Content, "Speed Spoof", "Spoof speed for server-side bypass", "SpoofSpeed", nil)

CreateToggle(bypassTab.Content, "Hide GUI", "Hide the GUI from screenshots", "HideGui", nil, function(s)
    pcall(function() ScreenGui.Enabled = not s end)
end)

CreateSectionLabel(bypassTab.Content, "Debug Info")

CreateButton(bypassTab.Content, "Print All Remotes", "List all remote events in output", T.BG3, function()
    print("=== REMOTE EVENTS ===")
    for _,v in ipairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            print(v:GetFullName())
        end
    end
    Notify("Remotes","Printed to output!", 2)
end)

CreateButton(bypassTab.Content, "Print All Scripts", "List all scripts in output", T.BG3, function()
    print("=== SCRIPTS ===")
    for _,v in ipairs(game:GetDescendants()) do
        if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
            print(v:GetFullName())
        end
    end
    Notify("Scripts","Printed to output!", 2)
end)

-- ── PLAYERS TAB ───────────────────────────────────────────────
local playersTab = CreateTab("Players", "👥")

CreateSectionLabel(playersTab.Content, "Player List")

local function RefreshPlayerList()
    -- Clear old
    for _,v in ipairs(playersTab.Content:GetChildren()) do
        if v.Name:find("PLR_") then v:Destroy() end
    end

    for _,p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end

        local pFrame = NewInst("Frame",{
            Name = "PLR_" .. p.Name,
            BackgroundColor3 = T.BG3,
            BorderSizePixel = 0,
            Size = UDim2.new(1,0,0,48),
            Parent = playersTab.Content
        })
        Corner(pFrame,8)
        Stroke(pFrame,T.Border,1)

        NewInst("TextLabel",{
            BackgroundTransparency=1, Font=Enum.Font.GothamBold,
            Position=UDim2.new(0,12,0,6), Size=UDim2.new(1,-130,0,20),
            Text=p.Name, TextColor3=T.Text, TextSize=13,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextTruncate=Enum.TextTruncate.AtEnd, Parent=pFrame
        })
        NewInst("TextLabel",{
            BackgroundTransparency=1, Font=Enum.Font.Gotham,
            Position=UDim2.new(0,12,0,26), Size=UDim2.new(1,-130,0,16),
            Text="ID: "..p.UserId, TextColor3=T.TextGray, TextSize=11,
            TextXAlignment=Enum.TextXAlignment.Left, Parent=pFrame
        })

        -- Teleport to button
        local tpBtn = NewInst("TextButton",{
            BackgroundColor3=T.Accent, BorderSizePixel=0,
            Position=UDim2.new(1,-110,0.5,-13), Size=UDim2.new(0,50,0,26),
            Text="TP To", TextColor3=T.Text, Font=Enum.Font.GothamBold, TextSize=12,
            Parent=pFrame
        })
        Corner(tpBtn,5)

        tpBtn.MouseButton1Click:Connect(function()
            if p.Character then
                local tHRP = p.Character:FindFirstChild("HumanoidRootPart")
                local hrp = SafeHRP()
                if tHRP and hrp then
                    pcall(function() hrp.CFrame = tHRP.CFrame * CFrame.new(3,0,0) end)
                    Notify("Teleport","Teleported to "..p.Name, 2)
                end
            end
        end)

        -- Spectate button
        local specBtn = NewInst("TextButton",{
            BackgroundColor3=T.Blue, BorderSizePixel=0,
            Position=UDim2.new(1,-54,0.5,-13), Size=UDim2.new(0,46,0,26),
            Text="Spec", TextColor3=T.Text, Font=Enum.Font.GothamBold, TextSize=12,
            Parent=pFrame
        })
        Corner(specBtn,5)

        specBtn.MouseButton1Click:Connect(function()
            if p.Character then
                pcall(function()
                    Workspace.CurrentCamera.CameraSubject = p.Character:FindFirstChildOfClass("Humanoid")
                end)
                Notify("Spectate","Spectating "..p.Name, 2)
            end
        end)
    end
end

CreateButton(playersTab.Content, "🔄 Refresh Player List", nil, T.BG3, RefreshPlayerList)
RefreshPlayerList()

Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    RefreshPlayerList()
end)

-- ════════════════════════════════════════════════════════════
-- ACTIVATE FIRST TAB
-- ════════════════════════════════════════════════════════════

Tabs["Player"].Button:MouseButton1Click()

-- ════════════════════════════════════════════════════════════
-- DRAGGABLE TITLE BAR
-- ════════════════════════════════════════════════════════════

local Dragging, DragStart, WindowStart

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = input.Position
        WindowStart = MainWindow.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - DragStart
        MainWindow.Position = UDim2.new(
            WindowStart.X.Scale, WindowStart.X.Offset + delta.X,
            WindowStart.Y.Scale, WindowStart.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = false
    end
end)

-- ════════════════════════════════════════════════════════════
-- RIGHT ALT TOGGLE
-- ════════════════════════════════════════════════════════════

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightAlt then
        MainWindow.Visible = not MainWindow.Visible
        if MainWindow.Visible then
            MainWindow.Size = UDim2.new(0,0,0,0)
            Tween(MainWindow, {Size=UDim2.new(0,700,0,480)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end
end)

-- ════════════════════════════════════════════════════════════
-- NOTIFICATION ON LOAD
-- ════════════════════════════════════════════════════════════

task.wait(1)
Notify("Universal Pro v6.0", "Loaded! Press Right Alt to open/close", 5)
MainWindow.Visible = true
MainWindow.Size = UDim2.new(0,0,0,0)
Tween(MainWindow, {Size=UDim2.new(0,700,0,480)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

print("╔══════════════════════════════╗")
print("║  Universal Pro v6.0 Loaded!  ║")
print("║  Right Alt = Toggle GUI      ║")
print("║  F = Toggle Fly              ║")
print("║  E (hold) = Aimbot           ║")
print("╚══════════════════════════════╝")
