--[=[
    W-Azure Inspired GUI
    Interface visual para Roblox Studio
    Coloque este LocalScript em StarterPlayer > StarterPlayerScripts

    Observação: esta interface é apenas visual/demonstrativa.
    Os botões e toggles não executam automações.
]=]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local COLORS = {
    background = Color3.fromRGB(10, 14, 24),
    panel = Color3.fromRGB(16, 22, 36),
    panelLight = Color3.fromRGB(22, 30, 48),
    panelHover = Color3.fromRGB(29, 39, 61),
    blue = Color3.fromRGB(61, 151, 255),
    blueDark = Color3.fromRGB(31, 92, 173),
    cyan = Color3.fromRGB(72, 215, 255),
    white = Color3.fromRGB(239, 244, 255),
    muted = Color3.fromRGB(144, 158, 185),
    border = Color3.fromRGB(44, 59, 88),
    green = Color3.fromRGB(76, 211, 141),
}

local function create(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function corner(parent, radius)
    return create("UICorner", {CornerRadius = UDim.new(0, radius or 8)}, parent)
end

local function stroke(parent, color, thickness, transparency)
    return create("UIStroke", {
        Color = color or COLORS.border,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
    }, parent)
end

local function label(parent, text, size, color, font)
    return create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = color or COLORS.white,
        TextSize = size or 14,
        Font = font or Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, parent)
end

local screenGui = create("ScreenGui", {
    Name = "AzureInspiredGUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
}, playerGui)

local overlay = create("Frame", {
    Name = "Overlay",
    BackgroundColor3 = COLORS.background,
    BackgroundTransparency = 0.18,
    Size = UDim2.fromScale(1, 1),
}, screenGui)

local main = create("Frame", {
    Name = "MainWindow",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0.78, 0, 0.72, 0),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, overlay)
corner(main, 12)
stroke(main, COLORS.border, 1)

local sizeConstraint = create("UISizeConstraint", {
    MinSize = Vector2.new(610, 390),
    MaxSize = Vector2.new(1050, 680),
}, main)

local topBar = create("Frame", {
    Name = "TopBar",
    BackgroundColor3 = COLORS.panelLight,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 68),
}, main)

local accent = create("Frame", {
    BackgroundColor3 = COLORS.blue,
    BorderSizePixel = 0,
    Size = UDim2.new(0, 4, 1, 0),
}, topBar)

local logo = create("Frame", {
    BackgroundColor3 = COLORS.blueDark,
    Position = UDim2.new(0, 22, 0.5, -18),
    Size = UDim2.fromOffset(36, 36),
}, topBar)
corner(logo, 10)
local logoText = label(logo, "A", 21, COLORS.white, Enum.Font.GothamBold)
logoText.TextXAlignment = Enum.TextXAlignment.Center
logoText.Size = UDim2.fromScale(1, 1)

local title = label(topBar, "AZURE HUB", 17, COLORS.white, Enum.Font.GothamBold)
title.Position = UDim2.new(0, 70, 0, 13)
title.Size = UDim2.new(0, 250, 0, 22)

local subtitle = label(topBar, "CUSTOM INTERFACE", 10, COLORS.cyan, Enum.Font.GothamMedium)
subtitle.Position = UDim2.new(0, 71, 0, 37)
subtitle.Size = UDim2.new(0, 250, 0, 16)

local status = label(topBar, "●  ONLINE", 11, COLORS.green, Enum.Font.GothamMedium)
status.AnchorPoint = Vector2.new(1, 0.5)
status.Position = UDim2.new(1, -56, 0.5, 0)
status.Size = UDim2.fromOffset(100, 22)
status.TextXAlignment = Enum.TextXAlignment.Right

local closeButton = create("TextButton", {
    Name = "Close",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -17, 0.5, 0),
    Size = UDim2.fromOffset(27, 27),
    BackgroundColor3 = COLORS.panelHover,
    Text = "×",
    TextColor3 = COLORS.muted,
    TextSize = 21,
    Font = Enum.Font.GothamMedium,
    AutoButtonColor = false,
}, topBar)
corner(closeButton, 7)

local sidebar = create("Frame", {
    Name = "Sidebar",
    BackgroundColor3 = COLORS.background,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 68),
    Size = UDim2.new(0, 178, 1, -68),
}, main)

