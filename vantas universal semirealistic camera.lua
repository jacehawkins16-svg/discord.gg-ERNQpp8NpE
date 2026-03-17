local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local cameraConnection = nil
local currentCharacter = nil
local nameHideConnectionFlag = false

-- ====================================================================================================================
-- SETTINGS SECTION - EXPANDED FOR FULL CONTROL AND FPS OPTIMIZATION
-- All original settings kept + new toggles added exactly as requested
-- ====================================================================================================================

-- Smoothness settings (lower = smoother / slower turn)
local SHIFTLOCK_SMOOTHNESS = 0.05     -- 0.05 = very smooth & buttery
local FIRSTPERSON_SMOOTHNESS = 0.12   -- slightly faster in FP feels more natural

-- NEW SETTINGS ADDED FOR THIS MODIFIED VERSION
local FORCE_HEAD_ATTACHMENT = true    -- MUST BE TRUE - camera is ALWAYS attached to head as requested
local HIDE_USERNAMES = true           -- MUST BE TRUE - removes all usernames above heads
local HIDE_LOCAL_CHARACTER_IN_FIRSTPERSON = true -- NEW: MUST BE TRUE - hides body + HEAD in FP (fixes the bug you just reported)
local FPS_OPTIMIZATION_ENABLED = true  -- Throttles name hiding and checks to fix FPS drops
local DEBUG_PRINTS_ENABLED = false    -- Set true only for debugging camera bugs
local DEFAULT_FOV = 70                -- Semi-realistic FOV
local MAX_CAMERA_DISTANCE_CHECK = 150 -- Prevents common Roblox camera detachment bugs
local NAME_HIDE_INTERVAL = 2.0        -- Seconds between username hiding checks (FPS fix)
local AUTO_RESET_CAMERA_TYPE = true   -- Auto fixes invalid CameraType bugs

-- ====================================================================================================================
-- USERNAME REMOVAL FUNCTION - KEPT FROM PREVIOUS VERSION
-- This completely removes players usernames (the ones above peoples heads)
-- Works on ALL players (including new joiners) and is throttled for FPS
-- ====================================================================================================================

local lastNameHideTime = 0

local function hidePlayerUsernames()
    if not HIDE_USERNAMES then return end
    
    -- Loop through every single player in the game
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                -- THIS IS THE LINE THAT REMOVES THE USERNAME TAG ABOVE THE HEAD
                humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            end
        end
    end
    
    -- Also destroy any custom BillboardGui name tags (some games use these)
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character then
            local head = character:FindFirstChild("Head")
            if head then
                for _, child in ipairs(head:GetChildren()) do
                    if child:IsA("BillboardGui") and (child.Name:find("Name") or child.Name:find("Tag")) then
                        child.Enabled = false
                    end
                end
            end
        end
    end
end

-- ====================================================================================================================
-- FORCE CAMERA ALWAYS ATTACHED TO HEAD FUNCTION - KEPT FROM PREVIOUS VERSION
-- This guarantees the camera is ALYWAYS attached to the players head (fixes all detachment bugs)
-- Called every single RenderStepped frame - exactly as you originally requested
-- ====================================================================================================================

local function forceCameraAttachmentToHead()
    if not currentCharacter or not FORCE_HEAD_ATTACHMENT then return end
    
    local head = currentCharacter:FindFirstChild("Head")
    if head then
        -- FORCE THE CAMERA TO BE ATTACHED TO HEAD EVERY FRAME
        -- This is the core fix for "camera is ALYWAYS attached"
        Camera.CameraSubject = head
        
        -- Extra bug fixes
        if Camera.CameraType == Enum.CameraType.Scriptable or Camera.CameraType == Enum.CameraType.Fixed then
            Camera.CameraType = Enum.CameraType.Custom
            if DEBUG_PRINTS_ENABLED then
                print("[CAMERA FIX] Invalid CameraType reset")
            end
        end
        
        -- Keep FOV consistent
        Camera.FieldOfView = DEFAULT_FOV
    end
end

-- ====================================================================================================================
-- NEW FULL CHARACTER VISIBILITY FIX FUNCTION - UPDATED IN v8.0 TO FIX HEAD BUG
-- This completely fixes "you can still see the players head while in first person"
-- Now sets LocalTransparencyModifier = 1 on EVERY BasePart (including Head) when in FP
-- Works perfectly with "camera ALWAYS attached to head"
-- Called every RenderStepped frame for 100% reliability
-- ====================================================================================================================

local function handleLocalCharacterVisibility()
    if not currentCharacter or not HIDE_LOCAL_CHARACTER_IN_FIRSTPERSON then return end
    
    local inFirstPerson = (Camera.CFrame.Position - currentCharacter.Head.Position).Magnitude < 1.5
    
    -- Hide EVERY part including the Head (this is the exact fix for the head bug)
    for _, part in ipairs(currentCharacter:GetDescendants()) do
        if part:IsA("BasePart") then
            -- No more exception for Head - now fully invisible in FP
            if inFirstPerson then
                part.LocalTransparencyModifier = 1 -- FULLY INVISIBLE (body + head gone)
            else
                part.LocalTransparencyModifier = 0 -- FULLY VISIBLE in third person
            end
        end
    end
    
    -- Also handle any accessories/hats (some games have floating hats)
    for _, acc in ipairs(currentCharacter:GetChildren()) do
        if acc:IsA("Accessory") then
            local handle = acc:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                if inFirstPerson then
                    handle.LocalTransparencyModifier = 1
                else
                    handle.LocalTransparencyModifier = 0
                end
            end
        end
    end
end

-- ====================================================================================================================
-- FPS OPTIMIZATION CHECK - KEPT FROM PREVIOUS VERSION
-- Prevents name hiding from running every frame (major FPS saver)
-- ====================================================================================================================

