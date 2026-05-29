--// Universal Pro v6.0 - Xeno Edition
--// Right Alt = Toggle GUI | F = Fly | Hold E = Aimbot

repeat task.wait(0.1) until game:IsLoaded()
repeat task.wait(0.1) until game.Players.LocalPlayer

local LP = game.Players.LocalPlayer
repeat task.wait(0.1) until LP:WaitForChild("PlayerGui", 10)

local PG = LP.PlayerGui

-- Kill any old versions
for _,v in ipairs(PG:GetChildren()) do
    if v.Name == "UniversalPro" or v.Name == "UniversalUltimate" or v.Name == "CoolGUI" then
        v:Destroy()
    end
end

local RS   = game:GetService("RunService")
local UIS  = game:GetService("UserInputService")
local TS   = game:GetService("TweenService")
local WS   = game:GetService("Workspace")
local LT   = game:GetService("Lighting")
local SG   = game:GetService("StarterGui")
local TPS  = game:GetService("TeleportService")
local VU   = game:GetService("VirtualUser")

-- Theme
local C = {
    BG      = Color3.fromRGB(18,18,24),
    BG2     = Color3.fromRGB(26,26,34),
    BG3     = Color3.fromRGB(34,34,45),
    BG4     = Color3.fromRGB(44,44,58),
    ACC     = Color3.fromRGB(120,80,220),
    ACCL    = Color3.fromRGB(145,105,245),
    ACCD    = Color3.fromRGB(80,50,170),
    TXT     = Color3.fromRGB(255,255,255),
    TXTG    = Color3.fromRGB(160,160,175),
    TXTD    = Color3.fromRGB(100,100,115),
    GRN     = Color3.fromRGB(80,220,140),
    RED     = Color3.fromRGB(220,80,80),
    YLW     = Color3.fromRGB(220,185,60),
    BLU     = Color3.fromRGB(80,155,220),
    BDR     = Color3.fromRGB(55,55,72),
}

-- Feature State
local F = {
    WalkSpeed     = {On=false, Val=100},
    JumpPower     = {On=false, Val=100},
    Fly           = {On=false, Speed=60},
    Noclip        = {On=false},
    InfJump       = {On=false},
    Ghost         = {On=false},
    Spin          = {On=false, Speed=8},
    Freeze        = {On=false},
    BigHead       = {On=false, Scale=5},
    AntiVoid      = {On=false},
    LowGrav       = {On=false, Val=50},
    Fullbright    = {On=false},
    NoFog         = {On=false},
    Crosshair     = {On=false},
    FPSBoost      = {On=false},
    ESP           = {On=false},
    Aimbot        = {On=false, FOV=200, Smooth=0.25},
    HitboxExp     = {On=false, Size=8},
    TriggerBot    = {On=false},
    Jerk          = {On=false},
    Fling         = {On=false},
    AntiKick      = {On=true},
    AntiTP        = {On=false},
    RemoteFilter  = {On=true},
    AntiAFK       = {On=true},
    ChatSpam      = {On=false, Msg="lol", Delay=3},
    CopyWalk      = {On=false, Target=""},
    TimeChange    = {On=false, Val=14},
}

-- Safe Getters
local function Char()   return LP.Character end
local function Hum()    local c=Char() return c and c:FindFirstChildOfClass("Humanoid") end
local function HRP()    local c=Char() return c and c:FindFirstChild("HumanoidRootPart") end
local function Head()   local c=Char() return c and c:FindFirstChild("Head") end

-- Notify
local function Notify(t,m,d)
    pcall(function()
        SG:SetCore("SendNotification",{Title=t,Text=m,Duration=d or 3})
    end)
end

-- New Instance helper
local function N(cls, props)
    local s,o = pcall(Instance.new, cls)
    if not s then return nil end
    for k,v in pairs(props or {}) do
        if k ~= "Parent" then pcall(function() o[k]=v end) end
    end
    if props and props.Parent then pcall(function() o.Parent=props.Parent end) end
    return o
end

-- Tween helper
local function Tw(o, g, t)
    if not o then return end
    pcall(function()
        TS:Create(o, TweenInfo.new(t or 0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), g):Play()
    end)
end

local function Crn(p, r)  N("UICorner",{CornerRadius=UDim.new(0,r or 8),Parent=p}) end
local function Strk(p,c,t) N("UIStroke",{Color=c or C.BDR,Thickness=t or 1,Parent=p}) end
local function LL(p,pad)   N("UIListLayout",{Padding=UDim.new(0,pad or 8),SortOrder=Enum.SortOrder.LayoutOrder,Parent=p}) end

-- ============================================================
-- ANTI-CHEAT BYPASS
-- ============================================================
pcall(function() LP.Kick = function() Notify("Bypass","Kick Blocked",2) end end)

if VU then
    pcall(function()
        LP.Idled:Connect(function()
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
        end)
    end)
end

if hookmetamethod then
    pcall(function()
        local old
        old = hookmetamethod(game,"__namecall",function(self,...)
            local m = getnamecallmethod()
            if F.AntiKick.On and (m=="Kick" or m=="kick") then
                Notify("Bypass","Kick Blocked",2)
                return
            end
            if F.RemoteFilter.On and (m=="FireServer" or m=="InvokeServer") then
                local n = string.lower(tostring(self and self.Name or ""))
                for _,b in ipairs({"anticheat","ac_","exploit","ban","kick","detect","report","flag"}) do
                    if string.find(n,b) then Notify("Bypass","Remote blocked: "..tostring(self.Name),2) return end
                end
            end
            return old(self,...)
        end)
    end)
end

-- Anti-Teleport
local lastSafePos
RS.Heartbeat:Connect(function()
    if F.AntiTP.On then
        local h = HRP()
        if h then
            if lastSafePos and (h.Position - lastSafePos).Magnitude > 200 then
                pcall(function() h.CFrame = CFrame.new(lastSafePos) end)
            end
            lastSafePos = h.Position
        end
    end
end)

