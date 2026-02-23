-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local invis_on = false
local guiMinimized = false

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GhostGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame (glassmorphic dark card)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 220)
mainFrame.Position = UDim2.new(1, -300, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
mainFrame.BackgroundTransparency = 0.35
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Glass effect gradient
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 25, 45)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 18, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 10, 22))
}
gradient.Rotation = 135
gradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0.38),
    NumberSequenceKeypoint.new(1, 0.62)
}
gradient.Parent = mainFrame

-- Neon stroke + glow
local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(0, 210, 255)
uiStroke.Transparency = 0.45
uiStroke.Thickness = 2
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiStroke.Parent = mainFrame

-- Rounded corners
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 18)
uiCorner.Parent = mainFrame

-- Shadow
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 60, 1, 60)
shadow.Position = UDim2.new(0, -30, 0, -30)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://6014263693"
shadow.ImageColor3 = Color3.new(0,0,0)
shadow.ImageTransparency = 0.72
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(49,49,450,450)
shadow.ZIndex = -2
shadow.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 0, 50)
title.Position = UDim2.new(0, 20, 0, 8)
title.BackgroundTransparency = 1
title.Text = "INVIS MODE"
title.TextColor3 = Color3.fromRGB(235, 245, 255)
title.TextSize = 26
title.Font = Enum.Font.GothamBlack
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextTransparency = 0.05
title.Parent = mainFrame

local titleStroke = Instance.new("UIStroke")
titleStroke.Color = Color3.fromRGB(0, 200, 255)
titleStroke.Transparency = 0.65
titleStroke.Thickness = 1
titleStroke.Parent = title

-- Minimize / Maximize Button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 38, 0, 38)
minimizeBtn.Position = UDim2.new(1, -52, 0, 10)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 255)
minimizeBtn.Text = "–"
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.TextSize = 26
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = mainFrame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 12)
minCorner.Parent = minimizeBtn

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 38, 0, 38)
closeBtn.Position = UDim2.new(1, -96, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(235, 70, 70)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextSize = 26
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 12)
closeCorner.Parent = closeBtn

-- Main Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.86, 0, 0, 68)
toggleBtn.Position = UDim2.new(0.07, 0, 0.32, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 145, 255)
toggleBtn.Text = "INVIS OFF"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextSize = 28
toggleBtn.Font = Enum.Font.GothamBlack
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = mainFrame

local togCorner = Instance.new("UICorner")
togCorner.CornerRadius = UDim.new(0, 14)
togCorner.Parent = toggleBtn

local togStroke = Instance.new("UIStroke")
togStroke.Color = Color3.fromRGB(100, 220, 255)
togStroke.Thickness = 2.4
togStroke.Transparency = 0.4
togStroke.Parent = toggleBtn

-- Credits
local credits = Instance.new("TextLabel")
credits.Size = UDim2.new(1, -40, 0, 18)
credits.Position = UDim2.new(0, 20, 1, -48)
credits.BackgroundTransparency = 1
credits.Text = "DC: Discord.gg/ERNQpp8NpE"
credits.TextColor3 = Color3.fromRGB(140, 150, 180)
credits.TextSize = 13
credits.Font = Enum.Font.Gotham
credits.TextXAlignment = Enum.TextXAlignment.Center
credits.Parent = mainFrame

-- ────────────────────────────────────────────────
--   Improved Notification
-- ────────────────────────────────────────────────
local notifyFrame = Instance.new("Frame")
notifyFrame.Size = UDim2.new(0, 360, 0, 84)
notifyFrame.Position = UDim2.new(0.5, -180, 0, -120)
notifyFrame.BackgroundColor3 = Color3.fromRGB(16, 18, 30)
notifyFrame.BackgroundTransparency = 0.25
notifyFrame.BorderSizePixel = 0
notifyFrame.Visible = false
notifyFrame.Parent = screenGui

local nCorner = Instance.new("UICorner")
nCorner.CornerRadius = UDim.new(0, 18)
nCorner.Parent = notifyFrame

local nStroke = Instance.new("UIStroke")
nStroke.Color = Color3.fromRGB(0, 200, 255)
nStroke.Transparency = 0.3
nStroke.Thickness = 2.2
nStroke.Parent = notifyFrame

local nGlow = Instance.new("UIGradient")
nGlow.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 220, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 80, 160))
}
nGlow.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0.92),
    NumberSequenceKeypoint.new(1, 1)
}
nGlow.Rotation = -45
nGlow.Parent = notifyFrame

local nTitle = Instance.new("TextLabel")
nTitle.Size = UDim2.new(1, -24, 0.38, 0)
nTitle.Position = UDim2.new(0, 12, 0, 10)
nTitle.BackgroundTransparency = 1
nTitle.Text = ""
nTitle.TextColor3 = Color3.fromRGB(230, 245, 255)
nTitle.TextSize = 22
nTitle.Font = Enum.Font.GothamBlack
nTitle.TextXAlignment = Enum.TextXAlignment.Center
nTitle.Parent = notifyFrame

local nText = Instance.new("TextLabel")
nText.Size = UDim2.new(1, -24, 0.5, 0)
nText.Position = UDim2.new(0, 12, 0.42, 0)
nText.BackgroundTransparency = 1
nText.Text = ""
nText.TextColor3 = Color3.fromRGB(180, 200, 230)
nText.TextSize = 17
nText.Font = Enum.Font.GothamSemibold
nText.TextXAlignment = Enum.TextXAlignment.Center
nText.TextWrapped = true
nText.Parent = notifyFrame

