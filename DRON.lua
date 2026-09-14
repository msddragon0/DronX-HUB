-- ============================================================
-- DRONX v7.0 – ARQUIVO COMPLETO
-- cola tudo isso no executor, substitui o anterior inteiro
-- ============================================================

-- [ZONA 1: CONFIGURAÇÕES]
getgenv().DRONX = {
    Enabled       = true,
    AutoFarm      = false,
    AutoMaestria  = false,
    AutoHeal      = false,
    AutoCollect   = false,
    AutoQuest     = false,
    BringMob      = false,
    AntiAFK       = true,
    AutoBoss      = false,
    BossName      = "",
    AutoChest     = false,
    ESP           = false,
    TipoArma      = "Sword",
    MaxDistance   = 1000,
    HealThreshold = 0.5,
    posY          = 3,
    Kills         = 0,
    TweenSpeed    = 300,
}

-- [ZONA 2: SERVIÇOS & REFS]
local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local VirtualUser  = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local char, root, hum

local function fetchChar()
    char = player.Character or player.CharacterAdded:Wait()
    root = char:WaitForChild("HumanoidRootPart")
    hum  = char:WaitForChild("Humanoid")
end
fetchChar()
player.CharacterAdded:Connect(fetchChar)

-- [ZONA 3: UTILITÁRIOS]

-- Blox Fruits guarda mobs em vários lugares dependendo da sea/island
-- essa função varre o workspace inteiro procurando humanoids vivos
local function getClosestNPC()
    local maxDist = getgenv().DRONX.MaxDistance
    local closest, closestDist = nil, maxDist

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Health > 0 then
            local model = obj.Parent
            -- ignora o próprio player e outros players
            if model == char then continue end
            if Players:GetPlayerFromCharacter(model) then continue end

            local hrp = model:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = model
                end
            end
        end
    end

    return closest
end

local function equiparArma(tipo)
    local alvo = tipo or getgenv().DRONX.TipoArma
    for _, t in ipairs(player.Backpack:GetChildren()) do
        if t:IsA("Tool") and (t.ToolTip == alvo or t.Name == alvo) then
            hum:EquipTool(t)
            return
        end
    end
end

local function usarPocao()
    for _, t in ipairs(player.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.Name:lower():find("potion") then
            hum:EquipTool(t)
            task.wait(0.15)
            local act = t:FindFirstChild("Activate")
            if act then act:Fire() end
            return
        end
    end
end

-- [ZONA 4: MOVIMENTO]
local function tweenTo(targetCFrame)
    local dist = (targetCFrame.Position - root.Position).Magnitude
    local info = TweenInfo.new(dist / getgenv().DRONX.TweenSpeed, Enum.EasingStyle.Linear)
    local tw   = TweenService:Create(root, info, {CFrame = targetCFrame})
    tw:Play()
    tw.Completed:Wait()
end

-- [ZONA 5: SEGURANÇA]
local function antiBan()
    pcall(function()
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("LocalScript") then
                local n = v.Name
                if n == "General" or n == "Shiftlock" or n == "FallDamage" then
                    v:Destroy()
                end
            end
        end
    end)
end

local function checkGround()
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char}
    local result = workspace:Raycast(root.Position, Vector3.new(0, -15, 0), params)
    if not result then
        root.CFrame = root.CFrame * CFrame.new(0, 5, 0)
    end
end

-- [ZONA 6: COMBATE]

-- Blox Fruits: o ataque principal é via tool equipada
-- FireServer do remote direto é inconsistente entre versões
-- método mais estável: simular clique na tool equipada
local function atacar(npc)
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    local hrp = npc:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- vira o personagem pro NPC
    root.CFrame = CFrame.new(root.Position, hrp.Position)

    -- dispara o evento de ativação da tool (ataque)
    local handle = tool:FindFirstChild("Handle")
    if handle then
        -- simula o hit via LocalScript event da tool
        local remoteEvt = tool:FindFirstChildOfClass("RemoteEvent")
            or tool:FindFirstChildOfClass("RemoteFunction")
        if remoteEvt and remoteEvt:IsA("RemoteEvent") then
            pcall(function() remoteEvt:FireServer(hrp.Position) end)
        end
    end

    -- fallback: ativa a tool diretamente
    pcall(function()
        tool:Activate()
    end)
end

local function travarNPC(npc)
    local hrp = npc:FindFirstChild("HumanoidRootPart")
    local nhum = npc:FindFirstChildOfClass("Humanoid")
    if not (hrp and nhum) then return end

    pcall(function()
        nhum.WalkSpeed  = 0
        nhum.JumpPower  = 0
        hrp.CanCollide  = false
        -- posiciona o NPC na frente do player a distância de combate
        hrp.CFrame = root.CFrame * CFrame.new(0, 0, -8)
    end)
end

-- [ZONA 7: ENGINE PRINCIPAL]
task.spawn(function()
    while task.wait(0.15) do
        if not getgenv().DRONX.Enabled then continue end
        if not (char and root and hum) then continue end
        if hum.Health <= 0 then continue end

        antiBan()
        checkGround()

        -- AUTO FARM / MAESTRIA
        if getgenv().DRONX.AutoFarm or getgenv().DRONX.AutoMaestria then
            local npc = getClosestNPC()
