--[[
===========================================
  BATTLE ROYALE ADMIN SCRIPTS
  by Claude
===========================================

  HOW TO USE:
  1. Copy the SERVER SCRIPT section into a Script in ServerScriptService
  2. Copy the LOCAL SCRIPT section into a LocalScript in StarterPlayerScripts
  3. Add your Roblox username to the ADMINS table in the server script
  4. Put any weapons (e.g. ClassicSword) inside ServerStorage

===========================================
]]

-- ============================================================
--[ SERVER SCRIPT ]
-- Place this in: ServerScriptService > Script
-- STOP COPYING HERE when you reach --[ LOCAL SCRIPT ]
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Remotes = Instance.new("Folder")
Remotes.Name = "BRRemotes"
Remotes.Parent = ReplicatedStorage

local function makeRemote(name, isFunction)
	local r = isFunction and Instance.new("RemoteFunction") or Instance.new("RemoteEvent")
	r.Name = name
	r.Parent = Remotes
	return r
end

local KillPlayer    = makeRemote("KillPlayer")
local FlingPlayer   = makeRemote("FlingPlayer")
local TeleportToMe  = makeRemote("TeleportToMe")
local GiveWeapon    = makeRemote("GiveWeapon")
local RespawnAll    = makeRemote("RespawnAll")
local GetPlayerData = makeRemote("GetPlayerData", true)
local SetGodMode    = makeRemote("SetGodMode")
local StartRound    = makeRemote("StartRound")
local EndRound      = makeRemote("EndRound")

-- !! ADD YOUR ROBLOX USERNAME HERE !!
local ADMINS = { "YourUsernameHere" }

local godModePlayers = {}
local stormActive = false
local stormRadius = 500
local stormCenter = Vector3.new(0, 0, 0)
local stormShrinkRate = 0.5

local function isAdmin(player)
	for _, name in ipairs(ADMINS) do
		if player.Name == name then return true end
	end
	return false
end

KillPlayer.OnServerEvent:Connect(function(sender, target)
	if not isAdmin(sender) then return end
	if target and target.Character then
		local hum = target.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.Health = 0 end
	end
end)

FlingPlayer.OnServerEvent:Connect(function(sender, target)
	if not isAdmin(sender) then return end
	if target and target.Character then
		local root = target.Character:FindFirstChild("HumanoidRootPart")
		if root then
			local bv = Instance.new("BodyVelocity")
			bv.Velocity = Vector3.new(
				math.random(-80, 80),
				math.random(60, 120),
				math.random(-80, 80)
			)
			bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
			bv.Parent = root
			game:GetService("Debris"):AddItem(bv, 0.3)
		end
	end
end)

TeleportToMe.OnServerEvent:Connect(function(sender, target)
	if not isAdmin(sender) then return end
	if sender.Character and target and target.Character then
		local sRoot = sender.Character:FindFirstChild("HumanoidRootPart")
		local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
		if sRoot and tRoot then
			tRoot.CFrame = sRoot.CFrame * CFrame.new(4, 0, 0)
		end
	end
end)

GiveWeapon.OnServerEvent:Connect(function(sender, target, weaponName)
	if not isAdmin(sender) then return end
	local weapon = game:GetService("ServerStorage"):FindFirstChild(weaponName, true)
	if weapon and target then
		weapon:Clone().Parent = target.Backpack
	end
end)

RespawnAll.OnServerEvent:Connect(function(sender)
	if not isAdmin(sender) then return end
	for _, p in ipairs(Players:GetPlayers()) do
		p:LoadCharacter()
	end
end)

SetGodMode.OnServerEvent:Connect(function(sender, target, enabled)
	if not isAdmin(sender) then return end
	godModePlayers[target.UserId] = enabled
	if target.Character then
		local hum = target.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.MaxHealth = enabled and math.huge or 100
			hum.Health = hum.MaxHealth
		end
	end
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid")
		if godModePlayers[player.UserId] then
			hum.MaxHealth = math.huge
			hum.Health = math.huge
		end
		hum.HealthChanged:Connect(function(health)
			if godModePlayers[player.UserId] and health <= 0 then
				hum.Health = math.huge
			end
		end)
	end)
end)

GetPlayerData.OnServerInvoke = function(sender)
	if not isAdmin(sender) then return {} end
	local data = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= sender and p.Character then
			local root = p.Character:FindFirstChild("HumanoidRootPart")
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if root and hum then
				table.insert(data, {
					name = p.Name,
					position = root.Position,
					health = math.floor(hum.Health),
					maxHealth = math.floor(hum.MaxHealth),
					alive = hum.Health > 0
				})
			end
		end
	end
	return data
end

