--[[
    VANTAHOOD V5 - PREMIER EDITION (REFINED AESTHETIC)
    CHARACTER OPTIMIZED BUILD: ~40,000 CHARACTERS
    
    FONT THEME: FredokaOne (Rounded & Cute)
    
    UPDATES:
    1. Branding Reordered: YouTube link is now prioritized above Discord.
    2. Credits Expanded: Added specialized roles and community acknowledgments.
    3. Typography: Switched to FredokaOne for a friendlier, modern look.
    4. Code Integrity: No functional logic altered; structural fixes only.
    5. ADDED: Transparency Slider, Font Selection, and Minimize Key changed to "Y".
    6. TRIGGERBOT FIX: Now ignores the local player's own character.
    7. TRIGGERBOT ENHANCEMENT: Detects all player parts (Head, Torso, Arms, etc).
]]

getgenv().Aimbot = {
    Status = true,
    Keybind  = 'C',
    Hitpart = 'HumanoidRootPart',
    ['Prediction'] = {
        X = 0.165,
        Y = 0.1,
    },
}

getgenv().Triggerbot = {
    Enabled = false,
    Keybind = 'O'
}

getgenv().ESP = {
    Enabled = false,
    Keybind = 'B',
}

getgenv().Fly = {
    Enabled = false,
    Keybind = 'V',
    Speed = 250
}

getgenv().Noclip = {
    Enabled = false,
    Keybind = 'Z'
}

getgenv().FakeMacro = {
    Enabled = false,
    Keybind = 'U',
    SpeedMultiplier = 20
}

getgenv().LoopKill = {
    Enabled = false,
    Keybind = 'L'
}

getgenv().Tornado = {
    Enabled = false,
    Keybind = 'T'
}

getgenv().Settings = {
    MinimizeKey = Enum.KeyCode.Y, -- Updated to "Y"
    IsVisible = true,
    Transparency = 0
}

-- Cleanup old UI
if game:GetService("CoreGui"):FindFirstChild("JacesScriptsRevamp") then
    game:GetService("CoreGui"):FindFirstChild("JacesScriptsRevamp"):Destroy()
end

local RunService = game:GetService('RunService')
local Players = game:GetService('Players')
local Workspace = game:GetService('Workspace')
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local TargetPlayer = nil 
local SelectedPlayerForTP = nil
local CuteFont = Enum.Font.FredokaOne 

-- Mobile Detection Logic
local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

--- ### MODERN UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JacesScriptsRevamp"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

-- Side Bar
local SideBar = Instance.new("Frame")
SideBar.Name = "SideBar"
SideBar.Parent = MainFrame
SideBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
SideBar.Size = UDim2.new(0, 140, 1, 0)
SideBar.BorderSizePixel = 0
Instance.new("UICorner", SideBar).CornerRadius = UDim.new(0, 10)

-- Top Navigation Container
local TopNav = Instance.new("Frame", SideBar)
TopNav.Size = UDim2.new(1, 0, 0.7, 0)
TopNav.BackgroundTransparency = 1

local TopNavList = Instance.new("UIListLayout", TopNav)
TopNavList.Padding = UDim.new(0, 5)
TopNavList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TopNavList.SortOrder = Enum.SortOrder.LayoutOrder

local TopSpacer = Instance.new("Frame", TopNav)
TopSpacer.Size = UDim2.new(1, 0, 0, 10)
TopSpacer.BackgroundTransparency = 1
TopSpacer.LayoutOrder = 0

local function NavBtn(text, order)
    local btn = Instance.new("TextButton", TopNav)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.Font = CuteFont
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 14
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local ExpBtn = NavBtn("Exploits", 1)
local SetBtn = NavBtn("Settings", 2)
local CrdBtn = NavBtn("Credits", 3)

-- Bottom Branding Section
local BottomNav = Instance.new("Frame", SideBar)
BottomNav.Size = UDim2.new(1, 0, 0, 85)
BottomNav.Position = UDim2.new(0, 0, 1, -85)
BottomNav.BackgroundTransparency = 1

local BottomNavList = Instance.new("UIListLayout", BottomNav)
BottomNavList.VerticalAlignment = Enum.VerticalAlignment.Bottom
BottomNavList.HorizontalAlignment = Enum.HorizontalAlignment.Center
BottomNavList.Padding = UDim.new(0, 2)
BottomNavList.SortOrder = Enum.SortOrder.LayoutOrder

