--[[
    VANTAHOOD V7 - PREMIER EDITION (REFINED AESTHETIC)
    CHARACTER OPTIMIZED BUILD: ~+45,000 CHARACTERS
    
    FONT THEME: FredokaOne (Rounded & Cute)
    
]]

-- ### BLACKLIST SYSTEM ###
local BlacklistedIDs = {
    ["5913858916"] = true,
    -- Add more IDs here: ["ID_HERE"] = true,
}

if BlacklistedIDs[tostring(game.GameId)] or BlacklistedIDs[tostring(game.PlaceId)] then
    game:GetService("Players").LocalPlayer:Kick("Game Blacklisted")
    return
end
-- ########################

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

getgenv().Armor = {
    Keybind = 'K'
}

getgenv().Settings = {
    MinimizeKey = 'Y',
    IsVisible = true,
    Transparency = 0
}

getgenv().Visuals = {
    Tracers = {
        Enabled = false,
        Color = Color3.fromRGB(0, 170, 255),
        Thickness = 1,
        From = "Bottom"  -- Options: "Bottom", "Center", "Mouse"
    },
    Skeletons = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1
    },
    Chams = {
        Enabled = false,
        Color = Color3.fromRGB(0, 170, 255),
        Transparency = 0.5
    },
    HeadDots = {
        Enabled = false,
        Color = Color3.fromRGB(255, 0, 0),
        Size = 5,
        Filled = true
    },
    HealthBars = {
        Enabled = false,
        Color = Color3.fromRGB(0, 255, 0),
        Width = 5
    },
    DistanceText = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255)
    },
    WeaponText = {
        Enabled = false,
        Color = Color3.fromRGB(200, 200, 200)
    }
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
MainFrame.Visible = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 170, 255)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.5

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1,0,0,30)
TitleBar.BackgroundColor3 = Color3.fromRGB(15,15,20)
TitleBar.BorderSizePixel = 0

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(1,0,1,0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = CuteFont
TitleLabel.Text = "VANTAHOOD V7"
TitleLabel.TextColor3 = Color3.fromRGB(0,170,255)
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Custom Dragging on TitleBar
local dragging = false
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        local conn
        conn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                conn:Disconnect()
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input == dragInput) then
        update(input)
    end
end)

-- Side Bar
local SideBar = Instance.new("Frame")
SideBar.Name = "SideBar"
SideBar.Parent = MainFrame
SideBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
SideBar.Position = UDim2.new(0, 0, 0, 30)
SideBar.Size = UDim2.new(0, 140, 1, -30)
SideBar.BorderSizePixel = 0
Instance.new("UICorner", SideBar).CornerRadius = UDim.new(0, 10)

local SideStroke = Instance.new("UIStroke", SideBar)
SideStroke.Color = Color3.fromRGB(0, 170, 255)
SideStroke.Thickness = 1
SideStroke.Transparency = 0.7

-- Top Navigation Container
local TopNav = Instance.new("Frame", SideBar)
TopNav.Size = UDim2.new(1, 0, 0.7, 0)
TopNav.BackgroundTransparency = 1

local TopNavList = Instance.new("UIListLayout", TopNav)
TopNavList.Padding = UDim.new(0, 8)
TopNavList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TopNavList.SortOrder = Enum.SortOrder.LayoutOrder

local TopSpacer = Instance.new("Frame", TopNav)
TopSpacer.Size = UDim2.new(1, 0, 0, 15)
TopSpacer.BackgroundTransparency = 1
TopSpacer.LayoutOrder = 0

local function NavBtn(text, order)
    local btn = Instance.new("TextButton", TopNav)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.Font = CuteFont
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 15
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Color3.fromRGB(0, 170, 255)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.8
    return btn
end

local ExpBtn = NavBtn("Exploits", 1)
local SetBtn = NavBtn("Settings", 2)
local VisBtn = NavBtn("Visuals", 3)
local CrdBtn = NavBtn("Credits", 4)

-- Bottom Branding Section
local BottomNav = Instance.new("Frame", SideBar)
BottomNav.Size = UDim2.new(1, 0, 0, 85)
BottomNav.Position = UDim2.new(0, 0, 1, -85)
BottomNav.BackgroundTransparency = 1

local BottomNavList = Instance.new("UIListLayout", BottomNav)
BottomNavList.VerticalAlignment = Enum.VerticalAlignment.Bottom
BottomNavList.HorizontalAlignment = Enum.HorizontalAlignment.Center
BottomNavList.Padding = UDim.new(0, 3)
BottomNavList.SortOrder = Enum.SortOrder.LayoutOrder

local YTLabel = Instance.new("TextLabel", BottomNav)
YTLabel.Size = UDim2.new(1, 0, 0, 18)
YTLabel.BackgroundTransparency = 1
YTLabel.Font = CuteFont
YTLabel.Text = "@VantabladeYT"
YTLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
YTLabel.TextSize = 12
YTLabel.LayoutOrder = 1 

local DiscLabel = Instance.new("TextLabel", BottomNav)
DiscLabel.Size = UDim2.new(1, 0, 0, 18)
DiscLabel.BackgroundTransparency = 1
DiscLabel.Font = CuteFont
DiscLabel.Text = "discord.gg/ERNQpp8NpE"
DiscLabel.TextColor3 = Color3.fromRGB(114, 137, 218)
DiscLabel.TextSize = 10
DiscLabel.LayoutOrder = 2 

local MainTitle = Instance.new("TextLabel", BottomNav)
MainTitle.Size = UDim2.new(1, 0, 0, 40)
MainTitle.BackgroundTransparency = 1
MainTitle.Font = CuteFont
MainTitle.Text = "VANTAHOOD V7"
MainTitle.TextColor3 = Color3.fromRGB(0, 170, 255)
MainTitle.TextSize = 18
MainTitle.LayoutOrder = 3

-- Container for Tabs
local Container = Instance.new("Frame", MainFrame)
Container.Name = "Container"
Container.Position = UDim2.new(0, 150, 0, 40)
Container.Size = UDim2.new(1, -160, 1, -50)
Container.BackgroundTransparency = 1

