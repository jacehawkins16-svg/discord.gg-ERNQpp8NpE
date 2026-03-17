if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local VirtualUser = game:GetService("VirtualUser") -- Anti-AFK

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- Respawn handling
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	hrp = newChar:WaitForChild("HumanoidRootPart")
end)

-- ANTI-AFK (prevents idle kick even if game has strict AFK system)
Players.LocalPlayer.Idled:Connect(function()
	VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
	task.wait(1)
	VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- SMART CHAT FUNCTION (works with legacy + TextChatService)
local function sendChat(message)
	if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		local channels = TextChatService:FindFirstChild("TextChannels")
		if channels then
			local general = channels:FindFirstChild("RBXGeneral")
			if general then
				pcall(function() general:SendAsync(message) end)
				return
			end
		end
	else
		local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
		if chatEvents then
			local say = chatEvents:FindFirstChild("SayMessageRequest")
			if say then
				pcall(function() say:FireServer(message, "All") end)
				return
			end
		end
	end
end

-- 50 MESSAGES
local messages = {
	"BEST E-GIRLS IN /bmf", "HOTTEST ROBLOX GIRLS /bmf", "JOIN FOR E-GIRLS /bmf",
	"ULTIMATE DISCORD /bmf", "TOP ROBLOX SERVER /bmf", "E-GIRL HEAVEN /bmf",
	"BEST CHAT EVER /bmf", "FLIRTY FRIENDS /bmf", "ROBLOX DISCORD KING /bmf",
	"GIRLS GALORE /bmf", "EPIC COMMUNITY /bmf", "JOIN NOW /bmf",
	"THE BEST SERVER /bmf", "E-GIRLS UNITE /bmf", "FUN TIMES ONLY /bmf",
	"HOT CHATS /bmf", "DISCORD ADVENTURE /bmf", "ROBLOX BESTIES /bmf",
	"E-GIRL LOVERS /bmf", "PREMIUM SERVER /bmf", "BEST FRIENDS /bmf",
	"GIRL POWER /bmf", "JOIN THE FUN /bmf", "TOP E-GIRLS /bmf",
	"AMAZING DISCORD /bmf", "ROBLOX PARTY /bmf", "E-GIRL CENTRAL /bmf",
	"BEST PLACE /bmf", "CHAT WITH GIRLS /bmf", "ULTIMATE FUN /bmf",
	"DISCORD GOALS /bmf", "HOT ROBLOX /bmf", "E-GIRLS FOR DAYS /bmf",
	"BEST SERVER EVER /bmf", "JOIN DISCORD /bmf", "GIRL CHATS /bmf",
	"ROBLOX SOCIAL /bmf", "THE /bmf EXPERIENCE", "E-GIRL PARADISE /bmf",
	"FRIENDLY SERVER /bmf", "BEST E-GIRL HUB /bmf", "DISCORD MAGIC /bmf",
	"ROBLOX GIRLS /bmf", "JOIN FOR GOOD TIMES /bmf", "TOP COMMUNITY /bmf",
	"E-GIRLS AND MORE /bmf", "BEST IN ROBLOX /bmf", "SERVER OF DREAMS /bmf",
	"HOT AND FUN /bmf", "DONT MISS OUT /bmf"
}

local radius = 5   -- CHANGED AS REQUESTED
local height = 3   -- CHANGED AS REQUESTED

while true do
	-- Get random target
	local validTargets = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			table.insert(validTargets, p)
		end
	end
	
	if #validTargets == 0 then
		task.wait(1)
		continue
	end
	
	local target = validTargets[math.random(1, #validTargets)]
	
	-- Random message + 3 uppercase letters
	local baseMsg = messages[math.random(1, #messages)]
	local randomLetters = string.char(math.random(65,90)) .. string.char(math.random(65,90)) .. string.char(math.random(65,90))
	local finalMsg = baseMsg .. " " .. randomLetters
	
	-- SEND MESSAGE
	sendChat(finalMsg)
	
	-- Orbit for exactly 5 seconds (closer & lower now)
	local startTime = tick()
	while tick() - startTime < 5 do
		local targetHrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
		if not targetHrp then break end
		
		local elapsed = tick() - startTime
		local theta = elapsed * 2
		
		local offset = Vector3.new(math.cos(theta) * radius, height, math.sin(theta) * radius)
		local newPos = targetHrp.Position + offset
		
		local cf = CFrame.lookAt(newPos, targetHrp.Position)
		hrp.CFrame = cf
		
		task.wait(0.016)
	end
end
