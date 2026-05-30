-- CoolGUI v8 - FIXED UI
-- RightShift = Toggle | F = Fly | Hold E = Aimbot
print("✅ CoolGUI v8 Loading...")

-- ═══════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local StarterGui       = game:GetService("StarterGui")
local Lighting         = game:GetService("Lighting")
local TeleportService  = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")

local LP        = Players.LocalPlayer
local Cam       = workspace.CurrentCamera
local PGui      = LP:WaitForChild("PlayerGui")

-- Kill old
for _,v in ipairs(PGui:GetChildren()) do
    if v.Name == "CoolGUI_v8" then v:Destroy() end
end

-- ═══════════════════════════════════════════════
-- SETTINGS
-- ═══════════════════════════════════════════════
local S = {
    Speed=true, WalkSpeed=140,
    JumpPower=false, JumpVal=100,
    Fly=false, FlySpeed=75,
    Noclip=false, InfJump=false,
    Ghost=false, Freeze=false,
    Spin=false, SpinSpeed=8,
    BigHead=false, BigHeadScale=5,
    AntiVoid=false, LowGrav=false, GravVal=60,
    ESP=true, Fullbright=false,
    NoFog=false, Crosshair=false, FPSBoost=false,
    Aimbot=false, AimbotFOV=200, AimbotSmooth=3,
    HitboxExp=false, HitboxSize=8,
    TriggerBot=false,
    Jerk=false, Fling=false,
    AntiKick=true, AntiAFK=true,
    RemoteFilter=true, AntiTP=false,
    ChatSpam=false, ChatMsg="hi", ChatDelay=3,
    CopyWalk=false, CopyTarget="",
    TimeChange=false, TimeVal=14,
}

-- ═══════════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════════
local function GetChar()  return LP.Character end
local function GetHum()   local c=GetChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function GetHRP()   local c=GetChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function GetHead()  local c=GetChar() return c and c:FindFirstChild("Head") end

local function Notify(t, m, d)
    pcall(function()
        StarterGui:SetCore("SendNotification",{Title=t,Text=m,Duration=d or 3})
    end)
end

local function Tween(o, g, t)
    if not o then return end
    pcall(function()
        TweenService:Create(o, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), g):Play()
    end)
end

local function Corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = p
    return c
end

local function Stroke(p, col, thick)
    local s = Instance.new("UIStroke")
    s.Color = col or Color3.fromRGB(55,55,75)
    s.Thickness = thick or 1
    s.Parent = p
    return s
end

-- ═══════════════════════════════════════════════
-- BYPASS
-- ═══════════════════════════════════════════════
pcall(function() LP.Kick = function() Notify("Bypass","Kick Blocked!",2) end end)

pcall(function()
    local VU = game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        VU:CaptureController()
        VU:ClickButton2(Vector2.new())
    end)
end)

if hookmetamethod then
    pcall(function()
        local old
        old = hookmetamethod(game,"__namecall",function(self,...)
            local m = getnamecallmethod()
            if S.AntiKick and (m=="Kick" or m=="kick") then
                Notify("Bypass","Kick Blocked",2) return
            end
            if S.RemoteFilter and (m=="FireServer" or m=="InvokeServer") then
                local n = string.lower(tostring(self and self.Name or ""))
                for _,b in ipairs({"anticheat","ac_","exploit","ban","kick","detect","report","flag"}) do
                    if string.find(n,b) then
                        Notify("Bypass","Blocked: "..tostring(self.Name),2) return
                    end
                end
            end
            return old(self,...)
        end)
    end)
end

local lastSafe = nil
RunService.Heartbeat:Connect(function()
    if S.AntiTP then
        local h = GetHRP()
        if h then
            if lastSafe and (h.Position-lastSafe).Magnitude > 200 then
                pcall(function() h.CFrame = CFrame.new(lastSafe) end)
            end
            lastSafe = h.Position
        end
    end
end)

-- ═══════════════════════════════════════════════
-- FLY
-- ═══════════════════════════════════════════════
local FV, FC = nil, nil
local FK = {W=false,A=false,S=false,D=false,Space=false,LeftControl=false}

local function StartFly()
    local h = GetHRP() if not h then return end
    FV = Instance.new("BodyVelocity")
    FV.MaxForce = Vector3.new(9e9,9e9,9e9)
    FV.Velocity = Vector3.zero
    FV.Parent = h
    local hm = GetHum()
    if hm then pcall(function() hm.PlatformStand=true end) end
    FC = RunService.Heartbeat:Connect(function()
        if not S.Fly or not FV then return end
        local m = Vector3.zero
        if FK.W then m=m+Cam.CFrame.LookVector end
        if FK.S then m=m-Cam.CFrame.LookVector end
        if FK.A then m=m-Cam.CFrame.RightVector end
        if FK.D then m=m+Cam.CFrame.RightVector end
        if FK.Space then m=m+Vector3.new(0,1,0) end
        if FK.LeftControl then m=m-Vector3.new(0,1,0) end
        if m.Magnitude>0 then m=m.Unit*S.FlySpeed end
        FV.Velocity = m
    end)
end

local function StopFly()
    if FC then FC:Disconnect() FC=nil end
    pcall(function()
        if FV then FV:Destroy() FV=nil end
        local hm = GetHum()
        if hm then hm.PlatformStand=false end
    end)
end

-- ═══════════════════════════════════════════════
-- JERK
-- ═══════════════════════════════════════════════
local jerkOn = false
RunService.Heartbeat:Connect(function()
    if S.Jerk and not jerkOn then
        jerkOn = true
        task.spawn(function()
            while S.Jerk do
                local h = GetHRP()
                if h then pcall(function()
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
                    bv.Velocity = Vector3.new(math.random(-250,250),math.random(-80,250),math.random(-250,250))
                    bv.Parent = h task.wait(0.055) bv:Destroy()
                    local ba = Instance.new("BodyAngularVelocity")
                    ba.MaxTorque = Vector3.new(9e9,9e9,9e9)
                    ba.AngularVelocity = Vector3.new(math.random(-30,30),math.random(-30,30),math.random(-30,30))
                    ba.Parent = h task.wait(0.055) ba:Destroy()
                end) end
                task.wait(0.08)
            end
            jerkOn = false
        end)
    end
end)

-- ═══════════════════════════════════════════════
-- FLING
-- ═══════════════════════════════════════════════
local flingOn = false
RunService.Heartbeat:Connect(function()
    if S.Fling and not flingOn then
        flingOn = true
        task.spawn(function()
            while S.Fling do
                local h = GetHRP()
                if h then pcall(function()
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
                    bv.Velocity = Vector3.new(math.random(-400,400),math.random(150,400),math.random(-400,400))
                    bv.Parent = h task.wait(0.15) bv:Destroy()
                end) end
                task.wait(0.4)
            end
            flingOn = false
        end)
    end
end)

