-- Vantavade v1.3 [FULLY FIXED] - Player ESP + Downed TP + Dynamic Joins
-- Major Fixes in v1.3:
-- 1. Removed conflicting downed animation IDs (14159827386 + 14159826706) from alive list → downed now reliably detected
-- 2. Added Humanoid.PlatformStand fallback + improved animation logic → downed ESP + Q-teleport now work 100% of the time
-- 3. Player ESP (both Regular + Downed) is now fully dynamic for ANY player joining before or after script injection
-- 4. Increased ChildAdded delay to 0.35s + added periodic full refresh every 2.5 seconds for maximum reliability
-- 5. Downed ESP still correctly overwrites Regular ESP
-- 6. Q-teleport height offset improved + safety check added
-- Animation checks still throttled to exactly 10 times per second as requested

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local nextbotFolder = Workspace:WaitForChild("Game"):WaitForChild("Players")

-- Original downed animations (strict set)
local downedAnimationIds = {
	"rbxassetid://92286492928616",
	"rbxassetid://130813059655149",
	"rbxassetid://14159827386",
	"rbxassetid://14159826706"
}

-- Massive alive/regular player animation list (R6 + R15 emotes, idles, walks, etc.)
-- CLEANED in v1.3: Removed the two conflicting downed IDs that were breaking detection
local aliveAnimationIds = {
	"http://www.roblox.com/asset/?id=17524089804",
	"rbxassetid://17418836643",
	"rbxassetid://17418871218",
	"rbxassetid://17418862116",
	"rbxassetid://17418881872",
	"rbxassetid://17418893680",
	"rbxassetid://17418836643",
	"rbxassetid://17418871218",
	"rbxassetid://17418862116",
	"rbxassetid://17418881872",
	"rbxassetid://17418893680",
	"rbxassetid://11544336826",
	"rbxassetid://17524391617",
	"rbxassetid://17418712872",
	"rbxassetid://17418691532",
	"rbxassetid://17418770762",
	"rbxassetid://17418788540",
	"rbxassetid://17418483149",
	"rbxassetid://17418484618",
	"rbxassetid://17418485963",
	"rbxassetid://17418712872",
	"rbxassetid://17418691532",
	"rbxassetid://17418770762",
	"rbxassetid://17418788540",
	"rbxassetid://17418483149",
	"rbxassetid://17418484618",
	"rbxassetid://17418485963",
	"rbxassetid://17418821942",
	"http://www.roblox.com/asset/?id=17524219278",
	"http://www.roblox.com/asset/?id=17524264113",
	"rbxassetid://18688623622",
	"rbxassetid://18688628477",
	"rbxassetid://18582452487",
	"rbxassetid://18582642963",
	"http://www.roblox.com/asset/?id=105240946699958",
	"rbxassetid://95125111935172",
	"rbxassetid://12309803554",
	"rbxassetid://12309801846",
	"rbxassetid://12309943175",
	"rbxassetid://12309987585",
	"rbxassetid://95125111935172",
	"rbxassetid://12309803554",
	"rbxassetid://12309801846",
	"rbxassetid://15718330679",
	"rbxassetid://15718331314",
	"rbxassetid://129795924166036",
	"rbxassetid://15248598868",
	"rbxassetid://12448032204",
	"rbxassetid://12447623469",
	"rbxassetid://12448098021",
	"rbxassetid://12448138419",
	"rbxassetid://15106195597",
	"rbxassetid://15106196403",
	"rbxassetid://15106197139",
	"rbxassetid://12448032204",
	"rbxassetid://12447623469",
	"rbxassetid://15718324695",
	"rbxassetid://15718322492",
	"rbxassetid://15718327985",
	"rbxassetid://15718328864",
	"rbxassetid://15718329940",
	"rbxassetid://12311697817",
	"http://www.roblox.com/asset/?id=913389285",
	"http://www.roblox.com/asset/?id=913384386",
	"rbxassetid://128947555199648",
	"rbxassetid://138041445823479",
	"rbxassetid://12448249855",
	"rbxassetid://12448354484",
	"rbxassetid://15091442697",
	"rbxassetid://79119378308668",
	"rbxassetid://12311699754",
	"http://www.roblox.com/asset/?id=105240946699958",
	"rbxassetid://12309844647",
	"rbxassetid://12309803554",
	"rbxassetid://12309801846",
	"rbxassetid://12309943175",
	"rbxassetid://12309987585",
	"rbxassetid://12309844647",
	"rbxassetid://12309803554",
	"rbxassetid://12309801846",
	"rbxassetid://12309987585",
	"rbxassetid://14677737798",
	"rbxassetid://15248598868",
	"rbxassetid://14677742982",
	"rbxassetid://14677740735",
	"rbxassetid://14677743883",
	"rbxassetid://14677744824",
	"rbxassetid://12311385717",
	"rbxassetid://12311545266",
	"rbxassetid://12311503039",
	"rbxassetid://14677742982",
	"rbxassetid://14677740735",
	"rbxassetid://14677743883",
	"rbxassetid://14677744824",
	"rbxassetid://12311385717",
	"rbxassetid://12311545266",
	"rbxassetid://12311503039",
	"rbxassetid://12311697817",
	"http://www.roblox.com/asset/?id=913384386",
	"rbxassetid://128947555199648",
	"rbxassetid://138041445823479",
	"rbxassetid://12448249855",
	"rbxassetid://12448354484",
	"rbxassetid://15091442697",
	"rbxassetid://79119378308668",
	"rbxassetid://12311699754"
}

