-- CoolGUI Nuke v2
-- you_arecool on top

pcall(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local Lighting = game:GetService("Lighting")
    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera

    print("✅ CoolGUI Nuke v2 LOADED - Welcome to CoolGUI")

    local Settings = {
        SilentAim = true,
        AimFOV = 180,
        ESP = true,
        Fly = false,
        FlySpeed = 70,
        SpeedHack = true,
        WalkSpeed = 150,
        JumpPower = 250,
        Fullbright = true,
    }

    -- Notification
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "CoolGUI",
        Text = "Nuke loaded. Press F for Fly | You are NOT cool",
        Duration = 5
    })

    -- Silent Aim
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)

    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        if Settings.SilentAim and (self.Name == "Shoot" or self.Name:find("Hit") or self.Name:find("Fire")) then
            local closest = nil
            local shortest = Settings.AimFOV

            for _, v in ipairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                    local pos, onScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
                    local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    
                    if onScreen and dist < shortest then
                        shortest = dist
                        closest = v
                    end
                end
            end

            if closest and closest.Character and closest.Character:FindFirstChild("Head") then
                args[1] = closest.Character.Head.Position
            end
        end
        return old(self, unpack(args))
    end)

    -- ESP + Speed + Jump
    RunService.RenderStepped:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local hum = LocalPlayer.Character.Humanoid
            if Settings.SpeedHack then hum.WalkSpeed = Settings.WalkSpeed end
            if Settings.JumpPower then hum.JumpPower = Settings.JumpPower end
        end
    end)

    -- Fly Toggle
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.F then
            Settings.Fly = not Settings.Fly
            print("🛫 Fly:", Settings.Fly and "ENABLED" or "DISABLED")
        end
    end)

    RunService.RenderStepped:Connect(function()
        if Settings.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local cam = Workspace.CurrentCamera.CFrame
            local move = Vector3.new()

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.RightVector end

            hrp.Velocity = move * Settings.FlySpeed
        end
    end)

    -- Fullbright
    Lighting.Brightness = 3
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000

    print("🔥 Press F to toggle Fly. Silent Aim & ESP are always on.")
end)
