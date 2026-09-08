-- ============================================================
-- DRONX – GUI com seta expandir/colapsar e abas
-- ============================================================

print("[DRONX] Carregando...")

-- ====== CONFIGURAÇÕES ======
getgenv().DRONX = {
    Running = false,
    AutoFarm = false,
    AutoCollect = false,
    AutoHeal = false,
    FarmMaestria = false,
    AutoBoss = false,
    BossName = "",
    AttackDistance = 40
}

-- ====== OBTÉM JOGADOR ======
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- ====== FUNÇÕES DO FARM ======
local function getClosestNPC()
    local closest = nil
    local minDist = math.huge
    local level = player.Data.Level.Value
    for _, npc in pairs(workspace.Enemies:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
            local npcLevel = npc:FindFirstChild("Level") and npc.Level.Value or 0
            if npcLevel >= level - 5 and npcLevel <= level + 10 then
                local dist = (rootPart.Position - npc.HumanoidRootPart.Position).Magnitude
                if dist < minDist and dist <= getgenv().DRONX.AttackDistance then
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

-- ====== LOOP PRINCIPAL ======
coroutine.wrap(function()
    while true do
        task.wait()
        local drx = getgenv().DRONX
        if drx.Running then
            if drx.AutoFarm or drx.FarmMaestria then
                local npc = getClosestNPC()
                if npc then attackNPC(npc) end
            end
            if drx.AutoCollect then collectItems() end
            if drx.AutoHeal then autoHeal() end
        end
    end
end)()

-- ====== CRIAÇÃO DA GUI ======
local function criarGUI()
    local guiParent = game:GetService("CoreGui") or player:WaitForChild("PlayerGui")
    if not guiParent then return warn("[DRONX] Sem pai") end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DRONX_GUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = guiParent

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
        gold = Color3.fromRGB(255, 215, 0),
    }

    local function corner(parent, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 8)
        c.Parent = parent
    end

    local function stroke(parent, color, thickness)
        local s = Instance.new("UIStroke")
        s.Color = color or COLORS.border
        s.Thickness = thickness or 1
        s.Parent = parent
    end

    local function label(parent, text, size, color, font, align)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = color or COLORS.white
        l.TextSize = size or 14
        l.Font = font or Enum.Font.Gotham
        l.TextXAlignment = align or Enum.TextXAlignment.Left
        l.TextYAlignment = Enum.TextYAlignment.Center
        l.Parent = parent
        return l
    end

    -- ====== JANELA PRINCIPAL (MAIOR) ======
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 480, 0, 520)
    main.Position = UDim2.new(0.5, -240, 0.5, -260)
    main.BackgroundColor3 = COLORS.panel
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Active = true
    main.Draggable = true
    main.Parent = screenGui
    corner(main, 12)
    stroke(main, COLORS.border, 1)

    -- ====== TOP BAR ======
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 50)
    topBar.BackgroundColor3 = COLORS.panelLight
    topBar.BorderSizePixel = 0
    topBar.Parent = main

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = COLORS.blue
    accent.BorderSizePixel = 0
    accent.Parent = topBar

    local logo = Instance.new("Frame")
    logo.Size = UDim2.new(0, 32, 0, 32)
    logo.Position = UDim2.new(0, 14, 0.5, -16)
    logo.BackgroundColor3 = COLORS.blueDark
    logo.Parent = topBar
    corner(logo, 8)

    local logoText = label(logo, "D", 18, COLORS.white, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    logoText.Size = UDim2.fromScale(1, 1)

    local title = label(topBar, "DRONX", 18, COLORS.white, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
    title.Position = UDim2.new(0, 56, 0, 8)
    title.Size = UDim2.new(0, 160, 0, 22)

    local subtitle = label(topBar, "FARM CONTROLS", 10, COLORS.cyan, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
    subtitle.Position = UDim2.new(0, 56, 0, 30)
    subtitle.Size = UDim2.new(0, 160, 0, 16)

    -- Status online
    local statusLabel = label(topBar, "●  ONLINE", 11, COLORS.green, Enum.Font.GothamMedium, Enum.TextXAlignment.Right)
    statusLabel.AnchorPoint = Vector2.new(1, 0.5)
    statusLabel.Position = UDim2.new(1, -50, 0.5, 0)
    statusLabel.Size = UDim2.fromOffset(90, 22)

    -- Botão fechar
    local closeBtn = Instance.new("TextButton")
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.Position = UDim2.new(1, -14, 0.5, 0)
    closeBtn.Size = UDim2.fromOffset(24, 24)
    closeBtn.BackgroundColor3 = COLORS.panelHover
    closeBtn.Text = "×"
    closeBtn.TextColor3 = COLORS.muted
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamMedium
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = topBar
    corner(closeBtn, 6)
    closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

    -- ====== BOTÃO EXPANDIR (SETA) ======
    local expandida = false
    local expandBtn = Instance.new("TextButton")
    expandBtn.AnchorPoint = Vector2.new(1, 0.5)
    expandBtn.Position = UDim2.new(1, -42, 0.5, 0)
    expandBtn.Size = UDim2.fromOffset(24, 24)
    expandBtn.BackgroundColor3 = COLORS.panelHover
    expandBtn.Text = "▼"
    expandBtn.TextColor3 = COLORS.white
    expandBtn.TextSize = 16
    expandBtn.Font = Enum.Font.GothamBold
    expandBtn.AutoButtonColor = false
    expandBtn.Parent = topBar
    corner(expandBtn, 6)

    -- ====== CONTEÚDO (SCROLLING FRAME) ======
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -24, 1, -64)
    content.Position = UDim2.new(0, 12, 0, 58)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = COLORS.blue
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Parent = main

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = content

    -- ====== FUNÇÃO CHECKBOX TOGGLE ======
    local function createToggle(parent, text, var)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 34)
        frame.BackgroundColor3 = COLORS.panelLight
        frame.Parent = parent
        corner(frame, 6)
        stroke(frame, COLORS.border, 1)

        local lbl = label(frame, text, 13, COLORS.white, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
        lbl.Position = UDim2.new(0, 14, 0, 0)
        lbl.Size = UDim2.new(0.6, 0, 1, 0)

        local toggleBtn = Instance.new("TextButton")
        toggleBtn.AnchorPoint = Vector2.new(1, 0.5)
        toggleBtn.Position = UDim2.new(1, -14, 0.5, 0)
        toggleBtn.Size = UDim2.fromOffset(40, 20)
        toggleBtn.BackgroundColor3 = getgenv().DRONX[var] and COLORS.blue or COLORS.background
        toggleBtn.Text = ""
        toggleBtn.AutoButtonColor = false
        toggleBtn.Parent = frame
        corner(toggleBtn, 10)
        stroke(toggleBtn, COLORS.border, 1)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(14, 14)
        knob.Position = getgenv().DRONX[var] and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7)
        knob.BackgroundColor3 = COLORS.white
        knob.Parent = toggleBtn
        corner(knob, 7)

        toggleBtn.MouseButton1Click:Connect(function()
            local state = not getgenv().DRONX[var]
            getgenv().DRONX[var] = state
            toggleBtn.BackgroundColor3 = state and COLORS.blue or COLORS.background
            knob.Position = state and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7)
        end)
        return frame
    end

    -- ====== FUNÇÃO CRIAR CATEGORIA ======
    local function criarCategoria(parent, titulo, icone)
        local secao = Instance.new("Frame")
        secao.Size = UDim2.new(1, 0, 0, 0)
        secao.BackgroundTransparency = 1
        secao.Parent = parent

        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 32)
        header.BackgroundColor3 = COLORS.panelLight
        header.Parent = secao
        corner(header, 6)
        stroke(header, COLORS.border, 1)

        local headerLabel = label(header, icone .. " " .. titulo, 13, COLORS.white, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
        headerLabel.Position = UDim2.new(0, 14, 0, 0)
        headerLabel.Size = UDim2.new(0.8, 0, 1, 0)

        local toggleHeader = Instance.new("TextButton")
        toggleHeader.Size = UDim2.new(1, 0, 1, 0)
        toggleHeader.BackgroundTransparency = 1
        toggleHeader.Parent = header

        local corpo = Instance.new("Frame")
        corpo.Size = UDim2.new(1, 0, 0, 0)
        corpo.BackgroundTransparency = 1
        corpo.Parent = secao

        local corpoLayout = Instance.new("UIListLayout")
        corpoLayout.Padding = UDim.new(0, 6)
        corpoLayout.SortOrder = Enum.SortOrder.LayoutOrder
        corpoLayout.Parent = corpo

        local expandido = false

        toggleHeader.MouseButton1Click:Connect(function()
            expandido = not expandido
            corpo.Visible = expandido
            headerLabel.Text = (expandido and "▼ " or "▶ ") .. icone .. " " .. titulo
        end)

        -- Começa expandido
        expandido = true
        corpo.Visible = true
        headerLabel.Text = "▼ " .. icone .. " " .. titulo

        return secao, corpo
    end

    -- ====== CATEGORIA: FARM ======
    local farmSec, farmCorpo = criarCategoria(content, "Farm", "⚔️")
    createToggle(farmCorpo, "Auto Farm", "AutoFarm")
    createToggle(farmCorpo, "Farm Maestria", "FarmMaestria")
    createToggle(farmCorpo, "Auto Coletar Itens", "AutoCollect")
    createToggle(farmCorpo, "Cura Automática", "AutoHeal")

    -- ====== CATEGORIA: BOSS ======
    local bossSec, bossCorpo = criarCategoria(content, "Boss", "👹")
    local bossInput = Instance.new("TextBox")
    bossInput.Size = UDim2.new(1, 0, 0, 34)
    bossInput.Position = UDim2.new(0, 0, 0, 0)
    bossInput.BackgroundColor3 = COLORS.panelLight
    bossInput.TextColor3 = COLORS.white
    bossInput.TextSize = 14
    bossInput.Font = Enum.Font.Gotham
    bossInput.PlaceholderText = "Nome do Boss (ex: Don Swan)"
    bossInput.Parent = bossCorpo
    corner(bossInput, 6)
    stroke(bossInput, COLORS.border, 1)

    createToggle(bossCorpo, "Auto Boss", "AutoBoss")

    -- ====== CATEGORIA: TELEPORT ======
    local teleSec, teleCorpo = criarCategoria(content, "Teleport", "📍")

    local coordInput = Instance.new("TextBox")
    coordInput.Size = UDim2.new(1, 0, 0, 34)
    coordInput.BackgroundColor3 = COLORS.panelLight
    coordInput.TextColor3 = COLORS.white
    coordInput.TextSize = 14
    coordInput.Font = Enum.Font.Gotham
    coordInput.PlaceholderText = "X, Y, Z (ex: 100, 50, 200)"
    coordInput.Parent = teleCorpo
    corner(coordInput, 6)
    stroke(coordInput, COLORS.border, 1)

    local teleBtn = Instance.new("TextButton")
    teleBtn.Size = UDim2.new(0.5, 0, 0, 34)
    teleBtn.Position = UDim2.new(0.25, 0, 0, 0)
    teleBtn.BackgroundColor3 = COLORS.blue
    teleBtn.Text = "TELEPORTAR"
    teleBtn.TextColor3 = COLORS.white
    teleBtn.TextSize = 14
    teleBtn.Font = Enum.Font.GothamBold
    teleBtn.AutoButtonColor = false
    teleBtn.Parent = teleCorpo
    corner(teleBtn, 6)

    teleBtn.MouseButton1Click:Connect(function()
        local coords = coordInput.Text
        local x, y, z = coords:match("(%d+),%s*(%d+),%s*(%d+)")
        if x and y and z then
            rootPart.CFrame = CFrame.new(tonumber(x), tonumber(y), tonumber(z))
        end
    end)

    -- ====== CATEGORIA: SOBRE ======
    local sobreSec, sobreCorpo = criarCategoria(content, "Sobre", "ℹ️")

    local sobreText = Instance.new("TextLabel")
    sobreText.Size = UDim2.new(1, 0, 0, 80)
    sobreText.BackgroundTransparency = 1
    sobreText.Text = "DRONX v2.0\nDesenvolvido para Blox Fruits\n\nFunções: Auto Farm, Maestria, Coleta, Cura, Boss, Teleport\n\n© 2025 DRONX Team"
    sobreText.TextColor3 = COLORS.muted
    sobreText.TextSize = 13
    sobreText.Font = Enum.Font.Gotham
    sobreText.TextXAlignment = Enum.TextXAlignment.Center
    sobreText.TextYAlignment = Enum.TextYAlignment.Top
    sobreText.Parent = sobreCorpo

    -- ====== STATUS RÁPIDO (SEM BOTÃO INICIAR) ======
    local statusSec = Instance.new("Frame")
    statusSec.Size = UDim2.new(1, 0, 0, 0)
    statusSec.BackgroundTransparency = 1
    statusSec.Parent = content

    local statusTitle = label(statusSec, "STATUS", 12, COLORS.muted, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
    statusTitle.Size = UDim2.new(1, 0, 0, 22)

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 140)
    card.BackgroundColor3 = COLORS.panelLight
    card.Parent = statusSec
    corner(card, 8)
    stroke(card, COLORS.border, 1)

    local cardPad = Instance.new("UIPadding")
    cardPad.PaddingLeft = UDim.new(0, 14)
    cardPad.PaddingTop = UDim.new(0, 10)
    cardPad.PaddingRight = UDim.new(0, 14)
    cardPad.PaddingBottom = UDim.new(0, 10)
    cardPad.Parent = card

    local cardLayout = Instance.new("UIListLayout")
    cardLayout.Padding = UDim.new(0, 4)
    cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cardLayout.Parent = card

    label(card, "Menu", 12, COLORS.muted, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
    label(card, "$1,323,522", 18, COLORS.gold, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
    label(card, "Lv. 2631", 16, COLORS.white, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
    label(card, "68,286,171 / 146,996,907", 13, COLORS.muted, Enum.Font.Gotham, Enum.TextXAlignment.Left)
    label(card, "Vida  11770 / 11770", 14, COLORS.white, Enum.Font.Gotham, Enum.TextXAlignment.Left)
    label(card, "Energy  14095 / 14095", 14, COLORS.white, Enum.Font.Gotham, Enum.TextXAlignment.Left)

    statusSec.Size = UDim2.new(1, 0, 0, 180)

    -- ====== EXPANDIR/COLAPSAR TUDO ======
    expandBtn.MouseButton1Click:Connect(function()
        expandida = not expandida
        expandBtn.Text = expandida and "▲" or "▼"
        -- Esconde/mostra todo o conteúdo
        content.Visible = expandida
        main.Size = expandida and UDim2.new(0, 480, 0, 520) or UDim2.new(0, 480, 0, 50)
    end)

    -- Atualiza o CanvasSize do ScrollingFrame
    local function updateCanvas()
        content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    task.wait(0.5)
    updateCanvas()

    print("[DRONX] GUI carregada com sucesso!")
end

pcall(criarGUI)
print("[DRONX] Pronto! Clique na seta ▼ para expandir as categorias.")
