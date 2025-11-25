--[[ 
    Rayfield Interface Suite (Optimized Standalone Library)
    -------------------------------------------------------
    - TARGET: Library Source Code ONLY.
    - LAYOUT: Exact Rayfield Replica (Horizontal Tabs).
    - TOPBAR: 
        1. Close (X) -> Termination Warning
        2. Minimize (-)
        3. Settings (Icon: 1402032199) -> Keybind UI
        4. Search (Magnifying Glass) -> Visual Placeholder
    - FIXED: Buttons use Manual Anchoring to prevent glitches.
    
    USAGE:
    local Library = loadstring(readfile("rayfield_lib.lua"))()
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
    Topbar = Color3.fromRGB(25, 25, 25), -- Seamless
    TabContainer = Color3.fromRGB(35, 35, 35),
    ElementBackground = Color3.fromRGB(32, 32, 32),
    TextColor = Color3.fromRGB(240, 240, 240),
    PlaceholderColor = Color3.fromRGB(150, 150, 150),
    Accent = Color3.fromRGB(60, 140, 255),
    NotificationBG = Color3.fromRGB(20, 20, 20),
    Stroke = Color3.fromRGB(50, 50, 50),
    Crimson = Color3.fromRGB(255, 65, 65)
}

--// ICONS
local Icons = {
    Search = "rbxassetid://3944680069",
    Close = "rbxassetid://3944676352",
    Minimize = "rbxassetid://3944652232",
    Settings = "rbxassetid://1402032199" -- Requested Custom Asset
}

--// UTILITY
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
function Library:CreateWindow(Config)
    local Window = {}
    local Minimized = false
    local SettingsOpen = false
    local UIKeybind = Enum.KeyCode.RightControl
    local DestroyCallbacks = {}
    
    -- Main GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RayfieldOptimized_" .. (Config.Name or "UI")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = GetUIContainer()

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

    -- Topbar
    local Topbar = Instance.new("Frame")
    Topbar.Parent = Main
    Topbar.BackgroundColor3 = Theme.Topbar
    Topbar.Size = UDim2.new(1, 0, 0, 50)
    
    local Title = Instance.new("TextLabel")
    Title.Parent = Topbar
    Title.Text = Config.Name or "Rayfield"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Theme.TextColor
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.TextXAlignment = Enum.TextXAlignment.Left

    --// BUTTONS (Manual Right Anchoring)
    local ButtonContainer = Instance.new("Frame")
    ButtonContainer.Parent = Topbar
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.AnchorPoint = Vector2.new(1, 0)
    ButtonContainer.Position = UDim2.new(1, -15, 0, 0) -- 15px Padding from Right Edge
    ButtonContainer.Size = UDim2.new(0, 150, 1, 0)

    local function CreateTopBtn(Name, Icon, OffsetX, Callback)
        local Btn = Instance.new("ImageButton")
        Btn.Name = Name
        Btn.Parent = ButtonContainer
        Btn.BackgroundTransparency = 1
        Btn.Image = Icon
        Btn.ImageColor3 = Color3.fromRGB(150, 150, 150)
        Btn.Size = UDim2.new(0, 20, 0, 20)
        -- Hardcoded offsets ensure they NEVER overlap or glitch
        Btn.Position = UDim2.new(1, OffsetX, 0.5, -10) 
        
        Btn.MouseEnter:Connect(function() Tween(Btn, {ImageColor3 = Color3.new(1,1,1)}) end)
        Btn.MouseLeave:Connect(function() Tween(Btn, {ImageColor3 = Color3.fromRGB(150,150,150)}) end)
        Btn.MouseButton1Click:Connect(Callback)
    end

    -- 1. Close Button (Far Right)
    CreateTopBtn("Close", Icons.Close, -25, function()
        -- Termination Warning Modal
        local Overlay = Instance.new("TextButton")
        Overlay.Name = "Blocker"
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
        
        local MC = Instance.new("UICorner"); MC.CornerRadius = UDim.new(0,12); MC.Parent = Modal
        local MS = Instance.new("UIStroke"); MS.Parent = Modal; MS.Color = Theme.Stroke
        
        local MT = Instance.new("TextLabel")
        MT.Parent = Modal; MT.BackgroundTransparency = 1
        MT.Text = "Terminate Script?"; MT.Font = Enum.Font.GothamBold
        MT.TextColor3 = Theme.TextColor; MT.TextSize = 20
        MT.Position = UDim2.new(0,0,0,15); MT.Size = UDim2.new(1,0,0,30)
        
        local MD = Instance.new("TextLabel")
        MD.Parent = Modal; MD.BackgroundTransparency = 1
        MD.Text = "Are you sure you want to stop all processes and close the UI?"
        MD.Font = Enum.Font.Gotham; MD.TextColor3 = Theme.PlaceholderColor
        MD.TextSize = 14; MD.TextWrapped = true
        MD.Position = UDim2.new(0,20,0,50); MD.Size = UDim2.new(1,-40,0,40)

        local Yes = Instance.new("TextButton")
        Yes.Parent = Modal; Yes.BackgroundColor3 = Theme.Crimson
        Yes.Text = "Yes, Terminate"; Yes.TextColor3 = Color3.new(1,1,1)
        Yes.Font = Enum.Font.GothamBold; Yes.TextSize = 14
        Yes.Size = UDim2.new(0,130,0,35); Yes.Position = UDim2.new(0,20,1,-50)
        local YC = Instance.new("UICorner"); YC.CornerRadius = UDim.new(0,6); YC.Parent = Yes

        local No = Instance.new("TextButton")
        No.Parent = Modal; No.BackgroundColor3 = Theme.ElementBackground
        No.Text = "Cancel"; No.TextColor3 = Theme.TextColor
        No.Font = Enum.Font.GothamBold; No.TextSize = 14
        No.Size = UDim2.new(0,130,0,35); No.Position = UDim2.new(1,-150,1,-50)
        local NC = Instance.new("UICorner"); NC.CornerRadius = UDim.new(0,6); NC.Parent = No

        Yes.MouseButton1Click:Connect(function()
            for _, cb in pairs(DestroyCallbacks) do task.spawn(cb) end
            ScreenGui:Destroy()
        end)
        No.MouseButton1Click:Connect(function() Overlay:Destroy() end)
    end)

    -- 2. Minimize Button
    CreateTopBtn("Min", Icons.Minimize, -60, function()
        Minimized = not Minimized
        if Minimized then
            Tween(Main, {Size = UDim2.new(0, 500, 0, 50)})
        else
            Tween(Main, {Size = UDim2.new(0, 500, 0, 350)})
        end
    end)

    -- 3. Settings Button (Using your Custom Asset)
    CreateTopBtn("Settings", Icons.Settings, -95, function()
        SettingsOpen = not SettingsOpen
        -- Keybind Changer Overlay
        local SetFrame = Main:FindFirstChild("SettingsOverlay")
        if not SetFrame then
            SetFrame = Instance.new("Frame")
            SetFrame.Name = "SettingsOverlay"
            SetFrame.Parent = Main
            SetFrame.BackgroundColor3 = Theme.Background
            SetFrame.Size = UDim2.new(1, 0, 1, -50)
            SetFrame.Position = UDim2.new(0, 0, 1, 0) -- Hidden initially
            SetFrame.ZIndex = 5
            
            local KeyBtn = Instance.new("TextButton")
            KeyBtn.Parent = SetFrame
            KeyBtn.BackgroundColor3 = Theme.ElementBackground
            KeyBtn.Size = UDim2.new(0, 200, 0, 40)
            KeyBtn.Position = UDim2.new(0.5, -100, 0.5, -20)
            KeyBtn.Text = "Keybind: " .. UIKeybind.Name
            KeyBtn.TextColor3 = Theme.TextColor
            KeyBtn.Font = Enum.Font.GothamBold
            KeyBtn.TextSize = 14
            local KC = Instance.new("UICorner"); KC.CornerRadius = UDim.new(0,6); KC.Parent = KeyBtn
            
            local Listening = false
            KeyBtn.MouseButton1Click:Connect(function()
                Listening = true
                KeyBtn.Text = "Press any key..."
                local Input = UserInputService.InputBegan:Wait()
                if Input.UserInputType == Enum.UserInputType.Keyboard then
                    UIKeybind = Input.KeyCode
                    KeyBtn.Text = "Keybind: " .. UIKeybind.Name
                end
                Listening = false
            end)
        end
        
        if SettingsOpen then
            Tween(SetFrame, {Position = UDim2.new(0,0,0,50)}) -- Slide Up
        else
            Tween(SetFrame, {Position = UDim2.new(0,0,1,0)}) -- Slide Down
        end
    end)

    -- 4. Search Button (Placeholder)
    CreateTopBtn("Search", Icons.Search, -130, function()
        Library:Notify({Title="Search", Content="No options found.", Duration=1})
    end)

    --// TOGGLE UI LOGIC
    UserInputService.InputBegan:Connect(function(Input, Processed)
        if not Processed and Input.KeyCode == UIKeybind then
            Main.Visible = not Main.Visible
        end
    end)

    --// TABS (Horizontal Layout)
    local TabContainer = Instance.new("Frame")
    TabContainer.Parent = Main
    TabContainer.BackgroundColor3 = Theme.Background
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 20, 0, 50)
    TabContainer.Size = UDim2.new(1, -40, 0, 35)

    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabContainer
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.Padding = UDim.new(0, 10)

    -- Content
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Parent = Main
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, 0, 0, 95)
    ContentContainer.Size = UDim2.new(1, 0, 1, -100)
    ContentContainer.ClipsDescendants = true

    --// NOTIFICATIONS (2 Seconds)
    local NotifHolder = Instance.new("Frame")
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
            if Notif then
                Tween(Notif, {BackgroundTransparency = 1}, 0.3)
                Tween(NT, {TextTransparency = 1}, 0.3)
                Tween(ND, {TextTransparency = 1}, 0.3)
                task.wait(0.3)
                Notif:Destroy()
            end
        end)
    end

    function Library:OnDestroy(func)
        table.insert(DestroyCallbacks, func)
    end

    --// ELEMENTS
    local FirstTab = true

    function Window:CreateTab(Name)
        local Tab = {}
        
        local TabBtn = Instance.new("TextButton")
        TabBtn.Parent = TabContainer
        TabBtn.BackgroundColor3 = Theme.TabContainer
        TabBtn.Text = "  " .. Name .. "  "
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextColor3 = Theme.TextColor
        TabBtn.TextSize = 13
        TabBtn.AutoButtonColor = false
        
        local W = TextService:GetTextSize(TabBtn.Text, 13, Enum.Font.GothamBold, Vector2.new(1000, 100)).X
        TabBtn.Size = UDim2.new(0, W + 20, 1, 0)
        local TC = Instance.new("UICorner"); TC.CornerRadius = UDim.new(1,0); TC.Parent = TabBtn

        local Scroll = Instance.new("ScrollingFrame")
        Scroll.Parent = ContentContainer
        Scroll.BackgroundTransparency = 1
        Scroll.Size = UDim2.new(1, 0, 1, 0)
        Scroll.Visible = false
        Scroll.ScrollBarThickness = 2
        
        local SL = Instance.new("UIListLayout"); SL.Parent = Scroll; SL.Padding = UDim.new(0, 6)
        local SP = Instance.new("UIPadding"); SP.Parent = Scroll
        SP.PaddingTop = UDim.new(0, 5); SP.PaddingLeft = UDim.new(0, 20); SP.PaddingRight = UDim.new(0, 20)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentContainer:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(TabContainer:GetChildren()) do 
                if v:IsA("TextButton") then Tween(v, {BackgroundColor3 = Theme.TabContainer, TextColor3 = Color3.fromRGB(150,150,150)}) end 
            end
            Scroll.Visible = true
            Tween(TabBtn, {BackgroundColor3 = Theme.TextColor, TextColor3 = Theme.Background})
        end)

        if FirstTab then 
            FirstTab = false; Scroll.Visible = true; TabBtn.TextColor3 = Theme.Background; TabBtn.BackgroundColor3 = Theme.TextColor 
        else
            TabBtn.TextColor3 = Color3.fromRGB(150,150,150)
        end

        function Tab:CreateSection(Text)
            local L = Instance.new("TextLabel"); L.Parent = Scroll; L.BackgroundTransparency = 1
            L.Text = Text; L.Font = Enum.Font.Gotham; L.TextColor3 = Theme.PlaceholderColor; L.TextSize = 13
            L.Size = UDim2.new(1,0,0,25); L.TextXAlignment = Enum.TextXAlignment.Left
        end

        function Tab:CreateToggle(Config)
            local En = Config.CurrentValue or false
            local B = Instance.new("TextButton"); B.Parent = Scroll; B.BackgroundColor3 = Theme.ElementBackground
            B.Size = UDim2.new(1,0,0,42); B.Text = ""; B.AutoButtonColor = false
            local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0,8); BC.Parent = B
            local S = Instance.new("UIStroke"); S.Parent = B; S.Color = Theme.Stroke; S.Thickness = 1
            
            local L = Instance.new("TextLabel"); L.Parent = B; L.BackgroundTransparency = 1
            L.Text = Config.Name; L.Font = Enum.Font.GothamMedium; L.TextColor3 = Theme.TextColor
            L.TextSize = 14; L.Position = UDim2.new(0,15,0,0); L.Size = UDim2.new(1,-60,1,0); L.TextXAlignment = Enum.TextXAlignment.Left
            
            local I = Instance.new("Frame"); I.Parent = B; I.BackgroundColor3 = En and Theme.Accent or Color3.fromRGB(60,60,60)
            I.Position = UDim2.new(1,-55,0.5,-11); I.Size = UDim2.new(0,40,0,22)
            local IC = Instance.new("UICorner"); IC.CornerRadius = UDim.new(1,0); IC.Parent = I
            
            local D = Instance.new("Frame"); D.Parent = I; D.BackgroundColor3 = Color3.new(1,1,1)
            D.Position = En and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9); D.Size = UDim2.new(0,18,0,18)
            local DC = Instance.new("UICorner"); DC.CornerRadius = UDim.new(1,0); DC.Parent = D
            
            B.MouseButton1Click:Connect(function()
                En = not En
                Tween(I, {BackgroundColor3 = En and Theme.Accent or Color3.fromRGB(60,60,60)})
                Tween(D, {Position = En and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)})
                if Config.Callback then Config.Callback(En) end
            end)
        end
        
        function Tab:CreateSlider(Config)
            local V = Config.CurrentValue or Config.Range[1]
            local F = Instance.new("Frame"); F.Parent = Scroll; F.BackgroundColor3 = Theme.ElementBackground; F.Size = UDim2.new(1,0,0,55)
            local FC = Instance.new("UICorner"); FC.CornerRadius = UDim.new(0,8); FC.Parent = F
            local S = Instance.new("UIStroke"); S.Parent = F; S.Color = Theme.Stroke; S.Thickness = 1
            
            local L = Instance.new("TextLabel"); L.Parent = F; L.BackgroundTransparency = 1; L.Text = Config.Name
            L.Font = Enum.Font.GothamMedium; L.TextColor3 = Theme.TextColor; L.TextSize = 14
            L.Position = UDim2.new(0,15,0,10); L.Size = UDim2.new(1,-15,0,15); L.TextXAlignment = Enum.TextXAlignment.Left
            
            local VL = Instance.new("TextLabel"); VL.Parent = F; VL.BackgroundTransparency = 1
            VL.Text = V .. (Config.Suffix or ""); VL.Font = Enum.Font.Gotham; VL.TextColor3 = Theme.PlaceholderColor
            VL.TextSize = 13; VL.Position = UDim2.new(1,-115,0,10); VL.Size = UDim2.new(0,100,0,15); VL.TextXAlignment = Enum.TextXAlignment.Right
            
            local Bar = Instance.new("TextButton"); Bar.Parent = F; Bar.BackgroundColor3 = Color3.fromRGB(45,45,45)
            Bar.Position = UDim2.new(0,15,0,35); Bar.Size = UDim2.new(1,-30,0,6); Bar.Text = ""; Bar.AutoButtonColor = false
            local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(1,0); BC.Parent = Bar
            
            local Fill = Instance.new("Frame"); Fill.Parent = Bar; Fill.BackgroundColor3 = Theme.Accent
            Fill.Size = UDim2.new((V - Config.Range[1])/(Config.Range[2] - Config.Range[1]), 0, 1, 0)
            local FiC = Instance.new("UICorner"); FiC.CornerRadius = UDim.new(1,0); FiC.Parent = Fill
            
            local function Update(Input)
                local SizeX = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                V = math.floor(Config.Range[1] + ((Config.Range[2] - Config.Range[1]) * SizeX))
                Tween(Fill, {Size = UDim2.new(SizeX,0,1,0)}, 0.1)
                VL.Text = V .. (Config.Suffix or "")
                if Config.Callback then Config.Callback(V) end
            end
            
            local Dragging = false
            Bar.InputBegan:Connect(function(I) if I.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; Update(I) end end)
            UserInputService.InputEnded:Connect(function(I) if I.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
            UserInputService.InputChanged:Connect(function(I) if Dragging and I.UserInputType == Enum.UserInputType.MouseMovement then Update(I) end end)
        end
        
        function Tab:CreateButton(Config)
            local B = Instance.new("TextButton"); B.Parent = Scroll; B.BackgroundColor3 = Theme.ElementBackground
            B.Size = UDim2.new(1,0,0,42); B.Text = Config.Name; B.Font = Enum.Font.GothamMedium
            B.TextColor3 = Theme.TextColor; B.TextSize = 14; B.AutoButtonColor = false
            local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0,8); BC.Parent = B
            local S = Instance.new("UIStroke"); S.Parent = B; S.Color = Theme.Stroke; S.Thickness = 1
            
            B.MouseButton1Click:Connect(function()
                Tween(B, {BackgroundColor3 = Color3.fromRGB(45,45,45)}, 0.1)
                task.wait(0.1)
                Tween(B, {BackgroundColor3 = Theme.ElementBackground}, 0.1)
                if Config.Callback then Config.Callback() end
            end)
        end

        function Tab:CreateInput(Config)
            local C = Instance.new("Frame"); C.Parent = Scroll; C.BackgroundColor3 = Theme.ElementBackground; C.Size = UDim2.new(1,0,0,42)
            local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0,8); CC.Parent = C
            local S = Instance.new("UIStroke"); S.Parent = C; S.Color = Theme.Stroke; S.Thickness = 1
            
            local T = Instance.new("TextLabel"); T.Parent = C; T.BackgroundTransparency = 1; T.Text = Config.Name
            T.Font = Enum.Font.GothamMedium; T.TextColor3 = Theme.TextColor; T.TextSize = 14
            T.Position = UDim2.new(0,15,0,0); T.Size = UDim2.new(1,-145,1,0); T.TextXAlignment = Enum.TextXAlignment.Left
            
            local TB = Instance.new("TextBox"); TB.Parent = C; TB.BackgroundColor3 = Color3.fromRGB(25,25,25)
            TB.Position = UDim2.new(1,-135,0.5,-12); TB.Size = UDim2.new(0,120,0,24)
            TB.Font = Enum.Font.Gotham; TB.Text = ""; TB.PlaceholderText = Config.PlaceholderText or "Input"
            TB.TextColor3 = Theme.TextColor; TB.PlaceholderColor3 = Theme.PlaceholderColor; TB.TextSize = 13
            local TBC = Instance.new("UICorner"); TBC.CornerRadius = UDim.new(0,4); TBC.Parent = TB
            
            TB.FocusLost:Connect(function()
                if Config.Callback then Config.Callback(TB.Text) end
                if Config.RemoveTextAfterFocusLost then TB.Text = "" end
            end)
        end

        return Tab
    end

    return Window
end

return Library
