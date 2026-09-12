local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")

local WindUI = loadstring(game:HttpGet('https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua'))()
WindUI:SetTheme('Crimson')

local Window = WindUI:CreateWindow({
    Title = "Dustway | MM2 Hub",
    Icon = "candy",
    Author = "AutoFarm & Visuals",
    Folder = "DustwayMM2",
    Transparent = true,
    KeySystem = false,
})

local TabFarm = Window:Tab({ Title = "AutoFarm", Icon = "cpu" })
local TabCombat = Window:Tab({ Title = "Combat & Gun", Icon = "sword" })
local TabVisuals = Window:Tab({ Title = "Visuals & ESP", Icon = "eye" })
local TabExtra = Window:Tab({ Title = "Extra", Icon = "plus" })

local Settings = {
    AutoFarmEnabled = false,
    FarmMode = "Underground",
    TweenSpeed = 25,
    AutoReset = true,
    AvoidMurder = true,
    UndergroundOffset = 4,
    MaxDistance = 600,
    CoinLimit = 40,
    GunAimbot = false,
    AutoGrabGun = false,
    AutoPickupGun = false,
    ESPEnabled = false,
    RoleESP = false,
    Fullbright = false,
    FOVChanger = false,
    FOVValue = 70,
    NoClip = false,
    InfiniteJump = false,
    SpeedHack = false,
    SpeedValue = 16,
    Fly = false,
    FlySpeed = 50,
    Bhop = false,
    AntiRagdoll = false,
    AutoSaveCoins = false,
    Xray = false,
}

local State = {
    isFarming = false,
    isActivelyFlying = false,
    currentTargetCoin = nil,
    ignoredCoins = {},
    currentTween = nil,
}

WindUI:Notify({
    Title = "Dustway Loaded!",
    Content = "Successfully loaded MM2 AutoFarm & Utility.",
    Duration = 4,
    Icon = "bell",
})

local function getTorso(char)
    if not char then return nil end
    return char:FindFirstChild("Torso") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("HumanoidRootPart")
end

local function getCurrentCoins()
    local ok, res = pcall(function()
        local gui = LocalPlayer.PlayerGui:FindFirstChild("MainGUI")
        if not gui then return 0 end
        local gameGui = gui:FindFirstChild("Game")
        if not gameGui then return 0 end
        local coinBags = gameGui:FindFirstChild("CoinBags")
        if not coinBags then return 0 end
        local container = coinBags:FindFirstChild("Container")
        if not container then return 0 end
        local coin = container:FindFirstChild("Coin")
        if not coin then return 0 end
        local currencyFrame = coin:FindFirstChild("CurrencyFrame")
        if not currencyFrame then return 0 end
        local icon = currencyFrame:FindFirstChild("Icon")
        if not icon then return 0 end
        local coinsText = icon:FindFirstChild("Coins")
        if not coinsText then return 0 end
        return coinsText.Text
    end)
    return ok and (tonumber(res) or 0) or 0
end

local function isRoundOver()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return false end
    local victoryGui = pGui:FindFirstChild("Victory")
    if victoryGui then
        for _, child in pairs(victoryGui:GetChildren()) do
            if child:IsA("GuiObject") and child.Visible then return true end
        end
    end
    return false
end

local function isBagFull()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        local mainGui = pGui:FindFirstChild("MainGUI")
        if mainGui and mainGui:FindFirstChild("Lobby") and mainGui.Lobby:FindFirstChild("Dock") then
            local coinBags = mainGui.Lobby.Dock:FindFirstChild("CoinBags")
            if coinBags then
                local notification = coinBags:FindFirstChild("FullBagNotification")
                if notification and notification.Visible then return true end
            end
        end
    end
    return false
end

local function hasNearbyMurderer()
    if not Settings.AvoidMurder then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local otherHRP = player.Character:FindFirstChild("HumanoidRootPart")
            local backpack = player:FindFirstChild("Backpack")
            
            if otherHRP and (otherHRP.Position - hrp.Position).Magnitude <= 10 then
                if player.Character:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")) then
                    return true
                end
            end
        end
    end
    return false
end

local function getNearestCoin(torso)
    local container = nil
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "CoinContainer" then
            container = obj
            break
        end
    end
    if not container then return nil end

    local nearestCoin = nil
    local minDist = math.huge
    for _, coin in pairs(container:GetChildren()) do
        if coin.Name == "Coin_Server" and coin:IsA("BasePart") and not State.ignoredCoins[coin] then
            local dist = (torso.Position - coin.Position).Magnitude
            if dist < minDist and dist <= Settings.MaxDistance then
                minDist = dist
                nearestCoin = coin
            end
        end
    end
    return nearestCoin
