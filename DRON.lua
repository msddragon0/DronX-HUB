-- ============================================================
-- DRONX – GUI Estilo Azure Hub (somente Farm + Status)
-- ============================================================

print("[DRONX] Carregando GUI estilo Azure...")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- ====== CORES ======
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

-- ====== FUNÇÕES AUXILIARES ======
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

local function stroke(parent, color, thickness)
    return create("UIStroke", {
        Color = color or COLORS.border,
        Thickness = thickness or 1,
    }, parent)
end

local function label(parent, text, size, color, font, align)
    return create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = color or COLORS.white,
        TextSize = size or 14,
        Font = font or Enum.Font.Gotham,
        TextXAlignment = align or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, parent)
end

-- ====== VARIÁVEIS GLOBAIS ======
getgenv().DRONX = getgenv().DRONX or {
    Running = false,
    AutoFarm = false,
    FarmMaestria = false,
    AutoCollect = false,
    AutoHeal = false,
    AttackDistance = 40,
}

-- ====== LOOP DE FARM ======
coroutine.wrap(function()
    while true do
        task.wait()
        local drx = getgenv().DRONX
        if drx.Running then
            if drx.AutoFarm or drx.FarmMaestria then
                local closest = nil
                local minDist = math.huge
                local level = player.Data.Level.Value
                for _, npc in pairs(workspace.Enemies:GetChildren()) do
                    if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                        local npcLevel = npc:FindFirstChild("Level") and npc.Level.Value or 0
                        if npcLevel >= level - 5 and npcLevel <= level + 10 then
                            local dist = (rootPart.Position - npc.HumanoidRootPart.Position).Magnitude
                            if dist < minDist and dist <= (drx.AttackDistance or 40) then
                                minDist = dist
                                closest = npc
                            end
                        end
                    end
                end
                if closest then
                    rootPart.CFrame = closest.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                    task.wait(0.1)
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, "Q", false, game)
                    task.wait(0.1)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, "Q", false, game)
                end
            end
            if drx.AutoCollect then
                for _, item in pairs(workspace.DroppedItems:GetChildren()) do
                    if item:IsA("Model") and item:FindFirstChild("Handle") then
                        if (rootPart.Position - item.Handle.Position).Magnitude < 15 then
                            fireclickdetector(item.Handle.ClickDetector)
                        end
                    end
                end
            end
            if drx.AutoHeal then
                if humanoid.Health / humanoid.MaxHealth < 0.3 then
                    local potion = player.Backpack:FindFirstChild("Potion") or character:FindFirstChild("Potion")
                    if potion then potion.Activate:FireServer() end
                end
            end
        end
    end
end)()

-- ====== CRIAÇÃO DA GUI ======
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = create("ScreenGui", {
    Name = "DRONX_Azure",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
}, playerGui)

local overlay = create("Frame", {
    Name = "Overlay",
    BackgroundColor3 = COLORS.background,
    BackgroundTransparency = 0.15,
    Size = UDim2.fromScale(1, 1),
}, screenGui)

local main = create("Frame", {
    Name = "MainWindow",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0.45, 0, 0.65, 0),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, overlay)
corner(main, 12)
stroke(main, COLORS.border, 1)

local topBar = create("Frame", {
    Name = "TopBar",
    BackgroundColor3 = COLORS.panelLight,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 58),
}, main)

local accent = create("Frame", {
    BackgroundColor3 = COLORS.blue,
    BorderSizePixel = 0,
    Size = UDim2.new(0, 4, 1, 0),
}, topBar)

local logo = create("Frame", {
    BackgroundColor3 = COLORS.blueDark,
    Position = UDim2.new(0, 18, 0.5, -16),
    Size = UDim2.fromOffset(32, 32),
}, topBar)
corner(logo, 8)
local logoText = label(logo, "D", 19, COLORS.white, Enum.Font.GothamBold)
logoText.TextXAlignment = Enum.TextXAlignment.Center
logoText.Size = UDim2.fromScale(1, 1)

local title = label(topBar, "DRONX", 17, COLORS.white, Enum.Font.GothamBold)
title.Position = UDim2.new(0, 60, 0, 10)
title.Size = UDim2.new(0, 200, 0, 22)

local subtitle = label(topBar, "FARM CONTROLS", 10, COLORS.cyan, Enum.Font.GothamMedium)
subtitle.Position = UDim2.new(0, 61, 0, 33)
subtitle.Size = UDim2.new(0, 200, 0, 16)