local Tabs = {
    Exploits = Instance.new("ScrollingFrame", Container),
    Settings = Instance.new("ScrollingFrame", Container),
    Visuals = Instance.new("ScrollingFrame", Container),
    Credits = Instance.new("ScrollingFrame", Container)
}

for name, frame in pairs(Tabs) do
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = (name == "Exploits")
    frame.ScrollBarThickness = 3
    frame.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
    frame.CanvasSize = UDim2.new(0, 0, 0, 1200) -- Increased for more content
    local layout = Instance.new("UIListLayout", frame)
    layout.Padding = UDim.new(0, 12)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
end

local function ToggleUI()
    getgenv().Settings.IsVisible = not getgenv().Settings.IsVisible
    MainFrame.Visible = getgenv().Settings.IsVisible
end

-- REDUCED MOBILE UI SIZE
if IsMobile then
    local MobileBtn = Instance.new("TextButton", ScreenGui)
    MobileBtn.Name = "MobileToggle"
    MobileBtn.Size = UDim2.new(0, 40, 0, 40)
    MobileBtn.Position = UDim2.new(0, 10, 0.5, -20)
    MobileBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MobileBtn.BorderSizePixel = 0
    MobileBtn.Text = "VH"
    MobileBtn.Font = CuteFont
    MobileBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
    MobileBtn.TextSize = 16
    MobileBtn.Draggable = true
    MobileBtn.Active = true
    Instance.new("UICorner", MobileBtn).CornerRadius = UDim.new(0, 10)
    local mobStroke = Instance.new("UIStroke", MobileBtn)
    mobStroke.Color = Color3.fromRGB(0, 170, 255)
    mobStroke.Thickness = 1
    mobStroke.Transparency = 0.5
    MobileBtn.MouseButton1Click:Connect(ToggleUI)
end

local function SwitchTab(tabName)
    for name, frame in pairs(Tabs) do
        frame.Visible = (name == tabName)
    end
end

ExpBtn.MouseButton1Click:Connect(function() SwitchTab("Exploits") end)
SetBtn.MouseButton1Click:Connect(function() SwitchTab("Settings") end)
VisBtn.MouseButton1Click:Connect(function() SwitchTab("Visuals") end)
CrdBtn.MouseButton1Click:Connect(function() SwitchTab("Credits") end)

local Elements = {}

local function CreateKeybindSetter(name, currentKey, configTable, configKey, parent, order)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(0.95, 0, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Frame.LayoutOrder = order
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    local frameStroke = Instance.new("UIStroke", Frame)
    frameStroke.Color = Color3.fromRGB(45, 45, 55)
    frameStroke.Thickness = 1

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
    BindBtn.Size = UDim2.new(0, 90, 0, 30)
    BindBtn.Position = UDim2.new(1, -100, 0.5, -15)
    BindBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    BindBtn.Font = CuteFont
    BindBtn.Text = "SET BIND"
    BindBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
    BindBtn.TextSize = 13
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

local function CreateSlider(name, configTable, configKey, min, max, parent, order)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(0.95, 0, 0, 60)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Frame.LayoutOrder = order
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    local frameStroke = Instance.new("UIStroke", Frame)
    frameStroke.Color = Color3.fromRGB(45, 45, 55)
    frameStroke.Thickness = 1

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Font = CuteFont
    Label.Text = name .. ": " .. configTable[configKey]
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local SliderBack = Instance.new("Frame", Frame)
    SliderBack.Size = UDim2.new(0.9, 0, 0, 8)
    SliderBack.Position = UDim2.new(0.05, 0, 0.6, 0)
    SliderBack.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Instance.new("UICorner", SliderBack)

    local SliderFill = Instance.new("Frame", SliderBack)
    SliderFill.Size = UDim2.new((configTable[configKey] - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    Instance.new("UICorner", SliderFill)

    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
        configTable[configKey] = math.floor(min + (max - min) * pos * 100) / 100
        Label.Text = name .. ": " .. configTable[configKey]
    end

    SliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local connection
            connection = UIS.InputChanged:Connect(function(change)
                if change.UserInputType == Enum.UserInputType.MouseMovement or change.UserInputType == Enum.UserInputType.Touch then
                    UpdateSlider(change)
                end
            end)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then connection:Disconnect() end
            end)
            UpdateSlider(input)
        end
    end)
end

local function CreateColorPicker(name, configTable, configKey, parent, order)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(0.95, 0, 0, 150)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Frame.LayoutOrder = order
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    local frameStroke = Instance.new("UIStroke", Frame)
    frameStroke.Color = Color3.fromRGB(45, 45, 55)
    frameStroke.Thickness = 1

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Font = CuteFont
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local function CreateRGBSlider(channel, posY, default)
        local SliderLabel = Instance.new("TextLabel", Frame)
        SliderLabel.Size = UDim2.new(0.2, 0, 0, 20)
        SliderLabel.Position = UDim2.new(0.05, 0, posY, 0)
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Font = CuteFont
        SliderLabel.Text = channel
        SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        SliderLabel.TextSize = 12

        local SliderBack = Instance.new("Frame", Frame)
        SliderBack.Size = UDim2.new(0.7, 0, 0, 8)
        SliderBack.Position = UDim2.new(0.25, 0, posY + 0.025, 0)
        SliderBack.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        Instance.new("UICorner", SliderBack)

        local SliderFill = Instance.new("Frame", SliderBack)
        SliderFill.Size = UDim2.new(default / 255, 0, 1, 0)
        SliderFill.BackgroundColor3 = (channel == "R" and Color3.fromRGB(255,0,0)) or (channel == "G" and Color3.fromRGB(0,255,0)) or Color3.fromRGB(0,0,255)
        Instance.new("UICorner", SliderFill)

        local function UpdateSlider(input)
            local pos = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
            SliderFill.Size = UDim2.new(pos, 0, 1, 0)
            local r,g,b = configTable[configKey].r * 255, configTable[configKey].g * 255, configTable[configKey].b * 255
            if channel == "R" then r = pos * 255 elseif channel == "G" then g = pos * 255 else b = pos * 255 end
            configTable[configKey] = Color3.fromRGB(r, g, b)
        end

        SliderBack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local connection
                connection = UIS.InputChanged:Connect(function(change)
                    if change.UserInputType == Enum.UserInputType.MouseMovement or change.UserInputType == Enum.UserInputType.Touch then
                        UpdateSlider(change)
                    end
                end)
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then connection:Disconnect() end
                end)
                UpdateSlider(input)
            end
        end)
    end

    CreateRGBSlider("R", 0.2, configTable[configKey].R * 255)
    CreateRGBSlider("G", 0.4, configTable[configKey].G * 255)
    CreateRGBSlider("B", 0.6, configTable[configKey].B * 255)