local YTLabel = Instance.new("TextLabel", BottomNav)
YTLabel.Size = UDim2.new(1, 0, 0, 15)
YTLabel.BackgroundTransparency = 1
YTLabel.Font = CuteFont
YTLabel.Text = "@VantabladeYT"
YTLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
YTLabel.TextSize = 11
YTLabel.LayoutOrder = 1 

local DiscLabel = Instance.new("TextLabel", BottomNav)
DiscLabel.Size = UDim2.new(1, 0, 0, 15)
DiscLabel.BackgroundTransparency = 1
DiscLabel.Font = CuteFont
DiscLabel.Text = "discord.gg/ERNQpp8NpE"
DiscLabel.TextColor3 = Color3.fromRGB(114, 137, 218)
DiscLabel.TextSize = 9
DiscLabel.LayoutOrder = 2 

local MainTitle = Instance.new("TextLabel", BottomNav)
MainTitle.Size = UDim2.new(1, 0, 0, 35)
MainTitle.BackgroundTransparency = 1
MainTitle.Font = CuteFont
MainTitle.Text = "VANTAHOOD V5"
MainTitle.TextColor3 = Color3.fromRGB(0, 170, 255)
MainTitle.TextSize = 17
MainTitle.LayoutOrder = 3

-- Container for Tabs
local Container = Instance.new("Frame", MainFrame)
Container.Name = "Container"
Container.Position = UDim2.new(0, 150, 0, 10)
Container.Size = UDim2.new(1, -160, 1, -20)
Container.BackgroundTransparency = 1

local Tabs = {
    Exploits = Instance.new("ScrollingFrame", Container),
    Settings = Instance.new("ScrollingFrame", Container),
    Credits = Instance.new("ScrollingFrame", Container)
}

for name, frame in pairs(Tabs) do
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = (name == "Exploits")
    frame.ScrollBarThickness = 2
    frame.CanvasSize = UDim2.new(0, 0, 0, 950)
    local layout = Instance.new("UIListLayout", frame)
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
end

local function ToggleUI()
    getgenv().Settings.IsVisible = not getgenv().Settings.IsVisible
    MainFrame.Visible = getgenv().Settings.IsVisible
end

if IsMobile then
    local MobileBtn = Instance.new("TextButton", ScreenGui)
    MobileBtn.Name = "MobileToggle"
    MobileBtn.Size = UDim2.new(0, 45, 0, 45)
    MobileBtn.Position = UDim2.new(0, 10, 0.5, -22)
    MobileBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MobileBtn.BorderSizePixel = 2
    MobileBtn.BorderColor3 = Color3.fromRGB(0, 170, 255)
    MobileBtn.Text = "VH"
    MobileBtn.Font = CuteFont
    MobileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MobileBtn.TextSize = 16
    MobileBtn.Draggable = true
    MobileBtn.Active = true
    Instance.new("UICorner", MobileBtn).CornerRadius = UDim.new(0, 12)
    MobileBtn.MouseButton1Click:Connect(ToggleUI)
end

local function SwitchTab(tabName)
    for name, frame in pairs(Tabs) do
        frame.Visible = (name == tabName)
    end
end

ExpBtn.MouseButton1Click:Connect(function() SwitchTab("Exploits") end)
SetBtn.MouseButton1Click:Connect(function() SwitchTab("Settings") end)
CrdBtn.MouseButton1Click:Connect(function() SwitchTab("Credits") end)

local Elements = {}

local function CreateKeybindSetter(name, currentKey, configTable, configKey, parent, order)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(0.95, 0, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Frame.LayoutOrder = order
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = CuteFont
    Label.Text = name .. " [" .. tostring(currentKey):upper() .. "]"
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local BindBtn = Instance.new("TextButton", Frame)
    BindBtn.Size = UDim2.new(0, 85, 0, 28)
    BindBtn.Position = UDim2.new(1, -95, 0.5, -14)
    BindBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    BindBtn.Font = CuteFont
    BindBtn.Text = "SET BIND"
    BindBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
    BindBtn.TextSize = 12
    Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 6)

    BindBtn.MouseButton1Click:Connect(function()
        BindBtn.Text = "..."
        local connection
        connection = UIS.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local newKey = input.KeyCode.Name
                configTable[configKey] = newKey
                Label.Text = name .. " [" .. newKey:upper() .. "]"
                BindBtn.Text = "SET BIND"
                connection:Disconnect()
            end
        end)
    end)
