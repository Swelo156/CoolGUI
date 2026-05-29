-- CoolGUI Universal Nuke v1
-- Made for CoolGUI Discord | you_arecool

pcall(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local Lighting = game:GetService("Lighting")
    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera

    local Settings = {
        SilentAim = true,
        AimFOV = 180,
        ESP = true,
        Fly = false,
        FlySpeed = 60,
        SpeedHack = true,
        WalkSpeed = 120,
        JumpPower = 200,
        Godmode = true,
        Fullbright = true,
    }

    print("CoolGUI Nuke Loaded - You are NOT cool.")

    -- Silent Aim (very strong version)
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)

    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        if Settings.SilentAim and (self.Name == "Shoot" or self.Name == "Hit" or self.Name:find("Fire")) then
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
                args[1] = closest.Character.Head.Position + Vector3.new(0, 0.1, 0)
            end
        end
        return old(self, unpack(args))
    end)

    -- ESP
    local function CreateESP(plr)
        if plr == LocalPlayer then return end
        local box = Drawing.new("Square")
        box.Thickness = 2
        box.Filled = false
        box.Color = Color3.fromRGB(255, 0, 0)
        box.Transparency = 1

        RunService.RenderStepped:Connect(function()
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and Settings.ESP then
                local root = plr.Character.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local size = 2500 / (Camera.CFrame.Position - root.Position).Magnitude
                    box.Size = Vector2.new(size, size * 2.5)
                    box.Position = Vector2.new(pos.X - size/2, pos.Y - size)
                    box.Visible = true
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        end)
    end

    for _, plr in ipairs(Players:GetPlayers()) do CreateESP(plr) end
    Players.PlayerAdded:Connect(CreateESP)

    -- Fly + Speed + Jump
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.F then
            Settings.Fly = not Settings.Fly
            print("Fly:", Settings.Fly)
        end
    end)

    RunService.RenderStepped:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")

            if hum then
                if Settings.SpeedHack then hum.WalkSpeed = Settings.WalkSpeed end
                if Settings.JumpPower then hum.JumpPower = Settings.JumpPower end
            end

            if Settings.Fly then
                local move = Vector3.new()
                local cam = Workspace.CurrentCamera.CFrame

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.RightVector end

                hrp.Velocity = move * Settings.FlySpeed
            end
        end
    end)

    -- Fullbright
    if Settings.Fullbright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 99999
    end

end)