-- ============================================================
-- FEATURE LOOPS
-- ============================================================

-- Speed / Jump
RS.Heartbeat:Connect(function()
    local h = Hum()
    if not h then return end
    if F.WalkSpeed.On   then pcall(function() h.WalkSpeed = F.WalkSpeed.Val end) end
    if F.JumpPower.On   then pcall(function() h.JumpPower = F.JumpPower.Val h.UseJumpPower=true end) end
    if F.LowGrav.On     then pcall(function() WS.Gravity = F.LowGrav.Val end) end
    if F.TimeChange.On  then pcall(function() LT.ClockTime = F.TimeChange.Val end) end
    if F.Fullbright.On  then pcall(function() LT.Brightness=10 LT.GlobalShadows=false LT.FogEnd=1e9 end) end
    if F.NoFog.On       then pcall(function() LT.FogEnd=1e9 end) end
    if F.AntiVoid.On then
        local h2=HRP() if h2 and h2.Position.Y < -150 then
            pcall(function() h2.CFrame=CFrame.new(h2.Position.X,10,h2.Position.Z) end)
        end
    end
    if F.ZoomOut then
        pcall(function() LP.CameraMaxZoomDistance = 200 end)
    end
end)

-- Noclip
RS.Stepped:Connect(function()
    if F.Noclip.On then
        local c=Char() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then pcall(function() p.CanCollide=false end) end
        end
    end
end)

-- Inf Jump
UIS.JumpRequest:Connect(function()
    if F.InfJump.On then
        local h=Hum() if h then pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    end
end)

-- Spin
RS.RenderStepped:Connect(function()
    if F.Spin.On then
        local h=HRP() if h then pcall(function() h.CFrame=h.CFrame*CFrame.Angles(0,math.rad(F.Spin.Speed),0) end) end
    end
end)

-- BigHead
RS.Heartbeat:Connect(function()
    if F.BigHead.On then
        local h=Head() if h then pcall(function() h.Size=Vector3.new(F.BigHead.Scale,F.BigHead.Scale,F.BigHead.Scale) end) end
    end
end)

-- Freeze
RS.Heartbeat:Connect(function()
    local h=HRP() if not h then return end
    if F.Freeze.On then pcall(function() h.Anchored=true end)
    elseif h.Anchored then pcall(function() h.Anchored=false end) end
end)

-- Ghost
RS.Heartbeat:Connect(function()
    if F.Ghost.On then
        local c=Char() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then pcall(function() p.CanCollide=false p.Transparency=0.6 end) end
        end
    end
end)