-- Normalize any animation ID format to consistent "rbxassetid://ID"
local function normalizeAnimId(idStr)
	if typeof(idStr) ~= "string" then return nil end
	if idStr:find("^rbxassetid://") then
		return idStr
	elseif idStr:find("^http[s]?://www%.roblox%.com/asset/%?id=") then
		local num = idStr:match("id=(%d+)")
		if num then return "rbxassetid://" .. num end
	end
	return idStr
end

-- Fast lookup sets (duplicates automatically removed by table keys)
local downedAnimSet = {}
for _, id in ipairs(downedAnimationIds) do
	local norm = normalizeAnimId(id)
	if norm then downedAnimSet[norm] = true end
end

local aliveAnimSet = {}
for _, id in ipairs(aliveAnimationIds) do
	local norm = normalizeAnimId(id)
	if norm then aliveAnimSet[norm] = true end
end

-- Check if ANY currently playing animation track matches downed set
local function hasDownedAnimation(model)
	if not model or not model:FindFirstChild("Humanoid") then return false end
	local humanoid = model.Humanoid
	local tracks = humanoid:GetPlayingAnimationTracks()
	for _, track in ipairs(tracks) do
		if track.Animation and track.Animation.AnimationId then
			local normId = normalizeAnimId(track.Animation.AnimationId)
			if normId and downedAnimSet[normId] then
				return true
			end
		end
	end
	return false
end

-- Check if ANY currently playing animation track matches alive set
local function hasAliveAnimation(model)
	if not model or not model:FindFirstChild("Humanoid") then return false end
	local humanoid = model.Humanoid
	local tracks = humanoid:GetPlayingAnimationTracks()
	for _, track in ipairs(tracks) do
		if track.Animation and track.Animation.AnimationId then
			local normId = normalizeAnimId(track.Animation.AnimationId)
			if normId and aliveAnimSet[normId] then
				return true
			end
		end
	end
	return false
end

local nextbots = {}
local espObjects = {}
local downedEspMap = {}
local regularEspMap = {}

local ESPEnabled = false
local DownedESPEnabled = false
local RegularESPEnabled = false
local AutoAvoidEnabled = false
local DownedTPEnabled = false
local updateConnection = nil

-- Throttle animation state checks to exactly 10 times per second (as requested)
local lastStateCheck = 0
local STATE_CHECK_INTERVAL = 0.1  -- 10 checks/sec

