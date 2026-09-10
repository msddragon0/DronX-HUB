-- ============================================================
-- DRONX v3.2 – Auto Farm + Fluent UI (FINAL CORRIGIDO)
-- ============================================================

print("[DRONX] Carregando...")

-- ====== CONFIGURAÇÕES ======
getgenv().DRONX = {
    AutoFarm = false,
    AutoHeal = false,
    AutoCollect = false,
    AttackSpeed = 0.3,
    MaxDistance = 1000,
    HealThreshold = 0.5,
}

-- ====== ILHAS ======
local ilhas = {
    {nome = "Port Town",         nivel = 1900, coords = CFrame.new(-290, 6, 5343)},
    {nome = "Haunted Castle",    nivel = 2000, coords = CFrame.new(-9515, 164, 5786)},
    {nome = "Great Tree",        nivel = 2200, coords = CFrame.new(2681, 1682, -7190)},
    {nome = "Floating Turtle",   nivel = 2400, coords = CFrame.new(-13274, 531, -7579)},
    {nome = "Castle on the Sea", nivel = 2600, coords = CFrame.new(-5075, 314, -3150)},
}

-- ====== JOGADOR ======
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(char)
    character = char
    rootPart = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    print("[DRONX] Respawnou.")
end)

local npcAtual = nil

-- ====== HOOK DE ATAQUE (com fallback) ======
local AC = nil

local sucesso = pcall(function()
    local CombatFramework = require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("CombatFramework", 5))
    local CameraShaker = require(game.ReplicatedStorage.Util.CameraShaker)
    CameraShaker:Stop()
    AC = debug.getupvalues(CombatFramework)[2]
end)

if not sucesso or not AC then
    warn("[DRONX] Hook de ataque falhou. Usando método alternativo (SendKeyEvent).")
end

local function atacarRapido()
    -- 🔥 AUTO-CLICK (clique básico, não tecla Q)
    pcall(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
    end)
end

-- Equipa arma
local function equiparArma()
    pcall(function()
        -- 🔥 Prioridade: SWORD (espada) > Melee
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.ToolTip == "Sword" then
                player.Character.Humanoid:EquipTool(tool)
                return
            end
        end
        -- Se não tem espada, tenta melee
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.ToolTip == "Melee" then
                player.Character.Humanoid:EquipTool(tool)
                return
            end
        end
    end)
end

-- Ativa Haki Busho
local function autoHaki()
    if not player.Character:FindFirstChild("HasBuso") then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
    end
end

-- ====== FUNÇÃO: Achar NPC ======
local function getClosestNPC()
    local closest, minDist = nil, math.huge
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

-- ====== FUNÇÃO: Atacar NPC (em cima + bring mob) ======
local function attackNPC(npc)
    if not npc or not npc.Parent then return end
    local hum = npc:FindFirstChildOfClass("Humanoid")
    local hrp = npc:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not hrp then return end

local dist = (rootPart.Position - hrp.Position).Magnitude
if dist > 8 then
    rootPart.CFrame = hrp.CFrame * CFrame.new(0, 1, 0)
    task.wait(0.15)
end
    task.wait(0.05)

    pcall(function()
        hum.WalkSpeed = 0
        hum.JumpPower = 0
        hrp.CanCollide = false
        hrp.Size = Vector3.new(60, 60, 60)
        hrp.CFrame = rootPart.CFrame * CFrame.new(0, -1, 0)
    end)

    equiparArma()
    autoHaki()

    atacarRapido()
    task.wait(0.05)
    atacarRapido()
    task.wait(0.05)
    atacarRapido()
end

-- ====== FUNÇÃO: Cura ======
local function autoHeal()
    if not humanoid or humanoid.Health <= 0 then return end
    if humanoid.Health / humanoid.MaxHealth < getgenv().DRONX.HealThreshold then
        local pociones = {"Potion", "Devil Fruit", "Mochi", "Dough", "Ice Cream", "Cake", "Candy", "Chocolate", "Bomb"}
        for _, nome in ipairs(pociones) do
            local item = player.Backpack:FindFirstChild(nome) or character:FindFirstChild(nome)
            if item and item:IsA("Tool") then
                pcall(function()
                    if item.Parent == player.Backpack then
                        player.Character.Humanoid:EquipTool(item)
                        task.wait(0.1)
                    end
                    item:Activate()
                    task.wait(0.3)
                end)
                return
            end
        end
    end
end

-- ====== FUNÇÃO: Coletar ======
local function autoCollect()
    if npcAtual and npcAtual.Parent then
        local h = npcAtual:FindFirstChildOfClass("Humanoid")
        if h and h.Health > 0 then return end
    end

    for _, item in pairs(workspace:GetChildren()) do
        if item:IsA("Model") or item:IsA("Tool") then
            local handle = item:FindFirstChild("Handle")
            local clickDetector = item:FindFirstChildOfClass("ClickDetector") 
                or (handle and handle:FindFirstChildOfClass("ClickDetector"))
            
            if handle then
                local dist = (rootPart.Position - handle.Position).Magnitude
                if dist < 30 then
                    if clickDetector then
                        local posAnterior = rootPart.CFrame
                        rootPart.CFrame = CFrame.new(handle.Position + Vector3.new(0, 3, 0))
                        task.wait(0.1)
                        fireclickdetector(clickDetector)
                        task.wait(0.2)
                        rootPart.CFrame = posAnterior
                        break
                    end
                end
            end
        end
    end
