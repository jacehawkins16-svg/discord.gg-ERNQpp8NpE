-- Vanta Universal - NUCLEAR RESET EDITION (March 2026) - FULLY FIXED
-- Fixes applied:
-- • Game freezing every short period → Replaced old raycast triggerbot with lightweight mouse.Target version from triggerbot.lua (no more expensive 12000-stud raycast every frame)
-- • Performance issues → Removed heavy per-frame raycast + optimized triggerbot + cursor now enforced safely every frame
-- • Changed triggerbot to exact logic from triggerbot.lua (safe, self-hit protected, holds while on target)
-- • Custom crosshair/preset not working → Now enforced every RenderStepped frame (games often reset mouse.Icon)
-- • Noclip buggy / inconsistent on/off → Completely rewritten with Stepped connection + dynamic part tracking (works on respawn, tools, new parts, perfect toggle)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Vanta Universal [Beta] | discord.gg-ERNQpp8NpE", "DarkTheme")

-- Tabs & Sections (unchanged)
local CombatTab    = Window:NewTab("Combat")
local VisualsTab   = Window:NewTab("Visuals [BETA]")
local MovementTab  = Window:NewTab("Movement")
local AFKTab       = Window:NewTab("Auto [BETA]")
local TeleportsTab = Window:NewTab("Teleports")
local CameraTab    = Window:NewTab("Camera")

local TriggerSection = CombatTab:NewSection("Triggerbot")
local AimbotSection  = CombatTab:NewSection("Aimbot")
local MiscSection    = CombatTab:NewSection("Misc")

local FOVSection       = VisualsTab:NewSection("Aimbot FOV Circle")
local BoxSection       = VisualsTab:NewSection("2D Boxes")
local TracerSection    = VisualsTab:NewSection("Tracers")
local NameSection      = VisualsTab:NewSection("Player Names")
local HealthSection    = VisualsTab:NewSection("Health Display")
local ChamsSection     = VisualsTab:NewSection("Chams / Wall Glow")
local CursorSection    = VisualsTab:NewSection("Custom Cursor Crosshair")

local SpeedSection            = MovementTab:NewSection("Speed Hack")
local NoclipSection           = MovementTab:NewSection("Noclip")
local FlySection              = MovementTab:NewSection("Fly")
local JumpSection             = MovementTab:NewSection("Jump Hacks")
local AdvancedMovementSection = MovementTab:NewSection("Advanced Movement")

local AutoWinSection   = AFKTab:NewSection("Auto Win / Kill")
local AntiAFKSection   = AFKTab:NewSection("Anti-AFK / Anti-Kick")
local FutureAFKSection = AFKTab:NewSection("More AFK Features (Coming Soon)")

local PlayerTPSection = TeleportsTab:NewSection("Player Teleports")
local ClickTPSection  = TeleportsTab:NewSection("Click Teleport")

local CameraFOVSection = CameraTab:NewSection("FOV Changer")

-- Services
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local UserInputService  = game:GetService("UserInputService")
local TeleportService   = game:GetService("TeleportService")

local lp     = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse  = lp:GetMouse()

-- ==================== AUTO REINJECT ON REJOIN (NUCLEAR FIX) ====================
local function queueReinject()
    local url = "https://jacehawkins16-svg.github.io/discord.gg-ERNQpp8NpE/vantas%20universal%20pvp.lua"
    local code = 'loadstring(game:HttpGet("' .. url .. '"))()'
    
    pcall(function()
        if syn and syn.queue_on_teleport then
            syn.queue_on_teleport(code)
        elseif queue_on_teleport then
            queue_on_teleport(code)
        elseif getgenv and getgenv().queue_on_teleport then
            getgenv().queue_on_teleport(code)
        elseif fluxus and fluxus.queue_on_teleport then
            fluxus.queue_on_teleport(code)
        end
    end)
end
-- ==================== END AUTO REINJECT ====================

