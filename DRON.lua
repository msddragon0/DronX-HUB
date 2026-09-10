-- ============================================================
-- DRONX – Auto Farm v2.0 (Robusto, com cura e troca de ilha)
-- ============================================================

print("[DRONX] Carregando...")

-- ====== CONFIGURAÇÕES ======
getgenv().DRONX = {
    Ativo = false,
    AutoFarm = false,
    AutoHeal = true,
    AutoCollect = true,
    AttackSpeed = 0.5,       -- intervalo entre ataques
    MaxDistance = 1000,      -- distância máxima para procurar NPC
    HealThreshold = 0.5,     -- cura quando vida < 50%
}

-- ====== LISTA DE ILHAS (Third Sea) ======
-- Adicione/edite conforme sua progressão
local ilhas = {
    {nome = "Port Town",      nivel = 1900, coords = CFrame.new(300, 20, 0)},
    {nome = "Haunted Castle", nivel = 2000, coords = CFrame.new(-500, 40, 3800)},
    {nome = "Sea of Treats",  nivel = 2200, coords = CFrame.new(300, 30, 4000)},
    {nome = "Floating Turtle",nivel = 2400, coords = CFrame.new(-200, 200, 5200)},
    {nome = "Haunted Castle II",nivel = 2500, coords = CFrame.new(-2000, 50, 1000)},
    {nome = "Castle on the Sea",nivel = 2600, coords = CFrame.new(500, 20, 3000)},
}

-- ====== JOGADOR ======
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Atualiza variáveis quando o personagem respawnar
player.CharacterAdded:Connect(function(char)
    character = char
    rootPart = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    print("[DRONX] Personagem respawnou.")
end)

-- ====== FUNÇÃO: Encontrar NPC mais próximo ======
local function getClosestNPC()
    local closest = nil
    local minDist = math.huge

    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return nil end

    for _, npc in pairs(enemiesFolder:GetChildren()) do
        if npc:IsA("Model") then
            local hum = npc:FindFirstChildOfClass("Humanoid")
            local hrp = npc:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                local dist = (rootPart.Position - hrp.Position).Magnitude
                if dist < minDist and dist <= getgenv().DRONX.MaxDistance then
                    minDist = dist
                    closest = npc
                end
            end
        end
    end
    return closest
end

-- ====== FUNÇÃO: Atacar NPC ======
local function attackNPC(npc)
    if not npc or not npc.Parent then return end
    local hum = npc:FindFirstChildOfClass("Humanoid")
    local hrp = npc:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not hrp then return end

    -- Teleporta para frente do NPC (não em cima)
    rootPart.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 0, 6), hrp.Position)
    task.wait(0.1)

    -- Ataca com Q
    game:GetService("VirtualInputManager"):SendKeyEvent(true, "Q", false, game)
    task.wait(0.1)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, "Q", false, game)
end

-- ====== FUNÇÃO: Cura automática ======
local function autoHeal()
    if not humanoid or humanoid.Health <= 0 then return end
    local percent = humanoid.Health / humanoid.MaxHealth
    if percent < getgenv().DRONX.HealThreshold then
        local potion = player.Backpack:FindFirstChild("Potion") or character:FindFirstChild("Potion")
        if potion then
            potion.Activate:FireServer()
        end
    end
end

-- ====== FUNÇÃO: Coletar itens ======
local function autoCollect()
    for _, item in pairs(workspace:GetChildren()) do
        if item:IsA("Model") and item.Name:lower():find("fruit") then
            if item:FindFirstChild("Handle") then
                local dist = (rootPart.Position - item.Handle.Position).Magnitude
                if dist < 30 then
                    rootPart.CFrame = item.Handle.CFrame
                    task.wait(0.2)
                end
            end
        end
    end
end

-- ====== FUNÇÃO: Trocar de ilha ======
local function trocarIlha()
    local nivelAtual = player.Data.Level.Value
    local melhorIlha = nil
    for _, ilha in ipairs(ilhas) do
        if nivelAtual >= ilha.nivel then
            melhorIlha = ilha
        end
    end
    if melhorIlha and melhorIlha.coords then
        rootPart.CFrame = melhorIlha.coords
        print("[DRONX] Teleportando para " .. melhorIlha.nome)
        task.wait(2)
    end
end

-- ====== LOOP PRINCIPAL ======
coroutine.wrap(function()
    local semNPC = 0  -- contador de ciclos sem encontrar NPC

    while true do
        task.wait(getgenv().DRONX.AttackSpeed)

        if getgenv().DRONX.Ativo and getgenv().DRONX.AutoFarm then
            -- Não faz nada se estiver morto
            if not character or not character.Parent or humanoid.Health <= 0 then
                task.wait(2)
                continue
            end

            -- Cura automática
            if getgenv().DRONX.AutoHeal then
                autoHeal()
            end

            -- Coleta automática
            if getgenv().DRONX.AutoCollect then
                autoCollect()
            end

            -- Procura NPC
            local npc = getClosestNPC()
            if npc then
                semNPC = 0
                attackNPC(npc)
            else
                semNPC = semNPC + 1
                -- Se ficar 5 ciclos sem NPC, tenta trocar de ilha
                if semNPC >= 5 then
                    print("[DRONX] Sem NPCs por perto. Tentando trocar de ilha...")
                    trocarIlha()
                    semNPC = 0
                end
            end
        end
    end
end)()

