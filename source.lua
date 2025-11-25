--[[ 
    Rayfield Interface Suite (Optimized Standalone Library)
    -------------------------------------------------------
    - TARGET: Library Source Code ONLY.
    - LAYOUT: Exact Rayfield Replica (Horizontal Tabs, Dark Theme).
    - FIXED: Buttons use Manual Positioning to prevent overlapping/glitching.
    - ADDED: Termination Confirmation Modal on Close.
    
    USAGE:
    local Library = loadstring(readfile("rayfield_optimized.lua"))()
    local Window = Library:CreateWindow({Name = "Script Name"})
]]

local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

--// THEME
local Theme = {
    Background = Color3.fromRGB(25, 25, 25),
    Topbar = Color3.fromRGB(25, 25, 25), -- Seamless with background
    TabContainer = Color3.fromRGB(35, 35, 35),
    ElementBackground = Color3.fromRGB(32, 32, 32),
    TextColor = Color3.fromRGB(240, 240, 240),
    PlaceholderColor = Color3.fromRGB(150, 150, 150),
    Accent = Color3.fromRGB(60, 140, 255), -- Default Blue Accent
    NotificationBG = Color3.fromRGB(20, 20, 20),
    Stroke = Color3.fromRGB(50, 50, 50),
    Crimson = Color3.fromRGB(255, 65, 65)
}