-- ═══════════════════════════════════════════════
-- FEATURE LOOPS
-- ═══════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    local hm = GetHum()
    local h  = GetHRP()
    local hd = GetHead()

    if hm and S.Speed     then pcall(function() hm.WalkSpeed = S.WalkSpeed end) end
    if hm and S.JumpPower then pcall(function() hm.JumpPower=S.JumpVal hm.UseJumpPower=true end) end
    if h  and S.Spin      then pcall(function() h.CFrame=h.CFrame*CFrame.Angles(0,math.rad(S.SpinSpeed),0) end) end
    if hd and S.BigHead   then pcall(function() hd.Size=Vector3.new(S.BigHeadScale,S.BigHeadScale,S.BigHeadScale) end) end
    if S.LowGrav          then pcall(function() workspace.Gravity=S.GravVal end) end
    if S.TimeChange       then pcall(function() Lighting.ClockTime=S.TimeVal end) end
    if S.Fullbright       then pcall(function() Lighting.Brightness=10 Lighting.GlobalShadows=false Lighting.FogEnd=1e9 end) end
    if S.NoFog            then pcall(function() Lighting.FogEnd=1e9 end) end
    if h and S.AntiVoid and h.Position.Y < -150 then
        pcall(function() h.CFrame=CFrame.new(h.Position.X,10,h.Position.Z) end)
    end
end)

RunService.Stepped:Connect(function()
    if S.Noclip then
        local c=GetChar() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then pcall(function() p.CanCollide=false end) end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if S.Ghost then
        local c=GetChar() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then pcall(function() p.CanCollide=false p.Transparency=0.6 end) end
        end
    end
    local h=GetHRP() if not h then return end
    if S.Freeze then pcall(function() h.Anchored=true end)
    elseif h.Anchored then pcall(function() h.Anchored=false end) end
end)

UserInputService.JumpRequest:Connect(function()
    if S.InfJump then
        local hm=GetHum() if hm then pcall(function() hm:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    end
end)

RunService.Heartbeat:Connect(function()
    if S.FPSBoost then
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                pcall(function() v.Enabled=false end)
            end
        end
    end
    if S.HitboxExp then
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                local hr=p.Character:FindFirstChild("HumanoidRootPart")
                if hr then pcall(function() hr.Size=Vector3.new(S.HitboxSize,S.HitboxSize,S.HitboxSize) end) end
            end
        end
    end
    if S.TriggerBot then
        local ray=Cam:ViewportPointToRay(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)
        local res=workspace:Raycast(ray.Origin,ray.Direction*1000)
        if res and res.Instance then
            local mdl=res.Instance:FindFirstAncestorOfClass("Model")
            if mdl then
                local pl=Players:GetPlayerFromCharacter(mdl)
                if pl and pl~=LP then
                    if mouse1press then mouse1press() task.wait(0.05) mouse1release() end
                end
            end
        end
    end
    if S.CopyWalk and S.CopyTarget~="" then
        local t=Players:FindFirstChild(S.CopyTarget)
        if t and t.Character then
            local th=t.Character:FindFirstChild("HumanoidRootPart") local mh=GetHRP()
            if th and mh then pcall(function() mh.CFrame=th.CFrame*CFrame.new(3,0,0) end) end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not S.Aimbot then return end
    if not UserInputService:IsKeyDown(Enum.KeyCode.E) then return end
    local mp=UserInputService:GetMouseLocation()
    local best,bd=nil,S.AimbotFOV
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local c=p.Character if not c then continue end
        local hd=c:FindFirstChild("Head") if not hd then continue end
        local pos,on=Cam:WorldToViewportPoint(hd.Position)
        if not on then continue end
        local d=(Vector2.new(pos.X,pos.Y)-mp).Magnitude
        if d<bd then bd=d best=hd end
    end
    if best and mousemoverel then
        local pos=Cam:WorldToViewportPoint(best.Position)
        local diff=Vector2.new(pos.X,pos.Y)-mp
        local sm=S.AimbotSmooth/10
        mousemoverel(diff.X*sm,diff.Y*sm)
    end
end)

task.spawn(function()
    while true do
        task.wait(math.max(S.ChatDelay,1))
        if S.ChatSpam then
            pcall(function()
                local tcs=game:GetService("TextChatService")
                if tcs and tcs.TextChannels then
                    local ch=tcs.TextChannels:FindFirstChild("RBXGeneral")
                    if ch then ch:SendAsync(S.ChatMsg) end
                end
            end)
        end
    end
end)

LP.CharacterAdded:Connect(function()
    task.wait(1)
    if S.Fly then StopFly() task.wait(0.3) StartFly() end
end)

-- ═══════════════════════════════════════════════
-- ESP (Drawing API)
-- ═══════════════════════════════════════════════
local ESPBoxes, ESPNames, ESPBars, ESPLines = {},{},{},{}

local function AddESP(p)
    if p==LP then return end
    local box=Drawing.new("Square") box.Thickness=2 box.Filled=false
    box.Color=Color3.fromRGB(0,170,255) box.Transparency=1 box.Visible=false
    ESPBoxes[p]=box

    local nm=Drawing.new("Text") nm.Size=13 nm.Center=true nm.Outline=true
    nm.Color=Color3.fromRGB(255,255,255) nm.Visible=false nm.Text=p.Name
    ESPNames[p]=nm

    local bar=Drawing.new("Line") bar.Thickness=3
    bar.Color=Color3.fromRGB(0,255,100) bar.Visible=false
    ESPBars[p]=bar

    local ln=Drawing.new("Line") ln.Thickness=1
    ln.Color=Color3.fromRGB(255,50,50) ln.Visible=false
    ESPLines[p]=ln
end

for _,p in ipairs(Players:GetPlayers()) do AddESP(p) end
Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(function(p)
    for _,tbl in ipairs({ESPBoxes,ESPNames,ESPBars,ESPLines}) do
        if tbl[p] then tbl[p]:Remove() tbl[p]=nil end
    end
end)

RunService.RenderStepped:Connect(function()
    for p,box in pairs(ESPBoxes) do
        local show = S.ESP and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if show then
            local root=p.Character.HumanoidRootPart
            local pos,on=Cam:WorldToViewportPoint(root.Position)
            if on then
                local dist=(Cam.CFrame.Position-root.Position).Magnitude
                local sz=1800/dist
                box.Size=Vector2.new(sz,sz*2.2)
                box.Position=Vector2.new(pos.X-sz/2,pos.Y-sz*1.1)
                box.Visible=true
                if ESPNames[p] then
                    ESPNames[p].Position=Vector2.new(pos.X,pos.Y-sz*1.1-18)
                    ESPNames[p].Text=p.Name.." ["..math.floor(dist).."]"
                    ESPNames[p].Visible=true
                end
                if ESPBars[p] then
                    local hm=p.Character:FindFirstChildOfClass("Humanoid")
                    if hm then
                        local hp=hm.Health/hm.MaxHealth
                        local bh=sz*2.2 local sy=pos.Y-sz*1.1
                        local col=hp>0.6 and Color3.fromRGB(0,255,100) or hp>0.3 and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,50,50)
                        ESPBars[p].From=Vector2.new(pos.X-sz/2-6,sy+bh*(1-hp))
                        ESPBars[p].To=Vector2.new(pos.X-sz/2-6,sy+bh)
                        ESPBars[p].Color=col ESPBars[p].Visible=true
                    end
                end
                if ESPLines[p] then
                    ESPLines[p].From=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y)
                    ESPLines[p].To=Vector2.new(pos.X,pos.Y)
                    ESPLines[p].Visible=true
                end
            else
                box.Visible=false
                if ESPNames[p] then ESPNames[p].Visible=false end
                if ESPBars[p] then ESPBars[p].Visible=false end
                if ESPLines[p] then ESPLines[p].Visible=false end
            end
        else
            box.Visible=false
            if ESPNames[p] then ESPNames[p].Visible=false end
            if ESPBars[p] then ESPBars[p].Visible=false end
            if ESPLines[p] then ESPLines[p].Visible=false end
        end
    end
