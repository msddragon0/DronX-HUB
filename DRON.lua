-- ============================================================
-- DRONX – GUI SIMPLES E FUNCIONAL (COM VALORES REAIS)
-- ============================================================

print("[DRONX] Carregando...")

-- ====== CONFIGURAÇÕES ======
getgenv().DRONX = {
    AutoFarm = false,
    AutoMaestria = false,
    AutoCollect = false,
    AutoHeal = false,
    AutoBoss = false,
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
                if dist < minDist and dist <= 40 then
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
        if getgenv().DRONX.AutoFarm or getgenv().DRONX.AutoMaestria then
            local npc = getClosestNPC()
            if npc then attackNPC(npc) end
        end
        if getgenv().DRONX.AutoCollect then collectItems() end
        if getgenv().DRONX.AutoHeal then autoHeal() end
    end
end)()

-- ====== CRIAÇÃO DA GUI ======
local function criarGUI()
    local guiParent = game:GetService("CoreGui") or player:WaitForChild("PlayerGui")
    if not guiParent then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DRONX_GUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = guiParent

    -- Cores
    local colors = {
        bg = Color3.fromRGB(16, 22, 36),
        panel = Color3.fromRGB(22, 30, 48),
        blue = Color3.fromRGB(61, 151, 255),
        white = Color3.fromRGB(239, 244, 255),
        muted = Color3.fromRGB(144, 158, 185),
        gold = Color3.fromRGB(255, 215, 0),
        green = Color3.fromRGB(76, 211, 141),
        red = Color3.fromRGB(255, 70, 70),
    }

    local function corner(p, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or 8)
        c.Parent = p
    end

    local function label(p, text, size, color, font, align)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = color or colors.white
        l.TextSize = size or 14
        l.Font = font or Enum.Font.Gotham
        l.TextXAlignment = align or Enum.TextXAlignment.Left
        l.TextYAlignment = Enum.TextYAlignment.Center
        l.Parent = p
        return l
    end

    -- Janela principal
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 400, 0, 460)
    main.Position = UDim2.new(0.5, -200, 0.5, -230)
    main.BackgroundColor3 = colors.bg
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = screenGui
    corner(main, 12)

    -- Top bar
    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, 0, 0, 44)
    top.BackgroundColor3 = colors.panel
    top.Parent = main

    local title = label(top, "DRONX", 18, colors.white, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
    title.Position = UDim2.new(0, 14, 0, 4)
    title.Size = UDim2.new(0, 140, 0, 22)

    local sub = label(top, "FARM CONTROLS", 10, colors.muted, Enum.Font.Gotham, Enum.TextXAlignment.Left)
    sub.Position = UDim2.new(0, 14, 0, 24)
    sub.Size = UDim2.new(0, 140, 0, 18)

    -- Botão fechar
    local close = Instance.new("TextButton")
    close.AnchorPoint = Vector2.new(1, 0.5)
    close.Position = UDim2.new(1, -12, 0.5, 0)
    close.Size = UDim2.fromOffset(24, 24)
    close.BackgroundColor3 = colors.panel
    close.Text = "×"
    close.TextColor3 = colors.muted
    close.TextSize = 18
    close.Font = Enum.Font.GothamBold
    close.AutoButtonColor = false
    close.Parent = top
    corner(close, 6)
    close.MouseButton1Click:Connect(function() screenGui:Destroy() end)

    -- Container (ScrollingFrame)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -16, 1, -56)
    scroll.Position = UDim2.new(0, 8, 0, 50)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = colors.blue
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = main

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    -- ====== FUNÇÃO CHECKBOX ======
    local function toggle(parent, text, var)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 32)
        f.BackgroundColor3 = colors.panel
        f.Parent = parent
        corner(f, 6)

        local lbl = label(f, text, 13, colors.white, Enum.Font.Gotham, Enum.TextXAlignment.Left)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.Size = UDim2.new(0.6, 0, 1, 0)

        local btn = Instance.new("TextButton")
        btn.AnchorPoint = Vector2.new(1, 0.5)
        btn.Position = UDim2.new(1, -12, 0.5, 0)
        btn.Size = UDim2.fromOffset(38, 18)
        btn.BackgroundColor3 = getgenv().DRONX[var] and colors.green or colors.muted
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = f
        corner(btn, 9)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(12, 12)
        knob.Position = getgenv().DRONX[var] and UDim2.new(1, -16, 0.5, -6) or UDim2.new(0, 4, 0.5, -6)
        knob.BackgroundColor3 = colors.white
        knob.Parent = btn
        corner(knob, 6)

        btn.MouseButton1Click:Connect(function()
            local state = not getgenv().DRONX[var]
            getgenv().DRONX[var] = state
            btn.BackgroundColor3 = state and colors.green or colors.muted
            knob.Position = state and UDim2.new(1, -16, 0.5, -6) or UDim2.new(0, 4, 0.5, -6)
        end)
    end

    -- ====== CATEGORIAS ======
    local function categoria(title, icon)
        local sec = Instance.new("Frame")
        sec.Size = UDim2.new(1, 0, 0, 0)
        sec.BackgroundTransparency = 1
        sec.Parent = scroll

        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 30)
        header.BackgroundColor3 = colors.panel
        header.Parent = sec
        corner(header, 6)

        local htext = label(header, "▼ " .. icon .. " " .. title, 13, colors.white, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
        htext.Position = UDim2.new(0, 12, 0, 0)
        htext.Size = UDim2.new(0.8, 0, 1, 0)

        local body = Instance.new("Frame")
        body.Size = UDim2.new(1, 0, 0, 0)
        body.BackgroundTransparency = 1
        body.Parent = sec

        local bodyLayout = Instance.new("UIListLayout")
        bodyLayout.Padding = UDim.new(0, 4)
        bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
        bodyLayout.Parent = body

        local expandido = true
        header.MouseButton1Click:Connect(function()
            expandido = not expandido
            body.Visible = expandido
            htext.Text = (expandido and "▼ " or "▶ ") .. icon .. " " .. title
        end)

        return sec, body
    end

    -- FARM
    local farmSec, farmBody = categoria("Farm", "⚔️")
    toggle(farmBody, "Auto Farm", "AutoFarm")
    toggle(farmBody, "Farm Maestria", "AutoMaestria")
    toggle(farmBody, "Auto Coletar", "AutoCollect")
    toggle(farmBody, "Cura Automática", "AutoHeal")

    -- BOSS
    local bossSec, bossBody = categoria("Boss", "👹")
    local bossInput = Instance.new("TextBox")
    bossInput.Size = UDim2.new(1, 0, 0, 32)
    bossInput.BackgroundColor3 = colors.panel
    bossInput.TextColor3 = colors.white
    bossInput.TextSize = 13
    bossInput.Font = Enum.Font.Gotham
    bossInput.PlaceholderText = "Nome do Boss"
    bossInput.Parent = bossBody
    corner(bossInput, 6)
    toggle(bossBody, "Auto Boss", "AutoBoss")

    -- TELEPORT
    local teleSec, teleBody = categoria("Teleport", "📍")
    local coordInput = Instance.new("TextBox")
    coordInput.Size = UDim2.new(1, 0, 0, 32)
    coordInput.BackgroundColor3 = colors.panel
    coordInput.TextColor3 = colors.white
    coordInput.TextSize = 13
    coordInput.Font = Enum.Font.Gotham
    coordInput.PlaceholderText = "X, Y, Z"
    coordInput.Parent = teleBody
    corner(coordInput, 6)

    local teleBtn = Instance.new("TextButton")
    teleBtn.Size = UDim2.new(0.5, 0, 0, 32)
    teleBtn.Position = UDim2.new(0.25, 0, 0, 0)
    teleBtn.BackgroundColor3 = colors.blue
    teleBtn.Text = "IR"
    teleBtn.TextColor3 = colors.white
    teleBtn.TextSize = 14
    teleBtn.Font = Enum.Font.GothamBold
    teleBtn.AutoButtonColor = false
    teleBtn.Parent = teleBody
    corner(teleBtn, 6)
    teleBtn.MouseButton1Click:Connect(function()
        local x, y, z = coordInput.Text:match("(%d+),%s*(%d+),%s*(%d+)")
        if x and y and z then
            rootPart.CFrame = CFrame.new(tonumber(x), tonumber(y), tonumber(z))
        end
    end)

    -- SOBRE
    local sobreSec, sobreBody = categoria("Sobre", "ℹ️")
    local sobreText = label(sobreBody, "DRONX v2.0\nAuto Farm, Maestria, Coleta, Cura, Boss, Teleport\n© 2025 DRONX Team", 12, colors.muted, Enum.Font.Gotham, Enum.TextXAlignment.Center)
    sobreText.Size = UDim2.new(1, 0, 0, 70)
    sobreText.TextYAlignment = Enum.TextYAlignment.Top

    -- ====== STATUS (COM VALORES REAIS) ======
    local statusSec = Instance.new("Frame")
    statusSec.Size = UDim2.new(1, 0, 0, 0)
    statusSec.BackgroundTransparency = 1
    statusSec.Parent = scroll

    local stitle = label(statusSec, "STATUS", 12, colors.muted, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
    stitle.Size = UDim2.new(1, 0, 0, 22)

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 130)
    card.BackgroundColor3 = colors.panel
    card.Parent = statusSec
    corner(card, 8)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 12)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.Parent = card

    local statusLayout = Instance.new("UIListLayout")
    statusLayout.Padding = UDim.new(0, 2)
    statusLayout.SortOrder = Enum.SortOrder.LayoutOrder
    statusLayout.Parent = card

    -- Labels dinâmicos (atualizados a cada segundo)
    local menuLbl = label(card, "Menu", 11, colors.muted, Enum.Font.GothamMedium, Enum.TextXAlignment.Left)
    local moneyLbl = label(card, "$0", 18, colors.gold, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
    local lvlLbl = label(card, "Lv. 0", 16, colors.white, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
    local expLbl = label(card, "0 / 0", 12, colors.muted, Enum.Font.Gotham, Enum.TextXAlignment.Left)
    local hpLbl = label(card, "Vida 0 / 0", 14, colors.white, Enum.Font.Gotham, Enum.TextXAlignment.Left)
    local enLbl = label(card, "Energy 0 / 0", 14, colors.white, Enum.Font.Gotham, Enum.TextXAlignment.Left)

    -- Atualiza os valores a cada 1 segundo
    coroutine.wrap(function()
        while screenGui.Parent do
            task.wait(1)
            local data = player.Data
            if data then
                moneyLbl.Text = "$" .. string.format("%.0f", data.Beli.Value)
                lvlLbl.Text = "Lv. " .. data.Level.Value
                expLbl.Text = string.format("%.0f", data.Experience.Value) .. " / " .. string.format("%.0f", data.Level.Value * 1000)
            end
            if humanoid then
                hpLbl.Text = "Vida " .. math.floor(humanoid.Health) .. " / " .. math.floor(humanoid.MaxHealth)
                enLbl.Text = "Energy " .. math.floor(humanoid.Energy) .. " / " .. math.floor(humanoid.MaxEnergy)
            end
        end
    end)()

    statusSec.Size = UDim2.new(1, 0, 0, 170)

    -- Ajusta canvas
    local function updateCanvas()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    task.wait(0.5)
    updateCanvas()

    print("[DRONX] GUI carregada com valores dinâmicos!")
end

pcall(criarGUI)
