--[[
    Aurora UI Library V5 (Revamped)
    - Complete Visual Overhaul (Sidebar Layout, Card Design, Outlines)
    - Fixed Settings Menu (Now fully populated and functional)
    - Modern "Glass-like" Dark Theme
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
        Background = Color3.fromRGB(18, 18, 22),
        Sidebar = Color3.fromRGB(24, 24, 28),
        ElementBackground = Color3.fromRGB(28, 28, 32),
        TextColor = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(160, 160, 160),
        Accent = Color3.fromRGB(114, 137, 218), -- Blurple
        Stroke = Color3.fromRGB(50, 50, 55),
        Font = Enum.Font.GothamMedium,
        FontBold = Enum.Font.GothamBold
    },
    ThemeObjects = {}
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
        BackgroundColor3 = Library.Theme.Sidebar,
        Size = UDim2.new(1, 0, 0, 0),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        BackgroundTransparency = 0
    })
    Create("UICorner", {Parent = NotifFrame, CornerRadius = UDim.new(0, 6)})
    Create("UIStroke", {Parent = NotifFrame, Color = Library.Theme.Stroke, Thickness = 1})
    
    -- Accent Line
    local AccLine = Create("Frame", {
        Parent = NotifFrame,
        BackgroundColor3 = Library.Theme.Accent,
        Size = UDim2.new(0, 3, 1, 0),
        BorderSizePixel = 0
    })
    
    local TitleLabel = Create("TextLabel", {
        Parent = NotifFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Library.Theme.FontBold,
        Text = Title,
        TextColor3 = Library.Theme.TextColor,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local ContentLabel = Create("TextLabel", {
        Parent = NotifFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 28),
        Size = UDim2.new(1, -20, 0, 30),
        Font = Library.Theme.Font,
        Text = Content,
        TextColor3 = Library.Theme.TextDim,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })

    Tween(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 70)})
    
    task.delay(Duration, function()
        local t = Tween(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})
        t.Completed:Connect(function() NotifFrame:Destroy() end)
    end)
end

