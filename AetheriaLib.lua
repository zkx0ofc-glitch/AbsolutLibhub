--[[
    AETHERIA UI LIBRARY + VORTEX HUB (SINGLE FILE EDITION)
    Design: Advanced Glassmorphism & Dynamic ARGB Borders
    Compatibility: Roblox Studio & External Executors
]]

--------------------------------------------------------------------------------
-- PARTE 1: CORE DA AETHERIA UI LIBRARY
--------------------------------------------------------------------------------
local AetheriaLib = {}
AetheriaLib.__index = AetheriaLib

-- Serviços do Roblox
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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
        
        pcall(function() NotificationGui.Parent = CoreGui end)
        if not NotificationGui.Parent then
            NotificationGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
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
    card.Position = UDim2.new(1, 350, 0, 0)
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

    Tween(card, {0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {Position = UDim2.new(0, 0, 0, 0)})

    task.delay(duration, function()
        local tweenOut = Tween(card, {0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In}, {Position = UDim2.new(1, 350, 0, 0)})
        tweenOut.Completed:Connect(function()
            card:Destroy()
        end)
    end)
end

--------------------------------------------------------------------------------
-- SISTEMA DE CONFIGURAÇÕES (JSON)
--------------------------------------------------------------------------------
function AetheriaLib:InitConfigSystem(windowObj, folderName)
    folderName = folderName or "AetheriaConfigs"
    
    if makefolder and not isfolder(folderName) then
        makefolder(folderName)
    end

    local ConfigSystem = {
        FolderName = folderName,
        RegisteredElements = {}
    }

    function ConfigSystem:Register(id, getValueFunc, setValueFunc)
        self.RegisteredElements[id] = { Get = getValueFunc, Set = setValueFunc }
    end

    function ConfigSystem:Save(configName)
        if not writefile then
            AetheriaLib:Notify({ Title = "Erro", Content = "O seu executor não suporta salvamento de arquivos.", Duration = 3 })
            return false
        end

        local dataToSave = {}
        for id, element in pairs(self.RegisteredElements) do
            dataToSave[id] = element.Get()
        end

        local filePath = self.FolderName .. "/" .. configName .. ".json"
        local success, err = pcall(function()
            writefile(filePath, HttpService:JSONEncode(dataToSave))
        end)

        if success then
            AetheriaLib:Notify({ Title = "Configurações", Content = "Perfil '" .. configName .. "' salvo com sucesso!", Duration = 2.5 })
            return true
        else
            warn("[AetheriaLib] Erro ao salvar config: " .. tostring(err))
            return false
        end
    end

    function ConfigSystem:Load(configName)
        if not readfile or not isfile then
            AetheriaLib:Notify({ Title = "Erro", Content = "O seu executor não suporta leitura de arquivos.", Duration = 3 })
            return false
        end

        local filePath = self.FolderName .. "/" .. configName .. ".json"
        if not isfile(filePath) then
            AetheriaLib:Notify({ Title = "Erro", Content = "Arquivo de configuração não encontrado.", Duration = 2.5 })
            return false
        end

        local success, err = pcall(function()
            local decodedData = HttpService:JSONDecode(readfile(filePath))
            for id, value in pairs(decodedData) do
                if self.RegisteredElements[id] then
                    self.RegisteredElements[id].Set(value)
                end
            end
        end)

        if success then
            AetheriaLib:Notify({ Title = "Configurações", Content = "Perfil '" .. configName .. "' carregado com sucesso!", Duration = 2.5 })
            return true
        else
            warn("[AetheriaLib] Erro ao carregar config: " .. tostring(err))
            return false
        end
    end

    windowObj.ConfigSystem = ConfigSystem
    return ConfigSystem
end

--------------------------------------------------------------------------------
-- CREATOR DA JANELA PRINCIPAL
--------------------------------------------------------------------------------
function AetheriaLib:CreateWindow(config)
    config = config or {}
    local TitleText = config.Title or "AETHERIA"
    local SubTitleText = config.SubTitle or "UI Dashboard"
    local AccentColor = config.AccentColor or Color3.fromRGB(0, 170, 255)
    local EnableARGB = config.ARGBBorders ~= false
    local GradientSpeed = config.GradientSpeed or 3
    local ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AetheriaLib_UI"
    ScreenGui.ResetOnSpawn = false
    
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

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

    -- Drag System
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Toggle de Visibilidade da UI por Tecla
    local IsVisible = true
    local IsAnimating = false

    local function SetUIVisibility(visible)
        if IsAnimating then return end
        IsAnimating = true
        IsVisible = visible

        if IsVisible then
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 620, 0, 400)
            MainFrame.Position = UDim2.new(0.5, -310, 0.5, -200)
            local tween = Tween(MainFrame, {0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {
                Size = UDim2.new(0, 650, 0, 420),
                Position = UDim2.new(0.5, -325, 0.5, -210)
            })
            tween.Completed:Connect(function() IsAnimating = false end)
        else
            local tween = Tween(MainFrame, {0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In}, {
                Size = UDim2.new(0, 620, 0, 400),
                Position = UDim2.new(0.5, -310, 0.5, -200)
            })
            tween.Completed:Connect(function()
                MainFrame.Visible = false
                IsAnimating = false
            end)
        end
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == ToggleKey then
                SetUIVisibility(not IsVisible)
            end
        end
    end)

    -- Sidebar & Brand
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
        ActiveTab = nil,
        SetToggleKey = function(self, newKey) ToggleKey = newKey end,
        ToggleUI = function(self) SetUIVisibility(not IsVisible) end
    }

    ----------------------------------------------------------------------------
    -- CRIADOR DE ABAS (CreateTab)
    ----------------------------------------------------------------------------
    function WindowObj:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local TabName = tabConfig.Name or "Aba"

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

        local TabObj = { Page = TabPage, Button = TabButton }

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
        TabButton.MouseEnter:Connect(function()
            if WindowObj.ActiveTab ~= TabObj then Tween(TabLabel, {0.2, Enum.EasingStyle.Quart}, {TextColor3 = Color3.fromRGB(210, 215, 230)}) end
        end)
        TabButton.MouseLeave:Connect(function()
            if WindowObj.ActiveTab ~= TabObj then Tween(TabLabel, {0.2, Enum.EasingStyle.Quart}, {TextColor3 = Color3.fromRGB(150, 155, 170)}) end
        end)

        table.insert(WindowObj.Tabs, TabObj)
        if #WindowObj.Tabs == 1 then Select() end

        ------------------------------------------------------------------------
        -- CRIADOR DE SEÇÕES (CreateSection)
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

            SecLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, 0, 0, SecLayout.AbsoluteContentSize.Y + 16)
            end)

            local SectionObj = {}

            -- COMPONENTE: BUTTON
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

            -- COMPONENTE: TOGGLE
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

                return { Set = SetState, Get = function() return State end }
            end

            -- COMPONENTE: SLIDER
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

                local function SetValue(val)
                    Value = math.clamp(val, Min, Max)
                    ValLabel.Text = tostring(Value)
                    local pos = (Value - Min) / (Max - Min)
                    Tween(Fill, {0.05, Enum.EasingStyle.Linear}, {Size = UDim2.new(pos, 0, 1, 0)})
                    task.spawn(Callback, Value)
                end

                local function UpdateSlider(input)
                    local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    SetValue(math.floor(Min + ((Max - Min) * pos)))
                end

                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSld = true
                        UpdateSlider(input)
                    end
                end)

                Track.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSld = false end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if draggingSld and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlider(input) end
                end)

                return { Set = SetValue, Get = function() return Value end }
            end

            -- COMPONENTE: DROPDOWN
            function SectionObj:CreateDropdown(drpConfig)
                drpConfig = drpConfig or {}
                local Name = drpConfig.Name or "Dropdown"
                local Options = drpConfig.Options or {}
                local Default = drpConfig.Default or Options[1] or "Nenhum"
                local Callback = drpConfig.Callback or function() end

                local Selected = Default
                local Expanded = false

                local DropdownContainer = Instance.new("Frame")
                DropdownContainer.Size = UDim2.new(1, 0, 0, 42)
                DropdownContainer.BackgroundColor3 = Color3.fromRGB(26, 29, 40)
                DropdownContainer.ClipsDescendants = true
                DropdownContainer.Parent = SectionFrame

                local DrpCorner = Instance.new("UICorner")
                DrpCorner.CornerRadius = UDim.new(0, 6)
                DrpCorner.Parent = DropdownContainer

                local Header = Instance.new("TextButton")
                Header.Size = UDim2.new(1, 0, 0, 42)
                Header.BackgroundTransparency = 1
                Header.Text = ""
                Header.Parent = DropdownContainer

                local Label = Instance.new("TextLabel")
                Label.Text = Name
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 12
                Label.TextColor3 = Color3.fromRGB(230, 235, 245)
                Label.Size = UDim2.new(0.5, 0, 0, 15)
                Label.Position = UDim2.new(0, 10, 0, 6)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = Header

                local SelectedLabel = Instance.new("TextLabel")
                SelectedLabel.Text = Selected
                SelectedLabel.Font = Enum.Font.Gotham
                SelectedLabel.TextSize = 11
                SelectedLabel.TextColor3 = AccentColor
                SelectedLabel.Size = UDim2.new(0.4, 0, 0, 15)
                SelectedLabel.Position = UDim2.new(0.6, -25, 0, 6)
                SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
                SelectedLabel.BackgroundTransparency = 1
                SelectedLabel.Parent = Header

                local Arrow = Instance.new("TextLabel")
                Arrow.Text = "▼"
                Arrow.Font = Enum.Font.GothamBold
                Arrow.TextSize = 9
                Arrow.TextColor3 = Color3.fromRGB(150, 155, 170)
                Arrow.Size = UDim2.new(0, 15, 0, 15)
                Arrow.Position = UDim2.new(1, -20, 0, 6)
                Arrow.BackgroundTransparency = 1
                Arrow.Parent = Header

                local OptionHolder = Instance.new("ScrollingFrame")
                OptionHolder.Size = UDim2.new(1, -20, 0, 0)
                OptionHolder.Position = UDim2.new(0, 10, 0, 28)
                OptionHolder.BackgroundTransparency = 1
                OptionHolder.ScrollBarThickness = 2
                OptionHolder.ScrollBarImageColor3 = AccentColor
                OptionHolder.Parent = DropdownContainer

                local OptionLayout = Instance.new("UIListLayout")
                OptionLayout.SortOrder = Enum.SortOrder.LayoutOrder
                OptionLayout.Padding = UDim.new(0, 4)
                OptionLayout.Parent = OptionHolder

                local function ToggleDropdown()
                    Expanded = not Expanded
                    local targetListHeight = math.min(#Options * 24, 100)
                    local targetTotalHeight = Expanded and (32 + targetListHeight) or 42

                    OptionHolder.Size = UDim2.new(1, -20, 0, Expanded and targetListHeight or 0)
                    Tween(Arrow, {0.2, Enum.EasingStyle.Quart}, {Rotation = Expanded and 180 or 0})
                    Tween(DropdownContainer, {0.2, Enum.EasingStyle.Quart}, {Size = UDim2.new(1, 0, 0, targetTotalHeight)})
                end

                Header.MouseButton1Click:Connect(ToggleDropdown)

                local function PopulateOptions()
                    for _, child in pairs(OptionHolder:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end

                    for _, opt in ipairs(Options) do
                        local OptBtn = Instance.new("TextButton")
                        OptBtn.Size = UDim2.new(1, -6, 0, 20)
                        OptBtn.BackgroundColor3 = Color3.fromRGB(34, 38, 52)
                        OptBtn.Text = opt
                        OptBtn.Font = Enum.Font.Gotham
                        OptBtn.TextSize = 11
                        OptBtn.TextColor3 = opt == Selected and AccentColor or Color3.fromRGB(200, 205, 220)
                        OptBtn.Parent = OptionHolder

                        local OptCorner = Instance.new("UICorner")
                        OptCorner.CornerRadius = UDim.new(0, 4)
                        OptCorner.Parent = OptBtn

                        OptBtn.MouseButton1Click:Connect(function()
                            Selected = opt
                            SelectedLabel.Text = Selected
                            PopulateOptions()
                            ToggleDropdown()
                            task.spawn(Callback, Selected)
                        end)
                    end
                    OptionHolder.CanvasSize = UDim2.new(0, 0, 0, OptionLayout.AbsoluteContentSize.Y)
                end

                PopulateOptions()

                return {
                    Set = function(val)
                        Selected = val
                        SelectedLabel.Text = Selected
                        PopulateOptions()
                        task.spawn(Callback, Selected)
                    end,
                    Get = function() return Selected end
                }
            end

            -- COMPONENTE: KEYBIND
            function SectionObj:CreateKeybind(kbConfig)
                kbConfig = kbConfig or {}
                local Name = kbConfig.Name or "Keybind"
                local Default = kbConfig.Default or Enum.KeyCode.E
                local Callback = kbConfig.Callback or function() end

                local CurrentKey = Default
                local Binding = false

                local KeybindFrame = Instance.new("Frame")
                KeybindFrame.Size = UDim2.new(1, 0, 0, 32)
                KeybindFrame.BackgroundColor3 = Color3.fromRGB(26, 29, 40)
                KeybindFrame.Parent = SectionFrame

                local KbCorner = Instance.new("UICorner")
                KbCorner.CornerRadius = UDim.new(0, 6)
                KbCorner.Parent = KeybindFrame

                local Label = Instance.new("TextLabel")
                Label.Text = Name
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 12
                Label.TextColor3 = Color3.fromRGB(230, 235, 245)
                Label.Size = UDim2.new(0.6, 0, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = KeybindFrame

                local KeyBtn = Instance.new("TextButton")
                KeyBtn.Size = UDim2.new(0, 70, 0, 20)
                KeyBtn.Position = UDim2.new(1, -80, 0.5, -10)
                KeyBtn.BackgroundColor3 = Color3.fromRGB(36, 40, 56)
                KeyBtn.Text = CurrentKey.Name
                KeyBtn.Font = Enum.Font.GothamBold
                KeyBtn.TextSize = 10
                KeyBtn.TextColor3 = AccentColor
                KeyBtn.Parent = KeybindFrame

                local KeyBtnCorner = Instance.new("UICorner")
                KeyBtnCorner.CornerRadius = UDim.new(0, 4)
                KeyBtnCorner.Parent = KeyBtn

                KeyBtn.MouseButton1Click:Connect(function()
                    Binding = true
                    KeyBtn.Text = "..."
                    KeyBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
                end)

                UserInputService.InputBegan:Connect(function(input, gpe)
                    if Binding and input.UserInputType == Enum.UserInputType.Keyboard then
                        CurrentKey = input.KeyCode
                        Binding = false
                        KeyBtn.Text = CurrentKey.Name
                        KeyBtn.TextColor3 = AccentColor
                        task.spawn(Callback, CurrentKey)
                    elseif not gpe and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == CurrentKey then
                        task.spawn(Callback, CurrentKey)
                    end
                end)

                return {
                    Set = function(keyEnum)
                        CurrentKey = keyEnum
                        KeyBtn.Text = CurrentKey.Name
                    end,
                    Get = function() return CurrentKey.Name end
                }
            end

            -- COMPONENTE: TEXTBOX
            function SectionObj:CreateTextBox(txtConfig)
                txtConfig = txtConfig or {}
                local Name = txtConfig.Name or "TextBox"
                local Placeholder = txtConfig.Placeholder or "Digite aqui..."
                local Callback = txtConfig.Callback or function() end

                local BoxFrame = Instance.new("Frame")
                BoxFrame.Size = UDim2.new(1, 0, 0, 36)
                BoxFrame.BackgroundColor3 = Color3.fromRGB(26, 29, 40)
                BoxFrame.Parent = SectionFrame

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 6)
                BoxCorner.Parent = BoxFrame

                local Label = Instance.new("TextLabel")
                Label.Text = Name
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 12
                Label.TextColor3 = Color3.fromRGB(230, 235, 245)
                Label.Size = UDim2.new(0.4, 0, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = BoxFrame

                local InputContainer = Instance.new("Frame")
                InputContainer.Size = UDim2.new(0.55, 0, 0, 22)
                InputContainer.Position = UDim2.new(0.45, -10, 0.5, -11)
                InputContainer.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
                InputContainer.Parent = BoxFrame

                local InputCorner = Instance.new("UICorner")
                InputCorner.CornerRadius = UDim.new(0, 4)
                InputCorner.Parent = InputContainer

                local InputStroke = Instance.new("UIStroke")
                InputStroke.Color = Color3.fromRGB(40, 45, 60)
                InputStroke.Thickness = 1
                InputStroke.Parent = InputContainer

                local TextBox = Instance.new("TextBox")
                TextBox.Size = UDim2.new(1, -10, 1, 0)
                TextBox.Position = UDim2.new(0, 5, 0, 0)
                TextBox.BackgroundTransparency = 1
                TextBox.Text = ""
                TextBox.PlaceholderText = Placeholder
                TextBox.Font = Enum.Font.Gotham
                TextBox.TextSize = 11
                TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                TextBox.PlaceholderColor3 = Color3.fromRGB(100, 105, 120)
                TextBox.TextXAlignment = Enum.TextXAlignment.Left
                TextBox.ClearTextOnFocus = false
                TextBox.Parent = InputContainer

                TextBox.Focused:Connect(function()
                    Tween(InputStroke, {0.15, Enum.EasingStyle.Quart}, {Color = AccentColor})
                end)

                TextBox.FocusLost:Connect(function(enterPressed)
                    Tween(InputStroke, {0.15, Enum.EasingStyle.Quart}, {Color = Color3.fromRGB(40, 45, 60)})
                    task.spawn(Callback, TextBox.Text, enterPressed)
                end)

                return {
                    Set = function(str)
                        TextBox.Text = str
                    end,
                    Get = function() return TextBox.Text end
                }
            end

            return SectionObj
        end

        return TabObj
    end

    return WindowObj
end