end

--- ### SETTINGS TAB
local ThemeHeader = Instance.new("TextLabel", Tabs.Settings)
ThemeHeader.Size = UDim2.new(0.95, 0, 0, 30)
ThemeHeader.BackgroundTransparency = 1
ThemeHeader.Font = CuteFont
ThemeHeader.Text = "--- UI CUSTOMIZATION ---"
ThemeHeader.TextColor3 = Color3.fromRGB(0, 170, 255)
ThemeHeader.TextSize = 13
ThemeHeader.LayoutOrder = 1

-- Transparency Slider
local TransparencyFrame = Instance.new("Frame", Tabs.Settings)
TransparencyFrame.Size = UDim2.new(0.95, 0, 0, 50)
TransparencyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TransparencyFrame.LayoutOrder = 1.1
Instance.new("UICorner", TransparencyFrame).CornerRadius = UDim.new(0, 8)

local TransLabel = Instance.new("TextLabel", TransparencyFrame)
TransLabel.Size = UDim2.new(1, 0, 0, 20)
TransLabel.Position = UDim2.new(0, 10, 0, 5)
TransLabel.BackgroundTransparency = 1
TransLabel.Font = CuteFont
TransLabel.Text = "MENU TRANSPARENCY: 0%"
TransLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TransLabel.TextSize = 12
TransLabel.TextXAlignment = Enum.TextXAlignment.Left

local SliderBack = Instance.new("Frame", TransparencyFrame)
SliderBack.Size = UDim2.new(0.9, 0, 0, 6)
SliderBack.Position = UDim2.new(0.05, 0, 0.7, 0)
SliderBack.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
Instance.new("UICorner", SliderBack)

local SliderFill = Instance.new("Frame", SliderBack)
SliderFill.Size = UDim2.new(0, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Instance.new("UICorner", SliderFill)

local function UpdateTransparency(input)
    local pos = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
    getgenv().Settings.Transparency = pos
    MainFrame.BackgroundTransparency = pos * 0.8
    SideBar.BackgroundTransparency = pos * 0.8
    TransLabel.Text = "MENU TRANSPARENCY: " .. math.floor(pos * 100) .. "%"
end

SliderBack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local connection
        connection = UIS.InputChanged:Connect(function(change)
            if change.UserInputType == Enum.UserInputType.MouseMovement or change.UserInputType == Enum.UserInputType.Touch then
                UpdateTransparency(change)
            end
        end)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then connection:Disconnect() end
        end)
        UpdateTransparency(input)
    end
end)

-- Font Selection Dropdown
local FontDropdownFrame = Instance.new("Frame", Tabs.Settings)
FontDropdownFrame.Size = UDim2.new(0.95, 0, 0, 35)
FontDropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
FontDropdownFrame.ClipsDescendants = true
FontDropdownFrame.LayoutOrder = 1.2
Instance.new("UICorner", FontDropdownFrame).CornerRadius = UDim.new(0, 8)

local FontDropBtn = Instance.new("TextButton", FontDropdownFrame)
FontDropBtn.Size = UDim2.new(1, 0, 0, 35)
FontDropBtn.BackgroundTransparency = 1
FontDropBtn.Font = CuteFont
FontDropBtn.Text = "SELECT FONT (FREDOKA DEFAULT) ▼"
FontDropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FontDropBtn.TextSize = 12

local FontDropContainer = Instance.new("Frame", FontDropdownFrame)
FontDropContainer.Position = UDim2.new(0, 0, 0, 35)
FontDropContainer.Size = UDim2.new(1, 0, 0, 160)
FontDropContainer.BackgroundTransparency = 1
Instance.new("UIListLayout", FontDropContainer)

local fonts = {
    ["FredokaOne"] = Enum.Font.FredokaOne,
    ["GothamBold"] = Enum.Font.GothamBold,
    ["Roboto"] = Enum.Font.Roboto,
    ["Ubuntu"] = Enum.Font.Ubuntu,
    ["SourceSans"] = Enum.Font.SourceSans
}

for name, font in pairs(fonts) do
    local fBtn = Instance.new("TextButton", FontDropContainer)
    fBtn.Size = UDim2.new(1, 0, 0, 32)
    fBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    fBtn.BorderSizePixel = 0
    fBtn.Font = font
    fBtn.Text = name
    fBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    fBtn.TextSize = 12
    fBtn.MouseButton1Click:Connect(function()
        CuteFont = font
        for _, v in pairs(ScreenGui:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then v.Font = font end
        end
        TweenService:Create(FontDropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.95, 0, 0, 35)}):Play()
    end)
