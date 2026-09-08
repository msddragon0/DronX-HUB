-- ============================================================
-- DRONX HUB – Interface W-Azure com funcionalidades de farm
-- ============================================================

print("[DRONX] Carregando...")

-- ====== CONFIGURAÇÕES GLOBAIS ======
getgenv().DRONX = getgenv().DRONX or {
    Running = false,
    AutoFarm = false,
    FarmMaestria = false,
    AutoCollect = false,
    AutoHeal = false,
    AttackDistance = 40,
    AutoBoss = false,
    BossName = "",
}

-- ====== OBTÉM JOGADOR ======
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- ====== FUNÇÕES AUXILIARES ======
local function getClosestNPC(levelMin, levelMax, distance)
    local closest = nil
    local minDist = math.huge
    for _, npc in pairs(workspace.Enemies:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
            local npcLevel = npc:FindFirstChild("Level") and npc.Level.Value or 0
            if npcLevel >= levelMin and npcLevel <= levelMax then
                local dist = (rootPart.Position - npc.HumanoidRootPart.Position).Magnitude
                if dist < minDist and dist <= distance then
                    minDist = dist
                    closest = npc
                end
            end
        end
    end
    return closest
end

local function attackNPC(npc)
    if not npc or not npc:FindFirstChild("Humanoid") or npc.Humanoid.Health <= 0 then return end
    rootPart.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
    task.wait(0.1)
    game:GetService("VirtualInputManager"):SendKeyEvent(true, "Q", false, game)
    task.wait(0.1)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, "Q", false, game)
end

local function collectItems()
    for _, item in pairs(workspace.DroppedItems:GetChildren()) do
        if item:IsA("Model") and item:FindFirstChild("Handle") then
            if (rootPart.Position - item.Handle.Position).Magnitude < 15 then
                fireclickdetector(item.Handle.ClickDetector)
            end
        end
    end
end

local function autoHeal()
    if humanoid.Health / humanoid.MaxHealth < 0.3 then
        local potion = player.Backpack:FindFirstChild("Potion") or character:FindFirstChild("Potion")
        if potion then potion.Activate:FireServer() end
    end
end

-- ====== LOOP PRINCIPAL (FARM) ======
coroutine.wrap(function()
    while true do
        task.wait()
        local drx = getgenv().DRONX
        if drx.Running then
            if drx.AutoFarm or drx.FarmMaestria then
                local npc = getClosestNPC(player.Data.Level.Value - 5, player.Data.Level.Value + 10, drx.AttackDistance or 40)
                if npc then attackNPC(npc) end
            end
            if drx.AutoCollect then collectItems() end
            if drx.AutoHeal then autoHeal() end
        end
    end
end)()

