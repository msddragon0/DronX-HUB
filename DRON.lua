-- ============================================================
-- DRONX – SCRIPT ÚNICO E FUNCIONAL (SEM FRESCURA)
-- ============================================================

print("[DRONX] Carregando...")

-- ====== CONFIGURAÇÕES ======
getgenv().DRONX = {
    Running = false,
    AutoFarm = false,
    AutoCollect = false,
    AutoHeal = false,
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
            if drx.AutoFarm then
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

    -- Janela principal
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 400, 0, 350)
    main.Position = UDim2.new(0.5, -200, 0.5, -175)
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    main.BorderSizePixel = 1
    main.BorderColor3 = Color3.fromRGB(60, 60, 70)
    main.Active = true
    main.Draggable = true
    main.Parent = screenGui

    -- Título
    local titulo = Instance.new("TextLabel")
    titulo.Size = UDim2.new(1, 0, 0, 35)
    titulo.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    titulo.Text = "DRONX"
    titulo.TextColor3 = Color3.fromRGB(255, 215, 0)
    titulo.TextScaled = true
    titulo.Font = Enum.Font.GothamBold
    titulo.Parent = main

    -- Fechar
    local fechar = Instance.new("TextButton")
    fechar.Size = UDim2.new(0, 30, 0, 30)
    fechar.Position = UDim2.new(1, -35, 0, 3)
    fechar.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    fechar.Text = "X"
    fechar.TextColor3 = Color3.fromRGB(255, 255, 255)
    fechar.TextScaled = true
    fechar.Font = Enum.Font.GothamBold
    fechar.Parent = main
    fechar.MouseButton1Click:Connect(function() screenGui:Destroy() end)

    -- Container
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 1, -45)
    container.Position = UDim2.new(0, 5, 0, 40)
    container.BackgroundTransparency = 1
    container.Parent = main

    -- Função checkbox
    local function checkbox(text, var, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 30)
        frame.Position = UDim2.new(0, 0, 0, y)
        frame.BackgroundTransparency = 1
        frame.Parent = container

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(220,220,230)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextScaled = true
        label.Font = Enum.Font.Gotham
        label.Parent = frame

        local check = Instance.new("TextButton")
        check.Size = UDim2.new(0, 25, 0, 25)
        check.Position = UDim2.new(0.9, 0, 0, 2)
        check.BackgroundColor3 = getgenv().DRONX[var] and Color3.fromRGB(0,200,0) or Color3.fromRGB(100,100,100)
        check.Text = getgenv().DRONX[var] and "✓" or ""
        check.TextColor3 = Color3.fromRGB(255,255,255)
        check.TextScaled = true
        check.Font = Enum.Font.GothamBold
        check.BorderSizePixel = 1
        check.BorderColor3 = Color3.fromRGB(255,255,255)
        check.Parent = frame

        check.MouseButton1Click:Connect(function()
            local state = not getgenv().DRONX[var]
            getgenv().DRONX[var] = state
            check.BackgroundColor3 = state and Color3.fromRGB(0,200,0) or Color3.fromRGB(100,100,100)
            check.Text = state and "✓" or ""
        end)
        return frame
    end

    -- Título Farm
    local farmTitle = Instance.new("TextLabel")
    farmTitle.Size = UDim2.new(1, 0, 0, 25)
    farmTitle.BackgroundTransparency = 1
    farmTitle.Text = "⚔️ FARM"
    farmTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
    farmTitle.TextSize = 18
    farmTitle.Font = Enum.Font.GothamBold
    farmTitle.TextXAlignment = Enum.TextXAlignment.Left
    farmTitle.Parent = container

    checkbox("Auto Farm", "AutoFarm", 30)
    checkbox("Auto Coletar Itens", "AutoCollect", 65)
    checkbox("Cura Automática", "AutoHeal", 100)

    -- Botão Iniciar/Parar
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.6, 0, 0, 40)
    btn.Position = UDim2.new(0.2, 0, 0, 145)
    btn.BackgroundColor3 = getgenv().DRONX.Running and Color3.fromRGB(150,0,0) or Color3.fromRGB(0,150,0)
    btn.Text = getgenv().DRONX.Running and "⏹ PARAR" or "▶ INICIAR"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = container

    btn.MouseButton1Click:Connect(function()
        local running = not getgenv().DRONX.Running
        getgenv().DRONX.Running = running
        btn.Text = running and "⏹ PARAR" or "▶ INICIAR"
        btn.BackgroundColor3 = running and Color3.fromRGB(150,0,0) or Color3.fromRGB(0,150,0)
    end)

    print("[DRONX] GUI carregada com sucesso!")
end

pcall(criarGUI)
print("[DRONX] Pronto! Marque as opções e clique em INICIAR.")
