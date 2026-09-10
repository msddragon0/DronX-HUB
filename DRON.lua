-- ============================================================
-- DRONX – TESTE DE DEBUG
-- ============================================================

print("[DRONX] Iniciando teste...")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Teste 1: Verificar se a pasta Enemies existe
if not workspace:FindFirstChild("Enemies") then
    warn("[DRONX] ERRO: A pasta 'Enemies' não existe no workspace!")
else
    print("[DRONX] Pasta Enemies encontrada. Total de NPCs:", #workspace.Enemies:GetChildren())
end

-- Teste 2: Verificar se o jogador tem Data e Level
if player:FindFirstChild("Data") and player.Data:FindFirstChild("Level") then
    print("[DRONX] Nível do jogador:", player.Data.Level.Value)
else
    warn("[DRONX] ERRO: Dados do jogador (Data/Level) não carregaram ainda!")
end

-- Teste 3: Função de ataque simplificada
local function testarAtaque()
    print("[DRONX] Tentando atacar...")
    game:GetService("VirtualInputManager"):SendKeyEvent(true, "Q", false, game)
    task.wait(0.1)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, "Q", false, game)
end

-- Teste 4: Loop principal com prints
coroutine.wrap(function()
    while true do
        task.wait(2)
        if getgenv().DRONX and getgenv().DRONX.Ativo then
            print("[DRONX] Loop ativo rodando...")
            
            -- Tenta encontrar qualquer inimigo (sem filtro de nível)
            local npcEncontrado = nil
            for _, npc in pairs(workspace.Enemies:GetChildren()) do
                if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                    npcEncontrado = npc
                    break
                end
            end

            if npcEncontrado then
                print("[DRONX] NPC encontrado:", npcEncontrado.Name)
                -- Teleporta para perto e ataca
                if npcEncontrado:FindFirstChild("HumanoidRootPart") then
                    rootPart.CFrame = npcEncontrado.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                    task.wait(0.2)
                    testarAtaque()
                end
            else
                warn("[DRONX] Nenhum NPC vivo encontrado na pasta Enemies.")
            end
        end
    end
end)()

print("[DRONX] Teste carregado. Ative o Auto Farm na GUI e veja o console.")