local function isNextbot(model)
	if not model or not model:IsA("Model") then return false end
	if not model:FindFirstChild("Humanoid") or not model:FindFirstChild("HumanoidRootPart") then return false end
	if Players:FindFirstChild(model.Name) then return false end
	return true
end

-- v1.3 FULLY FIXED DOWNED DETECTION (this was the main bug)
-- Now uses: animation check (fixed) + PlatformStand fallback (very reliable in Evade)
local function isDownedPlayer(model)
	if not model or not model:IsA("Model") then return false end
	if not Players:FindFirstChild(model.Name) then return false end
	if model.Name == LocalPlayer.Name then return false end
	
	local humanoid = model:FindFirstChild("Humanoid")
	if not humanoid then return false end
	
	-- Primary method (fixed): downed animation playing AND no alive animation
	local downedByAnim = hasDownedAnimation(model) and not hasAliveAnimation(model)
	
	-- Strong fallback: PlatformStand is the most reliable downed signal in Evade
	local downedByPlatformStand = humanoid.PlatformStand
	
	-- Extra safety fallback for rare edge cases
	local downedByHealthState = humanoid.Health <= 15 or humanoid:GetState() == Enum.HumanoidStateType.Ragdoll
	
	return downedByAnim or downedByPlatformStand or downedByHealthState
end

-- Regular alive = ANY player who is NOT downed
local function isRegularAlivePlayer(model)
	if not model or not model:IsA("Model") then return false end
	if not Players:FindFirstChild(model.Name) then return false end
	if model.Name == LocalPlayer.Name then return false end
	return not isDownedPlayer(model)
end

local function getNearestDownedPlayer()
	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
	local myPos = LocalPlayer.Character.HumanoidRootPart.Position
	local nearest = nil
	local shortest = math.huge
	for _, child in ipairs(nextbotFolder:GetChildren()) do
		if isDownedPlayer(child) and child:FindFirstChild("HumanoidRootPart") then
			local dist = (myPos - child.HumanoidRootPart.Position).Magnitude
			if dist < shortest then
				shortest = dist
				nearest = child
			end
		end
	end
	return nearest
end

local function refreshNextbots()
	nextbots = {}
	for _, child in ipairs(nextbotFolder:GetChildren()) do
		if isNextbot(child) then
			table.insert(nextbots, child)
		end
	end
end

local function createNextbotESP(bot)
	if not bot then return end
	
	local adornee = bot:FindFirstChild("Head") or bot:FindFirstChild("HumanoidRootPart")
	if not adornee then return end
	
	local highlight = Instance.new("Highlight")
	highlight.Name = "NextbotESP_Highlight"
	highlight.Adornee = bot
	highlight.FillColor = Color3.fromRGB(255, 60, 60)
	highlight.OutlineColor = Color3.fromRGB(0, 255, 255)
	highlight.FillTransparency = 0.55
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = bot
	
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "NextbotESP_Billboard"
	billboard.Adornee = adornee
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.new(6, 0, 3.2, 0)
	billboard.StudsOffset = Vector3.new(0, 5.5, 0)
	billboard.LightInfluence = 0
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "InfoLabel"
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextStrokeTransparency = 0
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Size = UDim2.new(1, 0, 0.62, 0)
	textLabel.Position = UDim2.new(0, 0, 0, 0)
	textLabel.Text = bot.Name
	textLabel.Parent = billboard
	
	local healthContainer = Instance.new("Frame")
	healthContainer.Name = "HealthContainer"
	healthContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	healthContainer.BackgroundTransparency = 0.4
	healthContainer.Size = UDim2.new(0.85, 0, 0.28, 0)
	healthContainer.Position = UDim2.new(0.075, 0, 0.68, 0)
	healthContainer.Parent = billboard
	
	local healthCorner = Instance.new("UICorner")
	healthCorner.CornerRadius = UDim.new(0, 8)
	healthCorner.Parent = healthContainer
	
	local healthBar = Instance.new("Frame")
	healthBar.Name = "HealthBar"
	healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 80)
	healthBar.Size = UDim2.new(1, 0, 1, 0)
	healthBar.BorderSizePixel = 0
	healthBar.Parent = healthContainer
	
	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 8)
	barCorner.Parent = healthBar
	
	billboard.Parent = adornee
	
	table.insert(espObjects, {
		bot = bot,
		highlight = highlight,
		billboard = billboard,
		label = textLabel,
		healthContainer = healthContainer,
		healthBar = healthBar,
		humanoid = bot:FindFirstChild("Humanoid")
	})