end)

-- Crosshair Drawing
local CHL1=Drawing.new("Line") CHL1.Thickness=2 CHL1.Color=Color3.new(1,1,1) CHL1.Visible=false
local CHL2=Drawing.new("Line") CHL2.Thickness=2 CHL2.Color=Color3.new(1,1,1) CHL2.Visible=false
local CHFOV=Drawing.new("Circle") CHFOV.Thickness=1 CHFOV.Filled=false CHFOV.Color=Color3.fromRGB(255,255,255) CHFOV.Visible=false

RunService.RenderStepped:Connect(function()
    local cx=Cam.ViewportSize.X/2 local cy=Cam.ViewportSize.Y/2
    CHL1.From=Vector2.new(cx,cy-14) CHL1.To=Vector2.new(cx,cy+14)
    CHL2.From=Vector2.new(cx-14,cy) CHL2.To=Vector2.new(cx+14,cy)
    CHL1.Visible=S.Crosshair CHL2.Visible=S.Crosshair
    CHFOV.Position=Vector2.new(cx,cy) CHFOV.Radius=S.AimbotFOV
    CHFOV.Visible=S.Aimbot
end)

-- ═══════════════════════════════════════════════
-- INPUT
-- ═══════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    local k=tostring(input.KeyCode):gsub("Enum.KeyCode.","")
    if FK[k]~=nil then FK[k]=true end
    if input.KeyCode==Enum.KeyCode.F then
        S.Fly=not S.Fly
        if S.Fly then StartFly() else StopFly() end
        Notify("Fly",S.Fly and "ON" or "OFF",2)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    local k=tostring(input.KeyCode):gsub("Enum.KeyCode.","")
    if FK[k]~=nil then FK[k]=false end
end)

-- ═══════════════════════════════════════════════
-- GUI - COMPLETELY REBUILT FROM SCRATCH
-- ═══════════════════════════════════════════════

local SGui = Instance.new("ScreenGui")
SGui.Name = "CoolGUI_v8"
SGui.ResetOnSpawn = false
SGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SGui.DisplayOrder = 9999
SGui.Parent = PGui

-- ── COLORS ──────────────────────────────────────
local BG1  = Color3.fromRGB(15,15,22)
local BG2  = Color3.fromRGB(22,22,32)
local BG3  = Color3.fromRGB(30,30,42)
local BG4  = Color3.fromRGB(38,38,52)
local ACC  = Color3.fromRGB(0,170,255)
local ACCD = Color3.fromRGB(0,120,200)
local ACCL = Color3.fromRGB(80,200,255)
local GRN  = Color3.fromRGB(0,200,100)
local RED  = Color3.fromRGB(220,60,60)
local YLW  = Color3.fromRGB(220,180,50)
local WHT  = Color3.fromRGB(255,255,255)
local GRY  = Color3.fromRGB(150,150,170)
local BDR  = Color3.fromRGB(50,50,68)

-- ── MAIN WINDOW ─────────────────────────────────
local Win = Instance.new("Frame")
Win.Name = "Win"
Win.BackgroundColor3 = BG1
Win.BorderSizePixel = 0
Win.Position = UDim2.new(0.5,-350,0.5,-260)
Win.Size = UDim2.new(0,700,0,520)
Win.Visible = false
Win.Parent = SGui
Corner(Win, 14)
Stroke(Win, BDR, 1)

-- Shadow
local Shad = Instance.new("ImageLabel")
Shad.BackgroundTransparency=1
Shad.Image="rbxassetid://5554236805"
Shad.ImageColor3=Color3.new(0,0,0)
Shad.ImageTransparency=0.5
Shad.Position=UDim2.new(0,-20,0,-20)
Shad.Size=UDim2.new(1,40,1,40)
Shad.ZIndex=0
Shad.Parent=Win

-- ── TOPBAR ──────────────────────────────────────
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.BackgroundColor3 = BG2
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1,0,0,52)
TopBar.Parent = Win
Corner(TopBar, 14)

-- Fix bottom corners
local TBFix = Instance.new("Frame")
TBFix.BackgroundColor3 = BG2
TBFix.BorderSizePixel = 0
TBFix.Position = UDim2.new(0,0,0.5,0)
TBFix.Size = UDim2.new(1,0,0.5,0)
TBFix.Parent = TopBar

-- Bottom accent line
local AccLine = Instance.new("Frame")
AccLine.BackgroundColor3 = ACC
AccLine.BorderSizePixel = 0
AccLine.Position = UDim2.new(0,0,1,-2)
AccLine.Size = UDim2.new(1,0,0,2)
AccLine.Parent = TopBar

-- Logo dot
local LDot = Instance.new("Frame")
LDot.BackgroundColor3 = ACC
LDot.BorderSizePixel = 0
LDot.Position = UDim2.new(0,14,0.5,-11)
LDot.Size = UDim2.new(0,22,0,22)
LDot.Parent = TopBar
Corner(LDot, 5)

-- Title
local TitleL = Instance.new("TextLabel")
TitleL.BackgroundTransparency = 1
TitleL.Font = Enum.Font.GothamBlack
TitleL.Position = UDim2.new(0,44,0,0)
TitleL.Size = UDim2.new(0,180,1,0)
TitleL.Text = "COOLGUI"
TitleL.TextColor3 = WHT
TitleL.TextSize = 22
TitleL.TextXAlignment = Enum.TextXAlignment.Left
TitleL.Parent = TopBar

-- Version badge
local VBG = Instance.new("Frame")
VBG.BackgroundColor3 = ACCD
VBG.BorderSizePixel = 0
VBG.Position = UDim2.new(0,228,0.5,-11)
VBG.Size = UDim2.new(0,42,0,22)
VBG.Parent = TopBar
Corner(VBG, 5)

local VL = Instance.new("TextLabel")
VL.BackgroundTransparency=1 VL.Font=Enum.Font.GothamBold
VL.Size=UDim2.new(1,0,1,0) VL.Text="v8.0"
VL.TextColor3=WHT VL.TextSize=12 VL.Parent=VBG