-- Settings Table (unchanged)
local Settings = {
    Triggerbot = { Enabled = false },
    Aimbot = {
        Enabled       = false,
        FOV           = 650,
        ShowCircle    = false,
        AimPart       = "HumanoidRootPart",
        CircleColor   = Color3.fromRGB(220,220,255),
        CircleThick   = 2,
        CircleTrans   = 0.9,
        VisibleCheck  = false,
        Smooth        = 1
    },
    ESP = {
        Boxes =   {Enabled = false, Color = Color3.fromRGB(255,60,60),   Thickness = 1.4},
        Tracers = {Enabled = false, Color = Color3.fromRGB(255, 0, 0),   Thickness = 1.2},
        Names =   {Enabled = false, Color = Color3.fromRGB(255,255,255), Size = 14},
        Health =  {Enabled = false, Color = Color3.fromRGB(80, 255, 80), Size = 13},
        Chams =   {Enabled = false, Outline = Color3.fromRGB(255,90,90), Fill = Color3.fromRGB(255,120,120), FillTrans = 0.7}
    },
    Movement = {
        Enabled = false,
        Value   = 58,
        Default = 16,
        Noclip  = false,
        Fly     = false,
        FlySpeed = 80,
        InfJump = false,
        Bhop    = false,
        CFrameSpeed = false,
        CFrameSpeedValue = 25,
        CustomJumpPower = false,
        JumpPower = 50
    },
    AFK = {
        AutoWinEnabled = false
    },
    CursorCrosshair = {
        Enabled = false,
        Preset  = "Default",
        CustomID = ""
    },
    FOVChanger = {
        Enabled = false,
        Value   = 70
    },
    AntiAFK = {
        Enabled = false
    },
    ClickTeleport = {
        Enabled = false
    },
    Invisible = {
        Enabled = false
    }
}

-- Persistent variables
local defaultFOV = camera.FieldOfView or 70
local defaultCursor = mouse.Icon
local tpTargetName = ""
local isAntiAFKActive = false
local lastClickTime     = 0
local currentTarget     = nil
local targetSwitchTime  = 0
local autoWinRunning    = false
local triggerClicked    = false   -- for new triggerbot

-- Noclip (NEW FIXED VERSION)
local noclipConn = nil
local savedCanCollide = {}