end

FontDropBtn.MouseButton1Click:Connect(function()
    local targetHeight = (FontDropdownFrame.Size.Y.Offset == 35) and 200 or 35
    TweenService:Create(FontDropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0.95, 0, 0, targetHeight)}):Play()
end)

local DropdownFrame = Instance.new("Frame", Tabs.Settings)
DropdownFrame.Size = UDim2.new(0.95, 0, 0, 35)
DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
DropdownFrame.ClipsDescendants = true
DropdownFrame.LayoutOrder = 2
Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 8)

local DropBtn = Instance.new("TextButton", DropdownFrame)
DropBtn.Size = UDim2.new(1, 0, 0, 35)
DropBtn.BackgroundTransparency = 1
DropBtn.Font = CuteFont
DropBtn.Text = "SELECT BACKGROUND COLOR ▼"
DropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DropBtn.TextSize = 12

local DropContainer = Instance.new("Frame", DropdownFrame)
DropContainer.Position = UDim2.new(0, 0, 0, 35)
DropContainer.Size = UDim2.new(1, 0, 0, 160)
DropContainer.BackgroundTransparency = 1
Instance.new("UIListLayout", DropContainer)

local themes = {
    ["VOID BLACK"] = Color3.fromRGB(5, 5, 5),
    ["MIDNIGHT BLUE"] = Color3.fromRGB(15, 15, 30),
    ["CRIMSON DARK"] = Color3.fromRGB(35, 10, 10),
    ["FOREST GREEN"] = Color3.fromRGB(10, 30, 15),
    ["STEEL GREY"] = Color3.fromRGB(40, 40, 45)
}

for name, color in pairs(themes) do
    local tBtn = Instance.new("TextButton", DropContainer)
    tBtn.Size = UDim2.new(1, 0, 0, 32)
    tBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    tBtn.BorderSizePixel = 0
    tBtn.Font = CuteFont
    tBtn.Text = name
    tBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tBtn.TextSize = 12
    tBtn.MouseButton1Click:Connect(function()
        MainFrame.BackgroundColor3 = color
        TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.95, 0, 0, 35)}):Play()
    end)
end

DropBtn.MouseButton1Click:Connect(function()
    local targetHeight = (DropdownFrame.Size.Y.Offset == 35) and 200 or 35
    TweenService:Create(DropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0.95, 0, 0, targetHeight)}):Play()
end)

local BindHeader = Instance.new("TextLabel", Tabs.Settings)
BindHeader.Size = UDim2.new(0.95, 0, 0, 30)
BindHeader.BackgroundTransparency = 1
BindHeader.Font = CuteFont
BindHeader.Text = "--- CORE BINDINGS ---"
BindHeader.TextColor3 = Color3.fromRGB(0, 170, 255)
BindHeader.TextSize = 13
BindHeader.LayoutOrder = 3

CreateKeybindSetter("GUI Minimize", "Y", getgenv().Settings, "MinimizeKey", Tabs.Settings, 4)
CreateKeybindSetter("Aimbot", getgenv().Aimbot.Keybind, getgenv().Aimbot, "Keybind", Tabs.Settings, 5)
CreateKeybindSetter("Triggerbot", getgenv().Triggerbot.Keybind, getgenv().Triggerbot, "Keybind", Tabs.Settings, 6)
CreateKeybindSetter("ESP", getgenv().ESP.Keybind, getgenv().ESP, "Keybind", Tabs.Settings, 7)
CreateKeybindSetter("Fly", getgenv().Fly.Keybind, getgenv().Fly, "Keybind", Tabs.Settings, 8)
CreateKeybindSetter("Noclip", getgenv().Noclip.Keybind, getgenv().Noclip, "Keybind", Tabs.Settings, 9)

local RejoinBtn = Instance.new("TextButton", Tabs.Settings)
RejoinBtn.Size = UDim2.new(0.95, 0, 0, 40)
RejoinBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
RejoinBtn.Text = "EMERGENCY SERVER REJOIN"
RejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RejoinBtn.Font = CuteFont
RejoinBtn.LayoutOrder = 10
Instance.new("UICorner", RejoinBtn).CornerRadius = UDim.new(0, 8)
RejoinBtn.MouseButton1Click:Connect(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end)

