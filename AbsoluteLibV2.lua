--[[
    ABSOLUTE UI LIBRARY v2.0 (Versão Estável sem Gradiente nos Botões)
    Design: Dark Glassmorphism & Status Badges
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

-- Cores do Sistema de Tags
local TagColors = {
    BETA = Color3.fromRGB(0, 150, 255),
    ATUALIZANDO = Color3.fromRGB(255, 140, 0),
    REMOVIDO = Color3.fromRGB(200, 40, 40),
    BLOQUEADO = Color3.fromRGB(100, 100, 115),
    NOVO = Color3.fromRGB(0, 230, 120)
}

-- Auxiliares de Estilização
local function Tween(instance, info, properties)
    local tween = TweenService:Create(instance, TweenInfo.new(unpack(info)), properties)
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

-- Auxiliar para Criar Badges/Tags
local function CreateBadge(parent, tagType, customPosition)
    if not tagType or not TagColors[string.upper(tagType)] then return end
    local cleanTag = string.upper(tagType)
    local tagColor = TagColors[cleanTag]

    local badge = Instance.new("Frame")
    badge.Name = "StatusBadge"
    badge.Size = UDim2.new(0, 0, 0, 18)
    badge.Position = customPosition or UDim2.new(1, -10, 0.5, -9)
    badge.BackgroundColor3 = tagColor
    badge.BackgroundTransparency = 0.2
    badge.AnchorPoint = Vector2.new(1, 0)
    badge.Parent = parent
    AddCorner(badge, 4)

    local stroke = Instance.new("UIStroke")
    stroke.Color = tagColor
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    stroke.Parent = badge

    local label = Instance.new("TextLabel")
    label.Text = cleanTag
    label.Font = Enum.Font.GothamBold
    label.TextSize = 9
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Parent = badge

    local textSize = game:GetService("TextService"):GetTextSize(cleanTag, 9, Enum.Font.GothamBold, Vector2.new(200, 18))
    badge.Size = UDim2.new(0, textSize.X + 10, 0, 18)

    return badge
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
            local decodedData = HttpService:JSONEncode(readfile(filePath))
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
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    AddCorner(MainFrame, 16)

    -- Efeito Borda Neon Apenas no MainFrame
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

    local RotConnection = RunService.RenderStepped:Connect(function(dt)
        if HubGradient and HubGradient.Parent then
            HubGradient.Rotation = (HubGradient.Rotation + (dt * 90)) % 360
        end
    end)

    -- Dragging
    local isDragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Visibilidade
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

    -- Sidebar
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

    -- ÁREA DE CONTEÚDO PRINCIPAL (Corta elementos vazando)
    local MainContent = Instance.new("Frame")
    MainContent.Size = UDim2.new(1, -220, 1, -20)
    MainContent.Position = UDim2.new(0, 210, 0, 10)
    MainContent.BackgroundTransparency = 1
    MainContent.ClipsDescendants = true
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
    SearchBox.Size = UDim2.new(0, 220, 0, 32)
    SearchBox.Position = UDim2.new(1, -230, 0, 0)
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
    DisplayViews.Size = UDim2.new(1, 0, 1, -45)
    DisplayViews.Position = UDim2.new(0, 0, 0, 45)
    DisplayViews.BackgroundTransparency = 1
    DisplayViews.ClipsDescendants = true
    DisplayViews.Parent = MainContent

    local FavoritesList = {}

    local WindowObj = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        Tabs = {},
        ActiveTab = nil,
        PrimaryColor = PrimaryColor,
        Favorites = FavoritesList,
        SetToggleKey = function(self, newKey) ToggleKey = newKey end,
        ToggleUI = function(self) SetUIVisibility(not IsVisible) end,
        Destroy = function(self)
            if RotConnection then RotConnection:Disconnect() end
            ScreenGui:Destroy()
        end
    }

    ------------------------------------------------------------------------
    -- CRIADOR DE ABAS
    ------------------------------------------------------------------------
    function WindowObj:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local TabName = tabConfig.Name or "Aba"
        local IsHorizontalGrid = tabConfig.HorizontalGrid or false
        local Hidden = tabConfig.Hidden or false
        local Tag = tabConfig.Tag

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

        if Tag then CreateBadge(NavBtn, Tag, UDim2.new(1, -8, 0.5, -9)) end

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = "Page_" .. TabName
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.Visible = false
        TabPage.BackgroundTransparency = 1
        TabPage.ClipsDescendants = true
        TabPage.BorderSizePixel = 0
        TabPage.Parent = DisplayViews

        if IsHorizontalGrid then
            TabPage.ScrollBarThickness = 4
            TabPage.ScrollBarImageColor3 = PrimaryColor
            TabPage.ScrollingDirection = Enum.ScrollingDirection.X

            local viewPadding = Instance.new("UIPadding")
            viewPadding.PaddingTop = UDim.new(0, 10)
            viewPadding.PaddingBottom = UDim.new(0, 10)
            viewPadding.PaddingLeft = UDim.new(0, 5)
            viewPadding.PaddingRight = UDim.new(0, 10)
            viewPadding.Parent = TabPage

            local horizontalLayout = Instance.new("UIListLayout")
            horizontalLayout.FillDirection = Enum.FillDirection.Horizontal
            horizontalLayout.Padding = UDim.new(0, 12)
            horizontalLayout.SortOrder = Enum.SortOrder.LayoutOrder
            horizontalLayout.Parent = TabPage

            horizontalLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                TabPage.CanvasSize = UDim2.new(0, horizontalLayout.AbsoluteContentSize.X + 20, 0, 0)
            end)
        else
            TabPage.ScrollBarThickness = 2
            TabPage.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 65)
            TabPage.ScrollingDirection = Enum.ScrollingDirection.Y

            local listLayout = Instance.new("UIListLayout")
            listLayout.Padding = UDim.new(0, 10)
            listLayout.Parent = TabPage

            listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                TabPage.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
            end)
        end

        local TabObj = { Page = TabPage, Button = NavBtn, Name = TabName, SearchItems = {} }

        function TabObj:Select()
            if Tag == "BLOQUEADO" or Tag == "REMOVIDO" then
                AbsoluteLib:Notify({ Title = "Acesso Negado", Content = "Esta aba está " .. string.lower(Tag) .. "!", Duration = 2 })
                return
            end

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

        -- Pesquisa
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
        
        -- CARD DE JOGO (Grade Ajustada)
        function TabObj:CreateGameCard(cardConfig)
            cardConfig = cardConfig or {}
            local Name = cardConfig.Name or "Jogo"
            local GameId = cardConfig.GameId or Name
            local Tag = cardConfig.Tag
            local Callback = cardConfig.Callback or function() end

            local card = Instance.new("TextButton")
            card.Name = Name
            card.Size = UDim2.new(0, 140, 0, 180)
            card.BackgroundColor3 = Color3.fromRGB(22, 23, 30)
            card.BackgroundTransparency = 0.4
            card.Text = ""
            card.ClipsDescendants = true
            card.Parent = TabPage
            AddCorner(card, 10)

            local cardStroke = Instance.new("UIStroke")
            cardStroke.Color = Color3.fromRGB(45, 48, 65)
            cardStroke.Thickness = 1
            cardStroke.Parent = card

            if Tag then CreateBadge(card, Tag, UDim2.new(0, 10, 0, 10)) end

            local FavBtn = Instance.new("TextButton")
            FavBtn.Size = UDim2.new(0, 24, 0, 24)
            FavBtn.Position = UDim2.new(1, -28, 0, 6)
            FavBtn.BackgroundTransparency = 1
            FavBtn.Text = FavoritesList[GameId] and "★" or "☆"
            FavBtn.TextColor3 = FavoritesList[GameId] and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(120, 120, 140)
            FavBtn.TextSize = 16
            FavBtn.Font = Enum.Font.GothamBold
            FavBtn.ZIndex = card.ZIndex + 2
            FavBtn.Parent = card

            FavBtn.MouseButton1Click:Connect(function()
                FavoritesList[GameId] = not FavoritesList[GameId]
                FavBtn.Text = FavoritesList[GameId] and "★" or "☆"
                FavBtn.TextColor3 = FavoritesList[GameId] and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(120, 120, 140)
                
                AbsoluteLib:Notify({
                    Title = "Favoritos",
                    Content = FavoritesList[GameId] and (Name .. " adicionado aos favoritos!") or (Name .. " removido dos favoritos."),
                    Duration = 2
                })
            end)

            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, -16, 0, 40)
            title.Position = UDim2.new(0, 8, 0.5, 20)
            title.BackgroundTransparency = 1
            title.Text = Name
            title.TextColor3 = NeonWhite
            title.TextSize = 12
            title.Font = Enum.Font.GothamBold
            title.TextWrapped = true
            title.Parent = card

            card.MouseEnter:Connect(function()
                Tween(card, {0.15}, {BackgroundColor3 = Color3.fromRGB(32, 34, 46)})
                Tween(cardStroke, {0.15}, {Color = PrimaryColor})
            end)

            card.MouseLeave:Connect(function()
                Tween(card, {0.15}, {BackgroundColor3 = Color3.fromRGB(22, 23, 30)})
                Tween(cardStroke, {0.15}, {Color = Color3.fromRGB(45, 48, 65)})
            end)

            card.MouseButton1Click:Connect(function()
                if Tag == "BLOQUEADO" or Tag == "REMOVIDO" then
                    AbsoluteLib:Notify({ Title = "Indisponível", Content = "Este jogo está " .. string.lower(Tag) .. "!", Duration = 2 })
                    return
                end
                task.spawn(Callback)
            end)

            table.insert(TabObj.SearchItems, { Name = Name, Instance = card })
            return card
        end

        -- COMPONENTE: SEÇÃO
        function TabObj:CreateSection(secConfig)
            local titleText = type(secConfig) == "string" and secConfig or (secConfig.Name or "Seção")
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -15, 0, 25)
            Label.BackgroundTransparency = 1
            Label.Text = titleText
            Label.TextColor3 = PrimaryColor
            Label.TextSize = 14
            Label.Font = Enum.Font.GothamBold
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = TabPage

            return Label
        end

        -- COMPONENTE: TOGGLE
        function TabObj:CreateToggle(tglConfig)
            tglConfig = tglConfig or {}
            local Name = tglConfig.Name or "Toggle"
            local State = tglConfig.Default or false
            local Tag = tglConfig.Tag
            local Callback = tglConfig.Callback or function() end

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -15, 0, 44)
            Frame.BackgroundColor3 = Color3.fromRGB(16, 17, 26)
            Frame.ClipsDescendants = true
            Frame.Parent = TabPage
            AddCorner(Frame, 8)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -140, 1, 0)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = Name
            Label.TextColor3 = Color3.fromRGB(235, 235, 240)
            Label.TextSize = 13
            Label.Font = Enum.Font.GothamSemibold
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            if Tag then CreateBadge(Frame, Tag, UDim2.new(1, -65, 0.5, -9)) end

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
                if Tag == "BLOQUEADO" or Tag == "REMOVIDO" then
                    AbsoluteLib:Notify({ Title = "Opção Indisponível", Content = "Esta opção foi " .. string.lower(Tag) .. "!", Duration = 2 })
                    return
                end
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
            local Tag = btnConfig.Tag
            local Callback = btnConfig.Callback or function() end

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, -15, 0, 42)
            Btn.BackgroundColor3 = Color3.fromRGB(24, 26, 38)
            Btn.Text = "   " .. Name
            Btn.TextColor3 = NeonWhite
            Btn.TextSize = 13
            Btn.Font = Enum.Font.GothamSemibold
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.ClipsDescendants = true
            Btn.Parent = TabPage
            AddCorner(Btn, 8)

            if Tag then CreateBadge(Btn, Tag, UDim2.new(1, -12, 0.5, -9)) end

            Btn.MouseButton1Click:Connect(function()
                if Tag == "BLOQUEADO" or Tag == "REMOVIDO" then
                    AbsoluteLib:Notify({ Title = "Opção Indisponível", Content = "Esta função foi " .. string.lower(Tag) .. "!", Duration = 2 })
                    return
                end
                task.spawn(Callback)
            end)

            table.insert(TabObj.SearchItems, { Name = Name, Instance = Btn })
            return Btn
        end

        -- COMPONENTE: SLIDER
        function TabObj:CreateSlider(sliderConfig)
            sliderConfig = sliderConfig or {}
            local Name = sliderConfig.Name or "Slider"
            local Min = sliderConfig.Min or 0
            local Max = sliderConfig.Max or 100
            local Default = sliderConfig.Default or Min
            local Tag = sliderConfig.Tag
            local Callback = sliderConfig.Callback or function() end

            local Value = math.clamp(Default, Min, Max)

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -15, 0, 50)
            Frame.BackgroundColor3 = Color3.fromRGB(16, 17, 26)
            Frame.ClipsDescendants = true
            Frame.Parent = TabPage
            AddCorner(Frame, 8)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -180, 0, 20)
            Label.Position = UDim2.new(0, 15, 0, 8)
            Label.BackgroundTransparency = 1
            Label.Text = Name
            Label.TextColor3 = Color3.fromRGB(235, 235, 240)
            Label.TextSize = 13
            Label.Font = Enum.Font.GothamSemibold
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            if Tag then CreateBadge(Frame, Tag, UDim2.new(1, -95, 0, 9)) end

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 80, 0, 20)
            ValueLabel.Position = UDim2.new(1, -95, 0, 8)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(Value)
            ValueLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
            ValueLabel.TextSize = 12
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = Frame

            local SliderTrack = Instance.new("TextButton")
            SliderTrack.Size = UDim2.new(1, -30, 0, 6)
            SliderTrack.Position = UDim2.new(0, 15, 0, 34)
            SliderTrack.BackgroundColor3 = Color3.fromRGB(35, 36, 48)
            SliderTrack.Text = ""
            SliderTrack.Parent = Frame
            AddCorner(SliderTrack, 3)

            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0)
            SliderFill.BackgroundColor3 = PrimaryColor
            SliderFill.Parent = SliderTrack
            AddCorner(SliderFill, 3)

            local function UpdateSlider(input)
                if Tag == "BLOQUEADO" or Tag == "REMOVIDO" then return end
                local percent = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                Value = math.floor(Min + (Max - Min) * percent)
                ValueLabel.Text = tostring(Value)
                SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                task.spawn(Callback, Value)
            end

            local isSliderDragging = false
            SliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isSliderDragging = true
                    UpdateSlider(input)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if isSliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isSliderDragging = false
                end
            end)

            local function SetValue(newVal)
                Value = math.clamp(newVal, Min, Max)
                local percent = (Value - Min) / (Max - Min)
                ValueLabel.Text = tostring(Value)
                SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                task.spawn(Callback, Value)
            end

            table.insert(TabObj.SearchItems, { Name = Name, Instance = Frame })
            return { Set = SetValue, Get = function() return Value end }
        end

        -- COMPONENTE: DROPDOWN
        function TabObj:CreateDropdown(dropConfig)
            dropConfig = dropConfig or {}
            local Name = dropConfig.Name or "Dropdown"
            local Options = dropConfig.Options or {}
            local CurrentOption = dropConfig.Default or Options[1] or ""
            local Tag = dropConfig.Tag
            local Callback = dropConfig.Callback or function() end

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -15, 0, 44)
            Frame.BackgroundColor3 = Color3.fromRGB(16, 17, 26)
            Frame.ClipsDescendants = true
            Frame.Parent = TabPage
            AddCorner(Frame, 8)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -220, 0, 44)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = Name
            Label.TextColor3 = Color3.fromRGB(235, 235, 240)
            Label.TextSize = 13
            Label.Font = Enum.Font.GothamSemibold
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            if Tag then CreateBadge(Frame, Tag, UDim2.new(1, -150, 0.5, -9)) end

            local DropButton = Instance.new("TextButton")
            DropButton.Size = UDim2.new(0, 130, 0, 28)
            DropButton.Position = UDim2.new(1, -140, 0, 8)
            DropButton.BackgroundColor3 = Color3.fromRGB(28, 30, 42)
            DropButton.Text = tostring(CurrentOption) .. "  ▼"
            DropButton.TextColor3 = NeonWhite
            DropButton.TextSize = 11
            DropButton.Font = Enum.Font.Gotham
            DropButton.Parent = Frame
            AddCorner(DropButton, 6)

            local OptionsContainer = Instance.new("Frame")
            OptionsContainer.Size = UDim2.new(1, -30, 0, 0)
            OptionsContainer.Position = UDim2.new(0, 15, 0, 48)
            OptionsContainer.BackgroundTransparency = 1
            OptionsContainer.Parent = Frame

            local OptLayout = Instance.new("UIListLayout")
            OptLayout.Padding = UDim.new(0, 4)
            OptLayout.Parent = OptionsContainer

            local isOpen = false
            local function ToggleDrop()
                if Tag == "BLOQUEADO" or Tag == "REMOVIDO" then
                    AbsoluteLib:Notify({ Title = "Opção Indisponível", Content = "Esta opção está " .. string.lower(Tag) .. "!", Duration = 2 })
                    return
                end
                isOpen = not isOpen
                local targetHeight = isOpen and (50 + #Options * 28) or 44
                Tween(Frame, {0.25, Enum.EasingStyle.Quart}, {Size = UDim2.new(1, -15, 0, targetHeight)})
            end

            local function SelectOption(opt)
                CurrentOption = opt
                DropButton.Text = tostring(opt) .. "  ▼"
                ToggleDrop()
                task.spawn(Callback, CurrentOption)
            end

            for _, opt in ipairs(Options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 24)
                OptBtn.BackgroundColor3 = Color3.fromRGB(24, 25, 35)
                OptBtn.Text = tostring(opt)
                OptBtn.TextColor3 = Color3.fromRGB(200, 200, 215)
                OptBtn.TextSize = 11
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.Parent = OptionsContainer
                AddCorner(OptBtn, 4)

                OptBtn.MouseButton1Click:Connect(function() SelectOption(opt) end)
            end

            DropButton.MouseButton1Click:Connect(ToggleDrop)

            table.insert(TabObj.SearchItems, { Name = Name, Instance = Frame })
            return {
                Set = function(opt) SelectOption(opt) end,
                Get = function() return CurrentOption end
            }
        end

        -- COMPONENTE: TEXTBOX
        function TabObj:CreateTextBox(inputConfig)
            inputConfig = inputConfig or {}
            local Name = inputConfig.Name or "Input"
            local Placeholder = inputConfig.Placeholder or "Digite aqui..."
            local Tag = inputConfig.Tag
            local Callback = inputConfig.Callback or function() end

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -15, 0, 44)
            Frame.BackgroundColor3 = Color3.fromRGB(16, 17, 26)
            Frame.ClipsDescendants = true
            Frame.Parent = TabPage
            AddCorner(Frame, 8)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -220, 1, 0)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = Name
            Label.TextColor3 = Color3.fromRGB(235, 235, 240)
            Label.TextSize = 13
            Label.Font = Enum.Font.GothamSemibold
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            if Tag then CreateBadge(Frame, Tag, UDim2.new(1, -160, 0.5, -9)) end

            local Box = Instance.new("TextBox")
            Box.Size = UDim2.new(0, 140, 0, 26)
            Box.Position = UDim2.new(1, -150, 0.5, -13)
            Box.BackgroundColor3 = Color3.fromRGB(28, 30, 42)
            Box.PlaceholderText = Placeholder
            Box.PlaceholderColor3 = Color3.fromRGB(90, 90, 110)
            Box.Text = ""
            Box.TextColor3 = NeonWhite
            Box.TextSize = 12
            Box.Font = Enum.Font.Gotham
            Box.Parent = Frame
            AddCorner(Box, 6)

            Box.FocusLost:Connect(function(enterPressed)
                if Tag == "BLOQUEADO" or Tag == "REMOVIDO" then return end
                task.spawn(Callback, Box.Text, enterPressed)
            end)

            table.insert(TabObj.SearchItems, { Name = Name, Instance = Frame })
            return {
                Set = function(txt) Box.Text = txt end,
                Get = function() return Box.Text end
            }
        end

        -- COMPONENTE: KEYBIND
        function TabObj:CreateKeybind(kbConfig)
            kbConfig = kbConfig or {}
            local Name = kbConfig.Name or "Keybind"
            local CurrentKey = kbConfig.Default or Enum.KeyCode.E
            local Tag = kbConfig.Tag
            local Callback = kbConfig.Callback or function() end

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -15, 0, 44)
            Frame.BackgroundColor3 = Color3.fromRGB(16, 17, 26)
            Frame.ClipsDescendants = true
            Frame.Parent = TabPage
            AddCorner(Frame, 8)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -200, 1, 0)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = Name
            Label.TextColor3 = Color3.fromRGB(235, 235, 240)
            Label.TextSize = 13
            Label.Font = Enum.Font.GothamSemibold
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            if Tag then CreateBadge(Frame, Tag, UDim2.new(1, -135, 0.5, -9)) end

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
                if Tag == "BLOQUEADO" or Tag == "REMOVIDO" then return end
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