local closeButton = create("TextButton", {
    Name = "Close",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -15, 0.5, 0),
    Size = UDim2.fromOffset(26, 26),
    BackgroundColor3 = COLORS.panelHover,
    Text = "×",
    TextColor3 = COLORS.muted,
    TextSize = 20,
    Font = Enum.Font.GothamMedium,
    AutoButtonColor = false,
}, topBar)
corner(closeButton, 7)
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ====== CONTEÚDO ======
local content = create("ScrollingFrame", {
    Name = "Content",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 58),
    Size = UDim2.new(1, 0, 1, -58),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = COLORS.blue,
}, main)

local contentPadding = create("UIPadding", {
    PaddingTop = UDim.new(0, 18),
    PaddingLeft = UDim.new(0, 22),
    PaddingRight = UDim.new(0, 22),
    PaddingBottom = UDim.new(0, 18),
}, content)

local layout = create("UIListLayout", {
    Padding = UDim.new(0, 14),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, content)

-- ====== FUNÇÕES DE CRIAÇÃO DE ELEMENTOS ======
local function createToggle(parent, titleText, desc, varName)
    local row = create("Frame", {
        BackgroundColor3 = COLORS.panelLight,
        Size = UDim2.new(1, 0, 0, 58),
    }, parent)
    corner(row, 8)
    stroke(row, COLORS.border, 1)

    local optTitle = label(row, titleText, 13, COLORS.white, Enum.Font.GothamMedium)
    optTitle.Position = UDim2.new(0, 16, 0, 10)
    optTitle.Size = UDim2.new(1, -80, 0, 20)

    local optDesc = label(row, desc, 10, COLORS.muted, Enum.Font.Gotham)
    optDesc.Position = UDim2.new(0, 16, 0, 33)
    optDesc.Size = UDim2.new(1, -80, 0, 16)

    local toggle = create("TextButton", {
        BackgroundColor3 = getgenv().DRONX[varName] and COLORS.blue or COLORS.background,
        Position = UDim2.new(1, -56, 0.5, -11),
        Size = UDim2.fromOffset(40, 22),
        Text = "",
        AutoButtonColor = false,
    }, row)
    corner(toggle, 12)
    stroke(toggle, COLORS.border, 1)

    local knob = create("Frame", {
        BackgroundColor3 = COLORS.white,
        Position = getgenv().DRONX[varName] and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7),
        Size = UDim2.fromOffset(14, 14),
    }, toggle)
    corner(knob, 7)

    toggle.MouseButton1Click:Connect(function()
        local state = not getgenv().DRONX[varName]
        getgenv().DRONX[varName] = state
        TweenService:Create(toggle, TweenInfo.new(0.18), {
            BackgroundColor3 = state and COLORS.blue or COLORS.background,
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.18), {
            Position = state and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7),
        }):Play()
    end)
    return row
end

local function createInfoCard(parent, title, value, color)
    local card = create("Frame", {
        BackgroundColor3 = COLORS.panelLight,
        Size = UDim2.new(1, 0, 0, 50),
    }, parent)
    corner(card, 8)
    stroke(card, COLORS.border, 1)

    local titleLabel = label(card, title, 11, COLORS.muted, Enum.Font.GothamMedium)
    titleLabel.Position = UDim2.new(0, 16, 0, 8)
    titleLabel.Size = UDim2.new(1, -20, 0, 18)

    local valueLabel = label(card, value, 16, color or COLORS.white, Enum.Font.GothamBold)
    valueLabel.Position = UDim2.new(0, 16, 0, 28)
    valueLabel.Size = UDim2.new(1, -20, 0, 20)
    return card
end

-- ====== SEÇÃO FARM ======
local farmSection = create("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 0),
}, content)

local farmTitle = label(farmSection, "⚔️ FARM", 18, COLORS.cyan, Enum.Font.GothamBold)
farmTitle.Size = UDim2.new(1, 0, 0, 28)

createToggle(farmSection, "Auto Farm", "Ataca NPCs próximos do seu nível.", "AutoFarm")
createToggle(farmSection, "Farm Maestria", "Foca em ganhar maestria de armas/frutas.", "FarmMaestria")
createToggle(farmSection, "Auto Coletar Itens", "Pega frutas e itens no chão automaticamente.", "AutoCollect")
createToggle(farmSection, "Cura Automática", "Usa poção quando a vida está baixa.", "AutoHeal")

-- ====== BOTÃO INICIAR/PARAR ======
local btnFrame = create("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 56),
}, content)

local btn = create("TextButton", {
    BackgroundColor3 = getgenv().DRONX.Running and COLORS.red or COLORS.green,
    Size = UDim2.new(1, 0, 1, 0),
    Text = getgenv().DRONX.Running and "⏹ PARAR" or "▶ INICIAR",
    TextColor3 = COLORS.white,
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
}, btnFrame)
corner(btn, 8)
stroke(btn, COLORS.border, 1)

