--[[ 
    Rayfield Interface Suite (Optimized Standalone Library)
    -------------------------------------------------------
    - Fully Self-Contained (No external loadstrings)
    - Optimized Performance (Reduced table lookups)
    - Minimizable & Hidable (Keybind system)
    - Secure Termination (Close button with confirmation)
    - Smooth Animations (TweenService)
    
    How to use:
    local Rayfield = loadstring(readfile("rayfield_standalone.lua"))()
    local Window = Rayfield:CreateWindow(...)
]]

local RayfieldLibrary = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

--// Utility: Safe GUI Container
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

--// Utility: Tweening
local function Tween(instance, info, propertyTable)
    local tween = TweenService:Create(instance, info, propertyTable)
    tween:Play()
    return tween
end

--// Utility: Draggable
local function MakeDraggable(topbar, main)
    local dragging, dragInput, dragStart, startPos
    
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(main, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            })
        end
    end)
end

--// Theme Configuration
local Theme = {
    TextColor = Color3.fromRGB(240, 240, 240),
    Background = Color3.fromRGB(25, 25, 25),
    Topbar = Color3.fromRGB(34, 34, 34),
    Shadow = Color3.fromRGB(20, 20, 20),
    TabBackground = Color3.fromRGB(80, 80, 80),
    TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
    TabTextColor = Color3.fromRGB(240, 240, 240),
    SelectedTabTextColor = Color3.fromRGB(50, 50, 50),
    ElementBackground = Color3.fromRGB(35, 35, 35),
    ElementStroke = Color3.fromRGB(50, 50, 50),
    ToggleEnabled = Color3.fromRGB(0, 146, 214),
    ToggleDisabled = Color3.fromRGB(100, 100, 100),
    SliderColor = Color3.fromRGB(50, 138, 220),
    Crimson = Color3.fromRGB(255, 65, 65)
}

