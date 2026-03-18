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
local isClicked = false

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

local camera = workspace.CurrentCamera
local FOV = 350
local smoothness = 0.2
local isAiming = false

local function isVisible(head, character)
    if not head or not character then return false end
    local origin = camera.CFrame.Position
    local direction = head.Position - origin
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
    if not _G.triggerbot then
        if not isClicked then
            mouse1release()
            isClicked = true
        end
    else
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
    end
    
    if isAiming then
        local aimTarget = nil
        local closestDist = math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health >= 1 then
                    local head = plr.Character:FindFirstChild("Head")
                    if head then
                        if isVisible(head, plr.Character) then
                            local screenPos = camera:WorldToScreenPoint(head.Position)
                            if screenPos.Z > 0 then
                                local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                                local center = camera.ViewportSize / 2
                                local distToCenter = (screenVec - center).Magnitude
                                if distToCenter <= FOV and distToCenter < closestDist then
                                    closestDist = distToCenter
                                    aimTarget = head
                                end
                            end
                        end
                    end
                end
            end
        end
        if aimTarget then
            local targetCFrame = CFrame.new(camera.CFrame.Position, aimTarget.Position)
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
local isClicked = false

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

local camera = workspace.CurrentCamera
local FOV = 350
local smoothness = 0.2
local isAiming = false

local function isVisible(head, character)
    if not head or not character then return false end
    local origin = camera.CFrame.Position
    local direction = head.Position - origin
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
    if not _G.triggerbot then
        if not isClicked then
            mouse1release()
            isClicked = true
        end
    else
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
    end
    
    if isAiming then
        local aimTarget = nil
        local closestDist = math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health >= 1 then
                    local head = plr.Character:FindFirstChild("Head")
                    if head then
                        if isVisible(head, plr.Character) then
                            local screenPos = camera:WorldToScreenPoint(head.Position)
                            if screenPos.Z > 0 then
                                local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                                local center = camera.ViewportSize / 2
                                local distToCenter = (screenVec - center).Magnitude
                                if distToCenter <= FOV and distToCenter < closestDist then
                                    closestDist = distToCenter
                                    aimTarget = head
                                end
                            end
                        end
                    end
                end
            end
        end
        if aimTarget then
            local targetCFrame = CFrame.new(camera.CFrame.Position, aimTarget.Position)
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