end

--- ### SETTINGS TAB
local ThemeHeader = Instance.new("TextLabel", Tabs.Settings)
ThemeHeader.Size = UDim2.new(0.95, 0, 0, 35)
ThemeHeader.BackgroundTransparency = 1
ThemeHeader.Font = CuteFont
ThemeHeader.Text = "--- UI CUSTOMIZATION ---"
ThemeHeader.TextColor3 = Color3.fromRGB(0, 170, 255)
ThemeHeader.TextSize = 14
ThemeHeader.LayoutOrder = 1

-- Transparency Slider
local TransparencyFrame = Instance.new("Frame", Tabs.Settings)
TransparencyFrame.Size = UDim2.new(0.95, 0, 0, 60)
TransparencyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TransparencyFrame.LayoutOrder = 1.1
Instance.new("UICorner", TransparencyFrame).CornerRadius = UDim.new(0, 8)
local transStroke = Instance.new("UIStroke", TransparencyFrame)
transStroke.Color = Color3.fromRGB(45, 45, 55)
transStroke.Thickness = 1

local TransLabel = Instance.new("TextLabel", TransparencyFrame)
TransLabel.Size = UDim2.new(1, 0, 0, 25)
TransLabel.Position = UDim2.new(0, 10, 0, 5)
TransLabel.BackgroundTransparency = 1
TransLabel.Font = CuteFont
TransLabel.Text = "MENU TRANSPARENCY: 0%"
TransLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TransLabel.TextSize = 13
TransLabel.TextXAlignment = Enum.TextXAlignment.Left

local SliderBack = Instance.new("Frame", TransparencyFrame)
SliderBack.Size = UDim2.new(0.9, 0, 0, 8)
SliderBack.Position = UDim2.new(0.05, 0, 0.6, 0)
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
FontDropdownFrame.Size = UDim2.new(0.95, 0, 0, 40)
FontDropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
FontDropdownFrame.ClipsDescendants = true
FontDropdownFrame.LayoutOrder = 1.2
Instance.new("UICorner", FontDropdownFrame).CornerRadius = UDim.new(0, 8)

local FontDropBtn = Instance.new("TextButton", FontDropdownFrame)
FontDropBtn.Size = UDim2.new(1, 0, 0, 40)
FontDropBtn.BackgroundTransparency = 1
FontDropBtn.Font = CuteFont
FontDropBtn.Text = "SELECT FONT (FREDOKA DEFAULT) ▼"
FontDropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FontDropBtn.TextSize = 13

local FontDropContainer = Instance.new("Frame", FontDropdownFrame)
FontDropContainer.Position = UDim2.new(0, 0, 0, 40)
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
    fBtn.Size = UDim2.new(1, 0, 0, 35)
    fBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    fBtn.BorderSizePixel = 0
    fBtn.Font = font
    fBtn.Text = name
    fBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    fBtn.TextSize = 13
    fBtn.MouseButton1Click:Connect(function()
        CuteFont = font
        for _, v in pairs(ScreenGui:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then v.Font = font end
        end
        TweenService:Create(FontDropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.95, 0, 0, 40)}):Play()
    end)
end

FontDropBtn.MouseButton1Click:Connect(function()
    local targetHeight = (FontDropdownFrame.Size.Y.Offset == 40) and 220 or 40
    TweenService:Create(FontDropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0.95, 0, 0, targetHeight)}):Play()
end)

local DropdownFrame = Instance.new("Frame", Tabs.Settings)
DropdownFrame.Size = UDim2.new(0.95, 0, 0, 40)
DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
DropdownFrame.ClipsDescendants = true
DropdownFrame.LayoutOrder = 2
Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 8)

local DropBtn = Instance.new("TextButton", DropdownFrame)
DropBtn.Size = UDim2.new(1, 0, 0, 40)
DropBtn.BackgroundTransparency = 1
DropBtn.Font = CuteFont
DropBtn.Text = "SELECT BACKGROUND COLOR ▼"
DropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DropBtn.TextSize = 13

local DropContainer = Instance.new("Frame", DropdownFrame)
DropContainer.Position = UDim2.new(0, 0, 0, 40)
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
    tBtn.Size = UDim2.new(1, 0, 0, 35)
    tBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    tBtn.BorderSizePixel = 0
    tBtn.Font = CuteFont
    tBtn.Text = name
    tBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tBtn.TextSize = 13
    tBtn.MouseButton1Click:Connect(function()
        MainFrame.BackgroundColor3 = color
        SideBar.BackgroundColor3 = color + Color3.fromRGB(10, 10, 10) -- Slightly lighter for sidebar
        TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.95, 0, 0, 40)}):Play()
    end)
end

DropBtn.MouseButton1Click:Connect(function()
    local targetHeight = (DropdownFrame.Size.Y.Offset == 40) and 220 or 40
    TweenService:Create(DropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0.95, 0, 0, targetHeight)}):Play()
end)

local BindHeader = Instance.new("TextLabel", Tabs.Settings)
BindHeader.Size = UDim2.new(0.95, 0, 0, 35)
BindHeader.BackgroundTransparency = 1
BindHeader.Font = CuteFont
BindHeader.Text = "--- CORE BINDINGS ---"
BindHeader.TextColor3 = Color3.fromRGB(0, 170, 255)
BindHeader.TextSize = 14
BindHeader.LayoutOrder = 3

