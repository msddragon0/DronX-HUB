-- ============================================================
-- DRONX v7.0 – ENGINE CORE (VERSÃO COMPLETA E ESTRUTURADA)
-- ============================================================

print("[DRONX] Inicializando Sistema...")

-- [ZONA 1: CONFIGURAÇÕES GLOBAIS]
getgenv().DRONX = {
    Enabled = true,
    AutoFarm = false,
    AutoMaestria = false,
    AutoHeal = false,
    AutoCollect = false,
    AutoQuest = false,
    BringMob = false,
    AntiAFK = true,
    AutoBoss = false,
    BossName = "",
    AutoChest = false,
    ESP = false,
    FPS = false,
    Fog = false,
    TipoArma = "Sword",
    MaxDistance = 1000,
    HealThreshold = 0.5,
    posY = 3,
    Kills = 0,
}

-- [ZONA 2: VARIÁVEIS DE ESTADO E PLAYER]
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Captura de Remotes (Sua lógica original)
getgenv().DRONX_REMOTES = getgenv().DRONX_REMOTES or {}
task.spawn(function()
    local caminhos = {
        function()
            local net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
            if net then
                local re = net:FindFirstChild("RE")
                if re then return re:FindFirstChild("RegisterAttack") end
            end
        end,
        function()
            local net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
            if net then return net:FindFirstChild("RegisterAttack") end
        end,
        function() return ReplicatedStorage:FindFirstChild("RegisterAttack", true) end,
    }
    for i, caminho in ipairs(caminhos) do
        local ok, remote = pcall(caminho)
        if ok and remote then
            getgenv().DRONX_REMOTES.RegisterAttack = remote
            break
        end
    end
end)

-- [ZONA 3: MÓDULO DE SEGURANÇA]
local Security = {}

function Security.checkGround()
    if not rootPart then return end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local raycastResult = workspace:Raycast(rootPart.Position, Vector3.new(0, -15, 0), raycastParams)
    if not raycastResult then
        rootPart.CFrame = rootPart.CFrame * CFrame.new(0, 5, 0)
    end
end

function Security.antiAFK()
    if getgenv().DRONX.AntiAFK then
        pcall(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):Button1Down(Vector2.new(0, 0))
            task.wait(0.05)
            game:GetService("VirtualUser"):Button1Up(Vector2.new(0, 0))
        end)
    end
end

-- [ZONA 4: MÓDULO DE COMBATE - AJUSTADO PARA ATAQUE DE LONGE]
local Combat = {}

function Combat.atacarRapido(npc)
    if not npc or not npc:FindFirstChild("HumanoidRootPart") then return end
    
    -- 1. Mantém o personagem olhando para o NPC
    rootPart.CFrame = CFrame.new(rootPart.Position, npc.HumanoidRootPart.Position)
    
    -- 2. Disparo do Remote de Ataque
    if getgenv().DRONX_REMOTES and getgenv().DRONX_REMOTES.RegisterAttack then
        -- Simula o ataque
        getgenv().DRONX_REMOTES.RegisterAttack:FireServer(0.4, 1, nil)
    end
end

function Combat.travarNPC(npc)
    local hrp = npc:FindFirstChild("HumanoidRootPart")
    local hum = npc:FindFirstChildOfClass("Humanoid")
    
    if hrp and hum then
        -- 1. Trava o movimento do NPC para ele não fugir
        hum.WalkSpeed = 0
        hum.JumpPower = 0
        
        -- 2. Posicionamento de Distância (O SEGREDO)
        -- Em vez de ficar em cima, o NPC será mantido a uma distância de 15 a 20 studs
        -- Isso evita que você tome dano e permite usar a hitbox de longe
        local distanciaDesejada = 15 
        local posicaoAlvo = rootPart.Position + (rootPart.CFrame.LookVector * distanciaDesejada)
        
        hrp.CFrame = CFrame.new(posicaoAlvo, rootPart.Position)
        
        -- 3. Desativa colisão para não bugar o personagem
        hrp.CanCollide = false
    end
