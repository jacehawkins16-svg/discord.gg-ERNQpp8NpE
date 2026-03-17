
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
end)

-- ====================================================================================================
-- ULTRA-REALISTIC SHADERS v3.0 – WAY MORE REALISM + ULTRA-SMOOTH SHADING & LIGHTING
-- 20+ layered effects now, softer realistic shadows, enhanced diffuse/specular for buttery gradients,
-- extra bloom/color/sun layers, dynamic lerped adjustments for perfectly smooth lighting transitions
-- Professionally re-tuned from real cinematography + top 2026 Roblox cinematic games
-- Future tech + maximum built-in post-processing = photorealistic RTX-style look
-- ====================================================================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Lighting = game:GetService("Lighting")

-- ── MASTER SHADER CONFIG TABLE v3.0 (ultra-smooth & hyper-realistic) ─────────────────────────────
-- Every value professionally re-calibrated for natural smooth shading, soft realistic shadows,
-- buttery light gradients, and cinematic depth without harsh edges
local SHADER_CONFIG = {
    -- Core Lighting (Future tech + smooth shading upgrades)
    TECHNOLOGY = Enum.Technology.Future,
    GLOBAL_SHADOWS = true,
    SHADOW_SOFTNESS = 0.45,                             -- SMOOTH realistic shadow edges (0.45 = perfect balance of detail + softness)
    BRIGHTNESS = 1.92,                                  -- Natural balanced daylight exposure
    AMBIENT = Color3.fromRGB(72, 58, 48),               -- Warm, smooth fill light for realistic shading
    OUTDOOR_AMBIENT = Color3.fromRGB(38, 28, 52),       -- Deep but smooth outdoor ambient
    COLOR_SHIFT_BOTTOM = Color3.fromRGB(15, 3, 22),     -- Subtle ground shading
    COLOR_SHIFT_TOP = Color3.fromRGB(255, 145, 25),     -- Rich golden-hour sky influence
    CLOCK_TIME = 6.7,
    FOG_COLOR = Color3.fromRGB(94, 76, 106),
    FOG_END = 100000,
    FOG_START = 0,
    EXPOSURE_COMPENSATION = 0.19,                       -- Smoother highlight/shadow roll-off
    ENV_DIFFUSE_SCALE = 1.15,                           -- Boosted for ultra-smooth diffuse shading
    ENV_SPECULAR_SCALE = 1.05,                          -- Enhanced specular for natural glossy gradients

    -- Bloom Layers (5 layers now – smoother falloff + extra highlight layer)
    BLOOM1_INTENSITY = 0.09,    BLOOM1_THRESHOLD = 0.05,    BLOOM1_SIZE = 95,
    BLOOM2_INTENSITY = 0.29,    BLOOM2_THRESHOLD = 0.18,    BLOOM2_SIZE = 52,
    BLOOM3_INTENSITY = 0.07,    BLOOM3_THRESHOLD = 0.12,    BLOOM3_SIZE = 28,
    BLOOM4_INTENSITY = 0.13,    BLOOM4_THRESHOLD = 0.03,    BLOOM4_SIZE = 68,
    BLOOM5_INTENSITY = 0.11,    BLOOM5_THRESHOLD = 0.08,    BLOOM5_SIZE = 45,   -- NEW smooth highlight bloom

    -- Blur for SUN GLARE ONLY (still subtle max 3.5)
    SUN_GLARE_BLUR_MAX_SIZE = 3.5,
    SUN_GLARE_DOT_THRESHOLD = 0.75,
    BASE_BLUR_SIZE = 0.8,

    -- Color Correction Layers (6 layers now – ultra-smooth cinematic grading)
    COLOR1_SATURATION = 0.05,   COLOR1_CONTRAST = 0.0,   COLOR1_TINT = Color3.fromRGB(255, 224, 219),
    COLOR2_SATURATION = -0.2,   COLOR2_CONTRAST = 0.0,   COLOR2_TINT = Color3.fromRGB(255, 232, 215),
    COLOR3_SATURATION = -0.3,   COLOR3_CONTRAST = 0.1,   COLOR3_TINT = Color3.fromRGB(235, 214, 204),
    COLOR4_SATURATION = 0.1,    COLOR4_CONTRAST = -0.05, COLOR4_TINT = Color3.fromRGB(240, 220, 200),
    COLOR5_SATURATION = 0.0,    COLOR5_CONTRAST = 0.08,  COLOR5_TINT = Color3.fromRGB(255, 245, 230),
    COLOR6_SATURATION = -0.1,   COLOR6_CONTRAST = 0.05,  COLOR6_TINT = Color3.fromRGB(250, 240, 220), -- NEW final smooth lift

    -- Sun Rays (3 layers now – smoother volumetric god rays)
    SUNRAYS1_INTENSITY = 0.05,
    SUNRAYS2_INTENSITY = 0.03,
    SUNRAYS3_INTENSITY = 0.02,

    -- Atmosphere (2 layers – slightly increased density for richer smooth haze)
    ATMOSPHERE1_DENSITY = 0.35,  ATMOSPHERE1_HAZE = 1.0,  ATMOSPHERE1_GLARE = 0.5,
    ATMOSPHERE2_DENSITY = 0.18,  ATMOSPHERE2_HAZE = 0.45, ATMOSPHERE2_GLARE = 0.32,

    -- Depth of Field (slightly wider focus for smoother cinematic bokeh)
    DOF_FOCUS_DISTANCE = 10,
    DOF_IN_FOCUS_RADIUS = 25,
    DOF_NEAR_INTENSITY = 0.5,
    DOF_FAR_INTENSITY = 0.5,
}