CreateKeybindSetter("Minimize GUI", getgenv().Settings.MinimizeKey, getgenv().Settings, "MinimizeKey", Tabs.Settings, 4)
CreateKeybindSetter("Aimbot", getgenv().Aimbot.Keybind, getgenv().Aimbot, "Keybind", Tabs.Settings, 5)
CreateKeybindSetter("Triggerbot", getgenv().Triggerbot.Keybind, getgenv().Triggerbot, "Keybind", Tabs.Settings, 6)
CreateKeybindSetter("ESP", getgenv().ESP.Keybind, getgenv().ESP, "Keybind", Tabs.Settings, 7)
CreateKeybindSetter("Fly", getgenv().Fly.Keybind, getgenv().Fly, "Keybind", Tabs.Settings, 8)
CreateKeybindSetter("Noclip", getgenv().Noclip.Keybind, getgenv().Noclip, "Keybind", Tabs.Settings, 9)
CreateKeybindSetter("Fake Macro", getgenv().FakeMacro.Keybind, getgenv().FakeMacro, "Keybind", Tabs.Settings, 10)
CreateKeybindSetter("Loop Kill", getgenv().LoopKill.Keybind, getgenv().LoopKill, "Keybind", Tabs.Settings, 11)
CreateKeybindSetter("Tornado", getgenv().Tornado.Keybind, getgenv().Tornado, "Keybind", Tabs.Settings, 12)
CreateKeybindSetter("Buy Armor", getgenv().Armor.Keybind, getgenv().Armor, "Keybind", Tabs.Settings, 13)

local ValuesHeader = Instance.new("TextLabel", Tabs.Settings)
ValuesHeader.Size = UDim2.new(0.95, 0, 0, 35)
ValuesHeader.BackgroundTransparency = 1
ValuesHeader.Font = CuteFont
ValuesHeader.Text = "--- FEATURE VALUES ---"
ValuesHeader.TextColor3 = Color3.fromRGB(0, 170, 255)
ValuesHeader.TextSize = 14
ValuesHeader.LayoutOrder = 14

CreateSlider("Aimbot Pred X", getgenv().Aimbot.Prediction, "X", 0, 1, Tabs.Settings, 15)
CreateSlider("Aimbot Pred Y", getgenv().Aimbot.Prediction, "Y", 0, 1, Tabs.Settings, 16)
CreateSlider("Fly Speed", getgenv().Fly, "Speed", 50, 500, Tabs.Settings, 17)
CreateSlider("Fake Macro Speed", getgenv().FakeMacro, "SpeedMultiplier", 10, 50, Tabs.Settings, 18)

local RejoinBtn = Instance.new("TextButton", Tabs.Settings)
RejoinBtn.Size = UDim2.new(0.95, 0, 0, 45)
RejoinBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
RejoinBtn.Text = "EMERGENCY SERVER REJOIN"
RejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RejoinBtn.Font = CuteFont
RejoinBtn.LayoutOrder = 19
Instance.new("UICorner", RejoinBtn).CornerRadius = UDim.new(0, 8)
RejoinBtn.MouseButton1Click:Connect(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end)

--- ### VISUALS TAB
local VisualsHeader = Instance.new("TextLabel", Tabs.Visuals)
VisualsHeader.Size = UDim2.new(0.95, 0, 0, 35)
VisualsHeader.BackgroundTransparency = 1
VisualsHeader.Font = CuteFont
VisualsHeader.Text = "--- VISUAL EXPLOITS ---"
VisualsHeader.TextColor3 = Color3.fromRGB(0, 170, 255)
VisualsHeader.TextSize = 14
VisualsHeader.LayoutOrder = 0

local function CreateVisualToggle(name, config, parent, order, desc)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0.95, 0, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Frame.Parent = parent
    Frame.LayoutOrder = order
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    local frameStroke = Instance.new("UIStroke", Frame)
    frameStroke.Color = Color3.fromRGB(45, 45, 55)
    frameStroke.Thickness = 1

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.6, 0, 0.6, 0)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Font = CuteFont
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 15
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local DescLabel = Instance.new("TextLabel", Frame)
    DescLabel.Size = UDim2.new(0.6, 0, 0.4, 0)
    DescLabel.Position = UDim2.new(0, 10, 0.6, 0)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Font = CuteFont
    DescLabel.Text = desc or ""
    DescLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    DescLabel.TextSize = 11
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.TextWrapped = true

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0, 75, 0, 30)
    Btn.Position = UDim2.new(1, -85, 0.5, -15)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Btn.Font = CuteFont
    Btn.Text = config.Enabled and "ON" or "OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 13
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    Btn.MouseButton1Click:Connect(function()
        config.Enabled = not config.Enabled
        Btn.Text = config.Enabled and "ON" or "OFF"
        Btn.BackgroundColor3 = config.Enabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 55)
    end)
end

CreateVisualToggle("Tracers", getgenv().Visuals.Tracers, Tabs.Visuals, 1, "Draws lines to players")
CreateColorPicker("Tracers Color", getgenv().Visuals.Tracers, "Color", Tabs.Visuals, 2)
CreateSlider("Tracers Thickness", getgenv().Visuals.Tracers, "Thickness", 1, 5, Tabs.Visuals, 3)

local TracerFromDropdown = Instance.new("Frame", Tabs.Visuals)
TracerFromDropdown.Size = UDim2.new(0.95, 0, 0, 40)
TracerFromDropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TracerFromDropdown.ClipsDescendants = true
TracerFromDropdown.LayoutOrder = 4
Instance.new("UICorner", TracerFromDropdown).CornerRadius = UDim.new(0, 8)

local TracerDropBtn = Instance.new("TextButton", TracerFromDropdown)
TracerDropBtn.Size = UDim2.new(1, 0, 0, 40)
TracerDropBtn.BackgroundTransparency = 1
TracerDropBtn.Font = CuteFont
TracerDropBtn.Text = "TRACER FROM: " .. getgenv().Visuals.Tracers.From .. " ▼"
TracerDropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TracerDropBtn.TextSize = 13

local TracerDropContainer = Instance.new("Frame", TracerFromDropdown)
TracerDropContainer.Position = UDim2.new(0, 0, 0, 40)
TracerDropContainer.Size = UDim2.new(1, 0, 0, 120)
TracerDropContainer.BackgroundTransparency = 1
Instance.new("UIListLayout", TracerDropContainer)

local tracerFromOptions = {"Bottom", "Center", "Mouse"}