local function startNoclip()
    if noclipConn then return end
    noclipConn = RunService.Stepped:Connect(function()
        local char = lp.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if not savedCanCollide[part] then
                    savedCanCollide[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
    for part, orig in pairs(savedCanCollide) do
        if part and part.Parent then
            part.CanCollide = orig
        end
    end
    savedCanCollide = {}
end

-- FOV Circle
local fov = Drawing.new("Circle")
fov.Thickness    = Settings.Aimbot.CircleThick
fov.NumSides     = 90
fov.Radius       = Settings.Aimbot.FOV
fov.Color        = Settings.Aimbot.CircleColor
fov.Transparency = Settings.Aimbot.CircleTrans
fov.Filled       = false
fov.Visible      = false

local espCache = {}

-- Cursor Presets (unchanged)
local CursorPresets = {
    ["Default"]      = "",
    ["Simple +"]     = "rbxassetid://1827745864",
    ["Medium Cross"] = "rbxassetid://4048495272",
    ["Small Dot"]    = "rbxassetid://1827745860",
    ["Glow Circle"]  = "rbxassetid://10891594364",
    ["Green Dot"]    = "rbxassetid://240080506",
    ["Hello Kitty"]  = "rbxassetid://11351620355",
    ["Meme Funny"]   = "rbxassetid://10868459554",
    ["Classic CB"]   = "rbxassetid://3024593464"
}

local function isEnemy(player) return true end

local function isVisible(targetPart, targetPlr)
    if not (targetPart and targetPlr and targetPlr.Character) then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {lp.Character or {}}
    rayParams.IgnoreWater = true

    local origin = camera.CFrame.Position
    local direction = targetPart.Position - origin
    local result = Workspace:Raycast(origin, direction, rayParams)

    if not result then return true end
    if result.Instance:IsDescendantOf(targetPlr.Character) then return true end
    return false
end

local function findClosest()
    local best, bestDist = nil, math.huge
    local mid = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    for _, p in Players:GetPlayers() do
        if p == lp or not p.Character or not isEnemy(p) then continue end

        local part = p.Character:FindFirstChild(Settings.Aimbot.AimPart)
        local hum  = p.Character:FindFirstChildOfClass("Humanoid")
        if not (part and hum and hum.Health > 0) then continue end

        local pos, vis = camera:WorldToViewportPoint(part.Position)
        if not vis then continue end

        local dist2d = (Vector2.new(pos.X, pos.Y) - mid).Magnitude
        if dist2d > Settings.Aimbot.FOV then continue end

        if Settings.Aimbot.VisibleCheck and not isVisible(part, p) then continue end

        local dist3d = (myRoot.Position - part.Position).Magnitude
        if dist3d < bestDist then
            bestDist = dist3d
            best = part
        end
    end
    return best
end

-- ESP SETUP (unchanged)
local function setupESPForPlayer(player)
    if player == lp then return end

    local function handleCharacter(char)
        if not char then return end

        if not espCache[player] then
            local boxLines = {}
            for i = 1,4 do
                local ln = Drawing.new("Line")
                ln.Transparency = 1
                ln.Visible = false
                table.insert(boxLines, ln)
            end

            local tr = Drawing.new("Line")
            tr.Transparency = 1
            tr.Visible = false

            local nameTxt = Drawing.new("Text")
            nameTxt.Center = true
            nameTxt.Outline = true
            nameTxt.OutlineColor = Color3.new(0,0,0)
            nameTxt.Visible = false

            local healthTxt = Drawing.new("Text")
            healthTxt.Center = true
            healthTxt.Outline = true
            healthTxt.OutlineColor = Color3.new(0,0,0)
            healthTxt.Visible = false

            local high = Instance.new("Highlight")
            high.Parent = game:GetService("CoreGui")
            high.Adornee = char
            high.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            high.Enabled = false

            espCache[player] = {
                box = boxLines,
                tracer = tr,
                name = nameTxt,
                health = healthTxt,
                chams = high
            }
        else
            if espCache[player].chams then
                espCache[player].chams.Adornee = char
            end
        end
    end

    player.CharacterAdded:Connect(handleCharacter)
    if player.Character then
        handleCharacter(player.Character)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    setupESPForPlayer(player)
end
Players.PlayerAdded:Connect(setupESPForPlayer)

-- Infinite Jump (unchanged)
UserInputService.JumpRequest:Connect(function()
    if Settings.Movement.InfJump and lp.Character then
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Click Teleport (unchanged)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if Settings.ClickTeleport.Enabled and input.UserInputType == Enum.UserInputType.MouseButton2 then
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local ray = camera:ViewportPointToRay(mouse.X, mouse.Y)
            local rp = RaycastParams.new()
            rp.FilterType = Enum.RaycastFilterType.Exclude
            rp.FilterDescendantsInstances = {lp.Character}
            rp.IgnoreWater = true

            local result = Workspace:Raycast(ray.Origin, ray.Direction * 5000, rp)
            if result then
                lp.Character.HumanoidRootPart.CFrame = CFrame.new(result.Position + Vector3.new(0, 4, 0))
            end
        end
    end
end)

-- Helper: find and equip first tool (unchanged)
local function equipFirstTool()
    if not lp.Character then return end
    local backpack = lp:FindFirstChild("Backpack")
    if not backpack then return end

    local alreadyEquipped = lp.Character:FindFirstChildWhichIsA("Tool")
    if alreadyEquipped then return end

    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            lp.Character.Humanoid:EquipTool(item)
            return
        end
    end
end

local function unequipCurrentTool()
    if not lp.Character then return end
    local tool = lp.Character:FindFirstChildWhichIsA("Tool")
    if tool then
        tool.Parent = lp:FindFirstChild("Backpack")
    end
end

-- AUTO WIN (unchanged)
local function startAutoWinLoop()
    if autoWinRunning then return end
    autoWinRunning = true
    task.spawn(function()
        while autoWinRunning and Settings.AFK.AutoWinEnabled do
            if not lp.Character then 
                task.wait(0.1)
                continue 
            end

            local root = lp.Character:FindFirstChild("HumanoidRootPart")
            if not root then 
                task.wait(0.1)
                continue 
            end

            local now = tick()

            if not lp.Character:FindFirstChildWhichIsA("Tool") then
                equipFirstTool()
            end

            if now - lastClickTime >= 0.1 then
                mouse1press()
                task.delay(0.015, mouse1release)
                lastClickTime = now
            end

            if now - targetSwitchTime >= 2 then
                local targets = {}
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= lp and p.Character and isEnemy(p) then
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            local leg = p.Character:FindFirstChild("LeftLowerLeg") 
                                     or p.Character:FindFirstChild("RightLowerLeg")
                                     or p.Character:FindFirstChild("LeftFoot")
                                     or p.Character:FindFirstChild("RightFoot")
                                     or p.Character:FindFirstChild("HumanoidRootPart")
                            if leg then
                                table.insert(targets, {leg = leg})
                            end
                        end
                    end
                end
                if #targets > 0 then
                    currentTarget = targets[math.random(1, #targets)]
                else
                    currentTarget = nil
                end
                targetSwitchTime = now
            end

            if currentTarget and currentTarget.leg and currentTarget.leg.Parent then
                local legCF = currentTarget.leg.CFrame
                local underPos = legCF.Position + Vector3.new(0, -3.8, 0)
                local rotation = legCF.Rotation * CFrame.Angles(math.rad(-90), math.rad(180), 0)
                root.CFrame = CFrame.new(underPos) * rotation
            end

            task.wait()
        end
        autoWinRunning = false
    end)
end

local function stopAutoWinLoop()
    autoWinRunning = false
    currentTarget = nil
    lastClickTime = 0
    targetSwitchTime = 0
    
    if lp.Character then
        local root = lp.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.Velocity = Vector3.new(0, 0, 0)
        end
    end
end

-- ==================== FIXED NOCLIP (dynamic, non-buggy) ====================
-- (functions defined above)
-- ==================== END FIXED NOCLIP ====================

-- Invisible exploit from invis v2.lua
local seatTeleportPosition = Vector3.new(-25.95, 400, 3537.55)
local voidLevelYThreshold = -50
local invis_transparency = 0.75
local isInvisibleEnabled = false

local function setCharacterTransparency(char, transparency)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = transparency
        end
    end
end

local function makeInvisible(char)
    setCharacterTransparency(char, invis_transparency)
    local humanoidRootPart = char:WaitForChild("HumanoidRootPart")
    local savedpos = humanoidRootPart.CFrame
    task.wait(0.05)
    pcall(function() char:MoveTo(seatTeleportPosition) end)
    task.wait(0.05)
    if not char:FindFirstChild("HumanoidRootPart") or char.HumanoidRootPart.Position.Y < voidLevelYThreshold then
        pcall(function() char:MoveTo(savedpos.Position) end)
        return
    end
    local Seat = Instance.new('Seat')
    Seat.Parent = workspace
    Seat.Anchored = false
    Seat.CanCollide = false
    Seat.Name = 'invischair'
    Seat.Transparency = 1
    Seat.Position = seatTeleportPosition
    local Weld = Instance.new("Weld")
    Weld.Part0 = Seat
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if torso then
        Weld.Part1 = torso
        Weld.Parent = Seat
        task.wait()
        pcall(function() Seat.CFrame = savedpos end)
    else
        Seat:Destroy()
    end
    char.DescendantAdded:Connect(function(desc)
        if isInvisibleEnabled and desc:IsA("BasePart") and desc.Name ~= "HumanoidRootPart" then
            desc.Transparency = invis_transparency
        end
    end)
    task.spawn(function()
        while task.wait(0.5) do
            if not isInvisibleEnabled then break end
            if not char or not char.Parent then break end
            setCharacterTransparency(char, invis_transparency)
        end
    end)
end

local function disableInvisible(char)
    if not char then return end
    setCharacterTransparency(char, 0)
    local seat = workspace:FindFirstChild("invischair")
    if seat then seat:Destroy() end
end

lp.CharacterAdded:Connect(function(char)
    if isInvisibleEnabled then
        makeInvisible(char)
    end
end)

-- ESP RENDER + ALL OTHER LOGIC
RunService.RenderStepped:Connect(function()
    -- NEW TRIGGERBOT (from triggerbot.lua - safe, no raycast, no self-hit, holds while on target)
    local isOnValidTarget = false
    if mouse.Target and lp.Character and not mouse.Target:IsDescendantOf(lp.Character) then
        local par = mouse.Target.Parent
        if par then
            local hum = par:FindFirstChildOfClass("Humanoid")
            if not hum and par.Parent then
                hum = par.Parent:FindFirstChildOfClass("Humanoid")
            end
            if hum and hum.Health >= 1 then
                isOnValidTarget = true
            end
        end
    end

    if isOnValidTarget and Settings.Triggerbot.Enabled then
        mouse1press()
        triggerClicked = false
    elseif Settings.Triggerbot.Enabled and not triggerClicked then
        mouse1release()
    elseif not Settings.Triggerbot.Enabled and isOnValidTarget then
        triggerClicked = true
    end

    -- FOV Changer
    if Settings.FOVChanger.Enabled then
        camera.FieldOfView = Settings.FOVChanger.Value
    else
        camera.FieldOfView = defaultFOV
    end

    -- FOV visual
    fov.Position      = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    fov.Radius        = Settings.Aimbot.FOV
    fov.Color         = Settings.Aimbot.CircleColor
    fov.Thickness     = Settings.Aimbot.CircleThick
    fov.Transparency  = Settings.Aimbot.CircleTrans
    fov.Visible       = Settings.Aimbot.Enabled and Settings.Aimbot.ShowCircle

    -- Aimbot
    if Settings.Aimbot.Enabled then
        local tgt = findClosest()
        if tgt then
            local goal = CFrame.lookAt(camera.CFrame.Position, tgt.Position)
            camera.CFrame = camera.CFrame:Lerp(goal, Settings.Aimbot.Smooth)
        end
    end

    -- Movement Hacks
    if lp.Character then
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        local root = lp.Character:FindFirstChild("HumanoidRootPart")

        if hum and root then
            hum.WalkSpeed = Settings.Movement.Enabled and Settings.Movement.Value or Settings.Movement.Default

            if Settings.Movement.Fly then
                hum.PlatformStand = true
                local moveDir = Vector3.new(0,0,0)
                local camCF = camera.CFrame
                if UserInputService:IsKeyDown(Enum.KeyCode.W)     then moveDir += camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S)     then moveDir -= camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A)     then moveDir -= camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D)     then moveDir += camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0,1,0) end

                if moveDir.Magnitude > 0 then
                    moveDir = moveDir.Unit * Settings.Movement.FlySpeed
                end
                root.Velocity = moveDir
            else
                hum.PlatformStand = false
            end

            if Settings.Movement.CFrameSpeed then
                local cfSpeed = Settings.Movement.CFrameSpeedValue
                local moveDir = Vector3.new(0,0,0)
                local camCF = camera.CFrame
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camCF.RightVector end

                if moveDir.Magnitude > 0 then
                    moveDir = moveDir.Unit * (cfSpeed / 40)
                    root.CFrame += moveDir
                end
            end

            hum.JumpPower = Settings.Movement.CustomJumpPower and Settings.Movement.JumpPower or 50

            if Settings.Movement.Bhop then
                if hum:GetState() ~= Enum.HumanoidStateType.Jumping and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                    hum.Jump = true
                end
            end
        end
    end

    -- ESP RENDER LOOP (unchanged)
    for _, player in Players:GetPlayers() do
        if player == lp then continue end

        local d = espCache[player]
        if not d then continue end

        local char = player.Character
        if not char then
            for _,ln in d.box do ln.Visible = false end
            d.tracer.Visible = false
            d.name.Visible = false
            d.health.Visible = false
            d.chams.Enabled = false
            continue
        end

        if d.chams.Adornee ~= char then
            d.chams.Adornee = char
        end

        local root = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChildOfClass("Humanoid")

        if not (root and hum and hum.Health > 0) then
            for _,ln in d.box do ln.Visible = false end
            d.tracer.Visible = false
            d.name.Visible = false
            d.health.Visible = false
            d.chams.Enabled = false
            continue
        end

        for _,ln in d.box do
            ln.Color = Settings.ESP.Boxes.Color
            ln.Thickness = Settings.ESP.Boxes.Thickness
        end
        d.tracer.Color     = Settings.ESP.Tracers.Color
        d.tracer.Thickness = Settings.ESP.Tracers.Thickness
        d.name.Color       = Settings.ESP.Names.Color
        d.name.Size        = Settings.ESP.Names.Size

        d.health.Color = Settings.ESP.Health.Color
        d.health.Size  = Settings.ESP.Health.Size

        d.chams.OutlineColor     = Settings.ESP.Chams.Outline
        d.chams.FillColor        = Settings.ESP.Chams.Fill
        d.chams.FillTransparency = Settings.ESP.Chams.FillTrans

        local top    = root.Position + Vector3.new(0, 3.4, 0)
        local bottom = root.Position - Vector3.new(0, 4.0, 0)
        local t2d, tvis = camera:WorldToViewportPoint(top)
        local b2d, bvis = camera:WorldToViewportPoint(bottom)

        if tvis and bvis then
            local h = math.abs(b2d.Y - t2d.Y)
            local w = h * 0.48

            local tl = Vector2.new(t2d.X - w/2, t2d.Y)
            local tr = Vector2.new(t2d.X + w/2, t2d.Y)
            local bl = Vector2.new(b2d.X - w/2, b2d.Y)
            local br = Vector2.new(b2d.X + w/2, b2d.Y)

            local bx = d.box
            bx[1].From = tl; bx[1].To = tr; bx[1].Visible = Settings.ESP.Boxes.Enabled
            bx[2].From = tr; bx[2].To = br; bx[2].Visible = Settings.ESP.Boxes.Enabled
            bx[3].From = br; bx[3].To = bl; bx[3].Visible = Settings.ESP.Boxes.Enabled
            bx[4].From = bl; bx[4].To = tl; bx[4].Visible = Settings.ESP.Boxes.Enabled

            d.tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
            d.tracer.To = Vector2.new(b2d.X, b2d.Y)
            d.tracer.Visible = Settings.ESP.Tracers.Enabled

            d.name.Text = player.Name
            d.name.Position = Vector2.new(t2d.X, t2d.Y - 22)
            d.name.Visible = Settings.ESP.Names.Enabled

            d.health.Text = "Health: " .. math.floor(hum.Health)
            d.health.Position = Vector2.new(t2d.X, t2d.Y - 38)
            d.health.Visible = Settings.ESP.Health.Enabled
        else
            for _,ln in d.box do ln.Visible = false end
            d.tracer.Visible = false
            d.name.Visible   = false
            d.health.Visible = false
        end

        d.chams.Enabled = Settings.ESP.Chams.Enabled
    end

    -- Enforce Custom Cursor every frame (fixes presets not applying / being reset by game)
    if Settings.CursorCrosshair.Enabled then
        local id = Settings.CursorCrosshair.CustomID ~= "" and Settings.CursorCrosshair.CustomID or (CursorPresets[Settings.CursorCrosshair.Preset] or "")
        if id ~= "" then
            mouse.Icon = id
        else
            mouse.Icon = defaultCursor
        end
    else
        mouse.Icon = defaultCursor
    end
end)