-- Apply core Lighting settings (with smooth shading upgrades)
Lighting.Technology = SHADER_CONFIG.TECHNOLOGY
Lighting.GlobalShadows = SHADER_CONFIG.GLOBAL_SHADOWS
Lighting.ShadowSoftness = SHADER_CONFIG.SHADOW_SOFTNESS
Lighting.Brightness = SHADER_CONFIG.BRIGHTNESS
Lighting.Ambient = SHADER_CONFIG.AMBIENT
Lighting.OutdoorAmbient = SHADER_CONFIG.OUTDOOR_AMBIENT
Lighting.ColorShift_Bottom = SHADER_CONFIG.COLOR_SHIFT_BOTTOM
Lighting.ColorShift_Top = SHADER_CONFIG.COLOR_SHIFT_TOP
Lighting.ClockTime = SHADER_CONFIG.CLOCK_TIME
Lighting.FogColor = SHADER_CONFIG.FOG_COLOR
Lighting.FogEnd = SHADER_CONFIG.FOG_END
Lighting.FogStart = SHADER_CONFIG.FOG_START
Lighting.ExposureCompensation = SHADER_CONFIG.EXPOSURE_COMPENSATION
Lighting.EnvironmentDiffuseScale = SHADER_CONFIG.ENV_DIFFUSE_SCALE
Lighting.EnvironmentSpecularScale = SHADER_CONFIG.ENV_SPECULAR_SCALE

-- Layer 1-5: Bloom Effects (5 stacked layers for ultra-smooth light bloom & natural gradients)
local Bloom1 = Instance.new("BloomEffect")
Bloom1.Name = "UltraBloomPrimary"
Bloom1.Intensity = SHADER_CONFIG.BLOOM1_INTENSITY
Bloom1.Threshold = SHADER_CONFIG.BLOOM1_THRESHOLD
Bloom1.Size = SHADER_CONFIG.BLOOM1_SIZE
Bloom1.Enabled = true
Bloom1.Parent = Lighting

local Bloom2 = Instance.new("BloomEffect")
Bloom2.Name = "SecondaryGlow"
Bloom2.Intensity = SHADER_CONFIG.BLOOM2_INTENSITY
Bloom2.Threshold = SHADER_CONFIG.BLOOM2_THRESHOLD
Bloom2.Size = SHADER_CONFIG.BLOOM2_SIZE
Bloom2.Enabled = true
Bloom2.Parent = Lighting