-- Hint
local HintL = Instance.new("TextLabel")
HintL.BackgroundTransparency=1 HintL.Font=Enum.Font.Gotham
HintL.Position=UDim2.new(0,280,0,0) HintL.Size=UDim2.new(0,240,1,0)
HintL.Text="RShift=Open  F=Fly  E=Aim" HintL.TextColor3=GRY
HintL.TextSize=12 HintL.TextXAlignment=Enum.TextXAlignment.Left HintL.Parent=TopBar

-- Close btn
local CloseB = Instance.new("TextButton")
CloseB.BackgroundColor3=RED CloseB.BorderSizePixel=0
CloseB.Position=UDim2.new(1,-42,0.5,-13) CloseB.Size=UDim2.new(0,26,0,26)
CloseB.Text="✕" CloseB.TextColor3=WHT CloseB.Font=Enum.Font.GothamBold CloseB.TextSize=13
CloseB.Parent=TopBar Corner(CloseB,6)
CloseB.MouseButton1Click:Connect(function() Win.Visible=false end)

-- Minimize btn
local MinB = Instance.new("TextButton")
MinB.BackgroundColor3=YLW MinB.BorderSizePixel=0
MinB.Position=UDim2.new(1,-76,0.5,-13) MinB.Size=UDim2.new(0,26,0,26)
MinB.Text="—" MinB.TextColor3=BG1 MinB.Font=Enum.Font.GothamBold MinB.TextSize=14
MinB.Parent=TopBar Corner(MinB,6)

local minimized=false
MinB.MouseButton1Click:Connect(function()
    minimized=not minimized
    Tween(Win,{Size=minimized and UDim2.new(0,700,0,52) or UDim2.new(0,700,0,520)},0.25)
end)

-- Drag
local dragging,dStart,wStart=false,nil,nil
TopBar.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true dStart=i.Position wStart=Win.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-dStart
        Win.Position=UDim2.new(wStart.X.Scale,wStart.X.Offset+d.X,wStart.Y.Scale,wStart.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)

-- ── LEFT SIDEBAR ─────────────────────────────────
local SideBar = Instance.new("Frame")
SideBar.BackgroundColor3 = BG2
SideBar.BorderSizePixel = 0
SideBar.Position = UDim2.new(0,0,0,52)
SideBar.Size = UDim2.new(0,160,1,-52)
SideBar.Parent = Win
Corner(SideBar, 14)

-- Right side of sidebar (no round corners)
local SBFix = Instance.new("Frame")
SBFix.BackgroundColor3=BG2 SBFix.BorderSizePixel=0
SBFix.Position=UDim2.new(1,-14,0,0) SBFix.Size=UDim2.new(0,14,1,0) SBFix.Parent=SideBar

local SBBorder = Instance.new("Frame")
SBBorder.BackgroundColor3=BDR SBBorder.BorderSizePixel=0
SBBorder.Position=UDim2.new(1,-1,0,0) SBBorder.Size=UDim2.new(0,1,1,0) SBBorder.Parent=SideBar

-- Player card in sidebar
local PCard = Instance.new("Frame")
PCard.BackgroundColor3=BG3 PCard.BorderSizePixel=0
PCard.Position=UDim2.new(0,10,0,10) PCard.Size=UDim2.new(1,-20,0,50)
PCard.Parent=SideBar Corner(PCard,8)

local PCName = Instance.new("TextLabel")
PCName.BackgroundTransparency=1 PCName.Font=Enum.Font.GothamBold
PCName.Position=UDim2.new(0,10,0,6) PCName.Size=UDim2.new(1,-20,0,20)
PCName.Text=LP.Name PCName.TextColor3=WHT PCName.TextSize=13
PCName.TextXAlignment=Enum.TextXAlignment.Left
PCName.TextTruncate=Enum.TextTruncate.AtEnd PCName.Parent=PCard

local PCID = Instance.new("TextLabel")
PCID.BackgroundTransparency=1 PCID.Font=Enum.Font.Gotham
PCID.Position=UDim2.new(0,10,0,26) PCID.Size=UDim2.new(1,-20,0,16)
PCID.Text="ID: "..LP.UserId PCID.TextColor3=GRY PCID.TextSize=10
PCID.TextXAlignment=Enum.TextXAlignment.Left PCID.Parent=PCard

-- Tab button container
local TabBtnHolder = Instance.new("Frame")
TabBtnHolder.BackgroundTransparency=1
TabBtnHolder.Position=UDim2.new(0,10,0,70)
TabBtnHolder.Size=UDim2.new(1,-20,1,-80)
TabBtnHolder.Parent=SideBar

local TBHLayout = Instance.new("UIListLayout")
TBHLayout.Padding=UDim.new(0,5)
TBHLayout.SortOrder=Enum.SortOrder.LayoutOrder
TBHLayout.Parent=TabBtnHolder

-- ── CONTENT AREA ─────────────────────────────────
local ContentHolder = Instance.new("Frame")
ContentHolder.BackgroundTransparency=1
ContentHolder.Position=UDim2.new(0,160,0,52)
ContentHolder.Size=UDim2.new(1,-160,1,-52)
ContentHolder.ClipsDescendants=true
ContentHolder.Parent=Win

-- ═══════════════════════════════════════════════
-- TAB SYSTEM (REBUILT - SIMPLE & RELIABLE)
-- ═══════════════════════════════════════════════
local AllTabs = {}
local CurrentTabName = nil