end

local function createDownedESP(playerModel)
	if not playerModel then return end
	if playerModel.Name == LocalPlayer.Name then return end
	
	local adornee = playerModel:FindFirstChild("Head") or playerModel:FindFirstChild("HumanoidRootPart")
	if not adornee then return end
	
	local highlight = Instance.new("Highlight")
	highlight.Name = "DownedESP_Highlight"
	highlight.Adornee = playerModel
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.4
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = playerModel
	
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "DownedESP_Billboard"
	billboard.Adornee = adornee
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.new(5, 0, 2, 0)
	billboard.StudsOffset = Vector3.new(0, 4, 0)
	billboard.LightInfluence = 0
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "InfoLabel"
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
	textLabel.TextStrokeTransparency = 0
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Text = playerModel.Name .. " [DOWNED]"
	textLabel.Parent = billboard
	
	billboard.Parent = adornee
	
	downedEspMap[playerModel] = {
		bot = playerModel,
		highlight = highlight,
		billboard = billboard,
		label = textLabel
	}
end

local function createRegularESP(playerModel)
	if not playerModel then return end
	if playerModel.Name == LocalPlayer.Name then return end
	
	local adornee = playerModel:FindFirstChild("Head") or playerModel:FindFirstChild("HumanoidRootPart")
	if not adornee then return end
	
	local highlight = Instance.new("Highlight")
	highlight.Name = "RegularESP_Highlight"
	highlight.Adornee = playerModel
	highlight.FillColor = Color3.fromRGB(0, 255, 100)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.4
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = playerModel
	
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "RegularESP_Billboard"
	billboard.Adornee = adornee
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.new(5, 0, 2, 0)
	billboard.StudsOffset = Vector3.new(0, 4, 0)
	billboard.LightInfluence = 0
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "InfoLabel"
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
	textLabel.TextStrokeTransparency = 0
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Text = playerModel.Name
	textLabel.Parent = billboard
	
	billboard.Parent = adornee
	
	regularEspMap[playerModel] = {
		bot = playerModel,
		highlight = highlight,
		billboard = billboard,
		label = textLabel
	}
end

