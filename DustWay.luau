local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

game:GetService("HttpService")

local CurrentCamera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "Murder Mystery 2 | Folite Panel (Lite)",
	LoadingTitle = "Murder Mystery 2 interface",
	LoadingSubtitle = "by rayz",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "wwww",
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

local t3, t4, u23, u24, u25, u26, u27, s3, u29, u30, u31, u32, u33, u34, u35, Players2, Workspace2, LocalPlayer2, u39, u40, s5, n1, u43, t6

do
	local v16

	do
		local v14 = string.lower(s2)
		local t2 = {
			solara = true,
			xeno = true,
			volcano = true,
			velocity = true
		}

		v16 = false

		for k in pairs(t2) do
			if v14:find(k) then
				v16 = true

				break
			end
		end
	end

	local v18 = v16 and s2 .. " (Not 100% Supported)" or s2 .. " Supported"
	local v19 = v16 and "Some features may not work correctly with your executor." or s2 .. " should run everything fine and everything should work ight"

	Tabs.HomeTab:CreateParagraph({
		Title = v18,
		Content = v19
	})
	
	t3 = {
		GetCurrentPlayerData = ReplicatedStorage:FindFirstChild("GetCurrentPlayerData", true)
	}
	t4 = {
		Roles = {},
		Murderer = "Unknown",
		Sheriff = "Unknown",
		Perk = "None"
	}
	u23 = Tabs.MainTab:CreateParagraph({
		Title = "Game Info",
		Content = "Murder: Unknown\nSheriff: Unknown\nMurderer Perk: None\nGun Dropped: No"
	})

	function u24()
		if t3.GetCurrentPlayerData and t3.GetCurrentPlayerData:IsA("RemoteFunction") then
			local ok, result = pcall(function()
				return t3.GetCurrentPlayerData:InvokeServer()
			end)

			if ok and typeof(result) == "table" then
				t4.Roles = result

				local v199 = t4
				local v200 = t4

				t4.Perk = "None"
				v200.Sheriff = "Unknown"
				v199.Murderer = "Unknown"

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
	function u25()
		for _, descendant in ipairs(Workspace:GetDescendants()) do
			if descendant.Name == "GunDrop" then
				return true
			end
		end

		return false
	end
	function u26()
		u24()

		local v206 = u25() and "Yes" or "No"
		local v207 = string.format("Murder: %s\nSheriff: %s\nMurderer Perk: %s\nGun Dropped: %s", t4.Murderer, t4.Sheriff, t4.Perk, v206)

		u23:Set({Title = "Game Info", Content = v207})
	end

	task.spawn(function()
		while true do
			u26()
			task.wait(0.2)
		end
	end)
	u27 = true
	s3 = "G"
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == Enum.KeyCode[s3] then
			u27 = not u27

			if not u27 then
				Rayfield:Notify({
					Title = " closed",
					Content = "Press " .. s3 .. " to reopen ",
					Duration = 50
				})
			end
		end
	end)
	Tabs.MiscTab:Button({
		Title = "Infinite Yield",
		Callback = function()
			loadstring(game:HttpGet("https://rawscripts.net/raw/Infinite-Yield_500"))()
		end
	})
	u29 = false
	u30 = nil
	u31 = nil

	function u32()
		local t5 = {}
		local GetCurrentPlayerData = ReplicatedStorage:FindFirstChild("GetCurrentPlayerData", true)

		if GetCurrentPlayerData and GetCurrentPlayerData:IsA("RemoteFunction") then
			t5 = GetCurrentPlayerData:InvokeServer() or {}
		end

		local v216 = nil
		local v217 = nil

		for k, v in pairs(t5) do
			if v.Role == "Murderer" then
				v216 = k
			elseif v.Role == "Sheriff" then
				v217 = k
			end
		end

		return v216, v217
	end
	function u33(p5, p6, p7)
		local s4 = "rbxassetid://129260712070622"

		if p7 then
			local p7_2 = Players:FindFirstChild(p7)

			if p7_2 then
				local ok, result = pcall(function()
					return Players:GetUserThumbnailAsync(p7_2.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
				end)

				if ok then
					s4 = result
				end
			end
		end

		Rayfield:Notify({
			Title = p5,
			Content = p6,
			Duration = 30
		})
	end
	function u34(p8, p9)
		local v229 = p8 == "Murderer" and "Murderer" or "Sheriff"
		local v230 = p9 or "No " .. p8

		u33(v229, v230, p9)
	end

	task.spawn(function()
		while true do
			if u29 then
				local v231, v232 = u32()

				if v231 ~= u30 then
					u34("Murderer", v231)
				end

				if v232 ~= u31 then
					u34("Sheriff", v232)
				end

				u31 = v232
				u30 = v231
			end

			task.wait(0.5)
		end
	end)
	Tabs.MainTab:Toggle({
		Title = "Auto Role Notification",
		Info = "Notify when roles are detected or changed",
		Callback = function(p10)
			u29 = p10

			if p10 then
				u30 = nil
				u31 = nil
			end
		end,
		Default = false
	})
	Tabs.MainTab:Button({
		Title = "Notify Murderer",
		Callback = function()
			local v234 = u32()

			u34("Murderer", v234)
		end
	})
	Tabs.MainTab:Button({
		Title = "Notify Sheriff",
		Callback = function()
			local _, v236 = u32()

			u34("Sheriff", v236)
		end
	})
	u35 = false
	Tabs.MainTab:Toggle({
		Title = "Auto Get Gun",
		Default = false,
		Callback = function(p11)
			u35 = p11
			Rayfield:Notify({
				Title = "Auto Gun",
				Content = p11 and "Enabled" or "Disabled",
				Duration = 3
			})
		end
	})
	Tabs.MainTab:Button({
		Title = "Get Gun Now",
		Callback = function()
			local v238 = nil

			for _, descendant in ipairs(Workspace:GetDescendants()) do
				if descendant.Name == "GunDrop" and descendant:IsA("Part") then
					v238 = descendant

					break
				end
			end

			if not v238 then
				Rayfield:Notify({
					Title = "Gun Pickup",
					Content = "gun has not been dropped",
					Duration = 5
				})
			else
				local _HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

				if _HumanoidRootPart then
					for _, v in ipairs(v238:GetConnections()) do
						if v.Name == "TouchInterest" then
							v:Fire(_HumanoidRootPart)
						end
					end
				end

				Rayfield:Notify({
					Title = "Gun Pickup",
					Content = "Gun successfully touched!",
					Duration = 5
				})
			end
		end
	})
	Players2 = game:GetService("Players")
	Workspace2 = game:GetService("Workspace")
	LocalPlayer2 = Players2.LocalPlayer
	u39 = false
	u40 = false
	task.spawn(function()
		while task.wait(0.25) do
			local v244

			if not u39 or u40 then
				v244 = true
			else
				local Character = LocalPlayer2.Character
				local _HumanoidRootPart2 = Character and Character:FindFirstChild("HumanoidRootPart")

				if _HumanoidRootPart2 then
					if Character:FindFirstChild("Gun") or LocalPlayer2.Backpack:FindFirstChild("Gun") then
						v244 = true
					else
						local GunDrop = Workspace2:FindFirstChild("GunDrop", true)

						if GunDrop and GunDrop:IsA("BasePart") then
							u40 = true
							firetouchinterest(_HumanoidRootPart2, GunDrop, 0)
							task.wait()
							firetouchinterest(_HumanoidRootPart2, GunDrop, 1)
							task.delay(0.5, function()
								u40 = false
							end)
						end

						v244 = true
					end
				else
					v244 = true
				end
			end

			if not v244 then
				return
			end
		end
	end)
	s5 = "rbxassetid://1076907875"
	n1 = 1
	u43 = false
	t6 = {
		Discord = "rbxassetid://1076907875",
		["Fire alarm"] = "rbxassetid://497153454",
		Oof = "rbxassetid://79348298352567",
		["Gun sfx"] = "rbxassetid://1585183374",
		["Samsung Notification"] = "rbxassetid://6205717931",
		Notify = "rbxassetid://225320558",
		["Windows Notify System Generic"] = "rbxassetid://489103549",
		Custom = ""
	}

	local t7 = {}

	for k in pairs(t6) do
		table.insert(t7, k)
	end

	Tabs.MainTab:Input({
		Title = "Custom Gun Drop Sound URL",
		PlaceholderText = "rbxassetid://",
		Callback = function(p12)
			if p12 ~= "" then
				s5 = p12
			end
		end
	})
	Tabs.MainTab:Dropdown({
		Title = "Gun Drop Sound",
		Options = t7,
		CurrentOption = {"Discord"},
		Callback = function(p13)
			local option = typeof(p13) == "table" and p13[1] or p13
			if option ~= "Custom" then
				s5 = t6[option]
			end
		end
	})
end

Tabs.MainTab:Button({
	Title = "Preview Gun Drop Sound",
	Callback = function()
		local Sound = Instance.new("Sound")

		Sound.SoundId = s5
		Sound.Volume = n1
		Sound.Parent = Workspace2
		Sound:Play()
		Sound.Ended:Connect(function()
			Sound:Destroy()
		end)
	end
})
Tabs.MainTab:Slider({
	Title = "Gun Drop Volume",
	Range = {0, 1},
	Increment = 0.05,
	CurrentValue = 1,
	Callback = function(p14)
		n1 = p14
	end
})
Tabs.MainTab:Toggle({
	Title = "Enable",
	Default = false,
	Callback = function(p15)
		u43 = p15
	end
})
task.spawn(function()
	local t8 = {}

	while true do
		task.wait(0.5)

		if u43 then
			for _, descendant in ipairs(Workspace2:GetDescendants()) do
				if descendant.Name == "GunDrop" and not t8[descendant] then
					local Sound = Instance.new("Sound")

					Sound.SoundId = s5
					Sound.Volume = n1
					Sound.Parent = descendant
					Sound:Play()
					Sound.Ended:Connect(function()
						Sound:Destroy()
					end)
					Rayfield:Notify({
						Title = "Gun!",
						Content = "Gun Dropped",
						Duration = 10
					})
					t8[descendant] = true
				end
			end
		end
	end
end)
Tabs.MainTab:Toggle({
	Title = "Round Timer",
	Callback = function(p16)
		if not p16 then
			local _TimerDisplayGui = LocalPlayer2:FindFirstChild("PlayerGui") and LocalPlayer2.PlayerGui:FindFirstChild("TimerDisplayGui")

			if _TimerDisplayGui then
				_TimerDisplayGui:Destroy()
			end
		else
			local PlayerGui = LocalPlayer2:FindFirstChild("PlayerGui")
			local RoundTimerPart = Workspace2:FindFirstChild("RoundTimerPart")
			local _Surfacegui = RoundTimerPart and (RoundTimerPart:FindFirstChild("SurfaceGui") and RoundTimerPart.SurfaceGui:FindFirstChild("Timer"))

			if not PlayerGui or not _Surfacegui then
				return
			end

			local ScreenGui = Instance.new("ScreenGui")

			ScreenGui.Name = "TimerDisplayGui"
			ScreenGui.Parent = PlayerGui
			ScreenGui.ResetOnSpawn = false

			local TextLabel = Instance.new("TextLabel")

			TextLabel.Size = UDim2.new(0, 150, 0, 30)
			TextLabel.Position = UDim2.new(0.5, 0, 0.05, 0)
			TextLabel.AnchorPoint = Vector2.new(0.5, 0)
			TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.TextScaled = true
			TextLabel.RichText = true
			TextLabel.Text = "Waiting..."
			TextLabel.FontFace = Font.new("rbxassetid://16658221428", Enum.FontWeight.Bold)
			TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
			TextLabel.TextStrokeTransparency = 0
			TextLabel.Parent = ScreenGui

			task.spawn(function()
				while ScreenGui.Parent do
					if _Surfacegui and _Surfacegui:IsA("TextLabel") then
						TextLabel.Text = _Surfacegui.Text
					end

					task.wait(0.1)
				end
			end)
		end
	end
})
Tabs.MainTab:Button({
	Title = "God mode",
	Callback = function(_)
		Rayfield:Notify({
			Title = "god mode",
			Content = "god mode is on",
			Duration = 5
		})

		local function u269(p18)
			p18:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
		end

		local LocalPlayer3 = game:GetService("Players").LocalPlayer

		u269(LocalPlayer3.Character.Humanoid)
		LocalPlayer3.CharacterAdded:Connect(function(character)
			u269(character:WaitForChild("Humanoid"))
		end)
	end
})

local u47 = false

Tabs.MiscTab:Toggle({
	Title = "Anti Stealer",
	Default = false,
	Callback = function(p19)
		u47 = p19
	end
})

local DeclineTrade, u51, u52, Players3, RunService2, LocalPlayer4, n2, n3, n4, E, u61, u62, u63, u64, u65, u66, u67, u68, u69, E2, u71, u72, Players4, VirtualUser, RunService3, LocalPlayer5, t9, u78, u79, u80, t11, u82, CurrentCamera2, LocalPlayer6, u85, u86, n5, n6, n7, n8, LocalPlayer7, u92, t14, t15, CurrentCamera3, LocalPlayer8, u97, u98, u99, u100, t16, t17, u107, u108, LocalPlayer9, u112, u113, RunService4, Workspace3, LocalPlayer10, u119, u120, u121, u122, n11, u124, vector3

do
	local Trade = ReplicatedStorage:WaitForChild("Trade")
	local StartTrade = Trade:WaitForChild("StartTrade")

	DeclineTrade = Trade:WaitForChild("DeclineTrade")
	u51 = false

	function u52()
		if u51 then
			return
		end

		u51 = true
		task.spawn(function()
			while u47 do
				pcall(function()
					DeclineTrade:FireServer()
				end)
				task.wait(0.1)
			end

			u51 = false
		end)
	end

	StartTrade.OnClientEvent:Connect(function()
		if not u47 then
			return
		end

		pcall(function()
			DeclineTrade:FireServer()
		end)
		u52()
	end)
	Tabs.MainTab:Slider({
		Title = "FOV",
		Range = {50, 120},
		Increment = 1,
		CurrentValue = CurrentCamera.FieldOfView,
		Callback = function(p20)
			CurrentCamera.FieldOfView = p20
		end
	})
	Tabs.MainTab:Toggle({
		Title = "Anti Fling",
		Default = false,
		Callback = function(p21)
			if not p21 then
				if getgenv().AntiFlingConnection then
					getgenv().AntiFlingConnection:Disconnect()
					getgenv().AntiFlingConnection = nil
				end
			else
				getgenv().AntiFlingConnection = RunService.Heartbeat:Connect(function()
					for _, player in ipairs(Players2:GetPlayers()) do
						if player ~= LocalPlayer2 and player.Character then
							for _, descendant in ipairs(player.Character:GetDescendants()) do
								if descendant:IsA("BasePart") and not descendant.Anchored and descendant.Velocity.Magnitude > 100 then
									local zero = Vector3.zero

									descendant.RotVelocity = Vector3.zero
									descendant.Velocity = zero
									descendant.Anchored = true
									task.delay(0.5, function()
										if descendant and descendant.Parent then
											descendant.Anchored = false
										end
									end)
								end
							end
						end
					end
				end)
			end
		end
	})
	
	Players3 = game:GetService("Players")
	RunService2 = game:GetService("RunService")

	local UserInputService2 = game:GetService("UserInputService")

	LocalPlayer4 = Players3.LocalPlayer
	n2 = 0.18
	n3 = 5000
	n4 = 0.08
	E = Enum.KeyCode.E
	u61 = false
	u62 = nil
	u63 = false
	u64 = nil

	function u65()
		local Character = LocalPlayer4.Character

		if Character then
			for _, child in ipairs(Character:GetChildren()) do
				if child:IsA("Tool") and child:FindFirstChild("Shoot") then
					return child, child:FindFirstChild("Shoot")
				end
			end
		end

		local Backpack = LocalPlayer4:FindFirstChild("Backpack")

		if Backpack then
			for _, child in ipairs(Backpack:GetChildren()) do
				if child:IsA("Tool") and child:FindFirstChild("Shoot") then
					return child, child:FindFirstChild("Shoot")
				end
			end
		end

		return nil, nil
	end
	function u66(p22)
		if not p22 then
			return false
		end

		local Backpack = p22:FindFirstChild("Backpack")

		if not Backpack or not Backpack:FindFirstChild("Knife") then
			local Character = p22.Character

			if Character and Character:FindFirstChild("Knife") then
				return true
			end

			return false
		end

		return true
	end
	function u67()
		local Character = LocalPlayer4.Character

		if not Character or not Character:FindFirstChild("HumanoidRootPart") then
			return nil
		end

		local HumanoidRootPart = Character.HumanoidRootPart
		local v285 = nil
		local huge = math.huge

		for _, player in ipairs(Players3:GetPlayers()) do
			local v289

			if player ~= LocalPlayer4 then
				if not player.Character then
					v289 = true
				else
					local Humanoid = player.Character:FindFirstChild("Humanoid")

					if not Humanoid or Humanoid.Health <= 0 then
						v289 = true
					else
						local HumanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")

						if not HumanoidRootPart2 then
							v289 = true
						elseif not u66(player) then
							v289 = true
						else
							local Magnitude = (HumanoidRootPart.Position - HumanoidRootPart2.Position).Magnitude

							if Magnitude < n3 and Magnitude < huge then
								huge = Magnitude
								v285 = player
							end

							v289 = true
						end
					end
				end
			else
				v289 = true
			end

			if not v289 then
				return v285
			end
		end

		return v285
	end
	function u68(p23)
		if p23 then
			return p23 + Vector3.new((math.random() - 0.5) * n4, (math.random() - 0.5) * n4, (math.random() - 0.5) * n4)
		end

		return CFrame.new()
	end
	function u69()
		local v294, v295 = u65()

		if v294 and v295 then
			local Character = LocalPlayer4.Character

			if not Character or not Character:FindFirstChild("HumanoidRootPart") then
				return
			end

			local v297 = u67()

			if v297 then
				local HumanoidRootPart = Character.HumanoidRootPart
				local HumanoidRootPart3 = v297.Character:FindFirstChild("HumanoidRootPart")

				if HumanoidRootPart3 then
					local v300 = u68(HumanoidRootPart3.CFrame)

					v295:FireServer(HumanoidRootPart.CFrame, v300)

					return
				end

				return
			end

			return
		end
	end

	Tabs.SheriffTab:Button({
		Title = "Shoot murd",
		Callback = u69
	})
	Tabs.SheriffTab:Toggle({
		Title = "Auto Shoot murd",
		Default = false,
		Callback = function(p24)
			u63 = p24

			if u64 then
				u64:Disconnect()
				u64 = nil
			end

			if p24 then
				u64 = RunService2.Heartbeat:Connect(function()
					if not u63 then
						return
					end

					u69()
					task.wait(n2)
				end)

				return
			end
		end
	})
	Tabs.SheriffTab:Keybind({
		Title = "Shoot / Auto-Shoot (hold)",
		CurrentKeybind = "E",
		Callback = function(p25)
			if Enum.KeyCode[p25] then
				E = Enum.KeyCode[p25]
			end
		end
	})
	UserInputService2.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode ~= E then
			return
		end

		u61 = true
		u69()

		if u62 then
			u62:Disconnect()
		end

		u62 = RunService2.Heartbeat:Connect(function()
			if not u61 then
				return
			end

			u69()
			task.wait(n2)
		end)
	end)
	UserInputService2.InputEnded:Connect(function(input, gameProcessed)
		if not gameProcessed then
			if input.KeyCode ~= E then
				return
			end

			u61 = false

			if u62 then
				u62:Disconnect()
				u62 = nil
			end

			return
		end
	end)
	
	Players4 = game:GetService("Players")
	VirtualUser = game:GetService("VirtualUser")
	RunService3 = game:GetService("RunService")
	LocalPlayer5 = Players4.LocalPlayer
	t9 = {
		KillAura = {
			Enabled = false,
			Distance = 50
		}
	}

	function u78()
		local Character = LocalPlayer5.Character

		if not Character or not Character:FindFirstChild("Humanoid") then
			return nil
		end

		local _Knife = LocalPlayer5.Backpack:FindFirstChild("Knife") or Character:FindFirstChild("Knife")

		if _Knife and _Knife.Parent == LocalPlayer5.Backpack then
			Character.Humanoid:EquipTool(_Knife)
			task.wait(0.1)
		end

		return Character:FindFirstChild("Knife")
	end
	function u79(p26)
		local v314 = u78()

		if not v314 then
			return
		end

		local Character = p26.Character

		if Character then
			local Humanoid = Character:FindFirstChildOfClass("Humanoid")

			if Humanoid and Humanoid.Health > 0 then
				local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

				if HumanoidRootPart then
					VirtualUser:ClickButton1(Vector2.new())
					firetouchinterest(HumanoidRootPart, v314.Handle, 1)
					firetouchinterest(HumanoidRootPart, v314.Handle, 0)
				end

				return
			end

			return
		end
	end
	function u80()
		local t10 = {}

		for _, player in ipairs(Players4:GetPlayers()) do
			if player ~= LocalPlayer5 then
				table.insert(t10, player.Name)
			end
		end

		table.sort(t10)

		return t10
	end

	t11 = {}
	u82 = Tabs.MurdTab:Dropdown({
		Title = "Select Players to Kill",
		Options = u80(),
		CurrentOption = {},
		MultipleOptions = true,
		Callback = function(p27)
			t11 = p27 or {}
		end
	})
	Players4.PlayerAdded:Connect(function()
		u82:Refresh(u80())
	end)
	Players4.PlayerRemoving:Connect(function()
		u82:Refresh(u80())
	end)
	Tabs.MurdTab:Button({
		Title = "Kill Selected Players",
		Callback = function()
			if #t11 == 0 then
				Rayfield:Notify({
					Title = "Warning",
					Content = "No players selected!",
					Duration = 3
				})

				return
			end

			for _, v in ipairs(t11) do
				local v2 = Players4:FindFirstChild(v)

				if v2 then
					u79(v2)
					task.wait(0.1)
				end
			end
		end
	})
	Tabs.MurdTab:Button({
		Title = "Kill All Players",
		Callback = function()
			local v328 = u78()

			if not v328 then
				Rayfield:Notify({
					Title = "Error",
					Content = "You don't have the knife! (Not murderer?)",
					Duration = 5
				})

				return
			end

			for _, player in ipairs(Players4:GetPlayers()) do
				if player ~= LocalPlayer5 and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					VirtualUser:ClickButton1(Vector2.new())
					firetouchinterest(player.Character.HumanoidRootPart, v328.Handle, 1)
					firetouchinterest(player.Character.HumanoidRootPart, v328.Handle, 0)
					task.wait(0.05)
				end
			end
		end
	})
	Tabs.MurdTab:Button({
		Title = "Kill Random Player",
		Callback = function()
			local t13 = {}

			for _, player in ipairs(Players4:GetPlayers()) do
				if player ~= LocalPlayer5 and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					table.insert(t13, player)
				end
			end

			if not (#t13 > 0) then
				Rayfield:Notify({
					Title = "Info",
					Content = "No valid targets found!",
					Duration = 3
				})
			else
				local v334 = t13[math.random(1, #t13)]

				u79(v334)
			end
		end
	})
	Tabs.MurdTab:Toggle({
		Title = "Kill Aura",
		Default = false,
		Callback = function(p28)
			t9.KillAura.Enabled = p28
		end
	})
	Tabs.MurdTab:Slider({
		Title = "Kill Aura Distance",
		Range = {10, 1000},
		Increment = 1,
		CurrentValue = 1000,
		Callback = function(p29)
			t9.KillAura.Distance = p29
		end
	})
	task.spawn(function()
		while task.wait(0.2) do
			local v340

			if t9.KillAura.Enabled then
				local v337 = u78()

				if v337 then
					local Character = LocalPlayer5.Character

					if Character then
						local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

						if not HumanoidRootPart then
							v340 = true
						else
							for _, player in ipairs(Players4:GetPlayers()) do
								if player ~= LocalPlayer5 then
									local Character2 = player.Character

									if Character2 then
										local Humanoid = Character2:FindFirstChildOfClass("Humanoid")

										if Humanoid and Humanoid.Health > 0 then
											local HumanoidRootPart4 = Character2:FindFirstChild("HumanoidRootPart")

											if HumanoidRootPart4 and (HumanoidRootPart.Position - HumanoidRootPart4.Position).Magnitude <= t9.KillAura.Distance then
												VirtualUser:ClickButton1(Vector2.new())
												firetouchinterest(HumanoidRootPart4, v337.Handle, 1)
												firetouchinterest(HumanoidRootPart4, v337.Handle, 0)
												task.wait(0.08)
											end
										end
									end
								end
							end

							v340 = true
						end
					else
						v340 = true
					end
				else
					v340 = true
				end
			else
				v340 = true
			end

			if not v340 then
				return
			end
		end
	end)
	CurrentCamera2 = Workspace2.CurrentCamera
	LocalPlayer6 = Players4.LocalPlayer
	getgenv().Aimlock = {
		Enabled = false,
		TargetPart = "HumanoidRootPart",
		Initialized = false
	}

	function u85()
		for _, player in ipairs(Players4:GetPlayers()) do
			if player ~= LocalPlayer6 and player.Character and (player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")) and player.Character:FindFirstChild("HumanoidRootPart") then
				return player
			end
		end

		return nil
	end

	Tabs.SheriffTab:Dropdown({
		Title = "Camlock Target Part",
		Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
		CurrentOption = {"HumanoidRootPart"},
		Callback = function(p30)
			local option = typeof(p30) == "table" and p30[1] or p30
			getgenv().Aimlock.TargetPart = option
		end
	})
	Tabs.SheriffTab:Toggle({
		Title = "Enable Camlock",
		Default = false,
		Callback = function(p31)
			getgenv().Aimlock.Enabled = p31

			if p31 and not getgenv().Aimlock.Initialized then
				getgenv().Aimlock.Initialized = true
				RunService3.RenderStepped:Connect(function()
					if getgenv().Aimlock.Enabled then
						local v878 = u85()

						if v878 and v878.Character then
							local AimlockTargetPart = v878.Character:FindFirstChild(getgenv().Aimlock.TargetPart)

							if AimlockTargetPart then
								CurrentCamera2.CFrame = CFrame.new(CurrentCamera2.CFrame.Position, AimlockTargetPart.Position)
							end
						end

						return
					end
				end)
			end
		end
	})
	
	u86 = false
	n5 = 0
	n6 = 20
	n7 = 0
	n8 = 1
	LocalPlayer7 = Players4.LocalPlayer
	Tabs.SheriffTab:Slider({
		Title = "Distance Behind Murderer",
		Range = {0, 120},
		Increment = 1,
		CurrentValue = 20,
		Callback = function(p32)
			n6 = p32
		end
	})
	Tabs.SheriffTab:Slider({
		Title = "Height Above Murderer",
		Range = {-20, 50},
		Increment = 1,
		CurrentValue = 0,
		Callback = function(p33)
			n7 = p33
		end
	})
	Tabs.SheriffTab:Slider({
		Title = "Orbit Speed",
		Range = {0, 200},
		Increment = 0.1,
		CurrentValue = 1,
		Callback = function(p34)
			n8 = p34
		end
	})
	Tabs.SheriffTab:Toggle({
		Title = "Enable Orbit",
		Default = false,
		Callback = function(p35)
			u86 = p35
		end
	})

	function u92()
		for _, player in ipairs(Players4:GetPlayers()) do
			if player ~= LocalPlayer7 then
				local v356 = false

				if player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Knife") then
					v356 = true
				elseif player.Character and player.Character:FindFirstChild("Knife") then
					v356 = true
				end

				if v356 then
					return player
				end
			end
		end

		return nil
	end

	RunService3.RenderStepped:Connect(function(dt)
		if u86 then
			local v358 = u92()

			if v358 and v358.Character then
				local HumanoidRootPart = v358.Character:FindFirstChild("HumanoidRootPart")
				local HumanoidRootPart5 = (LocalPlayer7.Character or LocalPlayer7.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")

				if HumanoidRootPart then
					if not (n8 > 0) then
						local v361 = HumanoidRootPart.Position - HumanoidRootPart.CFrame.LookVector * n6 + Vector3.new(0, n7, 0)

						HumanoidRootPart5.CFrame = CFrame.lookAt(v361, HumanoidRootPart.Position)
					else
						n5 = n5 + n8 * dt * 60

						local v362 = math.rad(n5)
						local v363 = math.sin(v362) * n6
						local v364 = math.cos(v362) * n6
						local v365 = HumanoidRootPart.Position + Vector3.new(v363, n7, v364)

						HumanoidRootPart5.CFrame = CFrame.lookAt(v365, HumanoidRootPart.Position)
					end

					return
				end

				return
			end

			return
		end
	end)
	
	t14 = {
		ReplicatedStorage = game:GetService("ReplicatedStorage"),
		Players = game:GetService("Players"),
		RunService = game:GetService("RunService")
	}
	t15 = {
		GetCurrentPlayerData = t14.ReplicatedStorage:FindFirstChild("GetCurrentPlayerData", true)
	}
	CurrentCamera3 = workspace.CurrentCamera
	LocalPlayer8 = t14.Players.LocalPlayer
	u97 = nil

	function u98()
		local ok, result = pcall(function()
			if t15.GetCurrentPlayerData then
				return t15.GetCurrentPlayerData:InvokeServer() or {}
			end
		end)

		return ok and result or {}
	end
	function u99(p36)
		local v378 = u97[p36.Name]

		return v378 and (not v378.Killed and not v378.Dead)
	end
	function u100(p37)
		local Backpack = p37:FindFirstChild("Backpack")

		if Backpack and Backpack:FindFirstChild("Gun") then
			return true
		end

		local v381 = p37.Character or workspace:FindFirstChild(p37.Name)

		if not v381 or not v381:FindFirstChild("Gun") then
			return false
		end

		return true
	end

	t16 = {
		Highlights = {
			Innocent = Color3.fromRGB(0, 255, 0),
			Murderer = Color3.fromRGB(255, 0, 0),
			Sheriff = Color3.fromRGB(0, 0, 255),
			Hero = Color3.fromRGB(0, 0, 255),
			DeadInnocent = Color3.fromRGB(128, 128, 128)
		}
	}
	t17 = {
		Highlights = {
			Innocent = false,
			Murderer = false,
			Sheriff = false,
			DeadInnocent = false
		}
	}

	u107 = false

	function u108(p38)
		if t19[p38] then
			pcall(function()
				t19[p38]:Destroy()
			end)
			t19[p38] = nil
		end
	end

	for _, player in ipairs(t14.Players:GetPlayers()) do
		if player ~= LocalPlayer8 then
			player.CharacterRemoving:Connect(function()
				u108(player)
			end)
		end
	end

	t14.Players.PlayerAdded:Connect(function(player)
		if player ~= LocalPlayer8 then
			player.CharacterRemoving:Connect(function()
				u108(player)
			end)
		end
	end)
	t14.Players.PlayerRemoving:Connect(u108)
	
	Tabs.ESPTab:Toggle({
		Title = "Innocent Highlights",
		Default = false,
		Callback = function(p39)
			t17.Highlights.Innocent = p39
		end
	})
	Tabs.ESPTab:Toggle({
		Title = "Murderer Highlights",
		Default = false,
		Callback = function(p40)
			t17.Highlights.Murderer = p40
		end
	})
	Tabs.ESPTab:Toggle({
		Title = "Sheriff/Hero Highlights",
		Default = false,
		Callback = function(p41)
			t17.Highlights.Sheriff = p41
		end
	})
	Tabs.ESPTab:Toggle({
		Title = "Dead Highlights",
		Default = false,
		Callback = function(p42)
			t17.Highlights.DeadInnocent = p42
		end
	})
	
	LocalPlayer9 = Players4.LocalPlayer

	function u112()
		return LocalPlayer9.Character or LocalPlayer9.CharacterAdded:Wait()
	end
	function u113()
		for _, child in ipairs(Workspace2:GetChildren()) do
			if child:IsA("Model") and child:FindFirstChild("Spawns") and not child.Name:lower():find("lobby") then
				for _, descendant in ipairs(child:GetDescendants()) do
					if descendant:IsA("BasePart") then
						return child
					end
				end
			end
		end

		return nil
	end

	Tabs.TeleportTab:Button({
		Title = "Teleport to Spawn",
		Callback = function()
			local v458 = u112()

			v458:WaitForChild("HumanoidRootPart")
			v458:PivotTo((CFrame.new(349.614563, 521.773132, -3.974884)))
		end
	})
	Tabs.TeleportTab:Button({
		Title = "Teleport to Game Map",
		Callback = function()
			local v459 = u112()

			v459:WaitForChild("HumanoidRootPart")

			local v460 = u113()

			if not v460 then
				Rayfield:Notify({
					Title = "Error",
					Content = "Game map not found",
					Duration = 3
				})

				return
			end

			local Spawns = v460:FindFirstChild("Spawns")
			local descendantPosition = nil

			if Spawns then
				for _, descendant in ipairs(Spawns:GetDescendants()) do
					if descendant:IsA("BasePart") then
						descendantPosition = descendant.Position

						break
					end
				end
			end

			if not descendantPosition then
				local zero = Vector3.zero
				local n9 = 0

				for _, descendant in ipairs(v460:GetDescendants()) do
					if descendant:IsA("BasePart") then
						zero = zero + descendant.Position
						n9 = n9 + 1
					end
				end

				if n9 > 0 then
					descendantPosition = zero / n9
				end
			end

			if descendantPosition then
				v459:PivotTo(CFrame.new(descendantPosition + Vector3.new(0, 5, 0)))
			end
		end
	})
	Tabs.TeleportTab:Button({
		Title = "Teleport Above Map",
		Callback = function()
			local v469 = u112()

			v469:WaitForChild("HumanoidRootPart")

			local v470 = u113()

			if v470 then
				local v471 = -math.huge
				local zero = Vector3.zero
				local n10 = 0

				for _, descendant in ipairs(v470:GetDescendants()) do
					if descendant:IsA("BasePart") then
						v471 = math.max(v471, descendant.Position.Y)
						zero = zero + descendant.Position
						n10 = n10 + 1
					end
				end

				if n10 == 0 then
					Rayfield:Notify({
						Title = "Error",
						Content = "No map parts found",
						Duration = 3
					})

					return
				end

				local v476 = zero / n10
				local vector3_2 = Vector3.new(v476.X, v471 + 30, v476.Z)

				v469:PivotTo(CFrame.new(vector3_2))
				Rayfield:Notify({
					Title = "Teleported",
					Content = "Teleported above map",
					Duration = 2
				})

				return
			end

			Rayfield:Notify({
				Title = "Error",
				Content = "Game map not found",
				Duration = 3
			})
		end
	})
	Tabs.TeleportTab:Button({
		Title = "TP to Murderer",
		Callback = function()
			local Character = game.Players.LocalPlayer.Character

			if Character then
				local v479 = nil

				for _, player in ipairs(game.Players:GetPlayers()) do
					if player ~= game.Players.LocalPlayer and (player.Backpack and player.Backpack:FindFirstChild("Knife") or player.Character and player.Character:FindFirstChild("Knife")) then
						v479 = player

						break
					end
				end

				if v479 and v479.Character and v479.Character:FindFirstChild("HumanoidRootPart") then
					Character:PivotTo(CFrame.new(v479.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0)))
				end

				return
			end
		end
	})
	Tabs.TeleportTab:Button({
		Title = "TP to Sheriff",
		Callback = function()
			local Character = game.Players.LocalPlayer.Character

			if not Character then
				return
			end

			local v483 = nil

			for _, player in ipairs(game.Players:GetPlayers()) do
				if player ~= game.Players.LocalPlayer and (player.Backpack and player.Backpack:FindFirstChild("Gun") or player.Character and player.Character:FindFirstChild("Gun")) then
					v483 = player

					break
				end
			end

			if v483 and v483.Character and v483.Character:FindFirstChild("HumanoidRootPart") then
				Character:PivotTo(CFrame.new(v483.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0)))
			end
		end
	})

	local Players5 = game:GetService("Players")
	local UserInputService3 = game:GetService("UserInputService")

	RunService4 = game:GetService("RunService")
	Workspace3 = game:GetService("Workspace")
	LocalPlayer10 = Players5.LocalPlayer
	u119 = false
	u120 = false
	u121 = false
	u122 = false
	n11 = -50
	u124 = nil
	vector3 = Vector3.new(1000, 10, 1000)

	Tabs.PlayerTab:Toggle({
		Title = "Noclip",
		Default = false,
		Callback = function(p63)
			u119 = p63
		end
	})
	RunService4.Stepped:Connect(function()
		if u119 and LocalPlayer10.Character then
			for _, descendant in ipairs(LocalPlayer10.Character:GetDescendants()) do
				if descendant:IsA("BasePart") then
					descendant.CanCollide = false
				end
			end
		end
	end)
	Tabs.PlayerTab:Slider({
		Title = "Walk Speed",
		Range = {16, 200},
		Increment = 1,
		CurrentValue = 16,
		Callback = function(p64)
			local _Humanoid = LocalPlayer10.Character and LocalPlayer10.Character:FindFirstChildOfClass("Humanoid")

			if _Humanoid then
				_Humanoid.WalkSpeed = p64
			end
		end
	})
	Tabs.PlayerTab:Slider({
		Title = "Jump Power",
		Range = {50, 500},
		Increment = 1,
		CurrentValue = 50,
		Callback = function(p65)
			local _Humanoid2 = LocalPlayer10.Character and LocalPlayer10.Character:FindFirstChildOfClass("Humanoid")

			if _Humanoid2 then
				_Humanoid2.JumpPower = p65
			end
		end
	})
	Tabs.PlayerTab:Toggle({
		Title = "Zero Gravity",
		Default = false,
		Callback = function(p66)
			Workspace3.Gravity = p66 and 0 or 196.2
		end
	})
	Tabs.PlayerTab:Toggle({
		Title = "Infinite Jump",
		Default = false,
		Callback = function(p68)
			u120 = p68
		end
	})
	UserInputService3.JumpRequest:Connect(function()
		if u120 and LocalPlayer10.Character then
			local Humanoid = LocalPlayer10.Character:FindFirstChildOfClass("Humanoid")

			if Humanoid then
				Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end)
end

Tabs.PlayerTab:Button({
	Title = "Teleport Tool",
	Callback = function()
		local Tool = Instance.new("Tool")

		Tool.RequiresHandle = false
		Tool.Name = "Teleport Tool"
		Tool.Activated:Connect(function()
			local v880 = LocalPlayer10:GetMouse().Hit.Position + Vector3.new(0, 5, 0)
			local _HumanoidRootPart4 = LocalPlayer10.Character and LocalPlayer10.Character:FindFirstChild("HumanoidRootPart")

			if _HumanoidRootPart4 then
				_HumanoidRootPart4.CFrame = CFrame.new(v880)
			end
		end)
		Tool.Parent = LocalPlayer10:WaitForChild("Backpack")
	end
})

local function u126()
	if u124 and u124.Parent then
		u124:Destroy()
	end

	u124 = Instance.new("Part")
	u124.Name = "AntiVoidPlatform"
	u124.Size = vector3
	u124.Position = Vector3.new(0, n11 + vector3.Y / 2, 0)
	u124.Anchored = true
	u124.CanCollide = true
	u124.Transparency = 0.7
	u124.Color = Color3.fromRGB(0, 170, 255)
	u124.Material = Enum.Material.Neon
	u124.Parent = Workspace3

	return u124
end
local function u127()
	if u124 and u124.Parent then
		u124:Destroy()
		u124 = nil
	end
end
local function u128()
	if not u122 then
		u127()
	else
		if not u124 or not u124.Parent then
			u126()
		end

		local Character = LocalPlayer10.Character

		if Character and Character:FindFirstChild("HumanoidRootPart") then
			local HumanoidRootPart = Character.HumanoidRootPart

			u124.Position = Vector3.new(math.floor(HumanoidRootPart.Position.X / 100) * 100, n11 + vector3.Y / 2, math.floor(HumanoidRootPart.Position.Z / 100) * 100)
		end
	end
end

Tabs.PlayerTab:Toggle({
	Title = "Anti Void",
	Default = false,
	Callback = function(p69)
		u122 = p69
		u128()

		if not p69 then
			u127()
		end
	end
})

Tabs.PlayerTab:Button({
	Title = "Mobile Fly",
	Callback = function(_)
		loadstring("loadstring(game:HttpGet(('https://gist.githubusercontent.com/meozoneYT/bf037dff9f0a70017304ddd67fdcd370/raw/e14e74f425b060df523343cf30b787074eb3c5d2/arceus%2520x%2520fly%25202%2520obflucator'),true))()\n\n")()
	end
})

local Players6 = game:GetService("Players")
local LocalPlayer11 = Players6.LocalPlayer
local t21 = {}
local u135 = false

getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

local u136 = Tabs.TrollingTab:CreateParagraph({
	Title = "Fling Status",
	Content = "Select players to fling"
})

local function u137()
	local n12 = 0

	for _ in pairs(t21) do
		n12 = n12 + 1
	end

	if u135 then
		u136:Set({Title = "Fling Status", Content = "Flinging " .. n12 .. " target(s)"})
	else
		u136:Set({Title = "Fling Status", Content = n12 .. " people selected"})
	end
end
local function u138(p71)
	local t22 = {}

	for _, player in ipairs(Players6:GetPlayers()) do
		if player ~= LocalPlayer11 then
			table.insert(t22, player.Name)
		end
	end

	p71:Refresh(t22)
end

local u139 = Tabs.TrollingTab:Dropdown({
	Title = "Select Players",
	Options = {},
	CurrentOption = {},
	MultipleOptions = true,
	Callback = function(p72)
		t21 = {}

		for _, v in pairs(p72) do
			local v3 = Players6:FindFirstChild(v)

			if v3 then
				t21[v] = v3
			end
		end

		u137()
	end
})

local function u140(p73)
	local Character = LocalPlayer11.Character
	local _Humanoid3 = Character and Character:FindFirstChildOfClass("Humanoid")
	local _RootPart = _Humanoid3 and _Humanoid3.RootPart
	local Character3 = p73.Character

	if not Character3 then
		return
	end

	local Humanoid = nil
	local RootPart = nil
	local Head = nil
	local Accessory = nil
	local Handle = nil

	if Character3:FindFirstChildOfClass("Humanoid") then
		Humanoid = Character3:FindFirstChildOfClass("Humanoid")
	end

	if Humanoid and Humanoid.RootPart then
		RootPart = Humanoid.RootPart
	end

	if Character3:FindFirstChild("Head") then
		Head = Character3.Head
	end

	if Character3:FindFirstChildOfClass("Accessory") then
		Accessory = Character3:FindFirstChildOfClass("Accessory")
	end

	if Accessory and Accessory:FindFirstChild("Handle") then
		Handle = Accessory.Handle
	end

	if Character and _Humanoid3 and _RootPart then
		if _RootPart.Velocity.Magnitude < 50 then
			getgenv().OldPos = _RootPart.CFrame
		end

		if Humanoid and Humanoid.Sit then
			return
		end

		if Head then
			workspace.CurrentCamera.CameraSubject = Head
		elseif not Handle then
			if Humanoid and RootPart then
				workspace.CurrentCamera.CameraSubject = Humanoid
			end
		else
			workspace.CurrentCamera.CameraSubject = Handle
		end

		if not Character3:FindFirstChildWhichIsA("BasePart") then
			return
		end

		local function u529(p74, p75, p76)
			_RootPart.CFrame = CFrame.new(p74.Position) * p75 * p76
			Character:SetPrimaryPartCFrame(CFrame.new(p74.Position) * p75 * p76)
			_RootPart.Velocity = Vector3.new(90000000, 900000000, 90000000)
			_RootPart.RotVelocity = Vector3.new(900000000, 900000000, 900000000)
		end
		local function v530(p77)
			local timestamp = tick()
			local n13 = 0

			repeat
				if _RootPart and Humanoid then
					if p77.Velocity.Magnitude < 50 then
						n13 = n13 + 100
						u529(p77, CFrame.new(0, 1.5, 0) + Humanoid.MoveDirection * p77.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(n13), 0, 0))
						task.wait()
						u529(p77, CFrame.new(0, -1.5, 0) + Humanoid.MoveDirection * p77.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(n13), 0, 0))
						task.wait()
						u529(p77, CFrame.new(0, 1.5, 0) + Humanoid.MoveDirection * p77.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(n13), 0, 0))
						task.wait()
						u529(p77, CFrame.new(0, -1.5, 0) + Humanoid.MoveDirection * p77.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(n13), 0, 0))
						task.wait()
						u529(p77, CFrame.new(0, 1.5, 0) + Humanoid.MoveDirection, CFrame.Angles(math.rad(n13), 0, 0))
						task.wait()
						u529(p77, CFrame.new(0, -1.5, 0) + Humanoid.MoveDirection, CFrame.Angles(math.rad(n13), 0, 0))
						task.wait()
					else
						u529(p77, CFrame.new(0, 1.5, Humanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
						task.wait()
						u529(p77, CFrame.new(0, -1.5, -Humanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
						task.wait()
						u529(p77, CFrame.new(0, 1.5, Humanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
						task.wait()
						u529(p77, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
						task.wait()
						u529(p77, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
						task.wait()
						u529(p77, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
						task.wait()
						u529(p77, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
						task.wait()
					end
				end
			until timestamp + 2 < tick() or not u135
		end

		workspace.FallenPartsDestroyHeight = 0 / 0

		local BodyVelocity = Instance.new("BodyVelocity")

		BodyVelocity.Parent = _RootPart
		BodyVelocity.Velocity = Vector3.new(0, 0, 0)
		BodyVelocity.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
		_Humanoid3:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

		if not RootPart then
			if Head then
				v530(Head)
			elseif Handle then
				v530(Handle)
			end
		else
			v530(RootPart)
		end

		BodyVelocity:Destroy()
		_Humanoid3:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
		workspace.CurrentCamera.CameraSubject = _Humanoid3

		if getgenv().OldPos then
			repeat
				_RootPart.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)
				Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, 0.5, 0))
				_Humanoid3:ChangeState("GettingUp")

				for _, child in pairs(Character:GetChildren()) do
					if child:IsA("BasePart") then
						local vector3_4 = Vector3.new()

						child.RotVelocity = Vector3.new()
						child.Velocity = vector3_4
					end
				end

				task.wait()
			until (_RootPart.Position - getgenv().OldPos.p).Magnitude < 25

			workspace.FallenPartsDestroyHeight = getgenv().FPDH
		end
	end
end

Tabs.TrollingTab:Button({
	Title = "Fling Players",
	Callback = function()
		if u135 then
			return
		end

		u135 = true
		task.spawn(function()
			while u135 do
				for _, v in pairs(t21) do
					if u135 and v and v.Parent then
						u140(v)
						task.wait(0.1)
					end
				end

				task.wait(0.5)
			end
		end)
	end
})
Tabs.TrollingTab:Button({
	Title = "Stop Fling",
	Callback = function()
		u135 = false
	end
})

local function u141(p78)
	local Backpack = p78:FindFirstChild("Backpack")

	if Backpack then
		for _, child in ipairs(Backpack:GetChildren()) do
			if child:IsA("Tool") then
				if child.Name:lower():find("knife") or child.Name:lower():find("murderer") then
					return "Murderer"
				end

				if child.Name:lower():find("gun") or child.Name:lower():find("sheriff") then
					return "Sheriff"
				end
			end
		end
	end

	local Character = p78.Character

	if Character then
		for _, child in ipairs(Character:GetChildren()) do
			if child:IsA("Tool") then
				if child.Name:lower():find("knife") or child.Name:lower():find("murderer") then
					return "Murderer"
				end

				if child.Name:lower():find("gun") or child.Name:lower():find("sheriff") then
					return "Sheriff"
				end
			end
		end
	end

	return "Innocent"
end

Tabs.TrollingTab:Button({
	Title = "Fling Murderer",
	Callback = function()
		if u135 then
			return
		end

		t21 = {}

		for _, player in ipairs(Players6:GetPlayers()) do
			if player ~= LocalPlayer11 and u141(player) == "Murderer" then
				t21[player.Name] = player
			end
		end

		u137()

		if next(t21) then
			u135 = true
			task.spawn(function()
				for _, v in pairs(t21) do
					if v and v.Parent then
						u140(v)
						task.wait(0.5)
					end
				end

				u135 = false
				u137()
			end)
		end
	end
})
Tabs.TrollingTab:Button({
	Title = "Fling Sheriff",
	Callback = function()
		if not u135 then
			t21 = {}

			for _, player in ipairs(Players6:GetPlayers()) do
				if player ~= LocalPlayer11 and u141(player) == "Sheriff" then
					t21[player.Name] = player
				end
			end

			u137()

			if next(t21) then
				u135 = true
				task.spawn(function()
					for _, v in pairs(t21) do
						if v and v.Parent then
							u140(v)
							task.wait(0.5)
						end
					end

					u135 = false
					u137()
				end)
			end

			return
		end
	end
})

local t23 = {
	"sit",
	"ninja",
	"dab",
	"zen",
	"floss",
	"headless",
	"zombie",
	"wave",
	"cheer",
	"laugh"
}

Tabs.TrollingTab:Dropdown({
	Title = "Select Emote",
	Options = t23,
	CurrentOption = {t23[1]},
	Callback = function(p79)
		local option = typeof(p79) == "table" and p79[1] or p79
		t15.PlayEmote:Fire(option)
	end
})
Tabs.TrollingTab:Toggle({
	Title = "Seizure Mode",
	Default = false,
	Callback = function(p80)
		if not p80 then
			if getgenv().SeizureLoop then
				task.cancel(getgenv().SeizureLoop)
				getgenv().SeizureLoop = nil
			end
		else
			getgenv().SeizureLoop = task.spawn(function()
				while task.wait(0.1) do
					for _, v in ipairs(t23) do
						t15.PlayEmote:Fire(v)
						task.wait(0.05)
					end
				end
			end)
		end
	end
})
Players6.PlayerAdded:Connect(function()
	u138(u139)
end)
Players6.PlayerRemoving:Connect(function(player)
	t21[player.Name] = nil
	u138(u139)
end)
u138(u139)

Rayfield:LoadConfiguration()