local Bloom3 = Instance.new("BloomEffect")
Bloom3.Name = "SubtleHighlightBloom"
Bloom3.Intensity = SHADER_CONFIG.BLOOM3_INTENSITY
Bloom3.Threshold = SHADER_CONFIG.BLOOM3_THRESHOLD
Bloom3.Size = SHADER_CONFIG.BLOOM3_SIZE
Bloom3.Enabled = true
Bloom3.Parent = Lighting

local Bloom4 = Instance.new("BloomEffect")
Bloom4.Name = "LensFlareSimulation"
Bloom4.Intensity = SHADER_CONFIG.BLOOM4_INTENSITY
Bloom4.Threshold = SHADER_CONFIG.BLOOM4_THRESHOLD
Bloom4.Size = SHADER_CONFIG.BLOOM4_SIZE
Bloom4.Enabled = true
Bloom4.Parent = Lighting

local Bloom5 = Instance.new("BloomEffect")  -- NEW layer for ultra-smooth specular highlights
Bloom5.Name = "SmoothHighlightBloom"
Bloom5.Intensity = SHADER_CONFIG.BLOOM5_INTENSITY
Bloom5.Threshold = SHADER_CONFIG.BLOOM5_THRESHOLD
Bloom5.Size = SHADER_CONFIG.BLOOM5_SIZE
Bloom5.Enabled = true
Bloom5.Parent = Lighting

-- Layer 6-7: Blur Effects
local BlurBase = Instance.new("BlurEffect")
BlurBase.Name = "BaseSoftness"
BlurBase.Size = SHADER_CONFIG.BASE_BLUR_SIZE
BlurBase.Enabled = true
BlurBase.Parent = Lighting

local BlurSunGlare = Instance.new("BlurEffect")
BlurSunGlare.Name = "SunGlareDynamicBlur"
BlurSunGlare.Size = SHADER_CONFIG.BASE_BLUR_SIZE
BlurSunGlare.Enabled = true
BlurSunGlare.Parent = Lighting

-- Layer 8-13: Color Correction Effects (6 stacked layers for ultra-smooth cinematic grading)
local Color1 = Instance.new("ColorCorrectionEffect")
Color1.Name = "WarmGoldenGrade"
Color1.Saturation = SHADER_CONFIG.COLOR1_SATURATION
Color1.Contrast = SHADER_CONFIG.COLOR1_CONTRAST
Color1.TintColor = SHADER_CONFIG.COLOR1_TINT
Color1.Enabled = true
Color1.Parent = Lighting

local Color2 = Instance.new("ColorCorrectionEffect")
Color2.Name = "NaturalFilmGrade"
Color2.Saturation = SHADER_CONFIG.COLOR2_SATURATION
Color2.Contrast = SHADER_CONFIG.COLOR2_CONTRAST
Color2.TintColor = SHADER_CONFIG.COLOR2_TINT
Color2.Enabled = true
Color2.Parent = Lighting

local Color3 = Instance.new("ColorCorrectionEffect")
Color3.Name = "TakayamaCinematic"
Color3.Saturation = SHADER_CONFIG.COLOR3_SATURATION
Color3.Contrast = SHADER_CONFIG.COLOR3_CONTRAST
Color3.TintColor = SHADER_CONFIG.COLOR3_TINT
Color3.Enabled = true
Color3.Parent = Lighting

local Color4 = Instance.new("ColorCorrectionEffect")
Color4.Name = "SubtleWarmBoost"
Color4.Saturation = SHADER_CONFIG.COLOR4_SATURATION
Color4.Contrast = SHADER_CONFIG.COLOR4_CONTRAST
Color4.TintColor = SHADER_CONFIG.COLOR4_TINT
Color4.Enabled = true
Color4.Parent = Lighting

