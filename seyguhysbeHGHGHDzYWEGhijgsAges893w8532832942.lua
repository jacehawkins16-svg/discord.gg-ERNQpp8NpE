-- Roblox Lua Script: Discord Advertisement Bot (/bmf)
-- Paste this as a LocalScript in StarterPlayer > StarterPlayerScripts
-- This script will:
-- • Teleport to a random player every 5 seconds
-- • Orbit/spin around them in a circle (10 stud radius, 5 studs in the air)
-- • Send a unique advertisement message in chat every teleport
-- • Uses 50 different base messages (all containing "/bmf")
-- • Adds 3 random uppercase letters to each message for uniqueness
-- • Works with the legacy chat system (most games)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- Handle respawn
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	hrp = newChar:WaitForChild("HumanoidRootPart")
end)

-- Chat service (legacy - works in almost all experiences)
local chatEvents = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents")
local SayMessageRequest = chatEvents:WaitForChild("SayMessageRequest")

-- 50 DIFFERENT MESSAGES (each one contains exactly "/bmf" as requested)
local messages = {
	"BEST E-GIRLS IN /bmf",
	"HOTTEST ROBLOX GIRLS /bmf",
	"JOIN FOR E-GIRLS /bmf",
	"ULTIMATE DISCORD /bmf",
	"TOP ROBLOX SERVER /bmf",
	"E-GIRL HEAVEN /bmf",
	"BEST CHAT EVER /bmf",
	"FLIRTY FRIENDS /bmf",
	"ROBLOX DISCORD KING /bmf",
	"GIRLS GALORE /bmf",
	"EPIC COMMUNITY /bmf",
	"JOIN NOW /bmf",
	"THE BEST SERVER /bmf",
	"E-GIRLS UNITE /bmf",
	"FUN TIMES ONLY /bmf",
	"HOT CHATS /bmf",
	"DISCORD ADVENTURE /bmf",
	"ROBLOX BESTIES /bmf",
	"E-GIRL LOVERS /bmf",
	"PREMIUM SERVER /bmf",
	"BEST FRIENDS /bmf",
	"GIRL POWER /bmf",
	"JOIN THE FUN /bmf",
	"TOP E-GIRLS /bmf",
	"AMAZING DISCORD /bmf",
	"ROBLOX PARTY /bmf",
	"E-GIRL CENTRAL /bmf",
	"BEST PLACE /bmf",
	"CHAT WITH GIRLS /bmf",
	"ULTIMATE FUN /bmf",
	"DISCORD GOALS /bmf",
	"HOT ROBLOX /bmf",
	"E-GIRLS FOR DAYS /bmf",
	"BEST SERVER EVER /bmf",
	"JOIN DISCORD /bmf",
	"GIRL CHATS /bmf",
	"ROBLOX SOCIAL /bmf",
	"THE /bmf EXPERIENCE",
	"E-GIRL PARADISE /bmf",
	"FRIENDLY SERVER /bmf",
	"BEST E-GIRL HUB /bmf",
	"DISCORD MAGIC /bmf",
	"ROBLOX GIRLS /bmf",
	"JOIN FOR GOOD TIMES /bmf",
	"TOP COMMUNITY /bmf",
	"E-GIRLS AND MORE /bmf",
	"BEST IN ROBLOX /bmf",
	"SERVER OF DREAMS /bmf",
	"HOT AND FUN /bmf",
	"DONT MISS OUT /bmf"
}

local radius = 10 -- circle radius
local height = 5  -- studs in the air

while true do
	-- Get valid random target player
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
	
	-- Pick random base message + 3 random letters (as in your example)
	local baseMsg = messages[math.random(1, #messages)]
	local randomLetters = string.char(math.random(65,90)) .. string.char(math.random(65,90)) .. string.char(math.random(65,90))
	local finalMsg = baseMsg .. " " .. randomLetters
	
	-- Send the advertisement in chat
	SayMessageRequest:FireServer(finalMsg, "All")
	
	-- Orbit around the target for exactly 5 seconds
	local startTime = tick()
	while tick() - startTime < 5 do
		local targetHrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
		if not targetHrp then break end
		
		local elapsed = tick() - startTime
		local theta = elapsed * 2 -- spins ~1 full circle every 3 seconds
		
		local offset = Vector3.new(math.cos(theta) * radius, height, math.sin(theta) * radius)
		local newPos = targetHrp.Position + offset
		
		-- Face the target while spinning
		local cf = CFrame.lookAt(newPos, targetHrp.Position)
		hrp.CFrame = cf
		
		task.wait(0.016) -- smooth 60 FPS
	end
end
