--[[
    AetheriaLib - Ultra-Modern UI Library for Roblox
    Design: Advanced Glassmorphism & Dynamic ARGB Borders
]]

local AetheriaLib = {}
AetheriaLib.__index = AetheriaLib

-- Serviços do Roblox
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- Auxiliar de Animação (Tween)
local function Tween(instance, info, properties)
    local tween = TweenService:Create(instance, TweenInfo.new(unpack(info)), properties)
    tween:Play()
    return tween
end

--------------------------------------------------------------------------------
-- SISTEMA DE NOTIFICAÇÕES
--------------------------------------------------------------------------------
local NotificationGui
local NotificationContainer

local function InitNotificationSystem()
    if not NotificationGui then
        NotificationGui = Instance.new("ScreenGui")
        NotificationGui.Name = "AetheriaNotifications"
        NotificationGui.ResetOnSpawn = false
        
        -- Proteção contra detecção simples de UI
        pcall(function()
            NotificationGui.Parent = CoreGui
        end)
        if not NotificationGui.Parent then
            NotificationGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        end

        NotificationContainer = Instance.new("Frame")
        NotificationContainer.Name = "Container"
        NotificationContainer.Size = UDim2.new(0, 300, 1, -20)
        NotificationContainer.Position = UDim2.new(1, -310, 0, 10)
        NotificationContainer.BackgroundTransparency = 1
        NotificationContainer.Parent = NotificationGui

        local layout = Instance.new("UIListLayout")
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)
        layout.Parent = NotificationContainer
    end
end