-- Cleanup (unchanged)
Players.PlayerRemoving:Connect(function(p)
    if espCache[p] then
        for _,l in espCache[p].box or {} do 
            if l then l:Remove() end 
        end
        if espCache[p].tracer then espCache[p].tracer:Remove() end
        if espCache[p].name   then espCache[p].name:Remove()   end
        if espCache[p].health then espCache[p].health:Remove() end
        if espCache[p].chams  then espCache[p].chams:Destroy() end
        espCache[p] = nil
    end
end)

-- ==================== UI CONTROLS ====================

-- Combat Tab
TriggerSection:NewToggle("Triggerbot", "Shoot when crosshair on valid target", function(v)
    Settings.Triggerbot.Enabled = v
end)

AimbotSection:NewToggle("Aimbot", "Lock onto closest in FOV", function(v)
    Settings.Aimbot.Enabled = v
end)

AimbotSection:NewSlider("FOV", "", 1400, 80, function(v)
    Settings.Aimbot.FOV = v
end)

AimbotSection:NewDropdown("Aim Part", "", {"Head","UpperTorso","HumanoidRootPart","LowerTorso"}, function(v)
    Settings.Aimbot.AimPart = v
end)

AimbotSection:NewToggle("Visible Check", "Only aim at players not behind walls", function(v)
    Settings.Aimbot.VisibleCheck = v
end)

