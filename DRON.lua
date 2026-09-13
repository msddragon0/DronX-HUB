-- ============================================================
-- DRONX v7.0 – ULTRA ENGINE (MAXIMIZED VERSION)
-- ============================================================

print("[DRONX] Carregando Engine Ultra...")

-- [ZONA 1: CONFIGURAÇÕES GLOBAIS & VARIÁVEIS]
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
    -- Variáveis de Controle de Velocidade (Tween)
    TweenSpeed = 300,
    BypassTP = true
}

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- [ZONA 2: MÓDULO DE SEGURANÇA & ANTI-BAN]
local Security = {}

function Security.AntiBan()
    pcall(function()
        -- Destruir scripts de detecção comuns
        for _, v in pairs(player.Character:GetDescendants()) do
            if v:IsA("LocalScript") then
                if v.Name == "General" or v.Name == "Shiftlock" or v.Name == "FallDamage" then
                    v:Destroy()
                end
            end
        end
        -- Limpar scripts do PlayerScripts
        for _, v in pairs(player.PlayerScripts:GetDescendants()) do
            if v:IsA("LocalScript") and (v.Name == "CamBob" or v.Name == "JumpCD") then
                v:Destroy()
            end
        end
    end)
end

function Security.checkGround()
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    local raycastResult = workspace:Raycast(rootPart.Position, Vector3.new(0, -15, 0), raycastParams)
    if not raycastResult then
        rootPart.CFrame = rootPart.CFrame * CFrame.new(0, 5, 0)
    end
end

-- [ZONA 3: MÓDULO DE MOVIMENTO (TWEEN & BYPASS)]
local Movement = {}

function Movement.TweenTo(targetCFrame)
    local distance = (targetCFrame.Position - rootPart.Position).Magnitude
    local speed = getgenv().DRONX.TweenSpeed
    
    local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
    
    tween:Play()
    return tween
end

function Movement.BypassTP()
    -- Simula o estado de queda para burlar o anti-cheat durante o TP
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    task.wait(0.1)
    humanoid:ChangeState(Enum.HumanoidStateType.Running)
end

-- [ZONA 4: MÓDULO DE COMBATE (ATTACK & HITBOX)]
local Combat = {}

function Combat.AttackNoCooldown()
    -- Lógica de ataque rápido (Simulando o Hit sem CD)
    pcall(function()
        if getgenv().DRONX_REMOTES.RegisterAttack then
            getgenv().DRONX_REMOTES.RegisterAttack:FireServer(0.4, 1, nil)
        end
    end)
end

function Combat.travarNPC(npc)
    local hrp = npc:FindFirstChild("HumanoidRootPart")
    local hum = npc:FindFirstChildOfClass("Humanoid")
    if hrp and hum then
        hum.WalkSpeed = 0
        hum.JumpPower = 0
        hrp.CanCollide = false
        -- Mantém o NPC a uma distância de combate segura
        local distanciaDesejada = 12 
        hrp.CFrame = rootPart.CFrame * CFrame.new(0, -getgenv().DRONX.posY, -distanciaDesejada)
    end
end

-- [ZONA 5: MÓDULO DE UTILITÁRIOS]
local Utils = {}

function Utils.equiparArma(tipo)
    local alvo = tipo or getgenv().DRONX.TipoArma
    for _, t in pairs(player.Backpack:GetChildren()) do
        if t:IsA("Tool") and (t.ToolTip == alvo or t.Name == alvo) then
            humanoid:EquipTool(t)
            return
        end
    end
end

-- [ZONA 6: O LOOP PRINCIPAL (ENGINE)]
task.spawn(function()
    while task.wait(0.3) do
        if not getgenv().DRONX.Enabled then continue end

        -- 1. Segurança constante
        Security.antiBan()
        Security.checkGround()

        -- 2. Lógica de Auto Farm
        if getgenv().DRONX.AutoFarm or getgenv().DRONX.AutoMaestria then
            local npc = getClosestNPC() -- Função que você já tem
            if npc then
                -- Trava o NPC
                Combat.travarNPC(npc)
                
                -- Ataca
                Combat.AttackNoCooldown()
                
                -- Auto Heal
                if getgenv().DRONX.AutoHeal and (humanoid.Health / humanoid.MaxHealth) < 0.5 then
                    -- Lógica de poção
                end
            end
        end
        
        -- 3. Anti-AFK
        if getgenv().DRONX.AntiAFK then
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):Button1Down(Vector2.new(0, 0))
            task.wait(0.05)
            game:GetService("VirtualUser"):Button1Up(Vector2.new(0, 0))
        end
    end
end)

-- [ZONA 7: INTERFACE (GUI)]
-- Aqui você mantém a sua estrutura do Fluent e chama os novos módulos!
-- Exemplo: No botão de Teleporte, use: Movement.TweenTo(CFrame)
-- Exemplo: No botão de Farm, use: Combat.AttackNoCooldown()

print("[DRONX] Engine Ultra Carregada!")