-- ====== GUI ======
local function criarGUI()
    local guiParent = game:GetService("CoreGui") or player:WaitForChild("PlayerGui")
    if not guiParent then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DRONX_GUI"
    screenGui.Parent = guiParent

    -- Botão flutuante
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleBtn.Position = UDim2.new(0, 10, 0, 10)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    toggleBtn.Text = "▶"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 24
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = screenGui

    -- Janela principal
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 300, 0, 260)
    main.Position = UDim2.new(0.5, -150, 0.5, -130)
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    main.BorderSizePixel = 1
    main.BorderColor3 = Color3.fromRGB(60, 60, 80)
    main.Active = true
    main.Draggable = true
    main.Visible = false
    main.Parent = screenGui

    local titulo = Instance.new("TextLabel")
    titulo.Size = UDim2.new(1, 0, 0, 35)
    titulo.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    titulo.Text = "DRONX v2.0"
    titulo.TextColor3 = Color3.fromRGB(255, 215, 0)
    titulo.TextScaled = true
    titulo.Font = Enum.Font.GothamBold
    titulo.Parent = main

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = main
    closeBtn.MouseButton1Click:Connect(function()
        main.Visible = false
    end)

    -- Função para criar checkbox
    local function criarCheckbox(texto, var, posY)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 30)
        frame.Position = UDim2.new(0, 10, 0, posY)
        frame.BackgroundTransparency = 1
        frame.Parent = main

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.7, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = texto
        lbl.TextColor3 = Color3.fromRGB(220, 220, 230)
        lbl.TextSize = 15
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame

        local chk = Instance.new("TextButton")
        chk.Size = UDim2.new(0, 25, 0, 25)
        chk.Position = UDim2.new(0.85, 0, 0, 2)
        chk.BackgroundColor3 = getgenv().DRONX[var] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
        chk.Text = getgenv().DRONX[var] and "✓" or ""
        chk.TextColor3 = Color3.fromRGB(255, 255, 255)
        chk.TextScaled = true
        chk.Font = Enum.Font.GothamBold
        chk.BorderSizePixel = 1
        chk.BorderColor3 = Color3.fromRGB(255, 255, 255)
        chk.Parent = frame

        chk.MouseButton1Click:Connect(function()
            local state = not getgenv().DRONX[var]
            getgenv().DRONX[var] = state
            chk.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
            chk.Text = state and "✓" or ""
        end)
    end

    criarCheckbox("Auto Farm", "AutoFarm", 45)
    criarCheckbox("Auto Cura", "AutoHeal", 80)
    criarCheckbox("Auto Coletar", "AutoCollect", 115)

    -- Botão Iniciar/Parar
    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(0.6, 0, 0, 40)
    startBtn.Position = UDim2.new(0.2, 0, 0, 155)
    startBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    startBtn.Text = "INICIAR"
    startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    startBtn.TextScaled = true
    startBtn.Font = Enum.Font.GothamBold
    startBtn.Parent = main

    startBtn.MouseButton1Click:Connect(function()
        local ativo = not getgenv().DRONX.Ativo
        getgenv().DRONX.Ativo = ativo
        startBtn.Text = ativo and "PARAR" or "INICIAR"
        startBtn.BackgroundColor3 = ativo and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 150, 0)
    end)

    -- Botão trocar ilha
    local ilhaBtn = Instance.new("TextButton")
    ilhaBtn.Size = UDim2.new(0.6, 0, 0, 30)
    ilhaBtn.Position = UDim2.new(0.2, 0, 0, 205)
    ilhaBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 200)
    ilhaBtn.Text = "TROCAR ILHA"
    ilhaBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ilhaBtn.TextScaled = true
    ilhaBtn.Font = Enum.Font.GothamBold
    ilhaBtn.Parent = main

    ilhaBtn.MouseButton1Click:Connect(function()
        trocarIlha()
    end)

    -- Botão flutuante (abrir/fechar)
    local aberta = false
    toggleBtn.MouseButton1Click:Connect(function()
        aberta = not aberta
        main.Visible = aberta
        toggleBtn.Text = aberta and "◀" or "▶"
        toggleBtn.BackgroundColor3 = aberta and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(30, 30, 40)
    end)

    print("[DRONX] GUI carregada.")
end

pcall(criarGUI)
print("[DRONX] v2.0 carregado. Clique no ▶ para abrir.")
