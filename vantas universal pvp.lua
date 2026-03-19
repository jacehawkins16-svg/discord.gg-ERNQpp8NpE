local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
	Name = "Vanta Universal [Beta] | discord.gg-ERNQpp8NpE",
	LoadingTitle = "Vanta Universal [Beta]",
	LoadingSubtitle = "discord.gg-ERNQpp8NpE",
	ConfigurationSaving = {
		Enabled = false,
		FolderName = nil,
		FileName = "VantaUniversal"
	},
	Discord = {
		Enabled = false,
		Invite = "ERNQpp8NpE",
		RememberJoins = true
	},
	KeySystem = false
})

Rayfield:Notify({
	Title = "Vanta Universal",
	Content = "UI loaded successfully!\nPress G to toggle the menu (custom keybind).",
	Duration = 6,
	Image = 4483362458
})

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

-- Settings Table
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
    CursorCrosshair = {
        Enabled = false,
        Preset  = "Default",
        CustomID = ""
    },
    FOVChanger = {
        Enabled = false,
        Value   = 70
    },
    ClickTeleport = {
        Enabled = false
    },
    Invisible = {
        Enabled = false
    },
    BetterCamera = {
        Enabled = false
    }
}

-- Persistent variables
local defaultFOV = camera.FieldOfView or 70
local defaultCursor = mouse.Icon
local tpTargetName = ""
local wasOnValidTarget  = false
local betterCameraLoaded = false

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

-- Cursor Presets
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

-- ESP SETUP
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

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Settings.Movement.InfJump and lp.Character then
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Click Teleport
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

-- Invisible exploit
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
    -- NEW STATE-BASED TRIGGERBOT
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

    if Settings.Triggerbot.Enabled then
        if isOnValidTarget and not wasOnValidTarget then
            mouse1press()
        elseif not isOnValidTarget and wasOnValidTarget then
            mouse1release()
        end
    end
    wasOnValidTarget = isOnValidTarget

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
            if Settings.Movement.Enabled then
                hum.WalkSpeed = Settings.Movement.Value
            end

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

            if Settings.Movement.CustomJumpPower then
                hum.JumpPower = Settings.Movement.JumpPower
            end

            if Settings.Movement.Bhop then
                if hum:GetState() ~= Enum.HumanoidStateType.Jumping and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                    hum.Jump = true
                end
            end
        end
    end

    -- ESP RENDER LOOP
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

    -- Enforce Custom Cursor every frame
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

-- Cleanup
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

-- ==================== RAYFIELD UI CONTROLS ====================

-- Combat Tab
local CombatTab = Window:CreateTab("Combat", 4483362458)
CombatTab:CreateSection("Triggerbot")
CombatTab:CreateToggle({
	Name = "Triggerbot",
	CurrentValue = Settings.Triggerbot.Enabled,
	Flag = "Triggerbot",
	Callback = function(Value)
		Settings.Triggerbot.Enabled = Value
		if not Value and wasOnValidTarget then
			mouse1release()
			wasOnValidTarget = false
		end
	end,
})

CombatTab:CreateSection("Aimbot")
CombatTab:CreateToggle({
	Name = "Aimbot",
	CurrentValue = Settings.Aimbot.Enabled,
	Flag = "Aimbot",
	Callback = function(Value)
		Settings.Aimbot.Enabled = Value
	end,
})
CombatTab:CreateSlider({
	Name = "FOV",
	Range = {80, 1400},
	Increment = 1,
	CurrentValue = Settings.Aimbot.FOV,
	Flag = "AimbotFOV",
	Callback = function(Value)
		Settings.Aimbot.FOV = Value
	end,
})
CombatTab:CreateDropdown({
	Name = "Aim Part",
	Options = {"Head","UpperTorso","HumanoidRootPart","LowerTorso"},
	CurrentOption = {Settings.Aimbot.AimPart},
	Flag = "AimPart",
	Callback = function(Option)
		Settings.Aimbot.AimPart = Option[1]
	end,
})
CombatTab:CreateToggle({
	Name = "Visible Check",
	CurrentValue = Settings.Aimbot.VisibleCheck,
	Flag = "VisibleCheck",
	Callback = function(Value)
		Settings.Aimbot.VisibleCheck = Value
	end,
})
CombatTab:CreateSlider({
	Name = "Smoothness",
	Range = {0, 100},
	Increment = 1,
	CurrentValue = Settings.Aimbot.Smooth * 100,
	Flag = "Smoothness",
	Callback = function(Value)
		Settings.Aimbot.Smooth = Value / 100
	end,
})