function AetheriaLib:Notify(config)
    InitNotificationSystem()
    
    local titleText = config.Title or "Notificação"
    local contentText = config.Content or ""
    local duration = config.Duration or 3

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 65)
    card.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    card.BackgroundTransparency = 0.15
    card.Position = UDim2.new(1, 350, 0, 0) -- Fora da tela para animação
    card.Parent = NotificationContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 200, 255)
    stroke.Transparency = 0.5
    stroke.Thickness = 1
    stroke.Parent = card

    local title = Instance.new("TextLabel")
    title.Text = titleText
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Position = UDim2.new(0, 12, 0, 10)
    title.Size = UDim2.new(1, -24, 0, 15)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Parent = card

    local content = Instance.new("TextLabel")
    content.Text = contentText
    content.Font = Enum.Font.Gotham
    content.TextSize = 11
    content.TextColor3 = Color3.fromRGB(180, 185, 200)
    content.Position = UDim2.new(0, 12, 0, 28)
    content.Size = UDim2.new(1, -24, 0, 30)
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextWrapped = true
    content.BackgroundTransparency = 1
    content.Parent = card

    -- Entrada fluida
    Tween(card, {0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {Position = UDim2.new(0, 0, 0, 0)})

    -- Saída com Fade
    task.delay(duration, function()
        local tweenOut = Tween(card, {0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In}, {Position = UDim2.new(1, 350, 0, 0)})
        tweenOut.Completed:Connect(function()
            card:Destroy()
        end)
    end)
end

--------------------------------------------------------------------------------
-- JANELA PRINCIPAL (CreateWindow)
--------------------------------------------------------------------------------
function AetheriaLib:CreateWindow(config)
    config = config or {}
    local TitleText = config.Title or "AETHERIA"
    local SubTitleText = config.SubTitle or "UI Dashboard"
    local AccentColor = config.AccentColor or Color3.fromRGB(0, 170, 255)
    local EnableARGB = config.ARGBBorders ~= false
    local GradientSpeed = config.GradientSpeed or 3

    -- ScreenGui Principal
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AetheriaLib_UI"
    ScreenGui.ResetOnSpawn = false
    
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 650, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    -- Borda Neon / ARGB Dinâmica
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 1.5
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = MainFrame

    local UIGradient = Instance.new("UIGradient")
    if EnableARGB then
        UIGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 128)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 230, 255)),
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(150, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 128))
        })
        
        -- Loop do Gradiente Neon
        local rotConnection
        rotConnection = RunService.RenderStepped:Connect(function(dt)
            if not MainFrame or not MainFrame.Parent then
                rotConnection:Disconnect()
                return
            end
            UIGradient.Rotation = (UIGradient.Rotation + (dt * 60 * GradientSpeed)) % 360
        end)
    else
        UIGradient.Color = ColorSequence.new(AccentColor)
    end
    UIGradient.Parent = UIStroke

    -- Sistema de Arraste (Draggable)
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Painel Esquerdo (Sidebar)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 170, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
    Sidebar.BackgroundTransparency = 0.2
    Sidebar.Parent = MainFrame

    local BrandContainer = Instance.new("Frame")
    BrandContainer.Size = UDim2.new(1, 0, 0, 50)
    BrandContainer.BackgroundTransparency = 1
    BrandContainer.Parent = Sidebar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = TitleText
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 15
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Position = UDim2.new(0, 15, 0, 10)
    TitleLabel.Size = UDim2.new(1, -30, 0, 16)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = BrandContainer

    local SubTitleLabel = Instance.new("TextLabel")
    SubTitleLabel.Text = SubTitleText
    SubTitleLabel.Font = Enum.Font.Gotham
    SubTitleLabel.TextSize = 10
    SubTitleLabel.TextColor3 = AccentColor
    SubTitleLabel.Position = UDim2.new(0, 15, 0, 26)
    SubTitleLabel.Size = UDim2.new(1, -30, 0, 14)
    SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubTitleLabel.BackgroundTransparency = 1
    SubTitleLabel.Parent = BrandContainer

    local TabHolder = Instance.new("ScrollingFrame")
    TabHolder.Name = "TabHolder"
    TabHolder.Size = UDim2.new(1, 0, 1, -60)
    TabHolder.Position = UDim2.new(0, 0, 0, 55)
    TabHolder.BackgroundTransparency = 1
    TabHolder.ScrollBarThickness = 0
    TabHolder.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 4)
    TabListLayout.Parent = TabHolder

    -- Contêiner do Conteúdo (Abas)
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -170, 1, 0)
    ContentContainer.Position = UDim2.new(0, 170, 0, 0)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    local WindowObj = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        ContentContainer = ContentContainer,
        TabHolder = TabHolder,
        AccentColor = AccentColor,
        Tabs = {},
        ActiveTab = nil
    }

    ----------------------------------------------------------------------------
    -- MÉTODOS DA JANELA (CreateTab)
    ----------------------------------------------------------------------------
    function WindowObj:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local TabName = tabConfig.Name or "Aba"

        -- Botão da Aba na Sidebar
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, -16, 0, 32)
        TabButton.Position = UDim2.new(0, 8, 0, 0)
        TabButton.BackgroundColor3 = Color3.fromRGB(22, 25, 35)
        TabButton.BackgroundTransparency = 1
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabHolder

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton

        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 3, 0, 16)
        Indicator.Position = UDim2.new(0, 0, 0.5, -8)
        Indicator.BackgroundColor3 = AccentColor
        Indicator.BackgroundTransparency = 1
        Indicator.Parent = TabButton

        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(0, 2)
        IndicatorCorner.Parent = Indicator

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Text = TabName
        TabLabel.Font = Enum.Font.GothamMedium
        TabLabel.TextSize = 12
        TabLabel.TextColor3 = Color3.fromRGB(150, 155, 170)
        TabLabel.Position = UDim2.new(0, 12, 0, 0)
        TabLabel.Size = UDim2.new(1, -12, 1, 0)
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.BackgroundTransparency = 1
        TabLabel.Parent = TabButton

        -- Frame da Página
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = "Page_" .. TabName
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.ScrollBarThickness = 2
        TabPage.ScrollBarImageColor3 = AccentColor
        TabPage.Parent = ContentContainer

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingLeft = UDim.new(0, 15)
        PagePadding.PaddingRight = UDim.new(0, 15)
        PagePadding.PaddingTop = UDim.new(0, 15)
        PagePadding.PaddingBottom = UDim.new(0, 15)
        PagePadding.Parent = TabPage

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 12)
        PageLayout.Parent = TabPage

        local TabObj = {
            Page = TabPage,
            Button = TabButton
        }

        -- Função para Selecionar Aba
        local function Select()
            for _, t in pairs(WindowObj.Tabs) do
                t.Page.Visible = false
                Tween(t.Button, {0.2, Enum.EasingStyle.Quart}, {BackgroundTransparency = 1})
                Tween(t.Button:FindFirstChildOfClass("TextLabel"), {0.2, Enum.EasingStyle.Quart}, {TextColor3 = Color3.fromRGB(150, 155, 170)})
                Tween(t.Button:FindFirstChild("Frame"), {0.2, Enum.EasingStyle.Quart}, {BackgroundTransparency = 1})
            end

            TabPage.Visible = true
            Tween(TabButton, {0.2, Enum.EasingStyle.Quart}, {BackgroundTransparency = 0.6})
            Tween(TabLabel, {0.2, Enum.EasingStyle.Quart}, {TextColor3 = Color3.fromRGB(255, 255, 255)})
            Tween(Indicator, {0.2, Enum.EasingStyle.Quart}, {BackgroundTransparency = 0})
            WindowObj.ActiveTab = TabObj
        end

        TabButton.MouseButton1Click:Connect(Select)

        -- Micro-interações de Hover
        TabButton.MouseEnter:Connect(function()
            if WindowObj.ActiveTab ~= TabObj then
                Tween(TabLabel, {0.2, Enum.EasingStyle.Quart}, {TextColor3 = Color3.fromRGB(210, 215, 230)})
            end
        end)

        TabButton.MouseLeave:Connect(function()
            if WindowObj.ActiveTab ~= TabObj then
                Tween(TabLabel, {0.2, Enum.EasingStyle.Quart}, {TextColor3 = Color3.fromRGB(150, 155, 170)})
            end
        end)

        table.insert(WindowObj.Tabs, TabObj)
        if #WindowObj.Tabs == 1 then Select() end

        ------------------------------------------------------------------------
        -- SUBSEÇÕES (CreateSection)
        ------------------------------------------------------------------------
        function TabObj:CreateSection(secConfig)
            secConfig = secConfig or {}
            local SecName = secConfig.Name or "Seção"

            local SectionFrame = Instance.new("Frame")
            SectionFrame.Size = UDim2.new(1, 0, 0, 30)
            SectionFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
            SectionFrame.BackgroundTransparency = 0.4
            SectionFrame.Parent = TabPage

            local SecCorner = Instance.new("UICorner")
            SecCorner.CornerRadius = UDim.new(0, 6)
            SecCorner.Parent = SectionFrame

            local SecLayout = Instance.new("UIListLayout")
            SecLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SecLayout.Padding = UDim.new(0, 8)
            SecLayout.Parent = SectionFrame

            local SecPadding = Instance.new("UIPadding")
            SecPadding.PaddingTop = UDim.new(0, 8)
            SecPadding.PaddingBottom = UDim.new(0, 8)
            SecPadding.PaddingLeft = UDim.new(0, 10)
            SecPadding.PaddingRight = UDim.new(0, 10)
            SecPadding.Parent = SectionFrame

            local Title = Instance.new("TextLabel")
            Title.Text = string.upper(SecName)
            Title.Font = Enum.Font.GothamBold
            Title.TextSize = 10
            Title.TextColor3 = AccentColor
            Title.Size = UDim2.new(1, 0, 0, 14)
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = SectionFrame

            -- Atualiza altura da Seção automaticamente
            SecLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, 0, 0, SecLayout.AbsoluteContentSize.Y + 16)
            end)

            local SectionObj = {}

            --------------------------------------------------------------------
            -- ELEMENTO: BUTTON
            --------------------------------------------------------------------
            function SectionObj:CreateButton(btnConfig)
                btnConfig = btnConfig or {}
                local Name = btnConfig.Name or "Botão"
                local Info = btnConfig.Info
                local Callback = btnConfig.Callback or function() end

                local Button = Instance.new("TextButton")
                Button.Size = UDim2.new(1, 0, 0, Info and 38 or 30)
                Button.BackgroundColor3 = Color3.fromRGB(26, 29, 40)
                Button.AutoButtonColor = false
                Button.Text = ""
                Button.Parent = SectionFrame

                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 6)
                BtnCorner.Parent = Button

                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = Color3.fromRGB(40, 45, 60)
                BtnStroke.Thickness = 1
                BtnStroke.Parent = Button

                local BtnLabel = Instance.new("TextLabel")
                BtnLabel.Text = Name
                BtnLabel.Font = Enum.Font.GothamMedium
                BtnLabel.TextSize = 12
                BtnLabel.TextColor3 = Color3.fromRGB(230, 235, 245)
                BtnLabel.Size = UDim2.new(1, -20, 0, 14)
                BtnLabel.Position = UDim2.new(0, 10, 0, Info and 4 or 8)
                BtnLabel.TextXAlignment = Enum.TextXAlignment.Left
                BtnLabel.BackgroundTransparency = 1
                BtnLabel.Parent = Button

                if Info then
                    local InfoLabel = Instance.new("TextLabel")
                    InfoLabel.Text = Info
                    InfoLabel.Font = Enum.Font.Gotham
                    InfoLabel.TextSize = 10
                    InfoLabel.TextColor3 = Color3.fromRGB(120, 125, 140)
                    InfoLabel.Size = UDim2.new(1, -20, 0, 12)
                    InfoLabel.Position = UDim2.new(0, 10, 0, 20)
                    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
                    InfoLabel.BackgroundTransparency = 1
                    InfoLabel.Parent = Button
                end

                -- Micro-interações
                Button.MouseEnter:Connect(function()
                    Tween(Button, {0.15, Enum.EasingStyle.Quart}, {BackgroundColor3 = Color3.fromRGB(34, 38, 52)})
                    Tween(BtnStroke, {0.15, Enum.EasingStyle.Quart}, {Color = AccentColor})
                end)

                Button.MouseLeave:Connect(function()
                    Tween(Button, {0.15, Enum.EasingStyle.Quart}, {BackgroundColor3 = Color3.fromRGB(26, 29, 40)})
                    Tween(BtnStroke, {0.15, Enum.EasingStyle.Quart}, {Color = Color3.fromRGB(40, 45, 60)})
                end)

                Button.MouseButton1Down:Connect(function()
                    Tween(Button, {0.1, Enum.EasingStyle.Quart}, {Size = UDim2.new(1, -4, 0, (Info and 38 or 30) - 2)})
                end)

                Button.MouseButton1Up:Connect(function()
                    Tween(Button, {0.1, Enum.EasingStyle.Quart}, {Size = UDim2.new(1, 0, 0, Info and 38 or 30)})
                    task.spawn(Callback)
                end)
            end

            --------------------------------------------------------------------
            -- ELEMENTO: TOGGLE
            --------------------------------------------------------------------
            function SectionObj:CreateToggle(tglConfig)
                tglConfig = tglConfig or {}
                local Name = tglConfig.Name or "Toggle"
                local State = tglConfig.Default or false
                local Callback = tglConfig.Callback or function() end

                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, 0, 0, 32)
                ToggleFrame.BackgroundColor3 = Color3.fromRGB(26, 29, 40)
                ToggleFrame.Parent = SectionFrame

                local TglCorner = Instance.new("UICorner")
                TglCorner.CornerRadius = UDim.new(0, 6)
                TglCorner.Parent = ToggleFrame

                local Label = Instance.new("TextLabel")
                Label.Text = Name
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 12
                Label.TextColor3 = Color3.fromRGB(230, 235, 245)
                Label.Size = UDim2.new(1, -60, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = ToggleFrame

                local Switch = Instance.new("Frame")
                Switch.Size = UDim2.new(0, 36, 0, 18)
                Switch.Position = UDim2.new(1, -46, 0.5, -9)
                Switch.BackgroundColor3 = State and AccentColor or Color3.fromRGB(40, 44, 58)
                Switch.Parent = ToggleFrame

                local SwitchCorner = Instance.new("UICorner")
                SwitchCorner.CornerRadius = UDim.new(1, 0)
                SwitchCorner.Parent = Switch

                local Knob = Instance.new("Frame")
                Knob.Size = UDim2.new(0, 14, 0, 14)
                Knob.Position = State and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.Parent = Switch

                local KnobCorner = Instance.new("UICorner")
                KnobCorner.CornerRadius = UDim.new(1, 0)
                KnobCorner.Parent = Knob

                local ClickBtn = Instance.new("TextButton")
                ClickBtn.Size = UDim2.new(1, 0, 1, 0)
                ClickBtn.BackgroundTransparency = 1
                ClickBtn.Text = ""
                ClickBtn.Parent = ToggleFrame

                local function SetState(val)
                    State = val
                    Tween(Switch, {0.2, Enum.EasingStyle.Quart}, {BackgroundColor3 = State and AccentColor or Color3.fromRGB(40, 44, 58)})
                    Tween(Knob, {0.2, Enum.EasingStyle.Quart}, {Position = State and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
                    task.spawn(Callback, State)
                end

                ClickBtn.MouseButton1Click:Connect(function()
                    SetState(not State)
                end)
            end

            --------------------------------------------------------------------
            -- ELEMENTO: SLIDER
            --------------------------------------------------------------------
            function SectionObj:CreateSlider(sldConfig)
                sldConfig = sldConfig or {}
                local Name = sldConfig.Name or "Slider"
                local Min = sldConfig.Min or 0
                local Max = sldConfig.Max or 100
                local Value = sldConfig.Default or Min
                local Callback = sldConfig.Callback or function() end

                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, 0, 0, 42)
                SliderFrame.BackgroundColor3 = Color3.fromRGB(26, 29, 40)
                SliderFrame.Parent = SectionFrame

                local SldCorner = Instance.new("UICorner")
                SldCorner.CornerRadius = UDim.new(0, 6)
                SldCorner.Parent = SliderFrame

                local Label = Instance.new("TextLabel")
                Label.Text = Name
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 12
                Label.TextColor3 = Color3.fromRGB(230, 235, 245)
                Label.Size = UDim2.new(0.6, 0, 0, 15)
                Label.Position = UDim2.new(0, 10, 0, 6)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = SliderFrame

                local ValLabel = Instance.new("TextLabel")
                ValLabel.Text = tostring(Value)
                ValLabel.Font = Enum.Font.GothamBold
                ValLabel.TextSize = 11
                ValLabel.TextColor3 = AccentColor
                ValLabel.Size = UDim2.new(0.3, 0, 0, 15)
                ValLabel.Position = UDim2.new(0.7, -10, 0, 6)
                ValLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValLabel.BackgroundTransparency = 1
                ValLabel.Parent = SliderFrame

                local Track = Instance.new("Frame")
                Track.Size = UDim2.new(1, -20, 0, 6)
                Track.Position = UDim2.new(0, 10, 0, 26)
                Track.BackgroundColor3 = Color3.fromRGB(40, 44, 58)
                Track.Parent = SliderFrame

                local TrackCorner = Instance.new("UICorner")
                TrackCorner.CornerRadius = UDim.new(1, 0)
                TrackCorner.Parent = Track

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((Value - Min)/(Max - Min), 0, 1, 0)
                Fill.BackgroundColor3 = AccentColor
                Fill.Parent = Track

                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent = Fill

                local draggingSld = false

                local function UpdateSlider(input)
                    local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local calculatedVal = math.floor(Min + ((Max - Min) * pos))
                    Value = calculatedVal
                    ValLabel.Text = tostring(Value)
                    Tween(Fill, {0.05, Enum.EasingStyle.Linear}, {Size = UDim2.new(pos, 0, 1, 0)})
                    task.spawn(Callback, Value)
                end

                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSld = true
                        UpdateSlider(input)
                    end
                end)

                Track.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSld = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if draggingSld and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)
            end

            return SectionObj
        end

        return TabObj
    end

    return WindowObj
end

return AetheriaLib
