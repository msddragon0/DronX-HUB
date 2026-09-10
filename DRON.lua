-- ============================================================
-- DRONX v3.0 – Auto Farm + Fluent UI
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

-- ====== FUNÇÃO: Atacar NPC (COM TWEEN) ======
local function attackNPC(npc)
    if not npc or not npc.Parent then return end
    local hum = npc:FindFirstChildOfClass("Humanoid")
    local hrp = npc:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not hrp then return end

    -- Tween suave (em vez de teleporte)
    local dist = (rootPart.Position - hrp.Position).Magnitude
    if dist > 15 then
        local tween = game:GetService("TweenService"):Create(
            rootPart,
            TweenInfo.new(dist / 300, Enum.EasingStyle.Linear),
            { CFrame = hrp.CFrame * CFrame.new(0, 3, 0) }
        )
        tween:Play()
        tween.Completed:Wait()
    end

    -- Ataca com Q
    game:GetService("VirtualInputManager"):SendKeyEvent(true, "Q", false, game)
    task.wait(0.1)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, "Q", false, game)
end

-- ====== FUNÇÃO: Cura ======
local function autoHeal()
    if not humanoid or humanoid.Health <= 0 then return end
    if humanoid.Health / humanoid.MaxHealth < getgenv().DRONX.HealThreshold then
        local potion = player.Backpack:FindFirstChild("Potion") or character:FindFirstChild("Potion")
        if potion then potion.Activate:FireServer() end
    end
end

-- ====== FUNÇÃO: Coletar ======
local function autoCollect()
    for _, item in pairs(workspace:GetChildren()) do
        if item:IsA("Model") and item.Name:lower():find("fruit") then
            if item:FindFirstChild("Handle") then
                if (rootPart.Position - item.Handle.Position).Magnitude < 30 then
                    rootPart.CFrame = item.Handle.CFrame
                    task.wait(0.2)
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
local npcAtual = nil

coroutine.wrap(function()
    local semNPC = 0
    while true do
        task.wait(0.3)

        if getgenv().DRONX.AutoFarm then
            -- Se morreu, espera respawnar
            if not character or not character.Parent or not humanoid or humanoid.Health <= 0 then
                task.wait(2)
                continue
            end

            -- Cura automática (MUDANÇA 3 AQUI)
            if getgenv().DRONX.AutoHeal then
                autoHeal()
            end

            -- Coleta automática
            if getgenv().DRONX.AutoCollect then
                autoCollect()
            end

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
                    if semNPC >= 5 then
                        trocarIlha()
                        semNPC = 0
                    end
                end
            end
        end
    end
end)()

-- ====== GUI (FLUENT) ======
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "DRONX HUB",
    SubTitle = "v3.0",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 320),
    Theme = "Dark"
})

local Tabs = {
    Farm = Window:AddTab({ Title = "Farm", Icon = "home" }),
    Config = Window:AddTab({ Title = "Config", Icon = "settings" })
}

Tabs.Farm:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Default = false,
    Callback = function(v) getgenv().DRONX.AutoFarm = v end
})

Tabs.Farm:AddToggle("AutoCollect", {
    Title = "Auto Coletar",
    Default = false,
    Callback = function(v) getgenv().DRONX.AutoCollect = v end
})

Tabs.Farm:AddToggle("AutoHeal", {
    Title = "Auto Cura",
    Default = false,
    Callback = function(v) getgenv().DRONX.AutoHeal = v end
})

-- Notificação quando ligar/desligar Auto Farm
Tabs.Farm:AddToggle("AutoFarm", {
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
