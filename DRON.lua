-- ============================================================
-- DRONX v3.1 – Auto Farm + Fluent UI (FINAL)
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

-- ====== FUNÇÕES ======
-- ====== HOOK DE ATAQUE (AttackNoCoolDown) ======
local CombatFramework = require(game:GetService("Players").LocalPlayer.PlayerScripts.CombatFramework)
local CameraShaker = require(game.ReplicatedStorage.Util.CameraShaker)
CameraShaker:Stop()
local AC = debug.getupvalues(CombatFramework)[2]

-- Função que ataca sem cooldown
local function atacarRapido()
    pcall(function()
        if not AC or not AC.activeController then return end
        local controller = AC.activeController
        controller.attacking = false
        controller.timeToNextAttack = 0
        controller.hitboxMagnitude = 60
        ...
local CameraShaker = require(game.ReplicatedStorage.Util.CameraShaker)
CameraShaker:Stop()
local AC = debug.getupvalues(CombatFramework)[2]

-- Função que ataca sem cooldown
local function atacarRapido()
    pcall(function()
        if not AC or not AC.activeController then return end
        local controller = AC.activeController
        controller.attacking = false
        controller.timeToNextAttack = 0
        controller.hitboxMagnitude = 60
        
        -- Pega os alvos perto
        local bladeHits = require(game.ReplicatedStorage.CombatFramework.RigLib).getBladeHits(
            player.Character,
            {player.Character.HumanoidRootPart},
            60
        )
        
        local targets = {}
        local hash = {}
        for _, v in pairs(bladeHits) do
            if v.Parent:FindFirstChild("HumanoidRootPart") and not hash[v.Parent] then
                table.insert(targets, v.Parent.HumanoidRootPart)
                hash[v.Parent] = true
            end
        end
        
        if #targets > 0 then
            -- Força o próximo ataque
            game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("hit", targets, 1, "")
            -- Toca animação
            pcall(function()
                for _, anim in pairs(controller.animator.anims.basic) do
                    anim:Play()
                end
            end)
        end
    end)
end

-- Equipa arma (melee de preferência)
local function equiparArma()
    pcall(function()
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.ToolTip == "Melee" or tool.ToolTip == "Sword") then
                player.Character.Humanoid:EquipTool(tool)
                return
            end
        end
    end)
end

-- Ativa Haki Busho (pra dar mais dano)
local function autoHaki()
    if not player.Character:FindFirstChild("HasBuso") then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
    end
end

-- ====== FUNÇÃO: Achar NPC (melhorada) ======
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

-- ====== FUNÇÃO: Atacar NPC (com bring mob) ======
-- ====== FUNÇÃO: Atacar NPC (em cima + longo alcance) ======
local function attackNPC(npc)
    if not npc or not npc.Parent then return end
    local hum = npc:FindFirstChildOfClass("Humanoid")
    local hrp = npc:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not hrp then return end

    -- 🔥 TELEPORTA PRA CIMA do NPC
    rootPart.CFrame = hrp.CFrame * CFrame.new(0, 1, 0)
    task.wait(0.05)

    -- 🔥 Prende o NPC embaixo de você
    pcall(function()
        hum.WalkSpeed = 0
        hum.JumpPower = 0
        hrp.CanCollide = false
        hrp.Size = Vector3.new(60, 60, 60)
        hrp.CFrame = rootPart.CFrame * CFrame.new(0, -1, 0)
    end)

    equiparArma()
    autoHaki()

    -- Ataca 3x por ciclo (rápido)
    atacarRapido()
    task.wait(0.05)
    atacarRapido()
    task.wait(0.05)
    atacarRapido()
end

-- ====== FUNÇÃO: Cura (todas as poções do jogo) ======
local function autoHeal()
    if not humanoid or humanoid.Health <= 0 then return end
    if humanoid.Health / humanoid.MaxHealth < getgenv().DRONX.HealThreshold then
        -- Lista completa de itens de cura do Blox Fruits
        local pociones = {
            "Potion",           -- Poção comum
            "Devil Fruit",      -- Fruta do diabo (cura HP se equipada)
            "Mochi",            -- Comida que cura
            "Dough",            -- Comida que cura
            "Ice Cream",        -- Sorvete (cura)
            "Cake",             -- Bolo (cura)
            "Candy",            -- Doce (cura)
            "Chocolate",        -- Chocolate (cura)
            "Bomb",             -- Fruta (não cura, mas tenta)
        }
        for _, nome in ipairs(pociones) do
            local item = player.Backpack:FindFirstChild(nome) or character:FindFirstChild(nome)
            if item and item:IsA("Tool") then
                pcall(function()
                    -- Equipa o item
                    if item.Parent == player.Backpack then
                        player.Character.Humanoid:EquipTool(item)
                        task.wait(0.1)
                    end
                    -- Ativa (usa) o item
                    item:Activate()
                    task.wait(0.3)
                end)
                return
            end
        end
    end