AimbotSection:NewSlider("Smoothness", "100 = instant snap", 100, 0, function(v)
    Settings.Aimbot.Smooth = v / 100
end)

MiscSection:NewToggle("Invisible", "Makes you partially invisible using seat glitch", function(v)
    Settings.Invisible.Enabled = v
    isInvisibleEnabled = v
    local char = lp.Character
    if v then
        if char then
            makeInvisible(char)
        end
    else
        if char then
            disableInvisible(char)
        end
    end
end)

-- AFK Tab
AutoWinSection:NewToggle("Auto Win / Kill", "Loop TP under enemy feet + lay down facing up (180° turn) + auto click + auto-equip (OFF = REJOIN + REINJECT)", function(v)
    Settings.AFK.AutoWinEnabled = v
    
    if v then
        equipFirstTool()
        startAutoWinLoop()
    else
        stopAutoWinLoop()
        unequipCurrentTool()
        if lp.Character then
            lp.Character:BreakJoints()
        end
        
        queueReinject()
        task.wait(0.6)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
    end
end)

AntiAFKSection:NewToggle("Anti-AFK / Anti-Kick", "Prevents idle kicks (jump + spin every ~25s)", function(v)
    Settings.AntiAFK.Enabled = v
    if v and not isAntiAFKActive then
        isAntiAFKActive = true
        task.spawn(function()
            while isAntiAFKActive and Settings.AntiAFK.Enabled do
                task.wait(20 + math.random(5, 15))
                if lp.Character then
                    local hum = lp.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Jump = true end
                    
                    local root = lp.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(12), 0)
                    end
                end
            end
            isAntiAFKActive = false
        end)
    elseif not v then
        isAntiAFKActive = false
    end