local function NewTab(name, icon)
    -- Sidebar button
    local Btn = Instance.new("TextButton")
    Btn.Name = "TB_"..name
    Btn.BackgroundColor3 = BG2
    Btn.BorderSizePixel = 0
    Btn.Size = UDim2.new(1,0,0,36)
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Btn.Parent = TabBtnHolder
    Corner(Btn, 7)

    local BtnIcon = Instance.new("TextLabel")
    BtnIcon.BackgroundTransparency=1 BtnIcon.Font=Enum.Font.GothamBold
    BtnIcon.Position=UDim2.new(0,8,0,0) BtnIcon.Size=UDim2.new(0,24,1,0)
    BtnIcon.Text=icon BtnIcon.TextColor3=GRY BtnIcon.TextSize=14 BtnIcon.Parent=Btn

    local BtnName = Instance.new("TextLabel")
    BtnName.BackgroundTransparency=1 BtnName.Font=Enum.Font.GothamBold
    BtnName.Position=UDim2.new(0,34,0,0) BtnName.Size=UDim2.new(1,-44,1,0)
    BtnName.Text=name BtnName.TextColor3=GRY BtnName.TextSize=13
    BtnName.TextXAlignment=Enum.TextXAlignment.Left BtnName.Parent=Btn

    local BtnInd = Instance.new("Frame")
    BtnInd.BackgroundColor3=ACC BtnInd.BorderSizePixel=0
    BtnInd.Position=UDim2.new(0,0,0.2,0) BtnInd.Size=UDim2.new(0,3,0.6,0)
    BtnInd.Visible=false BtnInd.Parent=Btn Corner(BtnInd,2)

    -- Content scroll frame
    local Content = Instance.new("ScrollingFrame")
    Content.Name = "TC_"..name
    Content.BackgroundTransparency=1
    Content.BorderSizePixel=0
    Content.Position=UDim2.new(0,14,0,10)
    Content.Size=UDim2.new(1,-28,1,-20)
    Content.ScrollBarThickness=3
    Content.ScrollBarImageColor3=ACC
    Content.CanvasSize=UDim2.new(0,0,0,0)
    Content.Visible=false  -- HIDDEN BY DEFAULT
    Content.Parent=ContentHolder

    local CLayout = Instance.new("UIListLayout")
    CLayout.Padding=UDim.new(0,10)
    CLayout.SortOrder=Enum.SortOrder.LayoutOrder
    CLayout.Parent=Content

    CLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.CanvasSize=UDim2.new(0,0,0,CLayout.AbsoluteContentSize.Y+20)
    end)

    local TabData = {
        Btn=Btn, Content=Content, Ind=BtnInd,
        BtnName=BtnName, BtnIcon=BtnIcon
    }
    AllTabs[name] = TabData

    -- Click handler
    Btn.MouseButton1Click:Connect(function()
        -- Deactivate old tab
        if CurrentTabName and AllTabs[CurrentTabName] then
            local old = AllTabs[CurrentTabName]
            old.Content.Visible = false
            old.Ind.Visible = false
            old.BtnName.TextColor3 = GRY
            old.BtnIcon.TextColor3 = GRY
            old.Btn.BackgroundColor3 = BG2
        end
        -- Activate this tab
        CurrentTabName = name
        Content.Visible = true
        BtnInd.Visible = true
        BtnName.TextColor3 = ACCL
        BtnIcon.TextColor3 = ACCL
        Btn.BackgroundColor3 = BG3
    end)

    Btn.MouseEnter:Connect(function()
        if CurrentTabName ~= name then
            Tween(Btn,{BackgroundColor3=BG3},0.1)
        end
    end)
    Btn.MouseLeave:Connect(function()
        if CurrentTabName ~= name then
            Tween(Btn,{BackgroundColor3=BG2},0.1)
        end
    end)

    return TabData
end

-- ═══════════════════════════════════════════════
-- UI COMPONENT BUILDERS
-- ═══════════════════════════════════════════════

local function SecLabel(parent, txt)
    local f=Instance.new("Frame")
    f.BackgroundTransparency=1 f.Size=UDim2.new(1,0,0,22) f.Parent=parent
    local l=Instance.new("TextLabel")
    l.BackgroundTransparency=1 l.Font=Enum.Font.GothamBold
    l.Size=UDim2.new(1,0,1,0) l.Text="  "..txt:upper()
    l.TextColor3=ACC l.TextSize=11 l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=f
    local ln=Instance.new("Frame")
    ln.BackgroundColor3=BDR ln.BorderSizePixel=0
    ln.Position=UDim2.new(0,0,1,-1) ln.Size=UDim2.new(1,0,0,1) ln.Parent=f
    return f
end

local function MakeToggle(parent, labelTxt, descTxt, stateKey, onToggle)
    local fr=Instance.new("Frame")
    fr.BackgroundColor3=BG3 fr.BorderSizePixel=0
    fr.Size=UDim2.new(1,0,0,descTxt and 58 or 46)
    fr.Parent=parent Corner(fr,9) Stroke(fr,BDR,1)

    local nl=Instance.new("TextLabel")
    nl.BackgroundTransparency=1 nl.Font=Enum.Font.GothamBold
    nl.Position=UDim2.new(0,12,0,descTxt and 7 or 0)
    nl.Size=UDim2.new(1,-66,0,22)
    nl.Text=labelTxt nl.TextColor3=WHT nl.TextSize=14
    nl.TextXAlignment=Enum.TextXAlignment.Left nl.Parent=fr

    if descTxt then
        local dl=Instance.new("TextLabel")
        dl.BackgroundTransparency=1 dl.Font=Enum.Font.Gotham
        dl.Position=UDim2.new(0,12,0,30) dl.Size=UDim2.new(1,-66,0,18)
        dl.Text=descTxt dl.TextColor3=GRY dl.TextSize=11
        dl.TextXAlignment=Enum.TextXAlignment.Left dl.Parent=fr
    end

    local swBG=Instance.new("Frame")
    swBG.BackgroundColor3=BG1 swBG.BorderSizePixel=0
    swBG.Position=UDim2.new(1,-54,0.5,-12) swBG.Size=UDim2.new(0,42,0,24)
    swBG.Parent=fr Corner(swBG,12) Stroke(swBG,BDR,1)

    local knob=Instance.new("Frame")
    knob.BackgroundColor3=GRY knob.BorderSizePixel=0
    knob.Position=UDim2.new(0,3,0.5,-9) knob.Size=UDim2.new(0,18,0,18)
    knob.Parent=swBG Corner(knob,9)

    local state = stateKey and S[stateKey] or false

    local function SetState(v)
        state=v
        if stateKey then S[stateKey]=v end
        Tween(knob,{
            Position=v and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),
            BackgroundColor3=v and GRN or GRY
        },0.2)
        Tween(swBG,{BackgroundColor3=v and Color3.fromRGB(0,90,50) or BG1},0.2)
        if onToggle then onToggle(v) end
    end

    if state then SetState(true) end

    local clickArea=Instance.new("TextButton")
    clickArea.BackgroundTransparency=1 clickArea.Size=UDim2.new(1,0,1,0)
    clickArea.Text="" clickArea.Parent=fr
    clickArea.MouseButton1Click:Connect(function() SetState(not state) end)
    clickArea.MouseEnter:Connect(function() Tween(fr,{BackgroundColor3=BG4},0.1) end)
    clickArea.MouseLeave:Connect(function() Tween(fr,{BackgroundColor3=BG3},0.1) end)

    return fr, SetState
end