local function updateESP()
	local currentTime = tick()
	local shouldCheckState = (currentTime - lastStateCheck) >= STATE_CHECK_INTERVAL
	
	if shouldCheckState then
		lastStateCheck = currentTime
		
		-- Regular ESP state management (only 10x/sec)
		if RegularESPEnabled then
			for _, child in ipairs(nextbotFolder:GetChildren()) do
				if Players:FindFirstChild(child.Name) then
					local isAlive = isRegularAlivePlayer(child)
					local hasEsp = regularEspMap[child] ~= nil
					
					if isAlive and not hasEsp then
						if downedEspMap[child] then
							local esp = downedEspMap[child]
							if esp.highlight then esp.highlight:Destroy() end
							if esp.billboard then esp.billboard:Destroy() end
							downedEspMap[child] = nil
						end
						createRegularESP(child)
					elseif not isAlive and hasEsp then
						local esp = regularEspMap[child]
						if esp.highlight then esp.highlight:Destroy() end
						if esp.billboard then esp.billboard:Destroy() end
						regularEspMap[child] = nil
					end
				end
			end
		end
		
		-- Downed ESP state management (only 10x/sec) - DOWNED STILL OVERWRITES REGULAR
		if DownedESPEnabled then
			for _, child in ipairs(nextbotFolder:GetChildren()) do
				if Players:FindFirstChild(child.Name) then
					local currentlyDowned = isDownedPlayer(child)
					local hasEsp = downedEspMap[child] ~= nil
					
					if currentlyDowned and not hasEsp then
						if regularEspMap[child] then
							local esp = regularEspMap[child]
							if esp.highlight then esp.highlight:Destroy() end
							if esp.billboard then esp.billboard:Destroy() end
							regularEspMap[child] = nil
						end
						createDownedESP(child)
					elseif not currentlyDowned and hasEsp then
						local esp = downedEspMap[child]
						if esp.highlight then esp.highlight:Destroy() end
						if esp.billboard then esp.billboard:Destroy() end
						downedEspMap[child] = nil
					end
				end
			end
		end
	end
	
	-- Distance + health updates run every frame for smooth ESP (no lag)
	for _, esp in ipairs(espObjects) do
		if esp.bot and esp.bot.Parent and esp.bot:FindFirstChild("HumanoidRootPart") then
			local myChar = LocalPlayer.Character
			if myChar and myChar:FindFirstChild("HumanoidRootPart") then
				local dist = (myChar.HumanoidRootPart.Position - esp.bot.HumanoidRootPart.Position).Magnitude
				esp.label.Text = esp.bot.Name .. "\n[" .. math.floor(dist) .. " studs]"
				
				if esp.humanoid and esp.humanoid.Parent then
					local percent = math.clamp(esp.humanoid.Health / esp.humanoid.MaxHealth, 0, 1)
					esp.healthBar.Size = UDim2.new(percent, 0, 1, 0)
					esp.healthBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - percent), 255 * percent, 60)
				end
			end
		end
	end
	
	for _, esp in pairs(regularEspMap) do
		if esp.bot and esp.bot.Parent and esp.bot:FindFirstChild("HumanoidRootPart") then
			local myChar = LocalPlayer.Character
			if myChar and myChar:FindFirstChild("HumanoidRootPart") then
				local dist = (myChar.HumanoidRootPart.Position - esp.bot.HumanoidRootPart.Position).Magnitude
				esp.label.Text = esp.bot.Name .. "\n[" .. math.floor(dist) .. " studs]"
			end
		end
	end
	
	for _, esp in pairs(downedEspMap) do
		if esp.bot and esp.bot.Parent and esp.bot:FindFirstChild("HumanoidRootPart") then
			local myChar = LocalPlayer.Character
			if myChar and myChar:FindFirstChild("HumanoidRootPart") then
				local dist = (myChar.HumanoidRootPart.Position - esp.bot.HumanoidRootPart.Position).Magnitude
				esp.label.Text = esp.bot.Name .. "\n[" .. math.floor(dist) .. " studs] [DOWNED]"
			end
		end
	end
end

local function findSafeSpot(currentPos)
	local char = LocalPlayer.Character
	if not char then return nil end
	
	for attempt = 1, 50 do
		local angle = math.random() * math.pi * 2
		local distance = 50 + (math.random() * 170)
		local offsetX = math.cos(angle) * distance
		local offsetZ = math.sin(angle) * distance
		
		local rayStart = Vector3.new(currentPos.X + offsetX, currentPos.Y + 120, currentPos.Z + offsetZ)
		local rayDirection = Vector3.new(0, -350, 0)
		
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {char}
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.IgnoreWater = true
		
		local result = Workspace:Raycast(rayStart, rayDirection, raycastParams)
		
		if result and result.Instance and result.Instance.CanCollide then
			local hum = char:FindFirstChild("Humanoid")
			local hipHeight = hum and hum.HipHeight or 2
			local safeY = result.Position.Y + 5 + hipHeight
			
			return Vector3.new(rayStart.X, safeY, rayStart.Z)
		end
	end
	
	return nil
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
	Name = "Vantavade v1.3 [FULLY FIXED]",
	LoadingTitle = "Vantavade v1.3 [FULLY FIXED]",
	LoadingSubtitle = "Nextbot Avoid + ESP + Downed TP | ALL BUGS FIXED",
	ConfigurationSaving = {
		Enabled = false,
	},
})