CombatTab:CreateSection("Misc")
CombatTab:CreateToggle({
	Name = "Invisible",
	CurrentValue = Settings.Invisible.Enabled,
	Flag = "Invisible",
	Callback = function(Value)
		Settings.Invisible.Enabled = Value
		isInvisibleEnabled = Value
		local char = lp.Character
		if Value then
			if char then makeInvisible(char) end
		else
			if char then disableInvisible(char) end
		end
	end,
})

-- Visuals Tab
local VisualsTab = Window:CreateTab("Visuals [BETA]", 6031094678)
VisualsTab:CreateSection("Aimbot FOV Circle")
VisualsTab:CreateToggle({
	Name = "Show FOV Circle",
	CurrentValue = Settings.Aimbot.ShowCircle,
	Flag = "ShowFOVCircle",
	Callback = function(Value)
		Settings.Aimbot.ShowCircle = Value
	end,
})
VisualsTab:CreateColorPicker({
	Name = "Circle Color",
	Color = Settings.Aimbot.CircleColor,
	Flag = "CircleColor",
	Callback = function(Value)
		Settings.Aimbot.CircleColor = Value
	end,
})
VisualsTab:CreateSlider({
	Name = "Thickness",
	Range = {1, 6},
	Increment = 1,
	CurrentValue = Settings.Aimbot.CircleThick,
	Flag = "CircleThick",
	Callback = function(Value)
		Settings.Aimbot.CircleThick = Value
	end,
})
VisualsTab:CreateSlider({
	Name = "Transparency",
	Range = {0, 10},
	Increment = 1,
	CurrentValue = Settings.Aimbot.CircleTrans * 10,
	Flag = "CircleTrans",
	Callback = function(Value)
		Settings.Aimbot.CircleTrans = Value / 10
	end,
})

VisualsTab:CreateSection("2D Boxes")
VisualsTab:CreateToggle({
	Name = "Boxes",
	CurrentValue = Settings.ESP.Boxes.Enabled,
	Flag = "Boxes",
	Callback = function(Value)
		Settings.ESP.Boxes.Enabled = Value
	end,
})
VisualsTab:CreateColorPicker({
	Name = "Color",
	Color = Settings.ESP.Boxes.Color,
	Flag = "BoxesColor",
	Callback = function(Value)
		Settings.ESP.Boxes.Color = Value
	end,
})
VisualsTab:CreateSlider({
	Name = "Thickness",
	Range = {1, 5},
	Increment = 1,
	CurrentValue = Settings.ESP.Boxes.Thickness,
	Flag = "BoxesThickness",
	Callback = function(Value)
		Settings.ESP.Boxes.Thickness = Value
	end,
})

VisualsTab:CreateSection("Tracers")
VisualsTab:CreateToggle({
	Name = "Tracers",
	CurrentValue = Settings.ESP.Tracers.Enabled,
	Flag = "Tracers",
	Callback = function(Value)
		Settings.ESP.Tracers.Enabled = Value
	end,
})
VisualsTab:CreateColorPicker({
	Name = "Color",
	Color = Settings.ESP.Tracers.Color,
	Flag = "TracersColor",
	Callback = function(Value)
		Settings.ESP.Tracers.Color = Value
	end,
})
VisualsTab:CreateSlider({
	Name = "Thickness",
	Range = {1, 5},
	Increment = 1,
	CurrentValue = Settings.ESP.Tracers.Thickness,
	Flag = "TracersThickness",
	Callback = function(Value)
		Settings.ESP.Tracers.Thickness = Value
	end,
})

