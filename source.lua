--[[ 
    Rayfield Interface Suite (Optimized Standalone)
    -----------------------------------------------
    - No Key System
    - No Analytics
    - No External "Loadstring" Dependencies
    - No Bloat/Prompts
    - Optimized for performance (Reduced table lookups, cleaner event handling)
]]

local Release = "Optimized Standalone 1.0"
local RayfieldLibrary = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

--// UI Protection (Prevention against simple detection)
local function GetUIContainer()
    if gethui then return gethui() end
    if Synapse and Synapse.ProtectGui then 
        local gui = Instance.new("ScreenGui")
        Synapse.ProtectGui(gui)
        gui.Parent = CoreGui
        return gui
    elseif CoreGui:FindFirstChild("RobloxGui") then
        return CoreGui:FindFirstChild("RobloxGui")
    else
        return CoreGui
    end
end

--// Utility Functions
local function Tween(instance, info, propertyTable)
    local tween = TweenService:Create(instance, info, propertyTable)
    tween:Play()
    return tween
end

local function GetTextSize(text, font, size, width)
    return game:GetService("TextService"):GetTextSize(text, size, font, Vector2.new(width, 100000)).Y
end

--// Theme System (Stripped to Essentials)
local RayfieldTheme = {
    Default = {
        TextColor = Color3.fromRGB(240, 240, 240),
        Background = Color3.fromRGB(25, 25, 25),
        Topbar = Color3.fromRGB(34, 34, 34),
        Shadow = Color3.fromRGB(20, 20, 20),
        NotificationBackground = Color3.fromRGB(20, 20, 20),
        TabBackground = Color3.fromRGB(80, 80, 80),
        TabStroke = Color3.fromRGB(85, 85, 85),
        TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
        TabTextColor = Color3.fromRGB(240, 240, 240),
        SelectedTabTextColor = Color3.fromRGB(50, 50, 50),
        ElementBackground = Color3.fromRGB(35, 35, 35),
        ElementStroke = Color3.fromRGB(50, 50, 50),
        SliderBackground = Color3.fromRGB(50, 138, 220),
        SliderProgress = Color3.fromRGB(50, 138, 220),
        ToggleEnabled = Color3.fromRGB(0, 146, 214),
        ToggleDisabled = Color3.fromRGB(100, 100, 100),
    }
}