--- ### EXPLOITS LOGIC
local function UpdateUI()
    local e = Elements
    if e["Aimbot"] then
        e["Aimbot"].Button.Text = (TargetPlayer ~= nil) and "ACTIVE" or "OFF"
        e["Aimbot"].Button.BackgroundColor3 = (TargetPlayer ~= nil) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 55)
    end
    if e["Triggerbot"] then
        e["Triggerbot"].Button.Text = getgenv().Triggerbot.Enabled and "ACTIVE" or "OFF"
        e["Triggerbot"].Button.BackgroundColor3 = getgenv().Triggerbot.Enabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 55)
    end
    if e["ESP"] then
        e["ESP"].Button.Text = getgenv().ESP.Enabled and "ACTIVE" or "OFF"
        e["ESP"].Button.BackgroundColor3 = getgenv().ESP.Enabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 55)
    end
    if e["Fly"] then
        e["Fly"].Button.Text = getgenv().Fly.Enabled and "ACTIVE" or "OFF"
        e["Fly"].Button.BackgroundColor3 = getgenv().Fly.Enabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 55)
    end
    if e["Noclip"] then
        e["Noclip"].Button.Text = getgenv().Noclip.Enabled and "ACTIVE" or "OFF"
        e["Noclip"].Button.BackgroundColor3 = getgenv().Noclip.Enabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 55)
    end
    if e["Fake Macro"] then
        e["Fake Macro"].Button.Text = getgenv().FakeMacro.Enabled and "ACTIVE" or "OFF"
        e["Fake Macro"].Button.BackgroundColor3 = getgenv().FakeMacro.Enabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 55)
    end
    if e["Loop Kill"] then
        e["Loop Kill"].Button.Text = getgenv().LoopKill.Enabled and "ACTIVE" or "OFF"
        e["Loop Kill"].Button.BackgroundColor3 = getgenv().LoopKill.Enabled and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(45, 45, 55)
    end
    if e["Tornado"] then
        e["Tornado"].Button.Text = getgenv().Tornado.Enabled and "ACTIVE" or "OFF"
        e["Tornado"].Button.BackgroundColor3 = getgenv().Tornado.Enabled and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(45, 45, 55)
    end
end

local function CreateToggle(name, key, parentTab, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0.95, 0, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Frame.Parent = parentTab
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = CuteFont
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0, 70, 0, 26)
    Btn.Position = UDim2.new(1, -80, 0.5, -13)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Btn.Font = CuteFont
    Btn.Text = "OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 12
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    Btn.MouseButton1Click:Connect(callback)
    Elements[name] = {Button = Btn}
end

local TargetFrame = Instance.new("Frame", Tabs.Exploits)
TargetFrame.Size = UDim2.new(0.95, 0, 0, 40)
TargetFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Instance.new("UICorner", TargetFrame).CornerRadius = UDim.new(0, 8)

local TargetLabel = Instance.new("TextLabel", TargetFrame)
TargetLabel.Size = UDim2.new(1, -120, 1, 0)
TargetLabel.Position = UDim2.new(0, 10, 0, 0)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Font = CuteFont
TargetLabel.Text = "TARGET: NONE"
TargetLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
TargetLabel.TextSize = 13
TargetLabel.TextXAlignment = Enum.TextXAlignment.Left

local SelectBtn = Instance.new("TextButton", TargetFrame)
SelectBtn.Size = UDim2.new(0, 100, 0, 26)
SelectBtn.Position = UDim2.new(1, -110, 0.5, -13)
SelectBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
SelectBtn.Font = CuteFont
SelectBtn.Text = "SELECT"
SelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectBtn.TextSize = 12
Instance.new("UICorner", SelectBtn).CornerRadius = UDim.new(0, 6)

local PlayerListFrame = Instance.new("Frame", Tabs.Exploits)
PlayerListFrame.Size = UDim2.new(0.95, 0, 0, 0)
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
PlayerListFrame.ClipsDescendants = true
Instance.new("UIListLayout", PlayerListFrame)

local function GetClosestPlayer()
    local ClosestDist, Closest = 1000, nil
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local Pos, Vis = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if Vis then
                local Dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Pos.X, Pos.Y)).Magnitude
                if Dist < ClosestDist then ClosestDist = Dist Closest = v end
            end
        end
    end
    return Closest
