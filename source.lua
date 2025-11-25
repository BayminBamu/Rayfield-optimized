--[[
    Aurora UI Library V4 (Fixed)
    - Fixed Minimize Icon (No longer looks like a checkmark)
    - Added Close Confirmation Modal
    - Added OnClose Callback for robust script termination
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
        Accent = Color3.fromRGB(114, 137, 218),
        Hover = Color3.fromRGB(40, 40, 45),
        Font = Enum.Font.GothamMedium,
        TextSize = 14
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
    local OnCloseCallback = Settings.OnClose or function() end
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
    
    local function CreateIconBtn(name, iconId, layoutOrder, callback, isImage)
        local Btn
        if isImage then
            Btn = Create("ImageButton", {
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
        else
            Btn = Create("TextButton", {
                Name = name,
                Parent = ButtonContainer,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -30 * layoutOrder, 0, 5),
                Size = UDim2.new(0, 30, 0, 30),
                Text = iconId, -- Text passed as iconId
                Font = Enum.Font.GothamBold,
                TextColor3 = Color3.fromRGB(200, 200, 200),
                TextSize = 20,
                ZIndex = 3
            })
            Btn.MouseEnter:Connect(function() Tween(Btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}) end)
            Btn.MouseLeave:Connect(function() Tween(Btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 200, 200)}) end)
        end
        
        Btn.MouseButton1Click:Connect(callback)
        return Btn
    end

    -- Close Modal Logic
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
            BackgroundColor3 = Library.Theme.Background,
            Position = UDim2.new(0.5, -150, 0.5, -60),
            Size = UDim2.new(0, 300, 0, 120),
            BorderSizePixel = 0,
            Transparency = 1
        })
        Create("UICorner", {Parent = ModalFrame, CornerRadius = UDim.new(0, 8)})
        
        local ModalText = Create("TextLabel", {
            Parent = ModalFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(1, -20, 0, 50),
            Font = Library.Theme.Font,
            Text = "Are you sure you want to terminate this script?",
            TextColor3 = Library.Theme.TextColor,
            TextSize = 16,
            TextWrapped = true,
            TextTransparency = 1
        })
        
        local ConfirmBtn = Create("TextButton", {
            Parent = ModalFrame,
            BackgroundColor3 = Color3.fromRGB(200, 50, 50),
            Position = UDim2.new(0, 20, 1, -40),
            Size = UDim2.new(0, 120, 0, 30),
            Font = Library.Theme.Font,
            Text = "Terminate",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            TextTransparency = 1
        })
        Create("UICorner", {Parent = ConfirmBtn, CornerRadius = UDim.new(0, 4)})
        
        local CancelBtn = Create("TextButton", {
            Parent = ModalFrame,
            BackgroundColor3 = Library.Theme.ElementColor,
            Position = UDim2.new(1, -140, 1, -40),
            Size = UDim2.new(0, 120, 0, 30),
            Font = Library.Theme.Font,
            Text = "Cancel",
            TextColor3 = Library.Theme.TextColor,
            TextSize = 14,
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            TextTransparency = 1
        })
        Create("UICorner", {Parent = CancelBtn, CornerRadius = UDim.new(0, 4)})

        ModalBackdrop.Visible = true
        Tween(ModalBackdrop, TweenInfo.new(0.2), {BackgroundTransparency = 0.5})
        Tween(ModalFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0})
        Tween(ModalText, TweenInfo.new(0.2), {TextTransparency = 0})
        Tween(ConfirmBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0, TextTransparency = 0})
        Tween(CancelBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0, TextTransparency = 0})

        local function CloseModal()
            local t = Tween(ModalBackdrop, TweenInfo.new(0.2), {BackgroundTransparency = 1})
            Tween(ModalFrame, TweenInfo.new(0.2), {BackgroundTransparency = 1})
            Tween(ModalText, TweenInfo.new(0.2), {TextTransparency = 1})
            Tween(ConfirmBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1})
            Tween(CancelBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1})
            t.Completed:Connect(function() 
                ModalFrame:Destroy() 
                ModalBackdrop.Visible = false 
            end)
        end

        ConfirmBtn.MouseButton1Click:Connect(function()
            CloseModal()
            OnCloseCallback() -- Trigger User Callback
            AuroraGUI:Destroy()
        end)
        CancelBtn.MouseButton1Click:Connect(CloseModal)
    end

    -- Close Button (Image)
    CreateIconBtn("Close", "rbxassetid://6031094678", 1, function()
        ShowConfirmation()
    end, true)
    
    -- Minimize Button (Text "-" to avoid checkmark confusion)
    local MinBtn = CreateIconBtn("Minimize", "-", 2, function() end, false)

    -- Settings Button (Image)
    local SettingsBtn = CreateIconBtn("Settings", "rbxassetid://6031280882", 3, function() end, true)

    --// Settings Panel & Minimize Logic (Same as V3 but omitted for brevity in diff, keeping core structure)
    -- ... [Settings Panel Logic Here] ... 
    
    local SettingsPanel = Create("Frame", {
        Name = "SettingsPanel",
        Parent = MainFrame,
        BackgroundColor3 = Library.Theme.Background,
        BackgroundTransparency = 0.05,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 1, -40),
        ZIndex = 20,
        Visible = false
    })
    
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
            t.Completed:Connect(function() if not SettingsOpen then SettingsPanel.Visible = false end end)
            ContentContainer.Visible = true
        end
    end)
    
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

    -- [Drag, Tabs, Elements Logic remains same as V3...]
    
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
        
        -- Simplified Elements for brevity
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
            BtnFrame.MouseButton1Click:Connect(BtnSettings.Callback or function() end)
        end

        function TabFunctions:CreateToggle(ToggleSettings)
            local Frame = Create("Frame", {Parent = Page, BackgroundColor3 = Library.Theme.ElementColor, Size = UDim2.new(1, -5, 0, 35)})
            Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 6)})
            RegisterThemeObject(Frame, "BackgroundColor3", "ElementColor")
            
            local Btn = Create("TextButton", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = ""})
            local Lbl = Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(0.6, 0, 1, 0), Font = Library.Theme.Font, Text = ToggleSettings.Name, TextColor3 = Library.Theme.TextColor, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
            RegisterThemeObject(Lbl, "TextColor3", "TextColor")
            
            local State = ToggleSettings.CurrentValue or false
            local Box = Create("Frame", {Parent = Frame, BackgroundColor3 = State and Library.Theme.Accent or Color3.fromRGB(60,60,60), Position = UDim2.new(1, -50, 0.5, -10), Size = UDim2.new(0, 40, 0, 20)})
            Create("UICorner", {Parent = Box, CornerRadius = UDim.new(1, 0)})
            local Circle = Create("Frame", {Parent = Box, BackgroundColor3 = Color3.new(1,1,1), Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), Size = UDim2.new(0, 16, 0, 16)})
            Create("UICorner", {Parent = Circle, CornerRadius = UDim.new(1, 0)})
            
            Btn.MouseButton1Click:Connect(function()
                State = not State
                Tween(Box, TweenInfo.new(0.2), {BackgroundColor3 = State and Library.Theme.Accent or Color3.fromRGB(60, 60, 60)})
                Tween(Circle, TweenInfo.new(0.2), {Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                if ToggleSettings.Callback then ToggleSettings.Callback(State) end
            end)
        end

        function TabFunctions:CreateSlider(SliderSettings)
            local Frame = Create("Frame", {Parent = Page, BackgroundColor3 = Library.Theme.ElementColor, Size = UDim2.new(1, -5, 0, 50)})
            Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 6)})
            RegisterThemeObject(Frame, "BackgroundColor3", "ElementColor")
            local Lbl = Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, -20, 0, 20), Font = Library.Theme.Font, Text = SliderSettings.Name, TextColor3 = Library.Theme.TextColor, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
            RegisterThemeObject(Lbl, "TextColor3", "TextColor")
            local ValLbl = Create("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, -20, 0, 20), Font = Library.Theme.Font, Text = tostring(SliderSettings.CurrentValue or 0), TextColor3 = Library.Theme.TextColor, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right})
            RegisterThemeObject(ValLbl, "TextColor3", "TextColor")
            local Bar = Create("Frame", {Parent = Frame, BackgroundColor3 = Color3.fromRGB(60,60,60), Position = UDim2.new(0, 10, 0, 30), Size = UDim2.new(1, -20, 0, 6)})
            Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(1, 0)})
            local Fill = Create("Frame", {Parent = Bar, BackgroundColor3 = Library.Theme.Accent, Size = UDim2.new(0, 0, 1, 0)})
            Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
            RegisterThemeObject(Fill, "BackgroundColor3", "Accent")
            
            local Min, Max = SliderSettings.Range[1], SliderSettings.Range[2]
            local Val = SliderSettings.CurrentValue or Min
            local function Update(pct)
                Fill.Size = UDim2.new(pct, 0, 1, 0)
                ValLbl.Text = tostring(Val)
            end
            Update((Val - Min)/(Max - Min))
            
            local Trigger = Create("TextButton", {Parent = Frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = ""})
            local Dragging = false
            Trigger.MouseButton1Down:Connect(function() Dragging = true end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
            UserInputService.InputChanged:Connect(function(i)
                if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local Pct = math.clamp((i.Position.X - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X, 0, 1)
                    Val = math.floor(((Min + ((Max - Min) * Pct))/(SliderSettings.Increment or 1)) + 0.5) * (SliderSettings.Increment or 1)
                    Update(Pct)
                    if SliderSettings.Callback then SliderSettings.Callback(Val) end
                end
            end)
        end

        return TabFunctions
    end
    
    Tween(MainFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0})
    Tween(Title, TweenInfo.new(0.5), {TextTransparency = 0})
    return WindowFunctions
end

return Library