StartRound.OnServerEvent:Connect(function(sender)
	if not isAdmin(sender) then return end
	stormActive = true
	stormRadius = 500
	print("[BR] Round started")
end)

EndRound.OnServerEvent:Connect(function(sender)
	if not isAdmin(sender) then return end
	stormActive = false
	print("[BR] Round ended")
end)

RunService.Heartbeat:Connect(function(dt)
	if not stormActive then return end
	stormRadius = math.max(30, stormRadius - stormShrinkRate * dt)
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then
			local root = p.Character:FindFirstChild("HumanoidRootPart")
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if root and hum and hum.Health > 0 then
				local dist = (root.Position - stormCenter).Magnitude
				if dist > stormRadius and not godModePlayers[p.UserId] then
					hum.Health = hum.Health - 5 * dt
				end
			end
		end
	end
end)

print("[BR Server] Loaded OK")

-- ============================================================
--[ END OF SERVER SCRIPT ]
-- ============================================================




-- ============================================================
--[ LOCAL SCRIPT ]
-- Place this in: StarterPlayerScripts > LocalScript
-- STOP COPYING at --[ END OF LOCAL SCRIPT ]
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Remotes = ReplicatedStorage:WaitForChild("BRRemotes", 10)
if not Remotes then warn("[BR] Remotes not found") return end

local KillPlayer    = Remotes:WaitForChild("KillPlayer")
local FlingPlayer   = Remotes:WaitForChild("FlingPlayer")
local TeleportToMe  = Remotes:WaitForChild("TeleportToMe")
local GiveWeapon    = Remotes:WaitForChild("GiveWeapon")
local RespawnAll    = Remotes:WaitForChild("RespawnAll")
local GetPlayerData = Remotes:WaitForChild("GetPlayerData")
local SetGodMode    = Remotes:WaitForChild("SetGodMode")
local StartRound    = Remotes:WaitForChild("StartRound")
local EndRound      = Remotes:WaitForChild("EndRound")

local espEnabled    = true
local godEnabled    = false
local espHighlights = {}
local selectedPlayer = nil
local panelOpen     = false

-- ============================================================
-- GUI SETUP
-- ============================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BRAdminGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

-- Toggle button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 115, 0, 32)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
toggleBtn.TextColor3 = Color3.fromRGB(180, 180, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
toggleBtn.Text = "[ BR Admin ]"
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = screenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

-- Main panel
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 275, 0, 530)
panel.Position = UDim2.new(0, 10, 0, 50)
panel.BackgroundColor3 = Color3.fromRGB(12, 12, 24)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = screenGui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 8)

-- Stroke around panel
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(60, 60, 120)
stroke.Thickness = 1
stroke.Parent = panel

-- Scrolling container
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.Parent = scroll

local pad = Instance.new("UIPadding")
pad.PaddingTop    = UDim.new(0, 8)
pad.PaddingLeft   = UDim.new(0, 8)
pad.PaddingRight  = UDim.new(0, 8)
pad.PaddingBottom = UDim.new(0, 8)
pad.Parent = scroll

-- ============================================================
-- GUI HELPERS
-- ============================================================

local function makeLabel(txt)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 18)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.fromRGB(100, 100, 180)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 11
	lbl.Text = txt:upper()
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = scroll
end

local function makeButton(txt, bgColor, cb)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.BackgroundColor3 = bgColor or Color3.fromRGB(35, 35, 65)
	btn.TextColor3 = Color3.fromRGB(220, 220, 255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 13
	btn.Text = txt
	btn.BorderSizePixel = 0
	btn.Parent = scroll
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
	btn.MouseButton1Click:Connect(cb)
	return btn
end

local function makeToggle(txt, init, cb)
	local state = init
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 13
	btn.BorderSizePixel = 0
	btn.Parent = scroll
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
	local function refresh()
		btn.BackgroundColor3 = state
			and Color3.fromRGB(25, 75, 35)
			or  Color3.fromRGB(65, 25, 25)
		btn.TextColor3 = Color3.fromRGB(210, 255, 210)
		btn.Text = txt .. (state and "   ON" or "   OFF")
	end
	refresh()
	btn.MouseButton1Click:Connect(function()
		state = not state
		refresh()
		cb(state)
	end)
	return btn
end

local function makeDivider()
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, 1)
	f.BackgroundColor3 = Color3.fromRGB(50, 50, 90)
	f.BorderSizePixel = 0
	f.Parent = scroll
end

-- ============================================================
-- PLAYER DROPDOWN
-- ============================================================

makeLabel("Target player")