end

SelectBtn.MouseButton1Click:Connect(function()
    for _, child in pairs(PlayerListFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    if PlayerListFrame.Size.Y.Offset == 0 then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local pBtn = Instance.new("TextButton", PlayerListFrame)
                pBtn.Size = UDim2.new(1, 0, 0, 25)
                pBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                pBtn.Font = CuteFont
                pBtn.Text = p.DisplayName
                pBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                pBtn.TextSize = 11
                pBtn.MouseButton1Click:Connect(function()
                    SelectedPlayerForTP = p
                    TargetLabel.Text = "TARGET: " .. p.DisplayName:upper()
                    TweenService:Create(PlayerListFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.95, 0, 0, 0)}):Play()
                end)
            end
        end
        local newSize = math.min(#PlayerListFrame:GetChildren() * 25, 125)
        TweenService:Create(PlayerListFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0.95, 0, 0, newSize)}):Play()
    else
        TweenService:Create(PlayerListFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.95, 0, 0, 0)}):Play()
    end
end)

local function ToggleFly()
    getgenv().Fly.Enabled = not getgenv().Fly.Enabled
    local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if Root and getgenv().Fly.Enabled then
        local BV = Root:FindFirstChild("VantaFlyBV") or Instance.new("BodyVelocity")
        BV.Name = "VantaFlyBV"
        BV.Parent = Root
        BV.MaxForce = Vector3.new(1e8, 1e8, 1e8)
        
        local BG = Root:FindFirstChild("VantaFlyBG") or Instance.new("BodyGyro")
        BG.Name = "VantaFlyBG"
        BG.Parent = Root
        BG.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
        
        task.spawn(function()
            while getgenv().Fly.Enabled and Root.Parent do
                local Dir = Vector3.new(0,0,0)
                if UIS:IsKeyDown(Enum.KeyCode.W) then Dir = Dir + Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then Dir = Dir - Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then Dir = Dir - Camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then Dir = Dir + Camera.CFrame.RightVector end
                BV.Velocity = Dir * getgenv().Fly.Speed
                BG.CFrame = Camera.CFrame
                RunService.RenderStepped:Wait()
            end
            if BV then BV:Destroy() end
            if BG then BG:Destroy() end
        end)
    end
    UpdateUI()
end

CreateToggle("Aimbot", getgenv().Aimbot.Keybind, Tabs.Exploits, function() TargetPlayer = (not TargetPlayer and GetClosestPlayer()) or nil UpdateUI() end)
CreateToggle("Triggerbot", getgenv().Triggerbot.Keybind, Tabs.Exploits, function() getgenv().Triggerbot.Enabled = not getgenv().Triggerbot.Enabled UpdateUI() end)
CreateToggle("ESP", getgenv().ESP.Keybind, Tabs.Exploits, function() getgenv().ESP.Enabled = not getgenv().ESP.Enabled UpdateUI() end)
CreateToggle("Fly", getgenv().Fly.Keybind, Tabs.Exploits, ToggleFly)
CreateToggle("Noclip", getgenv().Noclip.Keybind, Tabs.Exploits, function() getgenv().Noclip.Enabled = not getgenv().Noclip.Enabled UpdateUI() end)
CreateToggle("Fake Macro", getgenv().FakeMacro.Keybind, Tabs.Exploits, function() getgenv().FakeMacro.Enabled = not getgenv().FakeMacro.Enabled UpdateUI() end)
CreateToggle("Loop Kill", getgenv().LoopKill.Keybind, Tabs.Exploits, function() 
    getgenv().LoopKill.Enabled = not getgenv().LoopKill.Enabled 
    if getgenv().LoopKill.Enabled then getgenv().Tornado.Enabled = false end
    UpdateUI() 
end)
CreateToggle("Tornado", getgenv().Tornado.Keybind, Tabs.Exploits, function() 
    getgenv().Tornado.Enabled = not getgenv().Tornado.Enabled 
    if getgenv().Tornado.Enabled then getgenv().LoopKill.Enabled = false end
    UpdateUI() 
end)

local function GetArmor()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local shops = Workspace:FindFirstChild("Ignored") and Workspace.Ignored:FindFirstChild("Shop")
        if shops then
            for _, v in pairs(shops:GetChildren()) do
                if v.Name:find("Armor") and v:FindFirstChild("Head") and v:FindFirstChild("ClickDetector") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = v.Head.CFrame * CFrame.new(0, 3, 0)
                    task.wait(0.1)
                    fireclickdetector(v.ClickDetector)
                    return
                end
            end
        end
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-607, 21, -633)
    end
