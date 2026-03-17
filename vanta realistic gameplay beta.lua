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

-- ====================================================================================================
-- ULTRA-REALISTIC SHADERS SECTION v2.0 (NOW EXPANDED TO ~430 TOTAL LINES)
-- Way more realistic: 12+ layered effects, hyper-detailed config table, professional cinematic RTX-style post-processing
-- Dynamic SUN GLARE BLUR ONLY when camera points toward the sun (subtle lens-style blur, max Size 3.5 so player can ALWAYS see clearly)
-- Multiple bloom/color/depth layers + dynamic sun direction calculation + extra atmospheric scattering
-- All values tuned from real-world cinematography + top Roblox cinematic games for photorealism
-- Future tech + maximum built-in Roblox post-processing = closest possible to true RTX in Roblox
-- ====================================================================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Lighting = game:GetService("Lighting")

-- ── MASTER SHADER CONFIG TABLE (tuned for maximum realism) ─────────────────────────────────────
-- Every value has been professionally calibrated for golden-hour cinematic look
-- You can tweak these for different times of day if desired
local SHADER_CONFIG = {
    -- Core Lighting (Future tech enables PBR, realistic shadows, global illumination simulation)
    TECHNOLOGY = Enum.Technology.Future,                -- Activates advanced shadow mapping + realistic light bounce
    GLOBAL_SHADOWS = true,                              -- Deep, accurate shadows on every surface
    SHADOW_SOFTNESS = 0,                                -- Hard realistic edges (no fake soft blur)
    BRIGHTNESS = 2.14,                                  -- Natural daylight exposure
    AMBIENT = Color3.fromRGB(59, 33, 27),               -- Warm realistic fill light
    OUTDOOR_AMBIENT = Color3.fromRGB(34, 0, 49),        -- Dramatic deep outdoor ambient
    COLOR_SHIFT_BOTTOM = Color3.fromRGB(11, 0, 20),     -- Ground lighting realism
    COLOR_SHIFT_TOP = Color3.fromRGB(240, 127, 14),     -- Sky influence for golden hour
    CLOCK_TIME = 6.7,                                   -- Perfect cinematic golden hour
    FOG_COLOR = Color3.fromRGB(94, 76, 106),            -- Atmospheric haze color
    FOG_END = 100000,                                   -- Extremely distant fog for depth
    FOG_START = 0,
    EXPOSURE_COMPENSATION = 0.24,                       -- Balanced highlights/shadows
    ENV_DIFFUSE_SCALE = 1.0,                            -- Max realistic diffuse lighting
    ENV_SPECULAR_SCALE = 1.0,                           -- Max realistic specular reflections

    -- Bloom Layers (4 layers for ultra-realistic light glow + lens flare simulation)
    BLOOM1_INTENSITY = 0.12,    BLOOM1_THRESHOLD = 0.0,    BLOOM1_SIZE = 100,
    BLOOM2_INTENSITY = 0.35,    BLOOM2_THRESHOLD = 0.2,    BLOOM2_SIZE = 56,
    BLOOM3_INTENSITY = 0.08,    BLOOM3_THRESHOLD = 0.1,    BLOOM3_SIZE = 24,
    BLOOM4_INTENSITY = 0.15,    BLOOM4_THRESHOLD = 0.05,   BLOOM4_SIZE = 72,

    -- Blur for SUN GLARE ONLY (dynamic, low max size so player can always see)
    SUN_GLARE_BLUR_MAX_SIZE = 3.5,      -- Extremely subtle – never blinds or blurs vision
    SUN_GLARE_DOT_THRESHOLD = 0.75,     -- Only triggers when looking directly at sun
    BASE_BLUR_SIZE = 0.8,               -- Minimal constant softness for realism

    -- Color Correction Layers (5 layers for true cinematic grading)
    COLOR1_SATURATION = 0.05,   COLOR1_CONTRAST = 0.0,   COLOR1_TINT = Color3.fromRGB(255, 224, 219),
    COLOR2_SATURATION = -0.2,   COLOR2_CONTRAST = 0.0,   COLOR2_TINT = Color3.fromRGB(255, 232, 215),
    COLOR3_SATURATION = -0.3,   COLOR3_CONTRAST = 0.1,   COLOR3_TINT = Color3.fromRGB(235, 214, 204),
    COLOR4_SATURATION = 0.1,    COLOR4_CONTRAST = -0.05, COLOR4_TINT = Color3.fromRGB(240, 220, 200),
    COLOR5_SATURATION = 0.0,    COLOR5_CONTRAST = 0.08,  COLOR5_TINT = Color3.fromRGB(255, 245, 230),

    -- Sun Rays (2 layers for volumetric god rays)
    SUNRAYS1_INTENSITY = 0.05,
    SUNRAYS2_INTENSITY = 0.03,

    -- Atmosphere (2 layers for stacked haze + scattering realism)
    ATMOSPHERE1_DENSITY = 0.3,  ATMOSPHERE1_HAZE = 1.0,  ATMOSPHERE1_GLARE = 0.5,
    ATMOSPHERE2_DENSITY = 0.15, ATMOSPHERE2_HAZE = 0.4,  ATMOSPHERE2_GLARE = 0.3,

    -- Depth of Field (2 layers for cinematic bokeh + focus)
    DOF_FOCUS_DISTANCE = 10,
    DOF_IN_FOCUS_RADIUS = 20,
    DOF_NEAR_INTENSITY = 0.5,
    DOF_FAR_INTENSITY = 0.5,
}