for _, opt in ipairs(tracerFromOptions) do
    local optBtn = Instance.new("TextButton", TracerDropContainer)
    optBtn.Size = UDim2.new(1, 0, 0, 35)
    optBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    optBtn.BorderSizePixel = 0
    optBtn.Font = CuteFont
    optBtn.Text = opt
    optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    optBtn.TextSize = 13
    optBtn.MouseButton1Click:Connect(function()
        getgenv().Visuals.Tracers.From = opt
        TracerDropBtn.Text = "TRACER FROM: " .. opt .. " ▼"
        TweenService:Create(TracerFromDropdown, TweenInfo.new(0.3), {Size = UDim2.new(0.95, 0, 0, 40)}):Play()
    end)
end

TracerDropBtn.MouseButton1Click:Connect(function()
    local targetHeight = (TracerFromDropdown.Size.Y.Offset == 40) and 160 or 40
    TweenService:Create(TracerFromDropdown, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0.95, 0, 0, targetHeight)}):Play()
end)

CreateVisualToggle("Skeletons", getgenv().Visuals.Skeletons, Tabs.Visuals, 5, "Draws player skeletons")
CreateColorPicker("Skeletons Color", getgenv().Visuals.Skeletons, "Color", Tabs.Visuals, 6)
CreateSlider("Skeletons Thickness", getgenv().Visuals.Skeletons, "Thickness", 1, 5, Tabs.Visuals, 7)

CreateVisualToggle("Chams", getgenv().Visuals.Chams, Tabs.Visuals, 8, "Highlights player models")
CreateColorPicker("Chams Color", getgenv().Visuals.Chams, "Color", Tabs.Visuals, 9)
CreateSlider("Chams Transparency", getgenv().Visuals.Chams, "Transparency", 0, 1, Tabs.Visuals, 10)

CreateVisualToggle("Head Dots", getgenv().Visuals.HeadDots, Tabs.Visuals, 11, "Draws dots on heads")
CreateColorPicker("Head Dots Color", getgenv().Visuals.HeadDots, "Color", Tabs.Visuals, 12)
CreateSlider("Head Dots Size", getgenv().Visuals.HeadDots, "Size", 1, 10, Tabs.Visuals, 13)

CreateVisualToggle("Health Bars", getgenv().Visuals.HealthBars, Tabs.Visuals, 14, "Draws health bars")
CreateColorPicker("Health Bars Color", getgenv().Visuals.HealthBars, "Color", Tabs.Visuals, 15)
CreateSlider("Health Bars Width", getgenv().Visuals.HealthBars, "Width", 1, 10, Tabs.Visuals, 16)

CreateVisualToggle("Distance Text", getgenv().Visuals.DistanceText, Tabs.Visuals, 17, "Shows distance to players")
CreateColorPicker("Distance Text Color", getgenv().Visuals.DistanceText, "Color", Tabs.Visuals, 18)

CreateVisualToggle("Weapon Text", getgenv().Visuals.WeaponText, Tabs.Visuals, 19, "Shows held weapons")
CreateColorPicker("Weapon Text Color", getgenv().Visuals.WeaponText, "Color", Tabs.Visuals, 20)

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

local function CreateToggle(name, key, parentTab, callback, order, desc)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0.95, 0, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Frame.Parent = parentTab
    Frame.LayoutOrder = order
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    local frameStroke = Instance.new("UIStroke", Frame)
    frameStroke.Color = Color3.fromRGB(45, 45, 55)
    frameStroke.Thickness = 1

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.6, 0, 0.6, 0)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Font = CuteFont
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 15
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local DescLabel = Instance.new("TextLabel", Frame)
    DescLabel.Size = UDim2.new(0.6, 0, 0.4, 0)
    DescLabel.Position = UDim2.new(0, 10, 0.6, 0)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Font = CuteFont
    DescLabel.Text = desc or ""
    DescLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    DescLabel.TextSize = 11
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.TextWrapped = true

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0, 75, 0, 30)
    Btn.Position = UDim2.new(1, -85, 0.5, -15)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Btn.Font = CuteFont
    Btn.Text = "OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 13
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    Btn.MouseButton1Click:Connect(callback)
    Elements[name] = {Button = Btn}
end

local CombatHeader = Instance.new("TextLabel", Tabs.Exploits)
CombatHeader.Size = UDim2.new(0.95, 0, 0, 35)
CombatHeader.BackgroundTransparency = 1
CombatHeader.Font = CuteFont
CombatHeader.Text = "--- COMBAT EXPLOITS ---"
CombatHeader.TextColor3 = Color3.fromRGB(0, 170, 255)
CombatHeader.TextSize = 14
CombatHeader.LayoutOrder = 0

local TargetFrame = Instance.new("Frame", Tabs.Exploits)
TargetFrame.Size = UDim2.new(0.95, 0, 0, 50)
TargetFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TargetFrame.LayoutOrder = 1
Instance.new("UICorner", TargetFrame).CornerRadius = UDim.new(0, 8)
local targetStroke = Instance.new("UIStroke", TargetFrame)
targetStroke.Color = Color3.fromRGB(45, 45, 55)
targetStroke.Thickness = 1

local TargetLabel = Instance.new("TextLabel", TargetFrame)
TargetLabel.Size = UDim2.new(1, -120, 1, 0)
TargetLabel.Position = UDim2.new(0, 10, 0, 0)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Font = CuteFont
TargetLabel.Text = "TARGET: NONE"
TargetLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
TargetLabel.TextSize = 14
TargetLabel.TextXAlignment = Enum.TextXAlignment.Left

local SelectBtn = Instance.new("TextButton", TargetFrame)
SelectBtn.Size = UDim2.new(0, 105, 0, 30)
SelectBtn.Position = UDim2.new(1, -115, 0.5, -15)
SelectBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
SelectBtn.Font = CuteFont
SelectBtn.Text = "SELECT"
SelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectBtn.TextSize = 13
Instance.new("UICorner", SelectBtn).CornerRadius = UDim.new(0, 6)

local PlayerListFrame = Instance.new("ScrollingFrame", Tabs.Exploits)
PlayerListFrame.Size = UDim2.new(0.95, 0, 0, 0)
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
PlayerListFrame.ScrollBarThickness = 4
PlayerListFrame.ScrollBarImageColor3 = Color3.fromRGB(0,170,255)
PlayerListFrame.ClipsDescendants = true
PlayerListFrame.LayoutOrder = 2