end

local function applyFlightPhysics(char)
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return CFrame.Angles(0,0,0) end

    local bv = hrp:FindFirstChild("FarmBV") or Instance.new("BodyVelocity")
    bv.Name = "FarmBV"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp

    local bg = hrp:FindFirstChild("FarmBG") or Instance.new("BodyGyro")
    bg.Name = "FarmBG"
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 50000
    bg.Parent = hrp
    
    local _, rotY, _ = hrp.CFrame:ToOrientation()
    bg.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, rotY, 0) * CFrame.Angles(math.rad(-90), 0, 0)
    return bg.CFrame.Rotation 
end

local function removePhysics()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        if hrp:FindFirstChild("FarmBV") then hrp.FarmBV:Destroy() end
        if hrp:FindFirstChild("FarmBG") then hrp.FarmBG:Destroy() end
        if hrp.Anchored then hrp.Anchored = false end 
    end
end

local function setupNoclip()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then humanoid.PlatformStand = true end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end

local function flyToPoint(targetPos, targetCoin, hrp, torso, lockedRotation)
    local dist = (torso.Position - targetPos).Magnitude
    local tweenInfo = TweenInfo.new(dist / Settings.TweenSpeed, Enum.EasingStyle.Linear)
    local targetCFrame = CFrame.new(targetPos) * lockedRotation
    
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    State.currentTween = tween
    local reached = false
    tween:Play()
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not State.isFarming or not targetCoin or not targetCoin:IsDescendantOf(workspace) then 
            tween:Cancel()
            if connection then connection:Disconnect() end
            return
        end
        
        if firetouchinterest then
            pcall(function()
                firetouchinterest(torso, targetCoin, 0)
                firetouchinterest(torso, targetCoin, 1)
            end)
        end
        
        if (torso.Position - targetPos).Magnitude <= 1.5 then 
            reached = true
            tween:Cancel()
            if connection then connection:Disconnect() end
        end
    end)
    
    while connection and connection.Connected do
        RunService.Heartbeat:Wait()
    end
    return reached
end

local function startFarming()
    if State.isFarming then return end
    State.isFarming = true
    table.clear(State.ignoredCoins)

    task.spawn(function()
        while State.isFarming do
            task.wait()
            pcall(function()
                if hasNearbyMurderer() then
                    State.isActivelyFlying = false
                    removePhysics()
                    task.wait(1)
                    return
                end

                local char = LocalPlayer.Character
                if not char then return end
                
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local torso = getTorso(char)
                local humanoid = char:FindFirstChild("Humanoid")
                
                if not hrp or not torso or not humanoid or humanoid.Health <= 0 then
                    removePhysics()
                    task.wait(1)
                    return
                end

                if isRoundOver() or isBagFull() then
                    removePhysics()
                    if humanoid then humanoid.Sit = false end
                    task.wait(1)
                    return
                end

                if Settings.AutoReset and getCurrentCoins() >= Settings.CoinLimit then
                    humanoid.Health = 0
                    task.wait(5)
                    return
                end
                
                local targetCoin = getNearestCoin(torso)
                if not targetCoin or not targetCoin:IsDescendantOf(workspace) then
                    removePhysics()
                    task.wait(0.5)
                    return
                end

                State.isActivelyFlying = true
                State.currentTargetCoin = targetCoin
                
                if Settings.FarmMode == "Underground" then
                    setupNoclip()
                    local lockedRotation = applyFlightPhysics(char)
                    local targetPos = targetCoin.Position - Vector3.new(0, Settings.UndergroundOffset, 0)
                    flyToPoint(targetPos, targetCoin, hrp, torso, lockedRotation)
                end
                
                State.ignoredCoins[targetCoin] = true
                task.delay(5, function() State.ignoredCoins[targetCoin] = nil end)
            end)
        end
    end)
end

local function stopFarming()
    State.isFarming = false
    State.isActivelyFlying = false
    removePhysics()
    if State.currentTween then pcall(function() State.currentTween:Cancel() end) end
end
local function shootMurderer()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local gun = LocalPlayer.Backpack:FindFirstChild("Gun") or (char and char:FindFirstChild("Gun"))
        if gun and char and char:FindFirstChild("Humanoid") then
            char.Humanoid:EquipTool(gun)
        end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local otherChar = player.Character
                local backpack = player:FindFirstChild("Backpack")
                if otherChar:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")) then
                    local targetHrp = otherChar:FindFirstChild("HumanoidRootPart")
                    if targetHrp then
                        local args = {
                            [1] = 1,
                            [2] = targetHrp.Position,
                            [3] = "AH"
                        }
                        local gunObj = char:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
                        if gunObj and gunObj:FindFirstChild("Shoot") then
                            gunObj.Shoot:FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end)