end
function getClosestNPC()
    local closest, minDist = nil, math.huge
    local folder = workspace:FindFirstChild("Enemies")
    if not folder then return nil end
    for _, npc in pairs(folder:GetChildren()) do
        if npc:IsA("Model") and not npc.Name:lower():find("brigade") and not npc.Name:lower():find("boat") then
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

-- [ZONA 5: MÓDULO DE UTILITÁRIOS]
local Utils = {}

function Utils.teleport(cframe)
    if not rootPart then return end
    task.wait(0.1) 
    rootPart.CFrame = cframe
    rootPart.Velocity = Vector3.new(0, 0, 0)
    rootPart.RotVelocity = Vector3.new(0, 0, 0)
    print("[DRONX] Teleportado!")
end

function Utils.equiparArma(tipo)
    local alvo = tipo or getgenv().DRONX.TipoArma
    for _, t in pairs(player.Backpack:GetChildren()) do
        if t:IsA("Tool") and (t.ToolTip == alvo or t.Name == alvo) then
            humanoid:EquipTool(t)
            return
        end
    end
end

-- [DADOS: QUESTS, BOSSES, ILHAS]
local quests = {
    {lvl = 1500, mon = "Pirate Millionaire", quest = "PiratePortQuest", qlvl = 1, questPos = CFrame.new(-289, 43, 5580)},
    -- (Adicione as outras aqui conforme seu script original)
}

local bosses = {
    {nome = "Stone", pos = CFrame.new(-1027, 92, 6578)},
    -- (Adicione as outras aqui conforme seu script original)
}

local ilhas = {
    {nome = "⚓ Windmill Village (1st)", pos = CFrame.new(979, 16, 1429)},
    -- (Adicione as outras aqui conforme seu script original)
}

-- [ZONA 6: LOOP PRINCIPAL]
task.spawn(function()
    while task.wait(0.3) do
        if not getgenv().DRONX.Enabled then continue end

        Security.antiAFK()

        if getgenv().DRONX.AutoFarm or getgenv().DRONX.AutoMaestria then
            Security.checkGround()

            -- 1. Busca o NPC mais próximo (usando sua função original)
            local npc = getClosestNPC() 
            
            if npc then
                -- 2. Verifica se o NPC ainda é válido (tem vida e está no jogo)
                local hum = npc:FindFirstChildOfClass("Humanoid")
                local hrp = npc:FindFirstChild("HumanoidRootPart")
                
                if hum and hum.Health > 0 and hrp then
                    -- 3. Aplica o combo de Farm
                    Combat.travarNPC(npc) -- Trava o NPC na sua frente
                    Combat.atacarRapido(npc) -- Ataca o NPC
                    
                    -- 4. Auto Heal (Se estiver com pouca vida)
                    if getgenv().DRONX.AutoHeal and (humanoid.Health / humanoid.MaxHealth) < 0.5 then
                        local p = player.Backpack:FindFirstChild("Potion") or character:FindFirstChild("Potion")
                        if p then pcall(function() p:Activate() end) end
                    end
                end
            end
        end
    end
end)

-- [ZONA 7: INTERFACE (GUI)]
-- Carregamento da Fluent
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title = "DRONX HUB",
    SubTitle = "v7.0",
    TabWidth = 150,
    Size = UDim2.fromOffset(520, 350),
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Shop = Window:AddTab({ Title = "Shop", Icon = "shopping-cart" }),
    TP = Window:AddTab({ Title = "Teleport", Icon = "map" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Config = Window:AddTab({ Title = "Config", Icon = "settings" }),
}

-- Exemplo de Configuração de Botão de Teleporte
for _, ilha in ipairs(ilhas) do
    Tabs.TP:AddButton({
        Title = ilha.nome,
        Callback = function()
            Utils.teleport(ilha.pos)
            task.wait(0.5)
            Security.checkGround()
        end
    })
end

-- Configurações de Menu (Exemplo)
Tabs.Main:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Default = false,
    Callback = function(v) getgenv().DRONX.AutoFarm = v end
})

print("[DRONX] v7.0 Carregado com Sucesso!")
