local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local cameraConnection = nil
local currentCharacter = nil

-- Smoothness settings (lower = smoother / slower turn)
local SHIFTLOCK_SMOOTHNESS = 0.05     -- 0.05 = very smooth & buttery
local FIRSTPERSON_SMOOTHNESS = 0.12   -- slightly faster in FP feels more natural

local function isFirstPerson()
    if not currentCharacter then return false end
    local head = currentCharacter:FindFirstChild("Head")
    if not head then return false end
    return (Camera.CFrame.Position - head.Position).Magnitude < 1.5
end

local function updateCameraAndControls()
    if not currentCharacter then return end
    
    local head = currentCharacter:FindFirstChild("Head")
    local humanoid = currentCharacter:FindFirstChild("Humanoid")
    local root = currentCharacter:FindFirstChild("HumanoidRootPart")
    
    if not head or not humanoid or not root then return end
    
    local inFirstPerson = isFirstPerson()
    
    if inFirstPerson then
        -- ── FIRST PERSON ───────────────────────────────────────
        Camera.CameraSubject = humanoid
        Camera.CameraType = Enum.CameraType.Custom
        
        -- Force head to follow camera direction (fixes the main bug)
        if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
            humanoid.AutoRotate = false
            
            local camLook = Camera.CFrame.LookVector
            local horizontalLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
            
            if horizontalLook.Magnitude > 0.01 then
                local targetCFrame = CFrame.new(root.Position, root.Position + horizontalLook)
                root.CFrame = root.CFrame:Lerp(targetCFrame, FIRSTPERSON_SMOOTHNESS)
                
                -- Optional: slight neck tilt (very subtle - comment out if unwanted)
                -- local up = camLook:Cross(Vector3.new(0,1,0)).Unit:Cross(camLook)
                -- head.CFrame = CFrame.new(head.Position, head.Position + camLook) * CFrame.Angles(-0.08, 0, 0)
            end
        else
            humanoid.AutoRotate = true
        end
        
    else
        -- ── THIRD PERSON ───────────────────────────────────────
        Camera.CameraSubject = head
        Camera.CameraType = Enum.CameraType.Follow
        
        -- Ultra-smooth shiftlock turning
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
end

local function setupCharacter(character)
    if not character then return end
    currentCharacter = character
    
    -- Wait for critical parts
    character:WaitForChild("Head", 8)
    character:WaitForChild("Humanoid", 8)
    character:WaitForChild("HumanoidRootPart", 8)
    
    if cameraConnection then
        cameraConnection:Disconnect()
        cameraConnection = nil
    end
    
    cameraConnection = RunService.RenderStepped:Connect(updateCameraAndControls)
    
    print("✅ Head Camera v5 LOADED – First Person looking fixed + butter smooth shiftlock")
end

-- Initial character
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
    -- Don't nil CameraSubject – let Roblox handle it
end)