local sidePadding = create("UIPadding", {
    PaddingTop = UDim.new(0, 18),
    PaddingLeft = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 12),
}, sidebar)

local navLayout = create("UIListLayout", {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, sidebar)

local content = create("Frame", {
    Name = "Content",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 178, 0, 68),
    Size = UDim2.new(1, -178, 1, -68),
}, main)

local contentPadding = create("UIPadding", {
    PaddingTop = UDim.new(0, 24),
    PaddingLeft = UDim.new(0, 27),
    PaddingRight = UDim.new(0, 27),
    PaddingBottom = UDim.new(0, 20),
}, content)

local pages = {}
local navButtons = {}
local tabNames = {"Dashboard", "Visuals", "Layout", "Settings"}
local tabSymbols = {"⌂", "◈", "▦", "⚙"}

local function createPage(name)
    local page = create("ScrollingFrame", {
        Name = name .. "Page",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = COLORS.blue,
        Visible = false,
    }, content)
    local layout = create("UIListLayout", {
        Padding = UDim.new(0, 15),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, page)
    pages[name] = page
    return page
end

local function setActiveTab(name)
    for tabName, page in pairs(pages) do
        page.Visible = tabName == name
    end
    for tabName, button in pairs(navButtons) do
        local active = tabName == name
        button.BackgroundColor3 = active and COLORS.blueDark or COLORS.background
        button.TextColor3 = active and COLORS.white or COLORS.muted
        local bar = button:FindFirstChild("ActiveBar")
        if bar then bar.Visible = active end
    end
end

for index, name in ipairs(tabNames) do
    local button = create("TextButton", {
        Name = name .. "Tab",
        LayoutOrder = index,
        BackgroundColor3 = COLORS.background,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        Text = "  " .. tabSymbols[index] .. "    " .. name,
        TextColor3 = COLORS.muted,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
    }, sidebar)
    corner(button, 7)
    local activeBar = create("Frame", {
        Name = "ActiveBar",
        BackgroundColor3 = COLORS.cyan,
        Position = UDim2.new(0, 0, 0.5, -9),
        Size = UDim2.fromOffset(3, 18),
        Visible = false,
    }, button)
    corner(activeBar, 2)
    button.MouseEnter:Connect(function()
        if pages[name].Visible == false then
            TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.panelLight}):Play()
        end
    end)
    button.MouseLeave:Connect(function()
        if pages[name].Visible == false then
            TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.background}):Play()
        end
    end)
    button.MouseButton1Click:Connect(function()
        setActiveTab(name)
    end)
    navButtons[name] = button
end

local footer = label(sidebar, "v1.0.0  •  UI DEMO", 9, COLORS.muted, Enum.Font.GothamMedium)
footer.AnchorPoint = Vector2.new(0, 1)
footer.Position = UDim2.new(0, 13, 1, -13)
footer.Size = UDim2.new(1, -20, 0, 18)

local dashboard = createPage("Dashboard")

local welcome = label(dashboard, "Dashboard", 25, COLORS.white, Enum.Font.GothamBold)
welcome.Size = UDim2.new(1, 0, 0, 33)
local welcomeSub = label(dashboard, "Uma interface limpa para o seu próprio jogo.", 12, COLORS.muted, Enum.Font.Gotham)
welcomeSub.Size = UDim2.new(1, 0, 0, 21)

local hero = create("Frame", {
    BackgroundColor3 = COLORS.panelLight,
    Size = UDim2.new(1, 0, 0, 104),
}, dashboard)
corner(hero, 9)
stroke(hero, COLORS.border, 1)
local heroAccent = create("Frame", {
    BackgroundColor3 = COLORS.blue,
    Size = UDim2.new(0, 4, 1, 0),
}, hero)
corner(heroAccent, 2)
local heroTitle = label(hero, "Bem-vindo ao seu hub", 16, COLORS.white, Enum.Font.GothamBold)
heroTitle.Position = UDim2.new(0, 22, 0, 18)
heroTitle.Size = UDim2.new(1, -40, 0, 24)
local heroDesc = label(hero, "Este painel é somente visual e está pronto para receber as funções do seu game.", 11, COLORS.muted, Enum.Font.Gotham)
heroDesc.Position = UDim2.new(0, 22, 0, 50)
heroDesc.Size = UDim2.new(1, -40, 0, 35)
heroDesc.TextWrapped = true