-- FPS Boost
RS.Heartbeat:Connect(function()
    if F.FPSBoost.On then
        for _,v in ipairs(WS:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                pcall(function() v.Enabled=false end)
            end
        end
    end
end)

-- Hitbox Expander
RS.Heartbeat:Connect(function()
    if F.HitboxExp.On then
        for _,p in ipairs(game.Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local h=p.Character:FindFirstChild("HumanoidRootPart")
                if h then pcall(function() h.Size=Vector3.new(F.HitboxExp.Size,F.HitboxExp.Size,F.HitboxExp.Size) end) end
            end
        end
    end
end)

-- Triggerbot
RS.Heartbeat:Connect(function()
    if not F.TriggerBot.On then return end
    local cam=WS.CurrentCamera if not cam then return end
    local ray=cam:ViewportPointToRay(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)
    local res=WS:Raycast(ray.Origin,ray.Direction*1000)
    if res and res.Instance then
        local mdl=res.Instance:FindFirstAncestorOfClass("Model")
        if mdl then
            local pl=game.Players:GetPlayerFromCharacter(mdl)
            if pl and pl~=LP then
                if mouse1press then mouse1press() task.wait(0.05) mouse1release() end
            end
        end
    end
end)

-- JERK
local jerkActive=false
RS.Heartbeat:Connect(function()
    if F.Jerk.On and not jerkActive then
        jerkActive=true
        task.spawn(function()
            while F.Jerk.On do
                local h=HRP() if h then
                    pcall(function()
                        local bv=Instance.new("BodyVelocity")
                        bv.MaxForce=Vector3.new(9e9,9e9,9e9)
                        bv.Velocity=Vector3.new(math.random(-200,200),math.random(-50,200),math.random(-200,200))
                        bv.Parent=h task.wait(0.06) bv:Destroy()
                        local ba=Instance.new("BodyAngularVelocity")
                        ba.MaxTorque=Vector3.new(9e9,9e9,9e9)
                        ba.AngularVelocity=Vector3.new(math.random(-25,25),math.random(-25,25),math.random(-25,25))
                        ba.Parent=h task.wait(0.06) ba:Destroy()
                    end)
                end
                task.wait(0.1)
            end
            jerkActive=false
        end)
    end
end)

-- FLING
local flingActive=false
RS.Heartbeat:Connect(function()
    if F.Fling.On and not flingActive then
        flingActive=true
        task.spawn(function()
            while F.Fling.On do
                local h=HRP() if h then pcall(function()
                    local bv=Instance.new("BodyVelocity")
                    bv.MaxForce=Vector3.new(9e9,9e9,9e9)
                    bv.Velocity=Vector3.new(math.random(-300,300),math.random(100,300),math.random(-300,300))
                    bv.Parent=h task.wait(0.15) bv:Destroy()
                end) end
                task.wait(0.4)
            end
            flingActive=false
        end)
    end
end)

-- Chat Spam
task.spawn(function()
    while true do
        task.wait(math.max(F.ChatSpam.Delay, 1))
        if F.ChatSpam.On then
            pcall(function()
                local tcs = game:GetService("TextChatService")
                if tcs and tcs.TextChannels then
                    local ch = tcs.TextChannels:FindFirstChild("RBXGeneral")
                    if ch then ch:SendAsync(F.ChatSpam.Msg) end
                end
            end)
        end
    end
end)

-- Copy Walk
RS.Heartbeat:Connect(function()
    if F.CopyWalk.On and F.CopyWalk.Target ~= "" then
        local t=game.Players:FindFirstChild(F.CopyWalk.Target)
        if t and t.Character then
            local th=t.Character:FindFirstChild("HumanoidRootPart")
            local mh=HRP()
            if th and mh then pcall(function() mh.CFrame=th.CFrame*CFrame.new(3,0,0) end) end
        end
    end
end)

-- ============================================================
-- FLY
-- ============================================================
local FV, FA, FC
local FK={W=false,A=false,S=false,D=false,Space=false,LeftShift=false}

local function StartFly()
    local h=HRP() if not h then return end
    FV=Instance.new("BodyVelocity") FV.MaxForce=Vector3.new(9e9,9e9,9e9) FV.Velocity=Vector3.zero FV.Parent=h
    FA=Instance.new("BodyAngularVelocity") FA.MaxTorque=Vector3.new(9e9,9e9,9e9) FA.AngularVelocity=Vector3.zero FA.Parent=h
    local hm=Hum() if hm then pcall(function() hm.PlatformStand=true end) end
    FC=RS.Heartbeat:Connect(function()
        if not F.Fly.On then return end
        local cam=WS.CurrentCamera if not cam or not FV then return end
        local m=Vector3.zero
        if FK.W then m=m+cam.CFrame.LookVector end if FK.S then m=m-cam.CFrame.LookVector end
        if FK.A then m=m-cam.CFrame.RightVector end if FK.D then m=m+cam.CFrame.RightVector end
        if FK.Space then m=m+Vector3.new(0,1,0) end if FK.LeftShift then m=m-Vector3.new(0,1,0) end
        if m.Magnitude>0 then m=m.Unit*F.Fly.Speed end
        FV.Velocity=m if FA then FA.AngularVelocity=Vector3.zero end
    end)
end

local function StopFly()
    if FC then FC:Disconnect() FC=nil end
    pcall(function() if FV then FV:Destroy() FV=nil end if FA then FA:Destroy() FA=nil end end)
    local hm=Hum() if hm then pcall(function() hm.PlatformStand=false end) end
end

-- ============================================================
-- ESP (Highlights - no CoreGui needed)
-- ============================================================
local ESPFolder=N("Folder",{Name="ESP",Parent=PG})
local Highlights={}

local function MakeESP(p)
    if p==LP then return end
    local hl=N("Highlight",{
        Name="H_"..p.Name, FillColor=Color3.fromRGB(255,50,50),
        FillTransparency=0.65, OutlineColor=Color3.fromRGB(255,50,50),
        OutlineTransparency=0, DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,
        Enabled=false, Parent=ESPFolder
    })
    Highlights[p]=hl
    local function Up() if hl then hl.Adornee=p.Character hl.Enabled=F.ESP.On end end
    p.CharacterAdded:Connect(function() task.wait(0.5) Up() end)
    Up()
end

for _,p in ipairs(game.Players:GetPlayers()) do MakeESP(p) end
game.Players.PlayerAdded:Connect(MakeESP)
game.Players.PlayerRemoving:Connect(function(p)
    if Highlights[p] then Highlights[p]:Destroy() Highlights[p]=nil end
end)

RS.Heartbeat:Connect(function()
    for p,hl in pairs(Highlights) do
        if hl and hl.Parent then hl.Enabled=F.ESP.On if p.Character then hl.Adornee=p.Character end end
    end
end)

-- ============================================================
-- AIMBOT
-- ============================================================
RS.Heartbeat:Connect(function()
    if not F.Aimbot.On then return end
    if not UIS:IsKeyDown(Enum.KeyCode.E) then return end
    local cam=WS.CurrentCamera if not cam then return end
    local mp=UIS:GetMouseLocation()
    local best,bDist=nil,F.Aimbot.FOV
    for _,p in ipairs(game.Players:GetPlayers()) do
        if p==LP then continue end
        local c=p.Character if not c then continue end
        local hd=c:FindFirstChild("Head") if not hd then continue end
        local pos,on=cam:WorldToViewportPoint(hd.Position)
        if not on then continue end
        local d=(Vector2.new(pos.X,pos.Y)-mp).Magnitude
        if d<bDist then bDist=d best=hd end
    end
    if best and mousemoverel then
        local pos=cam:WorldToViewportPoint(best.Position)
        local diff=Vector2.new(pos.X,pos.Y)-mp
        mousemoverel(diff.X*F.Aimbot.Smooth, diff.Y*F.Aimbot.Smooth)
    end
end)

-- ============================================================
-- CROSSHAIR (in PlayerGui, no CoreGui)
-- ============================================================
local CHGui=N("ScreenGui",{Name="CH",ResetOnSpawn=false,Parent=PG})
local CHL1=N("Frame",{BackgroundColor3=C.TXT,BorderSizePixel=0,Position=UDim2.new(0.5,-1,0.5,-12),Size=UDim2.new(0,2,0,24),Visible=false,Parent=CHGui})
local CHL2=N("Frame",{BackgroundColor3=C.TXT,BorderSizePixel=0,Position=UDim2.new(0.5,-12,0.5,-1),Size=UDim2.new(0,24,0,2),Visible=false,Parent=CHGui})
RS.Heartbeat:Connect(function() CHL1.Visible=F.Crosshair.On CHL2.Visible=F.Crosshair.On end)

-- ============================================================
-- INPUT
-- ============================================================
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    local k=tostring(i.KeyCode):gsub("Enum.KeyCode.","")
    if FK[k]~=nil then FK[k]=true end
    if i.KeyCode==Enum.KeyCode.F then
        F.Fly.On=not F.Fly.On
        if F.Fly.On then StartFly() else StopFly() end
        Notify("Fly",F.Fly.On and "ON" or "OFF",2)
    end
end)
UIS.InputEnded:Connect(function(i)
    local k=tostring(i.KeyCode):gsub("Enum.KeyCode.","")
    if FK[k]~=nil then FK[k]=false end
end)

-- Respawn handler
LP.CharacterAdded:Connect(function()
    task.wait(1)
    if F.Fly.On then StopFly() task.wait(0.3) StartFly() end
end)

-- ============================================================
-- GUI
-- ============================================================
local SGui=N("ScreenGui",{Name="UniversalPro",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=999,Parent=PG})

local Win=N("Frame",{Name="Win",BackgroundColor3=C.BG,BorderSizePixel=0,Position=UDim2.new(0.5,-340,0.5,-230),Size=UDim2.new(0,680,0,460),Visible=false,Parent=SGui})
Crn(Win,12) Strk(Win,C.BDR,1)

-- Shadow
N("ImageLabel",{BackgroundTransparency=1,Image="rbxassetid://5554236805",ImageColor3=Color3.new(0,0,0),ImageTransparency=0.5,Position=UDim2.new(0,-18,0,-18),Size=UDim2.new(1,36,1,36),ZIndex=0,Parent=Win})

-- Title Bar
local TB=N("Frame",{BackgroundColor3=C.BG2,BorderSizePixel=0,Size=UDim2.new(1,0,0,50),Parent=Win})
Crn(TB,12)
N("Frame",{BackgroundColor3=C.BG2,BorderSizePixel=0,Position=UDim2.new(0,0,0.5,0),Size=UDim2.new(1,0,0.5,0),Parent=TB})
N("Frame",{BackgroundColor3=C.ACC,BorderSizePixel=0,Position=UDim2.new(0,0,1,-2),Size=UDim2.new(1,0,0,2),Parent=TB})

local dot=N("Frame",{BackgroundColor3=C.ACC,BorderSizePixel=0,Position=UDim2.new(0,16,0.5,-10),Size=UDim2.new(0,20,0,20),Parent=TB}) Crn(dot,5)
N("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBlack,Position=UDim2.new(0,44,0,0),Size=UDim2.new(0,200,1,0),Text="Universal Pro",TextColor3=C.TXT,TextSize=21,TextXAlignment=Enum.TextXAlignment.Left,Parent=TB})

local vbg=N("Frame",{BackgroundColor3=C.ACCD,BorderSizePixel=0,Position=UDim2.new(0,242,0.5,-10),Size=UDim2.new(0,40,0,20),Parent=TB}) Crn(vbg,4)
N("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Size=UDim2.new(1,0,1,0),Text="v6.0",TextColor3=C.TXT,TextSize=12,Parent=vbg})

-- Keybind hint
N("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Position=UDim2.new(0,292,0,0),Size=UDim2.new(0,160,1,0),Text="RightAlt to toggle",TextColor3=C.TXTG,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=TB})

-- Close button
local CloseB=N("TextButton",{BackgroundColor3=C.RED,BorderSizePixel=0,Position=UDim2.new(1,-40,0.5,-13),Size=UDim2.new(0,26,0,26),Text="✕",TextColor3=C.TXT,Font=Enum.Font.GothamBold,TextSize=13,Parent=TB})
Crn(CloseB,6)

-- Minimize
local MinB=N("TextButton",{BackgroundColor3=C.YLW,BorderSizePixel=0,Position=UDim2.new(1,-74,0.5,-13),Size=UDim2.new(0,26,0,26),Text="—",TextColor3=C.BG,Font=Enum.Font.GothamBold,TextSize=13,Parent=TB})
Crn(MinB,6)

local minimized=false
MinB.MouseButton1Click:Connect(function()
    minimized=not minimized
    Tw(Win,{Size=minimized and UDim2.new(0,680,0,50) or UDim2.new(0,680,0,460)},0.3)
end)
CloseB.MouseButton1Click:Connect(function()
    Win.Visible=false
end)

-- Sidebar
local SB=N("Frame",{BackgroundColor3=C.BG2,BorderSizePixel=0,Position=UDim2.new(0,0,0,50),Size=UDim2.new(0,165,1,-50),Parent=Win})
Crn(SB,12)
N("Frame",{BackgroundColor3=C.BG2,BorderSizePixel=0,Position=UDim2.new(1,-12,0,0),Size=UDim2.new(0,12,1,0),Parent=SB})
N("Frame",{BackgroundColor3=C.BDR,BorderSizePixel=0,Position=UDim2.new(1,-1,0,0),Size=UDim2.new(0,1,1,0),Parent=SB})

-- Player info card
local PIC=N("Frame",{BackgroundColor3=C.BG3,BorderSizePixel=0,Position=UDim2.new(0,10,0,10),Size=UDim2.new(1,-20,0,52),Parent=SB})
Crn(PIC,8)
N("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Position=UDim2.new(0,10,0,6),Size=UDim2.new(1,-20,0,20),Text=LP.Name,TextColor3=C.TXT,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=PIC})
N("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Position=UDim2.new(0,10,0,27),Size=UDim2.new(1,-20,0,16),Text="ID: "..LP.UserId,TextColor3=C.TXTG,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=PIC})

-- Tab list
local TL=N("Frame",{BackgroundTransparency=1,Position=UDim2.new(0,10,0,72),Size=UDim2.new(1,-20,1,-82),Parent=SB})
LL(TL,5)

-- Content area
local CA=N("Frame",{BackgroundTransparency=1,Position=UDim2.new(0,165,0,50),Size=UDim2.new(1,-165,1,-50),Parent=Win})

-- TAB SYSTEM
local Tabs={} local ActiveTab=nil

local function MakeTab(name,icon)
    local btn=N("TextButton",{Name=name,BackgroundColor3=C.BG2,BorderSizePixel=0,Size=UDim2.new(1,0,0,38),Text="",Parent=TL})
    Crn(btn,7)

    N("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Position=UDim2.new(0,10,0,0),Size=UDim2.new(0,28,1,0),Text=icon,TextColor3=C.TXTG,TextSize=15,Parent=btn})
    local nl=N("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Position=UDim2.new(0,40,0,0),Size=UDim2.new(1,-50,1,0),Text=name,TextColor3=C.TXTG,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,Parent=btn})
    local ind=N("Frame",{BackgroundColor3=C.ACC,BorderSizePixel=0,Position=UDim2.new(0,0,0.2,0),Size=UDim2.new(0,3,0.6,0),Visible=false,Parent=btn})
    Crn(ind,2)

    local sc=N("ScrollingFrame",{BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(0,14,0,10),Size=UDim2.new(1,-28,1,-20),ScrollBarThickness=3,ScrollBarImageColor3=C.ACC,Visible=false,CanvasSize=UDim2.new(0,0,0,0),Parent=CA})
    local scl=LL(sc,10)
    scl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() sc.CanvasSize=UDim2.new(0,0,0,scl.AbsoluteContentSize.Y+20) end)

    Tabs[name]={B=btn,C=sc,I=ind,NL=nl}

    btn.MouseButton1Click:Connect(function()
        if ActiveTab==name then return end
        if ActiveTab and Tabs[ActiveTab] then
            Tw(Tabs[ActiveTab].B,{BackgroundColor3=C.BG2},0.15)
            Tabs[ActiveTab].NL.TextColor3=C.TXTG
            Tabs[ActiveTab].I.Visible=false
            Tabs[ActiveTab].C.Visible=false
        end
        ActiveTab=name
        Tw(btn,{BackgroundColor3=C.BG3},0.15)
        nl.TextColor3=C.ACCL ind.Visible=true sc.Visible=true
    end)
    return Tabs[name]
end

-- COMPONENT BUILDERS

local function Sec(p,t)
    local f=N("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,22),Parent=p})
    N("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Size=UDim2.new(1,0,1,0),Text="  "..t:upper(),TextColor3=C.ACC,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
    N("Frame",{BackgroundColor3=C.BDR,BorderSizePixel=0,Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1),Parent=f})
end

local function Toggle(p,name,desc,feat,sub,cb)
    local h = desc and 58 or 48
    local fr=N("Frame",{BackgroundColor3=C.BG3,BorderSizePixel=0,Size=UDim2.new(1,0,0,h),Parent=p})
    Crn(fr,8) Strk(fr,C.BDR,1)

    N("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Position=UDim2.new(0,13,0,desc and 8 or 0),Size=UDim2.new(1,-68,0,22),Text=name,TextColor3=C.TXT,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,Parent=fr})
    if desc then N("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Position=UDim2.new(0,13,0,30),Size=UDim2.new(1,-68,0,18),Text=desc,TextColor3=C.TXTG,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=fr}) end

    local sbg=N("Frame",{BackgroundColor3=C.BG,BorderSizePixel=0,Position=UDim2.new(1,-52,0.5,-12),Size=UDim2.new(0,42,0,24),Parent=fr})
    Crn(sbg,12) Strk(sbg,C.BDR,1)
    local knb=N("Frame",{BackgroundColor3=C.TXTG,BorderSizePixel=0,Position=UDim2.new(0,3,0.5,-9),Size=UDim2.new(0,18,0,18),Parent=sbg})
    Crn(knb,9)

    local state=false
    if feat and F[feat] then state=sub and F[feat][sub] or F[feat].On end

    local function Set(s)
        state=s
        if feat and F[feat] then if sub then F[feat][sub]=s else F[feat].On=s end end
        Tw(knb,{Position=s and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),BackgroundColor3=s and C.GRN or C.TXTG},0.18)
        Tw(sbg,{BackgroundColor3=s and C.ACCD or C.BG},0.18)
        if cb then cb(s) end
    end

    if state then Set(true) end

    local cl=N("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text="",Parent=fr})
    cl.MouseButton1Click:Connect(function() Set(not state) end)
    cl.MouseEnter:Connect(function() Tw(fr,{BackgroundColor3=C.BG4},0.1) end)
    cl.MouseLeave:Connect(function() Tw(fr,{BackgroundColor3=C.BG3},0.1) end)
    return fr
end

local function Slider(p,name,mn,mx,def,feat,vk,cb)
    local fr=N("Frame",{BackgroundColor3=C.BG3,BorderSizePixel=0,Size=UDim2.new(1,0,0,76),Parent=p})
    Crn(fr,8) Strk(fr,C.BDR,1)
    local vl=N("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Position=UDim2.new(1,-52,0,9),Size=UDim2.new(0,42,0,20),Text=tostring(def),TextColor3=C.ACCL,TextSize=14,Parent=fr})
    N("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Position=UDim2.new(0,13,0,9),Size=UDim2.new(1,-78,0,20),Text=name,TextColor3=C.TXT,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,Parent=fr})
    local tr=N("Frame",{BackgroundColor3=C.BG,BorderSizePixel=0,Position=UDim2.new(0,13,0,42),Size=UDim2.new(1,-26,0,6),Parent=fr}) Crn(tr,3) Strk(tr,C.BDR,1)
    local fi=N("Frame",{BackgroundColor3=C.ACC,BorderSizePixel=0,Size=UDim2.new((def-mn)/(mx-mn),0,1,0),Parent=tr}) Crn(fi,3)
    local kn=N("Frame",{BackgroundColor3=C.TXT,BorderSizePixel=0,Position=UDim2.new((def-mn)/(mx-mn),-7,0.5,-7),Size=UDim2.new(0,14,0,14),Parent=tr}) Crn(kn,7) Strk(kn,C.ACC,2)
    N("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Position=UDim2.new(0,13,0,54),Size=UDim2.new(0,40,0,14),Text=tostring(mn),TextColor3=C.TXTD,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,Parent=fr})
    N("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Position=UDim2.new(1,-52,0,54),Size=UDim2.new(0,40,0,14),Text=tostring(mx),TextColor3=C.TXTD,TextSize=10,TextXAlignment=Enum.TextXAlignment.Right,Parent=fr})
    local drag=false
    local function Upd(x)
        local pos=math.clamp((x-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
        local val=math.floor(mn+(mx-mn)*pos)
        fi.Size=UDim2.new(pos,0,1,0) kn.Position=UDim2.new(pos,-7,0.5,-7) vl.Text=tostring(val)
        if feat and F[feat] and vk then F[feat][vk]=val end
        if cb then cb(val) end
    end
    kn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true end end)
    tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true Upd(i.Position.X) end end)
    UIS.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then Upd(i.Position.X) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
end

local function Btn(p,name,desc,col,cb)
    local h=desc and 56 or 42
    local b=N("TextButton",{BackgroundColor3=col or C.ACC,BorderSizePixel=0,Size=UDim2.new(1,0,0,h),Text="",Parent=p})
    Crn(b,8)
    N("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Position=UDim2.new(0,13,0,desc and 8 or 0),Size=UDim2.new(1,-26,0,26),Text=name,TextColor3=C.TXT,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,Parent=b})
    if desc then N("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Position=UDim2.new(0,13,0,31),Size=UDim2.new(1,-26,0,18),Text=desc,TextColor3=Color3.fromRGB(220,220,220),TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=b}) end
    local og=col or C.ACC
    b.MouseEnter:Connect(function() Tw(b,{BackgroundColor3=C.ACCL},0.1) end)
    b.MouseLeave:Connect(function() Tw(b,{BackgroundColor3=og},0.1) end)
    b.MouseButton1Click:Connect(function()
        Tw(b,{BackgroundColor3=C.ACCD},0.08)
        task.delay(0.12,function() Tw(b,{BackgroundColor3=og},0.1) end)
        if cb then cb() end
    end)
end

local function TextIn(p,name,ph,cb)
    local fr=N("Frame",{BackgroundColor3=C.BG3,BorderSizePixel=0,Size=UDim2.new(1,0,0,68),Parent=p})
    Crn(fr,8) Strk(fr,C.BDR,1)
    N("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Position=UDim2.new(0,13,0,9),Size=UDim2.new(1,-26,0,20),Text=name,TextColor3=C.TXT,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,Parent=fr})
    local box=N("TextBox",{BackgroundColor3=C.BG,BorderSizePixel=0,ClearTextOnFocus=false,Font=Enum.Font.Gotham,PlaceholderColor3=C.TXTD,PlaceholderText=ph or "...",Position=UDim2.new(0,13,0,35),Size=UDim2.new(1,-26,0,24),Text="",TextColor3=C.TXT,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=fr})
    Crn(box,4) Strk(box,C.BDR,1)
    N("UIPadding",{PaddingLeft=UDim.new(0,7),Parent=box})
    box.FocusLost:Connect(function() if cb then cb(box.Text) end end)
    return fr,box
end

-- ============================================================
-- POPULATE TABS
-- ============================================================

-- PLAYER
local PT=MakeTab("Player","👤")
Sec(PT.C,"Movement")
Toggle(PT.C,"WalkSpeed","Override walk speed","WalkSpeed",nil,function(s) Notify("WalkSpeed",s and "ON" or "OFF",2) end)
Slider(PT.C,"Speed",16,500,100,"WalkSpeed","Val")
Toggle(PT.C,"JumpPower","Override jump height","JumpPower",nil,function(s) Notify("JumpPower",s and "ON" or "OFF",2) end)
Slider(PT.C,"Jump",50,500,100,"JumpPower","Val")
Toggle(PT.C,"Infinite Jump","Jump again mid-air","InfJump",nil)
Toggle(PT.C,"Fly  [Press F]","WASD+Space+Shift to fly",nil,nil,function() Notify("Fly","Press F to toggle",3) end)
Slider(PT.C,"Fly Speed",10,250,60,"Fly","Speed")
Toggle(PT.C,"Noclip","Walk through everything","Noclip",nil)
Sec(PT.C,"Character")
Toggle(PT.C,"Ghost","Transparent + no collision","Ghost",nil,function(s)
    if not s then local c=Char() if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then pcall(function() p.Transparency=0 end) end end end end
end)
Toggle(PT.C,"Spin","Rotate continuously","Spin",nil)
Slider(PT.C,"Spin Speed",1,50,8,"Spin","Speed")
Toggle(PT.C,"Big Head","Giant head","BigHead",nil)
Slider(PT.C,"Head Scale",2,25,5,"BigHead","Scale")
Toggle(PT.C,"Freeze","Anchor in place","Freeze",nil)
Toggle(PT.C,"Anti Void","Catch void falls","AntiVoid",nil)
Sec(PT.C,"Physics")
Toggle(PT.C,"Low Gravity","Reduced gravity","LowGrav",nil,function(s) if not s then pcall(function() WS.Gravity=196.2 end) end end)
Slider(PT.C,"Gravity",1,196,50,"LowGrav","Val")

-- VISUAL
local VT=MakeTab("Visual","👁")
Sec(VT.C,"ESP")
Toggle(VT.C,"ESP Highlights","See players through walls","ESP",nil,function(s)
    for _,hl in pairs(Highlights) do pcall(function() hl.Enabled=s end) end
    Notify("ESP",s and "ON" or "OFF",2)
end)
Sec(VT.C,"World")
Toggle(VT.C,"Fullbright","Remove all darkness","Fullbright",nil,function(s)
    if not s then pcall(function() LT.Brightness=1 LT.GlobalShadows=true end) end
end)
Toggle(VT.C,"No Fog","Remove fog","NoFog",nil,function(s)
    if not s then pcall(function() LT.FogEnd=1000 end) end
end)
Toggle(VT.C,"FPS Boost","Disable effects","FPSBoost",nil)
Toggle(VT.C,"Crosshair","Custom crosshair","Crosshair",nil)
Sec(VT.C,"Time")
Toggle(VT.C,"Custom Time","Set time of day","TimeChange",nil)
Slider(VT.C,"Time (Hour)",0,24,14,"TimeChange","Val")

-- COMBAT
local COT=MakeTab("Combat","⚔")
Sec(COT.C,"Aimbot")
Toggle(COT.C,"Aimbot  [Hold E]","Snaps to nearest player","Aimbot",nil,function(s) Notify("Aimbot",s and "Hold E to aim" or "OFF",2) end)
Slider(COT.C,"FOV",30,600,200,"Aimbot","FOV")
Slider(COT.C,"Smooth (x10)",1,10,3,nil,nil,function(v) F.Aimbot.Smooth=v/10 end)
Sec(COT.C,"Other")
Toggle(COT.C,"Hitbox Expander","Bigger hitboxes","HitboxExp",nil)
Slider(COT.C,"Hitbox Size",4,30,8,"HitboxExp","Size")
Toggle(COT.C,"TriggerBot","Auto shoot on target","TriggerBot",nil)

-- FUN
local FT=MakeTab("Fun","🎮")
Sec(FT.C,"Chaos")
Toggle(FT.C,"JERK 💀","Violently spasm everywhere","Jerk",nil,function(s) Notify("Jerk",s and "ACTIVATED 💀" or "off",2) end)
Toggle(FT.C,"Fling","Launch in random directions","Fling",nil)
Sec(FT.C,"Instant")
Btn(FT.C,"🚀 Nuke Launch","Blast yourself into the sky",C.BLU,function()
    local h=HRP() if not h then return end
    pcall(function()
        local bv=Instance.new("BodyVelocity")
        bv.MaxForce=Vector3.new(0,9e9,0)
        bv.Velocity=Vector3.new(0,500,0)
        bv.Parent=h task.delay(0.4,function() pcall(function() bv:Destroy() end) end)
    end)
end)
Btn(FT.C,"🎯 TP To Random Player","Teleport to someone",C.ACC,function()
    local pl={}
    for _,p in ipairs(game.Players:GetPlayers()) do if p~=LP then table.insert(pl,p) end end
    if #pl==0 then Notify("TP","No others",2) return end
    local t=pl[math.random(1,#pl)]
    if t.Character then
        local th=t.Character:FindFirstChild("HumanoidRootPart")
        local mh=HRP()
        if th and mh then pcall(function() mh.CFrame=th.CFrame*CFrame.new(3,0,0) end)
        Notify("TP","→ "..t.Name,2) end
    end
end)
Btn(FT.C,"💥 Explode Here","Spawn explosion",C.RED,function()
    local h=HRP() if not h then return end
    pcall(function()
        local e=Instance.new("Explosion") e.Position=h.Position
        e.BlastRadius=20 e.BlastPressure=4e5 e.DestroyJointRadiusPercent=0 e.Parent=WS
    end)
end)
Btn(FT.C,"⚡ 2 Second Speed Burst","500 speed for 2s",C.GRN,function()
    F.WalkSpeed.Val=500 F.WalkSpeed.On=true
    task.delay(2,function() F.WalkSpeed.Val=16 F.WalkSpeed.On=false end)
    Notify("Speed Burst","2 seconds!",2)
end)
Btn(FT.C,"📡 Fake Disconnect Screen","Troll fake DC",C.YLW,function()
    local g=N("ScreenGui",{Name="FDC",ResetOnSpawn=false,DisplayOrder=9999,Parent=PG})
    N("TextLabel",{BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.2,Size=UDim2.new(1,0,1,0),Text="Roblox\n\nAttempting to reconnect...",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=30,Parent=g})
    task.delay(4,function() pcall(function() g:Destroy() end) end)
end)
Btn(FT.C,"🌀 Spin Fling","Spin + fling at same time",C.ACCD,function()
    F.Spin.On=true F.Fling.On=true
    Notify("Spin Fling","ACTIVE",2)
    task.delay(3,function() F.Spin.On=false F.Fling.On=false end)
end)

-- MISC
local MT=MakeTab("Misc","⚙")
Sec(MT.C,"Chat")
Toggle(MT.C,"Chat Spammer","Send msg repeatedly","ChatSpam",nil)
local _,msgBox=TextIn(MT.C,"Spam Message","Type here...",function(v) F.ChatSpam.Msg=v end)
Slider(MT.C,"Spam Delay (s)",1,30,3,"ChatSpam","Delay")
Sec(MT.C,"Server")
Btn(MT.C,"🔄 Rejoin","Reconnect to this server",C.ACC,function()
    pcall(function() TPS:Teleport(game.PlaceId,LP) end)
end)
Btn(MT.C,"🌐 Server Hop","Find a new server",C.BLU,function()
    task.spawn(function()
        pcall(function()
            local data=game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?limit=100"):format(game.PlaceId))
            local json=game:GetService("HttpService"):JSONDecode(data)
            for _,s in ipairs(json.data or {}) do
                if s.id~=game.JobId and (s.playing or 0)<(s.maxPlayers or 1) then
                    TPS:TeleportToPlaceInstance(game.PlaceId,s.id,LP)
                    return
                end
            end
            Notify("Server Hop","No servers found",2)
        end)
    end)
    Notify("Server Hop","Searching...",2)
end)
Sec(MT.C,"Follow")
TextIn(MT.C,"Copy Walk Target","Player name...",function(v) F.CopyWalk.Target=v end)
Toggle(MT.C,"Copy Walk","Follow target player","CopyWalk",nil)

-- BYPASS
local BT=MakeTab("Bypass","🛡")
Sec(BT.C,"Protection")
Toggle(BT.C,"Anti Kick","Block all kicks","AntiKick",nil,function(s) Notify("AntiKick",s and "ON" or "OFF",2) end)
Toggle(BT.C,"Anti Teleport","Block forced TP > 200 studs","AntiTP",nil)
Toggle(BT.C,"Remote Filter","Block AC remotes","RemoteFilter",nil)
Toggle(BT.C,"Anti AFK","Never get idle kicked","AntiAFK",nil)
Sec(BT.C,"Debug")
Btn(BT.C,"📋 Print All Remotes","List remotes in output",C.BG3,function()
    print("=== REMOTES ===")
    for _,v in ipairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then print(v:GetFullName()) end
    end
    Notify("Remotes","Printed!",2)
end)
Btn(BT.C,"📋 Print All Scripts","List scripts in output",C.BG3,function()
    print("=== SCRIPTS ===")
    for _,v in ipairs(game:GetDescendants()) do
        if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then print(v:GetFullName()) end
    end
    Notify("Scripts","Printed!",2)
end)
Btn(BT.C,"🎮 Print Game ID","Get current game ID",C.BG3,function()
    print("PlaceId: "..game.PlaceId)
    print("JobId: "..game.JobId)
    Notify("Game","PlaceId: "..game.PlaceId,4)
end)

-- PLAYERS
local PLT=MakeTab("Players","👥")

local function RefreshPlayers()
    for _,v in ipairs(PLT.C:GetChildren()) do
        if not v:IsA("UIListLayout") and v.Name~="RefreshBtn" then v:Destroy() end
    end
    Sec(PLT.C,"Online Players ("..#game.Players:GetPlayers()..")")
    for _,p in ipairs(game.Players:GetPlayers()) do
        if p==LP then continue end
        local pf=N("Frame",{Name="PLR_"..p.Name,BackgroundColor3=C.BG3,BorderSizePixel=0,Size=UDim2.new(1,0,0,52),Parent=PLT.C})
        Crn(pf,8) Strk(pf,C.BDR,1)
        N("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Position=UDim2.new(0,12,0,7),Size=UDim2.new(1,-130,0,20),Text=p.Name,TextColor3=C.TXT,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=pf})
        N("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Position=UDim2.new(0,12,0,27),Size=UDim2.new(1,-130,0,16),Text="ID: "..p.UserId,TextColor3=C.TXTG,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=pf})
        local tb=N("TextButton",{BackgroundColor3=C.ACC,BorderSizePixel=0,Position=UDim2.new(1,-112,0.5,-14),Size=UDim2.new(0,50,0,28),Text="TP",TextColor3=C.TXT,Font=Enum.Font.GothamBold,TextSize=13,Parent=pf}) Crn(tb,5)
        local sb=N("TextButton",{BackgroundColor3=C.BLU,BorderSizePixel=0,Position=UDim2.new(1,-56,0.5,-14),Size=UDim2.new(0,48,0,28),Text="Spec",TextColor3=C.TXT,Font=Enum.Font.GothamBold,TextSize=12,Parent=pf}) Crn(sb,5)
        tb.MouseButton1Click:Connect(function()
            if p.Character then
                local th=p.Character:FindFirstChild("HumanoidRootPart") local mh=HRP()
                if th and mh then pcall(function() mh.CFrame=th.CFrame*CFrame.new(3,0,0) end) Notify("TP","→ "..p.Name,2) end
            end
        end)
        sb.MouseButton1Click:Connect(function()
            if p.Character then
                pcall(function() WS.CurrentCamera.CameraSubject=p.Character:FindFirstChildOfClass("Humanoid") end)
                Notify("Spectate",p.Name,2)
            end
        end)
    end
end

RefreshPlayers()
game.Players.PlayerAdded:Connect(function() task.wait(0.5) RefreshPlayers() end)
game.Players.PlayerRemoving:Connect(function() task.wait(0.5) RefreshPlayers() end)
Btn(PLT.C,"🔄 Refresh",nil,C.BG3,RefreshPlayers)

-- ============================================================
-- DRAG
-- ============================================================
local drag,ds,ws=false,nil,nil
TB.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true ds=i.Position ws=Win.Position end
end)
UIS.InputChanged:Connect(function(i)
    if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-ds
        Win.Position=UDim2.new(ws.X.Scale,ws.X.Offset+d.X,ws.Y.Scale,ws.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
end)

-- ============================================================
-- RIGHT ALT TOGGLE
-- ============================================================
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.RightAlt then
        Win.Visible=not Win.Visible
        if Win.Visible then
            Win.Size=UDim2.new(0,0,0,0)
            Tw(Win,{Size=UDim2.new(0,680,0,460)},0.35)
        end
    end
end)

-- ============================================================
-- ACTIVATE FIRST TAB + OPEN
-- ============================================================
Tabs["Player"].B:MouseButton1Click()

task.wait(0.8)
Win.Visible=true
Win.Size=UDim2.new(0,0,0,0)
Tw(Win,{Size=UDim2.new(0,680,0,460)},0.4)

Notify("Universal Pro v6.0","✅ Loaded! Right Alt = Open/Close",5)
print("✅ Universal Pro v6.0 - LOADED")
print("   Right Alt = Toggle GUI")
print("   F = Fly toggle")
print("   Hold E = Aimbot")
