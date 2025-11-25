--[[
    Aurora UI Library V3 (Enhanced)
    
    New Features:
    - Built-in Settings Menu (Gear Icon)
    - Mutable Keybinds for UI Toggling
    - Real-time Theme Customization (Accent/Background)
    - Improved Aesthetics & Icons
    
    Usage:
    local Library = loadstring(game:HttpGet("..."))()
    local Window = Library:CreateWindow({
        Name = "My Script",
        IntroText = "Loading...",
        ToggleKey = Enum.KeyCode.RightControl
    })
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {
    Open = true,
    ToggleKey = Enum.KeyCode.RightControl,
    Theme = {
        Background = Color3.fromRGB(20, 20, 24),
        Header = Color3.fromRGB(28, 28, 32),
        TextColor = Color3.fromRGB(240, 240, 240),
        ElementColor = Color3.fromRGB(32, 32, 36),
        Accent = Color3.fromRGB(114, 137, 218), -- Blurple-ish default
        Hover = Color3.fromRGB(40, 40, 45),
        Font = Enum.Font.GothamMedium,
        TextSize = 14
    },
    ActiveTweens = {},
    ThemeObjects = {} -- For real-time updates
}

--// Utility Functions
local function Create(class, properties)
    local instance = Instance.new(class)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

local function Tween(instance, info, properties)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

local function RegisterThemeObject(instance, property, themeKey)
    if not Library.ThemeObjects[themeKey] then Library.ThemeObjects[themeKey] = {} end
    table.insert(Library.ThemeObjects[themeKey], {Object = instance, Property = property})
    -- Apply current
    instance[property] = Library.Theme[themeKey]
end

local function UpdateTheme(themeKey, color)
    Library.Theme[themeKey] = color
    if Library.ThemeObjects[themeKey] then
        for _, data in pairs(Library.ThemeObjects[themeKey]) do
            if data.Object then
                Tween(data.Object, TweenInfo.new(0.3), {[data.Property] = color})
            end
        end
    end
end

--// UI Protection
local ParentObj = nil
if gethui then
    ParentObj = gethui()
elseif syn and syn.protect_gui then 
    ParentObj = CoreGui 
    syn.protect_gui(ParentObj)
else
    ParentObj = CoreGui
end

--// Notification System
local NotificationHolder = nil
function Library:Notify(Settings)
    if not NotificationHolder then
        NotificationHolder = Create("ScreenGui", {
            Name = "AuroraNotifications",
            Parent = ParentObj,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        })
        local Container = Create("Frame", {
            Parent = NotificationHolder,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -320, 1, -50),
            Size = UDim2.new(0, 300, 1, 0),
            AnchorPoint = Vector2.new(0, 1)
        })
        Create("UIListLayout", {
            Parent = Container,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding = UDim.new(0, 10)
        })
        NotificationHolder = Container
    end

    local Title = Settings.Title or "Notification"
    local Content = Settings.Content or ""
    local Duration = Settings.Duration or 3
    
    local NotifFrame = Create("Frame", {
        Parent = NotificationHolder,
        BackgroundColor3 = Library.Theme.Header,
        Size = UDim2.new(1, 0, 0, 0),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        BackgroundTransparency = 0.1
    })
    Create("UICorner", {Parent = NotifFrame, CornerRadius = UDim.new(0, 6)})
    
    local TitleLabel = Create("TextLabel", {
        Parent = NotifFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = Title,
        TextColor3 = Library.Theme.Accent,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local ContentLabel = Create("TextLabel", {
        Parent = NotifFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 25),
        Size = UDim2.new(1, -20, 0, 30),
        Font = Library.Theme.Font,
        Text = Content,
        TextColor3 = Library.Theme.TextColor,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })

    -- Animate
    Tween(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 60)})
    
    task.delay(Duration, function()
        local t = Tween(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})
        t.Completed:Connect(function() NotifFrame:Destroy() end)
    end)