local stats = create("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 84),
}, dashboard)
local statLayout = create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    Padding = UDim.new(0, 12),
}, stats)

local function createStat(parent, number, caption, color)
    local card = create("Frame", {
        BackgroundColor3 = COLORS.panelLight,
        Size = UDim2.new(0.333, -8, 1, 0),
    }, parent)
    corner(card, 8)
    stroke(card, COLORS.border, 1)
    local numberLabel = label(card, number, 20, color, Enum.Font.GothamBold)
    numberLabel.Position = UDim2.new(0, 14, 0, 13)
    numberLabel.Size = UDim2.new(1, -20, 0, 25)
    local captionLabel = label(card, caption, 10, COLORS.muted, Enum.Font.GothamMedium)
    captionLabel.Position = UDim2.new(0, 14, 0, 47)
    captionLabel.Size = UDim2.new(1, -20, 0, 18)
end

createStat(stats, "READY", "STATUS", COLORS.green)
createStat(stats, "04", "PÁGINAS", COLORS.cyan)
createStat(stats, "100%", "VISUAL", COLORS.blue)

local actionsTitle = label(dashboard, "Quick preview", 15, COLORS.white, Enum.Font.GothamBold)
actionsTitle.Size = UDim2.new(1, 0, 0, 23)

local actionCard = create("Frame", {
    BackgroundColor3 = COLORS.panelLight,
    Size = UDim2.new(1, 0, 0, 60),
}, dashboard)
corner(actionCard, 8)
stroke(actionCard, COLORS.border, 1)
local actionText = label(actionCard, "Design system", 13, COLORS.white, Enum.Font.GothamMedium)
actionText.Position = UDim2.new(0, 16, 0, 9)
actionText.Size = UDim2.new(0.6, 0, 0, 20)
local actionSub = label(actionCard, "Tema escuro  •  Azul Azure  •  Responsivo", 10, COLORS.muted, Enum.Font.Gotham)
actionSub.Position = UDim2.new(0, 16, 0, 31)
actionSub.Size = UDim2.new(0.7, 0, 0, 18)
local previewBadge = label(actionCard, "PREVIEW", 9, COLORS.cyan, Enum.Font.GothamBold)
previewBadge.AnchorPoint = Vector2.new(1, 0.5)
previewBadge.Position = UDim2.new(1, -17, 0.5, 0)
previewBadge.Size = UDim2.fromOffset(64, 20)
previewBadge.TextXAlignment = Enum.TextXAlignment.Right

local visuals = createPage("Visuals")
local visualsTitle = label(visuals, "Visuals", 25, COLORS.white, Enum.Font.GothamBold)
visualsTitle.Size = UDim2.new(1, 0, 0, 33)
local visualsSub = label(visuals, "Controles demonstrativos para o estilo visual do seu jogo.", 12, COLORS.muted, Enum.Font.Gotham)
visualsSub.Size = UDim2.new(1, 0, 0, 21)

local function createOption(parent, titleText, description, defaultValue)
    local row = create("Frame", {
        BackgroundColor3 = COLORS.panelLight,
        Size = UDim2.new(1, 0, 0, 64),
    }, parent)
    corner(row, 8)
    stroke(row, COLORS.border, 1)
    local optionTitle = label(row, titleText, 13, COLORS.white, Enum.Font.GothamMedium)
    optionTitle.Position = UDim2.new(0, 17, 0, 11)
    optionTitle.Size = UDim2.new(1, -100, 0, 20)
    local optionDesc = label(row, description, 10, COLORS.muted, Enum.Font.Gotham)
    optionDesc.Position = UDim2.new(0, 17, 0, 34)
    optionDesc.Size = UDim2.new(1, -100, 0, 17)

    local toggle = create("TextButton", {
        BackgroundColor3 = defaultValue and COLORS.blue or COLORS.background,
        Position = UDim2.new(1, -64, 0.5, -12),
        Size = UDim2.fromOffset(45, 24),
        Text = "",
        AutoButtonColor = false,
    }, row)
    corner(toggle, 12)
    stroke(toggle, COLORS.border, 1)
    local knob = create("Frame", {
        BackgroundColor3 = COLORS.white,
        Position = defaultValue and UDim2.new(1, -21, 0.5, -8) or UDim2.new(0, 5, 0.5, -8),
        Size = UDim2.fromOffset(16, 16),
    }, toggle)
    corner(knob, 8)
    local enabled = defaultValue
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        TweenService:Create(toggle, TweenInfo.new(0.18), {
            BackgroundColor3 = enabled and COLORS.blue or COLORS.background,
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.18), {
            Position = enabled and UDim2.new(1, -21, 0.5, -8) or UDim2.new(0, 5, 0.5, -8),
        }):Play()
    end)