end

local function grabGun()
    pcall(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "GunDrop" and obj:IsA("BasePart") then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = obj.CFrame
                end
            end
        end
    end)
end

RunService.Heartbeat:Connect(function()
    if Settings.AutoGrabGun or Settings.AutoPickupGun then
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "GunDrop" and obj:IsA("BasePart") then
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and (hrp.Position - obj.Position).Magnitude < 25 then
                        hrp.CFrame = obj.CFrame
                    end
                end
            end
        end)
    end
end)

local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            pcall(function()
                local char = player.Character
                if char then
                    local head = char:FindFirstChild("Head")
                    if head then
                        local billboard = head:FindFirstChild("DustwayESP")
                        if Settings.ESPEnabled then
                            if not billboard then
                                billboard = Instance.new("BillboardGui")
                                billboard.Name = "DustwayESP"
                                billboard.Size = UDim2.new(0, 100, 0, 40)
                                billboard.StudsOffset = Vector3.new(0, 3, 0)
                                billboard.AlwaysOnTop = true
                                billboard.Parent = head
                                
                                local textLabel = Instance.new("TextLabel")
                                textLabel.Name = "ESPText"
                                textLabel.Size = UDim2.new(1, 0, 1, 0)
                                textLabel.BackgroundTransparency = 1
                                textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                                textLabel.TextStrokeTransparency = 0
                                textLabel.TextSize = 14
                                textLabel.Font = Enum.Font.SourceSansBold
                                textLabel.Parent = billboard
                            end
                            
                            local textLabel = billboard:FindFirstChild("ESPText")
                            if textLabel then
                                local roleText = player.Name
                                local roleColor = Color3.fromRGB(255, 255, 255)
                                
                                if Settings.RoleESP then
                                    local backpack = player:FindFirstChild("Backpack")
                                    local isSheriff = player.Character:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun"))
                                    local isMurderer = player.Character:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife"))
                                    
                                    if isMurderer then
                                        roleText = player.Name .. " [MURDERER]"
                                        roleColor = Color3.fromRGB(255, 0, 0)
                                    elseif isSheriff then
                                        roleText = player.Name .. " [SHERIFF]"
                                        roleColor = Color3.fromRGB(0, 150, 255)
                                    else
                                        roleText = player.Name .. " [INNOCENT]"
                                        roleColor = Color3.fromRGB(0, 255, 0)
                                    end
                                end
                                
                                textLabel.Text = roleText
                                textLabel.TextColor3 = roleColor
                            end
                        else
                            if billboard then billboard:Destroy() end
                        end
                    end
                end
            end)
        end
    end
end

