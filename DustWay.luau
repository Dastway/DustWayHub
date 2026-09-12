local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local CurrentCamera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "Murder Mystery 2 | Folite Panel (Lite)",
	LoadingTitle = "Murder Mystery 2 interface",
	LoadingSubtitle = "by rayz",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "FoliteMM2",
		FileName = "MM2Config"
	},
	Discord = {
		Enabled = false,
		Invite = "noinvite",
		RememberJoins = true
	},
	KeySystem = false,
	KeySettings = {
		Title = "Untitled",
		Subtitle = "Key System",
		Note = "No key provided",
		FileName = "Key",
		SaveKey = true,
		GrabKeyFromSite = false,
		Key = {"1234"}
	}
})

local Tabs = {
	HomeTab = Window:CreateTab("Info", "info"),
	MainTab = Window:CreateTab("Main", "box"),
	AutoFarmTab = Window:CreateTab("Farming", "bitcoin"),
	MurdTab = Window:CreateTab("Murder", "sword"),
	SheriffTab = Window:CreateTab("Sheriff", "swords"),
	ESPTab = Window:CreateTab("Esp", "crosshair"),
	TeleportTab = Window:CreateTab("Teleport", "map-pin"),
	PlayerTab = Window:CreateTab("Player", "user"),
	TrollingTab = Window:CreateTab("Trolling", "laugh"),
	MiscTab = Window:CreateTab("Extra", "settings"),
	ConfigTab = Window:CreateTab("Configs", "folder")
}

local s2 = "Unknown"
pcall(function()
	if identifyexecutor then
		s2 = identifyexecutor()
	end
end)

-- ==================== INFO TAB ====================
local InfoSection = Tabs.HomeTab:CreateSection("Executor & Status")
do
	local v14 = string.lower(s2)
	local t2 = { solara = true, xeno = true, volcano = true, velocity = true }
	local v16 = false
	for k in pairs(t2) do
		if v14:find(k) then
			v16 = true
			break
		end
	end

	local v18 = v16 and s2 .. " (Not 100% Supported)" or s2 .. " Supported"
	local v19 = v16 and "Some features may not work correctly with your executor." or s2 .. " should run everything fine."

	Tabs.HomeTab:CreateParagraph({
		Title = v18,
		Content = v19
	})
end

-- ==================== MAIN TAB ====================
local MainSection1 = Tabs.MainTab:CreateSection("Game Information")
local t3 = { GetCurrentPlayerData = ReplicatedStorage:FindFirstChild("GetCurrentPlayerData", true) }
local t4 = { Roles = {}, Murderer = "Unknown", Sheriff = "Unknown", Perk = "None" }
local GameInfoParagraph = Tabs.MainTab:CreateParagraph({
	Title = "Game Info",
	Content = "Murder: Unknown\nSheriff: Unknown\nMurderer Perk: None\nGun Dropped: No"
})

local function updateRolesData()
	if t3.GetCurrentPlayerData and t3.GetCurrentPlayerData:IsA("RemoteFunction") then
		local ok, result = pcall(function()
			return t3.GetCurrentPlayerData:InvokeServer()
		end)
		if ok and typeof(result) == "table" then
			t4.Roles = result
			t4.Perk = "None"
			t4.Sheriff = "Unknown"
			t4.Murderer = "Unknown"

			for k, v in pairs(t4.Roles) do
				local k2 = Players:FindFirstChild(k)
				if k2 and k2.Character and k2.Character:FindFirstChild("Humanoid") and k2.Character.Humanoid.Health > 0 then
					if v.Role == "Murderer" then
						t4.Murderer = k
						t4.Perk = v.Perk or "None"
					elseif v.Role == "Sheriff" then
						t4.Sheriff = k
					end
				end
			end
		end
	end
end

local function isGunDropped()
	for _, descendant in ipairs(Workspace:GetDescendants()) do
		if descendant.Name == "GunDrop" then
			return true
		end
	end
	return false
end

task.spawn(function()
	while true do
		updateRolesData()
		local gunStatus = isGunDropped() and "Yes" or "No"
		local contentStr = string.format("Murder: %s\nSheriff: %s\nMurderer Perk: %s\nGun Dropped: %s", t4.Murderer, t4.Sheriff, t4.Perk, gunStatus)
		GameInfoParagraph:Set({Title = "Game Info", Content = contentStr})
		task.wait(0.2)
	end
end)