end

createOption(visuals, "Glow effect", "Acento luminoso nos elementos do painel.", true)
createOption(visuals, "Compact mode", "Reduz o espaçamento interno da interface.", false)
createOption(visuals, "Show notifications", "Exibe avisos visuais no canto da tela.", true)

local layoutPage = createPage("Layout")
local layoutTitle = label(layoutPage, "Layout", 25, COLORS.white, Enum.Font.GothamBold)
layoutTitle.Size = UDim2.new(1, 0, 0, 33)
local layoutSub = label(layoutPage, "Organização dos componentes da interface.", 12, COLORS.muted, Enum.Font.Gotham)
layoutSub.Size = UDim2.new(1, 0, 0, 21)

local layoutCard = create("Frame", {
    BackgroundColor3 = COLORS.panelLight,
    Size = UDim2.new(1, 0, 0, 175),
}, layoutPage)
corner(layoutCard, 8)
stroke(layoutCard, COLORS.border, 1)
local layoutCardTitle = label(layoutCard, "Componentes disponíveis", 14, COLORS.white, Enum.Font.GothamBold)
layoutCardTitle.Position = UDim2.new(0, 18, 0, 16)
layoutCardTitle.Size = UDim2.new(1, -30, 0, 22)
local components = {"Tabs", "Cards", "Toggles", "Status badges", "Sidebar navigation", "Responsive window"}
for index, component in ipairs(components) do
    local col = (index - 1) % 2
    local row = math.floor((index - 1) / 2)
    local item = label(layoutCard, "✓  " .. component, 11, COLORS.muted, Enum.Font.GothamMedium)
    item.Position = UDim2.new(0, 20 + col * 170, 0, 52 + row * 31)
    item.Size = UDim2.fromOffset(160, 22)
end

local settings = createPage("Settings")
local settingsTitle = label(settings, "Settings", 25, COLORS.white, Enum.Font.GothamBold)
settingsTitle.Size = UDim2.new(1, 0, 0, 33)
local settingsSub = label(settings, "Preferências visuais do painel.", 12, COLORS.muted, Enum.Font.Gotham)
settingsSub.Size = UDim2.new(1, 0, 0, 21)
createOption(settings, "Interface enabled", "Mostra ou esconde o painel principal.", true)
createOption(settings, "Animated transitions", "Usa transições suaves entre páginas.", true)

local resetButton = create("TextButton", {
    BackgroundColor3 = COLORS.blueDark,
    Size = UDim2.new(1, 0, 0, 42),
    Text = "RESET VISUAL SETTINGS",
    TextColor3 = COLORS.white,
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
}, settings)
corner(resetButton, 7)
resetButton.MouseEnter:Connect(function()
    TweenService:Create(resetButton, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.blue}):Play()
end)
resetButton.MouseLeave:Connect(function()
    TweenService:Create(resetButton, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.blueDark}):Play()
end)

setActiveTab("Dashboard")

-- Janela arrastável pelo topo
local dragging = false
local dragStart
local startPosition

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

closeButton.MouseButton1Click:Connect(function()
    overlay.Visible = false
end)

-- Atalho visual para reabrir a interface: tecla RightShift
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        overlay.Visible = not overlay.Visible
    end
end)

-- Entrada suave
main.Position = UDim2.fromScale(0.5, 0.54)
main.Size = UDim2.new(0.74, 0, 0.68, 0)
TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0.78, 0, 0.72, 0),
}):Play()

print("AzureInspiredGUI carregada com sucesso. Pressione RightShift para abrir/fechar.")