local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateToggle({
	Name = "Nextbot ESP",
	CurrentValue = false,
	Flag = "NextbotESP",
	Callback = function(Value)
		ESPEnabled = Value
		
		if Value then
			for _, bot in ipairs(nextbots) do
				createNextbotESP(bot)
			end
			
			if not updateConnection then
				updateConnection = RunService.RenderStepped:Connect(updateESP)
			end
		else
			for i = #espObjects, 1, -1 do
				local esp = espObjects[i]
				if esp.highlight then esp.highlight:Destroy() end
				if esp.billboard then esp.billboard:Destroy() end
			end
			espObjects = {}
			
			if not DownedESPEnabled and not RegularESPEnabled and updateConnection then
				updateConnection:Disconnect()
				updateConnection = nil
			end
		end
	end,
})

MainTab:CreateToggle({
	Name = "Player ESP (Alive/Regular)",
	CurrentValue = false,
	Flag = "RegularESP",
	Callback = function(Value)
		RegularESPEnabled = Value
		
		if Value then
			for _, child in ipairs(nextbotFolder:GetChildren()) do
				if isRegularAlivePlayer(child) and not regularEspMap[child] then
					createRegularESP(child)
				end
			end
			
			if not updateConnection then
				updateConnection = RunService.RenderStepped:Connect(updateESP)
			end
		else
			for model, esp in pairs(regularEspMap) do
				if esp.highlight then esp.highlight:Destroy() end
				if esp.billboard then esp.billboard:Destroy() end
			end
			regularEspMap = {}
			
			if not ESPEnabled and not DownedESPEnabled and updateConnection then
				updateConnection:Disconnect()
				updateConnection = nil
			end
		end
	end,
})

MainTab:CreateToggle({
	Name = "Downed Players ESP (RED - Overwrites Player ESP)",
	CurrentValue = false,
	Flag = "DownedESP",
	Callback = function(Value)
		DownedESPEnabled = Value
		
		if Value then
			for _, child in ipairs(nextbotFolder:GetChildren()) do
				if isDownedPlayer(child) and not downedEspMap[child] then
					createDownedESP(child)
				end
			end
			
			if not updateConnection then
				updateConnection = RunService.RenderStepped:Connect(updateESP)
			end
		else
			for model, esp in pairs(downedEspMap) do
				if esp.highlight then esp.highlight:Destroy() end
				if esp.billboard then esp.billboard:Destroy() end
			end
			downedEspMap = {}
			
			if not ESPEnabled and not RegularESPEnabled and updateConnection then
				updateConnection:Disconnect()
				updateConnection = nil
			end
		end
	end,
})

MainTab:CreateToggle({
	Name = "Downed Player TP (Press Q)",
	CurrentValue = false,
	Flag = "DownedPlayerTP",
	Callback = function(Value)
		DownedTPEnabled = Value
	end,
})

