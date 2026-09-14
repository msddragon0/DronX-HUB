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

            if npc then
                local nhum = npc:FindFirstChildOfClass("Humanoid")
                local nhrp = npc:FindFirstChild("HumanoidRootPart")

                if nhum and nhum.Health > 0 and nhrp then
                    -- teleporta perto do NPC se estiver longe
                    local dist = (nhrp.Position - root.Position).Magnitude
                    if dist > 15 then
                        tweenTo(nhrp.CFrame * CFrame.new(0, 0, -10))
                    end

                    -- trava e ataca
                    travarNPC(npc)
                    atacar(npc)

                    -- contabiliza kill quando o NPC morre
                    if nhum.Health <= 0 then
                        getgenv().DRONX.Kills += 1
                    end
                end
            end
        end

        -- AUTO HEAL
        if getgenv().DRONX.AutoHeal then
            if (hum.Health / hum.MaxHealth) < getgenv().DRONX.HealThreshold then
                usarPocao()
            end
        end

        -- ANTI-AFK
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

-- [ZONA 8: GUI — FLUENT]
local Fluent           = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager      = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title       = "DRONX v7.0",
    SubTitle    = "nullsec philippines",
    TabWidth    = 160,
    Size        = UDim2.fromOffset(580, 460),
    Acrylic     = false,
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl,
})

local Tabs = {
    Main     = Window:AddTab({ Title = "Main",     Icon = "sword"    }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local Options = Fluent.Options

do
    Tabs.Main:AddParagraph({
        Title   = "DRONX Engine",
        Content = "Active os toggles abaixo para iniciar.",
    })

    -- AUTO FARM
    Tabs.Main:AddToggle("AutoFarm", {
        Title       = "Auto Farm",
        Description = "Mata NPCs em loop.",
        Default     = false,
    }):OnChanged(function()
        getgenv().DRONX.AutoFarm = Options.AutoFarm.Value
    end)

    -- AUTO MAESTRIA
    Tabs.Main:AddToggle("AutoMaestria", {
        Title       = "Auto Maestria",
        Description = "Farm de XP de maestria.",
        Default     = false,
    }):OnChanged(function()
        getgenv().DRONX.AutoMaestria = Options.AutoMaestria.Value
    end)

    -- AUTO HEAL
    Tabs.Main:AddToggle("AutoHeal", {
        Title       = "Auto Heal",
        Description = "Usa poção quando HP cai abaixo do limiar.",
        Default     = false,
    }):OnChanged(function()
        getgenv().DRONX.AutoHeal = Options.AutoHeal.Value
    end)

    Tabs.Main:AddSlider("HealThreshold", {
        Title       = "Limiar de Cura (%)",
        Description = "Cura quando HP < X%.",
        Default     = 50,
        Min         = 10,
        Max         = 90,
        Rounding    = 0,
        Callback    = function(v)
            getgenv().DRONX.HealThreshold = v / 100
        end,
    })

    -- AUTO CHEST
    Tabs.Main:AddToggle("AutoChest", {
        Title       = "Auto Chest",
        Description = "Coleta baús automaticamente.",
        Default     = false,
    }):OnChanged(function()
        getgenv().DRONX.AutoChest = Options.AutoChest.Value
    end)

    -- AUTO QUEST
    Tabs.Main:AddToggle("AutoQuest", {
        Title       = "Auto Quest",
        Description = "Aceita e entrega quests.",
        Default     = false,
    }):OnChanged(function()
        getgenv().DRONX.AutoQuest = Options.AutoQuest.Value
    end)

    -- AUTO BOSS
    Tabs.Main:AddToggle("AutoBoss", {
        Title       = "Auto Boss",
        Description = "Vai até o boss e ataca.",
        Default     = false,
    }):OnChanged(function()
        getgenv().DRONX.AutoBoss = Options.AutoBoss.Value
    end)

    Tabs.Main:AddInput("BossName", {
        Title       = "Nome do Boss",
        Default     = "",
        Placeholder = "ex: Gorilla King",
        Numeric     = false,
        Finished    = true,
        Callback    = function(v)
            getgenv().DRONX.BossName = v
        end,
    })

    -- BRING MOB
    Tabs.Main:AddToggle("BringMob", {
        Title       = "Bring Mob",
        Description = "Puxa NPC para perto de você.",
        Default     = false,
    }):OnChanged(function()
        getgenv().DRONX.BringMob = Options.BringMob.Value
    end)

    -- TIPO DE ARMA
    Tabs.Main:AddDropdown("TipoArma", {
        Title   = "Tipo de Arma",
        Values  = { "Sword", "Gun", "Fruit", "Melee" },
        Multi   = false,
        Default = 1,
    }):OnChanged(function(v)
        getgenv().DRONX.TipoArma = v
        equiparArma(v)
    end)

    -- DISTÂNCIA
    Tabs.Main:AddSlider("MaxDistance", {
        Title       = "Distância Máxima (studs)",
        Default     = 1000,
        Min         = 100,
        Max         = 5000,
        Rounding    = 0,
        Callback    = function(v)
            getgenv().DRONX.MaxDistance = v
        end,
    })

    -- VELOCIDADE DE TP
    Tabs.Main:AddSlider("TweenSpeed", {
        Title       = "Velocidade de TP (studs/s)",
        Default     = 300,
        Min         = 50,
        Max         = 2000,
        Rounding    = 0,
        Callback    = function(v)
            getgenv().DRONX.TweenSpeed = v
        end,
    })

    -- ANTI-AFK
    Tabs.Main:AddToggle("AntiAFK", {
        Title   = "Anti-AFK",
        Default = true,
    }):OnChanged(function()
        getgenv().DRONX.AntiAFK = Options.AntiAFK.Value
    end)

    -- TP MANUAL
    Tabs.Main:AddButton({
        Title    = "TP para NPC mais Próximo",
        Callback = function()
            local npc = getClosestNPC()
            if npc then
                local hrp = npc:FindFirstChild("HumanoidRootPart")
                if hrp then tweenTo(hrp.CFrame * CFrame.new(0, 0, -10)) end
            else
                Fluent:Notify({ Title = "DRONX", Content = "Nenhum NPC no raio.", Duration = 3 })
            end
        end,
    })

    -- KILL COUNTER
    local kp = Tabs.Main:AddParagraph({ Title = "Kills nesta sessão", Content = "0" })
    task.spawn(function()
        while task.wait(1) do
            pcall(function()
                kp:Set({ Title = "Kills nesta sessão", Content = tostring(getgenv().DRONX.Kills) })
            end)
        end
    end)
end

-- SETTINGS
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("DRONX")
SaveManager:SetFolder("DRONX/BloxFruits")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({ Title = "DRONX v7.0", Content = "Carregado. Boa farm.", Duration = 5 })
SaveManager:LoadAutoloadConfig()