--// Main Library
function RayfieldLibrary:CreateWindow(Settings)
    local Passthrough = false
    local Dragging = false
    local DragInput, DragStart, StartPosition
    
    local Theme = RayfieldTheme.Default -- Force Default or Custom, no complex loading
    if Settings.Theme and RayfieldTheme[Settings.Theme] then
        Theme = RayfieldTheme[Settings.Theme]
    end

    -- Create Main GUI
    local Rayfield = Instance.new("ScreenGui")
    Rayfield.Name = "Rayfield"
    Rayfield.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Rayfield.Parent = GetUIContainer()

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = Rayfield
    Main.BackgroundColor3 = Theme.Background
    Main.Position = UDim2.new(0.5, -250, 0.5, -175)
    Main.Size = UDim2.new(0, 500, 0, 350)
    Main.ClipsDescendants = true

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 9)
    UICorner.Parent = Main

    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Parent = Main
    Topbar.BackgroundColor3 = Theme.Topbar
    Topbar.Size = UDim2.new(1, 0, 0, 45)
    
    local TopbarCorner = Instance.new("UICorner")
    TopbarCorner.CornerRadius = UDim.new(0, 9)
    TopbarCorner.Parent = Topbar

    -- Fix Corner (Cover bottom rounded corners of topbar)
    local TopbarCover = Instance.new("Frame")
    TopbarCover.BorderSizePixel = 0
    TopbarCover.BackgroundColor3 = Theme.Topbar
    TopbarCover.Size = UDim2.new(1, 0, 0, 10)
    TopbarCover.Position = UDim2.new(0, 0, 1, -10)
    TopbarCover.Parent = Topbar

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = Topbar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = Settings.Name or "Rayfield Optimized"
    Title.TextColor3 = Theme.TextColor
    Title.TextSize = 17
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Container for Elements
    local Elements = Instance.new("Frame")
    Elements.Name = "Elements"
    Elements.Parent = Main
    Elements.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Elements.BackgroundTransparency = 1
    Elements.Position = UDim2.new(0, 0, 0, 45)
    Elements.Size = UDim2.new(1, 0, 1, -45)

    local TabList = Instance.new("UIListLayout")
    TabList.Parent = Elements
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    -- Sidebar (Navigation) - Simplified: Using a container on the left
    -- Note: Standard Rayfield puts tabs inside the main view or sidebar depending on config.
    -- We will implement a standard left-side tab system for stability.
    
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = Elements
    Sidebar.BackgroundColor3 = Theme.Background
    Sidebar.Size = UDim2.new(0, 130, 1, 0)
    Sidebar.BorderSizePixel = 0

    local SidebarList = Instance.new("UIListLayout")
    SidebarList.Parent = Sidebar
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarList.Padding = UDim.new(0, 5)

    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.Parent = Sidebar
    SidebarPadding.PaddingTop = UDim.new(0, 10)
    SidebarPadding.PaddingLeft = UDim.new(0, 10)

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "Content"
    ContentContainer.Parent = Elements
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Size = UDim2.new(1, -140, 1, 0)
    ContentContainer.Position = UDim2.new(0, 140, 0, 0)

    --// Dragging Functionality
    local function Update(Input)
        local Delta = Input.Position - DragStart
        local Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        TweenService:Create(Main, TweenInfo.new(0.25), {Position = Position}):Play()
    end

    Topbar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = Input.Position
            StartPosition = Main.Position
            
            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    Topbar.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            DragInput = Input
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Input == DragInput and Dragging then
            Update(Input)
        end
    end)

    --// Notification Logic
    local NotificationHolder = Instance.new("Frame")
    NotificationHolder.Name = "Notifications"
    NotificationHolder.Parent = Rayfield
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.Size = UDim2.new(0, 300, 1, -20)
    NotificationHolder.Position = UDim2.new(1, -320, 0, 20)
    
    local NotificationList = Instance.new("UIListLayout")
    NotificationList.Parent = NotificationHolder
    NotificationList.SortOrder = Enum.SortOrder.LayoutOrder
    NotificationList.Padding = UDim.new(0, 10)
    NotificationList.VerticalAlignment = Enum.VerticalAlignment.Bottom

    function RayfieldLibrary:Notify(NotifySettings)
        local Notif = Instance.new("Frame")
        Notif.Parent = NotificationHolder
        Notif.BackgroundColor3 = Theme.NotificationBackground
        Notif.Size = UDim2.new(1, 0, 0, 0) -- Animate height
        Notif.ClipsDescendants = true
        
        local NotifCorner = Instance.new("UICorner")
        NotifCorner.CornerRadius = UDim.new(0, 6)
        NotifCorner.Parent = Notif
        
        local NotifTitle = Instance.new("TextLabel")
        NotifTitle.Parent = Notif
        NotifTitle.BackgroundTransparency = 1
        NotifTitle.Position = UDim2.new(0, 10, 0, 10)
        NotifTitle.Size = UDim2.new(1, -20, 0, 20)
        NotifTitle.Font = Enum.Font.GothamBold
        NotifTitle.Text = NotifySettings.Title or "Notification"
        NotifTitle.TextColor3 = Theme.TextColor
        NotifTitle.TextSize = 14
        NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        local NotifContent = Instance.new("TextLabel")
        NotifContent.Parent = Notif
        NotifContent.BackgroundTransparency = 1
        NotifContent.Position = UDim2.new(0, 10, 0, 35)
        NotifContent.Size = UDim2.new(1, -20, 0, 20)
        NotifContent.Font = Enum.Font.Gotham
        NotifContent.Text = NotifySettings.Content or ""
        NotifContent.TextColor3 = Color3.fromRGB(180,180,180)
        NotifContent.TextSize = 13
        NotifContent.TextXAlignment = Enum.TextXAlignment.Left
        NotifContent.TextWrapped = true

        -- Animation In
        Tween(Notif, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 80)})
        
        task.delay(NotifySettings.Duration or 3, function()
            local Out = Tween(Notif, TweenInfo.new(0.3), {BackgroundTransparency = 1})
            Tween(NotifTitle, TweenInfo.new(0.3), {TextTransparency = 1})
            Tween(NotifContent, TweenInfo.new(0.3), {TextTransparency = 1})
            Out.Completed:Wait()
            Notif:Destroy()
        end)
    end

    --// Windows & Tabs
    local Tabs = {}
    local FirstTab = true

    local Window = {}
    
    function Window:CreateTab(Name, Image)
        local Tab = {}
        
        -- Tab Button (Sidebar)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = Name .. "Button"
        TabButton.Parent = Sidebar
        TabButton.BackgroundColor3 = Theme.TabBackground
        TabButton.Size = UDim2.new(1, -10, 0, 32)
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.Text = Name
        TabButton.TextColor3 = Theme.TabTextColor
        TabButton.TextSize = 14
        TabButton.AutoButtonColor = false
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        
        -- Tab Content Area
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = Name
        TabPage.Parent = ContentContainer
        TabPage.BackgroundTransparency = 1
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.ScrollBarThickness = 2
        TabPage.Visible = false
        
        local TabPageList = Instance.new("UIListLayout")
        TabPageList.Parent = TabPage
        TabPageList.SortOrder = Enum.SortOrder.LayoutOrder
        TabPageList.Padding = UDim.new(0, 8)
        
        local TabPagePadding = Instance.new("UIPadding")
        TabPagePadding.Parent = TabPage
        TabPagePadding.PaddingTop = UDim.new(0, 10)
        TabPagePadding.PaddingLeft = UDim.new(0, 10)
        TabPagePadding.PaddingRight = UDim.new(0, 10)
        
        -- Switch Function
        local function Activate()
            for _, t in pairs(ContentContainer:GetChildren()) do
                if t:IsA("ScrollingFrame") then t.Visible = false end
            end
            for _, b in pairs(Sidebar:GetChildren()) do
                if b:IsA("TextButton") then
                    Tween(b, TweenInfo.new(0.2), {BackgroundColor3 = Theme.TabBackground, TextColor3 = Theme.TabTextColor})
                end
            end
            
            TabPage.Visible = true
            Tween(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.TabBackgroundSelected, TextColor3 = Theme.SelectedTabTextColor})
        end
        
        TabButton.MouseButton1Click:Connect(Activate)
        
        if FirstTab then
            FirstTab = false
            Activate()
        end

        --// Elements
        
        -- SECTION
        function Tab:CreateSection(SectionName)
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Name = "Section"
            SectionLabel.Parent = TabPage
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Size = UDim2.new(1, 0, 0, 25)
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.Text = SectionName
            SectionLabel.TextColor3 = Theme.TextColor
            SectionLabel.TextSize = 15
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
        end

        -- BUTTON
        function Tab:CreateButton(ButtonSettings)
            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Name = ButtonSettings.Name
            ButtonFrame.Parent = TabPage
            ButtonFrame.BackgroundColor3 = Theme.ElementBackground
            ButtonFrame.Size = UDim2.new(1, -10, 0, 42)
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 6)
            BtnCorner.Parent = ButtonFrame
            
            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Parent = ButtonFrame
            BtnStroke.Color = Theme.ElementStroke
            BtnStroke.Thickness = 1
            
            local BtnText = Instance.new("TextLabel")
            BtnText.Parent = ButtonFrame
            BtnText.BackgroundTransparency = 1
            BtnText.Size = UDim2.new(1, -20, 1, 0)
            BtnText.Position = UDim2.new(0, 10, 0, 0)
            BtnText.Font = Enum.Font.GothamMedium
            BtnText.Text = ButtonSettings.Name
            BtnText.TextColor3 = Theme.TextColor
            BtnText.TextSize = 14
            BtnText.TextXAlignment = Enum.TextXAlignment.Left
            
            local Interact = Instance.new("TextButton")
            Interact.Parent = ButtonFrame
            Interact.BackgroundTransparency = 1
            Interact.Size = UDim2.new(1, 0, 1, 0)
            Interact.Text = ""
            
            Interact.MouseButton1Click:Connect(function()
                Tween(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
                task.wait(0.1)
                Tween(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ElementBackground})
                if ButtonSettings.Callback then
                    ButtonSettings.Callback()
                end
            end)
        end

        -- TOGGLE
        function Tab:CreateToggle(ToggleSettings)
            local Toggled = ToggleSettings.CurrentValue or false
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = ToggleSettings.Name
            ToggleFrame.Parent = TabPage
            ToggleFrame.BackgroundColor3 = Theme.ElementBackground
            ToggleFrame.Size = UDim2.new(1, -10, 0, 42)
            
            local TglCorner = Instance.new("UICorner")
            TglCorner.CornerRadius = UDim.new(0, 6)
            TglCorner.Parent = ToggleFrame
            
            local TglStroke = Instance.new("UIStroke")
            TglStroke.Parent = ToggleFrame
            TglStroke.Color = Theme.ElementStroke
            TglStroke.Thickness = 1
            
            local TglText = Instance.new("TextLabel")
            TglText.Parent = ToggleFrame
            TglText.BackgroundTransparency = 1
            TglText.Size = UDim2.new(1, -60, 1, 0)
            TglText.Position = UDim2.new(0, 10, 0, 0)
            TglText.Font = Enum.Font.GothamMedium
            TglText.Text = ToggleSettings.Name
            TglText.TextColor3 = Theme.TextColor
            TglText.TextSize = 14
            TglText.TextXAlignment = Enum.TextXAlignment.Left
            
            local SwitchFrame = Instance.new("Frame")
            SwitchFrame.Parent = ToggleFrame
            SwitchFrame.BackgroundColor3 = Toggled and Theme.ToggleEnabled or Theme.ToggleDisabled
            SwitchFrame.Position = UDim2.new(1, -50, 0.5, -10)
            SwitchFrame.Size = UDim2.new(0, 40, 0, 20)
            
            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = SwitchFrame
            
            local Dot = Instance.new("Frame")
            Dot.Parent = SwitchFrame
            Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Dot.Position = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Dot.Size = UDim2.new(0, 16, 0, 16)
            
            local DotCorner = Instance.new("UICorner")
            DotCorner.CornerRadius = UDim.new(1, 0)
            DotCorner.Parent = Dot
            
            local Interact = Instance.new("TextButton")
            Interact.Parent = ToggleFrame
            Interact.BackgroundTransparency = 1
            Interact.Size = UDim2.new(1, 0, 1, 0)
            Interact.Text = ""
            
            local function UpdateToggle()
                Toggled = not Toggled
                local TargetPos = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                local TargetColor = Toggled and Theme.ToggleEnabled or Theme.ToggleDisabled
                
                Tween(Dot, TweenInfo.new(0.2), {Position = TargetPos})
                Tween(SwitchFrame, TweenInfo.new(0.2), {BackgroundColor3 = TargetColor})
                
                if ToggleSettings.Callback then
                    ToggleSettings.Callback(Toggled)
                end
            end
            
            Interact.MouseButton1Click:Connect(UpdateToggle)
        end

        -- SLIDER
        function Tab:CreateSlider(SliderSettings)
            local SliderValue = SliderSettings.CurrentValue or SliderSettings.Range[1]
            local Min = SliderSettings.Range[1]
            local Max = SliderSettings.Range[2]
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = SliderSettings.Name
            SliderFrame.Parent = TabPage
            SliderFrame.BackgroundColor3 = Theme.ElementBackground
            SliderFrame.Size = UDim2.new(1, -10, 0, 55) -- Taller for slider
            
            local SliCorner = Instance.new("UICorner")
            SliCorner.CornerRadius = UDim.new(0, 6)
            SliCorner.Parent = SliderFrame
            
            local SliStroke = Instance.new("UIStroke")
            SliStroke.Parent = SliderFrame
            SliStroke.Color = Theme.ElementStroke
            SliStroke.Thickness = 1
            
            local SliText = Instance.new("TextLabel")
            SliText.Parent = SliderFrame
            SliText.BackgroundTransparency = 1
            SliText.Size = UDim2.new(1, -20, 0, 30)
            SliText.Position = UDim2.new(0, 10, 0, 0)
            SliText.Font = Enum.Font.GothamMedium
            SliText.Text = SliderSettings.Name
            SliText.TextColor3 = Theme.TextColor
            SliText.TextSize = 14
            SliText.TextXAlignment = Enum.TextXAlignment.Left
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Parent = SliderFrame
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Size = UDim2.new(0, 50, 0, 30)
            ValueLabel.Position = UDim2.new(1, -60, 0, 0)
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.Text = tostring(SliderValue) .. (SliderSettings.Suffix or "")
            ValueLabel.TextColor3 = Theme.TextColor
            ValueLabel.TextSize = 14
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            
            local SliderBar = Instance.new("Frame")
            SliderBar.Parent = SliderFrame
            SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            SliderBar.Position = UDim2.new(0, 10, 0, 35)
            SliderBar.Size = UDim2.new(1, -20, 0, 6)
            
            local BarCorner = Instance.new("UICorner")
            BarCorner.CornerRadius = UDim.new(1, 0)
            BarCorner.Parent = SliderBar
            
            local Fill = Instance.new("Frame")
            Fill.Parent = SliderBar
            Fill.BackgroundColor3 = Theme.SliderProgress
            Fill.Size = UDim2.new((SliderValue - Min) / (Max - Min), 0, 1, 0)
            
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = Fill
            
            local Trigger = Instance.new("TextButton")
            Trigger.Parent = SliderBar
            Trigger.BackgroundTransparency = 1
            Trigger.Size = UDim2.new(1, 0, 1, 0)
            Trigger.Text = ""
            
            local isDragging = false
            
            local function UpdateSlider(Input)
                local SizeX = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                local NewValue = math.floor(Min + ((Max - Min) * SizeX))
                
                -- Support Increment
                if SliderSettings.Increment then
                    NewValue = math.round(NewValue / SliderSettings.Increment) * SliderSettings.Increment
                end
                
                Tween(Fill, TweenInfo.new(0.05), {Size = UDim2.new(SizeX, 0, 1, 0)})
                ValueLabel.Text = tostring(NewValue) .. (SliderSettings.Suffix or "")
                
                if SliderSettings.Callback then
                    SliderSettings.Callback(NewValue)
                end
            end
            
            Trigger.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true
                    UpdateSlider(Input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(Input)
                if isDragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(Input)
                end
            end)
        end

        -- INPUT
        function Tab:CreateInput(InputSettings)
            local InputFrame = Instance.new("Frame")
            InputFrame.Name = InputSettings.Name
            InputFrame.Parent = TabPage
            InputFrame.BackgroundColor3 = Theme.ElementBackground
            InputFrame.Size = UDim2.new(1, -10, 0, 42)
            
            local InpCorner = Instance.new("UICorner")
            InpCorner.CornerRadius = UDim.new(0, 6)
            InpCorner.Parent = InputFrame
            
            local InpStroke = Instance.new("UIStroke")
            InpStroke.Parent = InputFrame
            InpStroke.Color = Theme.ElementStroke
            InpStroke.Thickness = 1
            
            local InpText = Instance.new("TextLabel")
            InpText.Parent = InputFrame
            InpText.BackgroundTransparency = 1
            InpText.Size = UDim2.new(0, 150, 1, 0)
            InpText.Position = UDim2.new(0, 10, 0, 0)
            InpText.Font = Enum.Font.GothamMedium
            InpText.Text = InputSettings.Name
            InpText.TextColor3 = Theme.TextColor
            InpText.TextSize = 14
            InpText.TextXAlignment = Enum.TextXAlignment.Left
            
            local TextBox = Instance.new("TextBox")
            TextBox.Parent = InputFrame
            TextBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            TextBox.Position = UDim2.new(1, -160, 0.5, -12)
            TextBox.Size = UDim2.new(0, 150, 0, 24)
            TextBox.Font = Enum.Font.Gotham
            TextBox.Text = InputSettings.CurrentValue or ""
            TextBox.PlaceholderText = InputSettings.PlaceholderText or "Enter text..."
            TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
            TextBox.TextSize = 13
            
            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 4)
            BoxCorner.Parent = TextBox
            
            TextBox.FocusLost:Connect(function(EnterPressed)
                if InputSettings.Callback then
                    InputSettings.Callback(TextBox.Text)
                end
                if InputSettings.RemoveTextAfterFocusLost then
                    TextBox.Text = ""
                end
            end)
        end

        return Tab
    end
    
    return Window
end

return RayfieldLibrary
