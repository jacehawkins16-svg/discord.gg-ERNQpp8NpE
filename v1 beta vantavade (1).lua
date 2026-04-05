-- Vantavade v1.0

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local nextbotFolder = Workspace:WaitForChild("Game"):WaitForChild("Players")

local downedAnimationIds = {
	"rbxassetid://92286492928616",
	"rbxassetid://130813059655149",
	"rbxassetid://14159827386",
	"rbxassetid://14159826706"
}

local nextbots = {}
local espObjects = {}
local downedEspMap = {}
local regularEspMap = {}
local downedPlayers = {}
local animationListeners = {}

local ESPEnabled = false
local DownedESPEnabled = false
local RegularESPEnabled = false
local AutoAvoidEnabled = false
local DownedTPEnabled = false
local updateConnection = nil

local function isNextbot(model)
	if not model or not model:IsA("Model") then return false end
	if not model:FindFirstChild("Humanoid") or not model:FindFirstChild("HumanoidRootPart") then return false end
	if Players:FindFirstChild(model.Name) then return false end
	return true
end

local function isPlayingDownedAnimation(model)
	if not model or not model:FindFirstChild("Humanoid") then return false end
	local humanoid = model.Humanoid
	for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
		if track.Animation and table.find(downedAnimationIds, track.Animation.AnimationId) then
			return true
		end
	end
	return false
end

local function isDownedPlayer(model)
	if not model or not model:IsA("Model") then return false end
	if not Players:FindFirstChild(model.Name) then return false end
	if model.Name == LocalPlayer.Name then return false end
	return downedPlayers[model] == true
end

local function isRegularAlivePlayer(model)
	if not model or not model:IsA("Model") then return false end
	if not Players:FindFirstChild(model.Name) then return false end
	if model.Name == LocalPlayer.Name then return false end
	return downedPlayers[model] ~= true
end

local function setupDownedListener(model)
	if not model or not model:IsA("Model") or not Players:FindFirstChild(model.Name) or model.Name == LocalPlayer.Name then return end
	if animationListeners[model] then return end

	local humanoid = model:WaitForChild("Humanoid", 2)
	if not humanoid then return end

	local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:WaitForChild("Animator", 2)
	if not animator then return end

	local playedConn = animator.AnimationPlayed:Connect(function(track)
		if track and track.Animation and table.find(downedAnimationIds, track.Animation.AnimationId) then
			downedPlayers[model] = true
			
			local stopConn
			stopConn = track.Stopped:Connect(function()
				downedPlayers[model] = nil
				stopConn:Disconnect()
			end)
		end
	end)

	animationListeners[model] = {playedConn = playedConn}

	local playingTracks = humanoid:GetPlayingAnimationTracks()
	for _, track in ipairs(playingTracks) do
		if track.Animation and table.find(downedAnimationIds, track.Animation.AnimationId) then
			downedPlayers[model] = true
			
			local stopConn
			stopConn = track.Stopped:Connect(function()
				downedPlayers[model] = nil
				stopConn:Disconnect()
			end)
			break
		end
	end
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
	textLabel.Text = playerModel.Name
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
	for _, child in ipairs(nextbotFolder:GetChildren()) do
		if Players:FindFirstChild(child.Name) and child.Name ~= LocalPlayer.Name then
			local actualDowned = isPlayingDownedAnimation(child)
			local trackedDowned = downedPlayers[child] == true
			
			if actualDowned and not trackedDowned then
				downedPlayers[child] = true
			elseif not actualDowned and trackedDowned then
				downedPlayers[child] = nil
			end
		end
	end
	
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
				esp.label.Text = esp.bot.Name .. "\n[" .. math.floor(dist) .. " studs]"
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
	Name = "Vantavade v1.0",
	LoadingTitle = "Vantavade v1.0",
	LoadingSubtitle = "Nextbot Avoid + ESP + Downed TP",
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
	Name = "Player ESP",
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
	Name = "Downed Players ESP",
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
				local targetPos = downed.HumanoidRootPart.Position + Vector3.new(0, 4, 0)
				char.HumanoidRootPart.CFrame = CFrame.new(targetPos)
			end
		end
	end
end)

refreshNextbots()

for _, child in ipairs(nextbotFolder:GetChildren()) do
	if Players:FindFirstChild(child.Name) and child.Name ~= LocalPlayer.Name then
		setupDownedListener(child)
	end
end

nextbotFolder.ChildAdded:Connect(function(child)
	task.wait(0.1)
	
	if isNextbot(child) then
		table.insert(nextbots, child)
		if ESPEnabled then
			createNextbotESP(child)
		end
	elseif Players:FindFirstChild(child.Name) and child.Name ~= LocalPlayer.Name then
		setupDownedListener(child)
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
	
	if animationListeners[child] then
		if animationListeners[child].playedConn then
			animationListeners[child].playedConn:Disconnect()
		end
		animationListeners[child] = nil
	end
	downedPlayers[child] = nil
end)

RunService.Heartbeat:Connect(function()
	for _, child in ipairs(nextbotFolder:GetChildren()) do
		if Players:FindFirstChild(child.Name) and child.Name ~= LocalPlayer.Name then
			local actualDowned = isPlayingDownedAnimation(child)
			if actualDowned and not downedPlayers[child] then
				downedPlayers[child] = true
			elseif not actualDowned and downedPlayers[child] then
				downedPlayers[child] = nil
			end
		end
	end
end)