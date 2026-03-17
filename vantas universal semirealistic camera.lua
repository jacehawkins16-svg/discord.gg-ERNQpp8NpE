local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local cameraConnection = nil
local currentCharacter = nil

local function forceHeadCamera()
    if not currentCharacter then return end
    
    local head = currentCharacter:FindFirstChild("Head")
    if head then
        Camera.CameraSubject = head
        Camera.CameraType = Enum.CameraType.Follow   -- realistic follow distance + mouse look
        -- Camera.CameraType = Enum.CameraType.Attach -- uncomment this line for "glued to head" mode
    end
end

local function setupCharacter(character)
    if not character then return end
    currentCharacter = character
    
    -- Wait for Head to load
    character:WaitForChild("Head", 5)
    
    -- Start forcing every frame
    if cameraConnection then cameraConnection:Disconnect() end
    cameraConnection = RunService.RenderStepped:Connect(forceHeadCamera)
    
    print("✅ Head Camera ACTIVATED - now following your head every frame")
end

-- Apply to current character
if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end

-- Auto-apply on respawn/death
LocalPlayer.CharacterAdded:Connect(setupCharacter)

-- Clean up when character is removed
LocalPlayer.CharacterRemoving:Connect(function()
    if cameraConnection then
        cameraConnection:Disconnect()
        cameraConnection = nil
    end
    currentCharacter = nil
    Camera.CameraSubject = nil
end)