--// ICONS (Roblox Asset IDs)
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
    Main.Position = UDim2.new(0.5, -250, 0.5, -175)
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

    --// CONTROL BUTTONS (Manual Positioning - No Layouts to prevent glitches)
    local ButtonContainer = Instance.new("Frame")
    ButtonContainer.Name = "Buttons"
    ButtonContainer.Parent = Topbar
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.Position = UDim2.new(1, -125, 0, 0) 
    ButtonContainer.Size = UDim2.new(0, 120, 1, 0)

    local function CreateTopButton(Name, Icon, Order, Callback)
        local Btn = Instance.new("ImageButton")
        Btn.Name = Name
        Btn.Parent = ButtonContainer
        Btn.BackgroundTransparency = 1
        -- Manual Positioning: Pushes from Right to Left (Order 1 = Far Right)
        Btn.Position = UDim2.new(1, -35 * Order, 0.5, -10) 
        Btn.Size = UDim2.new(0, 20, 0, 20)
        Btn.Image = Icon
        Btn.ImageColor3 = Color3.fromRGB(150, 150, 150)
        
        Btn.MouseEnter:Connect(function() Tween(Btn, {ImageColor3 = Color3.new(1,1,1)}) end)
        Btn.MouseLeave:Connect(function() Tween(Btn, {ImageColor3 = Color3.fromRGB(150,150,150)}) end)
        Btn.MouseButton1Click:Connect(Callback)
    end

    -- Close (Order 1: Far Right)
    CreateTopButton("Close", Icons.Close, 1, function()
        -- TERMINATION MODAL
        local Overlay = Instance.new("TextButton")
        Overlay.Name = "ModalOverlay"
        Overlay.Parent = ScreenGui
        Overlay.BackgroundColor3 = Color3.new(0,0,0)
        Overlay.BackgroundTransparency = 0.5
        Overlay.Size = UDim2.new(1,0,1,0)
        Overlay.AutoButtonColor = false
        Overlay.Text = ""
        Overlay.ZIndex = 20

        local Modal = Instance.new("Frame")
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

        local YesBtn = Instance.new("TextButton")
        YesBtn.Parent = Modal
        YesBtn.BackgroundColor3 = Theme.Crimson
        YesBtn.Text = "Yes, Terminate"
        YesBtn.TextColor3 = Color3.new(1,1,1)
        YesBtn.Font = Enum.Font.GothamBold
        YesBtn.TextSize = 14
        YesBtn.Size = UDim2.new(0, 130, 0, 35)
        YesBtn.Position = UDim2.new(0, 20, 1, -50)
        local YC = Instance.new("UICorner"); YC.CornerRadius = UDim.new(0,6); YC.Parent = YesBtn

        local NoBtn = Instance.new("TextButton")
        NoBtn.Parent = Modal
        NoBtn.BackgroundColor3 = Theme.ElementBackground
        NoBtn.Text = "Cancel"
        NoBtn.TextColor3 = Theme.TextColor
        NoBtn.Font = Enum.Font.GothamBold
        NoBtn.TextSize = 14
        NoBtn.Size = UDim2.new(0, 130, 0, 35)
        NoBtn.Position = UDim2.new(1, -150, 1, -50)
        local NC = Instance.new("UICorner"); NC.CornerRadius = UDim.new(0,6); NC.Parent = NoBtn

        YesBtn.MouseButton1Click:Connect(function()
            for _, cb in pairs(DestroyCallbacks) do task.spawn(cb) end
            ScreenGui:Destroy()
        end)
        NoBtn.MouseButton1Click:Connect(function() Overlay:Destroy() end)
    end)

    -- Minimize (Order 2)
    CreateTopButton("Minimize", Icons.Minimize, 2, function()
        Minimized = not Minimized
        if Minimized then
            Tween(Main, {Size = UDim2.new(0, 500, 0, 50)})
        else
            Tween(Main, {Size = UDim2.new(0, 500, 0, 350)})
        end
    end)

    -- Search (Order 3) - Visual Placeholder
    CreateTopButton("Search", Icons.Search, 3, function()
        Library:Notify({Title="Search", Content="Search feature not implemented.", Duration=1})
    end)

    --// TABS CONTAINER (Rayfield Horizontal Style)
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

    --// NOTIFICATIONS
    local NotifHolder = Instance.new("Frame")
    NotifHolder.Name = "Notifications"
    NotifHolder.Parent = ScreenGui
    NotifHolder.BackgroundTransparency = 1
    NotifHolder.Position = UDim2.new(1, -320, 1, -30)
    NotifHolder.Size = UDim2.new(0, 300, 0.5, 0)
    
    local NotifList = Instance.new("UIListLayout")
    NotifList.Parent = NotifHolder
    NotifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifList.SortOrder = Enum.SortOrder.LayoutOrder
    NotifList.Padding = UDim.new(0, 5)

    function Library:Notify(Config)
        local Notif = Instance.new("Frame")
        Notif.Parent = NotifHolder
        Notif.BackgroundColor3 = Theme.NotificationBG
        Notif.Size = UDim2.new(1, 0, 0, 60)
        Notif.BackgroundTransparency = 0.1
        
        local NC = Instance.new("UICorner"); NC.CornerRadius = UDim.new(0,8); NC.Parent = Notif
        
        local NT = Instance.new("TextLabel")
        NT.Parent = Notif; NT.BackgroundTransparency = 1
        NT.Text = Config.Title or "Notification"
        NT.Font = Enum.Font.GothamBold; NT.TextColor3 = Theme.TextColor
        NT.TextSize = 14; NT.Position = UDim2.new(0,10,0,8); NT.Size = UDim2.new(1,-20,0,20)
        NT.TextXAlignment = Enum.TextXAlignment.Left

        local ND = Instance.new("TextLabel")
        ND.Parent = Notif; ND.BackgroundTransparency = 1
        ND.Text = Config.Content or ""
        ND.Font = Enum.Font.Gotham; ND.TextColor3 = Theme.PlaceholderColor
        ND.TextSize = 13; ND.Position = UDim2.new(0,10,0,28); ND.Size = UDim2.new(1,-20,0,20)
        ND.TextXAlignment = Enum.TextXAlignment.Left

        task.delay(Config.Duration or 2, function()
            Tween(Notif, {BackgroundTransparency = 1}, 0.5)
            Tween(NT, {TextTransparency = 1}, 0.5)
            Tween(ND, {TextTransparency = 1}, 0.5)
            task.wait(0.5)
            Notif:Destroy()
        end)
    end

    function Library:OnDestroy(func)
        table.insert(DestroyCallbacks, func)
    end

    --// TABS & ELEMENTS
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
        
        -- Auto Width based on text size
        local Width = TextService:GetTextSize(TabBtn.Text, 13, Enum.Font.GothamBold, Vector2.new(1000, 100)).X
        TabBtn.Size = UDim2.new(0, Width + 20, 1, 0)

        local TC = Instance.new("UICorner"); TC.CornerRadius = UDim.new(1,0); TC.Parent = TabBtn

        -- Optional Tab Icon
        if IconId then
             -- Logic to add icon if provided (user requested specific asset for settings)
             local Img = Instance.new("ImageLabel")
             Img.Parent = TabBtn
             Img.BackgroundTransparency = 1
             Img.Position = UDim2.new(0, 5, 0.5, -7)
             Img.Size = UDim2.new(0, 14, 0, 14)
             if type(IconId) == "number" then
                Img.Image = "rbxassetid://" .. IconId
             else
                Img.Image = IconId
             end
             TabBtn.Text = "      " .. Name .. "  " -- Add padding for icon
             -- Recalculate width
             Width = TextService:GetTextSize(TabBtn.Text, 13, Enum.Font.GothamBold, Vector2.new(1000, 100)).X
             TabBtn.Size = UDim2.new(0, Width + 10, 1, 0)
        end

        local Scroll = Instance.new("ScrollingFrame")
        Scroll.Name = Name .. "Content"
        Scroll.Parent = ContentContainer
        Scroll.BackgroundTransparency = 1
        Scroll.Size = UDim2.new(1, 0, 1, 0)
        Scroll.Visible = false
        Scroll.ScrollBarThickness = 2
        
        local List = Instance.new("UIListLayout")
        List.Parent = Scroll
        List.SortOrder = Enum.SortOrder.LayoutOrder
        List.Padding = UDim.new(0, 6)
        
        local Pad = Instance.new("UIPadding")
        Pad.Parent = Scroll
        Pad.PaddingTop = UDim.new(0, 5)
        Pad.PaddingLeft = UDim.new(0, 20)
        Pad.PaddingRight = UDim.new(0, 20)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentContainer:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(TabContainer:GetChildren()) do 
                if v:IsA("TextButton") then 
                    Tween(v, {BackgroundColor3 = Theme.TabContainer, TextColor3 = Color3.fromRGB(150,150,150)})
                end 
            end
            Scroll.Visible = true
            Tween(TabBtn, {BackgroundColor3 = Theme.TextColor, TextColor3 = Theme.Background}) 
        end)

        if FirstTab then 
            FirstTab = false; Scroll.Visible = true
            TabBtn.TextColor3 = Theme.Background; TabBtn.BackgroundColor3 = Theme.TextColor
        else
            TabBtn.TextColor3 = Color3.fromRGB(150,150,150)
        end

        -- Element Construction Helpers
        function Tab:CreateSection(Text)
            local L = Instance.new("TextLabel")
            L.Parent = Scroll; L.BackgroundTransparency = 1
            L.Text = Text; L.Font = Enum.Font.Gotham
            L.TextColor3 = Theme.PlaceholderColor; L.TextSize = 13
            L.Size = UDim2.new(1,0,0,25); L.TextXAlignment = Enum.TextXAlignment.Left
        end

        function Tab:CreateToggle(Config)
            local Enabled = Config.CurrentValue or false
            local Btn = Instance.new("TextButton")
            Btn.Parent = Scroll; Btn.BackgroundColor3 = Theme.ElementBackground
            Btn.Size = UDim2.new(1,0,0,42); Btn.Text = ""; Btn.AutoButtonColor = false
            local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0,8); BC.Parent = Btn
            local S = Instance.new("UIStroke"); S.Parent = Btn; S.Color = Theme.Stroke; S.Thickness = 1
            
            local L = Instance.new("TextLabel")
            L.Parent = Btn; L.BackgroundTransparency = 1
            L.Text = Config.Name; L.Font = Enum.Font.GothamMedium
            L.TextColor3 = Theme.TextColor; L.TextSize = 14
            L.Position = UDim2.new(0,15,0,0); L.Size = UDim2.new(1,-60,1,0)
            L.TextXAlignment = Enum.TextXAlignment.Left
            
            local Ind = Instance.new("Frame")
            Ind.Parent = Btn; Ind.BackgroundColor3 = Enabled and Theme.Accent or Color3.fromRGB(60,60,60)
            Ind.Position = UDim2.new(1,-55,0.5,-11); Ind.Size = UDim2.new(0,40,0,22)
            local IC = Instance.new("UICorner"); IC.CornerRadius = UDim.new(1,0); IC.Parent = Ind
            
            local Dot = Instance.new("Frame")
            Dot.Parent = Ind; Dot.BackgroundColor3 = Color3.new(1,1,1)
            Dot.Position = Enabled and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)
            Dot.Size = UDim2.new(0,18,0,18)
            local DC = Instance.new("UICorner"); DC.CornerRadius = UDim.new(1,0); DC.Parent = Dot
            
            Btn.MouseButton1Click:Connect(function()
                Enabled = not Enabled
                Tween(Ind, {BackgroundColor3 = Enabled and Theme.Accent or Color3.fromRGB(60,60,60)})
                Tween(Dot, {Position = Enabled and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)})
                if Config.Callback then Config.Callback(Enabled) end
            end)
        end
        
        function Tab:CreateSlider(Config)
            local Val = Config.CurrentValue or Config.Range[1]
            local F = Instance.new("Frame")
            F.Parent = Scroll; F.BackgroundColor3 = Theme.ElementBackground
            F.Size = UDim2.new(1,0,0,55)
            local FC = Instance.new("UICorner"); FC.CornerRadius = UDim.new(0,8); FC.Parent = F
            local S = Instance.new("UIStroke"); S.Parent = F; S.Color = Theme.Stroke; S.Thickness = 1
            
            local T = Instance.new("TextLabel")
            T.Parent = F; T.BackgroundTransparency = 1
            T.Text = Config.Name; T.Font = Enum.Font.GothamMedium
            T.TextColor3 = Theme.TextColor; T.TextSize = 14
            T.Position = UDim2.new(0,15,0,10); T.Size = UDim2.new(1,-15,0,15)
            T.TextXAlignment = Enum.TextXAlignment.Left
            
            local V = Instance.new("TextLabel")
            V.Parent = F; V.BackgroundTransparency = 1
            V.Text = Val .. (Config.Suffix or ""); V.Font = Enum.Font.Gotham
            V.TextColor3 = Theme.PlaceholderColor; V.TextSize = 13
            V.Position = UDim2.new(1,-115,0,10); V.Size = UDim2.new(0,100,0,15)
            V.TextXAlignment = Enum.TextXAlignment.Right
            
            local Bar = Instance.new("TextButton")
            Bar.Parent = F; Bar.BackgroundColor3 = Color3.fromRGB(45,45,45)
            Bar.Position = UDim2.new(0,15,0,35); Bar.Size = UDim2.new(1,-30,0,6)
            Bar.Text = ""; Bar.AutoButtonColor = false
            local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(1,0); BC.Parent = Bar
            
            local Fill = Instance.new("Frame")
            Fill.Parent = Bar; Fill.BackgroundColor3 = Theme.Accent
            Fill.Size = UDim2.new((Val - Config.Range[1])/(Config.Range[2] - Config.Range[1]), 0, 1, 0)
            local FiC = Instance.new("UICorner"); FiC.CornerRadius = UDim.new(1,0); FiC.Parent = Fill
            
            local function Update(Input)
                local SizeX = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                Val = math.floor(Config.Range[1] + ((Config.Range[2] - Config.Range[1]) * SizeX))
                Tween(Fill, {Size = UDim2.new(SizeX,0,1,0)}, 0.1)
                V.Text = Val .. (Config.Suffix or "")
                if Config.Callback then Config.Callback(Val) end
            end
            
            local Dragging = false
            Bar.InputBegan:Connect(function(Input) 
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then 
                    Dragging = true; Update(Input) 
                end 
            end)
            UserInputService.InputEnded:Connect(function(Input) 
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end 
            end)
            UserInputService.InputChanged:Connect(function(Input) 
                if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then Update(Input) end 
            end)
        end
        
        function Tab:CreateButton(Config)
            local Btn = Instance.new("TextButton")
            Btn.Parent = Scroll; Btn.BackgroundColor3 = Theme.ElementBackground
            Btn.Size = UDim2.new(1,0,0,42); Btn.Text = Config.Name
            Btn.Font = Enum.Font.GothamMedium; Btn.TextColor3 = Theme.TextColor
            Btn.TextSize = 14; Btn.AutoButtonColor = false
            local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0,8); BC.Parent = Btn
            local S = Instance.new("UIStroke"); S.Parent = Btn; S.Color = Theme.Stroke; S.Thickness = 1
            
            Btn.MouseButton1Click:Connect(function()
                Tween(Btn, {BackgroundColor3 = Color3.fromRGB(45,45,45)}, 0.1)
                task.wait(0.1)
                Tween(Btn, {BackgroundColor3 = Theme.ElementBackground}, 0.1)
                if Config.Callback then Config.Callback() end
            end)
        end
        
        function Tab:CreateInput(Config)
            local C = Instance.new("Frame")
            C.Parent = Scroll; C.BackgroundColor3 = Theme.ElementBackground
            C.Size = UDim2.new(1,0,0,42)
            local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0,8); CC.Parent = C
            local S = Instance.new("UIStroke"); S.Parent = C; S.Color = Theme.Stroke; S.Thickness = 1
            
            local T = Instance.new("TextLabel")
            T.Parent = C; T.BackgroundTransparency = 1
            T.Text = Config.Name; T.Font = Enum.Font.GothamMedium
            T.TextColor3 = Theme.TextColor; T.TextSize = 14
            T.Position = UDim2.new(0,15,0,0); T.Size = UDim2.new(1,-145,1,0)
            T.TextXAlignment = Enum.TextXAlignment.Left
            
            local TB = Instance.new("TextBox")
            TB.Parent = C; TB.BackgroundColor3 = Color3.fromRGB(25,25,25)
            TB.Position = UDim2.new(1,-135,0.5,-12); TB.Size = UDim2.new(0,120,0,24)
            TB.Font = Enum.Font.Gotham; TB.Text = ""; TB.PlaceholderText = Config.PlaceholderText or "Input"
            TB.TextColor3 = Theme.TextColor; TB.PlaceholderColor3 = Theme.PlaceholderColor
            TB.TextSize = 13
            local TBC = Instance.new("UICorner"); TBC.CornerRadius = UDim.new(0,4); TBC.Parent = TB
            
            TB.FocusLost:Connect(function(Enter)
                if Config.Callback then Config.Callback(TB.Text) end
                if Config.RemoveTextAfterFocusLost then TB.Text = "" end
            end)
        end

        function Tab:CreateKeybind(Config)
            local C = Instance.new("Frame")
            C.Parent = Scroll; C.BackgroundColor3 = Theme.ElementBackground
            C.Size = UDim2.new(1,0,0,42)
            local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0,8); CC.Parent = C
            local S = Instance.new("UIStroke"); S.Parent = C; S.Color = Theme.Stroke; S.Thickness = 1
            
            local T = Instance.new("TextLabel")
            T.Parent = C; T.BackgroundTransparency = 1
            T.Text = Config.Name; T.Font = Enum.Font.GothamMedium
            T.TextColor3 = Theme.TextColor; T.TextSize = 14
            T.Position = UDim2.new(0,15,0,0); T.Size = UDim2.new(1,-145,1,0)
            T.TextXAlignment = Enum.TextXAlignment.Left
            
            local Btn = Instance.new("TextButton")
            Btn.Parent = C; Btn.BackgroundColor3 = Color3.fromRGB(25,25,25)
            Btn.Position = UDim2.new(1,-135,0.5,-12); Btn.Size = UDim2.new(0,120,0,24)
            Btn.Text = Config.CurrentKeybind or "None"; Btn.Font = Enum.Font.Gotham; Btn.TextColor3 = Theme.PlaceholderColor
            Btn.TextSize = 13; Btn.AutoButtonColor = false
            local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0,4); BC.Parent = Btn
            
            local Listening = false
            Btn.MouseButton1Click:Connect(function()
                if Listening then return end
                Listening = true
                Btn.Text = "..."
                local Input = UserInputService.InputBegan:Wait()
                if Input.UserInputType == Enum.UserInputType.Keyboard then
                    Btn.Text = Input.KeyCode.Name
                    if Config.Callback then Config.Callback(Input.KeyCode) end
                end
                Listening = false
            end)
        end

        return Tab
    end

    return Window
end

return Library
