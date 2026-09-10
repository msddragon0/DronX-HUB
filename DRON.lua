-- ====== FUNÇÃO: Encontrar NPC mais próximo (melhorada) ======
local function getClosestNPC()
    local closest = nil
    local minDist = math.huge
    local level = player.Data.Level.Value

    -- Verifica se a pasta Enemies existe
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return nil end

    for _, npc in pairs(enemiesFolder:GetChildren()) do
        -- Verificações de segurança
        if npc:IsA("Model") 
        and npc:FindFirstChild("Humanoid") 
        and npc.Humanoid.Health > 0 
        and npc:FindFirstChild("HumanoidRootPart") then

            local npcLevel = npc:FindFirstChild("Level") and npc.Level.Value or 0
            -- Filtro de nível: só farma NPCs entre 5 níveis abaixo e 10 acima
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

-- ====== FUNÇÃO: Atacar NPC (versão segura, sem teleporte brusco) ======
local function attackNPC(npc)
    if not npc or not npc.Parent then return end
    if not npc:FindFirstChild("Humanoid") or npc.Humanoid.Health <= 0 then return end
    if not npc:FindFirstChild("HumanoidRootPart") then return end

    -- Move suavemente para perto do NPC (em vez de teleportar)
    local targetPos = npc.HumanoidRootPart.Position
    local currentPos = rootPart.Position
    local direction = (targetPos - currentPos).Unit
    local newPos = currentPos + direction * 5 -- fica a 5 studs do NPC

    -- Teleporte suave (apenas uma pequena distância)
    rootPart.CFrame = CFrame.new(newPos, targetPos)

    -- Espera o personagem chegar (com limite de tempo)
    local timeout = 0
    repeat
        task.wait(0.05)
        timeout = timeout + 1
    until (rootPart.Position - targetPos).Magnitude < 10 or timeout > 20

    -- Ataca com a tecla Q
    game:GetService("VirtualInputManager"):SendKeyEvent(true, "Q", false, game)
    task.wait(0.15)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, "Q", false, game)
end
