--[[
    ABSOLUTE UI LIBRARY v2 (Neon Glass Edition)
    Design: Dark Glassmorphism, Dynamic Neon Borders & Horizontal Cards Grid
]]

local AbsoluteLib = {}
AbsoluteLib.__index = AbsoluteLib

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

-- Auxiliar de Canto Arredondado
local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

--------------------------------------------------------------------------------
-- SISTEMA DE NOTIFICAÇÕES
--------------------------------------------------------------------------------
local NotificationGui
local NotificationContainer

local function InitNotificationSystem()
    if not NotificationGui then
        NotificationGui = Instance.new("ScreenGui")
        NotificationGui.Name = "AbsoluteNotifications"
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

function AbsoluteLib:Notify(config)
    InitNotificationSystem()
    
    local titleText = config.Title or "Notificação"
    local contentText = config.Content or ""
    local duration = config.Duration or 3

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 65)
    card.BackgroundColor3 = Color3.fromRGB(16, 17, 26)
    card.BackgroundTransparency = 0.15
    card.Position = UDim2.new(1, 350, 0, 0)
    card.Parent = NotificationContainer
    AddCorner(card, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 191, 255)
    stroke.Transparency = 0.4
    stroke.Thickness = 1.5
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
function AbsoluteLib:InitConfigSystem(windowObj, folderName)
    folderName = folderName or "AbsoluteConfigs"
    
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
            AbsoluteLib:Notify({ Title = "Erro", Content = "Executor sem suporte a arquivos.", Duration = 3 })
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
            AbsoluteLib:Notify({ Title = "Configurações", Content = "Perfil '" .. configName .. "' salvo!", Duration = 2.5 })
            return true
        else
            warn("[AbsoluteLib] Erro ao salvar config: " .. tostring(err))
            return false
        end
    end

    function ConfigSystem:Load(configName)
        if not readfile or not isfile then
            AbsoluteLib:Notify({ Title = "Erro", Content = "Executor sem suporte a arquivos.", Duration = 3 })
            return false
        end

        local filePath = self.FolderName .. "/" .. configName .. ".json"
        if not isfile(filePath) then
            AbsoluteLib:Notify({ Title = "Erro", Content = "Arquivo de configuração não encontrado.", Duration = 2.5 })
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
            AbsoluteLib:Notify({ Title = "Configurações", Content = "Perfil '" .. configName .. "' carregado!", Duration = 2.5 })
            return true
        else
            warn("[AbsoluteLib] Erro ao carregar config: " .. tostring(err))
            return false
        end
    end

    windowObj.ConfigSystem = ConfigSystem
    return ConfigSystem
end