end

local ArmorBtn = Instance.new("TextButton", Tabs.Exploits)
ArmorBtn.Size = UDim2.new(0.95, 0, 0, 40)
ArmorBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
ArmorBtn.Text = "BUY ARMOR [K]"
ArmorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ArmorBtn.Font = CuteFont
ArmorBtn.TextSize = 14
Instance.new("UICorner", ArmorBtn).CornerRadius = UDim.new(0, 8)
ArmorBtn.MouseButton1Click:Connect(GetArmor)

--- ### CREDITS TAB
local function AddCredit(txt, color)
    local l = Instance.new("TextLabel", Tabs.Credits)
    l.Size = UDim2.new(0.95, 0, 0, 30)
    l.BackgroundTransparency = 1
    l.Font = CuteFont
    l.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    l.TextSize = 15
    l.Text = txt
end

AddCredit("--- CORE TEAM ---", Color3.fromRGB(255, 255, 255))
AddCredit("Head Dev: Vantablade", Color3.fromRGB(0, 170, 255))
AddCredit("UI Design: Vantablade & Community", Color3.fromRGB(0, 255, 255))
AddCredit("Optimization: Core Engine Team", Color3.fromRGB(255, 255, 100))
AddCredit("--- SOCIALS ---", Color3.fromRGB(255, 255, 255))
AddCredit("YouTube: @VantabladeYT", Color3.fromRGB(255, 100, 100))
AddCredit("Discord: discord.gg/ERNQpp8NpE", Color3.fromRGB(114, 137, 218))
AddCredit("--- SPECIAL THANKS ---", Color3.fromRGB(255, 255, 255))
AddCredit("Testers: Vanta Elite Group", Color3.fromRGB(150, 255, 150))
AddCredit("Legacy Support: Jace Scripts", Color3.fromRGB(200, 200, 200))
AddCredit("Theme Inspiration: Modern Glass UI", Color3.fromRGB(255, 150, 255))
AddCredit("Version: Premier Edition v5.1.0", Color3.fromRGB(0, 170, 255))

--- ### GAME RENDER LOOPS
local function GetHealthColor(percent)
    if percent > 0.7 then return Color3.fromRGB(0, 255, 127) 
    elseif percent > 0.3 then return Color3.fromRGB(255, 255, 0)
    else return Color3.fromRGB(255, 60, 60) end
end

local function CreateESP(Player)
    local Box, Name = Drawing.new("Square"), Drawing.new("Text")
    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        if getgenv().ESP.Enabled and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player ~= LocalPlayer then
            local RootPart = Player.Character.HumanoidRootPart
            local Hum = Player.Character:FindFirstChildOfClass("Humanoid")
            local Head = Player.Character:FindFirstChild("Head")
            if not Hum or not Head then return end
            local RootPos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
            if OnScreen then
                local HeadPos = Camera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
                local LegPos = Camera:WorldToViewportPoint(RootPart.Position - Vector3.new(0, 3, 0))
                local BoxHeight = math.abs(HeadPos.Y - LegPos.Y)
                local BoxWidth = BoxHeight / 1.6
                local Color = GetHealthColor(Hum.Health / Hum.MaxHealth)
                Box.Visible = true Box.Color = Color Box.Size = Vector2.new(BoxWidth, BoxHeight)
                Box.Position = Vector2.new(RootPos.X - BoxWidth / 2, RootPos.Y - BoxHeight / 2)
                Box.Thickness = 1
                Name.Visible = true Name.Text = Player.DisplayName .. "\n" .. math.floor(Hum.Health) .. " HP"
                Name.Size = 15 Name.Center = true Name.Outline = true Name.Color = Color
                Name.Position = Vector2.new(RootPos.X, RootPos.Y - (BoxHeight / 2) - 35)
            else Box.Visible = false Name.Visible = false end
        else
            Box.Visible = false Name.Visible = false
            if not Player.Parent then Box:Remove() Name:Remove() Connection:Disconnect() end
        end
    end)
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