-- ====== GUI VISUAL W-AZURE ======
local function criarGUI()
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
        red = Color3.fromRGB(255, 70, 70),
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
        Name = "DRONX_GUI",
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

    -- ====== TOP BAR ======
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
    local logoText = label(logo, "D", 21, COLORS.white, Enum.Font.GothamBold)
    logoText.TextXAlignment = Enum.TextXAlignment.Center
    logoText.Size = UDim2.fromScale(1, 1)

    local title = label(topBar, "DRONX HUB", 17, COLORS.white, Enum.Font.GothamBold)
    title.Position = UDim2.new(0, 70, 0, 13)
    title.Size = UDim2.new(0, 250, 0, 22)

    local subtitle = label(topBar, "BLOX FRUITS", 10, COLORS.cyan, Enum.Font.GothamMedium)
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
    closeButton.MouseButton1Click:Connect(function() overlay.Visible = false end)

    -- ====== SIDEBAR ======
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

    -- ====== CONTEÚDO ======
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

    -- ====== PÁGINAS ======
    local pages = {}
    local navButtons = {}
    local tabNames = {"Farm", "Maestria", "Boss", "Config"}
    local tabSymbols = {"⚔", "🗡", "👹", "⚙"}

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

    -- ====== FOOTER ======
    local footer = label(sidebar, "v1.0.0  •  DRONX", 9, COLORS.muted, Enum.Font.GothamMedium)
    footer.AnchorPoint = Vector2.new(0, 1)
    footer.Position = UDim2.new(0, 13, 1, -13)
    footer.Size = UDim2.new(1, -20, 0, 18)

    -- ====== FUNÇÃO PARA CRIAR TOGGLE ======
    local function createToggle(parent, titleText, description, varName, defaultValue)
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

        local enabled = defaultValue or false

        -- Atualiza estado inicial
        if getgenv().DRONX[varName] ~= nil then
            enabled = getgenv().DRONX[varName]
        end

        -- Atualiza o toggle visual
        local function updateToggle()
            toggle.BackgroundColor3 = enabled and COLORS.blue or COLORS.background
            knob.Position = enabled and UDim2.new(1, -21, 0.5, -8) or UDim2.new(0, 5, 0.5, -8)
            getgenv().DRONX[varName] = enabled
        end
        updateToggle()

        toggle.MouseButton1Click:Connect(function()
            enabled = not enabled
            TweenService:Create(toggle, TweenInfo.new(0.18), {
                BackgroundColor3 = enabled and COLORS.blue or COLORS.background,
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.18), {
                Position = enabled and UDim2.new(1, -21, 0.5, -8) or UDim2.new(0, 5, 0.5, -8),
            }):Play()
            getgenv().DRONX[varName] = enabled
        end)

        return row
    end

    -- ====== FUNÇÃO PARA CRIAR BOTÃO ======
    local function createButton(parent, text, color, callback)
        local btn = create("TextButton", {
            BackgroundColor3 = color or COLORS.blue,
            Size = UDim2.new(1, 0, 0, 42),
            Text = text,
            TextColor3 = COLORS.white,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false,
        }, parent)
        corner(btn, 7)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = color and Color3.new(color.r*0.8, color.g*0.8, color.b*0.8) or COLORS.blueDark}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = color or COLORS.blue}):Play()
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    -- ====== PÁGINA FARM ======
    local farmPage = createPage("Farm")
    local farmTitle = label(farmPage, "Farm", 25, COLORS.white, Enum.Font.GothamBold)
    farmTitle.Size = UDim2.new(1, 0, 0, 33)
    local farmSub = label(farmPage, "Automação para farm de NPCs.", 12, COLORS.muted, Enum.Font.Gotham)
    farmSub.Size = UDim2.new(1, 0, 0, 21)

    createToggle(farmPage, "Auto Farm", "Ataca automaticamente NPCs próximos.", "AutoFarm", false)
    createToggle(farmPage, "Auto Coletar Itens", "Coleta itens do chão automaticamente.", "AutoCollect", false)
    createToggle(farmPage, "Cura Automática", "Usa poção quando a vida está baixa.", "AutoHeal", false)

    local btnIniciar = createButton(farmPage, "▶ INICIAR", COLORS.green, function()
        local running = not getgenv().DRONX.Running
        getgenv().DRONX.Running = running
        btnIniciar.Text = running and "⏹ PARAR" or "▶ INICIAR"
        btnIniciar.BackgroundColor3 = running and COLORS.red or COLORS.green
    end)

    -- ====== PÁGINA MAESTRIA ======
    local maestriaPage = createPage("Maestria")
    local maestriaTitle = label(maestriaPage, "Maestria", 25, COLORS.white, Enum.Font.GothamBold)
    maestriaTitle.Size = UDim2.new(1, 0, 0, 33)
    local maestriaSub = label(maestriaPage, "Farm de maestria para armas e frutas.", 12, COLORS.muted, Enum.Font.Gotham)
    maestriaSub.Size = UDim2.new(1, 0, 0, 21)

    createToggle(maestriaPage, "Farm Maestria", "Ataca NPCs para ganhar maestria.", "FarmMaestria", false)
    createToggle(maestriaPage, "Usar Habilidade", "Usa habilidades da fruta (Z e X).", "UseFruitSkill", false)

    -- ====== PÁGINA BOSS ======
    local bossPage = createPage("Boss")
    local bossTitle = label(bossPage, "Boss", 25, COLORS.white, Enum.Font.GothamBold)
    bossTitle.Size = UDim2.new(1, 0, 0, 33)
    local bossSub = label(bossPage, "Caça a bosses específicos.", 12, COLORS.muted, Enum.Font.Gotham)
    bossSub.Size = UDim2.new(1, 0, 0, 21)

    -- Campo para nome do boss
    local bossInput = create("TextBox", {
        BackgroundColor3 = COLORS.panelLight,
        Size = UDim2.new(1, 0, 0, 40),
        PlaceholderText = "Digite o nome do Boss...",
        TextColor3 = COLORS.white,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
    }, bossPage)
    corner(bossInput, 8)
    stroke(bossInput, COLORS.border, 1)

    createToggle(bossPage, "Auto Boss", "Caça automaticamente o boss selecionado.", "AutoBoss", false)

    local btnBoss = createButton(bossPage, "CAÇAR BOSS", COLORS.blue, function()
        local nome = bossInput.Text
        if nome == "" then
            -- Notificação visual
            return
        end
        getgenv().DRONX.BossName = nome
        getgenv().DRONX.AutoBoss = true
    end)

    -- ====== PÁGINA CONFIG ======
    local configPage = createPage("Config")
    local configTitle = label(configPage, "Configurações", 25, COLORS.white, Enum.Font.GothamBold)
    configTitle.Size = UDim2.new(1, 0, 0, 33)
    local configSub = label(configPage, "Ajustes globais do hub.", 12, COLORS.muted, Enum.Font.Gotham)
    configSub.Size = UDim2.new(1, 0, 0, 21)

    -- Distância de ataque (slider visual)
    local distRow = create("Frame", {
        BackgroundColor3 = COLORS.panelLight,
        Size = UDim2.new(1, 0, 0, 50),
    }, configPage)
    corner(distRow, 8)
    stroke(distRow, COLORS.border, 1)
    local distLabel = label(distRow, "Distância de ataque: " .. (getgenv().DRONX.AttackDistance or 40), 13, COLORS.white, Enum.Font.GothamMedium)
    distLabel.Position = UDim2.new(0, 17, 0.5, -10)
    distLabel.Size = UDim2.new(0.6, 0, 0, 20)

    local function updateDistLabel(val)
        distLabel.Text = "Distância de ataque: " .. val
        getgenv().DRONX.AttackDistance = val
    end

    local decBtn = create("TextButton", {
        BackgroundColor3 = COLORS.panelHover,
        Position = UDim2.new(0.75, 0, 0.5, -14),
        Size = UDim2.fromOffset(30, 28),
        Text = "−",
        TextColor3 = COLORS.white,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
    }, distRow)
    corner(decBtn, 6)
    decBtn.MouseButton1Click:Connect(function()
        local val = math.max(10, (getgenv().DRONX.AttackDistance or 40) - 5)
        updateDistLabel(val)
    end)

    local incBtn = create("TextButton", {
        BackgroundColor3 = COLORS.panelHover,
        Position = UDim2.new(0.85, 0, 0.5, -14),
        Size = UDim2.fromOffset(30, 28),
        Text = "+",
        TextColor3 = COLORS.white,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
    }, distRow)
    corner(incBtn, 6)
    incBtn.MouseButton1Click:Connect(function()
        local val = math.min(80, (getgenv().DRONX.AttackDistance or 40) + 5)
        updateDistLabel(val)
    end)

    -- ====== ATALHO PARA ABRIR/FECHAR ======
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightShift then
            overlay.Visible = not overlay.Visible
        end
    end)

    -- ====== ANIMAÇÃO DE ENTRADA ======
    main.Position = UDim2.fromScale(0.5, 0.54)
    main.Size = UDim2.new(0.74, 0, 0.68, 0)
    TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0.78, 0, 0.72, 0),
    }):Play()

    -- ====== ATIVA A PÁGINA INICIAL ======
    setActiveTab("Farm")

    print("[DRONX] GUI carregada com sucesso! Pressione RightShift para abrir/fechar.")
end

pcall(criarGUI)
