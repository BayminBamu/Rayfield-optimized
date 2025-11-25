--[[ 
    Rayfield Interface Suite (Optimized Standalone Library)
    -------------------------------------------------------
    - FIXED: Topbar Buttons (Search, Min, Close) now use a strict LayoutOrder to prevent overlap.
    - ADDED: Termination Confirmation Modal on Close.
    - VISUALS: Exact Dark Theme & Rounded Corners.
    - BEHAVIOR: 2-Second Notifications.
    - CONTENT: Library ONLY. No Flight Scripts.
    
    USAGE:
    local Library = loadstring(readfile("this_script.lua"))()
    local Window = Library:CreateWindow({Name = "My Script"})
]]

local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

--// THEME CONFIGURATION
local Theme = {
    Background = Color3.fromRGB(25, 25, 25),
    Topbar = Color3.fromRGB(25, 25, 25),
    TabContainer = Color3.fromRGB(35, 35, 35),
    ElementBackground = Color3.fromRGB(32, 32, 32),
    TextColor = Color3.fromRGB(240, 240, 240),
    PlaceholderColor = Color3.fromRGB(150, 150, 150),
    Accent = Color3.fromRGB(60, 140, 255),
    NotificationBG = Color3.fromRGB(20, 20, 20),
    Stroke = Color3.fromRGB(50, 50, 50),
    Crimson = Color3.fromRGB(255, 65, 65)
}

local Icons = {
    Search = "rbxassetid://3944680069",
    Close = "rbxassetid://3944676352",
    Minimize = "rbxassetid://3944652232",
    Settings = "rbxassetid://3944672058"
}

--// UTILITY FUNCTIONS
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

local function Tween(obj, props, time)
    local info = TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