end)

FutureAFKSection:NewLabel("More AFK features coming soon...")
FutureAFKSection:NewLabel("• Auto collect coins / orbs")
FutureAFKSection:NewLabel("• Auto farm in simulators")
FutureAFKSection:NewLabel("• Better anti-kick methods")

-- Visuals Tab
FOVSection:NewToggle("Show FOV Circle", "", function(v)
    Settings.Aimbot.ShowCircle = v
end)

FOVSection:NewColorPicker("Circle Color", "", Settings.Aimbot.CircleColor, function(c)
    Settings.Aimbot.CircleColor = c
end)

FOVSection:NewSlider("Thickness", "", 6, 1, function(v)
    Settings.Aimbot.CircleThick = v
end)

FOVSection:NewSlider("Transparency", "0 = solid", 10, 0, function(v)
    Settings.Aimbot.CircleTrans = v/10
end)

BoxSection:NewToggle("Boxes", "Draw 2D boxes", function(v)
    Settings.ESP.Boxes.Enabled = v
end)

BoxSection:NewColorPicker("Color", "", Settings.ESP.Boxes.Color, function(c)
    Settings.ESP.Boxes.Color = c
end)

BoxSection:NewSlider("Thickness", "", 5, 1, function(v)
    Settings.ESP.Boxes.Thickness = v
end)