--------------------------------------------------------------------------------
-- CREATOR DA JANELA PRINCIPAL
--------------------------------------------------------------------------------
function AbsoluteLib:CreateWindow(config)
    config = config or {}
    local TitleText = config.Title or "Absolute Hub"
    local SubTitleText = config.SubTitle or "For Murder Drones"
    local PrimaryColor = config.PrimaryColor or Color3.fromRGB(0, 191, 255)
    local HoverColor = config.HoverColor or Color3.fromRGB(0, 150, 220)
    local NeonWhite = Color3.fromRGB(255, 255, 255)
    local ToggleKey = config.ToggleKey or Enum.KeyCode.LeftControl

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AbsoluteHub"
    ScreenGui.ResetOnSpawn = false
    
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 850, 0, 520)
    MainFrame.Position = UDim2.new(0.5, -425, 0.5, -260)
    MainFrame.BackgroundColor3 = Color3.fromRGB(8, 9, 13)
    MainFrame.BackgroundTransparency = 0.12
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui
    AddCorner(MainFrame, 16)

    -- Efeito Borda Neon Externa Gire
    local HubGlowFrame = Instance.new("Frame")
    HubGlowFrame.Name = "HubGlowFrame"
    HubGlowFrame.Size = UDim2.new(1, 4, 1, 4)
    HubGlowFrame.Position = UDim2.new(0, -2, 0, -2)
    HubGlowFrame.BackgroundTransparency = 1
    HubGlowFrame.ZIndex = MainFrame.ZIndex - 1
    HubGlowFrame.Parent = MainFrame
    AddCorner(HubGlowFrame, 18)

    local HubStroke = Instance.new("UIStroke")
    HubStroke.Color = NeonWhite
    HubStroke.Thickness = 2
    HubStroke.Transparency = 0.1
    HubStroke.Parent = HubGlowFrame

    local HubGradient = Instance.new("UIGradient")
    HubGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, NeonWhite),
        ColorSequenceKeypoint.new(0.5, PrimaryColor),
        ColorSequenceKeypoint.new(1, NeonWhite)
    }
    HubGradient.Parent = HubStroke

    -- Gerenciamento de Animação Neon Global
    local AnimatedGradients = { HubGradient }
    local RotConnection = RunService.RenderStepped:Connect(function(dt)
        if not MainFrame or not MainFrame.Parent then return end
        local rotDelta = dt * 90
        for _, grad in ipairs(AnimatedGradients) do
            if grad and grad.Parent then
                grad.Rotation = (grad.Rotation + rotDelta) % 360
            end
        end
    end)

    -- Auxiliar de Brilho em Botões Neon
    local function CreateButtonGlow(button)
        local glowBorder = Instance.new("Frame")
        glowBorder.Size = UDim2.new(1, 6, 1, 6)
        glowBorder.Position = UDim2.new(0, -3, 0, -3)
        glowBorder.BackgroundTransparency = 1
        glowBorder.ZIndex = button.ZIndex - 1
        glowBorder.Visible = false
        glowBorder.Parent = button
        AddCorner(glowBorder, 10)

        local stroke = Instance.new("UIStroke")
        stroke.Color = NeonWhite
        stroke.Thickness = 1.5
        stroke.Transparency = 0.4
        stroke.Parent = glowBorder

        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, NeonWhite),
            ColorSequenceKeypoint.new(0.5, PrimaryColor),
            ColorSequenceKeypoint.new(1, NeonWhite)
        }
        gradient.Parent = stroke
        table.insert(AnimatedGradients, gradient)

        button.MouseEnter:Connect(function()
            glowBorder.Visible = true
            Tween(button, {0.2, Enum.EasingStyle.Quad}, {BackgroundColor3 = HoverColor})
            Tween(stroke, {0.2, Enum.EasingStyle.Quad}, {Transparency = 0.1})
        end)

        button.MouseLeave:Connect(function()
            Tween(button, {0.2, Enum.EasingStyle.Quad}, {BackgroundColor3 = Color3.fromRGB(24, 26, 38)})
            Tween(stroke, {0.3, Enum.EasingStyle.Quad}, {Transparency = 0.7})
            task.delay(0.2, function()
                if glowBorder then glowBorder.Visible = false end
            end)
        end)
    end

    -- Sistema de Arrastar (Drag)
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

    -- Toggle de Visibilidade por Tecla
    local IsVisible = true
    local function SetUIVisibility(visible)
        IsVisible = visible
        MainFrame.Visible = IsVisible
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == ToggleKey then
            SetUIVisibility(not IsVisible)
        end
    end)

    -- Sidebar (Painel Esquerdo)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 200, 1, 0)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Parent = MainFrame

    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(0, 1, 1, 0)
    Divider.Position = UDim2.new(0, 200, 0, 0)
    Divider.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    Divider.BackgroundTransparency = 0.7
    Divider.BorderSizePixel = 0
    Divider.Parent = MainFrame

    local HubTitle = Instance.new("TextLabel")
    HubTitle.Text = TitleText
    HubTitle.Font = Enum.Font.GothamBold
    HubTitle.TextSize = 20
    HubTitle.TextColor3 = NeonWhite
    HubTitle.Position = UDim2.new(0, 20, 0, 35)
    HubTitle.Size = UDim2.new(1, -30, 0, 25)
    HubTitle.TextXAlignment = Enum.TextXAlignment.Left
    HubTitle.BackgroundTransparency = 1
    HubTitle.Parent = Sidebar

    local HubSub = Instance.new("TextLabel")
    HubSub.Text = SubTitleText
    HubSub.Font = Enum.Font.GothamMedium
    HubSub.TextSize = 12
    HubSub.TextColor3 = Color3.fromRGB(110, 110, 125)
    HubSub.Position = UDim2.new(0, 20, 0, 60)
    HubSub.Size = UDim2.new(1, -30, 0, 15)
    HubSub.TextXAlignment = Enum.TextXAlignment.Left
    HubSub.BackgroundTransparency = 1
    HubSub.Parent = Sidebar

    local NavContainer = Instance.new("Frame")
    NavContainer.Size = UDim2.new(1, -24, 1, -180)
    NavContainer.Position = UDim2.new(0, 12, 0, 105)
    NavContainer.BackgroundTransparency = 1
    NavContainer.Parent = Sidebar

    local NavLayout = Instance.new("UIListLayout")
    NavLayout.Padding = UDim.new(0, 6)
    NavLayout.Parent = NavContainer

    -- Conteúdo Principal (Lado Direito)
    local MainContent = Instance.new("Frame")
    MainContent.Size = UDim2.new(1, -240, 1, -40)
    MainContent.Position = UDim2.new(0, 220, 0, 20)
    MainContent.BackgroundTransparency = 1
    MainContent.Parent = MainFrame

    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Size = UDim2.new(0, 300, 0, 32)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = "Menu Principal"
    SectionTitle.TextColor3 = NeonWhite
    SectionTitle.TextSize = 24
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.Parent = MainContent

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(0, 250, 0, 32)
    SearchBox.Position = UDim2.new(1, -250, 0, 0)
    SearchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    SearchBox.BackgroundTransparency = 0.4
    SearchBox.PlaceholderText = "Pesquisar..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 95)
    SearchBox.TextColor3 = Color3.fromRGB(240, 240, 240)
    SearchBox.TextSize = 13
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.Parent = MainContent
    AddCorner(SearchBox, 8)

    local SearchPadding = Instance.new("UIPadding")
    SearchPadding.PaddingLeft = UDim.new(0, 12)
    SearchPadding.Parent = SearchBox

    local DisplayViews = Instance.new("Frame")
    DisplayViews.Size = UDim2.new(1, 0, 1, -50)
    DisplayViews.Position = UDim2.new(0, 0, 0, 50)
    DisplayViews.BackgroundTransparency = 1
    DisplayViews.Parent = MainContent

    local WindowObj = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        Tabs = {},
        ActiveTab = nil,
        PrimaryColor = PrimaryColor,
        SetToggleKey = function(self, newKey) ToggleKey = newKey end,
        ToggleUI = function(self) SetUIVisibility(not IsVisible) end,
        Destroy = function(self)
            if RotConnection then RotConnection:Disconnect() end
            ScreenGui:Destroy()
        end
    }

    ------------------------------------------------------------------------
    -- CRIADOR DE ABAS (CreateTab)
    ------------------------------------------------------------------------
    function WindowObj:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local TabName = tabConfig.Name or "Aba"
        local IsHorizontalGrid = tabConfig.HorizontalGrid or false
        local Hidden = tabConfig.Hidden or false

        local NavBtn = Instance.new("TextButton")
        NavBtn.Size = UDim2.new(1, 0, 0, 36)
        NavBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        NavBtn.BackgroundTransparency = 1
        NavBtn.Text = "     " .. TabName
        NavBtn.TextColor3 = Color3.fromRGB(140, 140, 155)
        NavBtn.TextSize = 13
        NavBtn.Font = Enum.Font.GothamSemibold
        NavBtn.TextXAlignment = Enum.TextXAlignment.Left
        NavBtn.Visible = not Hidden
        NavBtn.Parent = NavContainer
        AddCorner(NavBtn, 6)

        CreateButtonGlow(NavBtn)

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = "Page_" .. TabName
        TabPage.Visible = false
        TabPage.BackgroundTransparency = 1
        TabPage.Parent = DisplayViews

        if IsHorizontalGrid then
            TabPage.Size = UDim2.new(1, -30, 0, 190)
            TabPage.Position = UDim2.new(0, 15, 0, 10)
            TabPage.ScrollBarThickness = 4
            TabPage.ScrollBarImageColor3 = PrimaryColor
            TabPage.ScrollingDirection = Enum.ScrollingDirection.X
            TabPage.ClipsDescendants = true

            local viewPadding = Instance.new("UIPadding")
            viewPadding.PaddingTop = UDim.new(0, 10)
            viewPadding.PaddingBottom = UDim.new(0, 10)
            viewPadding.PaddingLeft = UDim.new(0, 10)
            viewPadding.PaddingRight = UDim.new(0, 10)
            viewPadding.Parent = TabPage

            local containerFrame = Instance.new("Frame")
            containerFrame.Size = UDim2.new(0, 0, 1, 0)
            containerFrame.BackgroundTransparency = 1
            containerFrame.Parent = TabPage

            local horizontalLayout = Instance.new("UIListLayout")
            horizontalLayout.FillDirection = Enum.FillDirection.Horizontal
            horizontalLayout.Padding = UDim.new(0, 25)
            horizontalLayout.SortOrder = Enum.SortOrder.LayoutOrder
            horizontalLayout.Parent = containerFrame

            horizontalLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                containerFrame.Size = UDim2.new(0, horizontalLayout.AbsoluteContentSize.X, 1, 0)
                TabPage.CanvasSize = UDim2.new(0, horizontalLayout.AbsoluteContentSize.X + 50, 0, 0)
            end)
        else
            TabPage.Size = UDim2.new(1, 0, 1, 0)
            TabPage.ScrollBarThickness = 2
            TabPage.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 65)
            TabPage.ScrollingDirection = Enum.ScrollingDirection.Y

            local listLayout = Instance.new("UIListLayout")
            listLayout.Padding = UDim.new(0, 12)
            listLayout.Parent = TabPage

            listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                TabPage.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
            end)
        end

        local TabObj = { Page = TabPage, Button = NavBtn, Name = TabName, SearchItems = {} }

        function TabObj:Select()
            for _, t in pairs(WindowObj.Tabs) do
                t.Page.Visible = false
                Tween(t.Button, {0.2}, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(140, 140, 155)})
            end

            TabPage.Visible = true
            SectionTitle.Text = TabName
            Tween(NavBtn, {0.2}, {BackgroundColor3 = PrimaryColor, BackgroundTransparency = 0.75, TextColor3 = NeonWhite})
            WindowObj.ActiveTab = TabObj
        end

        NavBtn.MouseButton1Click:Connect(function() TabObj:Select() end)

        table.insert(WindowObj.Tabs, TabObj)
        if #WindowObj.Tabs == 1 and not Hidden then TabObj:Select() end

        -- Pesquisa ativa na aba
        SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            if WindowObj.ActiveTab == TabObj then
                local cleanText = string.lower(SearchBox.Text)
                for _, item in ipairs(TabObj.SearchItems) do
                    if cleanText == "" or string.find(string.lower(item.Name), cleanText) then
                        item.Instance.Visible = true
                    else
                        item.Instance.Visible = false
                    end
                end
            end
        end)

        ------------------------------------------------------------------------
        -- COMPONENTES DA ABA
        ------------------------------------------------------------------------
        
        -- CARD DE JOGO (Grid Horizontal)
        function TabObj:CreateGameCard(cardConfig)
            cardConfig = cardConfig or {}
            local Name = cardConfig.Name or "Jogo"
            local Callback = cardConfig.Callback or function() end

            local parentFrame = TabPage:FindFirstChildOfClass("Frame") or TabPage

            local card = Instance.new("TextButton")
            card.Name = Name
            card.Size = UDim2.new(0, 115, 0, 150)
            card.BackgroundColor3 = Color3.fromRGB(22, 23, 30)
            card.BackgroundTransparency = 0.5
            card.Text = ""
            card.Parent = parentFrame
            AddCorner(card, 12)

            CreateButtonGlow(card)

            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, -16, 0, 50)
            title.Position = UDim2.new(0, 8, 0.5, 10)
            title.BackgroundTransparency = 1
            title.Text = Name
            title.TextColor3 = NeonWhite
            title.TextSize = 12
            title.Font = Enum.Font.GothamBold
            title.TextWrapped = true
            title.Parent = card

            card.MouseButton1Click:Connect(function()
                task.spawn(Callback)
            end)

            table.insert(TabObj.SearchItems, { Name = Name, Instance = card })
            return card
        end

        -- COMPONENTE: TOGGLE
        function TabObj:CreateToggle(tglConfig)
            tglConfig = tglConfig or {}
            local Name = tglConfig.Name or "Toggle"
            local State = tglConfig.Default or false
            local Callback = tglConfig.Callback or function() end

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -15, 0, 44)
            Frame.BackgroundColor3 = Color3.fromRGB(16, 17, 26)
            Frame.Parent = TabPage
            AddCorner(Frame, 8)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -70, 1, 0)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = Name
            Label.TextColor3 = Color3.fromRGB(235, 235, 240)
            Label.TextSize = 13
            Label.Font = Enum.Font.GothamSemibold
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            local Switch = Instance.new("TextButton")
            Switch.Size = UDim2.new(0, 40, 0, 22)
            Switch.Position = UDim2.new(1, -55, 0.5, -11)
            Switch.BackgroundColor3 = State and PrimaryColor or Color3.fromRGB(35, 36, 48)
            Switch.Text = ""
            Switch.Parent = Frame
            AddCorner(Switch, 11)

            local Indicator = Instance.new("Frame")
            Indicator.Size = UDim2.new(0, 16, 0, 16)
            Indicator.Position = State and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            Indicator.BackgroundColor3 = NeonWhite
            Indicator.Parent = Switch
            AddCorner(Indicator, 8)

            local function SetState(val)
                State = val
                Tween(Indicator, {0.18, Enum.EasingStyle.Quart}, {Position = State and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)})
                Tween(Switch, {0.18, Enum.EasingStyle.Quart}, {BackgroundColor3 = State and PrimaryColor or Color3.fromRGB(35, 36, 48)})
                task.spawn(Callback, State)
            end

            Switch.MouseButton1Click:Connect(function() SetState(not State) end)

            table.insert(TabObj.SearchItems, { Name = Name, Instance = Frame })
            return { Set = SetState, Get = function() return State end }
        end

        -- COMPONENTE: BUTTON
        function TabObj:CreateButton(btnConfig)
            btnConfig = btnConfig or {}
            local Name = btnConfig.Name or "Botão"
            local Callback = btnConfig.Callback or function() end

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, -15, 0, 42)
            Btn.BackgroundColor3 = Color3.fromRGB(24, 26, 38)
            Btn.Text = Name
            Btn.TextColor3 = NeonWhite
            Btn.TextSize = 13
            Btn.Font = Enum.Font.GothamSemibold
            Btn.Parent = TabPage
            AddCorner(Btn, 8)

            CreateButtonGlow(Btn)

            Btn.MouseButton1Click:Connect(function() task.spawn(Callback) end)

            table.insert(TabObj.SearchItems, { Name = Name, Instance = Btn })
            return Btn
        end

        -- COMPONENTE: KEYBIND
        function TabObj:CreateKeybind(kbConfig)
            kbConfig = kbConfig or {}
            local Name = kbConfig.Name or "Keybind"
            local CurrentKey = kbConfig.Default or Enum.KeyCode.E
            local Callback = kbConfig.Callback or function() end

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -15, 0, 44)
            Frame.BackgroundColor3 = Color3.fromRGB(16, 17, 26)
            Frame.Parent = TabPage
            AddCorner(Frame, 8)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -130, 1, 0)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = Name
            Label.TextColor3 = Color3.fromRGB(235, 235, 240)
            Label.TextSize = 13
            Label.Font = Enum.Font.GothamSemibold
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            local KeyBtn = Instance.new("TextButton")
            KeyBtn.Size = UDim2.new(0, 110, 0, 26)
            KeyBtn.Position = UDim2.new(1, -125, 0.5, -13)
            KeyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
            KeyBtn.Text = CurrentKey.Name
            KeyBtn.TextColor3 = NeonWhite
            KeyBtn.TextSize = 12
            KeyBtn.Font = Enum.Font.Code
            KeyBtn.Parent = Frame
            AddCorner(KeyBtn, 6)

            local Binding = false
            KeyBtn.MouseButton1Click:Connect(function()
                if Binding then return end
                Binding = true
                KeyBtn.Text = "..."
                KeyBtn.TextColor3 = Color3.fromRGB(200, 80, 80)

                local conn
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        CurrentKey = input.KeyCode
                        KeyBtn.Text = CurrentKey.Name
                        KeyBtn.TextColor3 = NeonWhite
                        Binding = false
                        conn:Disconnect()
                        task.spawn(Callback, CurrentKey)
                    end
                end)
            end)

            table.insert(TabObj.SearchItems, { Name = Name, Instance = Frame })
            return {
                Set = function(key) CurrentKey = key KeyBtn.Text = CurrentKey.Name end,
                Get = function() return CurrentKey end
            }
        end

        return TabObj
    end

    return WindowObj
end

return AbsoluteLib
