-- ============================================================
-- DRONX v7.0 – ULTRA ENGINE (COMPLETA)
-- ============================================================

print("[DRONX] Carregando Engine Ultra...")

-- [ZONA 1: CONFIGURAÇÕES GLOBAIS]
getgenv().DRONX = {
    Enabled      = true,
    AutoFarm     = false,
    AutoMaestria = false,
    AutoHeal     = false,
    AutoCollect  = false,
    AutoQuest    = false,
    BringMob     = false,
    AntiAFK      = true,
    AutoBoss     = false,
    BossName     = "",
    AutoChest    = false,
    ESP          = false,
    TipoArma     = "Sword",
    MaxDistance  = 1000,
    HealThreshold= 0.5,
    posY         = 3,
    Kills        = 0,
    TweenSpeed   = 300,
    BypassTP     = true,
}

getgenv().DRONX_REMOTES = {}

-- [ZONA 2: REFS DO PLAYER — COM RE-FETCH NO RESPAWN]
local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local VirtualUser  = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local character, rootPart, humanoid

local function fetchCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    rootPart  = character:WaitForChild("HumanoidRootPart")
    humanoid  = character:WaitForChild("Humanoid")
end

fetchCharacter()
player.CharacterAdded:Connect(fetchCharacter)

-- [ZONA 3: POPULANDO REMOTES]
-- Blox Fruits guarda os remotes dentro de ReplicatedStorage após o jogo carregar.
-- Ajuste os nomes conforme a versão atual do jogo.
task.defer(function()
    local RS = game:GetService("ReplicatedStorage")
    -- Tenta capturar o remote de ataque — nome pode variar por versão
    local ok, rem = pcall(function()
        return RS:WaitForChild("Remotes", 5):WaitForChild("CommF_", 5)
    end)
    if ok and rem then
        getgenv().DRONX_REMOTES.RegisterAttack = rem
    else
        warn("[DRONX] Remote de ataque não encontrado — verifique o nome no seu executor.")
    end
end)

-- [ZONA 4: SEGURANÇA & ANTI-BAN]
local Security = {}

function Security.AntiBan()
    pcall(function()
        for _, v in ipairs(character:GetDescendants()) do
            if v:IsA("LocalScript") then
                local n = v.Name
                if n == "General" or n == "Shiftlock" or n == "FallDamage" then
                    v:Destroy()
                end
            end
        end
        for _, v in ipairs(player.PlayerScripts:GetDescendants()) do
            if v:IsA("LocalScript") then
                local n = v.Name
                if n == "CamBob" or n == "JumpCD" then
                    v:Destroy()
                end
            end
        end
    end)
end

function Security.CheckGround()
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {character}
    local result = workspace:Raycast(rootPart.Position, Vector3.new(0, -15, 0), params)
    if not result then
        rootPart.CFrame = rootPart.CFrame * CFrame.new(0, 5, 0)
    end
end

-- [ZONA 5: MOVIMENTO]
local Movement = {}

function Movement.TweenTo(targetCFrame)
    local dist  = (targetCFrame.Position - rootPart.Position).Magnitude
    local speed = getgenv().DRONX.TweenSpeed
    local info  = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(rootPart, info, {CFrame = targetCFrame})
    tween:Play()
    return tween
end

function Movement.BypassTP()
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    task.wait(0.1)
    humanoid:ChangeState(Enum.HumanoidStateType.Running)
end

-- [ZONA 6: COMBATE]
local Combat = {}

function Combat.AttackNoCooldown()
    pcall(function()
        local rem = getgenv().DRONX_REMOTES.RegisterAttack
        if rem then
            rem:FireServer(0.4, 1, nil)
        end
    end)
end

function Combat.TravarNPC(npc)
    local hrp = npc:FindFirstChild("HumanoidRootPart")
    local hum = npc:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end
    pcall(function()
        hum.WalkSpeed  = 0
        hum.JumpPower  = 0
        hrp.CanCollide = false
        hrp.CFrame = rootPart.CFrame * CFrame.new(0, -getgenv().DRONX.posY, -12)
    end)
end

-- [ZONA 7: UTILITÁRIOS]
local Utils = {}

function Utils.EquiparArma(tipo)
    local alvo = tipo or getgenv().DRONX.TipoArma
    for _, t in ipairs(player.Backpack:GetChildren()) do
        if t:IsA("Tool") and (t.ToolTip == alvo or t.Name == alvo) then
            humanoid:EquipTool(t)
            return
        end
    end
end

-- Retorna o NPC mais próximo dentro de MaxDistance
function Utils.GetClosestNPC()
    local maxDist = getgenv().DRONX.MaxDistance
    local closest, closestDist = nil, maxDist

    -- Blox Fruits guarda mobs em workspace — ajuste a pasta se necessário
    local folder = workspace:FindFirstChild("Enemies") or workspace

    for _, model in ipairs(folder:GetChildren()) do
        local hum = model:FindFirstChildOfClass("Humanoid")
        local hrp = model:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 then
            local dist = (hrp.Position - rootPart.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = model
            end
        end
    end

    return closest
end

function Utils.UsarPocao()
    -- Blox Fruits: poções ficam no Backpack como Tools
    for _, t in ipairs(player.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.Name:lower():find("potion") then
            humanoid:EquipTool(t)
            task.wait(0.1)
            -- Simula ativação
            local fa = t:FindFirstChildOfClass("LocalScript")
            if fa then
                local ev = t:FindFirstChild("Activate")
                if ev then ev:Fire() end
            end
            return
        end
    end
end

-- [ZONA 8: ENGINE PRINCIPAL]
task.spawn(function()
    while task.wait(0.3) do
        if not getgenv().DRONX.Enabled then continue end
        if not (character and rootPart and humanoid) then continue end
        if humanoid.Health <= 0 then continue end

        -- Segurança constante
        Security.AntiBan()
        Security.CheckGround()

        -- Auto Farm / Maestria
        if getgenv().DRONX.AutoFarm or getgenv().DRONX.AutoMaestria then
            local npc = Utils.GetClosestNPC()
            if npc then
                Combat.TravarNPC(npc)
                Combat.AttackNoCooldown()

                -- Auto Heal
                if getgenv().DRONX.AutoHeal then
                    local pct = humanoid.Health / humanoid.MaxHealth
                    if pct < getgenv().DRONX.HealThreshold then
                        Utils.UsarPocao()
                    end
                end
            end
        end

        -- Anti-AFK
        if getgenv().DRONX.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(0, 0))
                task.wait(0.05)
                VirtualUser:Button1Up(Vector2.new(0, 0))
            end)
        end
    end
end)

-- [ZONA 9: GUI — FLUENT / RAYFIELD / QUALQUER LIB]
-- Conecte os toggles assim:
--
--   Toggle AutoFarm:
--     getgenv().DRONX.AutoFarm = true/false
--
--   Botão Teleportar até NPC:
--     local npc = Utils.GetClosestNPC()
--     if npc then Movement.TweenTo(npc.HumanoidRootPart.CFrame) end
--
--   Slider MaxDistance:
--     getgenv().DRONX.MaxDistance = valor
--
--   Slider TweenSpeed:
--     getgenv().DRONX.TweenSpeed = valor
--
-- Se quiser que eu monte a GUI completa com Fluent/Rayfield, manda falar.

print("[DRONX] Engine Ultra Carregada!")