TracerSection:NewToggle("Tracers", "Lines from bottom of screen", function(v)
    Settings.ESP.Tracers.Enabled = v
end)

TracerSection:NewColorPicker("Color", "", Settings.ESP.Tracers.Color, function(c)
    Settings.ESP.Tracers.Color = c
end)

TracerSection:NewSlider("Thickness", "", 5, 1, function(v)
    Settings.ESP.Tracers.Thickness = v
end)

NameSection:NewToggle("Names", "Show player names", function(v)
    Settings.ESP.Names.Enabled = v
end)

NameSection:NewColorPicker("Color", "", Settings.ESP.Names.Color, function(c)
    Settings.ESP.Names.Color = c
end)

NameSection:NewSlider("Text Size", "", 22, 10, function(v)
    Settings.ESP.Names.Size = v
end)

HealthSection:NewToggle("Health Display", 'Shows "Health: X" above name', function(v)
    Settings.ESP.Health.Enabled = v
end)

HealthSection:NewColorPicker("Color", "", Settings.ESP.Health.Color, function(c)
    Settings.ESP.Health.Color = c
end)

HealthSection:NewSlider("Text Size", "", 16, 8, function(v)
    Settings.ESP.Health.Size = v
end)

ChamsSection:NewToggle("Chams", "Visible through walls", function(v)
    Settings.ESP.Chams.Enabled = v
end)

ChamsSection:NewColorPicker("Outline", "", Settings.ESP.Chams.Outline, function(c)
    Settings.ESP.Chams.Outline = c
end)

ChamsSection:NewColorPicker("Fill", "", Settings.ESP.Chams.Fill, function(c)
    Settings.ESP.Chams.Fill = c
end)

ChamsSection:NewSlider("Fill Transparency", "0-1", 10, 0, function(v)
    Settings.ESP.Chams.FillTrans = v/10
end)

CursorSection:NewToggle("Custom Cursor Crosshair", "Replaces your mouse cursor with a Roblox catalog crosshair", function(v)
    Settings.CursorCrosshair.Enabled = v
end)

CursorSection:NewDropdown("Preset Crosshair", "Choose from popular Roblox catalog ones", {"Default","Simple +","Medium Cross","Small Dot","Glow Circle","Green Dot","Hello Kitty","Meme Funny","Classic CB"}, function(v)
    Settings.CursorCrosshair.Preset = v
    Settings.CursorCrosshair.CustomID = ""
end)