--// LIBRARY MAIN
function Library:CreateWindow(Settings)
    local Window = {}
    local Minimized = false
    local DestroyCallbacks = {}
    
    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RayfieldOptimized_" .. (Settings.Name or "UI")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = GetUIContainer()

    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = Theme.Background
    Main.Position = UDim2.new(0.5, -225, 0.5, -150)
    Main.Size = UDim2.new(0, 500, 0, 350)
    Main.ClipsDescendants = true
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = Main

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = Main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    Main.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    --// TOPBAR
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Parent = Main
    Topbar.BackgroundTransparency = 1
    Topbar.Size = UDim2.new(1, 0, 0, 50)
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = Topbar
    Title.Text = Settings.Name or "Rayfield"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Theme.TextColor
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.TextXAlignment = Enum.TextXAlignment.Left

    --// CONTROL BUTTONS (FIXED LAYOUT)
    -- We use a wide container with UIListLayout set to Right Alignment to prevent overlaps
    local ButtonContainer = Instance.new("Frame")
    ButtonContainer.Name = "ButtonContainer"
    ButtonContainer.Parent = Topbar
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.Position = UDim2.new(1, -140, 0, 0) 
    ButtonContainer.Size = UDim2.new(0, 130, 1, 0)

    local ButtonLayout = Instance.new("UIListLayout")
    ButtonLayout.Parent = ButtonContainer
    ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ButtonLayout.Padding = UDim.new(0, 5) -- 5px gap between buttons
    
    -- Padding to keep away from right edge
    local ButtonPad = Instance.new("UIPadding")
    ButtonPad.Parent = ButtonContainer
    ButtonPad.PaddingRight = UDim.new(0, 15)

    local function CreateTopBtn(Name, Icon, Order, Callback)
        -- Wrapper ensures size is respected by ListLayout
        local BtnWrapper = Instance.new("Frame")
        BtnWrapper.Name = Name .. "_Wrapper"
        BtnWrapper.Parent = ButtonContainer
        BtnWrapper.BackgroundTransparency = 1
        BtnWrapper.Size = UDim2.new(0, 30, 1, 0)
        BtnWrapper.LayoutOrder = Order

        local Btn = Instance.new("ImageButton")
        Btn.Name = Name
        Btn.Parent = BtnWrapper
        Btn.BackgroundTransparency = 1
        Btn.Image = Icon
        Btn.ImageColor3 = Color3.fromRGB(150, 150, 150)
        Btn.Size = UDim2.new(0, 20, 0, 20)
        Btn.Position = UDim2.new(0.5, -10, 0.5, -10) -- Center in wrapper

        Btn.MouseEnter:Connect(function() Tween(Btn, {ImageColor3 = Color3.new(1,1,1)}) end)
        Btn.MouseLeave:Connect(function() Tween(Btn, {ImageColor3 = Color3.fromRGB(150,150,150)}) end)
        Btn.MouseButton1Click:Connect(Callback)
    end

    -- Close Button (Order 3: Far Right)
    CreateTopBtn("Close", Icons.Close, 3, function()
        -- TERMINATION CONFIRMATION MODAL
        local Overlay = Instance.new("TextButton")
        Overlay.Name = "Overlay"
        Overlay.Parent = ScreenGui
        Overlay.BackgroundColor3 = Color3.new(0,0,0)
        Overlay.BackgroundTransparency = 0.5
        Overlay.Size = UDim2.new(1,0,1,0)
        Overlay.AutoButtonColor = false
        Overlay.Text = ""
        Overlay.ZIndex = 10

        local Modal = Instance.new("Frame")
        Modal.Name = "ConfirmationModal"
        Modal.Parent = Overlay
        Modal.BackgroundColor3 = Theme.Background
        Modal.Size = UDim2.new(0, 320, 0, 160)
        Modal.Position = UDim2.new(0.5, -160, 0.5, -80)
        
        local MCorner = Instance.new("UICorner")
        MCorner.CornerRadius = UDim.new(0, 12)
        MCorner.Parent = Modal
        
        local MStroke = Instance.new("UIStroke")
        MStroke.Parent = Modal
        MStroke.Color = Theme.Stroke
        MStroke.Thickness = 1

        local MTitle = Instance.new("TextLabel")
        MTitle.Parent = Modal
        MTitle.BackgroundTransparency = 1
        MTitle.Text = "Terminate Script?"
        MTitle.Font = Enum.Font.GothamBold
        MTitle.TextColor3 = Theme.TextColor
        MTitle.TextSize = 20
        MTitle.Position = UDim2.new(0, 0, 0, 15)
        MTitle.Size = UDim2.new(1, 0, 0, 30)
        
        local MDesc = Instance.new("TextLabel")
        MDesc.Parent = Modal
        MDesc.BackgroundTransparency = 1
        MDesc.Text = "Are you sure you want to terminate the script? This will stop all processes."
        MDesc.Font = Enum.Font.Gotham
        MDesc.TextColor3 = Theme.PlaceholderColor
        MDesc.TextSize = 14
        MDesc.TextWrapped = true
        MDesc.Position = UDim2.new(0, 20, 0, 50)
        MDesc.Size = UDim2.new(1, -40, 0, 40)

        -- Yes Button
        local YesBtn = Instance.new("TextButton")
        YesBtn.Parent = Modal
        YesBtn.BackgroundColor3 = Theme.Crimson
        YesBtn.Text = "Yes, Terminate"
        YesBtn.Font = Enum.Font.GothamBold
        YesBtn.TextColor3 = Color3.new(1,1,1)
        YesBtn.TextSize = 14
        YesBtn.Size = UDim2.new(0, 130, 0, 35)
        YesBtn.Position = UDim2.new(0, 20, 1, -50)
        
        local YCorner = Instance.new("UICorner")
        YCorner.CornerRadius = UDim.new(0, 6)
        YCorner.Parent = YesBtn
        
        -- Cancel Button
        local NoBtn = Instance.new("TextButton")
        NoBtn.Parent = Modal
        NoBtn.BackgroundColor3 = Theme.ElementBackground
        NoBtn.Text = "Cancel"
        NoBtn.Font = Enum.Font.GothamBold
        NoBtn.TextColor3 = Theme.TextColor
        NoBtn.TextSize = 14
        NoBtn.Size = UDim2.new(0, 130, 0, 35)
        NoBtn.Position = UDim2.new(1, -150, 1, -50)
        
        local NCorner = Instance.new("UICorner")
        NCorner.CornerRadius = UDim.new(0, 6)
        NCorner.Parent = NoBtn

        YesBtn.MouseButton1Click:Connect(function()
            for _, cb in pairs(DestroyCallbacks) do task.spawn(cb) end
            ScreenGui:Destroy()
        end)
        
        NoBtn.MouseButton1Click:Connect(function()
            Overlay:Destroy()
        end)
    end)

    -- Minimize Button (Order 2: Middle)
    CreateTopBtn("Minimize", Icons.Minimize, 2, function()
        Minimized = not Minimized
        if Minimized then
            Tween(Main, {Size = UDim2.new(0, 500, 0, 50)})
        else
            Tween(Main, {Size = UDim2.new(0, 500, 0, 350)})
        end
    end)

    -- Search Button (Order 1: Left)
    CreateTopBtn("Search", Icons.Search, 1, function()
        Library:Notify({Title = "Search", Content = "Search feature not implemented.", Duration = 2})
    end)

    --// TABS CONTAINER
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Main
    TabContainer.BackgroundColor3 = Theme.Background
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 20, 0, 50)
    TabContainer.Size = UDim2.new(1, -40, 0, 35)

    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabContainer
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 10)

    --// CONTENT CONTAINER
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Parent = Main
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, 0, 0, 95)
    ContentContainer.Size = UDim2.new(1, 0, 1, -100)
    ContentContainer.ClipsDescendants = true

    --// NOTIFICATION SYSTEM
    local NotifContainer = Instance.new("Frame")
    NotifContainer.Name = "Notifications"
    NotifContainer.Parent = ScreenGui
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.Position = UDim2.new(1, -320, 1, -30)
    NotifContainer.Size = UDim2.new(0, 300, 0.5, 0)
    
    local NotifList = Instance.new("UIListLayout")
    NotifList.Parent = NotifContainer
    NotifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifList.SortOrder = Enum.SortOrder.LayoutOrder
    NotifList.Padding = UDim.new(0, 5)

    function Library:Notify(Config)
        local Notif = Instance.new("Frame")
        Notif.Parent = NotifContainer
        Notif.BackgroundColor3 = Theme.NotificationBG
        Notif.Size = UDim2.new(1, 0, 0, 60)
        Notif.BackgroundTransparency = 0.1
        
        local NCorner = Instance.new("UICorner")
        NCorner.CornerRadius = UDim.new(0, 8)
        NCorner.Parent = Notif

        local NTitle = Instance.new("TextLabel")
        NTitle.Parent = Notif
        NTitle.BackgroundTransparency = 1
        NTitle.Text = Config.Title or "Notification"
        NTitle.Font = Enum.Font.GothamBold
        NTitle.TextColor3 = Theme.TextColor
        NTitle.TextSize = 14
        NTitle.Position = UDim2.new(0, 10, 0, 8)
        NTitle.Size = UDim2.new(1, -20, 0, 20)
        NTitle.TextXAlignment = Enum.TextXAlignment.Left

        local NDesc = Instance.new("TextLabel")
        NDesc.Parent = Notif
        NDesc.BackgroundTransparency = 1
        NDesc.Text = Config.Content or "Message"
        NDesc.Font = Enum.Font.Gotham
        NDesc.TextColor3 = Theme.PlaceholderColor
        NDesc.TextSize = 13
        NDesc.Position = UDim2.new(0, 10, 0, 28)
        NDesc.Size = UDim2.new(1, -20, 0, 20)
        NDesc.TextXAlignment = Enum.TextXAlignment.Left

        -- Auto Close (2 Seconds fixed)
        task.delay(Config.Duration or 2, function()
            Tween(Notif, {BackgroundTransparency = 1}, 0.3)
            Tween(NTitle, {TextTransparency = 1}, 0.3)
            Tween(NDesc, {TextTransparency = 1}, 0.3)
            task.wait(0.3)
            if Notif then Notif:Destroy() end
        end)
    end
    
    -- Cleanup Hook
    function Library:OnDestroy(func)
        table.insert(DestroyCallbacks, func)
    end

    --// TAB SYSTEM
    local FirstTab = true

    function Window:CreateTab(Name, IconId)
        local Tab = {}
        
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = Name .. "Tab"
        TabBtn.Parent = TabContainer
        TabBtn.BackgroundColor3 = Theme.TabContainer
        TabBtn.AutoButtonColor = false
        TabBtn.Text = "  " .. Name .. "  "
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 13
        TabBtn.TextColor3 = Theme.TextColor
        
        local Width = TextService:GetTextSize(TabBtn.Text, 13, Enum.Font.GothamBold, Vector2.new(1000, 100)).X
        TabBtn.Size = UDim2.new(0, Width + 20, 1, 0)

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(1, 0)
        TabCorner.Parent = TabBtn

        local Scroll = Instance.new("ScrollingFrame")
        Scroll.Name = Name .. "Content"
        Scroll.Parent = ContentContainer
        Scroll.BackgroundTransparency = 1
        Scroll.Size = UDim2.new(1, 0, 1, 0)
        Scroll.ScrollBarThickness = 2
        Scroll.Visible = false
        
        local Layout = Instance.new("UIListLayout")
        Layout.Parent = Scroll
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 8)
        
        local Pad = Instance.new("UIPadding")
        Pad.Parent = Scroll
        Pad.PaddingTop = UDim.new(0, 5)
        Pad.PaddingLeft = UDim.new(0, 20)
        Pad.PaddingRight = UDim.new(0, 20)

        local function Activate()
            for _, c in pairs(ContentContainer:GetChildren()) do if c:IsA("ScrollingFrame") then c.Visible = false end end
            for _, b in pairs(TabContainer:GetChildren()) do 
                if b:IsA("TextButton") then 
                    Tween(b, {BackgroundColor3 = Theme.TabContainer, TextColor3 = Color3.fromRGB(150,150,150)}) 
                end 
            end
            Scroll.Visible = true
            Tween(TabBtn, {BackgroundColor3 = Theme.TextColor, TextColor3 = Theme.Background}) 
        end

        TabBtn.MouseButton1Click:Connect(Activate)
        
        if FirstTab then
            FirstTab = false
            Activate()
        else
            TabBtn.TextColor3 = Color3.fromRGB(150,150,150)
        end

        --// UI ELEMENTS
        function Tab:CreateSection(Text)
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Parent = Scroll
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Text = Text
            SectionLabel.Font = Enum.Font.Gotham
            SectionLabel.TextColor3 = Theme.PlaceholderColor
            SectionLabel.TextSize = 13
            SectionLabel.Size = UDim2.new(1, 0, 0, 25)
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
        end

        function Tab:CreateToggle(Config)
            local Toggled = Config.CurrentValue or false
            
            local Container = Instance.new("TextButton")
            Container.Parent = Scroll
            Container.BackgroundColor3 = Theme.ElementBackground
            Container.Size = UDim2.new(1, 0, 0, 42)
            Container.AutoButtonColor = false
            Container.Text = ""
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 8)
            Corner.Parent = Container
            
            local Stroke = Instance.new("UIStroke")
            Stroke.Parent = Container
            Stroke.Color = Theme.Stroke
            Stroke.Thickness = 1
            
            local Title = Instance.new("TextLabel")
            Title.Parent = Container
            Title.BackgroundTransparency = 1
            Title.Text = Config.Name
            Title.Font = Enum.Font.GothamMedium
            Title.TextColor3 = Theme.TextColor
            Title.TextSize = 14
            Title.Position = UDim2.new(0, 15, 0, 0)
            Title.Size = UDim2.new(1, -60, 1, 0)
            Title.TextXAlignment = Enum.TextXAlignment.Left

            local Switch = Instance.new("Frame")
            Switch.Parent = Container
            Switch.BackgroundColor3 = Toggled and Theme.Accent or Color3.fromRGB(60,60,60)
            Switch.Size = UDim2.new(0, 40, 0, 22)
            Switch.Position = UDim2.new(1, -55, 0.5, -11)
            
            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = Switch
            
            local Dot = Instance.new("Frame")
            Dot.Parent = Switch
            Dot.BackgroundColor3 = Color3.new(1,1,1)
            Dot.Size = UDim2.new(0, 18, 0, 18)
            Dot.Position = Toggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            
            local DotCorner = Instance.new("UICorner")
            DotCorner.CornerRadius = UDim.new(1, 0)
            DotCorner.Parent = Dot
            
            Container.MouseButton1Click:Connect(function()
                Toggled = not Toggled
                Tween(Switch, {BackgroundColor3 = Toggled and Theme.Accent or Color3.fromRGB(60,60,60)})
                Tween(Dot, {Position = Toggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)})
                if Config.Callback then Config.Callback(Toggled) end
            end)
        end

        function Tab:CreateSlider(Config)
            local Value = Config.CurrentValue or Config.Range[1]
            local Container = Instance.new("Frame")
            Container.Parent = Scroll
            Container.BackgroundColor3 = Theme.ElementBackground
            Container.Size = UDim2.new(1, 0, 0, 55)
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 8)
            Corner.Parent = Container
            
            local Stroke = Instance.new("UIStroke")
            Stroke.Parent = Container
            Stroke.Color = Theme.Stroke
            Stroke.Thickness = 1
            
            local Title = Instance.new("TextLabel")
            Title.Parent = Container
            Title.BackgroundTransparency = 1
            Title.Text = Config.Name
            Title.Font = Enum.Font.GothamMedium
            Title.TextColor3 = Theme.TextColor
            Title.TextSize = 14
            Title.Position = UDim2.new(0, 15, 0, 10)
            Title.Size = UDim2.new(1, -15, 0, 15)
            Title.TextXAlignment = Enum.TextXAlignment.Left

            local ValueText = Instance.new("TextLabel")
            ValueText.Parent = Container
            ValueText.BackgroundTransparency = 1
            ValueText.Text = Value .. (Config.Suffix or "")
            ValueText.Font = Enum.Font.Gotham
            ValueText.TextColor3 = Theme.PlaceholderColor
            ValueText.TextSize = 13
            ValueText.Position = UDim2.new(1, -115, 0, 10)
            ValueText.Size = UDim2.new(0, 100, 0, 15)
            ValueText.TextXAlignment = Enum.TextXAlignment.Right

            local SliderBar = Instance.new("Frame")
            SliderBar.Parent = Container
            SliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            SliderBar.Size = UDim2.new(1, -30, 0, 6)
            SliderBar.Position = UDim2.new(0, 15, 0, 35)
            
            local BarCorner = Instance.new("UICorner")
            BarCorner.CornerRadius = UDim.new(1, 0)
            BarCorner.Parent = SliderBar
            
            local Fill = Instance.new("Frame")
            Fill.Parent = SliderBar
            Fill.BackgroundColor3 = Theme.Accent
            Fill.Size = UDim2.new((Value - Config.Range[1]) / (Config.Range[2] - Config.Range[1]), 0, 1, 0)
            
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = Fill
            
            local Trigger = Instance.new("TextButton")
            Trigger.Parent = SliderBar
            Trigger.BackgroundTransparency = 1
            Trigger.Size = UDim2.new(1, 0, 1, 0)
            Trigger.Text = ""

            local function Update(input)
                local SizeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                local NewValue = math.floor(Config.Range[1] + ((Config.Range[2] - Config.Range[1]) * SizeX))
                if Config.Increment then
                    NewValue = math.round(NewValue / Config.Increment) * Config.Increment
                end
                
                Tween(Fill, {Size = UDim2.new(SizeX, 0, 1, 0)}, 0.05)
                ValueText.Text = tostring(NewValue) .. (Config.Suffix or "")
                if Config.Callback then Config.Callback(NewValue) end
            end
            
            local Dragging = false
            Trigger.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = true; Update(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end
            end)
        end
        
        function Tab:CreateButton(Config)
            local Container = Instance.new("TextButton")
            Container.Parent = Scroll
            Container.BackgroundColor3 = Theme.ElementBackground
            Container.Size = UDim2.new(1, 0, 0, 42)
            Container.Text = Config.Name
            Container.Font = Enum.Font.GothamMedium
            Container.TextColor3 = Theme.TextColor
            Container.TextSize = 14
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 8)
            Corner.Parent = Container
            
            local Stroke = Instance.new("UIStroke")
            Stroke.Parent = Container
            Stroke.Color = Theme.Stroke
            Stroke.Thickness = 1

            Container.MouseButton1Click:Connect(function()
                Tween(Container, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}, 0.1)
                task.wait(0.1)
                Tween(Container, {BackgroundColor3 = Theme.ElementBackground}, 0.1)
                if Config.Callback then Config.Callback() end
            end)
        end

        function Tab:CreateLabel(Text)
            local Label = Instance.new("TextLabel")
            Label.Parent = Scroll
            Label.BackgroundTransparency = 1
            Label.Text = Text
            Label.Font = Enum.Font.Gotham
            Label.TextColor3 = Theme.PlaceholderColor
            Label.TextSize = 14
            Label.Size = UDim2.new(1, 0, 0, 30)
            Label.TextXAlignment = Enum.TextXAlignment.Center
        end
        
        function Tab:CreateInput(Config)
            local Container = Instance.new("Frame")
            Container.Parent = Scroll
            Container.BackgroundColor3 = Theme.ElementBackground
            Container.Size = UDim2.new(1, 0, 0, 42)
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 8)
            Corner.Parent = Container
            
            local Stroke = Instance.new("UIStroke")
            Stroke.Parent = Container
            Stroke.Color = Theme.Stroke
            Stroke.Thickness = 1
            
            local Title = Instance.new("TextLabel")
            Title.Parent = Container
            Title.BackgroundTransparency = 1
            Title.Text = Config.Name
            Title.Font = Enum.Font.GothamMedium
            Title.TextColor3 = Theme.TextColor
            Title.TextSize = 14
            Title.Position = UDim2.new(0, 15, 0, 0)
            Title.Size = UDim2.new(1, -145, 1, 0)
            Title.TextXAlignment = Enum.TextXAlignment.Left

            local InputBox = Instance.new("TextBox")
            InputBox.Parent = Container
            InputBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            InputBox.Position = UDim2.new(1, -135, 0.5, -12)
            InputBox.Size = UDim2.new(0, 120, 0, 24)
            InputBox.Font = Enum.Font.Gotham
            InputBox.Text = ""
            InputBox.PlaceholderText = Config.PlaceholderText or "Input..."
            InputBox.TextColor3 = Theme.TextColor
            InputBox.PlaceholderColor3 = Theme.PlaceholderColor
            InputBox.TextSize = 13
            
            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 4)
            BoxCorner.Parent = InputBox

            InputBox.FocusLost:Connect(function(Enter)
                if Config.Callback then Config.Callback(InputBox.Text) end
                if Config.RemoveTextAfterFocusLost then InputBox.Text = "" end
            end)
        end

        return Tab
    end

    return Window
end

return Library