end

--// Main Library Logic
function Library:CreateWindow(Settings)
    local Name = Settings.Name or "Aurora Library"
    local IntroText = Settings.IntroText or "Welcome"
    Library.ToggleKey = Settings.ToggleKey or Enum.KeyCode.RightControl
    
    local AuroraGUI = Create("ScreenGui", {
        Name = "AuroraGUI",
        Parent = ParentObj,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = AuroraGUI,
        BackgroundColor3 = Library.Theme.Background,
        Position = UDim2.new(0.5, -275, 0.5, -175),
        Size = UDim2.new(0, 550, 0, 350),
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 8)})
    RegisterThemeObject(MainFrame, "BackgroundColor3", "Background")
    
    local Header = Create("Frame", {
        Name = "Header",
        Parent = MainFrame,
        BackgroundColor3 = Library.Theme.Header,
        Size = UDim2.new(1, 0, 0, 40),
        BorderSizePixel = 0
    })
    Create("UICorner", {Parent = Header, CornerRadius = UDim.new(0, 8)})
    RegisterThemeObject(Header, "BackgroundColor3", "Header")

    -- Fix header bottom corners
    local HeaderCover = Create("Frame", {
        Parent = Header,
        BackgroundColor3 = Library.Theme.Header,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -5),
        Size = UDim2.new(1, 0, 0, 5),
        ZIndex = 1
    })
    RegisterThemeObject(HeaderCover, "BackgroundColor3", "Header")

    local Title = Create("TextLabel", {
        Name = "Title",
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0.6, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = Name,
        TextColor3 = Library.Theme.TextColor,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2
    })
    RegisterThemeObject(Title, "TextColor3", "TextColor")

    local ContentContainer = Create("Frame", {
        Name = "Content",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 1, -40)
    })

    --// TopBar Buttons
    local ButtonContainer = Create("Frame", {
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -100, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
        ZIndex = 2
    })
    
    local function CreateIconBtn(name, iconId, layoutOrder, callback)
        local Btn = Create("ImageButton", {
            Name = name,
            Parent = ButtonContainer,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -30 * layoutOrder, 0, 5),
            Size = UDim2.new(0, 30, 0, 30),
            Image = iconId,
            ImageColor3 = Color3.fromRGB(200, 200, 200),
            ZIndex = 3
        })
        Btn.MouseEnter:Connect(function() Tween(Btn, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(255, 255, 255)}) end)
        Btn.MouseLeave:Connect(function() Tween(Btn, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(200, 200, 200)}) end)
        Btn.MouseButton1Click:Connect(callback)
        return Btn
    end

    -- Icons (Roblox Asset IDs for generic icons)
    -- Close: X
    local CloseBtn = CreateIconBtn("Close", "rbxassetid://6031094678", 1, function()
        AuroraGUI:Destroy()
    end)
    
    -- Minimize: Dash
    local MinBtn = CreateIconBtn("Minimize", "rbxassetid://6031094667", 2, function() end)

    -- Settings: Gear
    local SettingsBtn = CreateIconBtn("Settings", "rbxassetid://6031280882", 3, function() end)

    --// Settings Panel
    local SettingsPanel = Create("Frame", {
        Name = "SettingsPanel",
        Parent = MainFrame,
        BackgroundColor3 = Library.Theme.Background,
        BackgroundTransparency = 0.05,
        Position = UDim2.new(0, 0, 1, 0), -- Start off screen
        Size = UDim2.new(1, 0, 1, -40),
        ZIndex = 20,
        Visible = false
    })
    RegisterThemeObject(SettingsPanel, "BackgroundColor3", "Background")
    
    local SettingsList = Create("ScrollingFrame", {
        Parent = SettingsPanel,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(1, -20, 1, -20),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2
    })
    Create("UIListLayout", {Parent = SettingsList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})

    local SettingsOpen = false
    SettingsBtn.MouseButton1Click:Connect(function()
        SettingsOpen = not SettingsOpen
        if SettingsOpen then
            SettingsPanel.Visible = true
            SettingsPanel.Position = UDim2.new(0, 0, 1, 0)
            Tween(SettingsPanel, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 40)})
            ContentContainer.Visible = false
        else
            local t = Tween(SettingsPanel, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(0, 0, 1, 0)})
            t.Completed:Connect(function() 
                if not SettingsOpen then SettingsPanel.Visible = false end 
            end)
            ContentContainer.Visible = true
        end
    end)

    -- Minimize Logic
    local Minimized = false
    local OldSize = MainFrame.Size
    MinBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            OldSize = MainFrame.Size
            Tween(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 550, 0, 40)})
            ContentContainer.Visible = false
            SettingsPanel.Visible = false
            HeaderCover.Visible = false
            MainFrame.UICorner.CornerRadius = UDim.new(0, 8)
        else
            Tween(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = OldSize})
            task.wait(0.2)
            if not SettingsOpen then ContentContainer.Visible = true end
            if SettingsOpen then SettingsPanel.Visible = true end
            HeaderCover.Visible = true
        end
    end)

    --// Dragging
    local DragToggle, DragInput, DragStart, StartPos
    Header.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            DragToggle = true
            DragStart = input.Position
            StartPos = MainFrame.Position
            input.Changed:Connect(function() if (input.UserInputState == Enum.UserInputState.End) then DragToggle = false end end)
        end
    end)
    Header.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then DragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if (input == DragInput and DragToggle) then
            local Delta = input.Position - DragStart
            Tween(MainFrame, TweenInfo.new(0.05), {Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)})
        end
    end)

    --// Toggle Key Logic
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Library.ToggleKey then
            Library.Open = not Library.Open
            MainFrame.Visible = Library.Open
        end
    end)

    --// Tab System
    local TabContainer = Create("ScrollingFrame", {
        Parent = ContentContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(0, 130, 1, -20),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2
    })
    Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
    
    local PagesContainer = Create("Frame", {
        Parent = ContentContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 150, 0, 10),
        Size = UDim2.new(1, -160, 1, -20),
        ClipsDescendants = true
    })
    
    -- Separator
    local Sep = Create("Frame", {
        Parent = ContentContainer,
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 145, 0, 10),
        Size = UDim2.new(0, 1, 1, -20)
    })
    RegisterThemeObject(Sep, "BackgroundColor3", "Hover")

    local WindowFunctions = {}
    local FirstTab = true

    --// Internal Element Generators
    local function CreateElementFrame(parent)
        local Frame = Create("Frame", {
            Parent = parent,
            BackgroundColor3 = Library.Theme.ElementColor,
            Size = UDim2.new(1, -5, 0, 35)
        })
        Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 6)})
        RegisterThemeObject(Frame, "BackgroundColor3", "ElementColor")
        return Frame
    end

    local function AddElementLabel(parent, text)
        local Label = Create("TextLabel", {
            Parent = parent,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(0.6, 0, 1, 0),
            Font = Library.Theme.Font,
            Text = text,
            TextColor3 = Library.Theme.TextColor,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        RegisterThemeObject(Label, "TextColor3", "TextColor")
        return Label
    end

    --// POPULATE SETTINGS PANEL
    do
        local SLabel = Create("TextLabel", {
            Parent = SettingsList,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 25),
            Font = Enum.Font.GothamBold,
            Text = "CONFIGURATION",
            TextColor3 = Library.Theme.Accent,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        RegisterThemeObject(SLabel, "TextColor3", "Accent")

        -- Toggle Keybind
        local KeyFrame = CreateElementFrame(SettingsList)
        AddElementLabel(KeyFrame, "Menu Toggle Key")
        local KeyBtn = Create("TextButton", {
            Parent = KeyFrame,
            BackgroundColor3 = Library.Theme.Background,
            Position = UDim2.new(1, -85, 0.5, -12),
            Size = UDim2.new(0, 75, 0, 24),
            Font = Enum.Font.GothamBold,
            Text = Library.ToggleKey.Name,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 12
        })
        Create("UICorner", {Parent = KeyBtn, CornerRadius = UDim.new(0, 4)})
        RegisterThemeObject(KeyBtn, "BackgroundColor3", "Background")

        local KeyBinding = false
        KeyBtn.MouseButton1Click:Connect(function()
            KeyBinding = true
            KeyBtn.Text = "..."
        end)
        UserInputService.InputBegan:Connect(function(input)
            if KeyBinding and input.UserInputType == Enum.UserInputType.Keyboard then
                KeyBinding = false
                Library.ToggleKey = input.KeyCode
                KeyBtn.Text = input.KeyCode.Name
            end
        end)

        -- Theme: Accent
        local AccentFrame = CreateElementFrame(SettingsList)
        AddElementLabel(AccentFrame, "Accent Color")
        
        -- Simple preset toggles for "Color Picker" simulation in settings for brevity
        local ColorContainer = Create("Frame", {
            Parent = AccentFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -150, 0, 0),
            Size = UDim2.new(0, 140, 1, 0)
        })
        Create("UIListLayout", {Parent = ColorContainer, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0,5), VerticalAlignment = Enum.VerticalAlignment.Center})
        
        local Presets = {
            Color3.fromRGB(114, 137, 218), -- Blurple
            Color3.fromRGB(255, 85, 85),   -- Red
            Color3.fromRGB(85, 255, 127),  -- Green
            Color3.fromRGB(255, 170, 0)    -- Orange
        }

        for _, c in ipairs(Presets) do
            local pBtn = Create("TextButton", {
                Parent = ColorContainer,
                BackgroundColor3 = c,
                Size = UDim2.new(0, 20, 0, 20),
                Text = "",
                AutoButtonColor = false
            })
            Create("UICorner", {Parent = pBtn, CornerRadius = UDim.new(1,0)})
            pBtn.MouseButton1Click:Connect(function()
                UpdateTheme("Accent", c)
            end)
        end
    end

    function WindowFunctions:CreateTab(TabName)
        local TabButton = Create("TextButton", {
            Parent = TabContainer,
            BackgroundColor3 = Library.Theme.ElementColor,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            Font = Library.Theme.Font,
            Text = TabName,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            TextSize = 14,
            AutoButtonColor = false
        })
        Create("UICorner", {Parent = TabButton, CornerRadius = UDim.new(0, 6)})
        RegisterThemeObject(TabButton, "BackgroundColor3", "ElementColor")

        local Page = Create("ScrollingFrame", {
            Name = TabName.."Page",
            Parent = PagesContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 2,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })
        Create("UIListLayout", {Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
        Page.ChildAdded:Connect(function() Page.CanvasSize = UDim2.new(0,0,0, Page.UIListLayout.AbsoluteContentSize.Y + 10) end)

        if FirstTab then
            FirstTab = false
            TabButton.TextColor3 = Library.Theme.TextColor
            TabButton.BackgroundTransparency = 0
            Page.Visible = true
        end

        TabButton.MouseButton1Click:Connect(function()
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Tween(v, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150)})
                end
            end
            for _, v in pairs(PagesContainer:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
            end
            Tween(TabButton, TweenInfo.new(0.2), {BackgroundTransparency = 0, TextColor3 = Library.Theme.TextColor})
            Page.Visible = true
        end)

        local TabFunctions = {}
        
        function TabFunctions:CreateSection(SectionName)
            local Label = Create("TextLabel", {
                Parent = Page,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 25),
                Font = Enum.Font.GothamBold,
                Text = SectionName,
                TextColor3 = Library.Theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            RegisterThemeObject(Label, "TextColor3", "TextColor")
            Create("UIPadding", {Parent = Label, PaddingLeft = UDim.new(0, 5)})
        end

        function TabFunctions:CreateLabel(Text)
            local Label = Create("TextLabel", {
                Parent = Page,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Font = Library.Theme.Font,
                Text = Text,
                TextColor3 = Color3.fromRGB(180, 180, 180),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            Create("UIPadding", {Parent = Label, PaddingLeft = UDim.new(0, 5)})
        end

        function TabFunctions:CreateButton(BtnSettings)
            local BtnFrame = Create("TextButton", {
                Parent = Page,
                BackgroundColor3 = Library.Theme.ElementColor,
                Size = UDim2.new(1, -5, 0, 35),
                Font = Library.Theme.Font,
                Text = BtnSettings.Name or "Button",
                TextColor3 = Library.Theme.TextColor,
                TextSize = 14,
                AutoButtonColor = false
            })
            Create("UICorner", {Parent = BtnFrame, CornerRadius = UDim.new(0, 6)})
            RegisterThemeObject(BtnFrame, "BackgroundColor3", "ElementColor")
            RegisterThemeObject(BtnFrame, "TextColor3", "TextColor")

            BtnFrame.MouseEnter:Connect(function() Tween(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Hover}) end)
            BtnFrame.MouseLeave:Connect(function() Tween(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.ElementColor}) end)
            BtnFrame.MouseButton1Click:Connect(BtnSettings.Callback or function() end)
        end

        function TabFunctions:CreateToggle(ToggleSettings)
            local ToggleFrame = CreateElementFrame(Page)
            local ToggleBtn = Create("TextButton", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })
            local Label = AddElementLabel(ToggleFrame, ToggleSettings.Name or "Toggle")
            
            local State = ToggleSettings.CurrentValue or false
            local CheckBox = Create("Frame", {
                Parent = ToggleFrame,
                BackgroundColor3 = State and Library.Theme.Accent or Color3.fromRGB(60, 60, 60),
                Position = UDim2.new(1, -50, 0.5, -10),
                Size = UDim2.new(0, 40, 0, 20)
            })
            Create("UICorner", {Parent = CheckBox, CornerRadius = UDim.new(1, 0)})
            RegisterThemeObject(CheckBox, "BackgroundColor3", State and "Accent" or "ElementColor") -- Conditional handled manually below
            
            local Circle = Create("Frame", {
                Parent = CheckBox,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16)
            })
            Create("UICorner", {Parent = Circle, CornerRadius = UDim.new(1, 0)})
            
            ToggleBtn.MouseButton1Click:Connect(function()
                State = not State
                Tween(CheckBox, TweenInfo.new(0.2), {BackgroundColor3 = State and Library.Theme.Accent or Color3.fromRGB(60, 60, 60)})
                Tween(Circle, TweenInfo.new(0.2), {Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                if ToggleSettings.Callback then ToggleSettings.Callback(State) end
            end)
        end

        function TabFunctions:CreateSlider(SliderSettings)
            local SliderFrame = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Library.Theme.ElementColor,
                Size = UDim2.new(1, -5, 0, 50)
            })
            Create("UICorner", {Parent = SliderFrame, CornerRadius = UDim.new(0, 6)})
            RegisterThemeObject(SliderFrame, "BackgroundColor3", "ElementColor")
            
            AddElementLabel(SliderFrame, SliderSettings.Name or "Slider")
            
            local ValueLabel = Create("TextLabel", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(1, -20, 0, 20),
                Font = Library.Theme.Font,
                Text = tostring(SliderSettings.CurrentValue or 0),
                TextColor3 = Library.Theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right
            })
            RegisterThemeObject(ValueLabel, "TextColor3", "TextColor")

            local SliderBar = Create("Frame", {
                Parent = SliderFrame,
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                Position = UDim2.new(0, 10, 0, 30),
                Size = UDim2.new(1, -20, 0, 6)
            })
            Create("UICorner", {Parent = SliderBar, CornerRadius = UDim.new(1, 0)})
            
            local Fill = Create("Frame", {
                Parent = SliderBar,
                BackgroundColor3 = Library.Theme.Accent,
                Size = UDim2.new(0, 0, 1, 0)
            })
            Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
            RegisterThemeObject(Fill, "BackgroundColor3", "Accent")

            -- Logic
            local Min, Max = SliderSettings.Range[1], SliderSettings.Range[2]
            local Default = SliderSettings.CurrentValue or Min
            
            local function Update(val)
                local pct = math.clamp((val - Min) / (Max - Min), 0, 1)
                Fill.Size = UDim2.new(pct, 0, 1, 0)
                ValueLabel.Text = tostring(val)
            end
            Update(Default)
            
            local Trigger = Create("TextButton", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })
            
            local dragging = false
            Trigger.MouseButton1Down:Connect(function() dragging = true end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local SizeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    local NewValue = math.floor(((Min + ((Max - Min) * SizeX)) / (SliderSettings.Increment or 1)) + 0.5) * (SliderSettings.Increment or 1)
                    Update(NewValue)
                    if SliderSettings.Callback then SliderSettings.Callback(NewValue) end
                end
            end)
        end

        function TabFunctions:CreateDropdown(Settings)
            local DropFrame = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Library.Theme.ElementColor,
                Size = UDim2.new(1, -5, 0, 35),
                ClipsDescendants = true,
                ZIndex = 5
            })
            Create("UICorner", {Parent = DropFrame, CornerRadius = UDim.new(0, 6)})
            RegisterThemeObject(DropFrame, "BackgroundColor3", "ElementColor")
            
            local HeaderBtn = Create("TextButton", {
                Parent = DropFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 35),
                Text = "",
                ZIndex = 6
            })
            AddElementLabel(HeaderBtn, Settings.Name or "Dropdown")
            
            local CurrentText = Create("TextLabel", {
                Parent = HeaderBtn,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0, 0),
                Size = UDim2.new(0.5, -30, 1, 0),
                Font = Library.Theme.Font,
                Text = Settings.CurrentOption or Settings.Options[1] or "",
                TextColor3 = Library.Theme.Accent,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right
            })
            RegisterThemeObject(CurrentText, "TextColor3", "Accent")

            local Container = Create("ScrollingFrame", {
                Parent = DropFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 35),
                Size = UDim2.new(1, 0, 1, -35),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 2,
                ZIndex = 6
            })
            Create("UIListLayout", {Parent = Container, SortOrder = Enum.SortOrder.LayoutOrder})
            
            local expanded = false
            local function BuildList()
                for _, c in pairs(Container:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                for _, opt in ipairs(Settings.Options) do
                    local b = Create("TextButton", {
                        Parent = Container,
                        BackgroundColor3 = Library.Theme.ElementColor,
                        Size = UDim2.new(1, 0, 0, 30),
                        Font = Library.Theme.Font,
                        Text = opt,
                        TextColor3 = Library.Theme.TextColor,
                        TextSize = 13,
                        AutoButtonColor = false,
                        ZIndex = 7
                    })
                    b.MouseButton1Click:Connect(function()
                        CurrentText.Text = opt
                        if Settings.Callback then Settings.Callback(opt) end
                        expanded = false
                        Tween(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -5, 0, 35)})
                    end)
                end
                Container.CanvasSize = UDim2.new(0,0,0, #Settings.Options * 30)
            end
            
            HeaderBtn.MouseButton1Click:Connect(function()
                expanded = not expanded
                if expanded then
                    BuildList()
                    Tween(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -5, 0, 150)})
                else
                    Tween(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -5, 0, 35)})
                end
            end)
        end

        return TabFunctions
    end
    
    -- Final Init
    Tween(MainFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0})
    Tween(Title, TweenInfo.new(0.5), {TextTransparency = 0})
    
    return WindowFunctions
end

return Library
