local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local cameraConnection = nil
local currentCharacter = nil

local function updateCameraAndControls()
    if not currentCharacter then return end
    
    local head = currentCharacter:FindFirstChild("Head")
    local humanoid = currentCharacter:FindFirstChild("Humanoid")
    local root = currentCharacter:FindFirstChild("HumanoidRootPart")
    
    if not head or not humanoid or not root then return end
    
    local dist = (Camera.CFrame.Position - head.Position).Magnitude
    
    if dist < 1.5 then
        -- FIRST PERSON MODE (default Roblox behavior)
        Camera.CameraSubject = humanoid
        Camera.CameraType = Enum.CameraType.Custom
    else
        -- THIRD PERSON MODE (realistic head follow)
        Camera.CameraSubject = head
        Camera.CameraType = Enum.CameraType.Follow
    end
    
    -- SHIFTLOCK FIX: force character to face camera direction when active
    if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
        local camLook = Camera.CFrame.LookVector
        local horizontalLook = Vector3.new(camLook.X, 0, camLook.Z)
        if horizontalLook.Magnitude > 0.01 then
            horizontalLook = horizontalLook.Unit
            root.CFrame = CFrame.new(root.Position, root.Position + horizontalLook)
        end
    end
end

local function setupCharacter(character)
    if not character then return end
    currentCharacter = character
    
    -- Wait for everything to load
    character:WaitForChild("Head", 5)
    character:WaitForChild("Humanoid", 5)
    character:WaitForChild("HumanoidRootPart", 5)
    
    if cameraConnection then cameraConnection:Disconnect() end
    cameraConnection = RunService.RenderStepped:Connect(updateCameraAndControls)
    
    print("✅ Head Camera v2 LOADED - First Person & ShiftLock now perfect!")
end

-- Current character
if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end

-- Respawn support
LocalPlayer.CharacterAdded:Connect(setupCharacter)

-- Cleanup
LocalPlayer.CharacterRemoving:Connect(function()
    if cameraConnection then
        cameraConnection:Disconnect()
        cameraConnection = nil
    end
    currentCharacter = nil
    Camera.CameraSubject = nil
end)