end

-- ====== FUNÇÃO: Coletar (funciona pra tudo) ======
-- ====== FUNÇÃO: Coletar (sem bugar o farm) ======
local function autoCollect()
    -- Só coleta se NÃO estiver atacando NPC no momento
    if npcAtual and npcAtual.Parent then
        local h = npcAtual:FindFirstChildOfClass("Humanoid")
        if h and h.Health > 0 then
            return -- Sai da função se ainda tem NPC vivo
        end
    end

    for _, item in pairs(workspace:GetChildren()) do
        if item:IsA("Model") or item:IsA("Tool") then
            local handle = item:FindFirstChild("Handle")
            local clickDetector = item:FindFirstChildOfClass("ClickDetector") 
                or (handle and handle:FindFirstChildOfClass("ClickDetector"))
            
            if handle then
                local dist = (rootPart.Position - handle.Position).Magnitude
                if dist < 30 then
                    -- Só coleta item que tem ClickDetector (é coletável)
                    if clickDetector then
                        -- Teleporta rápido, clica e volta
                        local posAnterior = rootPart.CFrame
                        rootPart.CFrame = CFrame.new(handle.Position + Vector3.new(0, 3, 0))
                        task.wait(0.1)
                        fireclickdetector(clickDetector)
                        task.wait(0.2)
                        rootPart.CFrame = posAnterior
                        break -- Coleta 1 item por ciclo (não buga)
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
            -- Verifica se está vivo
            if character and character.Parent and humanoid and humanoid.Health > 0 then
                -- Cura
                if getgenv().DRONX.AutoHeal then autoHeal() end

                -- Coleta
                if getgenv().DRONX.AutoCollect then autoCollect() end

                -- Verifica NPC atual
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
    SubTitle = "v3.1",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 320),
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Config = Window:AddTab({ Title = "Config", Icon = "settings" })
}

-- Toggle Auto Farm (ÚNICO)
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

-- ====== BOTÃO FLUTUANTE (ABRIR/FECHAR GUI) ======
local screenGuiBtn = Instance.new("ScreenGui")
screenGuiBtn.Name = "DRONX_BotaoFlutuante"
screenGuiBtn.ResetOnSpawn = false
screenGuiBtn.Parent = game:GetService("CoreGui") or game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Botão redondo
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

-- Borda arredondada
local cornerBtn = Instance.new("UICorner")
cornerBtn.CornerRadius = UDim.new(1, 0)
cornerBtn.Parent = toggleBtn

-- Borda dourada
local strokeBtn = Instance.new("UIStroke")
strokeBtn.Color = Color3.fromRGB(255, 215, 0)
strokeBtn.Thickness = 2
strokeBtn.Parent = toggleBtn

-- Variável de estado
local guiAberta = true

-- Função que acha a GUI do Fluent (SEM pegar a do botão)
local function encontrarFluent()
    local function procurar(pai)
        for _, gui in pairs(pai:GetChildren()) do
            if gui:IsA("ScreenGui") and gui ~= screenGuiBtn then
                -- Procura por filhos típicos do Fluent
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
    
    local fluenteCore = procurar(game:GetService("CoreGui"))
    if fluenteCore then return fluenteCore end
    
    local fluentePlayer = procurar(game.Players.LocalPlayer.PlayerGui)
    if fluentePlayer then return fluentePlayer end
    
    return nil
end

-- Guarda referência à GUI do Fluent
local fluentGui = encontrarFluent()

-- Se não achou de primeira, espera um pouco
if not fluentGui then
    task.wait(2)
    fluentGui = encontrarFluent()
end

-- Função que alterna (SEM afetar o botão)
toggleBtn.MouseButton1Click:Connect(function()
    guiAberta = not guiAberta
    
    -- Tentativa 1: API nativa do Fluent
    local sucesso = pcall(function()
        if guiAberta then
            Window:Show()
        else
            Window:Hide()
        end
    end)
    
    -- Tentativa 2: Procurar e alternar a ScreenGui específica
    if not sucesso then
        if not fluentGui or not fluentGui.Parent then
            fluentGui = encontrarFluent()
        end
        if fluentGui then
            fluentGui.Enabled = guiAberta
        end
    end
    
    -- Troca o ícone
    toggleBtn.Text = guiAberta and "◀" or "▶"
    toggleBtn.BackgroundColor3 = guiAberta and Color3.fromRGB(25, 25, 35) or Color3.fromRGB(50, 0, 0)
    
    print("[DRONX] GUI " .. (guiAberta and "ABERTA" or "FECHADA"))
end)

print("[DRONX] Botão flutuante criado!")
