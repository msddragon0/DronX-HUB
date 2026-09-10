-- ====== FUNÇÃO: Encontrar NPC mais próximo (raio grande) ======
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
                if dist < minDist and dist <= 1000 then
                    minDist = dist
                    closest = npc
                end
            end
        end
    end
    return closest
end

-- ====== FUNÇÃO: Atacar NPC (teleporte direto) ======
local function attackNPC(npc)
    if not npc or not npc.Parent then return end
    local hum = npc:FindFirstChildOfClass("Humanoid")
    local hrp = npc:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not hrp then return end

    rootPart.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 0, 5), hrp.Position)
    task.wait(0.15)

    game:GetService("VirtualInputManager"):SendKeyEvent(true, "Q", false, game)
    task.wait(0.15)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, "Q", false, game)
end