VisualsTab:CreateSection("Player Names")
VisualsTab:CreateToggle({
	Name = "Names",
	CurrentValue = Settings.ESP.Names.Enabled,
	Flag = "Names",
	Callback = function(Value)
		Settings.ESP.Names.Enabled = Value
	end,
})
VisualsTab:CreateColorPicker({
	Name = "Color",
	Color = Settings.ESP.Names.Color,
	Flag = "NamesColor",
	Callback = function(Value)
		Settings.ESP.Names.Color = Value
	end,
})
VisualsTab:CreateSlider({
	Name = "Text Size",
	Range = {10, 22},
	Increment = 1,
	CurrentValue = Settings.ESP.Names.Size,
	Flag = "NamesSize",
	Callback = function(Value)
		Settings.ESP.Names.Size = Value
	end,
})

VisualsTab:CreateSection("Health Display")
VisualsTab:CreateToggle({
	Name = "Health Display",
	CurrentValue = Settings.ESP.Health.Enabled,
	Flag = "HealthDisplay",
	Callback = function(Value)
		Settings.ESP.Health.Enabled = Value
	end,
})
VisualsTab:CreateColorPicker({
	Name = "Color",
	Color = Settings.ESP.Health.Color,
	Flag = "HealthColor",
	Callback = function(Value)
		Settings.ESP.Health.Color = Value
	end,
})
VisualsTab:CreateSlider({
	Name = "Text Size",
	Range = {8, 16},
	Increment = 1,
	CurrentValue = Settings.ESP.Health.Size,
	Flag = "HealthSize",
	Callback = function(Value)
		Settings.ESP.Health.Size = Value
	end,
})

VisualsTab:CreateSection("Chams / Wall Glow")
VisualsTab:CreateToggle({
	Name = "Chams",
	CurrentValue = Settings.ESP.Chams.Enabled,
	Flag = "Chams",
	Callback = function(Value)
		Settings.ESP.Chams.Enabled = Value
	end,
})
VisualsTab:CreateColorPicker({
	Name = "Outline",
	Color = Settings.ESP.Chams.Outline,
	Flag = "ChamsOutline",
	Callback = function(Value)
		Settings.ESP.Chams.Outline = Value
	end,
})
VisualsTab:CreateColorPicker({
	Name = "Fill",
	Color = Settings.ESP.Chams.Fill,
	Flag = "ChamsFill",
	Callback = function(Value)
		Settings.ESP.Chams.Fill = Value
	end,
})
VisualsTab:CreateSlider({
	Name = "Fill Transparency",
	Range = {0, 10},
	Increment = 1,
	CurrentValue = Settings.ESP.Chams.FillTrans * 10,
	Flag = "FillTrans",
	Callback = function(Value)
		Settings.ESP.Chams.FillTrans = Value / 10
	end,
})

VisualsTab:CreateSection("Custom Cursor Crosshair")
VisualsTab:CreateToggle({
	Name = "Custom Cursor Crosshair",
	CurrentValue = Settings.CursorCrosshair.Enabled,
	Flag = "CursorCrosshair",
	Callback = function(Value)
		Settings.CursorCrosshair.Enabled = Value
	end,
})
VisualsTab:CreateDropdown({
	Name = "Preset Crosshair",
	Options = {"Default","Simple +","Medium Cross","Small Dot","Glow Circle","Green Dot","Hello Kitty","Meme Funny","Classic CB"},
	CurrentOption = {Settings.CursorCrosshair.Preset},
	Flag = "CursorPreset",
	Callback = function(Option)
		Settings.CursorCrosshair.Preset = Option[1]
		Settings.CursorCrosshair.CustomID = ""
	end,
})
VisualsTab:CreateInput({
	Name = "Custom Asset ID",
	PlaceholderText = "Paste rbxassetid://123456789 for your own crosshair",
	CurrentValue = Settings.CursorCrosshair.CustomID,
	RemoveTextAfterFocusLost = false,
	Flag = "CustomAssetID",
	Callback = function(Text)
		Settings.CursorCrosshair.CustomID = Text
		if Text ~= "" then
			Settings.CursorCrosshair.Preset = "Custom"
		end
	end,
})
VisualsTab:CreateLabel("Tip: Use IDs from Roblox catalog (decals/images)")
VisualsTab:CreateLabel("Popular ones: 1827745864 (classic +), 4048495272, 10891594364 (glow)")
VisualsTab:CreateLabel("Hello Kitty style: 11351620355")