local dropBtn = Instance.new("TextButton")
dropBtn.Size = UDim2.new(1, 0, 0, 30)
dropBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 52)
dropBtn.TextColor3 = Color3.fromRGB(180, 180, 255)
dropBtn.Font = Enum.Font.Gotham
dropBtn.TextSize = 13
dropBtn.Text = "-- select player --"
dropBtn.BorderSizePixel = 0
dropBtn.Parent = scroll
Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 5)

local dropList = Instance.new("Frame")
dropList.Size = UDim2.new(1, 0, 0, 0)
dropList.BackgroundColor3 = Color3.fromRGB(22, 22, 42)
dropList.BorderSizePixel = 0
dropList.ClipsDescendants = true
dropList.Parent = scroll
Instance.new("UICorner", dropList).CornerRadius = UDim.new(0, 5)
local dropLayout = Instance.new("UIListLayout")
dropLayout.Parent = dropList

local dropOpen = false
dropBtn.MouseButton1Click:Connect(function()
	dropOpen = not dropOpen
	for _, c in ipairs(dropList:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	if dropOpen then
		local count = 0
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then
				count = count + 1
				local e = Instance.new("TextButton")
				e.Size = UDim2.new(1, 0, 0, 26)
				e.BackgroundTransparency = 1
				e.TextColor3 = Color3.fromRGB(190, 190, 255)
				e.Font = Enum.Font.Gotham
				e.TextSize = 12
				e.Text = "  " .. p.Name
				e.TextXAlignment = Enum.TextXAlignment.Left
				e.Parent = dropList
				e.MouseButton1Click:Connect(function()
					selectedPlayer = p
					dropBtn.Text = p.Name
					dropOpen = false
					dropList.Size = UDim2.new(1, 0, 0, 0)
				end)
			end
		end
		dropList.Size = UDim2.new(1, 0, 0, math.min(count * 26, 120))
	else
		dropList.Size = UDim2.new(1, 0, 0, 0)
	end
end)

-- Keep dropdown updated when players join/leave
Players.PlayerAdded:Connect(function()
	dropBtn.Text = "-- select player --"
	selectedPlayer = nil
end)
Players.PlayerRemoving:Connect(function(p)
	if selectedPlayer == p then
		selectedPlayer = nil
		dropBtn.Text = "-- select player --"
	end
end)

-- ============================================================
-- GAME CONTROLS
-- ============================================================

makeDivider()
makeLabel("Game controls")
makeButton("Start round", Color3.fromRGB(18, 65, 28), function()
	StartRound:FireServer()
end)
makeButton("End round", Color3.fromRGB(75, 18, 18), function()
	EndRound:FireServer()
end)
makeButton("Respawn all players", Color3.fromRGB(35, 35, 75), function()
	RespawnAll:FireServer()
end)

-- ============================================================
-- PLAYER ACTIONS
-- ============================================================

makeDivider()
makeLabel("Player actions")
makeButton("Kill selected", Color3.fromRGB(100, 18, 18), function()
	if selectedPlayer then
		KillPlayer:FireServer(selectedPlayer)
	end
end)
makeButton("Fling selected", Color3.fromRGB(85, 50, 10), function()
	if selectedPlayer then
		FlingPlayer:FireServer(selectedPlayer)
	end
end)
makeButton("Teleport selected to me", Color3.fromRGB(25, 50, 85), function()
	if selectedPlayer then
		TeleportToMe:FireServer(selectedPlayer)
	end
end)
makeButton("Give ClassicSword to selected", Color3.fromRGB(50, 28, 75), function()
	if selectedPlayer then
		GiveWeapon:FireServer(selectedPlayer, "ClassicSword")
	end
end)
makeButton("Give Rocket Launcher to selected", Color3.fromRGB(50, 28, 75), function()
	if selectedPlayer then
		GiveWeapon:FireServer(selectedPlayer, "RocketLauncher")
	end
end)

-- ============================================================
-- TOGGLES
-- ============================================================

makeDivider()
makeLabel("Toggles")
makeToggle("ESP  (enemy highlight)", true, function(state)
	espEnabled = state
	if not state then
		for _, h in pairs(espHighlights) do h:Destroy() end
		espHighlights = {}
	end
end)
makeToggle("God mode  (self)", false, function(state)
	godEnabled = state
	SetGodMode:FireServer(LocalPlayer, state)
end)

-- ============================================================
-- ESP LIST PANEL
-- ============================================================

makeDivider()
makeLabel("ESP — live players")

local espOuter = Instance.new("Frame")
espOuter.Size = UDim2.new(1, 0, 0, 110)
espOuter.BackgroundColor3 = Color3.fromRGB(18, 18, 36)
espOuter.BorderSizePixel = 0
espOuter.Parent = scroll
Instance.new("UICorner", espOuter).CornerRadius = UDim.new(0, 5)

local espScroll = Instance.new("ScrollingFrame")
espScroll.Size = UDim2.new(1, 0, 1, 0)
espScroll.BackgroundTransparency = 1
espScroll.BorderSizePixel = 0
espScroll.ScrollBarThickness = 3
espScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
espScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
espScroll.Parent = espOuter

local espListLayout = Instance.new("UIListLayout")
espListLayout.Padding = UDim.new(0, 2)
espListLayout.Parent = espScroll

local espPad = Instance.new("UIPadding")
espPad.PaddingLeft   = UDim.new(0, 6)
espPad.PaddingTop    = UDim.new(0, 4)
espPad.PaddingRight  = UDim.new(0, 6)
espPad.Parent = espScroll

-- ============================================================
-- ESP FUNCTIONS
-- ============================================================

local function hpColor(hp, max)
	local pct = hp / math.max(max, 1)
	if pct > 0.6 then return Color3.fromRGB(80, 210, 80)
	elseif pct > 0.3 then return Color3.fromRGB(220, 185, 30)
	else return Color3.fromRGB(225, 55, 55) end
end

local function getHighlight(player)
	if espHighlights[player.UserId] then
		return espHighlights[player.UserId]
	end
	local h = Instance.new("Highlight")
	h.FillTransparency = 0.55
	h.OutlineTransparency = 0
	h.Parent = Workspace
	espHighlights[player.UserId] = h
	return h
end

local function updateESPList(data)
	for _, c in ipairs(espScroll:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	for _, info in ipairs(data) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 22)
		row.BackgroundTransparency = 1
		row.Parent = espScroll

		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(0, 88, 1, 0)
		nameLbl.Position = UDim2.new(0, 0, 0, 0)
		nameLbl.BackgroundTransparency = 1
		nameLbl.TextColor3 = Color3.fromRGB(195, 195, 255)
		nameLbl.Font = Enum.Font.Gotham
		nameLbl.TextSize = 11
		nameLbl.Text = info.name
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.Parent = row

		local hpLbl = Instance.new("TextLabel")
		hpLbl.Size = UDim2.new(0, 55, 1, 0)
		hpLbl.Position = UDim2.new(0, 92, 0, 0)
		hpLbl.BackgroundTransparency = 1
		hpLbl.TextColor3 = hpColor(info.health, info.maxHealth)
		hpLbl.Font = Enum.Font.GothamBold
		hpLbl.TextSize = 11
		hpLbl.Text = info.health .. " HP"
		hpLbl.TextXAlignment = Enum.TextXAlignment.Left
		hpLbl.Parent = row

		local posLbl = Instance.new("TextLabel")
		posLbl.Size = UDim2.new(0, 90, 1, 0)
		posLbl.Position = UDim2.new(0, 150, 0, 0)
		posLbl.BackgroundTransparency = 1
		posLbl.TextColor3 = Color3.fromRGB(120, 120, 155)
		posLbl.Font = Enum.Font.Code
		posLbl.TextSize = 10
		local pos = info.position
		posLbl.Text = string.format("%d,%d,%d",
			math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
		posLbl.TextXAlignment = Enum.TextXAlignment.Left
		posLbl.Parent = row
	end
end

-- ============================================================
-- MAIN LOOP — ESP update every 0.5s
-- ============================================================

local espTimer = 0
RunService.RenderStepped:Connect(function(dt)
	espTimer += dt
	if espTimer < 0.5 then return end
	espTimer = 0

	if not espEnabled then return end

	local ok, data = pcall(function()
		return GetPlayerData:InvokeServer()
	end)
	if not ok or not data then return end

	local seen = {}
	for _, info in ipairs(data) do
		local p = Players:FindFirstChild(info.name)
		if p and p.Character then
			local h = getHighlight(p)
			h.Adornee = p.Character
			local c = hpColor(info.health, info.maxHealth)
			h.OutlineColor = c
			h.FillColor = c
			seen[p.UserId] = true
		end
	end

	for uid, h in pairs(espHighlights) do
		if not seen[uid] then
			h:Destroy()
			espHighlights[uid] = nil
		end
	end

	if panelOpen then
		updateESPList(data)
	end
end)

-- Clean up on player leave
Players.PlayerRemoving:Connect(function(p)
	if espHighlights[p.UserId] then
		espHighlights[p.UserId]:Destroy()
		espHighlights[p.UserId] = nil
	end
end)

-- Panel toggle
toggleBtn.MouseButton1Click:Connect(function()
	panelOpen = not panelOpen
	panel.Visible = panelOpen
end)

print("[BR Client] Loaded OK")

-- ============================================================
--[ END OF LOCAL SCRIPT ]
-- ============================================================