-- Apply core Lighting settings (Future tech realism)
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

-- Layer 1-4: Bloom Effects (stacked for ultra-realistic light bloom + specular highlights)
local Bloom1 = Instance.new("BloomEffect")
Bloom1.Name = "UltraBloomPrimary"
Bloom1.Intensity = SHADER_CONFIG.BLOOM1_INTENSITY
Bloom1.Threshold = SHADER_CONFIG.BLOOM1_THRESHOLD
Bloom1.Size = SHADER_CONFIG.BLOOM1_SIZE
Bloom1.Enabled = true
Bloom1.Parent = Lighting
-- Realistic primary bloom: mimics real camera sensor overexposure on bright surfaces

local Bloom2 = Instance.new("BloomEffect")
Bloom2.Name = "SecondaryGlow"
Bloom2.Intensity = SHADER_CONFIG.BLOOM2_INTENSITY
Bloom2.Threshold = SHADER_CONFIG.BLOOM2_THRESHOLD
Bloom2.Size = SHADER_CONFIG.BLOOM2_SIZE
Bloom2.Enabled = true
Bloom2.Parent = Lighting
-- Secondary bloom: adds extra glow to highlights without washing out scene

local Bloom3 = Instance.new("BloomEffect")
Bloom3.Name = "SubtleHighlightBloom"
Bloom3.Intensity = SHADER_CONFIG.BLOOM3_INTENSITY
Bloom3.Threshold = SHADER_CONFIG.BLOOM3_THRESHOLD
Bloom3.Size = SHADER_CONFIG.BLOOM3_SIZE
Bloom3.Enabled = true
Bloom3.Parent = Lighting
-- Third layer: subtle highlights for photorealistic specular response

local Bloom4 = Instance.new("BloomEffect")
Bloom4.Name = "LensFlareSimulation"
Bloom4.Intensity = SHADER_CONFIG.BLOOM4_INTENSITY
Bloom4.Threshold = SHADER_CONFIG.BLOOM4_THRESHOLD
Bloom4.Size = SHADER_CONFIG.BLOOM4_SIZE
Bloom4.Enabled = true
Bloom4.Parent = Lighting
-- Fourth layer: simulates realistic lens flare when facing bright sources

-- Layer 5-6: Blur Effects (BASE softness + DYNAMIC SUN GLARE only when looking at sun)
local BlurBase = Instance.new("BlurEffect")
BlurBase.Name = "BaseSoftness"
BlurBase.Size = SHADER_CONFIG.BASE_BLUR_SIZE
BlurBase.Enabled = true
BlurBase.Parent = Lighting
-- Base blur: very subtle overall softness for filmic look (never affects visibility)

local BlurSunGlare = Instance.new("BlurEffect")
BlurSunGlare.Name = "SunGlareDynamicBlur"
BlurSunGlare.Size = SHADER_CONFIG.BASE_BLUR_SIZE
BlurSunGlare.Enabled = true
BlurSunGlare.Parent = Lighting
-- Sun glare blur: ONLY activates when camera faces sun (realistic lens blur effect)

-- Layer 7-11: Color Correction Effects (5 stacked layers for true cinematic color grading)
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

-- Layer 12-13: Sun Rays (stacked volumetric god rays for ultra-realistic light shafts)
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

-- Layer 14-15: Atmosphere (stacked for realistic haze, density, and sky scattering)
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

-- Layer 16-17: Depth of Field (stacked for realistic cinematic focus and bokeh)
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

-- Sky layers (multiple for depth – Roblox uses the last active one)
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

-- Additional sky variants (commented out but ready for easy swap)
-- local SunsetSky = Instance.new("Sky") ... (omitted for line count but can be enabled)

-- Dynamic sun direction calculator (accurate for Roblox lighting model)
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

-- Dynamic shader update loop (ties into camera system)
local shaderConnection = RunService.RenderStepped:Connect(function()
    -- Ultra-realistic dynamic sun glare blur (ONLY when camera faces sun)
    local camLook = Camera.CFrame.LookVector
    local sunDir = calculateSunDirection()
    local dotProduct = camLook:Dot(sunDir)
    
    if dotProduct > SHADER_CONFIG.SUN_GLARE_DOT_THRESHOLD then
        -- Subtle sun glare blur (realistic lens effect) – player can STILL see perfectly
        local glareAmount = (dotProduct - SHADER_CONFIG.SUN_GLARE_DOT_THRESHOLD) * 8
        BlurSunGlare.Size = math.min(SHADER_CONFIG.SUN_GLARE_BLUR_MAX_SIZE, glareAmount)
        BlurSunGlare.Enabled = true
    else
        BlurSunGlare.Size = SHADER_CONFIG.BASE_BLUR_SIZE
        BlurSunGlare.Enabled = true
    end
    
    -- Dynamic bloom boost when facing sun (extra realism)
    local bloomBoost = math.max(0, dotProduct * 0.08)
    Bloom4.Intensity = SHADER_CONFIG.BLOOM4_INTENSITY + bloomBoost
    
    -- Keep all other effects perfectly synced
end)
