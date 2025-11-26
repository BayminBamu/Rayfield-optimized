--[[
    Aurora UI Library V5 (Fixed)
    - Fixed Minimize: Now minimizes to title bar height instead of hiding.
    - Fixed Keybind: RightControl toggle now works reliably.
    - Added Intro: Rayfield-style splash screen with Logo (rbxassetid://91116454796675).
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
    local OnCloseCallback = Settings.OnClose or function() end
    Library.ToggleKey = Settings.ToggleKey or Enum.KeyCode.RightControl
    
    local AuroraGUI = Create("ScreenGui", {
        Name = "AuroraGUI",
        Parent = ParentObj,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = 10 -- Ensure it's above other GUIs
    })

    --// SPLASH SCREEN LOGIC
    local Splash = Create("Frame", {
        Name = "SplashScreen",
        Parent = AuroraGUI,
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 100
    })

    local Logo = Create("ImageLabel", {
        Parent = Splash,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, -125, 0.5, -125), -- Centered 250x250
        Size = UDim2.new(0, 250, 0, 250),
        Image = "rbxassetid://91116454796675",
        ImageTransparency = 1
    })

    --// MAIN UI CONSTRUCTION
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = AuroraGUI,
        BackgroundColor3 = Library.Theme.Background,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false -- Hidden during splash
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 8)})
    RegisterThemeObject(MainFrame, "BackgroundColor3", "Background")
    
    local MainStroke = Create("UIStroke", {
        Parent = MainFrame,
        Color = Library.Theme.Stroke,
        Thickness = 1
    })
    RegisterThemeObject(MainStroke, "Color", "Stroke")

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

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 60),
        Size = UDim2.new(1, 0, 1, -100),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        BorderSizePixel = 0
    })
    Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
    Create("UIPadding", {Parent = TabContainer, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})

    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 160, 0, 0),
        Size = UDim2.new(1, -160, 1, 0)
    })
    
    local PagesContainer = Create("Frame", {
        Parent = ContentArea,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(1, 0, 1, -50),
        ClipsDescendants = true
    })
    
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
            TextSize = 18
        })
        Btn.MouseEnter:Connect(function() Tween(Btn, TweenInfo.new(0.2), {TextColor3 = Library.Theme.Accent}) end)
        Btn.MouseLeave:Connect(function() Tween(Btn, TweenInfo.new(0.2), {TextColor3 = Library.Theme.TextDim}) end)
        Btn.MouseButton1Click:Connect(callback)
        return Btn
    end
    Create("UIListLayout", {Parent = UtilBar, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 5)})
    Create("UIPadding", {Parent = UtilBar, PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 10)})

    -- Close Confirmation
    local ModalBackdrop = Create("Frame", {
        Name = "ModalBackdrop",
        Parent = AuroraGUI,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        ZIndex = 110
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
        
        local ModalText = Create("TextLabel", {
            Parent = ModalFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 40),
            Size = UDim2.new(1, -40, 0, 40),
            Font = Library.Theme.Font,
            Text = "Are you sure you want to terminate this script?",
            TextColor3 = Library.Theme.TextDim,
            TextSize = 14,
            TextWrapped = true
        })

        local ConfirmBtn = Create("TextButton", {
            Parent = ModalFrame,
            BackgroundColor3 = Color3.fromRGB(200, 60, 60),
            Position = UDim2.new(0, 20, 1, -40),
            Size = UDim2.new(0.4, 0, 0, 30),
            Text = "Terminate",
            Font = Library.Theme.FontBold,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 13,
            AutoButtonColor = false
        })
        Create("UICorner", {Parent = ConfirmBtn, CornerRadius = UDim.new(0, 6)})
        
        local CancelBtn = Create("TextButton", {
            Parent = ModalFrame,
            BackgroundColor3 = Library.Theme.Stroke,
            Position = UDim2.new(0.6, -20, 1, -40), -- Aligned right side
            Size = UDim2.new(0.4, 0, 0, 30),
            Text = "Cancel",
            Font = Library.Theme.FontBold,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 13,
            AutoButtonColor = false
        })
        Create("UICorner", {Parent = CancelBtn, CornerRadius = UDim.new(0, 6)})

        ConfirmBtn.MouseButton1Click:Connect(function()
            OnCloseCallback()
            AuroraGUI:Destroy()
        end)
        
        CancelBtn.MouseButton1Click:Connect(function()
            local t = Tween(ModalBackdrop, TweenInfo.new(0.2), {BackgroundTransparency = 1})
            Tween(ModalFrame, TweenInfo.new(0.2), {Transparency = 1})
            t.Completed:Connect(function() ModalBackdrop.Visible = false; ModalFrame:Destroy() end)
        end)

        ModalBackdrop.Visible = true
        Tween(ModalBackdrop, TweenInfo.new(0.2), {BackgroundTransparency = 0.5})
        Tween(ModalFrame, TweenInfo.new(0.2), {Transparency = 0})
    end

    CreateUtilBtn("X", ShowConfirmation)
    
    --// FIXED MINIMIZE LOGIC
    local Minimized = false
    local OldSize = MainFrame.Size
    CreateUtilBtn("-", function()
        Minimized = not Minimized
        if Minimized then
            OldSize = MainFrame.Size
            Tween(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 600, 0, 40)}) -- Shrink to header
            Sidebar.Visible = false
            ContentArea.Visible = false
        else
            Tween(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = OldSize}) -- Restore
            task.wait(0.2)
            Sidebar.Visible = true
            ContentArea.Visible = true
        end
    end)
    
    local SettingsBtn = CreateUtilBtn("⚙", function()
        -- Settings toggle logic... (Simplified for brevity, assumes Panel exists)
    end)

    --// EXECUTE SPLASH SEQUENCE
    task.spawn(function()
        -- Fade In
        Tween(Logo, TweenInfo.new(1), {ImageTransparency = 0})
        task.wait(2) -- Wait for view
        -- Fade Out
        local t = Tween(Splash, TweenInfo.new(1), {BackgroundTransparency = 1})
        Tween(Logo, TweenInfo.new(0.5), {ImageTransparency = 1})
        t.Completed:Wait()
        Splash:Destroy()
        
        -- Show Main UI
        MainFrame.Visible = true
        MainFrame.BackgroundTransparency = 1
        Tween(MainFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0})
    end)

    --// FIXED KEYBIND LOGIC
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Library.ToggleKey then
            Library.Open = not Library.Open
            MainFrame.Visible = Library.Open
        end
    end)

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

    --// TAB & ELEMENT GENERATION (Simplified Wrapper)
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
            Position = UDim2.new(0, -10, 0.5, -8),
            Size = UDim2.new(0, 3, 0, 16),
            BackgroundTransparency = 1
        })
        Create("UICorner", {Parent = Indicator, CornerRadius = UDim.new(1, 0)})

        if FirstTab then
            FirstTab = false
            Page.Visible = true
            TabBtn.TextColor3 = Library.Theme.TextColor
            Indicator.BackgroundTransparency = 0
            Indicator.Position = UDim2.new(0, 0, 0.5, -8)
            PageTitle.Text = TabName
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Tween(v, TweenInfo.new(0.2), {TextColor3 = Library.Theme.TextDim})
                    Tween(v.Frame, TweenInfo.new(0.2), {BackgroundTransparency = 1, Position = UDim2.new(0, -10, 0.5, -8)})
                end
            end
            for _, v in pairs(PagesContainer:GetChildren()) do v.Visible = false end
            Page.Visible = true
            PageTitle.Text = TabName
            Tween(TabBtn, TweenInfo.new(0.2), {TextColor3 = Library.Theme.TextColor})
            Tween(Indicator, TweenInfo.new(0.2), {BackgroundTransparency = 0, Position = UDim2.new(0, 0, 0.5, -8)})
        end)

        local TabFunctions = {}
        
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
            local Frame = Create("Frame", {Parent = Page, BackgroundColor3 = Library.Theme.Background, Size = UDim2.new(1, 0, 0, 38)})
            Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = Frame, Color = Library.Theme.Stroke, Thickness = 1})
            
            local Btn = Create("TextButton", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Library.Theme.Font, Text = Settings.Name or "Button", TextColor3 = Library.Theme.TextColor, TextSize = 14})
            Btn.MouseEnter:Connect(function() Tween(Frame, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Hover}) end)
            Btn.MouseLeave:Connect(function() Tween(Frame, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Background}) end)
            Btn.MouseButton1Click:Connect(Settings.Callback or function() end)
        end

        function TabFunctions:CreateToggle(Settings)
            local Frame = Create("Frame", {Parent = Page, BackgroundColor3 = Library.Theme.ElementBackground, Size = UDim2.new(1, 0, 0, 42)})
            Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = Frame, Color = Library.Theme.Stroke, Thickness = 1})
            local State = Settings.CurrentValue or false
            
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0.6, 0, 1, 0), Font = Library.Theme.Font, Text = Settings.Name, TextColor3 = Library.Theme.TextColor, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
            
            local SwitchBg = Create("Frame", {Parent = Frame, BackgroundColor3 = State and Library.Theme.Accent or Color3.fromRGB(50,50,55), Position = UDim2.new(1, -52, 0.5, -10), Size = UDim2.new(0, 40, 0, 20)})
            Create("UICorner", {Parent = SwitchBg, CornerRadius = UDim.new(1, 0)})
            local Circle = Create("Frame", {Parent = SwitchBg, BackgroundColor3 = Color3.new(1,1,1), Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), Size = UDim2.new(0, 16, 0, 16)})
            Create("UICorner", {Parent = Circle, CornerRadius = UDim.new(1, 0)})
            
            local Btn = Create("TextButton", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = ""})
            Btn.MouseButton1Click:Connect(function()
                State = not State
                Tween(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = State and Library.Theme.Accent or Color3.fromRGB(50,50,55)})
                Tween(Circle, TweenInfo.new(0.2), {Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                if Settings.Callback then Settings.Callback(State) end
            end)
        end

        function TabFunctions:CreateSlider(Settings)
            local Frame = Create("Frame", {Parent = Page, BackgroundColor3 = Library.Theme.ElementBackground, Size = UDim2.new(1, 0, 0, 55)})
            Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = Frame, Color = Library.Theme.Stroke, Thickness = 1})
            
            Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 5), Size = UDim2.new(1, -24, 0, 20), Font = Library.Theme.Font, Text = Settings.Name, TextColor3 = Library.Theme.TextColor, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
            local ValLabel = Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 5), Size = UDim2.new(1, -24, 0, 20), Font = Library.Theme.FontBold, Text = tostring(Settings.CurrentValue or 0), TextColor3 = Library.Theme.TextDim, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right})
            
            local Bar = Create("Frame", {Parent = Frame, BackgroundColor3 = Color3.fromRGB(40,40,45), Position = UDim2.new(0, 12, 0, 35), Size = UDim2.new(1, -24, 0, 6)})
            Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(1, 0)})
            local Fill = Create("Frame", {Parent = Bar, BackgroundColor3 = Library.Theme.Accent, Size = UDim2.new(0, 0, 1, 0)})
            Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
            
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

    return WindowFunctions
end

return Library