local function MakeSlider(parent, labelTxt, minV, maxV, defV, stateKey, onChange)
    local fr=Instance.new("Frame")
    fr.BackgroundColor3=BG3 fr.BorderSizePixel=0
    fr.Size=UDim2.new(1,0,0,76) fr.Parent=parent
    Corner(fr,9) Stroke(fr,BDR,1)

    local vl=Instance.new("TextLabel")
    vl.BackgroundTransparency=1 vl.Font=Enum.Font.GothamBold
    vl.Position=UDim2.new(1,-54,0,9) vl.Size=UDim2.new(0,44,0,20)
    vl.Text=tostring(defV) vl.TextColor3=ACCL vl.TextSize=14 vl.Parent=fr

    local nl=Instance.new("TextLabel")
    nl.BackgroundTransparency=1 nl.Font=Enum.Font.GothamBold
    nl.Position=UDim2.new(0,12,0,9) nl.Size=UDim2.new(1,-78,0,20)
    nl.Text=labelTxt nl.TextColor3=WHT nl.TextSize=14
    nl.TextXAlignment=Enum.TextXAlignment.Left nl.Parent=fr

    local track=Instance.new("Frame")
    track.BackgroundColor3=BG1 track.BorderSizePixel=0
    track.Position=UDim2.new(0,12,0,42) track.Size=UDim2.new(1,-24,0,8)
    track.Parent=fr Corner(track,4) Stroke(track,BDR,1)

    local fill=Instance.new("Frame")
    fill.BackgroundColor3=ACC fill.BorderSizePixel=0
    fill.Size=UDim2.new((defV-minV)/(maxV-minV),0,1,0)
    fill.Parent=track Corner(fill,4)

    local sknob=Instance.new("Frame")
    sknob.BackgroundColor3=WHT sknob.BorderSizePixel=0
    sknob.Position=UDim2.new((defV-minV)/(maxV-minV),-7,0.5,-7)
    sknob.Size=UDim2.new(0,14,0,14)
    sknob.Parent=track Corner(sknob,7) Stroke(sknob,ACC,2)

    -- Min/Max labels
    local function SmLabel(txt, xAl, xPos)
        local l=Instance.new("TextLabel")
        l.BackgroundTransparency=1 l.Font=Enum.Font.Gotham
        l.Position=UDim2.new(xPos,0,0,56) l.Size=UDim2.new(0,40,0,14)
        l.Text=txt l.TextColor3=Color3.fromRGB(70,70,90) l.TextSize=10
        l.TextXAlignment=xAl l.Parent=fr
    end
    SmLabel(tostring(minV), Enum.TextXAlignment.Left, 0)
    SmLabel(tostring(maxV), Enum.TextXAlignment.Right, 1)

    local isDrag=false

    local function Upd(x)
        local pos=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local val=math.floor(minV+(maxV-minV)*pos)
        fill.Size=UDim2.new(pos,0,1,0)
        sknob.Position=UDim2.new(pos,-7,0.5,-7)
        vl.Text=tostring(val)
        if stateKey then S[stateKey]=val end
        if onChange then onChange(val) end
    end

    sknob.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then isDrag=true end
    end)
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then isDrag=true Upd(i.Position.X) end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if isDrag and i.UserInputType==Enum.UserInputType.MouseMovement then Upd(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then isDrag=false end
    end)

    return fr
end

local function MakeButton(parent, labelTxt, descTxt, col, onClick)
    local h = descTxt and 56 or 42
    local btn=Instance.new("TextButton")
    btn.BackgroundColor3=col or ACC btn.BorderSizePixel=0
    btn.Size=UDim2.new(1,0,0,h) btn.Text="" btn.AutoButtonColor=false
    btn.Parent=parent Corner(btn,9)

    local nl=Instance.new("TextLabel")
    nl.BackgroundTransparency=1 nl.Font=Enum.Font.GothamBold
    nl.Position=UDim2.new(0,12,0,descTxt and 9 or 0)
    nl.Size=UDim2.new(1,-24,0,26)
    nl.Text=labelTxt nl.TextColor3=WHT nl.TextSize=14
    nl.TextXAlignment=Enum.TextXAlignment.Left nl.Parent=btn

    if descTxt then
        local dl=Instance.new("TextLabel")
        dl.BackgroundTransparency=1 dl.Font=Enum.Font.Gotham
        dl.Position=UDim2.new(0,12,0,32) dl.Size=UDim2.new(1,-24,0,18)
        dl.Text=descTxt dl.TextColor3=Color3.fromRGB(210,210,210) dl.TextSize=11
        dl.TextXAlignment=Enum.TextXAlignment.Left dl.Parent=btn
    end

    local og=col or ACC
    btn.MouseEnter:Connect(function() Tween(btn,{BackgroundColor3=ACCL},0.12) end)
    btn.MouseLeave:Connect(function() Tween(btn,{BackgroundColor3=og},0.12) end)
    btn.MouseButton1Click:Connect(function()
        Tween(btn,{BackgroundColor3=ACCD},0.08)
        task.delay(0.15,function() Tween(btn,{BackgroundColor3=og},0.1) end)
        if onClick then onClick() end
    end)
    return btn
end

local function MakeTextInput(parent, labelTxt, placeholder, onChange)
    local fr=Instance.new("Frame")
    fr.BackgroundColor3=BG3 fr.BorderSizePixel=0
    fr.Size=UDim2.new(1,0,0,70) fr.Parent=parent
    Corner(fr,9) Stroke(fr,BDR,1)

    local nl=Instance.new("TextLabel")
    nl.BackgroundTransparency=1 nl.Font=Enum.Font.GothamBold
    nl.Position=UDim2.new(0,12,0,9) nl.Size=UDim2.new(1,-24,0,20)
    nl.Text=labelTxt nl.TextColor3=WHT nl.TextSize=14
    nl.TextXAlignment=Enum.TextXAlignment.Left nl.Parent=fr

    local box=Instance.new("TextBox")
    box.BackgroundColor3=BG1 box.BorderSizePixel=0
    box.ClearTextOnFocus=false box.Font=Enum.Font.Gotham
    box.PlaceholderColor3=Color3.fromRGB(70,70,90) box.PlaceholderText=placeholder or "..."
    box.Position=UDim2.new(0,12,0,36) box.Size=UDim2.new(1,-24,0,26)
    box.Text="" box.TextColor3=WHT box.TextSize=13
    box.TextXAlignment=Enum.TextXAlignment.Left box.Parent=fr
    Corner(box,5) Stroke(box,BDR,1)
    local pad=Instance.new("UIPadding") pad.PaddingLeft=UDim.new(0,7) pad.Parent=box
    box.FocusLost:Connect(function() if onChange then onChange(box.Text) end end)
    return fr, box
end

-- ═══════════════════════════════════════════════
-- BUILD ALL TABS
-- ═══════════════════════════════════════════════

-- ── PLAYER ──────────────────────────────────────
local PT = NewTab("Player","👤")

SecLabel(PT.Content,"Movement")
MakeToggle(PT.Content,"Speed Hack","Override walk speed","Speed")
MakeSlider(PT.Content,"WalkSpeed",16,500,140,"WalkSpeed")
MakeToggle(PT.Content,"Jump Power","Override jump height","JumpPower")
MakeSlider(PT.Content,"Jump Value",50,500,100,"JumpVal")
MakeToggle(PT.Content,"Infinite Jump","Jump again in mid-air","InfJump")
MakeToggle(PT.Content,"Fly  [Press F]","WASD+Space+LCtrl to fly",nil)
MakeSlider(PT.Content,"Fly Speed",20,250,75,"FlySpeed")
MakeToggle(PT.Content,"Noclip","Walk through everything","Noclip")

SecLabel(PT.Content,"Character")
MakeToggle(PT.Content,"Ghost Mode","Transparent + no collision","Ghost",function(s)
    if not s then
        local c=GetChar() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then pcall(function() p.Transparency=0 end) end
        end
    end
end)
MakeToggle(PT.Content,"Spin","Rotate your character","Spin")
MakeSlider(PT.Content,"Spin Speed",1,50,8,"SpinSpeed")
MakeToggle(PT.Content,"Big Head","Giant head","BigHead")
MakeSlider(PT.Content,"Head Scale",2,25,5,"BigHeadScale")
MakeToggle(PT.Content,"Freeze","Anchor in place","Freeze")
MakeToggle(PT.Content,"Anti Void","Catch void falls","AntiVoid")