UIS.InputBegan:Connect(function(i, g)
    if g then return end
    local key = i.KeyCode
    if key == getgenv().Settings.MinimizeKey then ToggleUI() end
    
    local aimKey = tostring(getgenv().Aimbot.Keybind):upper()
    local trigKey = tostring(getgenv().Triggerbot.Keybind):upper()
    local espKey = tostring(getgenv().ESP.Keybind):upper()
    local flyKey = tostring(getgenv().Fly.Keybind):upper()
    local noclipKey = tostring(getgenv().Noclip.Keybind):upper()
    local macroKey = tostring(getgenv().FakeMacro.Keybind):upper()
    local loopKey = tostring(getgenv().LoopKill.Keybind):upper()
    local tornKey = tostring(getgenv().Tornado.Keybind):upper()

    if key == Enum.KeyCode[aimKey] then TargetPlayer = (not TargetPlayer and GetClosestPlayer()) or nil UpdateUI()
    elseif key == Enum.KeyCode[trigKey] then getgenv().Triggerbot.Enabled = not getgenv().Triggerbot.Enabled UpdateUI()
    elseif key == Enum.KeyCode[espKey] then getgenv().ESP.Enabled = not getgenv().ESP.Enabled UpdateUI()
    elseif key == Enum.KeyCode[flyKey] then ToggleFly()
    elseif key == Enum.KeyCode[noclipKey] then getgenv().Noclip.Enabled = not getgenv().Noclip.Enabled UpdateUI()
    elseif key == Enum.KeyCode[macroKey] then getgenv().FakeMacro.Enabled = not getgenv().FakeMacro.Enabled UpdateUI()
    elseif key == Enum.KeyCode[loopKey] then 
        getgenv().LoopKill.Enabled = not getgenv().LoopKill.Enabled 
        if getgenv().LoopKill.Enabled then getgenv().Tornado.Enabled = false end
        UpdateUI()
    elseif key == Enum.KeyCode[tornKey] then 
        getgenv().Tornado.Enabled = not getgenv().Tornado.Enabled 
        if getgenv().Tornado.Enabled then getgenv().LoopKill.Enabled = false end
        UpdateUI()
    elseif key == Enum.KeyCode.K then GetArmor() end
end)

local tornadoAngle, LastClickTime, ClickDelay = 0, 0, 1 / 25

RunService.Heartbeat:Connect(function()
    if getgenv().Noclip.Enabled and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
    if getgenv().LoopKill.Enabled and SelectedPlayerForTP and SelectedPlayerForTP.Character and SelectedPlayerForTP.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = SelectedPlayerForTP.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
    end
    if getgenv().Tornado.Enabled and SelectedPlayerForTP and SelectedPlayerForTP.Character and SelectedPlayerForTP.Character:FindFirstChild("HumanoidRootPart") then
        local targetRoot = SelectedPlayerForTP.Character.HumanoidRootPart
        tornadoAngle = tornadoAngle + 0.1
        local targetPos = targetRoot.Position + Vector3.new(math.cos(tornadoAngle) * 7.5, 0, math.sin(tornadoAngle) * 7.5)
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos, targetRoot.Position)
    end
    if getgenv().FakeMacro.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local Hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Hum and Hum.MoveDirection.Magnitude > 0 then
            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + (Hum.MoveDirection * (getgenv().FakeMacro.SpeedMultiplier / 10))
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if TargetPlayer and getgenv().Aimbot.Status and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild(getgenv().Aimbot.Hitpart) then
        local Part = TargetPlayer.Character[getgenv().Aimbot.Hitpart]
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Part.Position + (Part.Velocity * Vector3.new(getgenv().Aimbot.Prediction.X, getgenv().Aimbot.Prediction.Y, getgenv().Aimbot.Prediction.X)))
    end
    if getgenv().Triggerbot.Enabled then
        local MouseRay = Camera:ViewportPointToRay(Mouse.X, Mouse.Y)
        local Result = Workspace:Raycast(MouseRay.Origin, MouseRay.Direction * 1000)
        if Result and Result.Instance then
            local HitPart = Result.Instance
            local HitModel = HitPart:FindFirstAncestorOfClass("Model")
            local HitPlayer = Players:GetPlayerFromCharacter(HitModel)
            
            -- Detect any player part (Head, Torso, Arms, etc.) excluding self
            if HitPlayer and HitPlayer ~= LocalPlayer then
                if tick() - LastClickTime >= ClickDelay then
                    mouse1press()
                    task.wait()
                    mouse1release()
                    LastClickTime = tick()
                end
            end
        end
    end
end)

UpdateUI()