local function showNotification(titleStr, msg)
    nTitle.Text = titleStr
    nText.Text = msg
    notifyFrame.Visible = true
    notifyFrame.Position = UDim2.new(0.5, -180, 0, -120)
    notifyFrame.BackgroundTransparency = 1
    notifyFrame.Size = UDim2.new(0, 360, 0, 70)

    local tweenIn = TweenService:Create(notifyFrame, TweenInfo.new(0.65, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -180, 0, 50),
        BackgroundTransparency = 0.25,
        Size = UDim2.new(0, 360, 0, 84)
    })
    tweenIn:Play()

    task.delay(4.2, function()
        local tweenOut = TweenService:Create(notifyFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -180, 0, -120),
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 360, 0, 70)
        })
        tweenOut:Play()
        tweenOut.Completed:Wait()
        notifyFrame.Visible = false
    end)
end

-- ────────────────────────────────────────────────
--   Button hover / click effects
-- ────────────────────────────────────────────────
local function addButtonEffect(btn, normalColor, hoverColor)
    local originalSize = btn.Size
    local stroke = btn:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke", btn)
    stroke.Color = hoverColor
    stroke.Transparency = 0.55
    stroke.Thickness = 0

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.24, Enum.EasingStyle.Quint), {
            BackgroundColor3 = hoverColor,
            Size = originalSize + UDim2.new(0, 6, 0, 6)
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.24), {Thickness = 2.8, Transparency = 0.3}):Play()
    end)

    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.24, Enum.EasingStyle.Quint), {
            BackgroundColor3 = normalColor,
            Size = originalSize
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.24), {Thickness = 0, Transparency = 0.55}):Play()
    end)

    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.14), {Size = originalSize + UDim2.new(0, -5, 0, -5)}):Play()
    end)

    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.18, Enum.EasingStyle.Back), {Size = originalSize}):Play()
    end)
end

addButtonEffect(toggleBtn, Color3.fromRGB(0, 145, 255),   Color3.fromRGB(0, 195, 255))
addButtonEffect(closeBtn,   Color3.fromRGB(235, 70, 70),  Color3.fromRGB(255, 95, 95))
addButtonEffect(minimizeBtn,Color3.fromRGB(60, 140, 255), Color3.fromRGB(95, 175, 255))

-- ────────────────────────────────────────────────
--   Ghost Functions
-- ────────────────────────────────────────────────
local function disableGhost()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local chair = workspace:FindFirstChild("invischair")
    if chair then chair:Destroy() end

    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("MeshPart") then
            v.LocalTransparencyModifier = 0
        end
    end
end

local function enableGhost()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local root = char.HumanoidRootPart
    local savedCFrame = root.CFrame
    root.CFrame = CFrame.new(-25.95, 84, 3537.55)
    task.wait(0.03)

    local seat = Instance.new("Seat")
    seat.Name = "invischair"
    seat.Anchored = false
    seat.CanCollide = false
    seat.Transparency = 1
    seat.Size = Vector3.new(2, 0.2, 2)
    seat.Position = Vector3.new(-25.95, 84, 3537.55)
    seat.Parent = workspace

    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not torso then 
        seat:Destroy()
        return 
    end

    local weld = Instance.new("Weld")
    weld.Part0 = seat
    weld.Part1 = torso
    weld.Parent = seat

    seat.CFrame = savedCFrame

    for _, v in pairs(char:GetDescendants()) do
        if (v:IsA("BasePart") or v:IsA("MeshPart")) and v ~= root then
            v.LocalTransparencyModifier = 0
        end
    end
end

local function toggleGhost()
    invis_on = not invis_on

    if invis_on then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 210, 120)
        toggleBtn.Text = "INVIS ON"
        enableGhost()
        showNotification("INVIS MODE", "ENABLED  —  visible to yourself only")
    else
        disableGhost()
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 145, 255)
        toggleBtn.Text = "INVIS OFF"
        showNotification("INVIS MODE", "DISABLED")
    end
end

local function forceDisableGhost()
    if invis_on then
        disableGhost()
        invis_on = false
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 145, 255)
        toggleBtn.Text = "INVIS OFF"
    end
end

-- Minimize toggle
local function toggleMinimize()
    guiMinimized = not guiMinimized

    if guiMinimized then
        TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 280, 0, 56)
        }):Play()
        toggleBtn.Visible = false
        credits.Visible = false
        minimizeBtn.Text = "+"
    else
        TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 280, 0, 220)
        }):Play()
        toggleBtn.Visible = true
        credits.Visible = true
        minimizeBtn.Text = "–"
    end
end

-- Connections
toggleBtn.MouseButton1Click:Connect(toggleGhost)

closeBtn.MouseButton1Click:Connect(function()
    forceDisableGhost()          -- turns ghost off before closing
    screenGui:Destroy()
end)

minimizeBtn.MouseButton1Click:Connect(toggleMinimize)

-- Optional: disable ghost on respawn
player.CharacterAdded:Connect(function()
    task.delay(0.8, function()
        if invis_on then
            forceDisableGhost()
        end
    end)
end)
