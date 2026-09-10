-- ============================================================
-- DRONX – Auto Farm v1.0 (Script Completo)
-- ============================================================

print("[DRONX] Carregando...")

-- ====== CONFIGURAÇÕES ======
getgenv().DRONX = {
    Ativo = false,
    AutoFarm = false,
}

-- ====== OBTÉM JOGADOR ======
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ====== FUNÇÕES ======
-- ====== FUNÇÕES ======
local function getClosestNPC()
    local closest = nil
    local minDist = math.huge

    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return nil end

    for _, npc in pairs(enemiesFolder:GetChildren()) do
        if npc:IsA("Model") 
        and npc:FindFirstChild("Humanoid") 
        and npc.Humanoid.Health > 0 
        and npc:FindFirstChild("HumanoidRootPart") then

            local dist = (rootPart.Position - npc.HumanoidRootPart.Position).Magnitude
            if dist < minDist and dist <= 50 then
                minDist = dist
                closest = npc
            end
        end
    end
    return closest
end

local function attackNPC(npc)
    if not npc or not npc.Parent then return end
    if not npc:FindFirstChild("Humanoid") or npc.Humanoid.Health <= 0 then return end
    if not npc:FindFirstChild("HumanoidRootPart") then return end

    local targetPos = npc.HumanoidRootPart.Position
    rootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 0, 5), targetPos)
    task.wait(0.15)

    game:GetService("VirtualInputManager"):SendKeyEvent(true, "Q", false, game)
    task.wait(0.15)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, "Q", false, game)
end

-- ====== LOOP PRINCIPAL ======
coroutine.wrap(function()
    while true do
        task.wait()
        if getgenv().DRONX.Ativo and getgenv().DRONX.AutoFarm then
            local npc = getClosestNPC()
            if npc then attackNPC(npc) end
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

    -- Botão flutuante para abrir/fechar
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
    main.Size = UDim2.new(0, 280, 0, 180)
    main.Position = UDim2.new(0.5, -140, 0.5, -90)
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
    titulo.Text = "DRONX"
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

    local cbFrame = Instance.new("Frame")
    cbFrame.Size = UDim2.new(1, -20, 0, 30)
    cbFrame.Position = UDim2.new(0, 10, 0, 45)
    cbFrame.BackgroundTransparency = 1
    cbFrame.Parent = main

    local cbLabel = Instance.new("TextLabel")
    cbLabel.Size = UDim2.new(0.7, 0, 1, 0)
    cbLabel.BackgroundTransparency = 1
    cbLabel.Text = "Auto Farm"
    cbLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
    cbLabel.TextSize = 16
    cbLabel.Font = Enum.Font.Gotham
    cbLabel.TextXAlignment = Enum.TextXAlignment.Left
    cbLabel.Parent = cbFrame

    local cbCheck = Instance.new("TextButton")
    cbCheck.Size = UDim2.new(0, 25, 0, 25)
    cbCheck.Position = UDim2.new(0.85, 0, 0, 2)
    cbCheck.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    cbCheck.Text = ""
    cbCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
    cbCheck.TextScaled = true
    cbCheck.Font = Enum.Font.GothamBold
    cbCheck.BorderSizePixel = 1
    cbCheck.BorderColor3 = Color3.fromRGB(255, 255, 255)
    cbCheck.Parent = cbFrame

    cbCheck.MouseButton1Click:Connect(function()
        local state = not getgenv().DRONX.AutoFarm
        getgenv().DRONX.AutoFarm = state
        cbCheck.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
        cbCheck.Text = state and "✓" or ""
    end)

    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(0.6, 0, 0, 35)
    startBtn.Position = UDim2.new(0.2, 0, 0, 90)
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
print("[DRONX] Script completo carregado. Clique no ▶ para abrir.")