--// Main Function to Create Window
function RayfieldLibrary:CreateWindow(Settings)
    local Library = {}
    local DestroyCallbacks = {}
    
    -- UI State
    local UIKeybind = Settings.Keybind or Enum.KeyCode.RightControl
    local Minimized = false
    local SettingsOpen = false

    -- Create ScreenGui
    local RayfieldGui = Instance.new("ScreenGui")
    RayfieldGui.Name = "RayfieldOptimized_" .. (Settings.Name or "UI")
    RayfieldGui.ResetOnSpawn = false
    RayfieldGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    RayfieldGui.Parent = GetUIContainer()

    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = RayfieldGui
    Main.BackgroundColor3 = Theme.Background
    Main.Position = UDim2.new(0.5, -250, 0.5, -175)
    Main.Size = UDim2.new(0, 500, 0, 350)
    Main.ClipsDescendants = true
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 9)
    MainCorner.Parent = Main
    
    -- Topbar
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Parent = Main
    Topbar.BackgroundColor3 = Theme.Topbar
    Topbar.Size = UDim2.new(1, 0, 0, 45)
    
    local TopbarCorner = Instance.new("UICorner")
    TopbarCorner.CornerRadius = UDim.new(0, 9)
    TopbarCorner.Parent = Topbar
    
    -- Topbar Filler (Hides bottom rounded corners of Topbar for flush look)
    local TopbarFiller = Instance.new("Frame")
    TopbarFiller.Parent = Topbar
    TopbarFiller.BackgroundColor3 = Theme.Topbar
    TopbarFiller.BorderSizePixel = 0
    TopbarFiller.Position = UDim2.new(0, 0, 1, -10)
    TopbarFiller.Size = UDim2.new(1, 0, 0, 10)

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Parent = Topbar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = Settings.Name or "Rayfield Optimized"
    Title.TextColor3 = Theme.TextColor
    Title.TextSize = 17
    Title.TextXAlignment = Enum.TextXAlignment.Left

    MakeDraggable(Topbar, Main)

    --// CONTROL BUTTONS (Close, Min, Settings)
    local ButtonContainer = Instance.new("Frame")
    ButtonContainer.Parent = Topbar
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.Position = UDim2.new(1, -105, 0, 0)
    ButtonContainer.Size = UDim2.new(0, 100, 1, 0)

    local function CreateTopButton(name, icon, order)
        local Btn = Instance.new("TextButton")
        Btn.Name = name
        Btn.Parent = ButtonContainer
        Btn.BackgroundTransparency = 1
        Btn.Position = UDim2.new(1, -30 * order, 0, 7)
        Btn.Size = UDim2.new(0, 30, 0, 30)
        Btn.Text = icon
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 16
        Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
        
        Btn.MouseEnter:Connect(function() Tween(Btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255,255,255)}) end)
        Btn.MouseLeave:Connect(function() Tween(Btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150,150,150)}) end)
        return Btn
    end

    local CloseBtn = CreateTopButton("Close", "X", 1)
    local MinBtn = CreateTopButton("Minimize", "-", 2)
    local SettingsBtn = CreateTopButton("Settings", "⚙", 3)

    -- Elements Container
    local Elements = Instance.new("Frame")
    Elements.Name = "Elements"
    Elements.Parent = Main
    Elements.BackgroundColor3 = Theme.Background
    Elements.BackgroundTransparency = 1
    Elements.Position = UDim2.new(0, 0, 0, 45)
    Elements.Size = UDim2.new(1, 0, 1, -45)

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = Elements
    Sidebar.BackgroundColor3 = Theme.Background
    Sidebar.Size = UDim2.new(0, 130, 1, 0)
    Sidebar.BorderSizePixel = 0
    
    local SidebarList = Instance.new("UIListLayout")
    SidebarList.Parent = Sidebar
    SidebarList.Padding = UDim.new(0, 5)
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    
    local SidebarPad = Instance.new("UIPadding")
    SidebarPad.Parent = Sidebar
    SidebarPad.PaddingTop = UDim.new(0, 10)
    SidebarPad.PaddingLeft = UDim.new(0, 10)

    -- Content
    local Content = Instance.new("Frame")
    Content.Parent = Elements
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 140, 0, 0)
    Content.Size = UDim2.new(1, -140, 1, 0)

    --// MINIMIZE LOGIC
    MinBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            Tween(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 500, 0, 45)})
            Elements.Visible = false
        else
            Tween(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 500, 0, 350)})
            task.delay(0.3, function() if not Minimized then Elements.Visible = true end end)
        end
    end)

    --// TERMINATE / CLOSE LOGIC
    local function Terminate()
        for _, callback in pairs(DestroyCallbacks) do
            task.spawn(callback)
        end
        RayfieldGui:Destroy()
    end

    CloseBtn.MouseButton1Click:Connect(function()
        -- Confirmation Modal
        local Overlay = Instance.new("TextButton") -- Blocks input
        Overlay.Name = "ConfirmationOverlay"
        Overlay.Parent = RayfieldGui
        Overlay.BackgroundColor3 = Color3.new(0,0,0)
        Overlay.BackgroundTransparency = 0.5
        Overlay.Size = UDim2.new(1,0,1,0)
        Overlay.AutoButtonColor = false
        Overlay.Text = ""

        local Modal = Instance.new("Frame")
        Modal.Parent = Overlay
        Modal.BackgroundColor3 = Theme.Background
        Modal.Size = UDim2.new(0, 300, 0, 150)
        Modal.Position = UDim2.new(0.5, -150, 0.5, -75)
        
        local ModalCorner = Instance.new("UICorner")
        ModalCorner.CornerRadius = UDim.new(0, 9)
        ModalCorner.Parent = Modal
        
        local ModalTitle = Instance.new("TextLabel")
        ModalTitle.Parent = Modal
        ModalTitle.BackgroundTransparency = 1
        ModalTitle.Position = UDim2.new(0,0,0,15)
        ModalTitle.Size = UDim2.new(1,0,0,30)
        ModalTitle.Font = Enum.Font.GothamBold
        ModalTitle.Text = "Terminate Script?"
        ModalTitle.TextColor3 = Theme.TextColor
        ModalTitle.TextSize = 18

        local ModalDesc = Instance.new("TextLabel")
        ModalDesc.Parent = Modal
        ModalDesc.BackgroundTransparency = 1
        ModalDesc.Position = UDim2.new(0,10,0,50)
        ModalDesc.Size = UDim2.new(1,-20,0,40)
        ModalDesc.Font = Enum.Font.Gotham
        ModalDesc.Text = "Are you sure you want to stop all processes and close the UI?"
        ModalDesc.TextColor3 = Color3.fromRGB(180,180,180)
        ModalDesc.TextSize = 14
        ModalDesc.TextWrapped = true

        local Confirm = Instance.new("TextButton")
        Confirm.Parent = Modal
        Confirm.BackgroundColor3 = Theme.Crimson
        Confirm.Position = UDim2.new(0.5, -120, 1, -40)
        Confirm.Size = UDim2.new(0, 110, 0, 30)
        Confirm.Font = Enum.Font.GothamBold
        Confirm.Text = "Yes, Close"
        Confirm.TextColor3 = Color3.new(1,1,1)
        Confirm.TextSize = 14
        Instance.new("UICorner", Confirm).CornerRadius = UDim.new(0,6)

        local Cancel = Instance.new("TextButton")
        Cancel.Parent = Modal
        Cancel.BackgroundColor3 = Theme.ElementBackground
        Cancel.Position = UDim2.new(0.5, 10, 1, -40)
        Cancel.Size = UDim2.new(0, 110, 0, 30)
        Cancel.Font = Enum.Font.GothamBold
        Cancel.Text = "Cancel"
        Cancel.TextColor3 = Theme.TextColor
        Cancel.TextSize = 14
        Instance.new("UICorner", Cancel).CornerRadius = UDim.new(0,6)

        Confirm.MouseButton1Click:Connect(Terminate)
        Cancel.MouseButton1Click:Connect(function() Overlay:Destroy() end)
    end)

    --// SETTINGS & KEYBIND LOGIC
    local SettingFrame = Instance.new("Frame")
    SettingFrame.Parent = Main
    SettingFrame.BackgroundColor3 = Theme.Background
    SettingFrame.BackgroundTransparency = 0.1
    SettingFrame.Position = UDim2.new(0,0,1,0) -- Hidden
    SettingFrame.Size = UDim2.new(1,0,1,-45)
    SettingFrame.ZIndex = 5
    
    local SettingLabel = Instance.new("TextLabel")
    SettingLabel.Parent = SettingFrame
    SettingLabel.BackgroundTransparency = 1
    SettingLabel.Position = UDim2.new(0,0,0,20)
    SettingLabel.Size = UDim2.new(1,0,0,30)
    SettingLabel.Font = Enum.Font.GothamBold
    SettingLabel.Text = "Settings"
    SettingLabel.TextColor3 = Theme.TextColor
    SettingLabel.TextSize = 18

    local KeybindBtn = Instance.new("TextButton")
    KeybindBtn.Parent = SettingFrame
    KeybindBtn.BackgroundColor3 = Theme.ElementBackground
    KeybindBtn.Position = UDim2.new(0.5, -100, 0.5, -20)
    KeybindBtn.Size = UDim2.new(0, 200, 0, 40)
    KeybindBtn.Font = Enum.Font.Gotham
    KeybindBtn.Text = "Keybind: " .. UIKeybind.Name
    KeybindBtn.TextColor3 = Theme.TextColor
    KeybindBtn.TextSize = 14
    Instance.new("UICorner", KeybindBtn).CornerRadius = UDim.new(0,6)

    local Listening = false
    KeybindBtn.MouseButton1Click:Connect(function()
        Listening = true
        KeybindBtn.Text = "Press any key..."
    end)

    UserInputService.InputBegan:Connect(function(input)
        -- Handle Keybind Assignment
        if Listening and input.UserInputType == Enum.UserInputType.Keyboard then
            UIKeybind = input.KeyCode
            KeybindBtn.Text = "Keybind: " .. UIKeybind.Name
            Listening = false
        -- Handle Toggle Visibility
        elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == UIKeybind and not Listening then
            Main.Visible = not Main.Visible
        end
    end)

    SettingsBtn.MouseButton1Click:Connect(function()
        SettingsOpen = not SettingsOpen
        if SettingsOpen then
            Tween(SettingFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,45)})
        else
            Tween(SettingFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(0,0,1,0)})
        end
    end)

    --// TABS & ELEMENTS SYSTEM
    function Library:CreateTab(Name)
        local Tab = {}
        
        -- Tab Button
        local TabBtn = Instance.new("TextButton")
        TabBtn.Parent = Sidebar
        TabBtn.BackgroundColor3 = Theme.TabBackground
        TabBtn.Size = UDim2.new(1, -10, 0, 32)
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.Text = Name
        TabBtn.TextColor3 = Theme.TabTextColor
        TabBtn.TextSize = 13
        TabBtn.AutoButtonColor = false
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        -- Tab Content
        local Scroll = Instance.new("ScrollingFrame")
        Scroll.Parent = Content
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
        Pad.PaddingTop = UDim.new(0, 10)
        Pad.PaddingLeft = UDim.new(0, 5)
        Pad.PaddingRight = UDim.new(0, 10)

        -- Switch Tab Function
        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Content:GetChildren()) do v.Visible = false end
            for _, v in pairs(Sidebar:GetChildren()) do 
                if v:IsA("TextButton") then 
                    Tween(v, TweenInfo.new(0.2), {BackgroundColor3 = Theme.TabBackground, TextColor3 = Theme.TabTextColor}) 
                end 
            end
            
            Scroll.Visible = true
            Tween(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.TabBackgroundSelected, TextColor3 = Theme.SelectedTabTextColor})
        end)

        -- Elements
        function Tab:CreateSection(Name)
            local Label = Instance.new("TextLabel")
            Label.Parent = Scroll
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.new(1, 0, 0, 25)
            Label.Font = Enum.Font.GothamBold
            Label.Text = Name
            Label.TextColor3 = Theme.TextColor
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
        end

        function Tab:CreateToggle(Settings)
            local Enabled = Settings.CurrentValue or false
            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Parent = Scroll
            ToggleFrame.BackgroundColor3 = Theme.ElementBackground
            ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
            ToggleFrame.AutoButtonColor = false
            ToggleFrame.Text = ""
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", ToggleFrame).Color = Theme.ElementStroke

            local Label = Instance.new("TextLabel")
            Label.Parent = ToggleFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Size = UDim2.new(1, -60, 1, 0)
            Label.Font = Enum.Font.GothamMedium
            Label.Text = Settings.Name
            Label.TextColor3 = Theme.TextColor
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local Indicator = Instance.new("Frame")
            Indicator.Parent = ToggleFrame
            Indicator.Position = UDim2.new(1, -50, 0.5, -10)
            Indicator.Size = UDim2.new(0, 40, 0, 20)
            Indicator.BackgroundColor3 = Enabled and Theme.ToggleEnabled or Theme.ToggleDisabled
            Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

            local Dot = Instance.new("Frame")
            Dot.Parent = Indicator
            Dot.Size = UDim2.new(0, 16, 0, 16)
            Dot.Position = Enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Dot.BackgroundColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

            ToggleFrame.MouseButton1Click:Connect(function()
                Enabled = not Enabled
                Tween(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = Enabled and Theme.ToggleEnabled or Theme.ToggleDisabled})
                Tween(Dot, TweenInfo.new(0.2), {Position = Enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                if Settings.Callback then Settings.Callback(Enabled) end
            end)
        end

        function Tab:CreateSlider(Settings)
            local Value = Settings.CurrentValue or Settings.Range[1]
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Parent = Scroll
            SliderFrame.BackgroundColor3 = Theme.ElementBackground
            SliderFrame.Size = UDim2.new(1, 0, 0, 50)
            Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", SliderFrame).Color = Theme.ElementStroke

            local Label = Instance.new("TextLabel")
            Label.Parent = SliderFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 10, 0, 5)
            Label.Size = UDim2.new(1, -20, 0, 20)
            Label.Font = Enum.Font.GothamMedium
            Label.Text = Settings.Name
            Label.TextColor3 = Theme.TextColor
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Parent = SliderFrame
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Position = UDim2.new(0, 10, 0, 5)
            ValueLabel.Size = UDim2.new(1, -20, 0, 20)
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.Text = tostring(Value) .. (Settings.Suffix or "")
            ValueLabel.TextColor3 = Theme.TextColor
            ValueLabel.TextSize = 14
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

            local Bar = Instance.new("TextButton")
            Bar.Parent = SliderFrame
            Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Bar.Position = UDim2.new(0, 10, 0, 32)
            Bar.Size = UDim2.new(1, -20, 0, 6)
            Bar.AutoButtonColor = false
            Bar.Text = ""
            Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

            local Fill = Instance.new("Frame")
            Fill.Parent = Bar
            Fill.BackgroundColor3 = Theme.SliderColor
            Fill.Size = UDim2.new((Value - Settings.Range[1]) / (Settings.Range[2] - Settings.Range[1]), 0, 1, 0)
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

            local function Update(input)
                local SizeX = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                Value = math.floor(Settings.Range[1] + ((Settings.Range[2] - Settings.Range[1]) * SizeX))
                if Settings.Increment then Value = math.round(Value / Settings.Increment) * Settings.Increment end
                
                Tween(Fill, TweenInfo.new(0.05), {Size = UDim2.new(SizeX, 0, 1, 0)})
                ValueLabel.Text = tostring(Value) .. (Settings.Suffix or "")
                if Settings.Callback then Settings.Callback(Value) end
            end

            local Dragging = false
            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    Update(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    Update(input)
                end
            end)
        end
        
        function Tab:CreateButton(Settings)
            local Btn = Instance.new("TextButton")
            Btn.Parent = Scroll
            Btn.BackgroundColor3 = Theme.ElementBackground
            Btn.Size = UDim2.new(1, 0, 0, 40)
            Btn.Text = Settings.Name
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextColor3 = Theme.TextColor
            Btn.TextSize = 14
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", Btn).Color = Theme.ElementStroke
            
            Btn.MouseButton1Click:Connect(function()
                Tween(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60,60,60)})
                task.wait(0.1)
                Tween(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ElementBackground})
                if Settings.Callback then Settings.Callback() end
            end)
        end

        return Tab
    end

    function Library:Notify(Config)
        warn("[Rayfield Notification] " .. Config.Title .. ": " .. Config.Content)
    end
    
    function Library:OnDestroy(callback)
        table.insert(DestroyCallbacks, callback)
    end

    return Library
end

return RayfieldLibrary