SecLabel(PT.Content,"Physics")
MakeToggle(PT.Content,"Low Gravity","Reduce workspace gravity","LowGrav",function(s)
    if not s then pcall(function() workspace.Gravity=196.2 end) end
end)
MakeSlider(PT.Content,"Gravity Value",1,196,60,"GravVal",function(v)
    if S.LowGrav then pcall(function() workspace.Gravity=v end) end
end)

-- ── VISUAL ──────────────────────────────────────
local VT = NewTab("Visual","👁")

SecLabel(VT.Content,"ESP")
MakeToggle(VT.Content,"ESP","Boxes, names, health bars, tracers","ESP")

SecLabel(VT.Content,"World")
MakeToggle(VT.Content,"Fullbright","Remove all darkness","Fullbright",function(s)
    if not s then pcall(function() Lighting.Brightness=1 Lighting.GlobalShadows=true end) end
end)
MakeToggle(VT.Content,"No Fog","Remove fog","NoFog",function(s)
    if not s then pcall(function() Lighting.FogEnd=1000 end) end
end)
MakeToggle(VT.Content,"FPS Boost","Disable particles & effects","FPSBoost")
MakeToggle(VT.Content,"Crosshair","Custom crosshair overlay","Crosshair")

SecLabel(VT.Content,"Time")
MakeToggle(VT.Content,"Custom Time","Override time of day","TimeChange")
MakeSlider(VT.Content,"Time of Day",0,24,14,"TimeVal",function(v)
    if S.TimeChange then pcall(function() Lighting.ClockTime=v end) end
end)

-- ── COMBAT ──────────────────────────────────────
local CT = NewTab("Combat","⚔")

SecLabel(CT.Content,"Aimbot")
MakeToggle(CT.Content,"Aimbot  [Hold E]","Hold E to lock onto nearest player","Aimbot",function(s)
    Notify("Aimbot",s and "Hold E to aim" or "OFF",2)
end)
MakeSlider(CT.Content,"Aimbot FOV",30,600,200,"AimbotFOV")
MakeSlider(CT.Content,"Smoothness (x10)",1,10,3,"AimbotSmooth")

SecLabel(CT.Content,"Other Combat")
MakeToggle(CT.Content,"Hitbox Expander","Expand all enemy hitboxes","HitboxExp")
MakeSlider(CT.Content,"Hitbox Size",4,40,8,"HitboxSize")
MakeToggle(CT.Content,"TriggerBot","Auto-fire when crosshair on enemy","TriggerBot")

-- ── FUN ─────────────────────────────────────────
local FunT = NewTab("Fun","🎮")

SecLabel(FunT.Content,"Chaos")
MakeToggle(FunT.Content,"JERK 💀","Violently spasm & glitch everywhere","Jerk",function(s)
    Notify("Jerk",s and "💀 ACTIVATED" or "OFF",2)
end)
MakeToggle(FunT.Content,"Fling","Launch in random directions","Fling",function(s)
    Notify("Fling",s and "ON 🚀" or "OFF",2)
end)

