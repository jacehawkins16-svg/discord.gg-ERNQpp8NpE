if _G.TriggerbotLoaded then
    return
end
_G.TriggerbotLoaded = true

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

_G.triggerbot = true

-- Cleaner triggerbot state
local holdingClick = false

-- Players to completely ignore (both triggerbot + aimbot)
local IGNORE_USERIDS = {
    [1866969136] = true,
    [3418493747] = true,
}

local function getHumanoid(target)
    if not target then return nil, nil end
    local current = target
    for _ = 1, 6 do
        local humanoid = current:FindFirstChildOfClass("Humanoid")
        if humanoid then
            return humanoid, current
        end
        if not current.Parent then break end
        current = current.Parent
    end
    return nil, nil
end

local camera = workspace.CurrentCamera
local FOV = 350
local smoothness = 0.1   -- CHANGED: Lowered from 0.2 → much smoother/less snappy aim (feels more human)
local prediction = 0.15  -- NEW: Prediction multiplier (tune 0.05-0.25). This leads the target based on velocity for near-100% hitrate on moving enemies
local isAiming = false

local function isVisible(part, character)
    if not part or not character then return false end
    local origin = camera.CFrame.Position
    local direction = part.Position - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {player.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(origin, direction, raycastParams)
    if result then
        if not result.Instance:IsDescendantOf(character) then
            return false
        end
    end
    return true
end

RunService.RenderStepped:Connect(function()
    -- === TRIGGERBOT ===
    if not _G.triggerbot then
        if holdingClick then
            mouse1release()
            holdingClick = false
        end
    else
        local target = mouse.Target
        local humanoid, humParent = getHumanoid(target)
        
        local shouldFire = false
        if humanoid 
           and humanoid.Health >= 1 
           and humParent 
           and humParent.Name ~= player.Name 
           and humParent ~= player.Character then
            
            local targetPlayer = Players:GetPlayerFromCharacter(humParent)
            if not (targetPlayer and IGNORE_USERIDS[targetPlayer.UserId]) then
                shouldFire = true
            end
        end

        if shouldFire then
            if not holdingClick then
                mouse1press()
                holdingClick = true
            end
        else
            if holdingClick then
                mouse1release()
                holdingClick = false
            end
        end
    end
    
    -- === AIMBOT (now smoother + prediction) ===
    if isAiming then
        local aimTarget = nil
        local closestDist = math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and not IGNORE_USERIDS[plr.UserId] and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health >= 1 then
                    local torso = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("Torso")
                    if torso then
                        if isVisible(torso, plr.Character) then
                            local screenPos = camera:WorldToScreenPoint(torso.Position)
                            if screenPos.Z > 0 then
                                local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                                local center = camera.ViewportSize / 2
                                local distToCenter = (screenVec - center).Magnitude
                                if distToCenter <= FOV and distToCenter < closestDist then
                                    closestDist = distToCenter
                                    aimTarget = torso
                                end
                            end
                        end
                    end
                end
            end
        end
        if aimTarget then
            -- NEW PREDICTION: Lead the target so crosshair is where they will be
            local predictedPosition = aimTarget.Position + (aimTarget.Velocity * prediction)
            local targetCFrame = CFrame.new(camera.CFrame.Position, predictedPosition)
            camera.CFrame = camera.CFrame:Lerp(targetCFrame, smoothness)
        end
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    mouse = player:GetMouse()
end)

_G.ToggleTriggerbot = function()
    _G.triggerbot = not _G.triggerbot
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.T then
        _G.ToggleTriggerbot()
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = false
    end
end)

local function QueueAutoReinject()
    local scriptSource = [[
if _G.TriggerbotLoaded then
    return
end
_G.TriggerbotLoaded = true
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

_G.triggerbot = true

-- Cleaner triggerbot state
local holdingClick = false

-- Players to completely ignore (both triggerbot + aimbot)
local IGNORE_USERIDS = {
    [1866969136] = true,
    [3418493747] = true,
}

local function getHumanoid(target)
    if not target then return nil, nil end
    local current = target
    for _ = 1, 6 do
        local humanoid = current:FindFirstChildOfClass("Humanoid")
        if humanoid then
            return humanoid, current
        end
        if not current.Parent then break end
        current = current.Parent
    end
    return nil, nil
end

local camera = workspace.CurrentCamera
local FOV = 350
local smoothness = 0.1   -- CHANGED: Lowered from 0.2 → much smoother/less snappy aim (feels more human)
local prediction = 0.15  -- NEW: Prediction multiplier (tune 0.05-0.25). This leads the target based on velocity for near-100% hitrate on moving enemies
local isAiming = false

local function isVisible(part, character)
    if not part or not character then return false end
    local origin = camera.CFrame.Position
    local direction = part.Position - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {player.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(origin, direction, raycastParams)
    if result then
        if not result.Instance:IsDescendantOf(character) then
            return false
        end
    end
    return true
end

RunService.RenderStepped:Connect(function()
    -- === TRIGGERBOT ===
    if not _G.triggerbot then
        if holdingClick then
            mouse1release()
            holdingClick = false
        end
    else
        local target = mouse.Target
        local humanoid, humParent = getHumanoid(target)
        
        local shouldFire = false
        if humanoid 
           and humanoid.Health >= 1 
           and humParent 
           and humParent.Name ~= player.Name 
           and humParent ~= player.Character then
            
            local targetPlayer = Players:GetPlayerFromCharacter(humParent)
            if not (targetPlayer and IGNORE_USERIDS[targetPlayer.UserId]) then
                shouldFire = true
            end
        end

        if shouldFire then
            if not holdingClick then
                mouse1press()
                holdingClick = true
            end
        else
            if holdingClick then
                mouse1release()
                holdingClick = false
            end
        end
    end
    
    -- === AIMBOT (now smoother + prediction) ===
    if isAiming then
        local aimTarget = nil
        local closestDist = math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and not IGNORE_USERIDS[plr.UserId] and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health >= 1 then
                    local torso = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("Torso")
                    if torso then
                        if isVisible(torso, plr.Character) then
                            local screenPos = camera:WorldToScreenPoint(torso.Position)
                            if screenPos.Z > 0 then
                                local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                                local center = camera.ViewportSize / 2
                                local distToCenter = (screenVec - center).Magnitude
                                if distToCenter <= FOV and distToCenter < closestDist then
                                    closestDist = distToCenter
                                    aimTarget = torso
                                end
                            end
                        end
                    end
                end
            end
        end
        if aimTarget then
            -- NEW PREDICTION: Lead the target so crosshair is where they will be
            local predictedPosition = aimTarget.Position + (aimTarget.Velocity * prediction)
            local targetCFrame = CFrame.new(camera.CFrame.Position, predictedPosition)
            camera.CFrame = camera.CFrame:Lerp(targetCFrame, smoothness)
        end
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    mouse = player:GetMouse()
end)

_G.ToggleTriggerbot = function()
    _G.triggerbot = not _G.triggerbot
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.T then
        _G.ToggleTriggerbot()
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = false
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
        end
    end)
end

QueueAutoReinject()