--// Main Library Logic
function Library:CreateWindow(Settings)
    local Name = Settings.Name or "Aurora V5"
    local IntroText = Settings.IntroText or "Loading..."
    local OnCloseCallback = Settings.OnClose or function() end
    Library.ToggleKey = Settings.ToggleKey or Enum.KeyCode.RightControl
    
    local AuroraGUI = Create("ScreenGui", {
        Name = "AuroraGUI",
        Parent = ParentObj,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    -- Main Container
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = AuroraGUI,
        BackgroundColor3 = Library.Theme.Background,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 8)})
    RegisterThemeObject(MainFrame, "BackgroundColor3", "Background")
    
    -- Main Stroke
    local MainStroke = Create("UIStroke", {
        Parent = MainFrame,
        Color = Library.Theme.Stroke,
        Thickness = 1
    })
    RegisterThemeObject(MainStroke, "Color", "Stroke")

    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = Library.Theme.Sidebar,
        Size = UDim2.new(0, 160, 1, 0),
        BorderSizePixel = 0,
        ZIndex = 2
    })
    RegisterThemeObject(Sidebar, "BackgroundColor3", "Sidebar")
    
    local SidebarStroke = Create("UIStroke", {
        Parent = Sidebar,
        Color = Library.Theme.Stroke,
        Thickness = 1,
        Transparency = 0.5
    })
    
    -- Title Area
    local TitleLabel = Create("TextLabel", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 15),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Library.Theme.FontBold,
        Text = Name,
        TextColor3 = Library.Theme.TextColor,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    RegisterThemeObject(TitleLabel, "TextColor3", "TextColor")
    
    local TitleGradient = Create("UIGradient", {
        Parent = TitleLabel,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Library.Theme.Accent)
        })
    })

    -- Tab Container (Sidebar)
    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 60),
        Size = UDim2.new(1, 0, 1, -100), -- Leave room for user profile or settings at bottom
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        BorderSizePixel = 0
    })
    Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
    Create("UIPadding", {Parent = TabContainer, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})

    -- Content Area
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 160, 0, 0),
        Size = UDim2.new(1, -160, 1, 0)
    })
    
    -- Pages Container
    local PagesContainer = Create("Frame", {
        Parent = ContentArea,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 50), -- Top padding for page title
        Size = UDim2.new(1, 0, 1, -50),
        ClipsDescendants = true
    })
    
    -- Current Page Title
    local PageTitle = Create("TextLabel", {
        Parent = ContentArea,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 15),
        Size = UDim2.new(1, -40, 0, 30),
        Font = Library.Theme.FontBold,
        Text = "Home",
        TextColor3 = Library.Theme.TextColor,
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    RegisterThemeObject(PageTitle, "TextColor3", "TextColor")

    --// UTILITY BAR (Settings, Minimize, Close)
    local UtilBar = Create("Frame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -100, 0, 0),
        Size = UDim2.new(0, 100, 0, 40),
        ZIndex = 5
    })

    local function CreateUtilBtn(icon, callback)
        local Btn = Create("TextButton", {
            Parent = UtilBar,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 30, 0, 30),
            Text = icon,
            Font = Enum.Font.GothamBold,
            TextColor3 = Library.Theme.TextDim,
            TextSize = 18,
            Position = UDim2.new(0, 0, 0, 5)
        })
        Create("UIListLayout", {Parent = UtilBar, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 5)})
        Create("UIPadding", {Parent = UtilBar, PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 10)})

        Btn.MouseEnter:Connect(function() Tween(Btn, TweenInfo.new(0.2), {TextColor3 = Library.Theme.Accent}) end)
        Btn.MouseLeave:Connect(function() Tween(Btn, TweenInfo.new(0.2), {TextColor3 = Library.Theme.TextDim}) end)
        Btn.MouseButton1Click:Connect(callback)
        return Btn
    end

    -- Close Modal Logic (Copied from V4 but styled for V5)
    local ModalBackdrop = Create("Frame", {
        Name = "ModalBackdrop",
        Parent = AuroraGUI,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        ZIndex = 100
    })

    local function ShowConfirmation()
        local ModalFrame = Create("Frame", {
            Parent = ModalBackdrop,
            BackgroundColor3 = Library.Theme.ElementBackground,
            Position = UDim2.new(0.5, -150, 0.5, -60),
            Size = UDim2.new(0, 300, 0, 130),
            BorderSizePixel = 0,
            Transparency = 1
        })
        Create("UICorner", {Parent = ModalFrame, CornerRadius = UDim.new(0, 8)})
        Create("UIStroke", {Parent = ModalFrame, Color = Library.Theme.Stroke, Thickness = 1})
        
        local ModalTitle = Create("TextLabel", {
            Parent = ModalFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 15),
            Size = UDim2.new(1, -40, 0, 20),
            Font = Library.Theme.FontBold,
            Text = "Confirmation",
            TextColor3 = Library.Theme.TextColor,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 1
        })
        
        local ModalText = Create("TextLabel", {
            Parent = ModalFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 40),
            Size = UDim2.new(1, -40, 0, 40),
            Font = Library.Theme.Font,
            Text = "Are you sure you want to terminate this script?",
            TextColor3 = Library.Theme.TextDim,
            TextSize = 14,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 1
        })

        local BtnContainer = Create("Frame", {Parent = ModalFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 1, -40), Size = UDim2.new(1, -40, 0, 30)})
        Create("UIListLayout", {Parent = BtnContainer, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10)})
        
        local function MkBtn(txt, col, cb)
            local b = Create("TextButton", {
                Parent = BtnContainer,
                BackgroundColor3 = col,
                Size = UDim2.new(0.5, -5, 1, 0),
                Text = txt,
                Font = Library.Theme.FontBold,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 13,
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                TextTransparency = 1
            })
            Create("UICorner", {Parent = b, CornerRadius = UDim.new(0, 6)})
            b.MouseButton1Click:Connect(cb)
            return b
        end
        
        local ConfirmBtn = MkBtn("Terminate", Color3.fromRGB(200, 60, 60), function()
            OnCloseCallback()
            AuroraGUI:Destroy()
        end)
        
        local CancelBtn = MkBtn("Cancel", Library.Theme.Stroke, function()
            local t = Tween(ModalBackdrop, TweenInfo.new(0.2), {BackgroundTransparency = 1})
            Tween(ModalFrame, TweenInfo.new(0.2), {BackgroundTransparency = 1})
            Tween(ModalTitle, TweenInfo.new(0.2), {TextTransparency = 1})
            Tween(ModalText, TweenInfo.new(0.2), {TextTransparency = 1})
            Tween(ConfirmBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1})
            Tween(CancelBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1})
            t.Completed:Connect(function() ModalFrame:Destroy(); ModalBackdrop.Visible = false end)
        end)

        ModalBackdrop.Visible = true
        Tween(ModalBackdrop, TweenInfo.new(0.2), {BackgroundTransparency = 0.5})
        Tween(ModalFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0})
        Tween(ModalTitle, TweenInfo.new(0.2), {TextTransparency = 0})
        Tween(ModalText, TweenInfo.new(0.2), {TextTransparency = 0})
        Tween(ConfirmBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0, TextTransparency = 0})
        Tween(CancelBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0, TextTransparency = 0})
    end

    -- Top Buttons
    CreateUtilBtn("X", ShowConfirmation)
    CreateUtilBtn("-", function()
        MainFrame.Visible = false
        Library.Open = false
        -- Minimize Logic: Show a small button to open it back? 
        -- For V5, let's just use the Toggle Key to bring it back.
        Library:Notify({Title = "Minimized", Content = "Press " .. Library.ToggleKey.Name .. " to open.", Duration = 3})
    end)
    
    -- Settings Toggle (Cog)
    local SettingsOpen = false
    local SettingsPanel = nil -- Will be defined later
    
    local SettingsBtn = CreateUtilBtn("⚙", function()
        SettingsOpen = not SettingsOpen
        if SettingsOpen then
            SettingsPanel.Visible = true
            Tween(SettingsPanel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
        else
            Tween(SettingsPanel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 0, 0, 0)})
            task.wait(0.3)
            if not SettingsOpen then SettingsPanel.Visible = false end
        end
    end)

    --// SETTINGS PANEL (FIXED)
    SettingsPanel = Create("Frame", {
        Name = "SettingsPanel",
        Parent = ContentArea,
        BackgroundColor3 = Library.Theme.Background,
        Position = UDim2.new(1, 0, 0, 0), -- Start off-screen right
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        ZIndex = 10
    })
    
    local SettingsLabel = Create("TextLabel", {
        Parent = SettingsPanel,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 15),
        Size = UDim2.new(1, -40, 0, 30),
        Font = Library.Theme.FontBold,
        Text = "Settings",
        TextColor3 = Library.Theme.TextColor,
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local SettingsContainer = Create("ScrollingFrame", {
        Parent = SettingsPanel,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(1, 0, 1, -50),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2
    })
    Create("UIListLayout", {Parent = SettingsContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
    Create("UIPadding", {Parent = SettingsContainer, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20)})
    SettingsContainer.ChildAdded:Connect(function() SettingsContainer.CanvasSize = UDim2.new(0, 0, 0, SettingsContainer.UIListLayout.AbsoluteContentSize.Y + 20) end)

    -- Helper to create setting elements (Reusing similar logic to standard elements but simplified for settings)
    local function CreateSettingToggle(name, callback)
        local Frame = Create("Frame", {Parent = SettingsContainer, BackgroundColor3 = Library.Theme.ElementBackground, Size = UDim2.new(1, 0, 0, 40)})
        Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 6)})
        Create("UIStroke", {Parent = Frame, Color = Library.Theme.Stroke, Thickness = 1})
        
        local Lbl = Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(0.6, 0, 1, 0), Font = Library.Theme.Font, Text = name, TextColor3 = Library.Theme.TextColor, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
        
        local Btn = Create("TextButton", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = ""})
        local State = false
        local Box = Create("Frame", {Parent = Frame, BackgroundColor3 = Color3.fromRGB(50, 50, 55), Position = UDim2.new(1, -55, 0.5, -10), Size = UDim2.new(0, 40, 0, 20)})
        Create("UICorner", {Parent = Box, CornerRadius = UDim.new(1, 0)})
        local Circ = Create("Frame", {Parent = Box, BackgroundColor3 = Color3.fromRGB(200, 200, 200), Position = UDim2.new(0, 2, 0.5, -8), Size = UDim2.new(0, 16, 0, 16)})
        Create("UICorner", {Parent = Circ, CornerRadius = UDim.new(1, 0)})
        
        Btn.MouseButton1Click:Connect(function()
            State = not State
            Tween(Box, TweenInfo.new(0.2), {BackgroundColor3 = State and Library.Theme.Accent or Color3.fromRGB(50, 50, 55)})
            Tween(Circ, TweenInfo.new(0.2), {Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
            callback(State)
        end)
    end
    
    local function CreateSettingKeybind(name, defaultKey, callback)
        local Frame = Create("Frame", {Parent = SettingsContainer, BackgroundColor3 = Library.Theme.ElementBackground, Size = UDim2.new(1, 0, 0, 40)})
        Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 6)})
        Create("UIStroke", {Parent = Frame, Color = Library.Theme.Stroke, Thickness = 1})
        
        Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(0.6, 0, 1, 0), Font = Library.Theme.Font, Text = name, TextColor3 = Library.Theme.TextColor, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
        
        local BindBtn = Create("TextButton", {Parent = Frame, BackgroundColor3 = Library.Theme.Background, Position = UDim2.new(1, -95, 0.5, -12), Size = UDim2.new(0, 80, 0, 24), Text = defaultKey.Name, Font = Library.Theme.FontBold, TextColor3 = Library.Theme.TextDim, TextSize = 12})
        Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0, 4)})
        Create("UIStroke", {Parent = BindBtn, Color = Library.Theme.Stroke, Thickness = 1})
        
        local Binding = false
        BindBtn.MouseButton1Click:Connect(function()
            Binding = true
            BindBtn.Text = "..."
        end)
        UserInputService.InputBegan:Connect(function(input)
            if Binding and input.UserInputType == Enum.UserInputType.Keyboard then
                Binding = false
                BindBtn.Text = input.KeyCode.Name
                Library.ToggleKey = input.KeyCode
                if callback then callback(input.KeyCode) end
            end
        end)
    end

    -- POPULATE SETTINGS (FIXED BLACK SCREEN ISSUE)
    CreateSettingKeybind("Menu Toggle", Library.ToggleKey, function(k) Library.ToggleKey = k end)
    
    -- Accent Color Picker (Simplified)
    local ColorFrame = Create("Frame", {Parent = SettingsContainer, BackgroundColor3 = Library.Theme.ElementBackground, Size = UDim2.new(1, 0, 0, 60)})
    Create("UICorner", {Parent = ColorFrame, CornerRadius = UDim.new(0, 6)})
    Create("UIStroke", {Parent = ColorFrame, Color = Library.Theme.Stroke, Thickness = 1})
    Create("TextLabel", {Parent = ColorFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 5), Size = UDim2.new(1, 0, 0, 20), Font = Library.Theme.Font, Text = "Accent Color", TextColor3 = Library.Theme.TextColor, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
    
    local Palette = Create("Frame", {Parent = ColorFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 30), Size = UDim2.new(1, -30, 0, 20)})
    Create("UIListLayout", {Parent = Palette, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10)})
    
    local Colors = {
        Color3.fromRGB(114, 137, 218), -- Blurple
        Color3.fromRGB(255, 85, 85),   -- Red
        Color3.fromRGB(85, 255, 127),  -- Green
        Color3.fromRGB(255, 170, 0),   -- Orange
        Color3.fromRGB(255, 0, 127)    -- Pink
    }
    
    for _, col in ipairs(Colors) do
        local cBtn = Create("TextButton", {Parent = Palette, BackgroundColor3 = col, Size = UDim2.new(0, 20, 0, 20), Text = "", AutoButtonColor = false})
        Create("UICorner", {Parent = cBtn, CornerRadius = UDim.new(1, 0)})
        cBtn.MouseButton1Click:Connect(function()
            UpdateTheme("Accent", col)
            -- Update gradients
            TitleGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, col)})
        end)
    end

    -- Dragging Logic
    local DragToggle, DragInput, DragStart, StartPos
    local function UpdateInput(input)
        local Delta = input.Position - DragStart
        Tween(MainFrame, TweenInfo.new(0.05), {Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)})
    end
    Sidebar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            DragToggle = true
            DragStart = input.Position
            StartPos = MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then DragToggle = false end end)
        end
    end)
    Sidebar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == DragInput and DragToggle then UpdateInput(input) end end)
    
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Library.ToggleKey then
            Library.Open = not Library.Open
            MainFrame.Visible = Library.Open
        end
    end)

    --// TAB GENERATION
    local WindowFunctions = {}
    local FirstTab = true

    function WindowFunctions:CreateTab(TabName)
        local Page = Create("ScrollingFrame", {
            Name = TabName.."Page",
            Parent = PagesContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 2,
            Visible = false
        })
        Create("UIListLayout", {Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
        Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingBottom = UDim.new(0, 10)})
        Page.ChildAdded:Connect(function() Page.CanvasSize = UDim2.new(0, 0, 0, Page.UIListLayout.AbsoluteContentSize.Y + 20) end)

        local TabBtn = Create("TextButton", {
            Parent = TabContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 35),
            Text = TabName,
            Font = Library.Theme.Font,
            TextColor3 = Library.Theme.TextDim,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false
        })
        Create("UIPadding", {Parent = TabBtn, PaddingLeft = UDim.new(0, 15)})
        
        local Indicator = Create("Frame", {
            Parent = TabBtn,
            BackgroundColor3 = Library.Theme.Accent,
            Position = UDim2.new(0, -10, 0.5, -8), -- Hidden initially
            Size = UDim2.new(0, 3, 0, 16),
            BackgroundTransparency = 1
        })
        Create("UICorner", {Parent = Indicator, CornerRadius = UDim.new(1, 0)})
        RegisterThemeObject(Indicator, "BackgroundColor3", "Accent")

        if FirstTab then
            FirstTab = false
            Page.Visible = true
            TabBtn.TextColor3 = Library.Theme.TextColor
            Indicator.BackgroundTransparency = 0
            Indicator.Position = UDim2.new(0, 0, 0.5, -8)
            PageTitle.Text = TabName
        end

        TabBtn.MouseButton1Click:Connect(function()
            -- Reset all
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Tween(v, TweenInfo.new(0.2), {TextColor3 = Library.Theme.TextDim})
                    Tween(v.Frame, TweenInfo.new(0.2), {BackgroundTransparency = 1, Position = UDim2.new(0, -10, 0.5, -8)})
                end
            end
            for _, v in pairs(PagesContainer:GetChildren()) do v.Visible = false end
            
            -- Activate
            Page.Visible = true
            PageTitle.Text = TabName
            Tween(TabBtn, TweenInfo.new(0.2), {TextColor3 = Library.Theme.TextColor})
            Tween(Indicator, TweenInfo.new(0.2), {BackgroundTransparency = 0, Position = UDim2.new(0, 0, 0.5, -8)})
        end)

        local TabFunctions = {}
        
        -- Helper for Element Container
        local function CreateElementContainer()
            local Frame = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Library.Theme.ElementBackground,
                Size = UDim2.new(1, 0, 0, 42)
            })
            Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = Frame, Color = Library.Theme.Stroke, Thickness = 1})
            RegisterThemeObject(Frame, "BackgroundColor3", "ElementBackground")
            return Frame
        end

        function TabFunctions:CreateSection(Name)
            local Label = Create("TextLabel", {
                Parent = Page,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 30),
                Font = Library.Theme.FontBold,
                Text = Name,
                TextColor3 = Library.Theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            RegisterThemeObject(Label, "TextColor3", "TextColor")
        end

        function TabFunctions:CreateLabel(Text)
             local Label = Create("TextLabel", {
                Parent = Page,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Font = Library.Theme.Font,
                Text = Text,
                TextColor3 = Library.Theme.TextDim,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
        end

        function TabFunctions:CreateButton(Settings)
            local Frame = CreateElementContainer()
            Frame.Size = UDim2.new(1, 0, 0, 38)
            Frame.BackgroundColor3 = Library.Theme.Background -- Buttons slightly clearer
            
            local Btn = Create("TextButton", {
                Parent = Frame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Library.Theme.Font,
                Text = Settings.Name or "Button",
                TextColor3 = Library.Theme.TextColor,
                TextSize = 14
            })
            
            Btn.MouseEnter:Connect(function() Tween(Frame, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Hover}) end)
            Btn.MouseLeave:Connect(function() Tween(Frame, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Background}) end)
            Btn.MouseButton1Click:Connect(Settings.Callback or function() end)
        end

        function TabFunctions:CreateToggle(Settings)
            local Frame = CreateElementContainer()
            local State = Settings.CurrentValue or false
            
            local Label = Create("TextLabel", {
                Parent = Frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(0.6, 0, 1, 0),
                Font = Library.Theme.Font,
                Text = Settings.Name,
                TextColor3 = Library.Theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local SwitchBg = Create("Frame", {
                Parent = Frame,
                BackgroundColor3 = State and Library.Theme.Accent or Color3.fromRGB(50, 50, 55),
                Position = UDim2.new(1, -52, 0.5, -10),
                Size = UDim2.new(0, 40, 0, 20)
            })
            Create("UICorner", {Parent = SwitchBg, CornerRadius = UDim.new(1, 0)})
            RegisterThemeObject(SwitchBg, "BackgroundColor3", State and "Accent" or "Stroke") -- Simple dynamic update later
            
            local Circle = Create("Frame", {
                Parent = SwitchBg,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16)
            })
            Create("UICorner", {Parent = Circle, CornerRadius = UDim.new(1, 0)})
            
            local Btn = Create("TextButton", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = ""})
            
            Btn.MouseButton1Click:Connect(function()
                State = not State
                Tween(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = State and Library.Theme.Accent or Color3.fromRGB(50, 50, 55)})
                Tween(Circle, TweenInfo.new(0.2), {Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                if Settings.Callback then Settings.Callback(State) end
            end)
        end

        function TabFunctions:CreateSlider(Settings)
            local Frame = CreateElementContainer()
            Frame.Size = UDim2.new(1, 0, 0, 55)
            
            local Label = Create("TextLabel", {
                Parent = Frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 5),
                Size = UDim2.new(1, -24, 0, 20),
                Font = Library.Theme.Font,
                Text = Settings.Name,
                TextColor3 = Library.Theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ValLabel = Create("TextLabel", {
                Parent = Frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 5),
                Size = UDim2.new(1, -24, 0, 20),
                Font = Library.Theme.FontBold,
                Text = tostring(Settings.CurrentValue or 0),
                TextColor3 = Library.Theme.TextDim,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right
            })
            
            local Bar = Create("Frame", {
                Parent = Frame,
                BackgroundColor3 = Color3.fromRGB(40, 40, 45),
                Position = UDim2.new(0, 12, 0, 35),
                Size = UDim2.new(1, -24, 0, 6)
            })
            Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(1, 0)})
            
            local Fill = Create("Frame", {
                Parent = Bar,
                BackgroundColor3 = Library.Theme.Accent,
                Size = UDim2.new(0, 0, 1, 0)
            })
            Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
            RegisterThemeObject(Fill, "BackgroundColor3", "Accent")
            
            -- Draggable Logic (Copied from V4)
            local Min, Max = Settings.Range[1], Settings.Range[2]
            local Val = Settings.CurrentValue or Min
            
            local function Update(pct)
                Fill.Size = UDim2.new(pct, 0, 1, 0)
                ValLabel.Text = tostring(Val)
            end
            Update((Val - Min)/(Max - Min))
            
            local Btn = Create("TextButton", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 25), Size = UDim2.new(1, 0, 0, 30), Text = ""})
            local Dragging = false
            Btn.MouseButton1Down:Connect(function() Dragging = true end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
            UserInputService.InputChanged:Connect(function(i)
                if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local Pct = math.clamp((i.Position.X - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X, 0, 1)
                    Val = math.floor(((Min + ((Max - Min) * Pct))/(Settings.Increment or 1)) + 0.5) * (Settings.Increment or 1)
                    Update(Pct)
                    if Settings.Callback then Settings.Callback(Val) end
                end
            end)
        end

        return TabFunctions
    end

    -- Intro Animation
    MainFrame.BackgroundTransparency = 1
    Sidebar.Position = UDim2.new(0, -160, 0, 0)
    ContentArea.Position = UDim2.new(0, 0, 0, 0)
    ContentArea.BackgroundTransparency = 1
    
    Tween(MainFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0})
    Tween(Sidebar, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
    Tween(ContentArea, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 160, 0, 0)})

    return WindowFunctions
end

return Library