SecLabel(FunT.Content,"Instant Actions")
MakeButton(FunT.Content,"🚀 Launch Into Sky","Blast yourself upward",ACC,function()
    local h=GetHRP() if not h then return end
    pcall(function()
        local bv=Instance.new("BodyVelocity")
        bv.MaxForce=Vector3.new(0,9e9,0)
        bv.Velocity=Vector3.new(0,600,0)
        bv.Parent=h task.delay(0.3,function() pcall(function() bv:Destroy() end) end)
    end)
end)
MakeButton(FunT.Content,"🎯 TP To Random Player","Teleport to a random player",ACC,function()
    local pl={}
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then table.insert(pl,p) end end
    if #pl==0 then Notify("TP","No others!",2) return end
    local t=pl[math.random(1,#pl)]
    if t.Character then
        local th=t.Character:FindFirstChild("HumanoidRootPart") local mh=GetHRP()
        if th and mh then pcall(function() mh.CFrame=th.CFrame*CFrame.new(3,0,0) end)
            Notify("TP","→ "..t.Name,2) end
    end
end)
MakeButton(FunT.Content,"💥 Explode At Feet","Spawn explosion",RED,function()
    local h=GetHRP() if not h then return end
    pcall(function()
        local e=Instance.new("Explosion")
        e.Position=h.Position e.BlastRadius=25
        e.BlastPressure=4e5 e.DestroyJointRadiusPercent=0 e.Parent=workspace
    end)
end)
MakeButton(FunT.Content,"⚡ Speed Burst (2s)","500 speed for 2 seconds",GRN,function()
    local old=S.WalkSpeed
    S.WalkSpeed=500 S.Speed=true
    task.delay(2,function() S.WalkSpeed=old end)
    Notify("Speed Burst","2 seconds!",2)
end)
MakeButton(FunT.Content,"🌀 Spin Fling (3s)","Spin + fling for 3 seconds",Color3.fromRGB(140,50,220),function()
    S.Spin=true S.Fling=true
    Notify("Spin Fling","3 second chaos! 🌀",2)
    task.delay(3,function() S.Spin=false S.Fling=false end)
end)
MakeButton(FunT.Content,"📡 Fake Disconnect","Show fake error screen",YLW,function()
    local g=Instance.new("ScreenGui")
    g.Name="FDC" g.ResetOnSpawn=false g.DisplayOrder=9999 g.Parent=PGui
    local l=Instance.new("TextLabel")
    l.BackgroundColor3=Color3.new(0,0,0) l.BackgroundTransparency=0.1
    l.Size=UDim2.new(1,0,1,0)
    l.Text="Roblox\n\nAttempting to reconnect...\n\nError Code: 277"
    l.TextColor3=Color3.new(1,1,1) l.Font=Enum.Font.GothamBold l.TextSize=28 l.Parent=g
    task.delay(4,function() pcall(function() g:Destroy() end) end)
end)
MakeButton(FunT.Content,"👻 Toggle Ghost","Quick ghost mode toggle",Color3.fromRGB(80,80,120),function()
    S.Ghost=not S.Ghost
    Notify("Ghost",S.Ghost and "ON" or "OFF",2)
end)
MakeButton(FunT.Content,"❄ Quick Freeze","Freeze yourself instantly",Color3.fromRGB(60,100,180),function()
    S.Freeze=not S.Freeze
    Notify("Freeze",S.Freeze and "Frozen!" or "Unfrozen",2)
end)

-- ── MISC ────────────────────────────────────────
local MiscT = NewTab("Misc","⚙")

SecLabel(MiscT.Content,"Chat")
MakeToggle(MiscT.Content,"Chat Spammer","Send message repeatedly","ChatSpam")
MakeTextInput(MiscT.Content,"Spam Message","Type your message...",function(v) S.ChatMsg=v end)
MakeSlider(MiscT.Content,"Spam Delay (s)",1,30,3,"ChatDelay")

SecLabel(MiscT.Content,"Server")
MakeButton(MiscT.Content,"🔄 Rejoin","Reconnect to this server",ACC,function()
    pcall(function() TeleportService:Teleport(game.PlaceId,LP) end)
    Notify("Rejoin","Rejoining...",2)
end)
MakeButton(MiscT.Content,"🌐 Server Hop","Find a different server",ACCD,function()
    task.spawn(function()
        pcall(function()
            local data=game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?limit=100"):format(game.PlaceId))
            local json=HttpService:JSONDecode(data)
            for _,sv in ipairs(json.data or {}) do
                if sv.id~=game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId,sv.id,LP) return
                end
            end
            Notify("Server Hop","No servers found",2)
        end)
    end)
    Notify("Server Hop","Searching...",2)
end)
MakeButton(MiscT.Content,"📋 Print Game Info","Print IDs to output",BG4,function()
    print("PlaceId: "..game.PlaceId)
    print("JobId: "..game.JobId)
    Notify("Game Info","IDs printed to output",2)
end)

SecLabel(MiscT.Content,"Follow")
MakeTextInput(MiscT.Content,"Copy Walk Target","Enter player name...",function(v) S.CopyTarget=v end)
MakeToggle(MiscT.Content,"Copy Walk","Follow a target player","CopyWalk")

-- ── BYPASS ──────────────────────────────────────
local BypassT = NewTab("Bypass","🛡")

SecLabel(BypassT.Content,"Protection")
MakeToggle(BypassT.Content,"Anti Kick","Block all kick attempts","AntiKick")
MakeToggle(BypassT.Content,"Anti Teleport","Block forced TPs > 200 studs","AntiTP")
MakeToggle(BypassT.Content,"Remote Filter","Block anti-cheat remotes","RemoteFilter")
MakeToggle(BypassT.Content,"Anti AFK","Never get idle-kicked","AntiAFK")

SecLabel(BypassT.Content,"Debug")
MakeButton(BypassT.Content,"📋 Dump All Remotes","Print remote events to output",BG4,function()
    print("=== REMOTE EVENTS ===")
    for _,v in ipairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then print(v:GetFullName()) end
    end
    Notify("Remotes","Printed!",2)
end)
MakeButton(BypassT.Content,"📋 Dump All Scripts","Print scripts to output",BG4,function()
    print("=== SCRIPTS ===")
    for _,v in ipairs(game:GetDescendants()) do
        if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then print(v:GetFullName()) end
    end
    Notify("Scripts","Printed!",2)
end)

-- ── PLAYERS ─────────────────────────────────────
local PlayersT = NewTab("Players","👥")

local function RefreshPlayerList()
    for _,v in ipairs(PlayersT.Content:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end

    SecLabel(PlayersT.Content,"Online Players ("..#Players:GetPlayers()..")")

    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end

        local pf=Instance.new("Frame")
        pf.BackgroundColor3=BG3 pf.BorderSizePixel=0
        pf.Size=UDim2.new(1,0,0,52) pf.Parent=PlayersT.Content
        Corner(pf,9) Stroke(pf,BDR,1)

        local pn=Instance.new("TextLabel")
        pn.BackgroundTransparency=1 pn.Font=Enum.Font.GothamBold
        pn.Position=UDim2.new(0,12,0,7) pn.Size=UDim2.new(1,-132,0,20)
        pn.Text=p.Name pn.TextColor3=WHT pn.TextSize=13
        pn.TextXAlignment=Enum.TextXAlignment.Left
        pn.TextTruncate=Enum.TextTruncate.AtEnd pn.Parent=pf

        local pid=Instance.new("TextLabel")
        pid.BackgroundTransparency=1 pid.Font=Enum.Font.Gotham
        pid.Position=UDim2.new(0,12,0,28) pid.Size=UDim2.new(1,-132,0,16)
        pid.Text="ID: "..p.UserId pid.TextColor3=GRY pid.TextSize=11
        pid.TextXAlignment=Enum.TextXAlignment.Left pid.Parent=pf

        local tpb=Instance.new("TextButton")
        tpb.BackgroundColor3=ACC tpb.BorderSizePixel=0
        tpb.Position=UDim2.new(1,-116,0.5,-13) tpb.Size=UDim2.new(0,50,0,26)
        tpb.Text="TP" tpb.TextColor3=WHT tpb.Font=Enum.Font.GothamBold tpb.TextSize=13
        tpb.Parent=pf Corner(tpb,5)

        local spb=Instance.new("TextButton")
        spb.BackgroundColor3=ACCD spb.BorderSizePixel=0
        spb.Position=UDim2.new(1,-60,0.5,-13) spb.Size=UDim2.new(0,52,0,26)
        spb.Text="Spec" spb.TextColor3=WHT spb.Font=Enum.Font.GothamBold spb.TextSize=12
        spb.Parent=pf Corner(spb,5)

        tpb.MouseButton1Click:Connect(function()
            if p.Character then
                local th=p.Character:FindFirstChild("HumanoidRootPart") local mh=GetHRP()
                if th and mh then pcall(function() mh.CFrame=th.CFrame*CFrame.new(3,0,0) end)
                    Notify("TP","→ "..p.Name,2) end
            end
        end)
        spb.MouseButton1Click:Connect(function()
            if p.Character then
                pcall(function() workspace.CurrentCamera.CameraSubject=p.Character:FindFirstChildOfClass("Humanoid") end)
                Notify("Spectate",p.Name,2)
            end
        end)
    end
    MakeButton(PlayersT.Content,"🔄 Refresh",nil,BG4,RefreshPlayerList)
end

RefreshPlayerList()
Players.PlayerAdded:Connect(function() task.wait(0.5) RefreshPlayerList() end)
Players.PlayerRemoving:Connect(function() task.wait(0.5) RefreshPlayerList() end)

-- ═══════════════════════════════════════════════
-- OPEN FIRST TAB (Player)
-- ═══════════════════════════════════════════════
AllTabs["Player"].Btn:MouseButton1Click()

-- ═══════════════════════════════════════════════
-- RIGHTSHIFT TOGGLE
-- ═══════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Win.Visible = not Win.Visible
        if Win.Visible then
            Win.Size = UDim2.new(0,0,0,0)
            Tween(Win, {Size=UDim2.new(0,700,0,520)}, 0.3)
        end
    end
end)

-- ═══════════════════════════════════════════════
-- LAUNCH
-- ═══════════════════════════════════════════════
task.wait(0.5)
Win.Visible = true
Win.Size = UDim2.new(0,0,0,0)
Tween(Win, {Size=UDim2.new(0,700,0,520)}, 0.4)

Notify("CoolGUI v8","✅ Loaded! RightShift = Open/Close",5)

print("╔══════════════════════════════╗")
print("║   CoolGUI v8 LOADED ✅       ║")
print("║   RightShift = Toggle GUI    ║")
print("║   F          = Fly On/Off    ║")
print("║   Hold E     = Aimbot        ║")
print("╚══════════════════════════════╝")