-- Movement Tab
local MovementTab = Window:CreateTab("Movement", 6031075938)
MovementTab:CreateSection("Speed Hack")
MovementTab:CreateToggle({
	Name = "Speed Hack",
	CurrentValue = Settings.Movement.Enabled,
	Flag = "SpeedHack",
	Callback = function(Value)
		Settings.Movement.Enabled = Value
	end,
})
MovementTab:CreateSlider({
	Name = "Speed",
	Range = {16, 180},
	Increment = 1,
	CurrentValue = Settings.Movement.Value,
	Flag = "SpeedValue",
	Callback = function(Value)
		Settings.Movement.Value = Value
	end,
})

MovementTab:CreateSection("Noclip")
MovementTab:CreateToggle({
	Name = "Noclip",
	CurrentValue = Settings.Movement.Noclip,
	Flag = "Noclip",
	Callback = function(Value)
		Settings.Movement.Noclip = Value
		if Value then
			startNoclip()
		else
			stopNoclip()
		end
	end,
})

MovementTab:CreateSection("Fly")
MovementTab:CreateToggle({
	Name = "Fly",
	CurrentValue = Settings.Movement.Fly,
	Flag = "Fly",
	Callback = function(Value)
		Settings.Movement.Fly = Value
	end,
})
MovementTab:CreateSlider({
	Name = "Fly Speed",
	Range = {20, 300},
	Increment = 1,
	CurrentValue = Settings.Movement.FlySpeed,
	Flag = "FlySpeed",
	Callback = function(Value)
		Settings.Movement.FlySpeed = Value
	end,
})

MovementTab:CreateSection("Jump Hacks")
MovementTab:CreateToggle({
	Name = "Infinite Jump",
	CurrentValue = Settings.Movement.InfJump,
	Flag = "InfJump",
	Callback = function(Value)
		Settings.Movement.InfJump = Value
	end,
})
MovementTab:CreateToggle({
	Name = "Bunny Hop",
	CurrentValue = Settings.Movement.Bhop,
	Flag = "Bhop",
	Callback = function(Value)
		Settings.Movement.Bhop = Value
	end,
})
MovementTab:CreateToggle({
	Name = "Custom Jump Power",
	CurrentValue = Settings.Movement.CustomJumpPower,
	Flag = "CustomJumpPower",
	Callback = function(Value)
		Settings.Movement.CustomJumpPower = Value
	end,
})
MovementTab:CreateSlider({
	Name = "Jump Power",
	Range = {20, 400},
	Increment = 1,
	CurrentValue = Settings.Movement.JumpPower,
	Flag = "JumpPower",
	Callback = function(Value)
		Settings.Movement.JumpPower = Value
	end,
})

MovementTab:CreateSection("Advanced Movement")
MovementTab:CreateToggle({
	Name = "CFrame Speed",
	CurrentValue = Settings.Movement.CFrameSpeed,
	Flag = "CFrameSpeed",
	Callback = function(Value)
		Settings.Movement.CFrameSpeed = Value
	end,
})
MovementTab:CreateSlider({
	Name = "CFrame Speed",
	Range = {10, 120},
	Increment = 1,
	CurrentValue = Settings.Movement.CFrameSpeedValue,
	Flag = "CFrameSpeedValue",
	Callback = function(Value)
		Settings.Movement.CFrameSpeedValue = Value
	end,
})