local Color5 = Instance.new("ColorCorrectionEffect")
Color5.Name = "FinalHighlightLift"
Color5.Saturation = SHADER_CONFIG.COLOR5_SATURATION
Color5.Contrast = SHADER_CONFIG.COLOR5_CONTRAST
Color5.TintColor = SHADER_CONFIG.COLOR5_TINT
Color5.Enabled = true
Color5.Parent = Lighting

local Color6 = Instance.new("ColorCorrectionEffect")  -- NEW final smooth grading layer
Color6.Name = "UltraSmoothFinalGrade"
Color6.Saturation = SHADER_CONFIG.COLOR6_SATURATION
Color6.Contrast = SHADER_CONFIG.COLOR6_CONTRAST
Color6.TintColor = SHADER_CONFIG.COLOR6_TINT
Color6.Enabled = true
Color6.Parent = Lighting

-- Layer 14-16: Sun Rays (3 layers for smoother volumetric god rays)
local SunRays1 = Instance.new("SunRaysEffect")
SunRays1.Name = "PrimaryGodRays"
SunRays1.Intensity = SHADER_CONFIG.SUNRAYS1_INTENSITY
SunRays1.Enabled = true
SunRays1.Parent = Lighting

local SunRays2 = Instance.new("SunRaysEffect")
SunRays2.Name = "SecondaryVolumetricRays"
SunRays2.Intensity = SHADER_CONFIG.SUNRAYS2_INTENSITY
SunRays2.Enabled = true
SunRays2.Parent = Lighting

local SunRays3 = Instance.new("SunRaysEffect")  -- NEW smoother third layer
SunRays3.Name = "TertiarySoftRays"
SunRays3.Intensity = SHADER_CONFIG.SUNRAYS3_INTENSITY
SunRays3.Enabled = true
SunRays3.Parent = Lighting

-- Layer 17-18: Atmosphere
local Atmosphere1 = Instance.new("Atmosphere")
Atmosphere1.Name = "PrimaryAtmosphere"
Atmosphere1.Density = SHADER_CONFIG.ATMOSPHERE1_DENSITY
Atmosphere1.Offset = 0.25
Atmosphere1.Color = Color3.fromRGB(199, 199, 199)
Atmosphere1.Decay = Color3.fromRGB(199, 199, 199)
Atmosphere1.Glare = SHADER_CONFIG.ATMOSPHERE1_GLARE
Atmosphere1.Haze = SHADER_CONFIG.ATMOSPHERE1_HAZE
Atmosphere1.Parent = Lighting

local Atmosphere2 = Instance.new("Atmosphere")
Atmosphere2.Name = "SecondaryScattering"
Atmosphere2.Density = SHADER_CONFIG.ATMOSPHERE2_DENSITY
Atmosphere2.Offset = 0.15
Atmosphere2.Color = Color3.fromRGB(210, 210, 210)
Atmosphere2.Decay = Color3.fromRGB(210, 210, 210)
Atmosphere2.Glare = SHADER_CONFIG.ATMOSPHERE2_GLARE
Atmosphere2.Haze = SHADER_CONFIG.ATMOSPHERE2_HAZE
Atmosphere2.Parent = Lighting

-- Layer 19-20: Depth of Field
local DepthOfField1 = Instance.new("DepthOfFieldEffect")
DepthOfField1.Name = "PrimaryDOF"
DepthOfField1.FocusDistance = SHADER_CONFIG.DOF_FOCUS_DISTANCE
DepthOfField1.InFocusRadius = SHADER_CONFIG.DOF_IN_FOCUS_RADIUS
DepthOfField1.NearIntensity = SHADER_CONFIG.DOF_NEAR_INTENSITY
DepthOfField1.FarIntensity = SHADER_CONFIG.DOF_FAR_INTENSITY
DepthOfField1.Enabled = true
DepthOfField1.Parent = Lighting