local PlayerListLayout = Instance.new("UIListLayout", PlayerListFrame)
PlayerListLayout.SortOrder = Enum.SortOrder.LayoutOrder

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
    for _, child in pairs(PlayerListFrame:GetChildren()) do if not child:IsA("UIListLayout") then child:Destroy() end end
    if PlayerListFrame.Size.Y.Offset == 0 then
        local playerButtons = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local pBtn = Instance.new("TextButton", PlayerListFrame)
                pBtn.Size = UDim2.new(1, 0, 0, 30)
                pBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                pBtn.Font = CuteFont
                pBtn.Text = p.DisplayName
                pBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                pBtn.TextSize = 12
                pBtn.MouseButton1Click:Connect(function()
                    SelectedPlayerForTP = p
                    TargetLabel.Text = "TARGET: " .. p.DisplayName:upper()
                    TweenService:Create(PlayerListFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.95, 0, 0, 0)}):Play()
                end)
                table.insert(playerButtons, pBtn)
            end
        end
        local numPlayers = #playerButtons
        local newSize = math.min(numPlayers * 30, 150)
        PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, numPlayers * 30)
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

CreateToggle("Aimbot", getgenv().Aimbot.Keybind, Tabs.Exploits, function() TargetPlayer = (not TargetPlayer and GetClosestPlayer()) or nil UpdateUI() end, 3, "Locks camera to closest player")
CreateToggle("Triggerbot", getgenv().Triggerbot.Keybind, Tabs.Exploits, function() getgenv().Triggerbot.Enabled = not getgenv().Triggerbot.Enabled UpdateUI() end, 4, "Auto-clicks on player parts")
CreateToggle("ESP", getgenv().ESP.Keybind, Tabs.Exploits, function() getgenv().ESP.Enabled = not getgenv().ESP.Enabled UpdateUI() end, 5, "Highlights players with boxes")

local MovementHeader = Instance.new("TextLabel", Tabs.Exploits)
MovementHeader.Size = UDim2.new(0.95, 0, 0, 35)
MovementHeader.BackgroundTransparency = 1
MovementHeader.Font = CuteFont
MovementHeader.Text = "--- MOVEMENT EXPLOITS ---"
MovementHeader.TextColor3 = Color3.fromRGB(0, 170, 255)
MovementHeader.TextSize = 14
MovementHeader.LayoutOrder = 6

CreateToggle("Fly", getgenv().Fly.Keybind, Tabs.Exploits, ToggleFly, 7, "Enables flying with WASD")
CreateToggle("Noclip", getgenv().Noclip.Keybind, Tabs.Exploits, function() getgenv().Noclip.Enabled = not getgenv().Noclip.Enabled UpdateUI() end, 8, "Walk through walls")
CreateToggle("Fake Macro", getgenv().FakeMacro.Keybind, Tabs.Exploits, function() getgenv().FakeMacro.Enabled = not getgenv().FakeMacro.Enabled UpdateUI() end, 9, "Boosts movement speed")

local KillHeader = Instance.new("TextLabel", Tabs.Exploits)
KillHeader.Size = UDim2.new(0.95, 0, 0, 35)
KillHeader.BackgroundTransparency = 1
KillHeader.Font = CuteFont
KillHeader.Text = "--- KILL EXPLOITS ---"
KillHeader.TextColor3 = Color3.fromRGB(0, 170, 255)
KillHeader.TextSize = 14
KillHeader.LayoutOrder = 10

CreateToggle("Loop Kill", getgenv().LoopKill.Keybind, Tabs.Exploits, function() 
    getgenv().LoopKill.Enabled = not getgenv().LoopKill.Enabled 
    if getgenv().LoopKill.Enabled then getgenv().Tornado.Enabled = false end
    UpdateUI() 
end, 11, "Teleports to target repeatedly")
CreateToggle("Tornado", getgenv().Tornado.Keybind, Tabs.Exploits, function() 
    getgenv().Tornado.Enabled = not getgenv().Tornado.Enabled 
    if getgenv().Tornado.Enabled then getgenv().LoopKill.Enabled = false end
    UpdateUI() 
end, 12, "Circles around target")

local UtilityHeader = Instance.new("TextLabel", Tabs.Exploits)
UtilityHeader.Size = UDim2.new(0.95, 0, 0, 35)
UtilityHeader.BackgroundTransparency = 1
UtilityHeader.Font = CuteFont
UtilityHeader.Text = "--- UTILITY ---"
UtilityHeader.TextColor3 = Color3.fromRGB(0, 170, 255)
UtilityHeader.TextSize = 14
UtilityHeader.LayoutOrder = 13

local ArmorBtn = Instance.new("TextButton", Tabs.Exploits)
ArmorBtn.Size = UDim2.new(0.95, 0, 0, 45)
ArmorBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
ArmorBtn.Text = "BUY ARMOR [COMING SOON]"
ArmorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ArmorBtn.Font = CuteFont
ArmorBtn.TextSize = 15
ArmorBtn.LayoutOrder = 14
Instance.new("UICorner", ArmorBtn).CornerRadius = UDim.new(0, 8)
ArmorBtn.MouseButton1Click:Connect(GetArmor)

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

--- ### CREDITS TAB
local function AddCredit(txt, color, size)
    local l = Instance.new("TextLabel", Tabs.Credits)
    l.Size = UDim2.new(0.95, 0, 0, size or 30)
    l.BackgroundTransparency = 1
    l.Font = CuteFont
    l.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    l.TextSize = 16
    l.Text = txt
    l.TextWrapped = true
end