local MainSection2 = Tabs.MainTab:CreateSection("Gun & Utility")
local autoGetGunEnabled = false
Tabs.MainTab:CreateToggle({
	Title = "Auto Get Gun",
	Default = false,
	Callback = function(p11)
		autoGetGunEnabled = p11
		Rayfield:Notify({ Title = "Auto Gun", Content = p11 and "Enabled" or "Disabled", Duration = 3 })
	end
})

Tabs.MainTab:CreateButton({
	Title = "Get Gun Now",
	Callback = function()
		local gunDrop = nil
		for _, desc in ipairs(Workspace:GetDescendants()) do
			if desc.Name == "GunDrop" and desc:IsA("Part") then
				gunDrop = desc
				break
			end
		end
		if not gunDrop then
			Rayfield:Notify({ Title = "Gun Pickup", Content = "Gun has not been dropped", Duration = 5 })
		else
			local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				pcall(function()
					firetouchinterest(hrp, gunDrop, 0)
					task.wait()
					firetouchinterest(hrp, gunDrop, 1)
				end)
			end
			Rayfield:Notify({ Title = "Gun Pickup", Content = "Gun successfully touched!", Duration = 5 })
		end
	end
})

task.spawn(function()
	while task.wait(0.25) do
		if autoGetGunEnabled then
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp and not (char:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")) then
				local gunDrop = Workspace:FindFirstChild("GunDrop", true)
				if gunDrop and gunDrop:IsA("BasePart") then
					pcall(function()
						firetouchinterest(hrp, gunDrop, 0)
						task.wait()
						firetouchinterest(hrp, gunDrop, 1)
					end)
				end
			end
		end
	end
end)

-- ГУН СХОУДИО / ЗВУКИ
local customSoundId = "rbxassetid://1076907875"
local soundVol = 1
local gunSoundEnabled = false
local soundListMap = {
	Discord = "rbxassetid://1076907875",
	["Fire alarm"] = "rbxassetid://497153454",
	Oof = "rbxassetid://79348298352567",
	["Gun sfx"] = "rbxassetid://1585183374",
	["Samsung Notification"] = "rbxassetid://6205717931",
	Notify = "rbxassetid://225320558",
	["Windows Notify System Generic"] = "rbxassetid://489103549",
	Custom = ""
}
local soundOptionsTable = {}
for k in pairs(soundListMap) do table.insert(soundOptionsTable, k) end

Tabs.MainTab:CreateInput({
	Title = "Custom Gun Drop Sound URL",
	PlaceholderText = "rbxassetid://",
	Callback = function(p12)
		if p12 ~= "" then customSoundId = p12 end
	end
})

Tabs.MainTab:CreateDropdown({
	Title = "Gun Drop Sound",
	Options = soundOptionsTable,
	CurrentOption = {"Discord"},
	Callback = function(p13)
		local opt = typeof(p13) == "table" and p13[1] or p13
		if opt ~= "Custom" then
			customSoundId = soundListMap[opt]
		end
	end
})

Tabs.MainTab:CreateButton({
	Title = "Preview Gun Drop Sound",
	Callback = function()
		local snd = Instance.new("Sound")
		snd.SoundId = customSoundId
		snd.Volume = soundVol
		snd.Parent = Workspace
		snd:Play()
		snd.Ended:Connect(function() snd:Destroy() end)
	end
})

Tabs.MainTab:CreateSlider({
	Title = "Gun Drop Volume",
	Range = {0, 1},
	Increment = 0.05,
	CurrentValue = 1,
	Callback = function(val) soundVol = val end
})

Tabs.MainTab:CreateToggle({
	Title = "Enable Drop Sound / Notification",
	Default = false,
	Callback = function(state) gunSoundEnabled = state end
})

task.spawn(function()
	local notifiedDrops = {}
	while true do
		task.wait(0.5)
		if gunSoundEnabled then
			for _, desc in ipairs(Workspace:GetDescendants()) do
				if desc.Name == "GunDrop" and not notifiedDrops[desc] then
					local snd = Instance.new("Sound")
					snd.SoundId = customSoundId
					snd.Volume = soundVol
					snd.Parent = desc
					snd:Play()
					snd.Ended:Connect(function() snd:Destroy() end)
					Rayfield:Notify({ Title = "Gun!", Content = "Gun Dropped", Duration = 10 })
					notifiedDrops[desc] = true
				end
			end
		end
	end
end)

local MainSection3 = Tabs.MainTab:CreateSection("Extras & Customization")
Tabs.MainTab:CreateToggle({
	Title = "Round Timer Display",
	Callback = function(p16)
		local pg = LocalPlayer:FindFirstChild("PlayerGui")
		if not p16 then
			local tGui = pg and pg:FindFirstChild("TimerDisplayGui")
			if tGui then tGui:Destroy() end
		else
			local rTimerPart = Workspace:FindFirstChild("RoundTimerPart")
			local surfGuiTimer = rTimerPart and rTimerPart:FindFirstChild("SurfaceGui", true) and rTimerPart.SurfaceGui:FindFirstChild("Timer")
			if not pg or not surfGuiTimer then return end

			local screenGui = Instance.new("ScreenGui")
			screenGui.Name = "TimerDisplayGui"
			screenGui.Parent = pg
			screenGui.ResetOnSpawn = false

			local tLabel = Instance.new("TextLabel")
			tLabel.Size = UDim2.new(0, 150, 0, 30)
			tLabel.Position = UDim2.new(0.5, 0, 0.05, 0)
			tLabel.AnchorPoint = Vector2.new(0.5, 0)
			tLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			tLabel.TextScaled = true
			tLabel.Text = "Waiting..."
			tLabel.Parent = screenGui

			task.spawn(function()
				while screenGui.Parent do
					if surfGuiTimer and surfGuiTimer:IsA("TextLabel") then
						tLabel.Text = surfGuiTimer.Text
					end
					task.wait(0.1)
				end
			end)
		end
	end
})

Tabs.MainTab:CreateButton({
	Title = "God Mode",
	Callback = function()
		Rayfield:Notify({ Title = "God Mode", Content = "God mode enabled", Duration = 3 })
		local function applyGod(char)
			local hum = char:WaitForChild("Humanoid", 5)
			if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end
		end
		if LocalPlayer.Character then applyGod(LocalPlayer.Character) end
		LocalPlayer.CharacterAdded:Connect(applyGod)
	end
})

Tabs.MainTab:CreateSlider({
	Title = "FOV",
	Range = {50, 120},
	Increment = 1,
	CurrentValue = CurrentCamera.FieldOfView,
	Callback = function(v) CurrentCamera.FieldOfView = v end
})

Tabs.MainTab:CreateToggle({
	Title = "Anti Fling",
	Default = false,
	Callback = function(state)
		if not state then
			if getgenv().AntiFlingConnection then
				getgenv().AntiFlingConnection:Disconnect()
				getgenv().AntiFlingConnection = nil
			end
		else
			getgenv().AntiFlingConnection = RunService.Heartbeat:Connect(function()
				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= LocalPlayer and p.Character then
						for _, desc in ipairs(p.Character:GetDescendants()) do
							if desc:IsA("BasePart") and not desc.Anchored and desc.Velocity.Magnitude > 100 then
								desc.Velocity = Vector3.zero
								desc.RotVelocity = Vector3.zero
							end
						end
					end
				end
			end)
		end
	end
})

-- ==================== SHERIFF TAB ====================
local SheriffSec = Tabs.SheriffTab:CreateSection("Sheriff & Gun Mechanics")
local sheriffDist = 5000
local sheriffROF = 0.18

local function getClosestMurderer()
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
	local hrp = char.HumanoidRootPart
	local target, minDist = nil, math.huge

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local hum = p.Character:FindFirstChild("Humanoid")
			if hum and hum.Health > 0 then
				-- проверка на нож/мэрдера
				local hasKnife = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
				if hasKnife then
					local dist = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
					if dist < sheriffDist and dist < minDist then
						minDist = dist
						target = p
					end
				end
			end
		end
	end
	return target
end

local function getGunTools()
	local char = LocalPlayer.Character
	if char then
		for _, child in ipairs(char:GetChildren()) do
			if child:IsA("Tool") and child:FindFirstChild("Shoot") then
				return child, child:FindFirstChild("Shoot")
			end
		end
	end
	local bp = LocalPlayer:FindFirstChild("Backpack")
	if bp then
		for _, child in ipairs(bp:GetChildren()) do
			if child:IsA("Tool") and child:FindFirstChild("Shoot") then
				return child, child:FindFirstChild("Shoot")
			end
		end
	end
	return nil, nil
end

local function shootMurdererFunc()
	local _, shootRemote = getGunTools()
	if shootRemote then
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			local target = getClosestMurderer()
			if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
				local targetHrp = target.Character.HumanoidRootPart
				pcall(function()
					shootRemote:FireServer(char.HumanoidRootPart.CFrame, targetHrp.CFrame)
				end)
			end
		end
	end
end

Tabs.SheriffTab:CreateButton({
	Title = "Shoot Murderer",
	Callback = shootMurdererFunc
})

local autoShootActive = false
Tabs.SheriffTab:CreateToggle({
	Title = "Auto Shoot Murderer",
	Default = false,
	Callback = function(state)
		autoShootActive = state
		task.spawn(function()
			while autoShootActive do
				shootMurdererFunc()
				task.wait(sheriffROF)
			end
		end)
	end
})

-- ==================== MURDER TAB ====================
local MurdSec = Tabs.MurdTab:CreateSection("Murderer Options")
local function getKnifeTool()
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("Humanoid") then return nil end
	local knife = LocalPlayer.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife")
	if knife and knife.Parent == LocalPlayer.Backpack then
		char.Humanoid:EquipTool(knife)
		task.wait(0.1)
	end
	return char:FindFirstChild("Knife")
end

Tabs.MurdTab:CreateButton({
	Title = "Kill All Players",
	Callback = function()
		local knife = getKnifeTool()
		if not knife then
			Rayfield:Notify({Title = "Error", Content = "You don't have the knife!", Duration = 4})
			return
		end
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				pcall(function()
					firetouchinterest(p.Character.HumanoidRootPart, knife.Handle, 1)
					firetouchinterest(p.Character.HumanoidRootPart, knife.Handle, 0)
				end)
				task.wait(0.05)
			end
		end
	end
})

local killAuraEnabled = false
local killAuraDist = 50
Tabs.MurdTab:CreateToggle({
	Title = "Kill Aura",
	Default = false,
	Callback = function(state) killAuraEnabled = state end
})

Tabs.MurdTab:CreateSlider({
	Title = "Kill Aura Distance",
	Range = {10, 200},
	Increment = 1,
	CurrentValue = 50,
	Callback = function(val) killAuraDist = val end
})

task.spawn(function()
	while task.wait(0.2) do
		if killAuraEnabled then
			local knife = getKnifeTool()
			local char = LocalPlayer.Character
			if knife and char and char:FindFirstChild("HumanoidRootPart") then
				local hrp = char.HumanoidRootPart
				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
						local hum = p.Character:FindFirstChildOfClass("Humanoid")
						if hum and hum.Health > 0 then
							local dist = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
							if dist <= killAuraDist then
								pcall(function()
									firetouchinterest(p.Character.HumanoidRootPart, knife.Handle, 1)
									firetouchinterest(p.Character.HumanoidRootPart, knife.Handle, 0)
								end)
							end
						end
					end
				end
			end
		end
	end
end)

-- ==================== ESP TAB ====================
local EspSec = Tabs.ESPTab:CreateSection("Visuals & ESP")
local espInnocent = false
local espMurderer = false
local espSheriff = false

Tabs.ESPTab:CreateToggle({
	Title = "Innocent Highlights",
	Default = false,
	Callback = function(v) espInnocent = v end
})
Tabs.ESPTab:CreateToggle({
	Title = "Murderer Highlights",
	Default = false,
	Callback = function(v) espMurderer = v end
})
Tabs.ESPTab:CreateToggle({
	Title = "Sheriff Highlights",
	Default = false,
	Callback = function(v) espSheriff = v end
})

-- Простая система подсветки (Highlights)
task.spawn(function()
	while task.wait(1) do
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				local char = p.Character
				local hl = char:FindFirstChild("FoliteESP")
				
				local isM = (p.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife")) ~= nil
				local isS = (p.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun")) ~= nil
				
				local shouldShow = false
				local col = Color3.fromRGB(0, 255, 0)
				
				if isM and espMurderer then
					shouldShow = true
					col = Color3.fromRGB(255, 0, 0)
				elseif isS and espSheriff then
					shouldShow = true
					col = Color3.fromRGB(0, 0, 255)
				elseif not isM and not isS and espInnocent then
					shouldShow = true
					col = Color3.fromRGB(0, 255, 0)
				end
				
				if shouldShow then
					if not hl then
						hl = Instance.new("Highlight")
						hl.Name = "FoliteESP"
						hl.Parent = char
					end
					hl.FillColor = col
					hl.OutlineColor = Color3.fromRGB(255, 255, 255)
				else
					if hl then hl:Destroy() end
				end
			end
		end
	end
end)

-- ==================== TELEPORT TAB ====================
local TpSec = Tabs.TeleportTab:CreateSection("Teleports")
Tabs.TeleportTab:CreateButton({
	Title = "Teleport to Spawn",
	Callback = function()
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char:PivotTo(CFrame.new(349.6, 521.7, -3.9))
		end
	end
})

Tabs.TeleportTab:Button = Tabs.TeleportTab:CreateButton({
	Title = "TP to Murderer",
	Callback = function()
		local char = LocalPlayer.Character
		if not char then return end
		local target = nil
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and (p.Backpack:FindFirstChild("Knife") or (p.Character and p.Character:FindFirstChild("Knife"))) then
				target = p
				break
			end
		end
		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
			char:PivotTo(CFrame.new(target.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0)))
		end
	end
})

Tabs.TeleportTab:CreateButton({
	Title = "TP to Sheriff",
	Callback = function()
		local char = LocalPlayer.Character
		if not char then return end
		local target = nil
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and (p.Backpack:FindFirstChild("Gun") or (p.Character and p.Character:FindFirstChild("Gun"))) then
				target = p
				break
			end
		end
		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
			char:PivotTo(CFrame.new(target.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0)))
		end
	end
})

-- ==================== PLAYER TAB ====================
local PlayerSec = Tabs.PlayerTab:CreateSection("Local Player Modifications")
Tabs.PlayerTab:CreateToggle({
	Title = "Noclip",
	Default = false,
	Callback = function(state)
		getgenv().NoclipEnabled = state
	end
})

RunService.Stepped:Connect(function()
	if getgenv().NoclipEnabled and LocalPlayer.Character then
		for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

Tabs.PlayerTab:CreateSlider({
	Title = "Walk Speed",
	Range = {16, 150},
	Increment = 1,
	CurrentValue = 16,
	Callback = function(val)
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = val end
	end
})

Tabs.PlayerTab:CreateSlider({
	Title = "Jump Power",
	Range = {50, 300},
	Increment = 1,
	CurrentValue = 50,
	Callback = function(val)
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.JumpPower = val end
	end
})

Tabs.PlayerTab:CreateButton({
	Title = "Mobile Fly (External)",
	Callback = function()
		pcall(function()
			loadstring(game:HttpGet(('https://gist.githubusercontent.com/meozoneYT/bf037dff9f0a70017304ddd67fdcd370/raw/e14e74f425b060df523343cf30b787074eb3c5d2/arceus%2520x%2520fly%25202%2520obflucator'), true))()
		end)
	end
})

-- ==================== MISC TAB ====================
local MiscSec = Tabs.MiscTab:CreateSection("Extra Features")
Tabs.MiscTab:CreateButton({
	Title = "Infinite Yield",
	Callback = function()
		loadstring(game:HttpGet("https://rawscripts.net/raw/Infinite-Yield_500"))()
	end
})

Rayfield:LoadConfiguration()
Rayfield:Notify({
	Title = "Folite Panel (Lite)",
	Content = "Successfully Loaded for PC & Mobile!",
	Duration = 5
})