end

-- ====== FUNÇÃO: Trocar Ilha ======
local function trocarIlha()
    local nivel = player.Data.Level.Value
    local melhorIlha = nil
    for _, ilha in ipairs(ilhas) do
        if nivel >= ilha.nivel then melhorIlha = ilha end
    end
    if melhorIlha then
        rootPart.CFrame = melhorIlha.coords
        print("[DRONX] Indo para " .. melhorIlha.nome)
        task.wait(2)
    end
end

-- ====== LOOP PRINCIPAL ======
coroutine.wrap(function()
    local semNPC = 0
    while true do
        task.wait(0.3)

        if getgenv().DRONX.AutoFarm then
            if character and character.Parent and humanoid and humanoid.Health > 0 then
                if getgenv().DRONX.AutoHeal then autoHeal() end
                if getgenv().DRONX.AutoCollect then autoCollect() end

                local npcValido = false
                if npcAtual and npcAtual.Parent then
                    local h = npcAtual:FindFirstChildOfClass("Humanoid")
                    if h and h.Health > 0 then npcValido = true end
                end

                if npcValido then
                    semNPC = 0
                    attackNPC(npcAtual)
                else
                    npcAtual = nil
                    local novo = getClosestNPC()
                    if novo then
                        semNPC = 0
                        npcAtual = novo
                        attackNPC(novo)
                    else
                        semNPC = semNPC + 1
                        if semNPC >= 30 then
                            trocarIlha()
                            semNPC = 0
                        end
                    end
                end
            else
                task.wait(2)
            end
        end
    end
end)()

-- ====== GUI (FLUENT) ======
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "DRONX HUB",
    SubTitle = "v3.2",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 320),
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Config = Window:AddTab({ Title = "Config", Icon = "settings" })
}

Tabs.Main:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Default = false,
    Callback = function(v)
        getgenv().DRONX.AutoFarm = v
        Fluent:Notify({
            Title = "DRONX",
            Content = v and "Farm ATIVADO!" or "Farm DESATIVADO",
            Duration = 3
        })
    end
})

Tabs.Main:AddToggle("AutoCollect", {
    Title = "Auto Coletar",
    Default = false,
    Callback = function(v) getgenv().DRONX.AutoCollect = v end
})

Tabs.Main:AddToggle("AutoHeal", {
    Title = "Auto Cura",
    Default = false,
    Callback = function(v) getgenv().DRONX.AutoHeal = v end
})

local StatusLabel = Tabs.Config:AddParagraph({
    Title = "Status",
    Content = "Carregando..."
})

coroutine.wrap(function()
    while task.wait(1) do
        pcall(function()
            local p = game.Players.LocalPlayer
            StatusLabel:SetDesc(
                "Nivel: " .. p.Data.Level.Value ..
                " | $: " .. p.Data.Beli.Value ..
                " | Vida: " .. math.floor(p.Character.Humanoid.Health)
            )
        end)
    end
end)()

print("[DRONX] Carregado com sucesso!")

-- ====== BOTÃO FLUTUANTE ======
local screenGuiBtn = Instance.new("ScreenGui")
screenGuiBtn.Name = "DRONX_BotaoFlutuante"
screenGuiBtn.ResetOnSpawn = false
screenGuiBtn.Parent = game:GetService("CoreGui") or game.Players.LocalPlayer:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Position = UDim2.new(0, 20, 0.5, -22)
toggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
toggleBtn.Text = "◀"
toggleBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
toggleBtn.TextSize = 22
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Draggable = true
toggleBtn.Parent = screenGuiBtn

local cornerBtn = Instance.new("UICorner")
cornerBtn.CornerRadius = UDim.new(1, 0)
cornerBtn.Parent = toggleBtn

local strokeBtn = Instance.new("UIStroke")
strokeBtn.Color = Color3.fromRGB(255, 215, 0)
strokeBtn.Thickness = 2
strokeBtn.Parent = toggleBtn

local guiAberta = true

local function encontrarFluent()
    local function procurar(pai)
        for _, gui in pairs(pai:GetChildren()) do
            if gui:IsA("ScreenGui") and gui ~= screenGuiBtn then
                if gui.Name:lower():find("fluent") 
                or gui.Name:lower():find("dawid") 
                or gui:FindFirstChild("Main") 
                or gui:FindFirstChild("Fluent") then
                    return gui
                end
            end
        end
        return nil
    end
    return procurar(game:GetService("CoreGui")) or procurar(game.Players.LocalPlayer.PlayerGui)
end

local fluentGui = encontrarFluent()
if not fluentGui then
    task.wait(2)
    fluentGui = encontrarFluent()
end

toggleBtn.MouseButton1Click:Connect(function()
    guiAberta = not guiAberta
    local sucesso = pcall(function()
        if guiAberta then Window:Show() else Window:Hide() end
    end)
    if not sucesso then
        if not fluentGui or not fluentGui.Parent then
            fluentGui = encontrarFluent()
        end
        if fluentGui then fluentGui.Enabled = guiAberta end
    end
    toggleBtn.Text = guiAberta and "◀" or "▶"
    toggleBtn.BackgroundColor3 = guiAberta and Color3.fromRGB(25, 25, 35) or Color3.fromRGB(50, 0, 0)
end)

print("[DRONX] Botão flutuante criado!")