RunService.RenderStepped:Connect(function()
    updateESP()
    
    if Settings.Fullbright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    end
    
    if Settings.FOVChanger then
        workspace.CurrentCamera.FieldOfView = Settings.FOVValue
    end
    
    if Settings.SpeedHack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.SpeedValue
    end
    
    if Settings.NoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    if Settings.Bhop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        if humanoid.FloorMaterial ~= Enum.Material.Air then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end

    if Settings.Xray then
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part:IsDescendantOf(LocalPlayer.Character) then
                if part.Transparency ~= 0.5 then
                    part.Transparency = 0.5
                end
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and Settings.InfiniteJump and input.KeyCode == Enum.KeyCode.Space then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Settings.Fly and LocalPlayer.Character then
        local char = LocalPlayer.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local camera = workspace.CurrentCamera
        if hrp then
            local bv = hrp:FindFirstChild("CustomFlyBV") or Instance.new("BodyVelocity")
            bv.Name = "CustomFlyBV"
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = hrp

            local bg = hrp:FindFirstChild("CustomFlyBG") or Instance.new("BodyGyro")
            bg.Name = "CustomFlyBG"
            bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bg.CFrame = camera.CFrame
            bg.Parent = hrp

            local moveVector = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveVector = moveVector + (camera.CFrame.LookVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveVector = moveVector - (camera.CFrame.LookVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveVector = moveVector - (camera.CFrame.RightVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveVector = moveVector + (camera.CFrame.RightVector)
            end
            bv.Velocity = moveVector * Settings.FlySpeed
        end
    else
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            if hrp:FindFirstChild("CustomFlyBV") then hrp.CustomFlyBV:Destroy() end
            if hrp:FindFirstChild("CustomFlyBG") then hrp.CustomFlyBG:Destroy() end
        end
    end
end)

TabFarm:Toggle({
    Title = "Enable Auto Farm",
    Default = false,
    Callback = function(value)
        Settings.AutoFarmEnabled = value
        if value then startFarming() else stopFarming() end
    end
})

TabFarm:Dropdown({
    Title = "Farm Mode",
    Values = {"Underground"},
    Default = Settings.FarmMode,
    Callback = function(value)
        Settings.FarmMode = value
    end
})

TabFarm:Slider({
    Title = "Tween Speed",
    Min = 10,
    Max = 100,
    Default = Settings.TweenSpeed,
    Callback = function(value)
        Settings.TweenSpeed = value
    end
})

TabFarm:Toggle({
    Title = "Auto Reset (Coin Limit)",
    Default = Settings.AutoReset,
    Callback = function(value)
        Settings.AutoReset = value
    end
})

TabFarm:Toggle({
    Title = "Avoid Murderer",
    Default = Settings.AvoidMurder,
    Callback = function(value)
        Settings.AvoidMurder = value
    end
})

TabFarm:Slider({
    Title = "Coin Limit before Reset",
    Min = 10,
    Max = 40,
    Default = Settings.CoinLimit,
    Callback = function(value)
        Settings.CoinLimit = value
    end
})

TabCombat:Button({
    Title = "Shoot Murderer",
    Callback = function()
        shootMurderer()
    end
})

TabCombat:Button({
    Title = "Grab Gun",
    Callback = function()
        grabGun()
    end
})

TabCombat:Toggle({
    Title = "Auto Grab Gun",
    Default = Settings.AutoGrabGun,
    Callback = function(value)
        Settings.AutoGrabGun = value
    end
})

TabCombat:Toggle({
    Title = "Auto Pickup Gun",
    Default = Settings.AutoPickupGun,
    Callback = function(value)
        Settings.AutoPickupGun = value
    end
})

TabVisuals:Toggle({
    Title = "Enable ESP",
    Default = Settings.ESPEnabled,
    Callback = function(value)
        Settings.ESPEnabled = value
    end
})

TabVisuals:Toggle({
    Title = "Role ESP (Murderer / Sheriff)",
    Default = Settings.RoleESP,
    Callback = function(value)
        Settings.RoleESP = value
    end
})

TabVisuals:Toggle({
    Title = "Fullbright",
    Default = Settings.Fullbright,
    Callback = function(value)
        Settings.Fullbright = value
    end
})

TabVisuals:Toggle({
    Title = "FOV Changer",
    Default = Settings.FOVChanger,
    Callback = function(value)
        Settings.FOVChanger = value
    end
})

TabVisuals:Slider({
    Title = "FOV Value",
    Min = 50,
    Max = 120,
    Default = Settings.FOVValue,
    Callback = function(value)
        Settings.FOVValue = value
    end
})

TabVisuals:Toggle({
    Title = "NoClip",
    Default = Settings.NoClip,
    Callback = function(value)
        Settings.NoClip = value
    end
})

TabVisuals:Toggle({
    Title = "Infinite Jump",
    Default = Settings.InfiniteJump,
    Callback = function(value)
        Settings.InfiniteJump = value
    end
})

TabVisuals:Toggle({
    Title = "SpeedHack",
    Default = Settings.SpeedHack,
    Callback = function(value)
        Settings.SpeedHack = value
    end
})

TabVisuals:Slider({
    Title = "Speed Value",
    Min = 16,
    Max = 100,
    Default = Settings.SpeedValue,
    Callback = function(value)
        Settings.SpeedValue = value
    end
})

TabExtra:Toggle({
    Title = "Fly",
    Default = Settings.Fly,
    Callback = function(value)
        Settings.Fly = value
    end
})

TabExtra:Slider({
    Title = "Fly Speed",
    Min = 10,
    Max = 150,
    Default = Settings.FlySpeed,
    Callback = function(value)
        Settings.FlySpeed = value
    end
})

TabExtra:Toggle({
    Title = "Bunny Hop (Bhop)",
    Default = Settings.Bhop,
    Callback = function(value)
        Settings.Bhop = value
    end
})

TabExtra:Toggle({
    Title = "X-Ray",
    Default = Settings.Xray,
    Callback = function(value)
        Settings.Xray = value
    end
})

TabExtra:Button({
    Title = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})