CursorSection:NewTextBox("Custom Asset ID", "Paste rbxassetid://123456789 for your own crosshair", function(val)
    Settings.CursorCrosshair.CustomID = val
    if val ~= "" then
        Settings.CursorCrosshair.Preset = "Custom"
    end
end)

CursorSection:NewLabel("Tip: Use IDs from Roblox catalog (decals/images)")
CursorSection:NewLabel("Popular ones: 1827745864 (classic +), 4048495272, 10891594364 (glow)")
CursorSection:NewLabel("Hello Kitty style: 11351620355")

-- Movement Tab
SpeedSection:NewToggle("Speed Hack", "Change WalkSpeed", function(v)
    Settings.Movement.Enabled = v
end)

SpeedSection:NewSlider("Speed", "16 = default", 180, 16, function(v)
    Settings.Movement.Value = v
end)

NoclipSection:NewToggle("Noclip", "Walk through walls", function(v)
    Settings.Movement.Noclip = v
    if v then
        startNoclip()
    else
        stopNoclip()
    end
end)

FlySection:NewToggle("Fly", "Free camera flight (WASD + Space/Ctrl)", function(v)
    Settings.Movement.Fly = v
end)

FlySection:NewSlider("Fly Speed", "", 300, 20, function(v)
    Settings.Movement.FlySpeed = v
end)

JumpSection:NewToggle("Infinite Jump", "Jump mid-air", function(v)
    Settings.Movement.InfJump = v
end)

JumpSection:NewToggle("Bunny Hop", "Automatic bunny hopping", function(v)
    Settings.Movement.Bhop = v
end)

JumpSection:NewToggle("Custom Jump Power", "Change jump height", function(v)
    Settings.Movement.CustomJumpPower = v
end)

JumpSection:NewSlider("Jump Power", "", 400, 20, function(v)
    Settings.Movement.JumpPower = v
end)

AdvancedMovementSection:NewToggle("CFrame Speed", "Fast WASD movement (ignores walls)", function(v)
    Settings.Movement.CFrameSpeed = v
end)

AdvancedMovementSection:NewSlider("CFrame Speed", "", 120, 10, function(v)
    Settings.Movement.CFrameSpeedValue = v
end)

-- Teleports Tab (unchanged)
PlayerTPSection:NewTextBox("Player Name", "Exact username (case insensitive)", function(val)
    tpTargetName = val
end)

PlayerTPSection:NewButton("Teleport to Player", "Teleports you DIRECTLY CENTERED into the player's torso", function()
    if tpTargetName == "" then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower() == tpTargetName:lower() and p ~= lp then
            if p.Character and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                local targetPart = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("HumanoidRootPart")
                if targetPart then
                    lp.Character.HumanoidRootPart.CFrame = targetPart.CFrame
                end
            end
            return
        end
    end
end)

PlayerTPSection:NewButton("Teleport to Random Player", "Teleports you DIRECTLY CENTERED into a random player's torso", function()
    local candidates = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            table.insert(candidates, p)
        end
    end
    if #candidates > 0 then
        local chosen = candidates[math.random(1, #candidates)]
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = chosen.Character:FindFirstChild("UpperTorso") or chosen.Character:FindFirstChild("Torso") or chosen.Character:FindFirstChild("HumanoidRootPart")
            if targetPart then
                lp.Character.HumanoidRootPart.CFrame = targetPart.CFrame
            end
        end
    end
end)

ClickTPSection:NewToggle("Click Teleport (Right Click)", "Right-click anywhere in the world to teleport there", function(v)
    Settings.ClickTeleport.Enabled = v
end)

ClickTPSection:NewLabel("Tip: Works best with Noclip or Fly enabled")
ClickTPSection:NewLabel("Right-click on ground / wall to teleport")

-- Camera Tab
CameraFOVSection:NewToggle("Enable FOV Changer", "Wider/narrower view", function(v)
    Settings.FOVChanger.Enabled = v
end)

CameraFOVSection:NewSlider("FOV Value", "50 = zoomed in, 120 = super wide", 120, 50, function(v)
    Settings.FOVChanger.Value = v
end)

CameraFOVSection:NewLabel("Default Roblox FOV is usually 70")
CameraFOVSection:NewLabel("Higher values = wider view")
CameraFOVSection:NewLabel("Lower values = zoomed in feel")

-- End of script