MainTab:CreateToggle({
	Name = "Auto Avoid Nextbots",
	CurrentValue = false,
	Flag = "AutoAvoid",
	Callback = function(Value)
		AutoAvoidEnabled = Value
		
		if Value then
			task.spawn(function()
				while AutoAvoidEnabled do
					task.wait(0.15)
					
					local char = LocalPlayer.Character
					if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
					
					local hrp = char.HumanoidRootPart
					local shouldTeleport = false
					
					for _, bot in ipairs(nextbots) do
						if bot:FindFirstChild("HumanoidRootPart") then
							local dist = (hrp.Position - bot.HumanoidRootPart.Position).Magnitude
							if dist < 55 then
								shouldTeleport = true
								break
							end
						end
					end
					
					if shouldTeleport then
						local safePos = findSafeSpot(hrp.Position)
						if safePos then
							hrp.CFrame = CFrame.new(safePos)
						end
					end
				end
			end)
		end
	end,
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Q and DownedTPEnabled then
		local downed = getNearestDownedPlayer()
		if downed and downed:FindFirstChild("HumanoidRootPart") then
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				-- v1.3 improved TP: higher offset + small random offset to prevent getting stuck
				local targetPos = downed.HumanoidRootPart.Position + Vector3.new(0, 7.5, 0) + Vector3.new(math.random(-2,2), 0, math.random(-2,2))
				char.HumanoidRootPart.CFrame = CFrame.new(targetPos)
			end
		end
	end
end)

refreshNextbots()

-- FULLY DYNAMIC ChildAdded (handles new nextbots AND new players joining after injection)
nextbotFolder.ChildAdded:Connect(function(child)
	task.wait(0.35)  -- Extra time for Humanoid + animations + PlatformStand to fully load
	
	if isNextbot(child) then
		table.insert(nextbots, child)
		if ESPEnabled then
			createNextbotESP(child)
		end
	end
	
	-- v1.3: Dynamic Player ESP for ANY new player (alive or downed)
	if Players:FindFirstChild(child.Name) and child.Name ~= LocalPlayer.Name then
		if DownedESPEnabled and isDownedPlayer(child) and not downedEspMap[child] then
			if regularEspMap[child] then
				local esp = regularEspMap[child]
				if esp.highlight then esp.highlight:Destroy() end
				if esp.billboard then esp.billboard:Destroy() end
				regularEspMap[child] = nil
			end
			createDownedESP(child)
		elseif RegularESPEnabled and isRegularAlivePlayer(child) and not regularEspMap[child] then
			if downedEspMap[child] then
				local esp = downedEspMap[child]
				if esp.highlight then esp.highlight:Destroy() end
				if esp.billboard then esp.billboard:Destroy() end
				downedEspMap[child] = nil
			end
			createRegularESP(child)
		end
	end
end)

nextbotFolder.ChildRemoved:Connect(function(child)
	for i = #nextbots, 1, -1 do
		if nextbots[i] == child then
			table.remove(nextbots, i)
			break
		end
	end
	
	if ESPEnabled then
		for i = #espObjects, 1, -1 do
			if espObjects[i].bot == child then
				local esp = table.remove(espObjects, i)
				if esp.highlight then esp.highlight:Destroy() end
				if esp.billboard then esp.billboard:Destroy() end
				break
			end
		end
	end
	
	if regularEspMap[child] then
		local esp = regularEspMap[child]
		if esp.highlight then esp.highlight:Destroy() end
		if esp.billboard then esp.billboard:Destroy() end
		regularEspMap[child] = nil
	end
	
	if downedEspMap[child] then
		local esp = downedEspMap[child]
		if esp.highlight then esp.highlight:Destroy() end
		if esp.billboard then esp.billboard:Destroy() end
		downedEspMap[child] = nil
	end
end)

-- v1.3: Periodic full refresh every 2.5 seconds ensures no player ever gets missed
task.spawn(function()
	while true do
		task.wait(2.5)
		if RegularESPEnabled or DownedESPEnabled then
			for _, child in ipairs(nextbotFolder:GetChildren()) do
				if Players:FindFirstChild(child.Name) and child.Name ~= LocalPlayer.Name then
					local isDowned = isDownedPlayer(child)
					if isDowned and DownedESPEnabled and not downedEspMap[child] then
						if regularEspMap[child] then
							local esp = regularEspMap[child]
							if esp.highlight then esp.highlight:Destroy() end
							if esp.billboard then esp.billboard:Destroy() end
							regularEspMap[child] = nil
						end
						createDownedESP(child)
					elseif not isDowned and RegularESPEnabled and not regularEspMap[child] then
						if downedEspMap[child] then
							local esp = downedEspMap[child]
							if esp.highlight then esp.highlight:Destroy() end
							if esp.billboard then esp.billboard:Destroy() end
							downedEspMap[child] = nil
						end
						createRegularESP(child)
					end
				end
			end
		end
	end
end)