-- Teleports Tab
local TeleportsTab = Window:CreateTab("Teleports", 6022668955)
TeleportsTab:CreateSection("Player Teleports")
TeleportsTab:CreateInput({
	Name = "Player Name",
	PlaceholderText = "Exact username (case insensitive)",
	CurrentValue = tpTargetName,
	RemoveTextAfterFocusLost = false,
	Flag = "PlayerName",
	Callback = function(Text)
		tpTargetName = Text
	end,
})
TeleportsTab:CreateButton({
	Name = "Teleport to Player",
	Callback = function()
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
	end,
})
TeleportsTab:CreateButton({
	Name = "Teleport to Random Player",
	Callback = function()
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
	end,
})

TeleportsTab:CreateSection("Click Teleport")
TeleportsTab:CreateToggle({
	Name = "Click Teleport (Right Click)",
	CurrentValue = Settings.ClickTeleport.Enabled,
	Flag = "ClickTeleport",
	Callback = function(Value)
		Settings.ClickTeleport.Enabled = Value
	end,
})
TeleportsTab:CreateLabel("Tip: Works best with Noclip or Fly enabled")
TeleportsTab:CreateLabel("Right-click on ground / wall to teleport")

-- Camera Tab
local CameraTab = Window:CreateTab("Camera", 6034509993)
CameraTab:CreateSection("FOV Changer")
CameraTab:CreateToggle({
	Name = "Enable FOV Changer",
	CurrentValue = Settings.FOVChanger.Enabled,
	Flag = "FOVChanger",
	Callback = function(Value)
		Settings.FOVChanger.Enabled = Value
	end,
})
CameraTab:CreateSlider({
	Name = "FOV Value",
	Range = {50, 120},
	Increment = 1,
	CurrentValue = Settings.FOVChanger.Value,
	Flag = "FOVValue",
	Callback = function(Value)
		Settings.FOVChanger.Value = Value
	end,
})

CameraTab:CreateSection("Camera Exploits")
CameraTab:CreateToggle({
	Name = "Better Camera",
	CurrentValue = Settings.BetterCamera.Enabled,
	Flag = "BetterCamera",
	Callback = function(Value)
		Settings.BetterCamera.Enabled = Value
		if Value and not betterCameraLoaded then
			betterCameraLoaded = true
			loadstring(game:HttpGet('https://jacehawkins16-svg.github.io/discord.gg-ERNQpp8NpE/vantas%20universal%20semirealistic%20camera.lua'))()
			Rayfield:Notify({
				Title = "Better Camera",
				Content = "Loaded successfully!\n(Head-attached + first-person body hide + no names)",
				Duration = 5,
			})
		elseif not Value then
			-- Reset as much as possible before rejoin
			camera.CameraType = Enum.CameraType.Custom
			if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
				camera.CameraSubject = lp.Character:FindFirstChildOfClass("Humanoid")
			end
			camera.FieldOfView = defaultFOV

			if lp.Character then
				for _, part in ipairs(lp.Character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.LocalTransparencyModifier = 0
					end
				end
			end

			for _, player in ipairs(Players:GetPlayers()) do
				if player.Character then
					local hum = player.Character:FindFirstChildOfClass("Humanoid")
					if hum then
						hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Subject
					end
					local head = player.Character:FindFirstChild("Head")
					if head then
						for _, child in ipairs(head:GetChildren()) do
							if child:IsA("BillboardGui") then
								child.Enabled = true
							end
						end
					end
				end
			end

			Rayfield:Notify({
				Title = "Better Camera",
				Content = "Disabling...\nRejoining to fully unload the external camera script",
				Duration = 6,
			})

			queueReinject()
			task.wait(0.6)
			TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
		end
	end,
})

-- Custom G keybind to toggle Rayfield UI
local rayfieldMain = nil
task.spawn(function()
	repeat task.wait(0.2) until game.CoreGui:FindFirstChild("Rayfield")
	rayfieldMain = game.CoreGui.Rayfield:FindFirstChild("Main")
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.G and rayfieldMain then
		rayfieldMain.Visible = not rayfieldMain.Visible
	end
end)