AddCredit("--- CORE TEAM ---", Color3.fromRGB(255, 255, 255), 35)
AddCredit("Head Dev: Vantablade", Color3.fromRGB(0, 170, 255))
AddCredit("UI Design: Vantablade & Community", Color3.fromRGB(0, 255, 255))
AddCredit("Optimization: Core Engine Team", Color3.fromRGB(255, 255, 100))
AddCredit("--- SOCIALS ---", Color3.fromRGB(255, 255, 255), 35)
AddCredit("YouTube: @VantabladeYT", Color3.fromRGB(255, 100, 100))
AddCredit("Discord: discord.gg/ERNQpp8NpE", Color3.fromRGB(114, 137, 218))
AddCredit("--- SPECIAL THANKS ---", Color3.fromRGB(255, 255, 255), 35)
AddCredit("Testers: Vanta Elite Group", Color3.fromRGB(150, 255, 150))
AddCredit("Legacy Support: Jace Scripts", Color3.fromRGB(200, 200, 200))
AddCredit("Theme Inspiration: Modern Glass UI", Color3.fromRGB(255, 150, 255))
AddCredit("Version: Premier Edition v7.0.0", Color3.fromRGB(0, 170, 255))

--- ### GAME RENDER LOOPS
local function GetHealthColor(percent)
    if percent > 0.7 then return Color3.fromRGB(0, 255, 127) 
    elseif percent > 0.3 then return Color3.fromRGB(255, 255, 0)
    else return Color3.fromRGB(255, 60, 60) end
end

local function CreateESP(Player)
    local Box, Name = Drawing.new("Square"), Drawing.new("Text")
    local Tracer = Drawing.new("Line")
    local HeadDot = Drawing.new("Circle")
    local HealthBarBack = Drawing.new("Square")
    local HealthBarFill = Drawing.new("Square")
    local DistanceText = Drawing.new("Text")
    local WeaponText = Drawing.new("Text")
    local SkeletonLines = {}
    local ChamHighlight = Instance.new("Highlight")
    ChamHighlight.Parent = game.CoreGui
    ChamHighlight.Enabled = false

    local bones = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LowerTorso", "RightUpperLeg"},
        {"UpperTorso", "LeftUpperArm"},
        {"UpperTorso", "RightUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        {"RightLowerArm", "RightHand"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},
        {"RightLowerLeg", "RightFoot"}
    }

    for _, bonePair in ipairs(bones) do
        local line = Drawing.new("Line")
        line.Visible = false
        table.insert(SkeletonLines, line)
    end

    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player ~= LocalPlayer then
            local RootPart = Player.Character.HumanoidRootPart
            local Hum = Player.Character:FindFirstChildOfClass("Humanoid")
            local Head = Player.Character:FindFirstChild("Head")
            if not Hum or not Head then 
                Box.Visible = false Name.Visible = false Tracer.Visible = false HeadDot.Visible = false
                HealthBarBack.Visible = false HealthBarFill.Visible = false DistanceText.Visible = false WeaponText.Visible = false
                for _, line in ipairs(SkeletonLines) do line.Visible = false end
                ChamHighlight.Enabled = false
                return 
            end
            local RootPos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
            if OnScreen then
                local HeadPos = Camera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
                local LegPos = Camera:WorldToViewportPoint(RootPart.Position - Vector3.new(0, 3, 0))
                local BoxHeight = math.abs(HeadPos.Y - LegPos.Y)
                local BoxWidth = BoxHeight / 1.6
                local Color = GetHealthColor(Hum.Health / Hum.MaxHealth)

                -- Original ESP (unchanged)
                if getgenv().ESP.Enabled then
                    Box.Visible = true Box.Color = Color Box.Size = Vector2.new(BoxWidth, BoxHeight)
                    Box.Position = Vector2.new(RootPos.X - BoxWidth / 2, RootPos.Y - BoxHeight / 2)
                    Box.Thickness = 1
                    Name.Visible = true Name.Text = Player.DisplayName .. "\n" .. math.floor(Hum.Health) .. " HP"
                    Name.Size = 15 Name.Center = true Name.Outline = true Name.Color = Color
                    Name.Position = Vector2.new(RootPos.X, RootPos.Y - (BoxHeight / 2) - 35)
                else
                    Box.Visible = false Name.Visible = false
                end

                -- Tracers
                if getgenv().Visuals.Tracers.Enabled then
                    local fromPos
                    if getgenv().Visuals.Tracers.From == "Bottom" then
                        fromPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    elseif getgenv().Visuals.Tracers.From == "Center" then
                        fromPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    else  -- Mouse
                        fromPos = Vector2.new(Mouse.X, Mouse.Y)
                    end
                    Tracer.Visible = true
                    Tracer.Color = getgenv().Visuals.Tracers.Color
                    Tracer.Thickness = getgenv().Visuals.Tracers.Thickness
                    Tracer.From = fromPos
                    Tracer.To = Vector2.new(RootPos.X, RootPos.Y)
                else
                    Tracer.Visible = false
                end

                -- Head Dots
                if getgenv().Visuals.HeadDots.Enabled then
                    local headScreen = Camera:WorldToViewportPoint(Head.Position)
                    HeadDot.Visible = true
                    HeadDot.Color = getgenv().Visuals.HeadDots.Color
                    HeadDot.Radius = getgenv().Visuals.HeadDots.Size
                    HeadDot.Filled = getgenv().Visuals.HeadDots.Filled
                    HeadDot.Position = Vector2.new(headScreen.X, headScreen.Y)
                else
                    HeadDot.Visible = false
                end

                -- Health Bars
                if getgenv().Visuals.HealthBars.Enabled then
                    local healthPercent = Hum.Health / Hum.MaxHealth
                    HealthBarBack.Visible = true
                    HealthBarBack.Color = Color3.fromRGB(50, 50, 50)
                    HealthBarBack.Size = Vector2.new(getgenv().Visuals.HealthBars.Width, BoxHeight)
                    HealthBarBack.Position = Vector2.new(RootPos.X - BoxWidth / 2 - getgenv().Visuals.HealthBars.Width - 2, RootPos.Y - BoxHeight / 2)
                    HealthBarBack.Thickness = 1
                    HealthBarBack.Filled = true

                    HealthBarFill.Visible = true
                    HealthBarFill.Color = getgenv().Visuals.HealthBars.Color
                    HealthBarFill.Size = Vector2.new(getgenv().Visuals.HealthBars.Width, BoxHeight * healthPercent)
                    HealthBarFill.Position = HealthBarBack.Position + Vector2.new(0, BoxHeight - BoxHeight * healthPercent)
                    HealthBarFill.Thickness = 1
                    HealthBarFill.Filled = true
                else
                    HealthBarBack.Visible = false
                    HealthBarFill.Visible = false
                end

                -- Distance Text
                if getgenv().Visuals.DistanceText.Enabled then
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - RootPart.Position).Magnitude
                    DistanceText.Visible = true
                    DistanceText.Text = math.floor(distance) .. " studs"
                    DistanceText.Size = 14
                    DistanceText.Center = true
                    DistanceText.Outline = true
                    DistanceText.Color = getgenv().Visuals.DistanceText.Color
                    DistanceText.Position = Vector2.new(RootPos.X, RootPos.Y + BoxHeight / 2 + 5)
                else
                    DistanceText.Visible = false
                end

                -- Weapon Text
                if getgenv().Visuals.WeaponText.Enabled then
                    local tool = Player.Character:FindFirstChildOfClass("Tool")
                    local weaponName = tool and tool.Name or "None"
                    WeaponText.Visible = true
                    WeaponText.Text = "Weapon: " .. weaponName
                    WeaponText.Size = 14
                    WeaponText.Center = true
                    WeaponText.Outline = true
                    WeaponText.Color = getgenv().Visuals.WeaponText.Color
                    WeaponText.Position = Vector2.new(RootPos.X, RootPos.Y + BoxHeight / 2 + 20)
                else
                    WeaponText.Visible = false
                end

                -- Skeletons
                if getgenv().Visuals.Skeletons.Enabled then
                    for i, bonePair in ipairs(bones) do
                        local part1 = Player.Character:FindFirstChild(bonePair[1])
                        local part2 = Player.Character:FindFirstChild(bonePair[2])
                        if part1 and part2 then
                            local pos1, vis1 = Camera:WorldToViewportPoint(part1.Position)
                            local pos2, vis2 = Camera:WorldToViewportPoint(part2.Position)
                            if vis1 and vis2 then
                                SkeletonLines[i].Visible = true
                                SkeletonLines[i].Color = getgenv().Visuals.Skeletons.Color
                                SkeletonLines[i].Thickness = getgenv().Visuals.Skeletons.Thickness
                                SkeletonLines[i].From = Vector2.new(pos1.X, pos1.Y)
                                SkeletonLines[i].To = Vector2.new(pos2.X, pos2.Y)
                            else
                                SkeletonLines[i].Visible = false
                            end
                        else
                            SkeletonLines[i].Visible = false
                        end
                    end
                else
                    for _, line in ipairs(SkeletonLines) do line.Visible = false end
                end

                -- Chams
                if getgenv().Visuals.Chams.Enabled then
                    ChamHighlight.Adornee = Player.Character
                    ChamHighlight.FillColor = getgenv().Visuals.Chams.Color
                    ChamHighlight.FillTransparency = getgenv().Visuals.Chams.Transparency
                    ChamHighlight.OutlineColor = getgenv().Visuals.Chams.Color
                    ChamHighlight.OutlineTransparency = 0
                    ChamHighlight.Enabled = true
                else
                    ChamHighlight.Enabled = false
                end

            else
                Box.Visible = false Name.Visible = false Tracer.Visible = false HeadDot.Visible = false
                HealthBarBack.Visible = false HealthBarFill.Visible = false DistanceText.Visible = false WeaponText.Visible = false
                for _, line in ipairs(SkeletonLines) do line.Visible = false end
                ChamHighlight.Enabled = false
            end
        else
            Box.Visible = false Name.Visible = false Tracer.Visible = false HeadDot.Visible = false
            HealthBarBack.Visible = false HealthBarFill.Visible = false DistanceText.Visible = false WeaponText.Visible = false
            for _, line in ipairs(SkeletonLines) do line.Visible = false end
            ChamHighlight.Enabled = false
            if not Player.Parent then 
                Box:Remove() Name:Remove() Tracer:Remove() HeadDot:Remove()
                HealthBarBack:Remove() HealthBarFill:Remove() DistanceText:Remove() WeaponText:Remove()
                for _, line in ipairs(SkeletonLines) do line:Remove() end
                ChamHighlight:Destroy()
                Connection:Disconnect() 
            end
        end
    end)
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