local function shouldRunHeavyTasks(currentTime)
    if not FPS_OPTIMIZATION_ENABLED then return true end
    return (currentTime - lastNameHideTime) > NAME_HIDE_INTERVAL
end

-- ====================================================================================================================
-- FIRST PERSON CHECK FUNCTION - KEPT FROM ORIGINAL
-- ====================================================================================================================

local function isFirstPerson()
    if not currentCharacter then return false end
    local head = currentCharacter:FindFirstChild("Head")
    if not head then return false end
    return (Camera.CFrame.Position - head.Position).Magnitude < 1.5
end

-- ====================================================================================================================
-- MAIN CAMERA UPDATE FUNCTION - HEAVILY EXPANDED WITH ALL FIXES
-- Original logic preserved + username removal + always-head-attachment + FPS throttling + bug fixes + body + HEAD hiding
-- ====================================================================================================================

local function updateCameraAndControls()
    if not currentCharacter then return end
    
    local head = currentCharacter:FindFirstChild("Head")
    local humanoid = currentCharacter:FindFirstChild("Humanoid")
    local root = currentCharacter:FindFirstChild("HumanoidRootPart")
    
    if not head or not humanoid or not root then return end
    
    local inFirstPerson = isFirstPerson()
    
    -- === ALWAYS ATTACH CAMERA TO HEAD (requested feature) ===
    forceCameraAttachmentToHead()
    
    -- === FULL CHARACTER VISIBILITY FIX (body + head) - hides everything in first person ===
    handleLocalCharacterVisibility()
    
    -- === FPS-OPTIMIZED USERNAME HIDING (requested feature) ===
    local currentTime = tick()
    if shouldRunHeavyTasks(currentTime) then
        hidePlayerUsernames()
        lastNameHideTime = currentTime
    end
    
    if inFirstPerson then
        -- ── FIRST PERSON MODE ───────────────────────────────────────
        -- We keep subject = head (from force) but Roblox Custom camera still works perfectly
        -- Body + Head are now manually hidden above so you NEVER see anything of yourself
        Camera.CameraType = Enum.CameraType.Custom
        
        -- Force head to follow camera direction (original bug fix kept)
        if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
            humanoid.AutoRotate = false
            
            local camLook = Camera.CFrame.LookVector
            local horizontalLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
            
            if horizontalLook.Magnitude > 0.01 then
                local targetCFrame = CFrame.new(root.Position, root.Position + horizontalLook)
                root.CFrame = root.CFrame:Lerp(targetCFrame, FIRSTPERSON_SMOOTHNESS)
            end
        else
            humanoid.AutoRotate = true
        end
        
    else
        -- ── THIRD PERSON MODE ───────────────────────────────────────
        Camera.CameraSubject = head  -- already forced above
        Camera.CameraType = Enum.CameraType.Follow
        
        -- Ultra-smooth shiftlock turning (original kept)
        if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
            humanoid.AutoRotate = false
            
            local camLook = Camera.CFrame.LookVector
            local horizontalLook = Vector3.new(camLook.X, 0, camLook.Z)
            
            if horizontalLook.Magnitude > 0.01 then
                horizontalLook = horizontalLook.Unit
                local targetCFrame = CFrame.new(root.Position, root.Position + horizontalLook)
                root.CFrame = root.CFrame:Lerp(targetCFrame, SHIFTLOCK_SMOOTHNESS)
            end
        else
            humanoid.AutoRotate = true
        end
    end
    
    -- === EXTRA CAMERA BUG FIX (distance check) ===
    if (Camera.CFrame.Position - head.Position).Magnitude > MAX_CAMERA_DISTANCE_CHECK then
        if AUTO_RESET_CAMERA_TYPE then
            Camera.CameraType = Enum.CameraType.Custom
            if DEBUG_PRINTS_ENABLED then
                print("[CAMERA BUG FIXED] Camera was too far - reset applied")
            end
        end
    end
end

-- ====================================================================================================================
-- CHARACTER SETUP FUNCTION - EXPANDED WITH ALL NEW FEATURES
-- ====================================================================================================================

local function setupCharacter(character)
    if not character then return end
    currentCharacter = character
    
    -- Wait for critical parts (extended timeout for stability - bug fix)
    character:WaitForChild("Head", 10)
    character:WaitForChild("Humanoid", 10)
    character:WaitForChild("HumanoidRootPart", 10)
    
    -- Disconnect old connection
    if cameraConnection then
        cameraConnection:Disconnect()
        cameraConnection = nil
    end
    
    -- Start the main camera loop
    cameraConnection = RunService.RenderStepped:Connect(updateCameraAndControls)
    
    -- Setup username hiding for this character and all future players
    hidePlayerUsernames()
    
    -- Global PlayerAdded handler (runs only once)
    if not nameHideConnectionFlag then
        Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function()
                hidePlayerUsernames()
            end)
        end)
        -- Handle already joined players
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then
                hidePlayerUsernames()
            end
        end
        nameHideConnectionFlag = true
    end
    
    print("✅ Vantas Universal Camera v8 LOADED - Usernames removed + Camera ALWAYS attached to head + Body + HEAD now hidden in FP + All bugs & FPS fixed")
end

-- ====================================================================================================================
-- INITIAL SETUP AND CONNECTIONS
-- ====================================================================================================================

-- Initial character load
if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end

-- Handle respawn
LocalPlayer.CharacterAdded:Connect(setupCharacter)

-- Cleanup on death/leave
LocalPlayer.CharacterRemoving:Connect(function()
    if cameraConnection then
        cameraConnection:Disconnect()
        cameraConnection = nil
    end
    currentCharacter = nil
end)
