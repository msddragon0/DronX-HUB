-- ============================================================
-- DRONX v7.0 – ZONA 9: GUI (FLUENT) — ABA MAIN
-- Cola isso logo abaixo do print("[DRONX] Engine Ultra Carregada!")
-- ============================================================

-- [LIBS]
local Fluent          = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager     = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager= loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- [JANELA]
local Window = Fluent:CreateWindow({
    Title       = "DRONX v7.0",
    SubTitle    = "nullsec philippines",
    TabWidth    = 160,
    Size        = UDim2.fromOffset(580, 460),
    Acrylic     = false,   -- blur pode ser detectado — off por padrão
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl,
})

-- [ABAS]
local Tabs = {
    Main     = Window:AddTab({ Title = "Main",     Icon = "sword"   }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local Options = Fluent.Options

-- ============================================================
-- ABA MAIN
-- ============================================================
do
    -- ── AVISO ────────────────────────────────────────────────
    Tabs.Main:AddParagraph({
        Title   = "DRONX Engine",
        Content = "Todos os módulos rodam em background.\nDesative o script antes de fechar o jogo.",
    })

    -- ── AUTO FARM ────────────────────────────────────────────
    local ToggleFarm = Tabs.Main:AddToggle("AutoFarm", {
        Title       = "Auto Farm",
        Description = "Mata o NPC mais próximo em loop.",
        Default     = false,
    })
    ToggleFarm:OnChanged(function()
        getgenv().DRONX.AutoFarm = Options.AutoFarm.Value
    end)

    -- ── AUTO MAESTRIA ─────────────────────────────────────────
    local ToggleMaestria = Tabs.Main:AddToggle("AutoMaestria", {
        Title       = "Auto Maestria",
        Description = "Farm focado em XP de maestria da arma equipada.",
        Default     = false,
    })
    ToggleMaestria:OnChanged(function()
        getgenv().DRONX.AutoMaestria = Options.AutoMaestria.Value
    end)

    -- ── AUTO HEAL ─────────────────────────────────────────────
    local ToggleHeal = Tabs.Main:AddToggle("AutoHeal", {
        Title       = "Auto Heal",
        Description = "Usa poção quando HP cai abaixo do limiar.",
        Default     = false,
    })
    ToggleHeal:OnChanged(function()
        getgenv().DRONX.AutoHeal = Options.AutoHeal.Value
    end)

    -- Limiar de HP (slider — 10% a 90%)
    local SliderHeal = Tabs.Main:AddSlider("HealThreshold", {
        Title       = "Limiar de Cura",
        Description = "Cura quando HP < X% do máximo.",
        Default     = 50,
        Min         = 10,
        Max         = 90,
        Rounding    = 0,
        Callback    = function(Value)
            getgenv().DRONX.HealThreshold = Value / 100
        end,
    })

    -- ── AUTO CHEST ────────────────────────────────────────────
    local ToggleChest = Tabs.Main:AddToggle("AutoChest", {
        Title       = "Auto Chest",
        Description = "Coleta baús do mapa automaticamente.",
        Default     = false,
    })
    ToggleChest:OnChanged(function()
        getgenv().DRONX.AutoChest = Options.AutoChest.Value
    end)

    -- ── AUTO QUEST ────────────────────────────────────────────
    local ToggleQuest = Tabs.Main:AddToggle("AutoQuest", {
        Title       = "Auto Quest",
        Description = "Aceita e entrega quests do NPC mais próximo.",
        Default     = false,
    })
    ToggleQuest:OnChanged(function()
        getgenv().DRONX.AutoQuest = Options.AutoQuest.Value
    end)

    -- ── AUTO BOSS ─────────────────────────────────────────────
    local ToggleBoss = Tabs.Main:AddToggle("AutoBoss", {
        Title       = "Auto Boss",
        Description = "Teleporta e ataca o boss configurado abaixo.",
        Default     = false,
    })
    ToggleBoss:OnChanged(function()
        getgenv().DRONX.AutoBoss = Options.AutoBoss.Value
    end)

    -- Nome do boss (input de texto)
    local InputBoss = Tabs.Main:AddInput("BossName", {
        Title       = "Nome do Boss",
        Default     = "",
        Placeholder = "ex: Gorilla King",
        Numeric     = false,
        Finished    = true,   -- só aplica ao pressionar Enter
        Callback    = function(Value)
            getgenv().DRONX.BossName = Value
        end,
    })

    -- ── BRING MOB ─────────────────────────────────────────────
    local ToggleBring = Tabs.Main:AddToggle("BringMob", {
        Title       = "Bring Mob",
        Description = "Puxa o NPC para perto de você durante o farm.",
        Default     = false,
    })
    ToggleBring:OnChanged(function()
        getgenv().DRONX.BringMob = Options.BringMob.Value
    end)

    -- ── TIPO DE ARMA ──────────────────────────────────────────
    local DropdownArma = Tabs.Main:AddDropdown("TipoArma", {
        Title   = "Tipo de Arma",
        Values  = { "Sword", "Gun", "Fruit", "Melee" },
        Multi   = false,
        Default = 1,
    })
    DropdownArma:OnChanged(function(Value)
        getgenv().DRONX.TipoArma = Value
        Utils.EquiparArma(Value)
    end)

    -- ── DISTÂNCIA MÁXIMA ──────────────────────────────────────
    local SliderDist = Tabs.Main:AddSlider("MaxDistance", {
        Title       = "Distância Máxima (studs)",
        Description = "Raio de detecção de NPCs e baús.",
        Default     = 1000,
        Min         = 100,
        Max         = 5000,
        Rounding    = 0,
        Callback    = function(Value)
            getgenv().DRONX.MaxDistance = Value
        end,
    })

    -- ── VELOCIDADE DE TELEPORTE ───────────────────────────────
    local SliderSpeed = Tabs.Main:AddSlider("TweenSpeed", {
        Title       = "Velocidade de TP (studs/s)",
        Description = "Mais alto = mais rápido, mais detectável.",
        Default     = 300,
        Min         = 50,
        Max         = 2000,
        Rounding    = 0,
        Callback    = function(Value)
            getgenv().DRONX.TweenSpeed = Value
        end,
    })

    -- ── ANTI-AFK ─────────────────────────────────────────────
    local ToggleAFK = Tabs.Main:AddToggle("AntiAFK", {
        Title       = "Anti-AFK",
        Description = "Previne kick por inatividade.",
        Default     = true,
    })
    ToggleAFK:OnChanged(function()
        getgenv().DRONX.AntiAFK = Options.AntiAFK.Value
    end)

    -- ── TELEPORTE MANUAL ──────────────────────────────────────
    Tabs.Main:AddButton({
        Title       = "TP para NPC mais Próximo",
        Description = "Teleporta até o alvo atual via Tween.",
        Callback    = function()
            local npc = Utils.GetClosestNPC()
            if npc then
                local hrp = npc:FindFirstChild("HumanoidRootPart")
                if hrp then
                    Movement.TweenTo(hrp.CFrame * CFrame.new(0, 0, -12))
                end
            else
                Fluent:Notify({
                    Title   = "DRONX",
                    Content = "Nenhum NPC encontrado no raio configurado.",
                    Duration = 3,
                })
            end
        end,
    })

    -- ── KILL COUNT ────────────────────────────────────────────
    -- Parágrafo dinâmico — atualiza a cada 2s via loop separado
    local KillParagraph = Tabs.Main:AddParagraph({
        Title   = "Kills nesta sessão",
        Content = "0",
    })

    task.spawn(function()
        while task.wait(2) do
            KillParagraph:Set({
                Title   = "Kills nesta sessão",
                Content = tostring(getgenv().DRONX.Kills),
            })
        end
    end)
end

-- ============================================================
-- ABA SETTINGS (SaveManager + InterfaceManager)
-- ============================================================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("DRONX")
SaveManager:SetFolder("DRONX/BloxFruits")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- ============================================================
-- INICIALIZAR
-- ============================================================
Window:SelectTab(1)

Fluent:Notify({
    Title    = "DRONX v7.0",
    Content  = "Engine carregada. Boa farm.",
    Duration = 5,
})

SaveManager:LoadAutoloadConfig()