btn.MouseButton1Click:Connect(function()
    local running = not getgenv().DRONX.Running
    getgenv().DRONX.Running = running
    btn.Text = running and "⏹ PARAR" or "▶ INICIAR"
    btn.BackgroundColor3 = running and COLORS.red or COLORS.green
end)

-- ====== SEÇÃO STATUS ======
local statusSection = create("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 0),
}, content)

local statusTitle = label(statusSection, "📊 STATUS", 16, COLORS.cyan, Enum.Font.GothamBold)
statusTitle.Size = UDim2.new(1, 0, 0, 26)

-- Grid de status (2 colunas)
local grid = create("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 120),
}, statusSection)

local gridLayout = create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    Padding = UDim.new(0, 12),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, grid)

local function createStat(parent, labelText, valueText, color)
    local card = create("Frame", {
        BackgroundColor3 = COLORS.panelLight,
        Size = UDim2.new(0.5, -6, 1, 0),
    }, parent)
    corner(card, 8)
    stroke(card, COLORS.border, 1)
    local lbl = label(card, labelText, 11, COLORS.muted, Enum.Font.GothamMedium)
    lbl.Position = UDim2.new(0, 14, 0, 8)
    lbl.Size = UDim2.new(1, -20, 0, 18)
    local val = label(card, valueText, 15, color or COLORS.white, Enum.Font.GothamBold)
    val.Position = UDim2.new(0, 14, 0, 28)
    val.Size = UDim2.new(1, -20, 0, 20)
    return card
end

-- Atualiza os stats em tempo real (simplificado)
local function updateStats()
    local level = player.Data and player.Data.Level and player.Data.Level.Value or 0
    local money = player.Data and player.Data.Beli and player.Data.Beli.Value or 0
    local hp = math.floor(humanoid.Health)
    local maxHp = math.floor(humanoid.MaxHealth)
    local energy = player.Data and player.Data.Energy and player.Data.Energy.Value or 0
    local maxEnergy = player.Data and player.Data.MaxEnergy and player.Data.MaxEnergy.Value or 0

    -- Limpa o grid e recria (simples, mas funcional)
    for _, child in pairs(grid:GetChildren()) do
        if child:IsA("Frame") and child ~= gridLayout then child:Destroy() end
    end

    createStat(grid, "💰 Dinheiro", "$" .. tostring(money), COLORS.blue)
    createStat(grid, "📊 Nível", "Lv. " .. tostring(level), COLORS.cyan)
    createStat(grid, "❤️ Vida", hp .. "/" .. maxHp, COLORS.green)
    createStat(grid, "⚡ Energia", energy .. "/" .. maxEnergy, COLORS.blue)
end

updateStats()

-- Atualiza a cada 5 segundos
coroutine.wrap(function()
    while true do
        task.wait(5)
        pcall(updateStats)
    end
end)()

-- ====== NÚCLEO DE ENERGIA ======
local coreSection = create("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 0),
}, content)

local coreTitle = label(coreSection, "⚡ NÚCLEO DE ENERGIA", 14, COLORS.cyan, Enum.Font.GothamBold)
coreTitle.Size = UDim2.new(1, 0, 0, 24)

local coreCard = create("Frame", {
    BackgroundColor3 = COLORS.panelLight,
    Size = UDim2.new(1, 0, 0, 50),
}, coreSection)
corner(coreCard, 8)
stroke(coreCard, COLORS.border, 1)

local coreInfo = label(coreCard, "Núcleo Ativo:  ❖  Energia Máxima", 13, COLORS.white, Enum.Font.GothamMedium)
coreInfo.Position = UDim2.new(0, 16, 0, 10)
coreInfo.Size = UDim2.new(1, -20, 0, 20)
local coreSub = label(coreCard, "Capacidade: 100%  •  Recarga: 10/s", 10, COLORS.muted, Enum.Font.Gotham)
coreSub.Position = UDim2.new(0, 16, 0, 32)
coreSub.Size = UDim2.new(1, -20, 0, 16)

-- ====== FINALIZAÇÃO ======
print("[DRONX] GUI Azure carregada com sucesso! Pressione RightShift para abrir/fechar.")

-- Fechar/abrir com RightShift
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        overlay.Visible = not overlay.Visible
    end
end)

-- Animação de entrada
main.Position = UDim2.fromScale(0.5, 0.54)
TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
    Position = UDim2.fromScale(0.5, 0.5),
}):Play()