local DepthOfField2 = Instance.new("DepthOfFieldEffect")
DepthOfField2.Name = "SecondaryBokeh"
DepthOfField2.FocusDistance = SHADER_CONFIG.DOF_FOCUS_DISTANCE + 5
DepthOfField2.InFocusRadius = SHADER_CONFIG.DOF_IN_FOCUS_RADIUS * 1.2
DepthOfField2.NearIntensity = SHADER_CONFIG.DOF_NEAR_INTENSITY * 0.8
DepthOfField2.FarIntensity = SHADER_CONFIG.DOF_FAR_INTENSITY * 0.8
DepthOfField2.Enabled = true
DepthOfField2.Parent = Lighting

-- Sky
local TropicSky = Instance.new("Sky")
TropicSky.Name = "TropicGolden"
TropicSky.SkyboxUp = "http://www.roblox.com/asset/?id=169210149"
TropicSky.SkyboxLf = "http://www.roblox.com/asset/?id=169210133"
TropicSky.SkyboxBk = "http://www.roblox.com/asset/?id=169210090"
TropicSky.SkyboxFt = "http://www.roblox.com/asset/?id=169210121"
TropicSky.SkyboxDn = "http://www.roblox.com/asset/?id=169210108"
TropicSky.SkyboxRt = "http://www.roblox.com/asset/?id=169210143"
TropicSky.StarCount = 100
TropicSky.Parent = Lighting

-- Dynamic sun direction calculator
local function calculateSunDirection()
    local timeOfDay = Lighting.ClockTime
    local timeFraction = timeOfDay / 24
    local sunAzimuth = (timeFraction * math.pi * 2) + (math.pi / 2)
    local sunElevation = math.sin((timeOfDay - 6) * (math.pi / 12)) * (math.pi / 3)
    local dirX = math.cos(sunElevation) * math.cos(sunAzimuth)
    local dirY = math.sin(sunElevation)
    local dirZ = math.cos(sunElevation) * math.sin(sunAzimuth)
    return Vector3.new(dirX, dirY, dirZ).Unit
end

-- Dynamic shader update loop (now with smooth lerping for buttery lighting transitions)
local lastBloomBoost = 0
local lastGlareSize = SHADER_CONFIG.BASE_BLUR_SIZE

local shaderConnection = RunService.RenderStepped:Connect(function()
    local camLook = Camera.CFrame.LookVector
    local sunDir = calculateSunDirection()
    local dotProduct = camLook:Dot(sunDir)
    
    -- Ultra-smooth sun glare blur (still never blinds)
    if dotProduct > SHADER_CONFIG.SUN_GLARE_DOT_THRESHOLD then
        local glareAmount = (dotProduct - SHADER_CONFIG.SUN_GLARE_DOT_THRESHOLD) * 8
        local targetSize = math.min(SHADER_CONFIG.SUN_GLARE_BLUR_MAX_SIZE, glareAmount)
        lastGlareSize = lastGlareSize + (targetSize - lastGlareSize) * 0.15  -- smooth lerp
        BlurSunGlare.Size = lastGlareSize
        BlurSunGlare.Enabled = true
    else
        lastGlareSize = lastGlareSize + (SHADER_CONFIG.BASE_BLUR_SIZE - lastGlareSize) * 0.2
        BlurSunGlare.Size = lastGlareSize
        BlurSunGlare.Enabled = true
    end
    
    -- Smooth dynamic bloom boost when facing sun
    local bloomBoost = math.max(0, dotProduct * 0.08)
    local targetBloom = SHADER_CONFIG.BLOOM4_INTENSITY + bloomBoost
    lastBloomBoost = lastBloomBoost + (targetBloom - lastBloomBoost) * 0.12  -- buttery lerp
    Bloom4.Intensity = lastBloomBoost
    
    -- Keep everything perfectly synced
end)

print("✅ ULTRA-REALISTIC SHADERS v3.0 LOADED – WAY MORE REALISM + ULTRA-SMOOTH SHADING & LIGHTING!")
print("✅ Softer realistic shadows, 5 bloom / 6 color / 3 sunray layers, dynamic lerped transitions, photorealistic gradients!")
print("✅ Combined with buttery camera – full cinematic RTX-style experience in Roblox!")
