if _G.TriggerbotLoaded then
    return
end
_G.TriggerbotLoaded = true

if not game:IsLoaded() then
    game.Loaded:Wait()
end

print("✅ Triggerbot Auto-Loaded! (Reinject enabled)")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

_G.triggerbot = true
local isClicked = false

-- Better target detection (fixes original bugs)
local function getHumanoid(target)
    if not target then return nil, nil end
    local parent = target.Parent
    if not parent then return nil, nil end
    
    local humanoid = parent:FindFirstChildOfClass("Humanoid")
    if humanoid then
        return humanoid, parent
    end
    
    if parent.Parent then
        humanoid = parent.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid then
            return humanoid, parent.Parent
        end
    end
    return nil, nil
end

-- Main triggerbot loop (fixed & improved)
RunService.RenderStepped:Connect(function()
    if not _G.triggerbot then
        if not isClicked then
            mouse1release()
            isClicked = true
        end
        return
    end
    
    local target = mouse.Target
    local humanoid, humParent = getHumanoid(target)
    
    if humanoid 
       and humanoid.Health >= 1 
       and humParent 
       and humParent.Name ~= player.Name 
       and humParent ~= player.Character then
        
        mouse1press()
        isClicked = false
    elseif not isClicked then
        mouse1release()
        isClicked = true
    end
end)

-- Handle respawn (mouse refresh)
player.CharacterAdded:Connect(function()
    task.wait(0.5)
    mouse = player:GetMouse()
end)

-- Toggle function (you can call _G.ToggleTriggerbot() in console)
_G.ToggleTriggerbot = function()
    _G.triggerbot = not _G.triggerbot
    print("🔫 Triggerbot is now " .. (_G.triggerbot and "ENABLED ✅" or "DISABLED ❌"))
end

-- Hotkey: Press T to toggle (works in most executors)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.T then
        _G.ToggleTriggerbot()
    end
end)

-- =====================================================
-- AUTO-REINJECT / AUTO-LOAD ON REJOIN OR NEW GAME
-- (Nuclear fix from Vanta Universal + Infinite Yield style)
-- =====================================================
local function QueueAutoReinject()
    -- Full self-contained script source (no external URL needed)
    local scriptSource = [[
if _G.TriggerbotLoaded then return end
_G.TriggerbotLoaded = true
if not game:IsLoaded() then game.Loaded:Wait() end
print("✅ Triggerbot Auto-Loaded! (Reinject enabled)")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

_G.triggerbot = true
local isClicked = false

local function getHumanoid(target)
    if not target then return nil, nil end
    local parent = target.Parent
    if not parent then return nil, nil end
    local humanoid = parent:FindFirstChildOfClass("Humanoid")
    if humanoid then return humanoid, parent end
    if parent.Parent then
        humanoid = parent.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid then return humanoid, parent.Parent end
    end
    return nil, nil
end

RunService.RenderStepped:Connect(function()
    if not _G.triggerbot then
        if not isClicked then
            mouse1release()
            isClicked = true
        end
        return
    end
    local target = mouse.Target
    local humanoid, humParent = getHumanoid(target)
    if humanoid and humanoid.Health >= 1 and humParent and humParent.Name ~= player.Name and humParent ~= player.Character then
        mouse1press()
        isClicked = false
    elseif not isClicked then
        mouse1release()
        isClicked = true
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    mouse = player:GetMouse()
end)

_G.ToggleTriggerbot = function()
    _G.triggerbot = not _G.triggerbot
    print("🔫 Triggerbot is now " .. (_G.triggerbot and "ENABLED ✅" or "DISABLED ❌"))
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.T then
        _G.ToggleTriggerbot()
    end
end)
    ]]
    
    local queuedCode = 'loadstring([[' .. scriptSource .. ']])()'
    
    pcall(function()
        local qtp = syn and syn.queue_on_teleport
            or queue_on_teleport
            or (fluxus and fluxus.queue_on_teleport)
            or (getgenv and getgenv().queue_on_teleport)
        
        if qtp then
            qtp(queuedCode)
            print("🚀 Auto-reinject queued! Will auto-load on rejoin or new game.")
        else
            print("⚠️  queue_on_teleport not found. Put this script in your executor's autoexec folder for full auto-load.")
        end
    end)
end

QueueAutoReinject()