UIS.InputBegan:Connect(function(i, g)
    if g then return end
    local key = i.KeyCode
    if key == Enum.KeyCode[getgenv().Settings.MinimizeKey:upper()] then ToggleUI() end
    
    local aimKey = tostring(getgenv().Aimbot.Keybind):upper()
    local trigKey = tostring(getgenv().Triggerbot.Keybind):upper()
    local espKey = tostring(getgenv().ESP.Keybind):upper()
    local flyKey = tostring(getgenv().Fly.Keybind):upper()
    local noclipKey = tostring(getgenv().Noclip.Keybind):upper()
    local macroKey = tostring(getgenv().FakeMacro.Keybind):upper()
    local loopKey = tostring(getgenv().LoopKill.Keybind):upper()
    local tornKey = tostring(getgenv().Tornado.Keybind):upper()
    local armorKey = tostring(getgenv().Armor.Keybind):upper()

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
    elseif key == Enum.KeyCode[armorKey] then GetArmor() end
end)

local tornadoAngle, LastClickTime, ClickDelay = 0, 0, 0

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
        local RaycastParamsInstance = RaycastParams.new() -- Integrated from vantahood triggerbot.lua
        RaycastParamsInstance.FilterType = Enum.RaycastFilterType.Include
        local filters = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                table.insert(filters, p.Character)
            end
        end
        RaycastParamsInstance.FilterDescendantsInstances = filters

        local Result = Workspace:Raycast(MouseRay.Origin, MouseRay.Direction * 1000, RaycastParamsInstance)
        if Result and Result.Instance then
            local HitPart = Result.Instance
            local HitModel = HitPart:FindFirstAncestorOfClass("Model")
            local HitPlayer = Players:GetPlayerFromCharacter(HitModel)
            
            -- Detect any player part (Head, Torso, Arms, etc.) excluding self
            if HitPlayer and HitPlayer ~= LocalPlayer then
                if tick() - LastClickTime >= ClickDelay then
                    mouse1press()
                    mouse1release()
                    LastClickTime = tick()
                end
            end
        end
    end
end)

UpdateUI()
